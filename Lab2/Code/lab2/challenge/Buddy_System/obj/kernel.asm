
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	4bf010ef          	jal	ra,ffffffffc0201d0c <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(NKUs.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	cca50513          	addi	a0,a0,-822 # ffffffffc0201d20 <etext+0x2>
ffffffffc020005e:	35e000ef          	jal	ra,ffffffffc02003bc <cputs>

    print_kerninfo();
ffffffffc0200062:	01a000ef          	jal	ra,ffffffffc020007c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	57a010ef          	jal	ra,ffffffffc02015e4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020007e:	00002517          	auipc	a0,0x2
ffffffffc0200082:	cf250513          	addi	a0,a0,-782 # ffffffffc0201d70 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200086:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200088:	2fc000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020008c:	00000597          	auipc	a1,0x0
ffffffffc0200090:	faa58593          	addi	a1,a1,-86 # ffffffffc0200036 <kern_init>
ffffffffc0200094:	00002517          	auipc	a0,0x2
ffffffffc0200098:	cfc50513          	addi	a0,a0,-772 # ffffffffc0201d90 <etext+0x72>
ffffffffc020009c:	2e8000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02000a0:	00002597          	auipc	a1,0x2
ffffffffc02000a4:	c7e58593          	addi	a1,a1,-898 # ffffffffc0201d1e <etext>
ffffffffc02000a8:	00002517          	auipc	a0,0x2
ffffffffc02000ac:	d0850513          	addi	a0,a0,-760 # ffffffffc0201db0 <etext+0x92>
ffffffffc02000b0:	2d4000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02000b4:	00006597          	auipc	a1,0x6
ffffffffc02000b8:	f5c58593          	addi	a1,a1,-164 # ffffffffc0206010 <edata>
ffffffffc02000bc:	00002517          	auipc	a0,0x2
ffffffffc02000c0:	d1450513          	addi	a0,a0,-748 # ffffffffc0201dd0 <etext+0xb2>
ffffffffc02000c4:	2c0000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02000c8:	00006597          	auipc	a1,0x6
ffffffffc02000cc:	3a858593          	addi	a1,a1,936 # ffffffffc0206470 <end>
ffffffffc02000d0:	00002517          	auipc	a0,0x2
ffffffffc02000d4:	d2050513          	addi	a0,a0,-736 # ffffffffc0201df0 <etext+0xd2>
ffffffffc02000d8:	2ac000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02000dc:	00006597          	auipc	a1,0x6
ffffffffc02000e0:	79358593          	addi	a1,a1,1939 # ffffffffc020686f <end+0x3ff>
ffffffffc02000e4:	00000797          	auipc	a5,0x0
ffffffffc02000e8:	f5278793          	addi	a5,a5,-174 # ffffffffc0200036 <kern_init>
ffffffffc02000ec:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000f0:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000f4:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000f6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000fa:	95be                	add	a1,a1,a5
ffffffffc02000fc:	85a9                	srai	a1,a1,0xa
ffffffffc02000fe:	00002517          	auipc	a0,0x2
ffffffffc0200102:	d1250513          	addi	a0,a0,-750 # ffffffffc0201e10 <etext+0xf2>
}
ffffffffc0200106:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200108:	27c0006f          	j	ffffffffc0200384 <cprintf>

ffffffffc020010c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020010c:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020010e:	00002617          	auipc	a2,0x2
ffffffffc0200112:	c3260613          	addi	a2,a2,-974 # ffffffffc0201d40 <etext+0x22>
ffffffffc0200116:	04e00593          	li	a1,78
ffffffffc020011a:	00002517          	auipc	a0,0x2
ffffffffc020011e:	c3e50513          	addi	a0,a0,-962 # ffffffffc0201d58 <etext+0x3a>
void print_stackframe(void) {
ffffffffc0200122:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200124:	1c6000ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0200128 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200128:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020012a:	00002617          	auipc	a2,0x2
ffffffffc020012e:	df660613          	addi	a2,a2,-522 # ffffffffc0201f20 <commands+0xe0>
ffffffffc0200132:	00002597          	auipc	a1,0x2
ffffffffc0200136:	e0e58593          	addi	a1,a1,-498 # ffffffffc0201f40 <commands+0x100>
ffffffffc020013a:	00002517          	auipc	a0,0x2
ffffffffc020013e:	e0e50513          	addi	a0,a0,-498 # ffffffffc0201f48 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200142:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200144:	240000ef          	jal	ra,ffffffffc0200384 <cprintf>
ffffffffc0200148:	00002617          	auipc	a2,0x2
ffffffffc020014c:	e1060613          	addi	a2,a2,-496 # ffffffffc0201f58 <commands+0x118>
ffffffffc0200150:	00002597          	auipc	a1,0x2
ffffffffc0200154:	e3058593          	addi	a1,a1,-464 # ffffffffc0201f80 <commands+0x140>
ffffffffc0200158:	00002517          	auipc	a0,0x2
ffffffffc020015c:	df050513          	addi	a0,a0,-528 # ffffffffc0201f48 <commands+0x108>
ffffffffc0200160:	224000ef          	jal	ra,ffffffffc0200384 <cprintf>
ffffffffc0200164:	00002617          	auipc	a2,0x2
ffffffffc0200168:	e2c60613          	addi	a2,a2,-468 # ffffffffc0201f90 <commands+0x150>
ffffffffc020016c:	00002597          	auipc	a1,0x2
ffffffffc0200170:	e4458593          	addi	a1,a1,-444 # ffffffffc0201fb0 <commands+0x170>
ffffffffc0200174:	00002517          	auipc	a0,0x2
ffffffffc0200178:	dd450513          	addi	a0,a0,-556 # ffffffffc0201f48 <commands+0x108>
ffffffffc020017c:	208000ef          	jal	ra,ffffffffc0200384 <cprintf>
    }
    return 0;
}
ffffffffc0200180:	60a2                	ld	ra,8(sp)
ffffffffc0200182:	4501                	li	a0,0
ffffffffc0200184:	0141                	addi	sp,sp,16
ffffffffc0200186:	8082                	ret

ffffffffc0200188 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200188:	1141                	addi	sp,sp,-16
ffffffffc020018a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020018c:	ef1ff0ef          	jal	ra,ffffffffc020007c <print_kerninfo>
    return 0;
}
ffffffffc0200190:	60a2                	ld	ra,8(sp)
ffffffffc0200192:	4501                	li	a0,0
ffffffffc0200194:	0141                	addi	sp,sp,16
ffffffffc0200196:	8082                	ret

ffffffffc0200198 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200198:	1141                	addi	sp,sp,-16
ffffffffc020019a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020019c:	f71ff0ef          	jal	ra,ffffffffc020010c <print_stackframe>
    return 0;
}
ffffffffc02001a0:	60a2                	ld	ra,8(sp)
ffffffffc02001a2:	4501                	li	a0,0
ffffffffc02001a4:	0141                	addi	sp,sp,16
ffffffffc02001a6:	8082                	ret

ffffffffc02001a8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02001a8:	7115                	addi	sp,sp,-224
ffffffffc02001aa:	e962                	sd	s8,144(sp)
ffffffffc02001ac:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001ae:	00002517          	auipc	a0,0x2
ffffffffc02001b2:	cda50513          	addi	a0,a0,-806 # ffffffffc0201e88 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02001b6:	ed86                	sd	ra,216(sp)
ffffffffc02001b8:	e9a2                	sd	s0,208(sp)
ffffffffc02001ba:	e5a6                	sd	s1,200(sp)
ffffffffc02001bc:	e1ca                	sd	s2,192(sp)
ffffffffc02001be:	fd4e                	sd	s3,184(sp)
ffffffffc02001c0:	f952                	sd	s4,176(sp)
ffffffffc02001c2:	f556                	sd	s5,168(sp)
ffffffffc02001c4:	f15a                	sd	s6,160(sp)
ffffffffc02001c6:	ed5e                	sd	s7,152(sp)
ffffffffc02001c8:	e566                	sd	s9,136(sp)
ffffffffc02001ca:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02001cc:	1b8000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02001d0:	00002517          	auipc	a0,0x2
ffffffffc02001d4:	ce050513          	addi	a0,a0,-800 # ffffffffc0201eb0 <commands+0x70>
ffffffffc02001d8:	1ac000ef          	jal	ra,ffffffffc0200384 <cprintf>
    if (tf != NULL) {
ffffffffc02001dc:	000c0563          	beqz	s8,ffffffffc02001e6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02001e0:	8562                	mv	a0,s8
ffffffffc02001e2:	468000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02001e6:	00002c97          	auipc	s9,0x2
ffffffffc02001ea:	c5ac8c93          	addi	s9,s9,-934 # ffffffffc0201e40 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02001ee:	00002997          	auipc	s3,0x2
ffffffffc02001f2:	cea98993          	addi	s3,s3,-790 # ffffffffc0201ed8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02001f6:	00002917          	auipc	s2,0x2
ffffffffc02001fa:	cea90913          	addi	s2,s2,-790 # ffffffffc0201ee0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02001fe:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200200:	00002b17          	auipc	s6,0x2
ffffffffc0200204:	ce8b0b13          	addi	s6,s6,-792 # ffffffffc0201ee8 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200208:	00002a97          	auipc	s5,0x2
ffffffffc020020c:	d38a8a93          	addi	s5,s5,-712 # ffffffffc0201f40 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200210:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200212:	854e                	mv	a0,s3
ffffffffc0200214:	177010ef          	jal	ra,ffffffffc0201b8a <readline>
ffffffffc0200218:	842a                	mv	s0,a0
ffffffffc020021a:	dd65                	beqz	a0,ffffffffc0200212 <kmonitor+0x6a>
ffffffffc020021c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200220:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200222:	c999                	beqz	a1,ffffffffc0200238 <kmonitor+0x90>
ffffffffc0200224:	854a                	mv	a0,s2
ffffffffc0200226:	2c9010ef          	jal	ra,ffffffffc0201cee <strchr>
ffffffffc020022a:	c925                	beqz	a0,ffffffffc020029a <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020022c:	00144583          	lbu	a1,1(s0)
ffffffffc0200230:	00040023          	sb	zero,0(s0)
ffffffffc0200234:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200236:	f5fd                	bnez	a1,ffffffffc0200224 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200238:	dce9                	beqz	s1,ffffffffc0200212 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020023a:	6582                	ld	a1,0(sp)
ffffffffc020023c:	00002d17          	auipc	s10,0x2
ffffffffc0200240:	c04d0d13          	addi	s10,s10,-1020 # ffffffffc0201e40 <commands>
    if (argc == 0) {
ffffffffc0200244:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200246:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200248:	0d61                	addi	s10,s10,24
ffffffffc020024a:	27b010ef          	jal	ra,ffffffffc0201cc4 <strcmp>
ffffffffc020024e:	c919                	beqz	a0,ffffffffc0200264 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200250:	2405                	addiw	s0,s0,1
ffffffffc0200252:	09740463          	beq	s0,s7,ffffffffc02002da <kmonitor+0x132>
ffffffffc0200256:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020025a:	6582                	ld	a1,0(sp)
ffffffffc020025c:	0d61                	addi	s10,s10,24
ffffffffc020025e:	267010ef          	jal	ra,ffffffffc0201cc4 <strcmp>
ffffffffc0200262:	f57d                	bnez	a0,ffffffffc0200250 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200264:	00141793          	slli	a5,s0,0x1
ffffffffc0200268:	97a2                	add	a5,a5,s0
ffffffffc020026a:	078e                	slli	a5,a5,0x3
ffffffffc020026c:	97e6                	add	a5,a5,s9
ffffffffc020026e:	6b9c                	ld	a5,16(a5)
ffffffffc0200270:	8662                	mv	a2,s8
ffffffffc0200272:	002c                	addi	a1,sp,8
ffffffffc0200274:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200278:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020027a:	f8055ce3          	bgez	a0,ffffffffc0200212 <kmonitor+0x6a>
}
ffffffffc020027e:	60ee                	ld	ra,216(sp)
ffffffffc0200280:	644e                	ld	s0,208(sp)
ffffffffc0200282:	64ae                	ld	s1,200(sp)
ffffffffc0200284:	690e                	ld	s2,192(sp)
ffffffffc0200286:	79ea                	ld	s3,184(sp)
ffffffffc0200288:	7a4a                	ld	s4,176(sp)
ffffffffc020028a:	7aaa                	ld	s5,168(sp)
ffffffffc020028c:	7b0a                	ld	s6,160(sp)
ffffffffc020028e:	6bea                	ld	s7,152(sp)
ffffffffc0200290:	6c4a                	ld	s8,144(sp)
ffffffffc0200292:	6caa                	ld	s9,136(sp)
ffffffffc0200294:	6d0a                	ld	s10,128(sp)
ffffffffc0200296:	612d                	addi	sp,sp,224
ffffffffc0200298:	8082                	ret
        if (*buf == '\0') {
ffffffffc020029a:	00044783          	lbu	a5,0(s0)
ffffffffc020029e:	dfc9                	beqz	a5,ffffffffc0200238 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02002a0:	03448863          	beq	s1,s4,ffffffffc02002d0 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02002a4:	00349793          	slli	a5,s1,0x3
ffffffffc02002a8:	0118                	addi	a4,sp,128
ffffffffc02002aa:	97ba                	add	a5,a5,a4
ffffffffc02002ac:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002b0:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02002b4:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002b6:	e591                	bnez	a1,ffffffffc02002c2 <kmonitor+0x11a>
ffffffffc02002b8:	b749                	j	ffffffffc020023a <kmonitor+0x92>
            buf ++;
ffffffffc02002ba:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002bc:	00044583          	lbu	a1,0(s0)
ffffffffc02002c0:	ddad                	beqz	a1,ffffffffc020023a <kmonitor+0x92>
ffffffffc02002c2:	854a                	mv	a0,s2
ffffffffc02002c4:	22b010ef          	jal	ra,ffffffffc0201cee <strchr>
ffffffffc02002c8:	d96d                	beqz	a0,ffffffffc02002ba <kmonitor+0x112>
ffffffffc02002ca:	00044583          	lbu	a1,0(s0)
ffffffffc02002ce:	bf91                	j	ffffffffc0200222 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002d0:	45c1                	li	a1,16
ffffffffc02002d2:	855a                	mv	a0,s6
ffffffffc02002d4:	0b0000ef          	jal	ra,ffffffffc0200384 <cprintf>
ffffffffc02002d8:	b7f1                	j	ffffffffc02002a4 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002da:	6582                	ld	a1,0(sp)
ffffffffc02002dc:	00002517          	auipc	a0,0x2
ffffffffc02002e0:	c2c50513          	addi	a0,a0,-980 # ffffffffc0201f08 <commands+0xc8>
ffffffffc02002e4:	0a0000ef          	jal	ra,ffffffffc0200384 <cprintf>
    return 0;
ffffffffc02002e8:	b72d                	j	ffffffffc0200212 <kmonitor+0x6a>

ffffffffc02002ea <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02002ea:	00006317          	auipc	t1,0x6
ffffffffc02002ee:	12630313          	addi	t1,t1,294 # ffffffffc0206410 <is_panic>
ffffffffc02002f2:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02002f6:	715d                	addi	sp,sp,-80
ffffffffc02002f8:	ec06                	sd	ra,24(sp)
ffffffffc02002fa:	e822                	sd	s0,16(sp)
ffffffffc02002fc:	f436                	sd	a3,40(sp)
ffffffffc02002fe:	f83a                	sd	a4,48(sp)
ffffffffc0200300:	fc3e                	sd	a5,56(sp)
ffffffffc0200302:	e0c2                	sd	a6,64(sp)
ffffffffc0200304:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200306:	02031c63          	bnez	t1,ffffffffc020033e <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020030a:	4785                	li	a5,1
ffffffffc020030c:	8432                	mv	s0,a2
ffffffffc020030e:	00006717          	auipc	a4,0x6
ffffffffc0200312:	10f72123          	sw	a5,258(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200316:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200318:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020031a:	85aa                	mv	a1,a0
ffffffffc020031c:	00002517          	auipc	a0,0x2
ffffffffc0200320:	ca450513          	addi	a0,a0,-860 # ffffffffc0201fc0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc0200324:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200326:	05e000ef          	jal	ra,ffffffffc0200384 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020032a:	65a2                	ld	a1,8(sp)
ffffffffc020032c:	8522                	mv	a0,s0
ffffffffc020032e:	036000ef          	jal	ra,ffffffffc0200364 <vcprintf>
    cprintf("\n");
ffffffffc0200332:	00002517          	auipc	a0,0x2
ffffffffc0200336:	b0650513          	addi	a0,a0,-1274 # ffffffffc0201e38 <etext+0x11a>
ffffffffc020033a:	04a000ef          	jal	ra,ffffffffc0200384 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020033e:	126000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200342:	4501                	li	a0,0
ffffffffc0200344:	e65ff0ef          	jal	ra,ffffffffc02001a8 <kmonitor>
ffffffffc0200348:	bfed                	j	ffffffffc0200342 <__panic+0x58>

ffffffffc020034a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020034a:	1141                	addi	sp,sp,-16
ffffffffc020034c:	e022                	sd	s0,0(sp)
ffffffffc020034e:	e406                	sd	ra,8(sp)
ffffffffc0200350:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200352:	100000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200356:	401c                	lw	a5,0(s0)
}
ffffffffc0200358:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020035a:	2785                	addiw	a5,a5,1
ffffffffc020035c:	c01c                	sw	a5,0(s0)
}
ffffffffc020035e:	6402                	ld	s0,0(sp)
ffffffffc0200360:	0141                	addi	sp,sp,16
ffffffffc0200362:	8082                	ret

ffffffffc0200364 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200364:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200366:	86ae                	mv	a3,a1
ffffffffc0200368:	862a                	mv	a2,a0
ffffffffc020036a:	006c                	addi	a1,sp,12
ffffffffc020036c:	00000517          	auipc	a0,0x0
ffffffffc0200370:	fde50513          	addi	a0,a0,-34 # ffffffffc020034a <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200374:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200376:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200378:	486010ef          	jal	ra,ffffffffc02017fe <vprintfmt>
    return cnt;
}
ffffffffc020037c:	60e2                	ld	ra,24(sp)
ffffffffc020037e:	4532                	lw	a0,12(sp)
ffffffffc0200380:	6105                	addi	sp,sp,32
ffffffffc0200382:	8082                	ret

