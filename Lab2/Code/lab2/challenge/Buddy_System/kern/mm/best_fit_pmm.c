#include <pmm.h>
#include <list.h>
#include <string.h>
#include <best_fit_pmm.h>
#include <stdio.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 获取指数
size_t
get_exp(size_t num)
{
    size_t exp = 0;
    while (num > 1)
    {
        num >>= 1; // 右移一位，相当于除以2
        exp++;
    }
    return (size_t)(1 << exp);
}

static void
best_fit_init(void)
{
    list_init(&free_list);
    nr_free = 0;
}

static void
best_fit_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    // 为了方便实现，我们向下取整，这是一个非常偷懒的方式！！但是由于时间原因，请允许我这样操作。
    // n = (1 << get_exp(n));
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        // 清空当前页框的标志和属性信息
        p->flags = p->property = 0;
        // 将页框的引用计数设置为0
        set_page_ref(p, 0);
    }
    nr_free += n;
    // 设置base指向尚未处理内存的尾地址，从后向前初始化
    base += n;
    while (n != 0)
    {
        // 获取本轮处理内存页数
        size_t curr_n = get_exp(n);
        // 将base向前移动
        base -= curr_n;
        // 设置此时的property参数
        base->property = curr_n;
        // 标记可用
        SetPageProperty(base);
        // 我们采用按照块大小排序方式插入空闲块链表，当大小相同时的排序策略是地址
        list_entry_t *le;
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
        {
            struct Page *page = le2page(le, page_link);
            if ((page->property > base->property) || (page->property == base->property && page > base))
                break;
        }
        list_add_before(le, &(base->page_link));
        n -= curr_n;
    }
}

static struct Page *
best_fit_alloc_pages(size_t n)
{
    assert(n > 0);
    // 现在我们要向上取整来分配合适的内存
    size_t size = get_exp(n);
    if (size < n)
        n = 2 * size;
    if (n > nr_free)
    {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list)
    {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n){
            page = p;
            break;
        }
    }
    // 如果需要切割，分配切割后的前一块
    if (page != NULL)
    {
        while (page->property > n)
        {
            page->property /= 2;
            // 切割出的右边那一半内存块不用于内存分配
            struct Page *p = page + page->property;
            p->property = page->property;
            SetPageProperty(p);
            list_add_after(&(page->page_link), &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
        assert(page->property == n);
        list_del(&(page->page_link));
    }
    return page;
}

static void
best_fit_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    // 回收也是同样的，现在我们要向上取整来分配合适的内存
    size_t size = get_exp(n);
    if (size < n)
        n = 2 * size;
    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    list_entry_t *le;
    // 先插入至链表中
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
    {
        p = le2page(le, page_link);
        // 这里的条件修改：与初始化策略相似
        if ((base->property < p->property) || (base->property == p->property && base < p))
            break;
    }
    list_add_before(le, &(base->page_link));
    // 合并：合并条件如下
    /*
        - 大小相同且为2的整数次幂
        - 地址相邻
        - 低地址空闲块的起始地址为块大小的整数次幂的位数
    */

    // 1、判断前面的空闲页块是否与当前页块是连续的，相同大小的，如果是连续的且是相同大小的，则将当前页块合并到前面的空闲页块中
    if ((p->property == base->property) && (p + p->property == base))
    {
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        p->property += base->property;
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        ClearPageProperty(base);
        // 4、从链表中删除当前页块
        list_del(&(base->page_link));
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
        base = p;
        le = &(base->page_link);
    }

    // 循环向右合并

    while (le != &free_list)
    {
        p = le2page(le, page_link);
        if ((p->property == base->property) && (base + base->property == p))
        {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            le = &(base->page_link);
        }
        // 无法合并时，退出
        else if (base->property < p->property)
        {
            // 修改base在链表中的位置使大小相同的聚在一起
            list_entry_t *targetLe = list_next(&base->page_link);
            while (le2page(targetLe, page_link)->property < base->property)
                targetLe = list_next(targetLe);
            if (targetLe != list_next(&base->page_link))
            {
                list_del(&(base->page_link));
                list_add_before(targetLe, &(base->page_link));
            }
            // 最后退出
            break;
        }
        le = list_next(le);
    }
}

static size_t
best_fit_nr_free_pages(void)
{
    return nr_free;
}

static void
basic_check(void)
{
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

static void
best_fit_check(void)
{
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(26), *p1;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    //.........................................................
    // 先释放
    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
    // 首先检查是否对齐2
    p0 = alloc_pages(6);  // 8- 8+ 16+
    p1 = alloc_pages(10); // 8- 8+ 16-
    assert((p0 + 8)->property == 8);
    free_pages(p1, 10); // 8- 8+ 16+
    assert((p0 + 8)->property == 8);
    assert(p1->property == 16);
    p1 = alloc_pages(16); // 8- 8+ 16-
    // 之后检查合并
    free_pages(p0, 6); // 16+ 16-
    assert(p0->property == 16);
    free_pages(p1, 16); // 32+
    assert(p0->property == 32);

    p0 = alloc_pages(8); // 8- 8+ 16+
    p1 = alloc_pages(9); // 8- 8+ 16-
    free_pages(p1, 9);   // 8- 8+ 16+
    assert(p1->property == 16);
    assert((p0 + 8)->property == 8);
    free_pages(p0, 8); // 32+
    assert(p0->property == 32);
    // 检测链表顺序是否按照块的大小排序的
    p0 = alloc_pages(5);
    p1 = alloc_pages(16);
    free_pages(p1, 16);
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
    free_pages(p0, 5);
    assert(list_next(&(free_list)) == &(p0->page_link));

    p0 = alloc_pages(5);
    p1 = alloc_pages(16);
    free_pages(p0, 5);
    assert(list_next(&(free_list)) == &(p0->page_link));
    free_pages(p1, 16);
    assert(list_next(&(free_list)) == &(p0->page_link));

    // 还原
    p0 = alloc_pages(26);
    //.........................................................
    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 26);

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
    {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

// 这个结构体在
const struct pmm_manager best_fit_pmm_manager = {
    .name = "best_fit_pmm_manager",
    .init = best_fit_init,
    .init_memmap = best_fit_init_memmap,
    .alloc_pages = best_fit_alloc_pages,
    .free_pages = best_fit_free_pages,
    .nr_free_pages = best_fit_nr_free_pages,
    .check = best_fit_check,
};
