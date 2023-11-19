#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory space, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/
/*
------------- 进程/线程机制设计与实现 -------------
(简化的 Linux 进程/线程机制 )
简介：
  ucore实现了一种简单的进程/线程机制。进程包含独立的内存空间、至少一个执行线程、用于管理的内核数据、用于上下文切换的处理器状态、文件（在lab6中）等。
ucore需要高效管理所有这些细节。在 ucore 中，线程只是一种特殊的进程（共享内存的进程）。
------------------------------
进程状态：含义--原因
    PROC_UNINIT : 未初始化 -- alloc_proc
    PROC_SLEEPING : 休眠 -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE : 可运行（可能正在运行） -- proc_init, wakeup_proc、 
    PROC_ZOMBIE : 僵尸 -- do_exit

-----------------------------
进程状态发生变化：参见上面英文版
-----------------------------
进程关系
父进程：proc->parent（proc 是子进程）
子女：proc->cptr（proc 是父进程）
年长的同胞：proc->optr（proc 是年幼的同胞）
弟弟妹妹：proc->yptr（proc 是哥哥姐姐）
-----------------------------
进程的相关系统调用：
SYS_exit : 进程退出，-->do_exit
SYS_fork：创建子进程，dup mm -->do_fork-->wakeup_proc
SYS_wait : 等待进程 -->do_wait
SYS_exec：子进程创建后，执行进程 -->load a program and refresh the mm
SYS_clone : 创建子线程 -->do_fork-->wakeup_proc
SYS_yield：进程标记自己需要重新调度，--proc->need_sched=1，则调度程序将重新调度该进程
SYS_sleep : 进程睡眠 -->do_sleep 
SYS_kill：杀死进程-->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->doo_wait-->doo_exit   
SYS_getpid：获取进程的 pid
*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Process
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        // 参考实验指导手册：alloc_proc函数获取一块内存作为第0个进程控制块，并初始化（大体是将成员变量清零）
        proc->state = PROC_UNINIT;  // 设置进程为“未初始化”状态——即第0个内核线程（空闲进程idleproc）
        proc->pid = -1;  // 设置进程PID为未初始化值，即-1
        proc->runs = 0;  // 根据提示可知该成员变量表示进程的运行时间，初始化为0
        proc->kstack = 0;  // 进程内核栈初始化为0【kstack记录了分配给该进程/线程的内核栈的位置】
        proc->need_resched = 0;  // 是否需要重新调度以释放 CPU？当然了，我们现在处于未初始化状态，不需要进行调度
        proc->parent = NULL;  // 父进程控制块指针，第0个进程控制块诶，它是始祖！
        proc->mm = NULL;  // 进程的内存管理字段:参见lab3练习一分析；对于内核进程而言，不存在虚拟内存管理
        memset(&(proc->context), 0, sizeof(struct context));  // 上下文，现在是源头，当然为空，发生切换时修改
        proc->tf = NULL;  // 进程中断帧，初始化为空，发生中断时修改
        proc->cr3 = boot_cr3;  // 页表基址初始化——在pmm_init中初始化页表基址，实际上是satp寄存器【X86历史残留，有点想改但是由于涉及文件相对较多，万一没修改完全就寄了，索性放弃】
        proc->flags = 0;  // 进程标志位，初始化为空
        memset(proc->name, 0, PROC_NAME_LEN);  // 进程名初始化为空
        // 【好好好！！！快写完了我才发现，这个函数在proc_init中有检测是否分配正确，也就是说我可以根据它的判断条件来编写初始化函数，也就是说可以偷懒却没发现...】
    }
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);  // 用于在编译时检查 MAX_PID 是否大于 MAX_PROCESS，以确保 PID 的范围足够大以覆盖所有可能的进程。
    struct proc_struct *proc;  // 遍历进程链表时会使用的指针
    list_entry_t *list = &proc_list, *le;  // 遍历进程链表
    static int next_safe = MAX_PID, last_pid = MAX_PID;  // next_safe 用于保存下一个安全的 PID，last_pid 用于保存上一个分配的 PID。
    if (++ last_pid >= MAX_PID) {  // 如果递增后的 last_pid 超过或等于 MAX_PID，则将其重置为1，然后跳转到 inside 标签。
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {  // 如果 last_pid 大于等于 next_safe，则执行以下操作：
    inside:
        next_safe = MAX_PID;  // 将 next_safe 重置为 MAX_PID
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {  //  如果当前进程的 PID 等于 last_pid，表示该 PID 已经被使用。
                if (++ last_pid >= next_safe) {  // 如果递增后的 last_pid 超过或等于 next_safe，则执行以下操作：
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;  // 跳转到 repeat，重新检查进程链表
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {  // 如果当前进程的 PID 大于 last_pid 且小于 next_safe，则更新 next_safe 为当前进程的 PID
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        // 禁用中断
        bool interrupt_flag;
        struct proc_struct *from = current, *to = proc;
        local_intr_save(interrupt_flag);
        {
            // 切换当前进程为要运行的进程
            current = proc;
            // 切换页表，以便使用新进程的地址空间
            lcr3(to->cr3);
            // 实现上下文切换
            switch_to(&(from->context), &(to->context));
        }
        // 允许中断
        local_intr_restore(interrupt_flag);
    }
}

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    // 设置内核线程的参数和函数指针
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数
    // 设置 trapframe 中的 status 寄存器（SSTATUS）
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 模式，因为这是一个内核线程）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断，因为这是一个内核线程）
    // SSTATUS_SIE：Supervisor Interrupt Enable（设置为禁用中断，因为我们不希望该线程被中断）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;  // 错误码：没有空闲进程
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {  // 如果进程数量已达到上限，返回错误码，此时错误码表示没有空闲进程
        goto fork_out;
    }
    ret = -E_NO_MEM;  // 错误码：没有可分配内存
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */
    /*
     * 一些有用的 宏、函数和定义，你可以在下面的实现中使用它们。
     * 宏或函数：
     * alloc_proc：创建一个 proc 结构和初始化字段（lab4:exercise1）
     * setup_kstack：分配大小为 KSTACKPAGE 的页面作为进程内核栈
     * copy_mm：根据 clone_flags 复制或共享进程 "proc "的 mm，如果 clone_flags & CLONE_VM，则 "共享"；否则 "复制"。
     * copy_thread：在进程的内核堆栈顶部设置陷阱框架，并设置进程的内核入口点和栈
     * hash_proc: 将进程添加到进程 hash_list 中
     * get_pid：为进程分配唯一的 pid
     * wakeup_proc: 设置 proc->state = PROC_RUNNABLE
     * 变量：
     * proc_list：进程列表
     * nr_process：进程的数量
     */
    //    1. call alloc_proc to allocate a proc_struct 调用 alloc_proc 分配一个 proc_struct
    // 分析练习1中我们实现的进程分配函数，当返回值为NULL时是由于kmalloc(sizeof(struct proc_struct));的返回值为NULL
    // 而kmalloc函数是用于分配内存的函数，其返回值为NULL表示内存分配失败，此时错误码应该时表示内存问题，与我们前面ret = -E_NO_MEM;  // 错误码：没有可分配内存的设置一致，直接返回错误码
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    proc->parent = current;  // 子进程的父进程是当前进程
    //    2. call setup_kstack to allocate a kernel stack for child process 调用 setup_kstack 为子进程分配内核栈
    if (setup_kstack(proc) == -E_NO_MEM) {  // 检查进程内核栈分配是否成功（实际上复制了父进程的内核栈），如果返回-E_NO_MEM表示由于内存不足分配失败，我们需要处理已分配的子进程
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag 调用 copy_mm，根据 clone_flag 复制或共享 mm
    if (copy_mm(clone_flags, proc) != 0) {  // 本次实验中没有具体实现该函数功能，仅仅使用assert做判断模拟该函数错误情况，如果没有错误返回值为0，有错误那么我们需要释放初始化的子进程内核栈
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct 调用 copy_thread 在 proc_struct 中设置 tf 和 context
    copy_thread(proc, stack, tf);  // stack父节点的用户栈指针。果 stack==0，则表示fork一个内核线程。那么和esp没啥区别了吧，另外在risc-v的代码里看到X86遗迹真的好丑陋，应该是sp寄存器
    //    5. insert proc_struct into hash_list && proc_list 将 proc_struct 插入 hash_list && proc_list
    // hash_proc(proc);
    // list_add(&proc_list, &(proc->list_link));
    //【太天真了！会这么简单么？孩子，你太天真了！】
    // 现在让我们思考这样一种情况：当进程正在插入链表时，一个新的进程一脚踹开之前的进程，那么我们的前一个进程没插入，这...这不对吧？【竞争？】
    // 那么我们有什么办法可以避免这种问题么？好吧，这个问题意识到了，解决办法源于下一问
    // 去sync.h看看：
    // #define local_intr_save(x)      do { x = __intr_save(); } while (0)
    // #define local_intr_restore(x)   __intr_restore(x);
    /* 
        【GPT】
        这是两个宏定义，用于在代码中禁用和恢复中断。这些宏的目的是保护临界区，防止在执行关键代码段时被中断打断。
        这两个宏的组合允许程序员在执行一段关键代码时禁用中断，以防止中断干扰。
        在关键代码执行完成后，通过调用 local_intr_restore 宏，恢复之前保存的中断状态，保持系统的正确性和可靠性。
        这样的操作通常在实现操作系统内核或驱动程序等系统级代码时会经常使用。

        另外一个神奇的问题：这个do-while是啥？？？简单说是程序健壮性，好！从来没有考虑的东西，下面是更加详细的解释
        【GPT】
        * 语法要求： 
        do-while 结构确保宏定义始终是一个语句块，因此无论在何处使用它，都不会受到语法限制。
        在C语言中，do-while 是一种循环结构，它需要一个语句块作为循环体。通过使用 do-while (0)，即使宏在其他语法结构中被嵌套，也能够保证语法的正确性。
        这样的嵌套在实际应用中可能很少见，但是为了确保宏定义的通用性和安全性，这是一个良好的实践。

        * 强制使用花括号 {}： 
        在C语言中，如果 do-while 循环体只有一条语句，可以不使用花括号。
        然而，这可能导致在某些上下文中产生意外的结果。
        通过使用 do-while (0)，宏定义始终需要花括号，从而避免了由于宏在某些上下文中被当作单个语句而导致的问题。
    */
    bool interrupt_flag;  // 判断是否禁用中断
    local_intr_save(interrupt_flag);  // copy_thread函数中tf的实参 是tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;那么调用该函数将会禁用中断
    {  // 没别的意思，就是让下面这部分看起来更舒服，这是禁用中断后执行的一块代码
        proc->pid = get_pid();  // 获取当前pid
        hash_proc(proc);
        list_add(&proc_list, &proc->list_link);  // 这才是正确的打开方式（bushi）
        nr_process++;  // 更新进程数
    }
    local_intr_restore(interrupt_flag);  // 恢复之前的中断状态；有借有还呢
    //    6. call wakeup_proc to make the new child process RUNNABLE 调用 wakeup_proc 使新的子进程可运行
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid 使用子进程的 pid 设置 ret vaule
    ret = proc->pid;

    fork_out:
        return ret;  // 正确情况下返回子进程pid，否则返回错误码

    bad_fork_cleanup_kstack:
        put_kstack(proc);
    bad_fork_cleanup_proc:
        kfree(proc);
        goto fork_out;
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process ++;

    current = idleproc;

    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}