ffffffffc0200384 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200384:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200386:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc020038a:	f42e                	sd	a1,40(sp)
ffffffffc020038c:	f832                	sd	a2,48(sp)
ffffffffc020038e:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200390:	862a                	mv	a2,a0
ffffffffc0200392:	004c                	addi	a1,sp,4
ffffffffc0200394:	00000517          	auipc	a0,0x0
ffffffffc0200398:	fb650513          	addi	a0,a0,-74 # ffffffffc020034a <cputch>
ffffffffc020039c:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc020039e:	ec06                	sd	ra,24(sp)
ffffffffc02003a0:	e0ba                	sd	a4,64(sp)
ffffffffc02003a2:	e4be                	sd	a5,72(sp)
ffffffffc02003a4:	e8c2                	sd	a6,80(sp)
ffffffffc02003a6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02003a8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02003aa:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02003ac:	452010ef          	jal	ra,ffffffffc02017fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02003b0:	60e2                	ld	ra,24(sp)
ffffffffc02003b2:	4512                	lw	a0,4(sp)
ffffffffc02003b4:	6125                	addi	sp,sp,96
ffffffffc02003b6:	8082                	ret

ffffffffc02003b8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02003b8:	09a0006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02003bc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02003bc:	1101                	addi	sp,sp,-32
ffffffffc02003be:	e822                	sd	s0,16(sp)
ffffffffc02003c0:	ec06                	sd	ra,24(sp)
ffffffffc02003c2:	e426                	sd	s1,8(sp)
ffffffffc02003c4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02003c6:	00054503          	lbu	a0,0(a0)
ffffffffc02003ca:	c51d                	beqz	a0,ffffffffc02003f8 <cputs+0x3c>
ffffffffc02003cc:	0405                	addi	s0,s0,1
ffffffffc02003ce:	4485                	li	s1,1
ffffffffc02003d0:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02003d2:	080000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc02003d6:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02003da:	0405                	addi	s0,s0,1
ffffffffc02003dc:	fff44503          	lbu	a0,-1(s0)
ffffffffc02003e0:	f96d                	bnez	a0,ffffffffc02003d2 <cputs+0x16>
ffffffffc02003e2:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02003e6:	4529                	li	a0,10
ffffffffc02003e8:	06a000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02003ec:	8522                	mv	a0,s0
ffffffffc02003ee:	60e2                	ld	ra,24(sp)
ffffffffc02003f0:	6442                	ld	s0,16(sp)
ffffffffc02003f2:	64a2                	ld	s1,8(sp)
ffffffffc02003f4:	6105                	addi	sp,sp,32
ffffffffc02003f6:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02003f8:	4405                	li	s0,1
ffffffffc02003fa:	b7f5                	j	ffffffffc02003e6 <cputs+0x2a>

ffffffffc02003fc <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02003fc:	1141                	addi	sp,sp,-16
ffffffffc02003fe:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200400:	05a000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200404:	dd75                	beqz	a0,ffffffffc0200400 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200406:	60a2                	ld	ra,8(sp)
ffffffffc0200408:	0141                	addi	sp,sp,16
ffffffffc020040a:	8082                	ret

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	041010ef          	jal	ra,ffffffffc0201c64 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	bae50513          	addi	a0,a0,-1106 # ffffffffc0201fe0 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	f49ff06f          	j	ffffffffc0200384 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	0190106f          	j	ffffffffc0201c64 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	7f20106f          	j	ffffffffc0201c48 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	0270106f          	j	ffffffffc0201c80 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	c7450513          	addi	a0,a0,-908 # ffffffffc02020f8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	ef7ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	c7c50513          	addi	a0,a0,-900 # ffffffffc0202110 <commands+0x2d0>
ffffffffc020049c:	ee9ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	c8650513          	addi	a0,a0,-890 # ffffffffc0202128 <commands+0x2e8>
ffffffffc02004aa:	edbff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	c9050513          	addi	a0,a0,-880 # ffffffffc0202140 <commands+0x300>
ffffffffc02004b8:	ecdff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0202158 <commands+0x318>
ffffffffc02004c6:	ebfff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	ca450513          	addi	a0,a0,-860 # ffffffffc0202170 <commands+0x330>
ffffffffc02004d4:	eb1ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	cae50513          	addi	a0,a0,-850 # ffffffffc0202188 <commands+0x348>
ffffffffc02004e2:	ea3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	cb850513          	addi	a0,a0,-840 # ffffffffc02021a0 <commands+0x360>
ffffffffc02004f0:	e95ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	cc250513          	addi	a0,a0,-830 # ffffffffc02021b8 <commands+0x378>
ffffffffc02004fe:	e87ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	ccc50513          	addi	a0,a0,-820 # ffffffffc02021d0 <commands+0x390>
ffffffffc020050c:	e79ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	cd650513          	addi	a0,a0,-810 # ffffffffc02021e8 <commands+0x3a8>
ffffffffc020051a:	e6bff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	ce050513          	addi	a0,a0,-800 # ffffffffc0202200 <commands+0x3c0>
ffffffffc0200528:	e5dff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	cea50513          	addi	a0,a0,-790 # ffffffffc0202218 <commands+0x3d8>
ffffffffc0200536:	e4fff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	cf450513          	addi	a0,a0,-780 # ffffffffc0202230 <commands+0x3f0>
ffffffffc0200544:	e41ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0202248 <commands+0x408>
ffffffffc0200552:	e33ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	d0850513          	addi	a0,a0,-760 # ffffffffc0202260 <commands+0x420>
ffffffffc0200560:	e25ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	d1250513          	addi	a0,a0,-750 # ffffffffc0202278 <commands+0x438>
ffffffffc020056e:	e17ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	d1c50513          	addi	a0,a0,-740 # ffffffffc0202290 <commands+0x450>
ffffffffc020057c:	e09ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	d2650513          	addi	a0,a0,-730 # ffffffffc02022a8 <commands+0x468>
ffffffffc020058a:	dfbff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	d3050513          	addi	a0,a0,-720 # ffffffffc02022c0 <commands+0x480>
ffffffffc0200598:	dedff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	d3a50513          	addi	a0,a0,-710 # ffffffffc02022d8 <commands+0x498>
ffffffffc02005a6:	ddfff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	d4450513          	addi	a0,a0,-700 # ffffffffc02022f0 <commands+0x4b0>
ffffffffc02005b4:	dd1ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	d4e50513          	addi	a0,a0,-690 # ffffffffc0202308 <commands+0x4c8>
ffffffffc02005c2:	dc3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	d5850513          	addi	a0,a0,-680 # ffffffffc0202320 <commands+0x4e0>
ffffffffc02005d0:	db5ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	d6250513          	addi	a0,a0,-670 # ffffffffc0202338 <commands+0x4f8>
ffffffffc02005de:	da7ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0202350 <commands+0x510>
ffffffffc02005ec:	d99ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	d7650513          	addi	a0,a0,-650 # ffffffffc0202368 <commands+0x528>
ffffffffc02005fa:	d8bff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	d8050513          	addi	a0,a0,-640 # ffffffffc0202380 <commands+0x540>
ffffffffc0200608:	d7dff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	d8a50513          	addi	a0,a0,-630 # ffffffffc0202398 <commands+0x558>
ffffffffc0200616:	d6fff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	d9450513          	addi	a0,a0,-620 # ffffffffc02023b0 <commands+0x570>
ffffffffc0200624:	d61ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	d9e50513          	addi	a0,a0,-610 # ffffffffc02023c8 <commands+0x588>
ffffffffc0200632:	d53ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	da450513          	addi	a0,a0,-604 # ffffffffc02023e0 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	d3fff06f          	j	ffffffffc0200384 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	da650513          	addi	a0,a0,-602 # ffffffffc02023f8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	d29ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	da650513          	addi	a0,a0,-602 # ffffffffc0202410 <commands+0x5d0>
ffffffffc0200672:	d13ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	dae50513          	addi	a0,a0,-594 # ffffffffc0202428 <commands+0x5e8>
ffffffffc0200682:	d03ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	db650513          	addi	a0,a0,-586 # ffffffffc0202440 <commands+0x600>
ffffffffc0200692:	cf3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	dba50513          	addi	a0,a0,-582 # ffffffffc0202458 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	cddff06f          	j	ffffffffc0200384 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00002717          	auipc	a4,0x2
ffffffffc02006c0:	94070713          	addi	a4,a4,-1728 # ffffffffc0201ffc <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00002517          	auipc	a0,0x2
ffffffffc02006d2:	9c250513          	addi	a0,a0,-1598 # ffffffffc0202090 <commands+0x250>
ffffffffc02006d6:	cafff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	99650513          	addi	a0,a0,-1642 # ffffffffc0202070 <commands+0x230>
ffffffffc02006e2:	ca3ff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	94a50513          	addi	a0,a0,-1718 # ffffffffc0202030 <commands+0x1f0>
ffffffffc02006ee:	c97ff06f          	j	ffffffffc0200384 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	9be50513          	addi	a0,a0,-1602 # ffffffffc02020b0 <commands+0x270>
ffffffffc02006fa:	c8bff06f          	j	ffffffffc0200384 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02020d8 <commands+0x298>
ffffffffc0200732:	c53ff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00002517          	auipc	a0,0x2
ffffffffc020073a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0202050 <commands+0x210>
ffffffffc020073e:	c47ff06f          	j	ffffffffc0200384 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00002517          	auipc	a0,0x2
ffffffffc0200750:	97c50513          	addi	a0,a0,-1668 # ffffffffc02020c8 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	c2fff06f          	j	ffffffffc0200384 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)

static void
best_fit_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <best_fit_nr_free_pages>:

static size_t
best_fit_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <best_fit_check>:
    free_page(p2);
}

static void
best_fit_check(void)
{
ffffffffc0200846:	715d                	addi	sp,sp,-80
ffffffffc0200848:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084a:	00006917          	auipc	s2,0x6
ffffffffc020084e:	bee90913          	addi	s2,s2,-1042 # ffffffffc0206438 <free_area>
ffffffffc0200852:	00893783          	ld	a5,8(s2)
ffffffffc0200856:	e486                	sd	ra,72(sp)
ffffffffc0200858:	e0a2                	sd	s0,64(sp)
ffffffffc020085a:	fc26                	sd	s1,56(sp)
ffffffffc020085c:	f44e                	sd	s3,40(sp)
ffffffffc020085e:	f052                	sd	s4,32(sp)
ffffffffc0200860:	ec56                	sd	s5,24(sp)
ffffffffc0200862:	e85a                	sd	s6,16(sp)
ffffffffc0200864:	e45e                	sd	s7,8(sp)
ffffffffc0200866:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200868:	39278463          	beq	a5,s2,ffffffffc0200bf0 <best_fit_check+0x3aa>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020086c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200870:	8305                	srli	a4,a4,0x1
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200872:	8b05                	andi	a4,a4,1
ffffffffc0200874:	3a070263          	beqz	a4,ffffffffc0200c18 <best_fit_check+0x3d2>
    int count = 0, total = 0;
ffffffffc0200878:	4401                	li	s0,0
ffffffffc020087a:	4481                	li	s1,0
ffffffffc020087c:	a031                	j	ffffffffc0200888 <best_fit_check+0x42>
ffffffffc020087e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200882:	8b09                	andi	a4,a4,2
ffffffffc0200884:	38070a63          	beqz	a4,ffffffffc0200c18 <best_fit_check+0x3d2>
        count++, total += p->property;
ffffffffc0200888:	ff87a703          	lw	a4,-8(a5)
ffffffffc020088c:	679c                	ld	a5,8(a5)
ffffffffc020088e:	2485                	addiw	s1,s1,1
ffffffffc0200890:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200892:	ff2796e3          	bne	a5,s2,ffffffffc020087e <best_fit_check+0x38>
ffffffffc0200896:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200898:	50d000ef          	jal	ra,ffffffffc02015a4 <nr_free_pages>
ffffffffc020089c:	5f351e63          	bne	a0,s3,ffffffffc0200e98 <best_fit_check+0x652>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008a0:	4505                	li	a0,1
ffffffffc02008a2:	479000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02008a6:	8aaa                	mv	s5,a0
ffffffffc02008a8:	7a050863          	beqz	a0,ffffffffc0201058 <best_fit_check+0x812>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008ac:	4505                	li	a0,1
ffffffffc02008ae:	46d000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02008b2:	8a2a                	mv	s4,a0
ffffffffc02008b4:	78050263          	beqz	a0,ffffffffc0201038 <best_fit_check+0x7f2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008b8:	4505                	li	a0,1
ffffffffc02008ba:	461000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02008be:	89aa                	mv	s3,a0
ffffffffc02008c0:	50050c63          	beqz	a0,ffffffffc0200dd8 <best_fit_check+0x592>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02008c4:	7f4a8a63          	beq	s5,s4,ffffffffc02010b8 <best_fit_check+0x872>
ffffffffc02008c8:	7eaa8863          	beq	s5,a0,ffffffffc02010b8 <best_fit_check+0x872>
ffffffffc02008cc:	7eaa0663          	beq	s4,a0,ffffffffc02010b8 <best_fit_check+0x872>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02008d0:	000aa783          	lw	a5,0(s5)
ffffffffc02008d4:	7c079263          	bnez	a5,ffffffffc0201098 <best_fit_check+0x852>
ffffffffc02008d8:	000a2783          	lw	a5,0(s4)
ffffffffc02008dc:	7a079e63          	bnez	a5,ffffffffc0201098 <best_fit_check+0x852>
ffffffffc02008e0:	411c                	lw	a5,0(a0)
ffffffffc02008e2:	7a079b63          	bnez	a5,ffffffffc0201098 <best_fit_check+0x852>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e6:	00006797          	auipc	a5,0x6
ffffffffc02008ea:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206468 <pages>
ffffffffc02008ee:	639c                	ld	a5,0(a5)
ffffffffc02008f0:	00002717          	auipc	a4,0x2
ffffffffc02008f4:	b9870713          	addi	a4,a4,-1128 # ffffffffc0202488 <commands+0x648>
ffffffffc02008f8:	630c                	ld	a1,0(a4)
ffffffffc02008fa:	40fa8733          	sub	a4,s5,a5
ffffffffc02008fe:	870d                	srai	a4,a4,0x3
ffffffffc0200900:	02b70733          	mul	a4,a4,a1
ffffffffc0200904:	00002697          	auipc	a3,0x2
ffffffffc0200908:	2c468693          	addi	a3,a3,708 # ffffffffc0202bc8 <nbase>
ffffffffc020090c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020090e:	00006697          	auipc	a3,0x6
ffffffffc0200912:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0206418 <npage>
ffffffffc0200916:	6294                	ld	a3,0(a3)
ffffffffc0200918:	06b2                	slli	a3,a3,0xc
ffffffffc020091a:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020091c:	0732                	slli	a4,a4,0xc
ffffffffc020091e:	74d77d63          	bleu	a3,a4,ffffffffc0201078 <best_fit_check+0x832>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200922:	40fa0733          	sub	a4,s4,a5
ffffffffc0200926:	870d                	srai	a4,a4,0x3
ffffffffc0200928:	02b70733          	mul	a4,a4,a1
ffffffffc020092c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020092e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200930:	5ad77463          	bleu	a3,a4,ffffffffc0200ed8 <best_fit_check+0x692>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200934:	40f507b3          	sub	a5,a0,a5
ffffffffc0200938:	878d                	srai	a5,a5,0x3
ffffffffc020093a:	02b787b3          	mul	a5,a5,a1
ffffffffc020093e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200940:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200942:	36d7fb63          	bleu	a3,a5,ffffffffc0200cb8 <best_fit_check+0x472>
    assert(alloc_page() == NULL);
ffffffffc0200946:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200948:	00093c03          	ld	s8,0(s2)
ffffffffc020094c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200950:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200954:	00006797          	auipc	a5,0x6
ffffffffc0200958:	af27b623          	sd	s2,-1300(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc020095c:	00006797          	auipc	a5,0x6
ffffffffc0200960:	ad27be23          	sd	s2,-1316(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200964:	00006797          	auipc	a5,0x6
ffffffffc0200968:	ae07a223          	sw	zero,-1308(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020096c:	3af000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200970:	32051463          	bnez	a0,ffffffffc0200c98 <best_fit_check+0x452>
    free_page(p0);
ffffffffc0200974:	4585                	li	a1,1
ffffffffc0200976:	8556                	mv	a0,s5
ffffffffc0200978:	3e7000ef          	jal	ra,ffffffffc020155e <free_pages>
    free_page(p1);
ffffffffc020097c:	4585                	li	a1,1
ffffffffc020097e:	8552                	mv	a0,s4
ffffffffc0200980:	3df000ef          	jal	ra,ffffffffc020155e <free_pages>
    free_page(p2);
ffffffffc0200984:	4585                	li	a1,1
ffffffffc0200986:	854e                	mv	a0,s3
ffffffffc0200988:	3d7000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(nr_free == 3);
ffffffffc020098c:	01092703          	lw	a4,16(s2)
ffffffffc0200990:	478d                	li	a5,3
ffffffffc0200992:	2ef71363          	bne	a4,a5,ffffffffc0200c78 <best_fit_check+0x432>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200996:	4505                	li	a0,1
ffffffffc0200998:	383000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc020099c:	89aa                	mv	s3,a0
ffffffffc020099e:	2a050d63          	beqz	a0,ffffffffc0200c58 <best_fit_check+0x412>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009a2:	4505                	li	a0,1
ffffffffc02009a4:	377000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02009a8:	8aaa                	mv	s5,a0
ffffffffc02009aa:	34050763          	beqz	a0,ffffffffc0200cf8 <best_fit_check+0x4b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009ae:	4505                	li	a0,1
ffffffffc02009b0:	36b000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02009b4:	8a2a                	mv	s4,a0
ffffffffc02009b6:	32050163          	beqz	a0,ffffffffc0200cd8 <best_fit_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc02009ba:	4505                	li	a0,1
ffffffffc02009bc:	35f000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02009c0:	42051c63          	bnez	a0,ffffffffc0200df8 <best_fit_check+0x5b2>
    free_page(p0);
ffffffffc02009c4:	4585                	li	a1,1
ffffffffc02009c6:	854e                	mv	a0,s3
ffffffffc02009c8:	397000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02009cc:	00893783          	ld	a5,8(s2)
ffffffffc02009d0:	27278463          	beq	a5,s2,ffffffffc0200c38 <best_fit_check+0x3f2>
    assert((p = alloc_page()) == p0);
ffffffffc02009d4:	4505                	li	a0,1
ffffffffc02009d6:	345000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02009da:	38a99f63          	bne	s3,a0,ffffffffc0200d78 <best_fit_check+0x532>
    assert(alloc_page() == NULL);
ffffffffc02009de:	4505                	li	a0,1
ffffffffc02009e0:	33b000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc02009e4:	36051a63          	bnez	a0,ffffffffc0200d58 <best_fit_check+0x512>
    assert(nr_free == 0);
ffffffffc02009e8:	01092783          	lw	a5,16(s2)
ffffffffc02009ec:	34079663          	bnez	a5,ffffffffc0200d38 <best_fit_check+0x4f2>
    free_page(p);
ffffffffc02009f0:	854e                	mv	a0,s3
ffffffffc02009f2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009f4:	00006797          	auipc	a5,0x6
ffffffffc02009f8:	a587b223          	sd	s8,-1468(a5) # ffffffffc0206438 <free_area>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a577b223          	sd	s7,-1468(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a04:	00006797          	auipc	a5,0x6
ffffffffc0200a08:	a567a223          	sw	s6,-1468(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200a0c:	353000ef          	jal	ra,ffffffffc020155e <free_pages>
    free_page(p1);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	34b000ef          	jal	ra,ffffffffc020155e <free_pages>
    free_page(p2);
ffffffffc0200a18:	4585                	li	a1,1
ffffffffc0200a1a:	8552                	mv	a0,s4
ffffffffc0200a1c:	343000ef          	jal	ra,ffffffffc020155e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(26), *p1;
ffffffffc0200a20:	4569                	li	a0,26
ffffffffc0200a22:	2f9000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200a26:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a28:	2e050863          	beqz	a0,ffffffffc0200d18 <best_fit_check+0x4d2>
ffffffffc0200a2c:	651c                	ld	a5,8(a0)
ffffffffc0200a2e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a30:	8b85                	andi	a5,a5,1
ffffffffc0200a32:	38079363          	bnez	a5,ffffffffc0200db8 <best_fit_check+0x572>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a36:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a38:	00093b03          	ld	s6,0(s2)
ffffffffc0200a3c:	00893a83          	ld	s5,8(s2)
ffffffffc0200a40:	00006797          	auipc	a5,0x6
ffffffffc0200a44:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206438 <free_area>
ffffffffc0200a48:	00006797          	auipc	a5,0x6
ffffffffc0200a4c:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200a50:	2cb000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200a54:	34051263          	bnez	a0,ffffffffc0200d98 <best_fit_check+0x552>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    //.........................................................
    // 先释放
    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
ffffffffc0200a58:	45e9                	li	a1,26
ffffffffc0200a5a:	854e                	mv	a0,s3
    unsigned int nr_free_store = nr_free;
ffffffffc0200a5c:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200a60:	00006797          	auipc	a5,0x6
ffffffffc0200a64:	9e07a423          	sw	zero,-1560(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0, 26); // 32+  (-:已分配 +: 已释放)
ffffffffc0200a68:	2f7000ef          	jal	ra,ffffffffc020155e <free_pages>
    // 首先检查是否对齐2
    p0 = alloc_pages(6);  // 8- 8+ 16+
ffffffffc0200a6c:	4519                	li	a0,6
ffffffffc0200a6e:	2ad000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200a72:	89aa                	mv	s3,a0
    p1 = alloc_pages(10); // 8- 8+ 16-
ffffffffc0200a74:	4529                	li	a0,10
ffffffffc0200a76:	2a5000ef          	jal	ra,ffffffffc020151a <alloc_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a7a:	1509aa03          	lw	s4,336(s3)
ffffffffc0200a7e:	47a1                	li	a5,8
    p1 = alloc_pages(10); // 8- 8+ 16-
ffffffffc0200a80:	8c2a                	mv	s8,a0
    assert((p0 + 8)->property == 8);
ffffffffc0200a82:	56fa1b63          	bne	s4,a5,ffffffffc0200ff8 <best_fit_check+0x7b2>
    free_pages(p1, 10); // 8- 8+ 16+
ffffffffc0200a86:	45a9                	li	a1,10
ffffffffc0200a88:	2d7000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert((p0 + 8)->property == 8);
ffffffffc0200a8c:	1509a783          	lw	a5,336(s3)
ffffffffc0200a90:	55479463          	bne	a5,s4,ffffffffc0200fd8 <best_fit_check+0x792>
    assert(p1->property == 16);
ffffffffc0200a94:	010c2a03          	lw	s4,16(s8)
ffffffffc0200a98:	47c1                	li	a5,16
ffffffffc0200a9a:	50fa1f63          	bne	s4,a5,ffffffffc0200fb8 <best_fit_check+0x772>
    p1 = alloc_pages(16); // 8- 8+ 16-
ffffffffc0200a9e:	4541                	li	a0,16
ffffffffc0200aa0:	27b000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200aa4:	8c2a                	mv	s8,a0
    // 之后检查合并
    free_pages(p0, 6); // 16+ 16-
ffffffffc0200aa6:	4599                	li	a1,6
ffffffffc0200aa8:	854e                	mv	a0,s3
ffffffffc0200aaa:	2b5000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(p0->property == 16);
ffffffffc0200aae:	0109a783          	lw	a5,16(s3)
ffffffffc0200ab2:	4f479363          	bne	a5,s4,ffffffffc0200f98 <best_fit_check+0x752>
    free_pages(p1, 16); // 32+
ffffffffc0200ab6:	45c1                	li	a1,16
ffffffffc0200ab8:	8562                	mv	a0,s8
ffffffffc0200aba:	2a5000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(p0->property == 32);
ffffffffc0200abe:	0109aa03          	lw	s4,16(s3)
ffffffffc0200ac2:	02000793          	li	a5,32
ffffffffc0200ac6:	4afa1963          	bne	s4,a5,ffffffffc0200f78 <best_fit_check+0x732>

    p0 = alloc_pages(8); // 8- 8+ 16+
ffffffffc0200aca:	4521                	li	a0,8
ffffffffc0200acc:	24f000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200ad0:	89aa                	mv	s3,a0
    p1 = alloc_pages(9); // 8- 8+ 16-
ffffffffc0200ad2:	4525                	li	a0,9
ffffffffc0200ad4:	247000ef          	jal	ra,ffffffffc020151a <alloc_pages>
    free_pages(p1, 9);   // 8- 8+ 16+
ffffffffc0200ad8:	45a5                	li	a1,9
    p1 = alloc_pages(9); // 8- 8+ 16-
ffffffffc0200ada:	8c2a                	mv	s8,a0
    free_pages(p1, 9);   // 8- 8+ 16+
ffffffffc0200adc:	283000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(p1->property == 16);
ffffffffc0200ae0:	010c2703          	lw	a4,16(s8)
ffffffffc0200ae4:	47c1                	li	a5,16
ffffffffc0200ae6:	46f71963          	bne	a4,a5,ffffffffc0200f58 <best_fit_check+0x712>
    assert((p0 + 8)->property == 8);
ffffffffc0200aea:	1509a703          	lw	a4,336(s3)
ffffffffc0200aee:	47a1                	li	a5,8
ffffffffc0200af0:	44f71463          	bne	a4,a5,ffffffffc0200f38 <best_fit_check+0x6f2>
    free_pages(p0, 8); // 32+
ffffffffc0200af4:	45a1                	li	a1,8
ffffffffc0200af6:	854e                	mv	a0,s3
ffffffffc0200af8:	267000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(p0->property == 32);
ffffffffc0200afc:	0109a783          	lw	a5,16(s3)
ffffffffc0200b00:	41479c63          	bne	a5,s4,ffffffffc0200f18 <best_fit_check+0x6d2>
    // 检测链表顺序是否按照块的大小排序的
    p0 = alloc_pages(5);
ffffffffc0200b04:	4515                	li	a0,5
ffffffffc0200b06:	215000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200b0a:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200b0c:	4541                	li	a0,16
ffffffffc0200b0e:	20d000ef          	jal	ra,ffffffffc020151a <alloc_pages>
    free_pages(p1, 16);
ffffffffc0200b12:	45c1                	li	a1,16
    p1 = alloc_pages(16);
ffffffffc0200b14:	8a2a                	mv	s4,a0
    free_pages(p1, 16);
ffffffffc0200b16:	249000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200b1a:	00893783          	ld	a5,8(s2)
ffffffffc0200b1e:	ed8a0a13          	addi	s4,s4,-296
ffffffffc0200b22:	3d479b63          	bne	a5,s4,ffffffffc0200ef8 <best_fit_check+0x6b2>
    free_pages(p0, 5);
ffffffffc0200b26:	854e                	mv	a0,s3
ffffffffc0200b28:	4595                	li	a1,5
ffffffffc0200b2a:	235000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200b2e:	00893783          	ld	a5,8(s2)
ffffffffc0200b32:	09e1                	addi	s3,s3,24
ffffffffc0200b34:	33379263          	bne	a5,s3,ffffffffc0200e58 <best_fit_check+0x612>

    p0 = alloc_pages(5);
ffffffffc0200b38:	4515                	li	a0,5
ffffffffc0200b3a:	1e1000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200b3e:	89aa                	mv	s3,a0
    p1 = alloc_pages(16);
ffffffffc0200b40:	4541                	li	a0,16
ffffffffc0200b42:	1d9000ef          	jal	ra,ffffffffc020151a <alloc_pages>
ffffffffc0200b46:	8a2a                	mv	s4,a0
    free_pages(p0, 5);
ffffffffc0200b48:	4595                	li	a1,5
ffffffffc0200b4a:	854e                	mv	a0,s3
ffffffffc0200b4c:	213000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200b50:	00893783          	ld	a5,8(s2)
ffffffffc0200b54:	09e1                	addi	s3,s3,24
ffffffffc0200b56:	2ef99163          	bne	s3,a5,ffffffffc0200e38 <best_fit_check+0x5f2>
    free_pages(p1, 16);
ffffffffc0200b5a:	45c1                	li	a1,16
ffffffffc0200b5c:	8552                	mv	a0,s4
ffffffffc0200b5e:	201000ef          	jal	ra,ffffffffc020155e <free_pages>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200b62:	00893783          	ld	a5,8(s2)
ffffffffc0200b66:	2af99963          	bne	s3,a5,ffffffffc0200e18 <best_fit_check+0x5d2>

    // 还原
    p0 = alloc_pages(26);
ffffffffc0200b6a:	4569                	li	a0,26
ffffffffc0200b6c:	1af000ef          	jal	ra,ffffffffc020151a <alloc_pages>
    //.........................................................
    assert(nr_free == 0);
ffffffffc0200b70:	01092783          	lw	a5,16(s2)
ffffffffc0200b74:	34079263          	bnez	a5,ffffffffc0200eb8 <best_fit_check+0x672>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 26);
ffffffffc0200b78:	45e9                	li	a1,26
    nr_free = nr_free_store;
ffffffffc0200b7a:	00006797          	auipc	a5,0x6
ffffffffc0200b7e:	8d77a723          	sw	s7,-1842(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200b82:	00006797          	auipc	a5,0x6
ffffffffc0200b86:	8b67bb23          	sd	s6,-1866(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b8a:	00006797          	auipc	a5,0x6
ffffffffc0200b8e:	8b57bb23          	sd	s5,-1866(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 26);
ffffffffc0200b92:	1cd000ef          	jal	ra,ffffffffc020155e <free_pages>
    return listelm->next;
ffffffffc0200b96:	00893703          	ld	a4,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200b9a:	03270b63          	beq	a4,s2,ffffffffc0200bd0 <best_fit_check+0x38a>
    {
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200b9e:	671c                	ld	a5,8(a4)
ffffffffc0200ba0:	6394                	ld	a3,0(a5)
ffffffffc0200ba2:	04d71b63          	bne	a4,a3,ffffffffc0200bf8 <best_fit_check+0x3b2>
ffffffffc0200ba6:	6314                	ld	a3,0(a4)
ffffffffc0200ba8:	6694                	ld	a3,8(a3)
ffffffffc0200baa:	00e68d63          	beq	a3,a4,ffffffffc0200bc4 <best_fit_check+0x37e>
ffffffffc0200bae:	a0a9                	j	ffffffffc0200bf8 <best_fit_check+0x3b2>
ffffffffc0200bb0:	6794                	ld	a3,8(a5)
ffffffffc0200bb2:	6298                	ld	a4,0(a3)
ffffffffc0200bb4:	04f71263          	bne	a4,a5,ffffffffc0200bf8 <best_fit_check+0x3b2>
ffffffffc0200bb8:	6390                	ld	a2,0(a5)
ffffffffc0200bba:	873e                	mv	a4,a5
ffffffffc0200bbc:	661c                	ld	a5,8(a2)
ffffffffc0200bbe:	02e79d63          	bne	a5,a4,ffffffffc0200bf8 <best_fit_check+0x3b2>
ffffffffc0200bc2:	87b6                	mv	a5,a3
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0200bc4:	ff872703          	lw	a4,-8(a4)
ffffffffc0200bc8:	34fd                	addiw	s1,s1,-1
ffffffffc0200bca:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200bcc:	ff2792e3          	bne	a5,s2,ffffffffc0200bb0 <best_fit_check+0x36a>
    }
    assert(count == 0);
ffffffffc0200bd0:	44049463          	bnez	s1,ffffffffc0201018 <best_fit_check+0x7d2>
    assert(total == 0);
ffffffffc0200bd4:	2a041263          	bnez	s0,ffffffffc0200e78 <best_fit_check+0x632>
}
ffffffffc0200bd8:	60a6                	ld	ra,72(sp)
ffffffffc0200bda:	6406                	ld	s0,64(sp)
ffffffffc0200bdc:	74e2                	ld	s1,56(sp)
ffffffffc0200bde:	7942                	ld	s2,48(sp)
ffffffffc0200be0:	79a2                	ld	s3,40(sp)
ffffffffc0200be2:	7a02                	ld	s4,32(sp)
ffffffffc0200be4:	6ae2                	ld	s5,24(sp)
ffffffffc0200be6:	6b42                	ld	s6,16(sp)
ffffffffc0200be8:	6ba2                	ld	s7,8(sp)
ffffffffc0200bea:	6c02                	ld	s8,0(sp)
ffffffffc0200bec:	6161                	addi	sp,sp,80
ffffffffc0200bee:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0200bf0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bf2:	4401                	li	s0,0
ffffffffc0200bf4:	4481                	li	s1,0
ffffffffc0200bf6:	b14d                	j	ffffffffc0200898 <best_fit_check+0x52>
        assert(le->next->prev == le && le->prev->next == le);
ffffffffc0200bf8:	00002697          	auipc	a3,0x2
ffffffffc0200bfc:	b8068693          	addi	a3,a3,-1152 # ffffffffc0202778 <commands+0x938>
ffffffffc0200c00:	00002617          	auipc	a2,0x2
ffffffffc0200c04:	8a060613          	addi	a2,a2,-1888 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200c08:	14e00593          	li	a1,334
ffffffffc0200c0c:	00002517          	auipc	a0,0x2
ffffffffc0200c10:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200c14:	ed6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
        assert(PageProperty(p));
ffffffffc0200c18:	00002697          	auipc	a3,0x2
ffffffffc0200c1c:	87868693          	addi	a3,a3,-1928 # ffffffffc0202490 <commands+0x650>
ffffffffc0200c20:	00002617          	auipc	a2,0x2
ffffffffc0200c24:	88060613          	addi	a2,a2,-1920 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200c28:	10900593          	li	a1,265
ffffffffc0200c2c:	00002517          	auipc	a0,0x2
ffffffffc0200c30:	88c50513          	addi	a0,a0,-1908 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200c34:	eb6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c38:	00002697          	auipc	a3,0x2
ffffffffc0200c3c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0202640 <commands+0x800>
ffffffffc0200c40:	00002617          	auipc	a2,0x2
ffffffffc0200c44:	86060613          	addi	a2,a2,-1952 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200c48:	0f200593          	li	a1,242
ffffffffc0200c4c:	00002517          	auipc	a0,0x2
ffffffffc0200c50:	86c50513          	addi	a0,a0,-1940 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200c54:	e96ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c58:	00002697          	auipc	a3,0x2
ffffffffc0200c5c:	89868693          	addi	a3,a3,-1896 # ffffffffc02024f0 <commands+0x6b0>
ffffffffc0200c60:	00002617          	auipc	a2,0x2
ffffffffc0200c64:	84060613          	addi	a2,a2,-1984 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200c68:	0eb00593          	li	a1,235
ffffffffc0200c6c:	00002517          	auipc	a0,0x2
ffffffffc0200c70:	84c50513          	addi	a0,a0,-1972 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200c74:	e76ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 3);
ffffffffc0200c78:	00002697          	auipc	a3,0x2
ffffffffc0200c7c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0202630 <commands+0x7f0>
ffffffffc0200c80:	00002617          	auipc	a2,0x2
ffffffffc0200c84:	82060613          	addi	a2,a2,-2016 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200c88:	0e900593          	li	a1,233
ffffffffc0200c8c:	00002517          	auipc	a0,0x2
ffffffffc0200c90:	82c50513          	addi	a0,a0,-2004 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200c94:	e56ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c98:	00002697          	auipc	a3,0x2
ffffffffc0200c9c:	98068693          	addi	a3,a3,-1664 # ffffffffc0202618 <commands+0x7d8>
ffffffffc0200ca0:	00002617          	auipc	a2,0x2
ffffffffc0200ca4:	80060613          	addi	a2,a2,-2048 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200ca8:	0e400593          	li	a1,228
ffffffffc0200cac:	00002517          	auipc	a0,0x2
ffffffffc0200cb0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200cb4:	e36ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cb8:	00002697          	auipc	a3,0x2
ffffffffc0200cbc:	94068693          	addi	a3,a3,-1728 # ffffffffc02025f8 <commands+0x7b8>
ffffffffc0200cc0:	00001617          	auipc	a2,0x1
ffffffffc0200cc4:	7e060613          	addi	a2,a2,2016 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200cc8:	0db00593          	li	a1,219
ffffffffc0200ccc:	00001517          	auipc	a0,0x1
ffffffffc0200cd0:	7ec50513          	addi	a0,a0,2028 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200cd4:	e16ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cd8:	00002697          	auipc	a3,0x2
ffffffffc0200cdc:	85868693          	addi	a3,a3,-1960 # ffffffffc0202530 <commands+0x6f0>
ffffffffc0200ce0:	00001617          	auipc	a2,0x1
ffffffffc0200ce4:	7c060613          	addi	a2,a2,1984 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200ce8:	0ed00593          	li	a1,237
ffffffffc0200cec:	00001517          	auipc	a0,0x1
ffffffffc0200cf0:	7cc50513          	addi	a0,a0,1996 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200cf4:	df6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cf8:	00002697          	auipc	a3,0x2
ffffffffc0200cfc:	81868693          	addi	a3,a3,-2024 # ffffffffc0202510 <commands+0x6d0>
ffffffffc0200d00:	00001617          	auipc	a2,0x1
ffffffffc0200d04:	7a060613          	addi	a2,a2,1952 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200d08:	0ec00593          	li	a1,236
ffffffffc0200d0c:	00001517          	auipc	a0,0x1
ffffffffc0200d10:	7ac50513          	addi	a0,a0,1964 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200d14:	dd6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != NULL);
ffffffffc0200d18:	00002697          	auipc	a3,0x2
ffffffffc0200d1c:	97068693          	addi	a3,a3,-1680 # ffffffffc0202688 <commands+0x848>
ffffffffc0200d20:	00001617          	auipc	a2,0x1
ffffffffc0200d24:	78060613          	addi	a2,a2,1920 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200d28:	11100593          	li	a1,273
ffffffffc0200d2c:	00001517          	auipc	a0,0x1
ffffffffc0200d30:	78c50513          	addi	a0,a0,1932 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200d34:	db6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200d38:	00002697          	auipc	a3,0x2
ffffffffc0200d3c:	94068693          	addi	a3,a3,-1728 # ffffffffc0202678 <commands+0x838>
ffffffffc0200d40:	00001617          	auipc	a2,0x1
ffffffffc0200d44:	76060613          	addi	a2,a2,1888 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200d48:	0f800593          	li	a1,248
ffffffffc0200d4c:	00001517          	auipc	a0,0x1
ffffffffc0200d50:	76c50513          	addi	a0,a0,1900 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200d54:	d96ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d58:	00002697          	auipc	a3,0x2
ffffffffc0200d5c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0202618 <commands+0x7d8>
ffffffffc0200d60:	00001617          	auipc	a2,0x1
ffffffffc0200d64:	74060613          	addi	a2,a2,1856 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200d68:	0f600593          	li	a1,246
ffffffffc0200d6c:	00001517          	auipc	a0,0x1
ffffffffc0200d70:	74c50513          	addi	a0,a0,1868 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200d74:	d76ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d78:	00002697          	auipc	a3,0x2
ffffffffc0200d7c:	8e068693          	addi	a3,a3,-1824 # ffffffffc0202658 <commands+0x818>
ffffffffc0200d80:	00001617          	auipc	a2,0x1
ffffffffc0200d84:	72060613          	addi	a2,a2,1824 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200d88:	0f500593          	li	a1,245
ffffffffc0200d8c:	00001517          	auipc	a0,0x1
ffffffffc0200d90:	72c50513          	addi	a0,a0,1836 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200d94:	d56ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d98:	00002697          	auipc	a3,0x2
ffffffffc0200d9c:	88068693          	addi	a3,a3,-1920 # ffffffffc0202618 <commands+0x7d8>
ffffffffc0200da0:	00001617          	auipc	a2,0x1
ffffffffc0200da4:	70060613          	addi	a2,a2,1792 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200da8:	11700593          	li	a1,279
ffffffffc0200dac:	00001517          	auipc	a0,0x1
ffffffffc0200db0:	70c50513          	addi	a0,a0,1804 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200db4:	d36ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!PageProperty(p0));
ffffffffc0200db8:	00002697          	auipc	a3,0x2
ffffffffc0200dbc:	8e068693          	addi	a3,a3,-1824 # ffffffffc0202698 <commands+0x858>
ffffffffc0200dc0:	00001617          	auipc	a2,0x1
ffffffffc0200dc4:	6e060613          	addi	a2,a2,1760 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200dc8:	11200593          	li	a1,274
ffffffffc0200dcc:	00001517          	auipc	a0,0x1
ffffffffc0200dd0:	6ec50513          	addi	a0,a0,1772 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200dd4:	d16ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200dd8:	00001697          	auipc	a3,0x1
ffffffffc0200ddc:	75868693          	addi	a3,a3,1880 # ffffffffc0202530 <commands+0x6f0>
ffffffffc0200de0:	00001617          	auipc	a2,0x1
ffffffffc0200de4:	6c060613          	addi	a2,a2,1728 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200de8:	0d400593          	li	a1,212
ffffffffc0200dec:	00001517          	auipc	a0,0x1
ffffffffc0200df0:	6cc50513          	addi	a0,a0,1740 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200df4:	cf6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200df8:	00002697          	auipc	a3,0x2
ffffffffc0200dfc:	82068693          	addi	a3,a3,-2016 # ffffffffc0202618 <commands+0x7d8>
ffffffffc0200e00:	00001617          	auipc	a2,0x1
ffffffffc0200e04:	6a060613          	addi	a2,a2,1696 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200e08:	0ef00593          	li	a1,239
ffffffffc0200e0c:	00001517          	auipc	a0,0x1
ffffffffc0200e10:	6ac50513          	addi	a0,a0,1708 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200e14:	cd6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200e18:	00002697          	auipc	a3,0x2
ffffffffc0200e1c:	93068693          	addi	a3,a3,-1744 # ffffffffc0202748 <commands+0x908>
ffffffffc0200e20:	00001617          	auipc	a2,0x1
ffffffffc0200e24:	68060613          	addi	a2,a2,1664 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200e28:	14000593          	li	a1,320
ffffffffc0200e2c:	00001517          	auipc	a0,0x1
ffffffffc0200e30:	68c50513          	addi	a0,a0,1676 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200e34:	cb6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200e38:	00002697          	auipc	a3,0x2
ffffffffc0200e3c:	91068693          	addi	a3,a3,-1776 # ffffffffc0202748 <commands+0x908>
ffffffffc0200e40:	00001617          	auipc	a2,0x1
ffffffffc0200e44:	66060613          	addi	a2,a2,1632 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200e48:	13e00593          	li	a1,318
ffffffffc0200e4c:	00001517          	auipc	a0,0x1
ffffffffc0200e50:	66c50513          	addi	a0,a0,1644 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200e54:	c96ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &(p0->page_link));
ffffffffc0200e58:	00002697          	auipc	a3,0x2
ffffffffc0200e5c:	8f068693          	addi	a3,a3,-1808 # ffffffffc0202748 <commands+0x908>
ffffffffc0200e60:	00001617          	auipc	a2,0x1
ffffffffc0200e64:	64060613          	addi	a2,a2,1600 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200e68:	13900593          	li	a1,313
ffffffffc0200e6c:	00001517          	auipc	a0,0x1
ffffffffc0200e70:	64c50513          	addi	a0,a0,1612 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200e74:	c76ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == 0);
ffffffffc0200e78:	00002697          	auipc	a3,0x2
ffffffffc0200e7c:	94068693          	addi	a3,a3,-1728 # ffffffffc02027b8 <commands+0x978>
ffffffffc0200e80:	00001617          	auipc	a2,0x1
ffffffffc0200e84:	62060613          	addi	a2,a2,1568 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200e88:	15300593          	li	a1,339
ffffffffc0200e8c:	00001517          	auipc	a0,0x1
ffffffffc0200e90:	62c50513          	addi	a0,a0,1580 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200e94:	c56ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e98:	00001697          	auipc	a3,0x1
ffffffffc0200e9c:	63868693          	addi	a3,a3,1592 # ffffffffc02024d0 <commands+0x690>
ffffffffc0200ea0:	00001617          	auipc	a2,0x1
ffffffffc0200ea4:	60060613          	addi	a2,a2,1536 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200ea8:	10c00593          	li	a1,268
ffffffffc0200eac:	00001517          	auipc	a0,0x1
ffffffffc0200eb0:	60c50513          	addi	a0,a0,1548 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200eb4:	c36ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200eb8:	00001697          	auipc	a3,0x1
ffffffffc0200ebc:	7c068693          	addi	a3,a3,1984 # ffffffffc0202678 <commands+0x838>
ffffffffc0200ec0:	00001617          	auipc	a2,0x1
ffffffffc0200ec4:	5e060613          	addi	a2,a2,1504 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200ec8:	14500593          	li	a1,325
ffffffffc0200ecc:	00001517          	auipc	a0,0x1
ffffffffc0200ed0:	5ec50513          	addi	a0,a0,1516 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200ed4:	c16ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ed8:	00001697          	auipc	a3,0x1
ffffffffc0200edc:	70068693          	addi	a3,a3,1792 # ffffffffc02025d8 <commands+0x798>
ffffffffc0200ee0:	00001617          	auipc	a2,0x1
ffffffffc0200ee4:	5c060613          	addi	a2,a2,1472 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200ee8:	0da00593          	li	a1,218
ffffffffc0200eec:	00001517          	auipc	a0,0x1
ffffffffc0200ef0:	5cc50513          	addi	a0,a0,1484 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200ef4:	bf6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
ffffffffc0200ef8:	00002697          	auipc	a3,0x2
ffffffffc0200efc:	81868693          	addi	a3,a3,-2024 # ffffffffc0202710 <commands+0x8d0>
ffffffffc0200f00:	00001617          	auipc	a2,0x1
ffffffffc0200f04:	5a060613          	addi	a2,a2,1440 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200f08:	13700593          	li	a1,311
ffffffffc0200f0c:	00001517          	auipc	a0,0x1
ffffffffc0200f10:	5ac50513          	addi	a0,a0,1452 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200f14:	bd6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 32);
ffffffffc0200f18:	00001697          	auipc	a3,0x1
ffffffffc0200f1c:	7e068693          	addi	a3,a3,2016 # ffffffffc02026f8 <commands+0x8b8>
ffffffffc0200f20:	00001617          	auipc	a2,0x1
ffffffffc0200f24:	58060613          	addi	a2,a2,1408 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200f28:	13200593          	li	a1,306
ffffffffc0200f2c:	00001517          	auipc	a0,0x1
ffffffffc0200f30:	58c50513          	addi	a0,a0,1420 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200f34:	bb6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200f38:	00001697          	auipc	a3,0x1
ffffffffc0200f3c:	77868693          	addi	a3,a3,1912 # ffffffffc02026b0 <commands+0x870>
ffffffffc0200f40:	00001617          	auipc	a2,0x1
ffffffffc0200f44:	56060613          	addi	a2,a2,1376 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200f48:	13000593          	li	a1,304
ffffffffc0200f4c:	00001517          	auipc	a0,0x1
ffffffffc0200f50:	56c50513          	addi	a0,a0,1388 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200f54:	b96ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p1->property == 16);
ffffffffc0200f58:	00001697          	auipc	a3,0x1
ffffffffc0200f5c:	77068693          	addi	a3,a3,1904 # ffffffffc02026c8 <commands+0x888>
ffffffffc0200f60:	00001617          	auipc	a2,0x1
ffffffffc0200f64:	54060613          	addi	a2,a2,1344 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200f68:	12f00593          	li	a1,303
ffffffffc0200f6c:	00001517          	auipc	a0,0x1
ffffffffc0200f70:	54c50513          	addi	a0,a0,1356 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200f74:	b76ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 32);
ffffffffc0200f78:	00001697          	auipc	a3,0x1
ffffffffc0200f7c:	78068693          	addi	a3,a3,1920 # ffffffffc02026f8 <commands+0x8b8>
ffffffffc0200f80:	00001617          	auipc	a2,0x1
ffffffffc0200f84:	52060613          	addi	a2,a2,1312 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200f88:	12a00593          	li	a1,298
ffffffffc0200f8c:	00001517          	auipc	a0,0x1
ffffffffc0200f90:	52c50513          	addi	a0,a0,1324 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200f94:	b56ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0->property == 16);
ffffffffc0200f98:	00001697          	auipc	a3,0x1
ffffffffc0200f9c:	74868693          	addi	a3,a3,1864 # ffffffffc02026e0 <commands+0x8a0>
ffffffffc0200fa0:	00001617          	auipc	a2,0x1
ffffffffc0200fa4:	50060613          	addi	a2,a2,1280 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200fa8:	12800593          	li	a1,296
ffffffffc0200fac:	00001517          	auipc	a0,0x1
ffffffffc0200fb0:	50c50513          	addi	a0,a0,1292 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200fb4:	b36ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p1->property == 16);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	71068693          	addi	a3,a3,1808 # ffffffffc02026c8 <commands+0x888>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	4e060613          	addi	a2,a2,1248 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200fc8:	12400593          	li	a1,292
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200fd4:	b16ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200fd8:	00001697          	auipc	a3,0x1
ffffffffc0200fdc:	6d868693          	addi	a3,a3,1752 # ffffffffc02026b0 <commands+0x870>
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	4c060613          	addi	a2,a2,1216 # ffffffffc02024a0 <commands+0x660>
ffffffffc0200fe8:	12300593          	li	a1,291
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	4cc50513          	addi	a0,a0,1228 # ffffffffc02024b8 <commands+0x678>
ffffffffc0200ff4:	af6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 + 8)->property == 8);
ffffffffc0200ff8:	00001697          	auipc	a3,0x1
ffffffffc0200ffc:	6b868693          	addi	a3,a3,1720 # ffffffffc02026b0 <commands+0x870>
ffffffffc0201000:	00001617          	auipc	a2,0x1
ffffffffc0201004:	4a060613          	addi	a2,a2,1184 # ffffffffc02024a0 <commands+0x660>
ffffffffc0201008:	12100593          	li	a1,289
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	4ac50513          	addi	a0,a0,1196 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201014:	ad6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(count == 0);
ffffffffc0201018:	00001697          	auipc	a3,0x1
ffffffffc020101c:	79068693          	addi	a3,a3,1936 # ffffffffc02027a8 <commands+0x968>
ffffffffc0201020:	00001617          	auipc	a2,0x1
ffffffffc0201024:	48060613          	addi	a2,a2,1152 # ffffffffc02024a0 <commands+0x660>
ffffffffc0201028:	15200593          	li	a1,338
ffffffffc020102c:	00001517          	auipc	a0,0x1
ffffffffc0201030:	48c50513          	addi	a0,a0,1164 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201034:	ab6ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201038:	00001697          	auipc	a3,0x1
ffffffffc020103c:	4d868693          	addi	a3,a3,1240 # ffffffffc0202510 <commands+0x6d0>
ffffffffc0201040:	00001617          	auipc	a2,0x1
ffffffffc0201044:	46060613          	addi	a2,a2,1120 # ffffffffc02024a0 <commands+0x660>
ffffffffc0201048:	0d300593          	li	a1,211
ffffffffc020104c:	00001517          	auipc	a0,0x1
ffffffffc0201050:	46c50513          	addi	a0,a0,1132 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201054:	a96ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201058:	00001697          	auipc	a3,0x1
ffffffffc020105c:	49868693          	addi	a3,a3,1176 # ffffffffc02024f0 <commands+0x6b0>
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	44060613          	addi	a2,a2,1088 # ffffffffc02024a0 <commands+0x660>
ffffffffc0201068:	0d200593          	li	a1,210
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	44c50513          	addi	a0,a0,1100 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201074:	a76ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201078:	00001697          	auipc	a3,0x1
ffffffffc020107c:	54068693          	addi	a3,a3,1344 # ffffffffc02025b8 <commands+0x778>
ffffffffc0201080:	00001617          	auipc	a2,0x1
ffffffffc0201084:	42060613          	addi	a2,a2,1056 # ffffffffc02024a0 <commands+0x660>
ffffffffc0201088:	0d900593          	li	a1,217
ffffffffc020108c:	00001517          	auipc	a0,0x1
ffffffffc0201090:	42c50513          	addi	a0,a0,1068 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201094:	a56ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201098:	00001697          	auipc	a3,0x1
ffffffffc020109c:	4e068693          	addi	a3,a3,1248 # ffffffffc0202578 <commands+0x738>
ffffffffc02010a0:	00001617          	auipc	a2,0x1
ffffffffc02010a4:	40060613          	addi	a2,a2,1024 # ffffffffc02024a0 <commands+0x660>
ffffffffc02010a8:	0d700593          	li	a1,215
ffffffffc02010ac:	00001517          	auipc	a0,0x1
ffffffffc02010b0:	40c50513          	addi	a0,a0,1036 # ffffffffc02024b8 <commands+0x678>
ffffffffc02010b4:	a36ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010b8:	00001697          	auipc	a3,0x1
ffffffffc02010bc:	49868693          	addi	a3,a3,1176 # ffffffffc0202550 <commands+0x710>
ffffffffc02010c0:	00001617          	auipc	a2,0x1
ffffffffc02010c4:	3e060613          	addi	a2,a2,992 # ffffffffc02024a0 <commands+0x660>
ffffffffc02010c8:	0d600593          	li	a1,214
ffffffffc02010cc:	00001517          	auipc	a0,0x1
ffffffffc02010d0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02024b8 <commands+0x678>
ffffffffc02010d4:	a16ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02010d8 <best_fit_free_pages>:
{
ffffffffc02010d8:	1141                	addi	sp,sp,-16
ffffffffc02010da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010dc:	1c058863          	beqz	a1,ffffffffc02012ac <best_fit_free_pages+0x1d4>
    while (num > 1)
ffffffffc02010e0:	4605                	li	a2,1
ffffffffc02010e2:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc02010e4:	4701                	li	a4,0
    while (num > 1)
ffffffffc02010e6:	4685                	li	a3,1
ffffffffc02010e8:	18b67e63          	bleu	a1,a2,ffffffffc0201284 <best_fit_free_pages+0x1ac>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc02010ec:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc02010ee:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc02010f0:	fed79ee3          	bne	a5,a3,ffffffffc02010ec <best_fit_free_pages+0x14>
    return (size_t)(1 << exp);
ffffffffc02010f4:	4785                	li	a5,1
ffffffffc02010f6:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc02010fa:	00b77463          	bleu	a1,a4,ffffffffc0201102 <best_fit_free_pages+0x2a>
        n = 2 * size;
ffffffffc02010fe:	00171593          	slli	a1,a4,0x1
    for (; p != base + n; p++)
ffffffffc0201102:	00259693          	slli	a3,a1,0x2
ffffffffc0201106:	96ae                	add	a3,a3,a1
ffffffffc0201108:	068e                	slli	a3,a3,0x3
ffffffffc020110a:	96aa                	add	a3,a3,a0
ffffffffc020110c:	02d50d63          	beq	a0,a3,ffffffffc0201146 <best_fit_free_pages+0x6e>
ffffffffc0201110:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201112:	8b85                	andi	a5,a5,1
ffffffffc0201114:	16079c63          	bnez	a5,ffffffffc020128c <best_fit_free_pages+0x1b4>
ffffffffc0201118:	651c                	ld	a5,8(a0)
ffffffffc020111a:	8385                	srli	a5,a5,0x1
ffffffffc020111c:	8b85                	andi	a5,a5,1
ffffffffc020111e:	16079763          	bnez	a5,ffffffffc020128c <best_fit_free_pages+0x1b4>
ffffffffc0201122:	87aa                	mv	a5,a0
ffffffffc0201124:	a809                	j	ffffffffc0201136 <best_fit_free_pages+0x5e>
ffffffffc0201126:	6798                	ld	a4,8(a5)
ffffffffc0201128:	8b05                	andi	a4,a4,1
ffffffffc020112a:	16071163          	bnez	a4,ffffffffc020128c <best_fit_free_pages+0x1b4>
ffffffffc020112e:	6798                	ld	a4,8(a5)
ffffffffc0201130:	8b09                	andi	a4,a4,2
ffffffffc0201132:	14071d63          	bnez	a4,ffffffffc020128c <best_fit_free_pages+0x1b4>
        p->flags = 0;
ffffffffc0201136:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020113a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020113e:	02878793          	addi	a5,a5,40
ffffffffc0201142:	fed792e3          	bne	a5,a3,ffffffffc0201126 <best_fit_free_pages+0x4e>
    base->property = n;
ffffffffc0201146:	2581                	sext.w	a1,a1
ffffffffc0201148:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020114a:	00850313          	addi	t1,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020114e:	4789                	li	a5,2
ffffffffc0201150:	40f3302f          	amoor.d	zero,a5,(t1)
    nr_free += n;
ffffffffc0201154:	00005817          	auipc	a6,0x5
ffffffffc0201158:	2e480813          	addi	a6,a6,740 # ffffffffc0206438 <free_area>
ffffffffc020115c:	01082703          	lw	a4,16(a6)
ffffffffc0201160:	00883783          	ld	a5,8(a6)
ffffffffc0201164:	9db9                	addw	a1,a1,a4
ffffffffc0201166:	00005717          	auipc	a4,0x5
ffffffffc020116a:	2eb72123          	sw	a1,738(a4) # ffffffffc0206448 <free_area+0x10>
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc020116e:	11078d63          	beq	a5,a6,ffffffffc0201288 <best_fit_free_pages+0x1b0>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0201172:	4910                	lw	a2,16(a0)
ffffffffc0201174:	ff87a703          	lw	a4,-8(a5)
        p = le2page(le, page_link);
ffffffffc0201178:	fe878693          	addi	a3,a5,-24
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc020117c:	00e66d63          	bltu	a2,a4,ffffffffc0201196 <best_fit_free_pages+0xbe>
ffffffffc0201180:	08c70363          	beq	a4,a2,ffffffffc0201206 <best_fit_free_pages+0x12e>
ffffffffc0201184:	679c                	ld	a5,8(a5)
    for (le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0201186:	01078863          	beq	a5,a6,ffffffffc0201196 <best_fit_free_pages+0xbe>
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc020118a:	ff87a703          	lw	a4,-8(a5)
        p = le2page(le, page_link);
ffffffffc020118e:	fe878693          	addi	a3,a5,-24
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0201192:	fee677e3          	bleu	a4,a2,ffffffffc0201180 <best_fit_free_pages+0xa8>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201196:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc0201198:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020119c:	e38c                	sd	a1,0(a5)
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc020119e:	0106a883          	lw	a7,16(a3)
ffffffffc02011a2:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02011a4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011a6:	ed18                	sd	a4,24(a0)
ffffffffc02011a8:	06c88c63          	beq	a7,a2,ffffffffc0201220 <best_fit_free_pages+0x148>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011ac:	55f5                	li	a1,-3
    while (le != &free_list)
ffffffffc02011ae:	01079863          	bne	a5,a6,ffffffffc02011be <best_fit_free_pages+0xe6>
ffffffffc02011b2:	a0b9                	j	ffffffffc0201200 <best_fit_free_pages+0x128>
        else if (base->property < p->property)
ffffffffc02011b4:	08e6ee63          	bltu	a3,a4,ffffffffc0201250 <best_fit_free_pages+0x178>
    return listelm->next;
ffffffffc02011b8:	679c                	ld	a5,8(a5)
    while (le != &free_list)
ffffffffc02011ba:	05078363          	beq	a5,a6,ffffffffc0201200 <best_fit_free_pages+0x128>
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc02011be:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011c2:	4914                	lw	a3,16(a0)
ffffffffc02011c4:	fed718e3          	bne	a4,a3,ffffffffc02011b4 <best_fit_free_pages+0xdc>
ffffffffc02011c8:	02071613          	slli	a2,a4,0x20
ffffffffc02011cc:	9201                	srli	a2,a2,0x20
ffffffffc02011ce:	00261693          	slli	a3,a2,0x2
ffffffffc02011d2:	96b2                	add	a3,a3,a2
ffffffffc02011d4:	068e                	slli	a3,a3,0x3
        p = le2page(le, page_link);
ffffffffc02011d6:	fe878613          	addi	a2,a5,-24
        if ((p->property == base->property) && (base + base->property == p))
ffffffffc02011da:	96aa                	add	a3,a3,a0
ffffffffc02011dc:	fcd61ee3          	bne	a2,a3,ffffffffc02011b8 <best_fit_free_pages+0xe0>
            base->property += p->property;
ffffffffc02011e0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02011e4:	c918                	sw	a4,16(a0)
ffffffffc02011e6:	ff078713          	addi	a4,a5,-16
ffffffffc02011ea:	60b7302f          	amoand.d	zero,a1,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011ee:	6394                	ld	a3,0(a5)
ffffffffc02011f0:	6798                	ld	a4,8(a5)
            le = &(base->page_link);
ffffffffc02011f2:	01850793          	addi	a5,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02011f6:	e698                	sd	a4,8(a3)
    return listelm->next;
ffffffffc02011f8:	679c                	ld	a5,8(a5)
    next->prev = prev;
ffffffffc02011fa:	e314                	sd	a3,0(a4)
    while (le != &free_list)
ffffffffc02011fc:	fd0791e3          	bne	a5,a6,ffffffffc02011be <best_fit_free_pages+0xe6>
}
ffffffffc0201200:	60a2                	ld	ra,8(sp)
ffffffffc0201202:	0141                	addi	sp,sp,16
ffffffffc0201204:	8082                	ret
        if ((base->property < p->property) || (base->property == p->property && base < p))
ffffffffc0201206:	f6d57fe3          	bleu	a3,a0,ffffffffc0201184 <best_fit_free_pages+0xac>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020120a:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc020120c:	01850593          	addi	a1,a0,24
    prev->next = next->prev = elm;
ffffffffc0201210:	e38c                	sd	a1,0(a5)
    if ((p->property == base->property) && (p + p->property == base))
ffffffffc0201212:	0106a883          	lw	a7,16(a3)
ffffffffc0201216:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0201218:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020121a:	ed18                	sd	a4,24(a0)
ffffffffc020121c:	f8c898e3          	bne	a7,a2,ffffffffc02011ac <best_fit_free_pages+0xd4>
ffffffffc0201220:	02061593          	slli	a1,a2,0x20
ffffffffc0201224:	9181                	srli	a1,a1,0x20
ffffffffc0201226:	00259713          	slli	a4,a1,0x2
ffffffffc020122a:	972e                	add	a4,a4,a1
ffffffffc020122c:	070e                	slli	a4,a4,0x3
ffffffffc020122e:	9736                	add	a4,a4,a3
ffffffffc0201230:	f6e51ee3          	bne	a0,a4,ffffffffc02011ac <best_fit_free_pages+0xd4>
        p->property += base->property;
ffffffffc0201234:	0016161b          	slliw	a2,a2,0x1
ffffffffc0201238:	ca90                	sw	a2,16(a3)
ffffffffc020123a:	57f5                	li	a5,-3
ffffffffc020123c:	60f3302f          	amoand.d	zero,a5,(t1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201240:	6d10                	ld	a2,24(a0)
ffffffffc0201242:	7118                	ld	a4,32(a0)
        le = &(base->page_link);
ffffffffc0201244:	01868793          	addi	a5,a3,24
ffffffffc0201248:	8536                	mv	a0,a3
    prev->next = next;
ffffffffc020124a:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020124c:	e310                	sd	a2,0(a4)
ffffffffc020124e:	bfb9                	j	ffffffffc02011ac <best_fit_free_pages+0xd4>
    return listelm->next;
ffffffffc0201250:	7110                	ld	a2,32(a0)
            while (le2page(targetLe, page_link)->property < base->property)
ffffffffc0201252:	ff862703          	lw	a4,-8(a2)
ffffffffc0201256:	87b2                	mv	a5,a2
ffffffffc0201258:	fad774e3          	bleu	a3,a4,ffffffffc0201200 <best_fit_free_pages+0x128>
ffffffffc020125c:	679c                	ld	a5,8(a5)
ffffffffc020125e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201262:	fed76de3          	bltu	a4,a3,ffffffffc020125c <best_fit_free_pages+0x184>
            if (targetLe != list_next(&base->page_link))
ffffffffc0201266:	f8f60de3          	beq	a2,a5,ffffffffc0201200 <best_fit_free_pages+0x128>
    __list_del(listelm->prev, listelm->next);
ffffffffc020126a:	6d18                	ld	a4,24(a0)
                list_add_before(targetLe, &(base->page_link));
ffffffffc020126c:	01850693          	addi	a3,a0,24
}
ffffffffc0201270:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201272:	e710                	sd	a2,8(a4)
    next->prev = prev;
ffffffffc0201274:	e218                	sd	a4,0(a2)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201276:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201278:	e394                	sd	a3,0(a5)
ffffffffc020127a:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc020127c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020127e:	ed18                	sd	a4,24(a0)
ffffffffc0201280:	0141                	addi	sp,sp,16
ffffffffc0201282:	8082                	ret
    while (num > 1)
ffffffffc0201284:	4585                	li	a1,1
ffffffffc0201286:	bdb5                	j	ffffffffc0201102 <best_fit_free_pages+0x2a>
ffffffffc0201288:	4910                	lw	a2,16(a0)
ffffffffc020128a:	b731                	j	ffffffffc0201196 <best_fit_free_pages+0xbe>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020128c:	00001697          	auipc	a3,0x1
ffffffffc0201290:	54468693          	addi	a3,a3,1348 # ffffffffc02027d0 <commands+0x990>
ffffffffc0201294:	00001617          	auipc	a2,0x1
ffffffffc0201298:	20c60613          	addi	a2,a2,524 # ffffffffc02024a0 <commands+0x660>
ffffffffc020129c:	08000593          	li	a1,128
ffffffffc02012a0:	00001517          	auipc	a0,0x1
ffffffffc02012a4:	21850513          	addi	a0,a0,536 # ffffffffc02024b8 <commands+0x678>
ffffffffc02012a8:	842ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02012ac:	00001697          	auipc	a3,0x1
ffffffffc02012b0:	51c68693          	addi	a3,a3,1308 # ffffffffc02027c8 <commands+0x988>
ffffffffc02012b4:	00001617          	auipc	a2,0x1
ffffffffc02012b8:	1ec60613          	addi	a2,a2,492 # ffffffffc02024a0 <commands+0x660>
ffffffffc02012bc:	07800593          	li	a1,120
ffffffffc02012c0:	00001517          	auipc	a0,0x1
ffffffffc02012c4:	1f850513          	addi	a0,a0,504 # ffffffffc02024b8 <commands+0x678>
ffffffffc02012c8:	822ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02012cc <best_fit_alloc_pages>:
{
ffffffffc02012cc:	1141                	addi	sp,sp,-16
ffffffffc02012ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012d0:	0e050f63          	beqz	a0,ffffffffc02013ce <best_fit_alloc_pages+0x102>
    while (num > 1)
ffffffffc02012d4:	4585                	li	a1,1
ffffffffc02012d6:	862a                	mv	a2,a0
ffffffffc02012d8:	87aa                	mv	a5,a0
    size_t exp = 0;
ffffffffc02012da:	4701                	li	a4,0
    while (num > 1)
ffffffffc02012dc:	4685                	li	a3,1
ffffffffc02012de:	0ca5f663          	bleu	a0,a1,ffffffffc02013aa <best_fit_alloc_pages+0xde>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc02012e2:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc02012e4:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc02012e6:	fed79ee3          	bne	a5,a3,ffffffffc02012e2 <best_fit_alloc_pages+0x16>
    return (size_t)(1 << exp);
ffffffffc02012ea:	4785                	li	a5,1
ffffffffc02012ec:	00e7973b          	sllw	a4,a5,a4
    if (size < n)
ffffffffc02012f0:	00c77463          	bleu	a2,a4,ffffffffc02012f8 <best_fit_alloc_pages+0x2c>
        n = 2 * size;
ffffffffc02012f4:	00171613          	slli	a2,a4,0x1
    if (n > nr_free)
ffffffffc02012f8:	00005897          	auipc	a7,0x5
ffffffffc02012fc:	14088893          	addi	a7,a7,320 # ffffffffc0206438 <free_area>
ffffffffc0201300:	0108a583          	lw	a1,16(a7)
ffffffffc0201304:	02059793          	slli	a5,a1,0x20
ffffffffc0201308:	9381                	srli	a5,a5,0x20
ffffffffc020130a:	00c7ee63          	bltu	a5,a2,ffffffffc0201326 <best_fit_alloc_pages+0x5a>
    list_entry_t *le = &free_list;
ffffffffc020130e:	8746                	mv	a4,a7
ffffffffc0201310:	a801                	j	ffffffffc0201320 <best_fit_alloc_pages+0x54>
        if (p->property >= n){
ffffffffc0201312:	ff872683          	lw	a3,-8(a4)
ffffffffc0201316:	02069793          	slli	a5,a3,0x20
ffffffffc020131a:	9381                	srli	a5,a5,0x20
ffffffffc020131c:	00c7f963          	bleu	a2,a5,ffffffffc020132e <best_fit_alloc_pages+0x62>
    return listelm->next;
ffffffffc0201320:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201322:	ff1718e3          	bne	a4,a7,ffffffffc0201312 <best_fit_alloc_pages+0x46>
        return NULL;
ffffffffc0201326:	4501                	li	a0,0
}
ffffffffc0201328:	60a2                	ld	ra,8(sp)
ffffffffc020132a:	0141                	addi	sp,sp,16
ffffffffc020132c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020132e:	fe870513          	addi	a0,a4,-24
    if (page != NULL)
ffffffffc0201332:	d97d                	beqz	a0,ffffffffc0201328 <best_fit_alloc_pages+0x5c>
        while (page->property > n)
ffffffffc0201334:	04f67663          	bleu	a5,a2,ffffffffc0201380 <best_fit_alloc_pages+0xb4>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201338:	4309                	li	t1,2
            page->property /= 2;
ffffffffc020133a:	0016d69b          	srliw	a3,a3,0x1
            struct Page *p = page + page->property;
ffffffffc020133e:	02069593          	slli	a1,a3,0x20
ffffffffc0201342:	9181                	srli	a1,a1,0x20
ffffffffc0201344:	00259793          	slli	a5,a1,0x2
ffffffffc0201348:	97ae                	add	a5,a5,a1
ffffffffc020134a:	078e                	slli	a5,a5,0x3
            page->property /= 2;
ffffffffc020134c:	fed72c23          	sw	a3,-8(a4)
            struct Page *p = page + page->property;
ffffffffc0201350:	97aa                	add	a5,a5,a0
            p->property = page->property;
ffffffffc0201352:	cb94                	sw	a3,16(a5)
ffffffffc0201354:	00878693          	addi	a3,a5,8
ffffffffc0201358:	4066b02f          	amoor.d	zero,t1,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020135c:	670c                	ld	a1,8(a4)
        while (page->property > n)
ffffffffc020135e:	ff872683          	lw	a3,-8(a4)
            list_add_after(&(page->page_link), &(p->page_link));
ffffffffc0201362:	01878813          	addi	a6,a5,24
    prev->next = next->prev = elm;
ffffffffc0201366:	0105b023          	sd	a6,0(a1)
ffffffffc020136a:	01073423          	sd	a6,8(a4)
    elm->next = next;
ffffffffc020136e:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0201370:	ef98                	sd	a4,24(a5)
        while (page->property > n)
ffffffffc0201372:	02069793          	slli	a5,a3,0x20
ffffffffc0201376:	9381                	srli	a5,a5,0x20
ffffffffc0201378:	fcf661e3          	bltu	a2,a5,ffffffffc020133a <best_fit_alloc_pages+0x6e>
ffffffffc020137c:	0108a583          	lw	a1,16(a7)
        nr_free -= n;
ffffffffc0201380:	9d91                	subw	a1,a1,a2
ffffffffc0201382:	00005797          	auipc	a5,0x5
ffffffffc0201386:	0cb7a323          	sw	a1,198(a5) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020138a:	57f5                	li	a5,-3
ffffffffc020138c:	ff070693          	addi	a3,a4,-16
ffffffffc0201390:	60f6b02f          	amoand.d	zero,a5,(a3)
        assert(page->property == n);
ffffffffc0201394:	ff876783          	lwu	a5,-8(a4)
ffffffffc0201398:	00f61b63          	bne	a2,a5,ffffffffc02013ae <best_fit_alloc_pages+0xe2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020139c:	6314                	ld	a3,0(a4)
ffffffffc020139e:	671c                	ld	a5,8(a4)
}
ffffffffc02013a0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013a2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013a4:	e394                	sd	a3,0(a5)
ffffffffc02013a6:	0141                	addi	sp,sp,16
ffffffffc02013a8:	8082                	ret
    while (num > 1)
ffffffffc02013aa:	4605                	li	a2,1
ffffffffc02013ac:	b7b1                	j	ffffffffc02012f8 <best_fit_alloc_pages+0x2c>
        assert(page->property == n);
ffffffffc02013ae:	00001697          	auipc	a3,0x1
ffffffffc02013b2:	0c268693          	addi	a3,a3,194 # ffffffffc0202470 <commands+0x630>
ffffffffc02013b6:	00001617          	auipc	a2,0x1
ffffffffc02013ba:	0ea60613          	addi	a2,a2,234 # ffffffffc02024a0 <commands+0x660>
ffffffffc02013be:	06f00593          	li	a1,111
ffffffffc02013c2:	00001517          	auipc	a0,0x1
ffffffffc02013c6:	0f650513          	addi	a0,a0,246 # ffffffffc02024b8 <commands+0x678>
ffffffffc02013ca:	f21fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02013ce:	00001697          	auipc	a3,0x1
ffffffffc02013d2:	3fa68693          	addi	a3,a3,1018 # ffffffffc02027c8 <commands+0x988>
ffffffffc02013d6:	00001617          	auipc	a2,0x1
ffffffffc02013da:	0ca60613          	addi	a2,a2,202 # ffffffffc02024a0 <commands+0x660>
ffffffffc02013de:	04c00593          	li	a1,76
ffffffffc02013e2:	00001517          	auipc	a0,0x1
ffffffffc02013e6:	0d650513          	addi	a0,a0,214 # ffffffffc02024b8 <commands+0x678>
ffffffffc02013ea:	f01fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02013ee <best_fit_init_memmap>:
{
ffffffffc02013ee:	1141                	addi	sp,sp,-16
ffffffffc02013f0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013f2:	10058463          	beqz	a1,ffffffffc02014fa <best_fit_init_memmap+0x10c>
    for (; p != base + n; p++)
ffffffffc02013f6:	00259813          	slli	a6,a1,0x2
ffffffffc02013fa:	982e                	add	a6,a6,a1
ffffffffc02013fc:	080e                	slli	a6,a6,0x3
ffffffffc02013fe:	982a                	add	a6,a6,a0
ffffffffc0201400:	01050f63          	beq	a0,a6,ffffffffc020141e <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201404:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0201406:	8b85                	andi	a5,a5,1
ffffffffc0201408:	cbe9                	beqz	a5,ffffffffc02014da <best_fit_init_memmap+0xec>
        p->flags = p->property = 0;
ffffffffc020140a:	00052823          	sw	zero,16(a0)
ffffffffc020140e:	00053423          	sd	zero,8(a0)
ffffffffc0201412:	00052023          	sw	zero,0(a0)
    for (; p != base + n; p++)
ffffffffc0201416:	02850513          	addi	a0,a0,40
ffffffffc020141a:	ff0515e3          	bne	a0,a6,ffffffffc0201404 <best_fit_init_memmap+0x16>
    nr_free += n;
ffffffffc020141e:	00005897          	auipc	a7,0x5
ffffffffc0201422:	01a88893          	addi	a7,a7,26 # ffffffffc0206438 <free_area>
ffffffffc0201426:	0108a783          	lw	a5,16(a7)
    while (num > 1)
ffffffffc020142a:	4305                	li	t1,1
ffffffffc020142c:	4e85                	li	t4,1
    nr_free += n;
ffffffffc020142e:	9fad                	addw	a5,a5,a1
ffffffffc0201430:	00005717          	auipc	a4,0x5
ffffffffc0201434:	00f72c23          	sw	a5,24(a4) # ffffffffc0206448 <free_area+0x10>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201438:	4e09                	li	t3,2
    while (num > 1)
ffffffffc020143a:	87ae                	mv	a5,a1
    size_t exp = 0;
ffffffffc020143c:	4701                	li	a4,0
    while (num > 1)
ffffffffc020143e:	08b37963          	bleu	a1,t1,ffffffffc02014d0 <best_fit_init_memmap+0xe2>
        num >>= 1; // 右移一位，相当于除以2
ffffffffc0201442:	8385                	srli	a5,a5,0x1
        exp++;
ffffffffc0201444:	0705                	addi	a4,a4,1
    while (num > 1)
ffffffffc0201446:	fe679ee3          	bne	a5,t1,ffffffffc0201442 <best_fit_init_memmap+0x54>
ffffffffc020144a:	00ee963b          	sllw	a2,t4,a4
ffffffffc020144e:	00261793          	slli	a5,a2,0x2
ffffffffc0201452:	97b2                	add	a5,a5,a2
ffffffffc0201454:	078e                	slli	a5,a5,0x3
ffffffffc0201456:	40f007b3          	neg	a5,a5
ffffffffc020145a:	8732                	mv	a4,a2
        base -= curr_n;
ffffffffc020145c:	983e                	add	a6,a6,a5
        base->property = curr_n;
ffffffffc020145e:	00e82823          	sw	a4,16(a6)
ffffffffc0201462:	00880793          	addi	a5,a6,8
ffffffffc0201466:	41c7b02f          	amoor.d	zero,t3,(a5)
    return listelm->next;
ffffffffc020146a:	0088b783          	ld	a5,8(a7)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc020146e:	03178563          	beq	a5,a7,ffffffffc0201498 <best_fit_init_memmap+0xaa>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc0201472:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201476:	01082683          	lw	a3,16(a6)
            struct Page *page = le2page(le, page_link);
ffffffffc020147a:	fe878513          	addi	a0,a5,-24
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc020147e:	00e6ed63          	bltu	a3,a4,ffffffffc0201498 <best_fit_init_memmap+0xaa>
ffffffffc0201482:	02e68963          	beq	a3,a4,ffffffffc02014b4 <best_fit_init_memmap+0xc6>
ffffffffc0201486:	679c                	ld	a5,8(a5)
        for(le = list_next(&free_list); le != &free_list; le = list_next(le))
ffffffffc0201488:	01178863          	beq	a5,a7,ffffffffc0201498 <best_fit_init_memmap+0xaa>
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc020148c:	ff87a703          	lw	a4,-8(a5)
            struct Page *page = le2page(le, page_link);
ffffffffc0201490:	fe878513          	addi	a0,a5,-24
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc0201494:	fee6f7e3          	bleu	a4,a3,ffffffffc0201482 <best_fit_init_memmap+0x94>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201498:	6398                	ld	a4,0(a5)
        list_add_before(le, &(base->page_link));
ffffffffc020149a:	01880693          	addi	a3,a6,24
    prev->next = next->prev = elm;
ffffffffc020149e:	e394                	sd	a3,0(a5)
ffffffffc02014a0:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02014a2:	02f83023          	sd	a5,32(a6)
    elm->prev = prev;
ffffffffc02014a6:	00e83c23          	sd	a4,24(a6)
        n -= curr_n;
ffffffffc02014aa:	8d91                	sub	a1,a1,a2
    while (n != 0)
ffffffffc02014ac:	f5d9                	bnez	a1,ffffffffc020143a <best_fit_init_memmap+0x4c>
}
ffffffffc02014ae:	60a2                	ld	ra,8(sp)
ffffffffc02014b0:	0141                	addi	sp,sp,16
ffffffffc02014b2:	8082                	ret
            if ((page->property > base->property) || (page->property == base->property && page > base))
ffffffffc02014b4:	fca879e3          	bleu	a0,a6,ffffffffc0201486 <best_fit_init_memmap+0x98>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014b8:	6398                	ld	a4,0(a5)
        list_add_before(le, &(base->page_link));
ffffffffc02014ba:	01880693          	addi	a3,a6,24
    prev->next = next->prev = elm;
ffffffffc02014be:	e394                	sd	a3,0(a5)
ffffffffc02014c0:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02014c2:	02f83023          	sd	a5,32(a6)
    elm->prev = prev;
ffffffffc02014c6:	00e83c23          	sd	a4,24(a6)
        n -= curr_n;
ffffffffc02014ca:	8d91                	sub	a1,a1,a2
    while (n != 0)
ffffffffc02014cc:	f5bd                	bnez	a1,ffffffffc020143a <best_fit_init_memmap+0x4c>
ffffffffc02014ce:	b7c5                	j	ffffffffc02014ae <best_fit_init_memmap+0xc0>
    while (num > 1)
ffffffffc02014d0:	4705                	li	a4,1
ffffffffc02014d2:	fd800793          	li	a5,-40
ffffffffc02014d6:	4605                	li	a2,1
ffffffffc02014d8:	b751                	j	ffffffffc020145c <best_fit_init_memmap+0x6e>
        assert(PageReserved(p));
ffffffffc02014da:	00001697          	auipc	a3,0x1
ffffffffc02014de:	31e68693          	addi	a3,a3,798 # ffffffffc02027f8 <commands+0x9b8>
ffffffffc02014e2:	00001617          	auipc	a2,0x1
ffffffffc02014e6:	fbe60613          	addi	a2,a2,-66 # ffffffffc02024a0 <commands+0x660>
ffffffffc02014ea:	02900593          	li	a1,41
ffffffffc02014ee:	00001517          	auipc	a0,0x1
ffffffffc02014f2:	fca50513          	addi	a0,a0,-54 # ffffffffc02024b8 <commands+0x678>
ffffffffc02014f6:	df5fe0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02014fa:	00001697          	auipc	a3,0x1
ffffffffc02014fe:	2ce68693          	addi	a3,a3,718 # ffffffffc02027c8 <commands+0x988>
ffffffffc0201502:	00001617          	auipc	a2,0x1
ffffffffc0201506:	f9e60613          	addi	a2,a2,-98 # ffffffffc02024a0 <commands+0x660>
ffffffffc020150a:	02300593          	li	a1,35
ffffffffc020150e:	00001517          	auipc	a0,0x1
ffffffffc0201512:	faa50513          	addi	a0,a0,-86 # ffffffffc02024b8 <commands+0x678>
ffffffffc0201516:	dd5fe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc020151a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020151a:	100027f3          	csrr	a5,sstatus
ffffffffc020151e:	8b89                	andi	a5,a5,2
ffffffffc0201520:	eb89                	bnez	a5,ffffffffc0201532 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201522:	00005797          	auipc	a5,0x5
ffffffffc0201526:	f3678793          	addi	a5,a5,-202 # ffffffffc0206458 <pmm_manager>
ffffffffc020152a:	639c                	ld	a5,0(a5)
ffffffffc020152c:	0187b303          	ld	t1,24(a5)
ffffffffc0201530:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201532:	1141                	addi	sp,sp,-16
ffffffffc0201534:	e406                	sd	ra,8(sp)
ffffffffc0201536:	e022                	sd	s0,0(sp)
ffffffffc0201538:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020153a:	f2bfe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020153e:	00005797          	auipc	a5,0x5
ffffffffc0201542:	f1a78793          	addi	a5,a5,-230 # ffffffffc0206458 <pmm_manager>
ffffffffc0201546:	639c                	ld	a5,0(a5)
ffffffffc0201548:	8522                	mv	a0,s0
ffffffffc020154a:	6f9c                	ld	a5,24(a5)
ffffffffc020154c:	9782                	jalr	a5
ffffffffc020154e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201550:	f0ffe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201554:	8522                	mv	a0,s0
ffffffffc0201556:	60a2                	ld	ra,8(sp)
ffffffffc0201558:	6402                	ld	s0,0(sp)
ffffffffc020155a:	0141                	addi	sp,sp,16
ffffffffc020155c:	8082                	ret

ffffffffc020155e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020155e:	100027f3          	csrr	a5,sstatus
ffffffffc0201562:	8b89                	andi	a5,a5,2
ffffffffc0201564:	eb89                	bnez	a5,ffffffffc0201576 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201566:	00005797          	auipc	a5,0x5
ffffffffc020156a:	ef278793          	addi	a5,a5,-270 # ffffffffc0206458 <pmm_manager>
ffffffffc020156e:	639c                	ld	a5,0(a5)
ffffffffc0201570:	0207b303          	ld	t1,32(a5)
ffffffffc0201574:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201576:	1101                	addi	sp,sp,-32
ffffffffc0201578:	ec06                	sd	ra,24(sp)
ffffffffc020157a:	e822                	sd	s0,16(sp)
ffffffffc020157c:	e426                	sd	s1,8(sp)
ffffffffc020157e:	842a                	mv	s0,a0
ffffffffc0201580:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201582:	ee3fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201586:	00005797          	auipc	a5,0x5
ffffffffc020158a:	ed278793          	addi	a5,a5,-302 # ffffffffc0206458 <pmm_manager>
ffffffffc020158e:	639c                	ld	a5,0(a5)
ffffffffc0201590:	85a6                	mv	a1,s1
ffffffffc0201592:	8522                	mv	a0,s0
ffffffffc0201594:	739c                	ld	a5,32(a5)
ffffffffc0201596:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201598:	6442                	ld	s0,16(sp)
ffffffffc020159a:	60e2                	ld	ra,24(sp)
ffffffffc020159c:	64a2                	ld	s1,8(sp)
ffffffffc020159e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02015a0:	ebffe06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02015a4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015a4:	100027f3          	csrr	a5,sstatus
ffffffffc02015a8:	8b89                	andi	a5,a5,2
ffffffffc02015aa:	eb89                	bnez	a5,ffffffffc02015bc <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02015ac:	00005797          	auipc	a5,0x5
ffffffffc02015b0:	eac78793          	addi	a5,a5,-340 # ffffffffc0206458 <pmm_manager>
ffffffffc02015b4:	639c                	ld	a5,0(a5)
ffffffffc02015b6:	0287b303          	ld	t1,40(a5)
ffffffffc02015ba:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02015bc:	1141                	addi	sp,sp,-16
ffffffffc02015be:	e406                	sd	ra,8(sp)
ffffffffc02015c0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02015c2:	ea3fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02015c6:	00005797          	auipc	a5,0x5
ffffffffc02015ca:	e9278793          	addi	a5,a5,-366 # ffffffffc0206458 <pmm_manager>
ffffffffc02015ce:	639c                	ld	a5,0(a5)
ffffffffc02015d0:	779c                	ld	a5,40(a5)
ffffffffc02015d2:	9782                	jalr	a5
ffffffffc02015d4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02015d6:	e89fe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02015da:	8522                	mv	a0,s0
ffffffffc02015dc:	60a2                	ld	ra,8(sp)
ffffffffc02015de:	6402                	ld	s0,0(sp)
ffffffffc02015e0:	0141                	addi	sp,sp,16
ffffffffc02015e2:	8082                	ret

ffffffffc02015e4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02015e4:	00001797          	auipc	a5,0x1
ffffffffc02015e8:	22478793          	addi	a5,a5,548 # ffffffffc0202808 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02015ec:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02015ee:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02015f0:	00001517          	auipc	a0,0x1
ffffffffc02015f4:	26850513          	addi	a0,a0,616 # ffffffffc0202858 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02015f8:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02015fa:	00005717          	auipc	a4,0x5
ffffffffc02015fe:	e4f73f23          	sd	a5,-418(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201602:	e822                	sd	s0,16(sp)
ffffffffc0201604:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201606:	00005417          	auipc	s0,0x5
ffffffffc020160a:	e5240413          	addi	s0,s0,-430 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020160e:	d77fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    pmm_manager->init();
ffffffffc0201612:	601c                	ld	a5,0(s0)
ffffffffc0201614:	679c                	ld	a5,8(a5)
ffffffffc0201616:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201618:	57f5                	li	a5,-3
ffffffffc020161a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020161c:	00001517          	auipc	a0,0x1
ffffffffc0201620:	25450513          	addi	a0,a0,596 # ffffffffc0202870 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201624:	00005717          	auipc	a4,0x5
ffffffffc0201628:	e2f73e23          	sd	a5,-452(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020162c:	d59fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201630:	46c5                	li	a3,17
ffffffffc0201632:	06ee                	slli	a3,a3,0x1b
ffffffffc0201634:	40100613          	li	a2,1025
ffffffffc0201638:	16fd                	addi	a3,a3,-1
ffffffffc020163a:	0656                	slli	a2,a2,0x15
ffffffffc020163c:	07e005b7          	lui	a1,0x7e00
ffffffffc0201640:	00001517          	auipc	a0,0x1
ffffffffc0201644:	24850513          	addi	a0,a0,584 # ffffffffc0202888 <best_fit_pmm_manager+0x80>
ffffffffc0201648:	d3dfe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020164c:	777d                	lui	a4,0xfffff
ffffffffc020164e:	00006797          	auipc	a5,0x6
ffffffffc0201652:	e2178793          	addi	a5,a5,-479 # ffffffffc020746f <end+0xfff>
ffffffffc0201656:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201658:	00088737          	lui	a4,0x88
ffffffffc020165c:	00005697          	auipc	a3,0x5
ffffffffc0201660:	dae6be23          	sd	a4,-580(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201664:	4601                	li	a2,0
ffffffffc0201666:	00005717          	auipc	a4,0x5
ffffffffc020166a:	e0f73123          	sd	a5,-510(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020166e:	4681                	li	a3,0
ffffffffc0201670:	00005897          	auipc	a7,0x5
ffffffffc0201674:	da888893          	addi	a7,a7,-600 # ffffffffc0206418 <npage>
ffffffffc0201678:	00005597          	auipc	a1,0x5
ffffffffc020167c:	df058593          	addi	a1,a1,-528 # ffffffffc0206468 <pages>
ffffffffc0201680:	4805                	li	a6,1
ffffffffc0201682:	fff80537          	lui	a0,0xfff80
ffffffffc0201686:	a011                	j	ffffffffc020168a <pmm_init+0xa6>
ffffffffc0201688:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020168a:	97b2                	add	a5,a5,a2
ffffffffc020168c:	07a1                	addi	a5,a5,8
ffffffffc020168e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201692:	0008b703          	ld	a4,0(a7)
ffffffffc0201696:	0685                	addi	a3,a3,1
ffffffffc0201698:	02860613          	addi	a2,a2,40
ffffffffc020169c:	00a707b3          	add	a5,a4,a0
ffffffffc02016a0:	fef6e4e3          	bltu	a3,a5,ffffffffc0201688 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016a4:	6190                	ld	a2,0(a1)
ffffffffc02016a6:	00271793          	slli	a5,a4,0x2
ffffffffc02016aa:	97ba                	add	a5,a5,a4
ffffffffc02016ac:	fec006b7          	lui	a3,0xfec00
ffffffffc02016b0:	078e                	slli	a5,a5,0x3
ffffffffc02016b2:	96b2                	add	a3,a3,a2
ffffffffc02016b4:	96be                	add	a3,a3,a5
ffffffffc02016b6:	c02007b7          	lui	a5,0xc0200
ffffffffc02016ba:	08f6e863          	bltu	a3,a5,ffffffffc020174a <pmm_init+0x166>
ffffffffc02016be:	00005497          	auipc	s1,0x5
ffffffffc02016c2:	da248493          	addi	s1,s1,-606 # ffffffffc0206460 <va_pa_offset>
ffffffffc02016c6:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02016c8:	45c5                	li	a1,17
ffffffffc02016ca:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016cc:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02016ce:	04b6e963          	bltu	a3,a1,ffffffffc0201720 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02016d2:	601c                	ld	a5,0(s0)
ffffffffc02016d4:	7b9c                	ld	a5,48(a5)
ffffffffc02016d6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02016d8:	00001517          	auipc	a0,0x1
ffffffffc02016dc:	24850513          	addi	a0,a0,584 # ffffffffc0202920 <best_fit_pmm_manager+0x118>
ffffffffc02016e0:	ca5fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02016e4:	00004697          	auipc	a3,0x4
ffffffffc02016e8:	91c68693          	addi	a3,a3,-1764 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02016ec:	00005797          	auipc	a5,0x5
ffffffffc02016f0:	d2d7ba23          	sd	a3,-716(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02016f4:	c02007b7          	lui	a5,0xc0200
ffffffffc02016f8:	06f6e563          	bltu	a3,a5,ffffffffc0201762 <pmm_init+0x17e>
ffffffffc02016fc:	609c                	ld	a5,0(s1)
}
ffffffffc02016fe:	6442                	ld	s0,16(sp)
ffffffffc0201700:	60e2                	ld	ra,24(sp)
ffffffffc0201702:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201704:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201706:	8e9d                	sub	a3,a3,a5
ffffffffc0201708:	00005797          	auipc	a5,0x5
ffffffffc020170c:	d4d7b423          	sd	a3,-696(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201710:	00001517          	auipc	a0,0x1
ffffffffc0201714:	23050513          	addi	a0,a0,560 # ffffffffc0202940 <best_fit_pmm_manager+0x138>
ffffffffc0201718:	8636                	mv	a2,a3
}
ffffffffc020171a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020171c:	c69fe06f          	j	ffffffffc0200384 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201720:	6785                	lui	a5,0x1
ffffffffc0201722:	17fd                	addi	a5,a5,-1
ffffffffc0201724:	96be                	add	a3,a3,a5
ffffffffc0201726:	77fd                	lui	a5,0xfffff
ffffffffc0201728:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020172a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020172e:	04e7f663          	bleu	a4,a5,ffffffffc020177a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201732:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201734:	97aa                	add	a5,a5,a0
ffffffffc0201736:	00279513          	slli	a0,a5,0x2
ffffffffc020173a:	953e                	add	a0,a0,a5
ffffffffc020173c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020173e:	8d95                	sub	a1,a1,a3
ffffffffc0201740:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201742:	81b1                	srli	a1,a1,0xc
ffffffffc0201744:	9532                	add	a0,a0,a2
ffffffffc0201746:	9782                	jalr	a5
ffffffffc0201748:	b769                	j	ffffffffc02016d2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020174a:	00001617          	auipc	a2,0x1
ffffffffc020174e:	16e60613          	addi	a2,a2,366 # ffffffffc02028b8 <best_fit_pmm_manager+0xb0>
ffffffffc0201752:	06e00593          	li	a1,110
ffffffffc0201756:	00001517          	auipc	a0,0x1
ffffffffc020175a:	18a50513          	addi	a0,a0,394 # ffffffffc02028e0 <best_fit_pmm_manager+0xd8>
ffffffffc020175e:	b8dfe0ef          	jal	ra,ffffffffc02002ea <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201762:	00001617          	auipc	a2,0x1
ffffffffc0201766:	15660613          	addi	a2,a2,342 # ffffffffc02028b8 <best_fit_pmm_manager+0xb0>
ffffffffc020176a:	08900593          	li	a1,137
ffffffffc020176e:	00001517          	auipc	a0,0x1
ffffffffc0201772:	17250513          	addi	a0,a0,370 # ffffffffc02028e0 <best_fit_pmm_manager+0xd8>
ffffffffc0201776:	b75fe0ef          	jal	ra,ffffffffc02002ea <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020177a:	00001617          	auipc	a2,0x1
ffffffffc020177e:	17660613          	addi	a2,a2,374 # ffffffffc02028f0 <best_fit_pmm_manager+0xe8>
ffffffffc0201782:	06b00593          	li	a1,107
ffffffffc0201786:	00001517          	auipc	a0,0x1
ffffffffc020178a:	18a50513          	addi	a0,a0,394 # ffffffffc0202910 <best_fit_pmm_manager+0x108>
ffffffffc020178e:	b5dfe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201792 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201792:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201796:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201798:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020179c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020179e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017a2:	f022                	sd	s0,32(sp)
ffffffffc02017a4:	ec26                	sd	s1,24(sp)
ffffffffc02017a6:	e84a                	sd	s2,16(sp)
ffffffffc02017a8:	f406                	sd	ra,40(sp)
ffffffffc02017aa:	e44e                	sd	s3,8(sp)
ffffffffc02017ac:	84aa                	mv	s1,a0
ffffffffc02017ae:	892e                	mv	s2,a1
ffffffffc02017b0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02017b4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02017b6:	03067e63          	bleu	a6,a2,ffffffffc02017f2 <printnum+0x60>
ffffffffc02017ba:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02017bc:	00805763          	blez	s0,ffffffffc02017ca <printnum+0x38>
ffffffffc02017c0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02017c2:	85ca                	mv	a1,s2
ffffffffc02017c4:	854e                	mv	a0,s3
ffffffffc02017c6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02017c8:	fc65                	bnez	s0,ffffffffc02017c0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017ca:	1a02                	slli	s4,s4,0x20
ffffffffc02017cc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02017d0:	00001797          	auipc	a5,0x1
ffffffffc02017d4:	34078793          	addi	a5,a5,832 # ffffffffc0202b10 <error_string+0x38>
ffffffffc02017d8:	9a3e                	add	s4,s4,a5
}
ffffffffc02017da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017dc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02017e0:	70a2                	ld	ra,40(sp)
ffffffffc02017e2:	69a2                	ld	s3,8(sp)
ffffffffc02017e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017e6:	85ca                	mv	a1,s2
ffffffffc02017e8:	8326                	mv	t1,s1
}
ffffffffc02017ea:	6942                	ld	s2,16(sp)
ffffffffc02017ec:	64e2                	ld	s1,24(sp)
ffffffffc02017ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017f0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02017f2:	03065633          	divu	a2,a2,a6
ffffffffc02017f6:	8722                	mv	a4,s0
ffffffffc02017f8:	f9bff0ef          	jal	ra,ffffffffc0201792 <printnum>
ffffffffc02017fc:	b7f9                	j	ffffffffc02017ca <printnum+0x38>

ffffffffc02017fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02017fe:	7119                	addi	sp,sp,-128
ffffffffc0201800:	f4a6                	sd	s1,104(sp)
ffffffffc0201802:	f0ca                	sd	s2,96(sp)
ffffffffc0201804:	e8d2                	sd	s4,80(sp)
ffffffffc0201806:	e4d6                	sd	s5,72(sp)
ffffffffc0201808:	e0da                	sd	s6,64(sp)
ffffffffc020180a:	fc5e                	sd	s7,56(sp)
ffffffffc020180c:	f862                	sd	s8,48(sp)
ffffffffc020180e:	f06a                	sd	s10,32(sp)
ffffffffc0201810:	fc86                	sd	ra,120(sp)
ffffffffc0201812:	f8a2                	sd	s0,112(sp)
ffffffffc0201814:	ecce                	sd	s3,88(sp)
ffffffffc0201816:	f466                	sd	s9,40(sp)
ffffffffc0201818:	ec6e                	sd	s11,24(sp)
ffffffffc020181a:	892a                	mv	s2,a0
ffffffffc020181c:	84ae                	mv	s1,a1
ffffffffc020181e:	8d32                	mv	s10,a2
ffffffffc0201820:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201822:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201824:	00001a17          	auipc	s4,0x1
ffffffffc0201828:	15ca0a13          	addi	s4,s4,348 # ffffffffc0202980 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020182c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201830:	00001c17          	auipc	s8,0x1
ffffffffc0201834:	2a8c0c13          	addi	s8,s8,680 # ffffffffc0202ad8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201838:	000d4503          	lbu	a0,0(s10)
ffffffffc020183c:	02500793          	li	a5,37
ffffffffc0201840:	001d0413          	addi	s0,s10,1
ffffffffc0201844:	00f50e63          	beq	a0,a5,ffffffffc0201860 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201848:	c521                	beqz	a0,ffffffffc0201890 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020184a:	02500993          	li	s3,37
ffffffffc020184e:	a011                	j	ffffffffc0201852 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201850:	c121                	beqz	a0,ffffffffc0201890 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201852:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201854:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201856:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201858:	fff44503          	lbu	a0,-1(s0)
ffffffffc020185c:	ff351ae3          	bne	a0,s3,ffffffffc0201850 <vprintfmt+0x52>
ffffffffc0201860:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201864:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201868:	4981                	li	s3,0
ffffffffc020186a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020186c:	5cfd                	li	s9,-1
ffffffffc020186e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201870:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201874:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201876:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020187a:	0ff6f693          	andi	a3,a3,255
ffffffffc020187e:	00140d13          	addi	s10,s0,1
ffffffffc0201882:	20d5e563          	bltu	a1,a3,ffffffffc0201a8c <vprintfmt+0x28e>
ffffffffc0201886:	068a                	slli	a3,a3,0x2
ffffffffc0201888:	96d2                	add	a3,a3,s4
ffffffffc020188a:	4294                	lw	a3,0(a3)
ffffffffc020188c:	96d2                	add	a3,a3,s4
ffffffffc020188e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201890:	70e6                	ld	ra,120(sp)
ffffffffc0201892:	7446                	ld	s0,112(sp)
ffffffffc0201894:	74a6                	ld	s1,104(sp)
ffffffffc0201896:	7906                	ld	s2,96(sp)
ffffffffc0201898:	69e6                	ld	s3,88(sp)
ffffffffc020189a:	6a46                	ld	s4,80(sp)
ffffffffc020189c:	6aa6                	ld	s5,72(sp)
ffffffffc020189e:	6b06                	ld	s6,64(sp)
ffffffffc02018a0:	7be2                	ld	s7,56(sp)
ffffffffc02018a2:	7c42                	ld	s8,48(sp)
ffffffffc02018a4:	7ca2                	ld	s9,40(sp)
ffffffffc02018a6:	7d02                	ld	s10,32(sp)
ffffffffc02018a8:	6de2                	ld	s11,24(sp)
ffffffffc02018aa:	6109                	addi	sp,sp,128
ffffffffc02018ac:	8082                	ret
    if (lflag >= 2) {
ffffffffc02018ae:	4705                	li	a4,1
ffffffffc02018b0:	008a8593          	addi	a1,s5,8
ffffffffc02018b4:	01074463          	blt	a4,a6,ffffffffc02018bc <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02018b8:	26080363          	beqz	a6,ffffffffc0201b1e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02018bc:	000ab603          	ld	a2,0(s5)
ffffffffc02018c0:	46c1                	li	a3,16
ffffffffc02018c2:	8aae                	mv	s5,a1
ffffffffc02018c4:	a06d                	j	ffffffffc020196e <vprintfmt+0x170>
            goto reswitch;
ffffffffc02018c6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02018ca:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018cc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018ce:	b765                	j	ffffffffc0201876 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02018d0:	000aa503          	lw	a0,0(s5)
ffffffffc02018d4:	85a6                	mv	a1,s1
ffffffffc02018d6:	0aa1                	addi	s5,s5,8
ffffffffc02018d8:	9902                	jalr	s2
            break;
ffffffffc02018da:	bfb9                	j	ffffffffc0201838 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018dc:	4705                	li	a4,1
ffffffffc02018de:	008a8993          	addi	s3,s5,8
ffffffffc02018e2:	01074463          	blt	a4,a6,ffffffffc02018ea <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02018e6:	22080463          	beqz	a6,ffffffffc0201b0e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02018ea:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02018ee:	24044463          	bltz	s0,ffffffffc0201b36 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02018f2:	8622                	mv	a2,s0
ffffffffc02018f4:	8ace                	mv	s5,s3
ffffffffc02018f6:	46a9                	li	a3,10
ffffffffc02018f8:	a89d                	j	ffffffffc020196e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02018fa:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02018fe:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201900:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201902:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201906:	8fb5                	xor	a5,a5,a3
ffffffffc0201908:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020190c:	1ad74363          	blt	a4,a3,ffffffffc0201ab2 <vprintfmt+0x2b4>
ffffffffc0201910:	00369793          	slli	a5,a3,0x3
ffffffffc0201914:	97e2                	add	a5,a5,s8
ffffffffc0201916:	639c                	ld	a5,0(a5)
ffffffffc0201918:	18078d63          	beqz	a5,ffffffffc0201ab2 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020191c:	86be                	mv	a3,a5
ffffffffc020191e:	00001617          	auipc	a2,0x1
ffffffffc0201922:	2a260613          	addi	a2,a2,674 # ffffffffc0202bc0 <error_string+0xe8>
ffffffffc0201926:	85a6                	mv	a1,s1
ffffffffc0201928:	854a                	mv	a0,s2
ffffffffc020192a:	240000ef          	jal	ra,ffffffffc0201b6a <printfmt>
ffffffffc020192e:	b729                	j	ffffffffc0201838 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201930:	00144603          	lbu	a2,1(s0)
ffffffffc0201934:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201936:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201938:	bf3d                	j	ffffffffc0201876 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020193a:	4705                	li	a4,1
ffffffffc020193c:	008a8593          	addi	a1,s5,8
ffffffffc0201940:	01074463          	blt	a4,a6,ffffffffc0201948 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201944:	1e080263          	beqz	a6,ffffffffc0201b28 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201948:	000ab603          	ld	a2,0(s5)
ffffffffc020194c:	46a1                	li	a3,8
ffffffffc020194e:	8aae                	mv	s5,a1
ffffffffc0201950:	a839                	j	ffffffffc020196e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201952:	03000513          	li	a0,48
ffffffffc0201956:	85a6                	mv	a1,s1
ffffffffc0201958:	e03e                	sd	a5,0(sp)
ffffffffc020195a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020195c:	85a6                	mv	a1,s1
ffffffffc020195e:	07800513          	li	a0,120
ffffffffc0201962:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201964:	0aa1                	addi	s5,s5,8
ffffffffc0201966:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020196a:	6782                	ld	a5,0(sp)
ffffffffc020196c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020196e:	876e                	mv	a4,s11
ffffffffc0201970:	85a6                	mv	a1,s1
ffffffffc0201972:	854a                	mv	a0,s2
ffffffffc0201974:	e1fff0ef          	jal	ra,ffffffffc0201792 <printnum>
            break;
ffffffffc0201978:	b5c1                	j	ffffffffc0201838 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020197a:	000ab603          	ld	a2,0(s5)
ffffffffc020197e:	0aa1                	addi	s5,s5,8
ffffffffc0201980:	1c060663          	beqz	a2,ffffffffc0201b4c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201984:	00160413          	addi	s0,a2,1
ffffffffc0201988:	17b05c63          	blez	s11,ffffffffc0201b00 <vprintfmt+0x302>
ffffffffc020198c:	02d00593          	li	a1,45
ffffffffc0201990:	14b79263          	bne	a5,a1,ffffffffc0201ad4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201994:	00064783          	lbu	a5,0(a2)
ffffffffc0201998:	0007851b          	sext.w	a0,a5
ffffffffc020199c:	c905                	beqz	a0,ffffffffc02019cc <vprintfmt+0x1ce>
ffffffffc020199e:	000cc563          	bltz	s9,ffffffffc02019a8 <vprintfmt+0x1aa>
ffffffffc02019a2:	3cfd                	addiw	s9,s9,-1
ffffffffc02019a4:	036c8263          	beq	s9,s6,ffffffffc02019c8 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02019a8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019aa:	18098463          	beqz	s3,ffffffffc0201b32 <vprintfmt+0x334>
ffffffffc02019ae:	3781                	addiw	a5,a5,-32
ffffffffc02019b0:	18fbf163          	bleu	a5,s7,ffffffffc0201b32 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02019b4:	03f00513          	li	a0,63
ffffffffc02019b8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019ba:	0405                	addi	s0,s0,1
ffffffffc02019bc:	fff44783          	lbu	a5,-1(s0)
ffffffffc02019c0:	3dfd                	addiw	s11,s11,-1
ffffffffc02019c2:	0007851b          	sext.w	a0,a5
ffffffffc02019c6:	fd61                	bnez	a0,ffffffffc020199e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02019c8:	e7b058e3          	blez	s11,ffffffffc0201838 <vprintfmt+0x3a>
ffffffffc02019cc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02019ce:	85a6                	mv	a1,s1
ffffffffc02019d0:	02000513          	li	a0,32
ffffffffc02019d4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02019d6:	e60d81e3          	beqz	s11,ffffffffc0201838 <vprintfmt+0x3a>
ffffffffc02019da:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02019dc:	85a6                	mv	a1,s1
ffffffffc02019de:	02000513          	li	a0,32
ffffffffc02019e2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02019e4:	fe0d94e3          	bnez	s11,ffffffffc02019cc <vprintfmt+0x1ce>
ffffffffc02019e8:	bd81                	j	ffffffffc0201838 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02019ea:	4705                	li	a4,1
ffffffffc02019ec:	008a8593          	addi	a1,s5,8
ffffffffc02019f0:	01074463          	blt	a4,a6,ffffffffc02019f8 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02019f4:	12080063          	beqz	a6,ffffffffc0201b14 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02019f8:	000ab603          	ld	a2,0(s5)
ffffffffc02019fc:	46a9                	li	a3,10
ffffffffc02019fe:	8aae                	mv	s5,a1
ffffffffc0201a00:	b7bd                	j	ffffffffc020196e <vprintfmt+0x170>
ffffffffc0201a02:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201a06:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a0a:	846a                	mv	s0,s10
ffffffffc0201a0c:	b5ad                	j	ffffffffc0201876 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201a0e:	85a6                	mv	a1,s1
ffffffffc0201a10:	02500513          	li	a0,37
ffffffffc0201a14:	9902                	jalr	s2
            break;
ffffffffc0201a16:	b50d                	j	ffffffffc0201838 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201a18:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201a1c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201a20:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a22:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201a24:	e40dd9e3          	bgez	s11,ffffffffc0201876 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201a28:	8de6                	mv	s11,s9
ffffffffc0201a2a:	5cfd                	li	s9,-1
ffffffffc0201a2c:	b5a9                	j	ffffffffc0201876 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201a2e:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201a32:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a36:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a38:	bd3d                	j	ffffffffc0201876 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201a3a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201a3e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a42:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201a44:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201a48:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a4c:	fcd56ce3          	bltu	a0,a3,ffffffffc0201a24 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201a50:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201a52:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201a56:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201a5a:	0196873b          	addw	a4,a3,s9
ffffffffc0201a5e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201a62:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201a66:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201a6a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201a6e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a72:	fcd57fe3          	bleu	a3,a0,ffffffffc0201a50 <vprintfmt+0x252>
ffffffffc0201a76:	b77d                	j	ffffffffc0201a24 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201a78:	fffdc693          	not	a3,s11
ffffffffc0201a7c:	96fd                	srai	a3,a3,0x3f
ffffffffc0201a7e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201a82:	00144603          	lbu	a2,1(s0)
ffffffffc0201a86:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a88:	846a                	mv	s0,s10
ffffffffc0201a8a:	b3f5                	j	ffffffffc0201876 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201a8c:	85a6                	mv	a1,s1
ffffffffc0201a8e:	02500513          	li	a0,37
ffffffffc0201a92:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201a94:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201a98:	02500793          	li	a5,37
ffffffffc0201a9c:	8d22                	mv	s10,s0
ffffffffc0201a9e:	d8f70de3          	beq	a4,a5,ffffffffc0201838 <vprintfmt+0x3a>
ffffffffc0201aa2:	02500713          	li	a4,37
ffffffffc0201aa6:	1d7d                	addi	s10,s10,-1
ffffffffc0201aa8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201aac:	fee79de3          	bne	a5,a4,ffffffffc0201aa6 <vprintfmt+0x2a8>
ffffffffc0201ab0:	b361                	j	ffffffffc0201838 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201ab2:	00001617          	auipc	a2,0x1
ffffffffc0201ab6:	0fe60613          	addi	a2,a2,254 # ffffffffc0202bb0 <error_string+0xd8>
ffffffffc0201aba:	85a6                	mv	a1,s1
ffffffffc0201abc:	854a                	mv	a0,s2
ffffffffc0201abe:	0ac000ef          	jal	ra,ffffffffc0201b6a <printfmt>
ffffffffc0201ac2:	bb9d                	j	ffffffffc0201838 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201ac4:	00001617          	auipc	a2,0x1
ffffffffc0201ac8:	0e460613          	addi	a2,a2,228 # ffffffffc0202ba8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201acc:	00001417          	auipc	s0,0x1
ffffffffc0201ad0:	0dd40413          	addi	s0,s0,221 # ffffffffc0202ba9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ad4:	8532                	mv	a0,a2
ffffffffc0201ad6:	85e6                	mv	a1,s9
ffffffffc0201ad8:	e032                	sd	a2,0(sp)
ffffffffc0201ada:	e43e                	sd	a5,8(sp)
ffffffffc0201adc:	1c2000ef          	jal	ra,ffffffffc0201c9e <strnlen>
ffffffffc0201ae0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201ae4:	6602                	ld	a2,0(sp)
ffffffffc0201ae6:	01b05d63          	blez	s11,ffffffffc0201b00 <vprintfmt+0x302>
ffffffffc0201aea:	67a2                	ld	a5,8(sp)
ffffffffc0201aec:	2781                	sext.w	a5,a5
ffffffffc0201aee:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201af0:	6522                	ld	a0,8(sp)
ffffffffc0201af2:	85a6                	mv	a1,s1
ffffffffc0201af4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201af6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201af8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201afa:	6602                	ld	a2,0(sp)
ffffffffc0201afc:	fe0d9ae3          	bnez	s11,ffffffffc0201af0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b00:	00064783          	lbu	a5,0(a2)
ffffffffc0201b04:	0007851b          	sext.w	a0,a5
ffffffffc0201b08:	e8051be3          	bnez	a0,ffffffffc020199e <vprintfmt+0x1a0>
ffffffffc0201b0c:	b335                	j	ffffffffc0201838 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201b0e:	000aa403          	lw	s0,0(s5)
ffffffffc0201b12:	bbf1                	j	ffffffffc02018ee <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201b14:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b18:	46a9                	li	a3,10
ffffffffc0201b1a:	8aae                	mv	s5,a1
ffffffffc0201b1c:	bd89                	j	ffffffffc020196e <vprintfmt+0x170>
ffffffffc0201b1e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b22:	46c1                	li	a3,16
ffffffffc0201b24:	8aae                	mv	s5,a1
ffffffffc0201b26:	b5a1                	j	ffffffffc020196e <vprintfmt+0x170>
ffffffffc0201b28:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b2c:	46a1                	li	a3,8
ffffffffc0201b2e:	8aae                	mv	s5,a1
ffffffffc0201b30:	bd3d                	j	ffffffffc020196e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201b32:	9902                	jalr	s2
ffffffffc0201b34:	b559                	j	ffffffffc02019ba <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201b36:	85a6                	mv	a1,s1
ffffffffc0201b38:	02d00513          	li	a0,45
ffffffffc0201b3c:	e03e                	sd	a5,0(sp)
ffffffffc0201b3e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201b40:	8ace                	mv	s5,s3
ffffffffc0201b42:	40800633          	neg	a2,s0
ffffffffc0201b46:	46a9                	li	a3,10
ffffffffc0201b48:	6782                	ld	a5,0(sp)
ffffffffc0201b4a:	b515                	j	ffffffffc020196e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201b4c:	01b05663          	blez	s11,ffffffffc0201b58 <vprintfmt+0x35a>
ffffffffc0201b50:	02d00693          	li	a3,45
ffffffffc0201b54:	f6d798e3          	bne	a5,a3,ffffffffc0201ac4 <vprintfmt+0x2c6>
ffffffffc0201b58:	00001417          	auipc	s0,0x1
ffffffffc0201b5c:	05140413          	addi	s0,s0,81 # ffffffffc0202ba9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b60:	02800513          	li	a0,40
ffffffffc0201b64:	02800793          	li	a5,40
ffffffffc0201b68:	bd1d                	j	ffffffffc020199e <vprintfmt+0x1a0>

ffffffffc0201b6a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b6a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201b6c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b70:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b72:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b74:	ec06                	sd	ra,24(sp)
ffffffffc0201b76:	f83a                	sd	a4,48(sp)
ffffffffc0201b78:	fc3e                	sd	a5,56(sp)
ffffffffc0201b7a:	e0c2                	sd	a6,64(sp)
ffffffffc0201b7c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201b7e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b80:	c7fff0ef          	jal	ra,ffffffffc02017fe <vprintfmt>
}
ffffffffc0201b84:	60e2                	ld	ra,24(sp)
ffffffffc0201b86:	6161                	addi	sp,sp,80
ffffffffc0201b88:	8082                	ret

ffffffffc0201b8a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201b8a:	715d                	addi	sp,sp,-80
ffffffffc0201b8c:	e486                	sd	ra,72(sp)
ffffffffc0201b8e:	e0a2                	sd	s0,64(sp)
ffffffffc0201b90:	fc26                	sd	s1,56(sp)
ffffffffc0201b92:	f84a                	sd	s2,48(sp)
ffffffffc0201b94:	f44e                	sd	s3,40(sp)
ffffffffc0201b96:	f052                	sd	s4,32(sp)
ffffffffc0201b98:	ec56                	sd	s5,24(sp)
ffffffffc0201b9a:	e85a                	sd	s6,16(sp)
ffffffffc0201b9c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201b9e:	c901                	beqz	a0,ffffffffc0201bae <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201ba0:	85aa                	mv	a1,a0
ffffffffc0201ba2:	00001517          	auipc	a0,0x1
ffffffffc0201ba6:	01e50513          	addi	a0,a0,30 # ffffffffc0202bc0 <error_string+0xe8>
ffffffffc0201baa:	fdafe0ef          	jal	ra,ffffffffc0200384 <cprintf>
readline(const char *prompt) {
ffffffffc0201bae:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bb0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201bb2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201bb4:	4aa9                	li	s5,10
ffffffffc0201bb6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201bb8:	00004b97          	auipc	s7,0x4
ffffffffc0201bbc:	458b8b93          	addi	s7,s7,1112 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bc0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201bc4:	839fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc0201bc8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201bca:	00054b63          	bltz	a0,ffffffffc0201be0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bce:	00a95b63          	ble	a0,s2,ffffffffc0201be4 <readline+0x5a>
ffffffffc0201bd2:	029a5463          	ble	s1,s4,ffffffffc0201bfa <readline+0x70>
        c = getchar();
ffffffffc0201bd6:	827fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc0201bda:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201bdc:	fe0559e3          	bgez	a0,ffffffffc0201bce <readline+0x44>
            return NULL;
ffffffffc0201be0:	4501                	li	a0,0
ffffffffc0201be2:	a099                	j	ffffffffc0201c28 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201be4:	03341463          	bne	s0,s3,ffffffffc0201c0c <readline+0x82>
ffffffffc0201be8:	e8b9                	bnez	s1,ffffffffc0201c3e <readline+0xb4>
        c = getchar();
ffffffffc0201bea:	813fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc0201bee:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201bf0:	fe0548e3          	bltz	a0,ffffffffc0201be0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bf4:	fea958e3          	ble	a0,s2,ffffffffc0201be4 <readline+0x5a>
ffffffffc0201bf8:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201bfa:	8522                	mv	a0,s0
ffffffffc0201bfc:	fbcfe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            buf[i ++] = c;
ffffffffc0201c00:	009b87b3          	add	a5,s7,s1
ffffffffc0201c04:	00878023          	sb	s0,0(a5)
ffffffffc0201c08:	2485                	addiw	s1,s1,1
ffffffffc0201c0a:	bf6d                	j	ffffffffc0201bc4 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201c0c:	01540463          	beq	s0,s5,ffffffffc0201c14 <readline+0x8a>
ffffffffc0201c10:	fb641ae3          	bne	s0,s6,ffffffffc0201bc4 <readline+0x3a>
            cputchar(c);
ffffffffc0201c14:	8522                	mv	a0,s0
ffffffffc0201c16:	fa2fe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            buf[i] = '\0';
ffffffffc0201c1a:	00004517          	auipc	a0,0x4
ffffffffc0201c1e:	3f650513          	addi	a0,a0,1014 # ffffffffc0206010 <edata>
ffffffffc0201c22:	94aa                	add	s1,s1,a0
ffffffffc0201c24:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201c28:	60a6                	ld	ra,72(sp)
ffffffffc0201c2a:	6406                	ld	s0,64(sp)
ffffffffc0201c2c:	74e2                	ld	s1,56(sp)
ffffffffc0201c2e:	7942                	ld	s2,48(sp)
ffffffffc0201c30:	79a2                	ld	s3,40(sp)
ffffffffc0201c32:	7a02                	ld	s4,32(sp)
ffffffffc0201c34:	6ae2                	ld	s5,24(sp)
ffffffffc0201c36:	6b42                	ld	s6,16(sp)
ffffffffc0201c38:	6ba2                	ld	s7,8(sp)
ffffffffc0201c3a:	6161                	addi	sp,sp,80
ffffffffc0201c3c:	8082                	ret
            cputchar(c);
ffffffffc0201c3e:	4521                	li	a0,8
ffffffffc0201c40:	f78fe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            i --;
ffffffffc0201c44:	34fd                	addiw	s1,s1,-1
ffffffffc0201c46:	bfbd                	j	ffffffffc0201bc4 <readline+0x3a>

ffffffffc0201c48 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201c48:	00004797          	auipc	a5,0x4
ffffffffc0201c4c:	3c078793          	addi	a5,a5,960 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201c50:	6398                	ld	a4,0(a5)
ffffffffc0201c52:	4781                	li	a5,0
ffffffffc0201c54:	88ba                	mv	a7,a4
ffffffffc0201c56:	852a                	mv	a0,a0
ffffffffc0201c58:	85be                	mv	a1,a5
ffffffffc0201c5a:	863e                	mv	a2,a5
ffffffffc0201c5c:	00000073          	ecall
ffffffffc0201c60:	87aa                	mv	a5,a0
}
ffffffffc0201c62:	8082                	ret

ffffffffc0201c64 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201c64:	00004797          	auipc	a5,0x4
ffffffffc0201c68:	7c478793          	addi	a5,a5,1988 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201c6c:	6398                	ld	a4,0(a5)
ffffffffc0201c6e:	4781                	li	a5,0
ffffffffc0201c70:	88ba                	mv	a7,a4
ffffffffc0201c72:	852a                	mv	a0,a0
ffffffffc0201c74:	85be                	mv	a1,a5
ffffffffc0201c76:	863e                	mv	a2,a5
ffffffffc0201c78:	00000073          	ecall
ffffffffc0201c7c:	87aa                	mv	a5,a0
}
ffffffffc0201c7e:	8082                	ret

ffffffffc0201c80 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201c80:	00004797          	auipc	a5,0x4
ffffffffc0201c84:	38078793          	addi	a5,a5,896 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201c88:	639c                	ld	a5,0(a5)
ffffffffc0201c8a:	4501                	li	a0,0
ffffffffc0201c8c:	88be                	mv	a7,a5
ffffffffc0201c8e:	852a                	mv	a0,a0
ffffffffc0201c90:	85aa                	mv	a1,a0
ffffffffc0201c92:	862a                	mv	a2,a0
ffffffffc0201c94:	00000073          	ecall
ffffffffc0201c98:	852a                	mv	a0,a0
ffffffffc0201c9a:	2501                	sext.w	a0,a0
ffffffffc0201c9c:	8082                	ret

ffffffffc0201c9e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201c9e:	c185                	beqz	a1,ffffffffc0201cbe <strnlen+0x20>
ffffffffc0201ca0:	00054783          	lbu	a5,0(a0)
ffffffffc0201ca4:	cf89                	beqz	a5,ffffffffc0201cbe <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201ca6:	4781                	li	a5,0
ffffffffc0201ca8:	a021                	j	ffffffffc0201cb0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201caa:	00074703          	lbu	a4,0(a4)
ffffffffc0201cae:	c711                	beqz	a4,ffffffffc0201cba <strnlen+0x1c>
        cnt ++;
ffffffffc0201cb0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201cb2:	00f50733          	add	a4,a0,a5
ffffffffc0201cb6:	fef59ae3          	bne	a1,a5,ffffffffc0201caa <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201cba:	853e                	mv	a0,a5
ffffffffc0201cbc:	8082                	ret
    size_t cnt = 0;
ffffffffc0201cbe:	4781                	li	a5,0
}
ffffffffc0201cc0:	853e                	mv	a0,a5
ffffffffc0201cc2:	8082                	ret

ffffffffc0201cc4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201cc4:	00054783          	lbu	a5,0(a0)
ffffffffc0201cc8:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ccc:	cb91                	beqz	a5,ffffffffc0201ce0 <strcmp+0x1c>
ffffffffc0201cce:	00e79c63          	bne	a5,a4,ffffffffc0201ce6 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201cd2:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201cd4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201cd8:	0585                	addi	a1,a1,1
ffffffffc0201cda:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201cde:	fbe5                	bnez	a5,ffffffffc0201cce <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ce0:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ce2:	9d19                	subw	a0,a0,a4
ffffffffc0201ce4:	8082                	ret
ffffffffc0201ce6:	0007851b          	sext.w	a0,a5
ffffffffc0201cea:	9d19                	subw	a0,a0,a4
ffffffffc0201cec:	8082                	ret

ffffffffc0201cee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201cee:	00054783          	lbu	a5,0(a0)
ffffffffc0201cf2:	cb91                	beqz	a5,ffffffffc0201d06 <strchr+0x18>
        if (*s == c) {
ffffffffc0201cf4:	00b79563          	bne	a5,a1,ffffffffc0201cfe <strchr+0x10>
ffffffffc0201cf8:	a809                	j	ffffffffc0201d0a <strchr+0x1c>
ffffffffc0201cfa:	00b78763          	beq	a5,a1,ffffffffc0201d08 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201cfe:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201d00:	00054783          	lbu	a5,0(a0)
ffffffffc0201d04:	fbfd                	bnez	a5,ffffffffc0201cfa <strchr+0xc>
    }
    return NULL;
ffffffffc0201d06:	4501                	li	a0,0
}
ffffffffc0201d08:	8082                	ret
ffffffffc0201d0a:	8082                	ret

ffffffffc0201d0c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201d0c:	ca01                	beqz	a2,ffffffffc0201d1c <memset+0x10>
ffffffffc0201d0e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201d10:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201d12:	0785                	addi	a5,a5,1
ffffffffc0201d14:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201d18:	fec79de3          	bne	a5,a2,ffffffffc0201d12 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201d1c:	8082                	ret
