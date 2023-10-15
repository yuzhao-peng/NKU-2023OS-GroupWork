
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
ffffffffc020004e:	26f010ef          	jal	ra,ffffffffc0201abc <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(NKUs.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201ad0 <etext+0x2>
ffffffffc020005e:	35e000ef          	jal	ra,ffffffffc02003bc <cputs>

    print_kerninfo();
ffffffffc0200062:	01a000ef          	jal	ra,ffffffffc020007c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	32a010ef          	jal	ra,ffffffffc0201394 <pmm_init>

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
ffffffffc0200082:	aa250513          	addi	a0,a0,-1374 # ffffffffc0201b20 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200086:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200088:	2fc000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020008c:	00000597          	auipc	a1,0x0
ffffffffc0200090:	faa58593          	addi	a1,a1,-86 # ffffffffc0200036 <kern_init>
ffffffffc0200094:	00002517          	auipc	a0,0x2
ffffffffc0200098:	aac50513          	addi	a0,a0,-1364 # ffffffffc0201b40 <etext+0x72>
ffffffffc020009c:	2e8000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02000a0:	00002597          	auipc	a1,0x2
ffffffffc02000a4:	a2e58593          	addi	a1,a1,-1490 # ffffffffc0201ace <etext>
ffffffffc02000a8:	00002517          	auipc	a0,0x2
ffffffffc02000ac:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201b60 <etext+0x92>
ffffffffc02000b0:	2d4000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02000b4:	00006597          	auipc	a1,0x6
ffffffffc02000b8:	f5c58593          	addi	a1,a1,-164 # ffffffffc0206010 <edata>
ffffffffc02000bc:	00002517          	auipc	a0,0x2
ffffffffc02000c0:	ac450513          	addi	a0,a0,-1340 # ffffffffc0201b80 <etext+0xb2>
ffffffffc02000c4:	2c0000ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02000c8:	00006597          	auipc	a1,0x6
ffffffffc02000cc:	3a858593          	addi	a1,a1,936 # ffffffffc0206470 <end>
ffffffffc02000d0:	00002517          	auipc	a0,0x2
ffffffffc02000d4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0201ba0 <etext+0xd2>
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
ffffffffc0200102:	ac250513          	addi	a0,a0,-1342 # ffffffffc0201bc0 <etext+0xf2>
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
ffffffffc0200112:	9e260613          	addi	a2,a2,-1566 # ffffffffc0201af0 <etext+0x22>
ffffffffc0200116:	04e00593          	li	a1,78
ffffffffc020011a:	00002517          	auipc	a0,0x2
ffffffffc020011e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0201b08 <etext+0x3a>
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
ffffffffc020012e:	ba660613          	addi	a2,a2,-1114 # ffffffffc0201cd0 <commands+0xe0>
ffffffffc0200132:	00002597          	auipc	a1,0x2
ffffffffc0200136:	bbe58593          	addi	a1,a1,-1090 # ffffffffc0201cf0 <commands+0x100>
ffffffffc020013a:	00002517          	auipc	a0,0x2
ffffffffc020013e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0201cf8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200142:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200144:	240000ef          	jal	ra,ffffffffc0200384 <cprintf>
ffffffffc0200148:	00002617          	auipc	a2,0x2
ffffffffc020014c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0201d08 <commands+0x118>
ffffffffc0200150:	00002597          	auipc	a1,0x2
ffffffffc0200154:	be058593          	addi	a1,a1,-1056 # ffffffffc0201d30 <commands+0x140>
ffffffffc0200158:	00002517          	auipc	a0,0x2
ffffffffc020015c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0201cf8 <commands+0x108>
ffffffffc0200160:	224000ef          	jal	ra,ffffffffc0200384 <cprintf>
ffffffffc0200164:	00002617          	auipc	a2,0x2
ffffffffc0200168:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0201d40 <commands+0x150>
ffffffffc020016c:	00002597          	auipc	a1,0x2
ffffffffc0200170:	bf458593          	addi	a1,a1,-1036 # ffffffffc0201d60 <commands+0x170>
ffffffffc0200174:	00002517          	auipc	a0,0x2
ffffffffc0200178:	b8450513          	addi	a0,a0,-1148 # ffffffffc0201cf8 <commands+0x108>
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
ffffffffc02001b2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201c38 <commands+0x48>
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
ffffffffc02001d4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201c60 <commands+0x70>
ffffffffc02001d8:	1ac000ef          	jal	ra,ffffffffc0200384 <cprintf>
    if (tf != NULL) {
ffffffffc02001dc:	000c0563          	beqz	s8,ffffffffc02001e6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02001e0:	8562                	mv	a0,s8
ffffffffc02001e2:	468000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02001e6:	00002c97          	auipc	s9,0x2
ffffffffc02001ea:	a0ac8c93          	addi	s9,s9,-1526 # ffffffffc0201bf0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02001ee:	00002997          	auipc	s3,0x2
ffffffffc02001f2:	a9a98993          	addi	s3,s3,-1382 # ffffffffc0201c88 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02001f6:	00002917          	auipc	s2,0x2
ffffffffc02001fa:	a9a90913          	addi	s2,s2,-1382 # ffffffffc0201c90 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02001fe:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200200:	00002b17          	auipc	s6,0x2
ffffffffc0200204:	a98b0b13          	addi	s6,s6,-1384 # ffffffffc0201c98 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200208:	00002a97          	auipc	s5,0x2
ffffffffc020020c:	ae8a8a93          	addi	s5,s5,-1304 # ffffffffc0201cf0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200210:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200212:	854e                	mv	a0,s3
ffffffffc0200214:	726010ef          	jal	ra,ffffffffc020193a <readline>
ffffffffc0200218:	842a                	mv	s0,a0
ffffffffc020021a:	dd65                	beqz	a0,ffffffffc0200212 <kmonitor+0x6a>
ffffffffc020021c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200220:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200222:	c999                	beqz	a1,ffffffffc0200238 <kmonitor+0x90>
ffffffffc0200224:	854a                	mv	a0,s2
ffffffffc0200226:	079010ef          	jal	ra,ffffffffc0201a9e <strchr>
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
ffffffffc0200240:	9b4d0d13          	addi	s10,s10,-1612 # ffffffffc0201bf0 <commands>
    if (argc == 0) {
ffffffffc0200244:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200246:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200248:	0d61                	addi	s10,s10,24
ffffffffc020024a:	02b010ef          	jal	ra,ffffffffc0201a74 <strcmp>
ffffffffc020024e:	c919                	beqz	a0,ffffffffc0200264 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200250:	2405                	addiw	s0,s0,1
ffffffffc0200252:	09740463          	beq	s0,s7,ffffffffc02002da <kmonitor+0x132>
ffffffffc0200256:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020025a:	6582                	ld	a1,0(sp)
ffffffffc020025c:	0d61                	addi	s10,s10,24
ffffffffc020025e:	017010ef          	jal	ra,ffffffffc0201a74 <strcmp>
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
ffffffffc02002c4:	7da010ef          	jal	ra,ffffffffc0201a9e <strchr>
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
ffffffffc02002e0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201cb8 <commands+0xc8>
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
ffffffffc0200320:	a5450513          	addi	a0,a0,-1452 # ffffffffc0201d70 <commands+0x180>
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
ffffffffc0200336:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201be8 <etext+0x11a>
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
ffffffffc0200378:	236010ef          	jal	ra,ffffffffc02015ae <vprintfmt>
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
ffffffffc02003ac:	202010ef          	jal	ra,ffffffffc02015ae <vprintfmt>
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
ffffffffc0200424:	5f0010ef          	jal	ra,ffffffffc0201a14 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201d90 <commands+0x1a0>
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
ffffffffc020044c:	5c80106f          	j	ffffffffc0201a14 <sbi_set_timer>

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
ffffffffc0200456:	5a20106f          	j	ffffffffc02019f8 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	5d60106f          	j	ffffffffc0201a30 <sbi_console_getchar>

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
ffffffffc0200488:	a2450513          	addi	a0,a0,-1500 # ffffffffc0201ea8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	ef7ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0201ec0 <commands+0x2d0>
ffffffffc020049c:	ee9ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a3650513          	addi	a0,a0,-1482 # ffffffffc0201ed8 <commands+0x2e8>
ffffffffc02004aa:	edbff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0201ef0 <commands+0x300>
ffffffffc02004b8:	ecdff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0201f08 <commands+0x318>
ffffffffc02004c6:	ebfff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0201f20 <commands+0x330>
ffffffffc02004d4:	eb1ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0201f38 <commands+0x348>
ffffffffc02004e2:	ea3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a6850513          	addi	a0,a0,-1432 # ffffffffc0201f50 <commands+0x360>
ffffffffc02004f0:	e95ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a7250513          	addi	a0,a0,-1422 # ffffffffc0201f68 <commands+0x378>
ffffffffc02004fe:	e87ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0201f80 <commands+0x390>
ffffffffc020050c:	e79ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	a8650513          	addi	a0,a0,-1402 # ffffffffc0201f98 <commands+0x3a8>
ffffffffc020051a:	e6bff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201fb0 <commands+0x3c0>
ffffffffc0200528:	e5dff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0201fc8 <commands+0x3d8>
ffffffffc0200536:	e4fff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201fe0 <commands+0x3f0>
ffffffffc0200544:	e41ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	aae50513          	addi	a0,a0,-1362 # ffffffffc0201ff8 <commands+0x408>
ffffffffc0200552:	e33ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0202010 <commands+0x420>
ffffffffc0200560:	e25ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0202028 <commands+0x438>
ffffffffc020056e:	e17ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	acc50513          	addi	a0,a0,-1332 # ffffffffc0202040 <commands+0x450>
ffffffffc020057c:	e09ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ad650513          	addi	a0,a0,-1322 # ffffffffc0202058 <commands+0x468>
ffffffffc020058a:	dfbff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	ae050513          	addi	a0,a0,-1312 # ffffffffc0202070 <commands+0x480>
ffffffffc0200598:	dedff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	aea50513          	addi	a0,a0,-1302 # ffffffffc0202088 <commands+0x498>
ffffffffc02005a6:	ddfff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	af450513          	addi	a0,a0,-1292 # ffffffffc02020a0 <commands+0x4b0>
ffffffffc02005b4:	dd1ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	afe50513          	addi	a0,a0,-1282 # ffffffffc02020b8 <commands+0x4c8>
ffffffffc02005c2:	dc3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b0850513          	addi	a0,a0,-1272 # ffffffffc02020d0 <commands+0x4e0>
ffffffffc02005d0:	db5ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b1250513          	addi	a0,a0,-1262 # ffffffffc02020e8 <commands+0x4f8>
ffffffffc02005de:	da7ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0202100 <commands+0x510>
ffffffffc02005ec:	d99ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b2650513          	addi	a0,a0,-1242 # ffffffffc0202118 <commands+0x528>
ffffffffc02005fa:	d8bff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b3050513          	addi	a0,a0,-1232 # ffffffffc0202130 <commands+0x540>
ffffffffc0200608:	d7dff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0202148 <commands+0x558>
ffffffffc0200616:	d6fff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b4450513          	addi	a0,a0,-1212 # ffffffffc0202160 <commands+0x570>
ffffffffc0200624:	d61ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202178 <commands+0x588>
ffffffffc0200632:	d53ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202190 <commands+0x5a0>
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
ffffffffc0200656:	b5650513          	addi	a0,a0,-1194 # ffffffffc02021a8 <commands+0x5b8>
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
ffffffffc020066e:	b5650513          	addi	a0,a0,-1194 # ffffffffc02021c0 <commands+0x5d0>
ffffffffc0200672:	d13ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02021d8 <commands+0x5e8>
ffffffffc0200682:	d03ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021f0 <commands+0x600>
ffffffffc0200692:	cf3ff0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0202208 <commands+0x618>
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
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	6f070713          	addi	a4,a4,1776 # ffffffffc0201dac <commands+0x1bc>
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
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	77250513          	addi	a0,a0,1906 # ffffffffc0201e40 <commands+0x250>
ffffffffc02006d6:	cafff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	74650513          	addi	a0,a0,1862 # ffffffffc0201e20 <commands+0x230>
ffffffffc02006e2:	ca3ff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201de0 <commands+0x1f0>
ffffffffc02006ee:	c97ff06f          	j	ffffffffc0200384 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	76e50513          	addi	a0,a0,1902 # ffffffffc0201e60 <commands+0x270>
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
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	75e50513          	addi	a0,a0,1886 # ffffffffc0201e88 <commands+0x298>
ffffffffc0200732:	c53ff06f          	j	ffffffffc0200384 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	6ca50513          	addi	a0,a0,1738 # ffffffffc0201e00 <commands+0x210>
ffffffffc020073e:	c47ff06f          	j	ffffffffc0200384 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	72c50513          	addi	a0,a0,1836 # ffffffffc0201e78 <commands+0x288>
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
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200846:	c15d                	beqz	a0,ffffffffc02008ec <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200848:	00006617          	auipc	a2,0x6
ffffffffc020084c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206438 <free_area>
ffffffffc0200850:	01062803          	lw	a6,16(a2)
ffffffffc0200854:	86aa                	mv	a3,a0
ffffffffc0200856:	02081793          	slli	a5,a6,0x20
ffffffffc020085a:	9381                	srli	a5,a5,0x20
ffffffffc020085c:	08a7e663          	bltu	a5,a0,ffffffffc02008e8 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200860:	0018059b          	addiw	a1,a6,1
ffffffffc0200864:	1582                	slli	a1,a1,0x20
ffffffffc0200866:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200868:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc020086a:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020086c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020086e:	00c78e63          	beq	a5,a2,ffffffffc020088a <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property < min_size) { // 如果当前的空闲块小于"最小量"
ffffffffc0200872:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200876:	fed76be3          	bltu	a4,a3,ffffffffc020086c <best_fit_alloc_pages+0x26>
ffffffffc020087a:	feb779e3          	bleu	a1,a4,ffffffffc020086c <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc020087e:	fe878513          	addi	a0,a5,-24
ffffffffc0200882:	679c                	ld	a5,8(a5)
ffffffffc0200884:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200886:	fec796e3          	bne	a5,a2,ffffffffc0200872 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020088a:	c125                	beqz	a0,ffffffffc02008ea <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc020088c:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc020088e:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200890:	490c                	lw	a1,16(a0)
ffffffffc0200892:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200896:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200898:	e310                	sd	a2,0(a4)
ffffffffc020089a:	02059713          	slli	a4,a1,0x20
ffffffffc020089e:	9301                	srli	a4,a4,0x20
ffffffffc02008a0:	02e6f863          	bleu	a4,a3,ffffffffc02008d0 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc02008a4:	00269713          	slli	a4,a3,0x2
ffffffffc02008a8:	9736                	add	a4,a4,a3
ffffffffc02008aa:	070e                	slli	a4,a4,0x3
ffffffffc02008ac:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008ae:	411585bb          	subw	a1,a1,a7
ffffffffc02008b2:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008b4:	4689                	li	a3,2
ffffffffc02008b6:	00870593          	addi	a1,a4,8
ffffffffc02008ba:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008be:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008c0:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008c4:	0107a803          	lw	a6,16(a5)
ffffffffc02008c8:	e28c                	sd	a1,0(a3)
ffffffffc02008ca:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008cc:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008ce:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02008d0:	4118083b          	subw	a6,a6,a7
ffffffffc02008d4:	00006797          	auipc	a5,0x6
ffffffffc02008d8:	b707aa23          	sw	a6,-1164(a5) # ffffffffc0206448 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008dc:	57f5                	li	a5,-3
ffffffffc02008de:	00850713          	addi	a4,a0,8
ffffffffc02008e2:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008e6:	8082                	ret
        return NULL;
ffffffffc02008e8:	4501                	li	a0,0
}
ffffffffc02008ea:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008ec:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008ee:	00002697          	auipc	a3,0x2
ffffffffc02008f2:	93268693          	addi	a3,a3,-1742 # ffffffffc0202220 <commands+0x630>
ffffffffc02008f6:	00002617          	auipc	a2,0x2
ffffffffc02008fa:	93260613          	addi	a2,a2,-1742 # ffffffffc0202228 <commands+0x638>
ffffffffc02008fe:	03a00593          	li	a1,58
ffffffffc0200902:	00002517          	auipc	a0,0x2
ffffffffc0200906:	93e50513          	addi	a0,a0,-1730 # ffffffffc0202240 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc020090a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020090c:	9dfff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0200910 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200910:	715d                	addi	sp,sp,-80
ffffffffc0200912:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200914:	00006917          	auipc	s2,0x6
ffffffffc0200918:	b2490913          	addi	s2,s2,-1244 # ffffffffc0206438 <free_area>
ffffffffc020091c:	00893783          	ld	a5,8(s2)
ffffffffc0200920:	e486                	sd	ra,72(sp)
ffffffffc0200922:	e0a2                	sd	s0,64(sp)
ffffffffc0200924:	fc26                	sd	s1,56(sp)
ffffffffc0200926:	f44e                	sd	s3,40(sp)
ffffffffc0200928:	f052                	sd	s4,32(sp)
ffffffffc020092a:	ec56                	sd	s5,24(sp)
ffffffffc020092c:	e85a                	sd	s6,16(sp)
ffffffffc020092e:	e45e                	sd	s7,8(sp)
ffffffffc0200930:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200932:	2d278363          	beq	a5,s2,ffffffffc0200bf8 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200936:	ff07b703          	ld	a4,-16(a5)
ffffffffc020093a:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020093c:	8b05                	andi	a4,a4,1
ffffffffc020093e:	2c070163          	beqz	a4,ffffffffc0200c00 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200942:	4401                	li	s0,0
ffffffffc0200944:	4481                	li	s1,0
ffffffffc0200946:	a031                	j	ffffffffc0200952 <best_fit_check+0x42>
ffffffffc0200948:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020094c:	8b09                	andi	a4,a4,2
ffffffffc020094e:	2a070963          	beqz	a4,ffffffffc0200c00 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200952:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200956:	679c                	ld	a5,8(a5)
ffffffffc0200958:	2485                	addiw	s1,s1,1
ffffffffc020095a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020095c:	ff2796e3          	bne	a5,s2,ffffffffc0200948 <best_fit_check+0x38>
ffffffffc0200960:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200962:	1f3000ef          	jal	ra,ffffffffc0201354 <nr_free_pages>
ffffffffc0200966:	37351d63          	bne	a0,s3,ffffffffc0200ce0 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020096a:	4505                	li	a0,1
ffffffffc020096c:	15f000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200970:	8a2a                	mv	s4,a0
ffffffffc0200972:	3a050763          	beqz	a0,ffffffffc0200d20 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200976:	4505                	li	a0,1
ffffffffc0200978:	153000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc020097c:	89aa                	mv	s3,a0
ffffffffc020097e:	38050163          	beqz	a0,ffffffffc0200d00 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200982:	4505                	li	a0,1
ffffffffc0200984:	147000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200988:	8aaa                	mv	s5,a0
ffffffffc020098a:	30050b63          	beqz	a0,ffffffffc0200ca0 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020098e:	293a0963          	beq	s4,s3,ffffffffc0200c20 <best_fit_check+0x310>
ffffffffc0200992:	28aa0763          	beq	s4,a0,ffffffffc0200c20 <best_fit_check+0x310>
ffffffffc0200996:	28a98563          	beq	s3,a0,ffffffffc0200c20 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020099a:	000a2783          	lw	a5,0(s4)
ffffffffc020099e:	2a079163          	bnez	a5,ffffffffc0200c40 <best_fit_check+0x330>
ffffffffc02009a2:	0009a783          	lw	a5,0(s3)
ffffffffc02009a6:	28079d63          	bnez	a5,ffffffffc0200c40 <best_fit_check+0x330>
ffffffffc02009aa:	411c                	lw	a5,0(a0)
ffffffffc02009ac:	28079a63          	bnez	a5,ffffffffc0200c40 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009b0:	00006797          	auipc	a5,0x6
ffffffffc02009b4:	ab878793          	addi	a5,a5,-1352 # ffffffffc0206468 <pages>
ffffffffc02009b8:	639c                	ld	a5,0(a5)
ffffffffc02009ba:	00002717          	auipc	a4,0x2
ffffffffc02009be:	89e70713          	addi	a4,a4,-1890 # ffffffffc0202258 <commands+0x668>
ffffffffc02009c2:	630c                	ld	a1,0(a4)
ffffffffc02009c4:	40fa0733          	sub	a4,s4,a5
ffffffffc02009c8:	870d                	srai	a4,a4,0x3
ffffffffc02009ca:	02b70733          	mul	a4,a4,a1
ffffffffc02009ce:	00002697          	auipc	a3,0x2
ffffffffc02009d2:	f4a68693          	addi	a3,a3,-182 # ffffffffc0202918 <nbase>
ffffffffc02009d6:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009d8:	00006697          	auipc	a3,0x6
ffffffffc02009dc:	a4068693          	addi	a3,a3,-1472 # ffffffffc0206418 <npage>
ffffffffc02009e0:	6294                	ld	a3,0(a3)
ffffffffc02009e2:	06b2                	slli	a3,a3,0xc
ffffffffc02009e4:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e6:	0732                	slli	a4,a4,0xc
ffffffffc02009e8:	26d77c63          	bleu	a3,a4,ffffffffc0200c60 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ec:	40f98733          	sub	a4,s3,a5
ffffffffc02009f0:	870d                	srai	a4,a4,0x3
ffffffffc02009f2:	02b70733          	mul	a4,a4,a1
ffffffffc02009f6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009f8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009fa:	42d77363          	bleu	a3,a4,ffffffffc0200e20 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009fe:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a02:	878d                	srai	a5,a5,0x3
ffffffffc0200a04:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a08:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a0a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a0c:	3ed7fa63          	bleu	a3,a5,ffffffffc0200e00 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a10:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a12:	00093c03          	ld	s8,0(s2)
ffffffffc0200a16:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a1a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a1e:	00006797          	auipc	a5,0x6
ffffffffc0200a22:	a327b123          	sd	s2,-1502(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200a26:	00006797          	auipc	a5,0x6
ffffffffc0200a2a:	a127b923          	sd	s2,-1518(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200a2e:	00006797          	auipc	a5,0x6
ffffffffc0200a32:	a007ad23          	sw	zero,-1510(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a36:	095000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200a3a:	3a051363          	bnez	a0,ffffffffc0200de0 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a3e:	4585                	li	a1,1
ffffffffc0200a40:	8552                	mv	a0,s4
ffffffffc0200a42:	0cd000ef          	jal	ra,ffffffffc020130e <free_pages>
    free_page(p1);
ffffffffc0200a46:	4585                	li	a1,1
ffffffffc0200a48:	854e                	mv	a0,s3
ffffffffc0200a4a:	0c5000ef          	jal	ra,ffffffffc020130e <free_pages>
    free_page(p2);
ffffffffc0200a4e:	4585                	li	a1,1
ffffffffc0200a50:	8556                	mv	a0,s5
ffffffffc0200a52:	0bd000ef          	jal	ra,ffffffffc020130e <free_pages>
    assert(nr_free == 3);
ffffffffc0200a56:	01092703          	lw	a4,16(s2)
ffffffffc0200a5a:	478d                	li	a5,3
ffffffffc0200a5c:	36f71263          	bne	a4,a5,ffffffffc0200dc0 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a60:	4505                	li	a0,1
ffffffffc0200a62:	069000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200a66:	89aa                	mv	s3,a0
ffffffffc0200a68:	32050c63          	beqz	a0,ffffffffc0200da0 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a6c:	4505                	li	a0,1
ffffffffc0200a6e:	05d000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200a72:	8aaa                	mv	s5,a0
ffffffffc0200a74:	30050663          	beqz	a0,ffffffffc0200d80 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a78:	4505                	li	a0,1
ffffffffc0200a7a:	051000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200a7e:	8a2a                	mv	s4,a0
ffffffffc0200a80:	2e050063          	beqz	a0,ffffffffc0200d60 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a84:	4505                	li	a0,1
ffffffffc0200a86:	045000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200a8a:	2a051b63          	bnez	a0,ffffffffc0200d40 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a8e:	4585                	li	a1,1
ffffffffc0200a90:	854e                	mv	a0,s3
ffffffffc0200a92:	07d000ef          	jal	ra,ffffffffc020130e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a96:	00893783          	ld	a5,8(s2)
ffffffffc0200a9a:	1f278363          	beq	a5,s2,ffffffffc0200c80 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200a9e:	4505                	li	a0,1
ffffffffc0200aa0:	02b000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200aa4:	54a99e63          	bne	s3,a0,ffffffffc0201000 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200aa8:	4505                	li	a0,1
ffffffffc0200aaa:	021000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200aae:	52051963          	bnez	a0,ffffffffc0200fe0 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200ab2:	01092783          	lw	a5,16(s2)
ffffffffc0200ab6:	50079563          	bnez	a5,ffffffffc0200fc0 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200aba:	854e                	mv	a0,s3
ffffffffc0200abc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200abe:	00006797          	auipc	a5,0x6
ffffffffc0200ac2:	9787bd23          	sd	s8,-1670(a5) # ffffffffc0206438 <free_area>
ffffffffc0200ac6:	00006797          	auipc	a5,0x6
ffffffffc0200aca:	9777bd23          	sd	s7,-1670(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ace:	00006797          	auipc	a5,0x6
ffffffffc0200ad2:	9767ad23          	sw	s6,-1670(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200ad6:	039000ef          	jal	ra,ffffffffc020130e <free_pages>
    free_page(p1);
ffffffffc0200ada:	4585                	li	a1,1
ffffffffc0200adc:	8556                	mv	a0,s5
ffffffffc0200ade:	031000ef          	jal	ra,ffffffffc020130e <free_pages>
    free_page(p2);
ffffffffc0200ae2:	4585                	li	a1,1
ffffffffc0200ae4:	8552                	mv	a0,s4
ffffffffc0200ae6:	029000ef          	jal	ra,ffffffffc020130e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aea:	4515                	li	a0,5
ffffffffc0200aec:	7de000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200af0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200af2:	4a050763          	beqz	a0,ffffffffc0200fa0 <best_fit_check+0x690>
ffffffffc0200af6:	651c                	ld	a5,8(a0)
ffffffffc0200af8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200afa:	8b85                	andi	a5,a5,1
ffffffffc0200afc:	48079263          	bnez	a5,ffffffffc0200f80 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b00:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b02:	00093b03          	ld	s6,0(s2)
ffffffffc0200b06:	00893a83          	ld	s5,8(s2)
ffffffffc0200b0a:	00006797          	auipc	a5,0x6
ffffffffc0200b0e:	9327b723          	sd	s2,-1746(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b12:	00006797          	auipc	a5,0x6
ffffffffc0200b16:	9327b723          	sd	s2,-1746(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b1a:	7b0000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b1e:	44051163          	bnez	a0,ffffffffc0200f60 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b22:	4589                	li	a1,2
ffffffffc0200b24:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b28:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b2c:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b30:	00006797          	auipc	a5,0x6
ffffffffc0200b34:	9007ac23          	sw	zero,-1768(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b38:	7d6000ef          	jal	ra,ffffffffc020130e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b3c:	8562                	mv	a0,s8
ffffffffc0200b3e:	4585                	li	a1,1
ffffffffc0200b40:	7ce000ef          	jal	ra,ffffffffc020130e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b44:	4511                	li	a0,4
ffffffffc0200b46:	784000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b4a:	3e051b63          	bnez	a0,ffffffffc0200f40 <best_fit_check+0x630>
ffffffffc0200b4e:	0309b783          	ld	a5,48(s3)
ffffffffc0200b52:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b54:	8b85                	andi	a5,a5,1
ffffffffc0200b56:	3c078563          	beqz	a5,ffffffffc0200f20 <best_fit_check+0x610>
ffffffffc0200b5a:	0389a703          	lw	a4,56(s3)
ffffffffc0200b5e:	4789                	li	a5,2
ffffffffc0200b60:	3cf71063          	bne	a4,a5,ffffffffc0200f20 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b64:	4505                	li	a0,1
ffffffffc0200b66:	764000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b6a:	8a2a                	mv	s4,a0
ffffffffc0200b6c:	38050a63          	beqz	a0,ffffffffc0200f00 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b70:	4509                	li	a0,2
ffffffffc0200b72:	758000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b76:	36050563          	beqz	a0,ffffffffc0200ee0 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b7a:	354c1363          	bne	s8,s4,ffffffffc0200ec0 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b7e:	854e                	mv	a0,s3
ffffffffc0200b80:	4595                	li	a1,5
ffffffffc0200b82:	78c000ef          	jal	ra,ffffffffc020130e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b86:	4515                	li	a0,5
ffffffffc0200b88:	742000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b8c:	89aa                	mv	s3,a0
ffffffffc0200b8e:	30050963          	beqz	a0,ffffffffc0200ea0 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b92:	4505                	li	a0,1
ffffffffc0200b94:	736000ef          	jal	ra,ffffffffc02012ca <alloc_pages>
ffffffffc0200b98:	2e051463          	bnez	a0,ffffffffc0200e80 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b9c:	01092783          	lw	a5,16(s2)
ffffffffc0200ba0:	2c079063          	bnez	a5,ffffffffc0200e60 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ba4:	4595                	li	a1,5
ffffffffc0200ba6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ba8:	00006797          	auipc	a5,0x6
ffffffffc0200bac:	8b77a023          	sw	s7,-1888(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bb0:	00006797          	auipc	a5,0x6
ffffffffc0200bb4:	8967b423          	sd	s6,-1912(a5) # ffffffffc0206438 <free_area>
ffffffffc0200bb8:	00006797          	auipc	a5,0x6
ffffffffc0200bbc:	8957b423          	sd	s5,-1912(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bc0:	74e000ef          	jal	ra,ffffffffc020130e <free_pages>
    return listelm->next;
ffffffffc0200bc4:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bc8:	01278963          	beq	a5,s2,ffffffffc0200bda <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bcc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd0:	679c                	ld	a5,8(a5)
ffffffffc0200bd2:	34fd                	addiw	s1,s1,-1
ffffffffc0200bd4:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd6:	ff279be3          	bne	a5,s2,ffffffffc0200bcc <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200bda:	26049363          	bnez	s1,ffffffffc0200e40 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200bde:	e06d                	bnez	s0,ffffffffc0200cc0 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200be0:	60a6                	ld	ra,72(sp)
ffffffffc0200be2:	6406                	ld	s0,64(sp)
ffffffffc0200be4:	74e2                	ld	s1,56(sp)
ffffffffc0200be6:	7942                	ld	s2,48(sp)
ffffffffc0200be8:	79a2                	ld	s3,40(sp)
ffffffffc0200bea:	7a02                	ld	s4,32(sp)
ffffffffc0200bec:	6ae2                	ld	s5,24(sp)
ffffffffc0200bee:	6b42                	ld	s6,16(sp)
ffffffffc0200bf0:	6ba2                	ld	s7,8(sp)
ffffffffc0200bf2:	6c02                	ld	s8,0(sp)
ffffffffc0200bf4:	6161                	addi	sp,sp,80
ffffffffc0200bf6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bf8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bfa:	4401                	li	s0,0
ffffffffc0200bfc:	4481                	li	s1,0
ffffffffc0200bfe:	b395                	j	ffffffffc0200962 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c00:	00001697          	auipc	a3,0x1
ffffffffc0200c04:	66068693          	addi	a3,a3,1632 # ffffffffc0202260 <commands+0x670>
ffffffffc0200c08:	00001617          	auipc	a2,0x1
ffffffffc0200c0c:	62060613          	addi	a2,a2,1568 # ffffffffc0202228 <commands+0x638>
ffffffffc0200c10:	0da00593          	li	a1,218
ffffffffc0200c14:	00001517          	auipc	a0,0x1
ffffffffc0200c18:	62c50513          	addi	a0,a0,1580 # ffffffffc0202240 <commands+0x650>
ffffffffc0200c1c:	eceff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c20:	00001697          	auipc	a3,0x1
ffffffffc0200c24:	6d068693          	addi	a3,a3,1744 # ffffffffc02022f0 <commands+0x700>
ffffffffc0200c28:	00001617          	auipc	a2,0x1
ffffffffc0200c2c:	60060613          	addi	a2,a2,1536 # ffffffffc0202228 <commands+0x638>
ffffffffc0200c30:	0a600593          	li	a1,166
ffffffffc0200c34:	00001517          	auipc	a0,0x1
ffffffffc0200c38:	60c50513          	addi	a0,a0,1548 # ffffffffc0202240 <commands+0x650>
ffffffffc0200c3c:	eaeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c40:	00001697          	auipc	a3,0x1
ffffffffc0200c44:	6d868693          	addi	a3,a3,1752 # ffffffffc0202318 <commands+0x728>
ffffffffc0200c48:	00001617          	auipc	a2,0x1
ffffffffc0200c4c:	5e060613          	addi	a2,a2,1504 # ffffffffc0202228 <commands+0x638>
ffffffffc0200c50:	0a700593          	li	a1,167
ffffffffc0200c54:	00001517          	auipc	a0,0x1
ffffffffc0200c58:	5ec50513          	addi	a0,a0,1516 # ffffffffc0202240 <commands+0x650>
ffffffffc0200c5c:	e8eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c60:	00001697          	auipc	a3,0x1
ffffffffc0200c64:	6f868693          	addi	a3,a3,1784 # ffffffffc0202358 <commands+0x768>
ffffffffc0200c68:	00001617          	auipc	a2,0x1
ffffffffc0200c6c:	5c060613          	addi	a2,a2,1472 # ffffffffc0202228 <commands+0x638>
ffffffffc0200c70:	0a900593          	li	a1,169
ffffffffc0200c74:	00001517          	auipc	a0,0x1
ffffffffc0200c78:	5cc50513          	addi	a0,a0,1484 # ffffffffc0202240 <commands+0x650>
ffffffffc0200c7c:	e6eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c80:	00001697          	auipc	a3,0x1
ffffffffc0200c84:	76068693          	addi	a3,a3,1888 # ffffffffc02023e0 <commands+0x7f0>
ffffffffc0200c88:	00001617          	auipc	a2,0x1
ffffffffc0200c8c:	5a060613          	addi	a2,a2,1440 # ffffffffc0202228 <commands+0x638>
ffffffffc0200c90:	0c200593          	li	a1,194
ffffffffc0200c94:	00001517          	auipc	a0,0x1
ffffffffc0200c98:	5ac50513          	addi	a0,a0,1452 # ffffffffc0202240 <commands+0x650>
ffffffffc0200c9c:	e4eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca0:	00001697          	auipc	a3,0x1
ffffffffc0200ca4:	63068693          	addi	a3,a3,1584 # ffffffffc02022d0 <commands+0x6e0>
ffffffffc0200ca8:	00001617          	auipc	a2,0x1
ffffffffc0200cac:	58060613          	addi	a2,a2,1408 # ffffffffc0202228 <commands+0x638>
ffffffffc0200cb0:	0a400593          	li	a1,164
ffffffffc0200cb4:	00001517          	auipc	a0,0x1
ffffffffc0200cb8:	58c50513          	addi	a0,a0,1420 # ffffffffc0202240 <commands+0x650>
ffffffffc0200cbc:	e2eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == 0);
ffffffffc0200cc0:	00002697          	auipc	a3,0x2
ffffffffc0200cc4:	85068693          	addi	a3,a3,-1968 # ffffffffc0202510 <commands+0x920>
ffffffffc0200cc8:	00001617          	auipc	a2,0x1
ffffffffc0200ccc:	56060613          	addi	a2,a2,1376 # ffffffffc0202228 <commands+0x638>
ffffffffc0200cd0:	11c00593          	li	a1,284
ffffffffc0200cd4:	00001517          	auipc	a0,0x1
ffffffffc0200cd8:	56c50513          	addi	a0,a0,1388 # ffffffffc0202240 <commands+0x650>
ffffffffc0200cdc:	e0eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ce0:	00001697          	auipc	a3,0x1
ffffffffc0200ce4:	59068693          	addi	a3,a3,1424 # ffffffffc0202270 <commands+0x680>
ffffffffc0200ce8:	00001617          	auipc	a2,0x1
ffffffffc0200cec:	54060613          	addi	a2,a2,1344 # ffffffffc0202228 <commands+0x638>
ffffffffc0200cf0:	0dd00593          	li	a1,221
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	54c50513          	addi	a0,a0,1356 # ffffffffc0202240 <commands+0x650>
ffffffffc0200cfc:	deeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d00:	00001697          	auipc	a3,0x1
ffffffffc0200d04:	5b068693          	addi	a3,a3,1456 # ffffffffc02022b0 <commands+0x6c0>
ffffffffc0200d08:	00001617          	auipc	a2,0x1
ffffffffc0200d0c:	52060613          	addi	a2,a2,1312 # ffffffffc0202228 <commands+0x638>
ffffffffc0200d10:	0a300593          	li	a1,163
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	52c50513          	addi	a0,a0,1324 # ffffffffc0202240 <commands+0x650>
ffffffffc0200d1c:	dceff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d20:	00001697          	auipc	a3,0x1
ffffffffc0200d24:	57068693          	addi	a3,a3,1392 # ffffffffc0202290 <commands+0x6a0>
ffffffffc0200d28:	00001617          	auipc	a2,0x1
ffffffffc0200d2c:	50060613          	addi	a2,a2,1280 # ffffffffc0202228 <commands+0x638>
ffffffffc0200d30:	0a200593          	li	a1,162
ffffffffc0200d34:	00001517          	auipc	a0,0x1
ffffffffc0200d38:	50c50513          	addi	a0,a0,1292 # ffffffffc0202240 <commands+0x650>
ffffffffc0200d3c:	daeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d40:	00001697          	auipc	a3,0x1
ffffffffc0200d44:	67868693          	addi	a3,a3,1656 # ffffffffc02023b8 <commands+0x7c8>
ffffffffc0200d48:	00001617          	auipc	a2,0x1
ffffffffc0200d4c:	4e060613          	addi	a2,a2,1248 # ffffffffc0202228 <commands+0x638>
ffffffffc0200d50:	0bf00593          	li	a1,191
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	4ec50513          	addi	a0,a0,1260 # ffffffffc0202240 <commands+0x650>
ffffffffc0200d5c:	d8eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d60:	00001697          	auipc	a3,0x1
ffffffffc0200d64:	57068693          	addi	a3,a3,1392 # ffffffffc02022d0 <commands+0x6e0>
ffffffffc0200d68:	00001617          	auipc	a2,0x1
ffffffffc0200d6c:	4c060613          	addi	a2,a2,1216 # ffffffffc0202228 <commands+0x638>
ffffffffc0200d70:	0bd00593          	li	a1,189
ffffffffc0200d74:	00001517          	auipc	a0,0x1
ffffffffc0200d78:	4cc50513          	addi	a0,a0,1228 # ffffffffc0202240 <commands+0x650>
ffffffffc0200d7c:	d6eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d80:	00001697          	auipc	a3,0x1
ffffffffc0200d84:	53068693          	addi	a3,a3,1328 # ffffffffc02022b0 <commands+0x6c0>
ffffffffc0200d88:	00001617          	auipc	a2,0x1
ffffffffc0200d8c:	4a060613          	addi	a2,a2,1184 # ffffffffc0202228 <commands+0x638>
ffffffffc0200d90:	0bc00593          	li	a1,188
ffffffffc0200d94:	00001517          	auipc	a0,0x1
ffffffffc0200d98:	4ac50513          	addi	a0,a0,1196 # ffffffffc0202240 <commands+0x650>
ffffffffc0200d9c:	d4eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200da0:	00001697          	auipc	a3,0x1
ffffffffc0200da4:	4f068693          	addi	a3,a3,1264 # ffffffffc0202290 <commands+0x6a0>
ffffffffc0200da8:	00001617          	auipc	a2,0x1
ffffffffc0200dac:	48060613          	addi	a2,a2,1152 # ffffffffc0202228 <commands+0x638>
ffffffffc0200db0:	0bb00593          	li	a1,187
ffffffffc0200db4:	00001517          	auipc	a0,0x1
ffffffffc0200db8:	48c50513          	addi	a0,a0,1164 # ffffffffc0202240 <commands+0x650>
ffffffffc0200dbc:	d2eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 3);
ffffffffc0200dc0:	00001697          	auipc	a3,0x1
ffffffffc0200dc4:	61068693          	addi	a3,a3,1552 # ffffffffc02023d0 <commands+0x7e0>
ffffffffc0200dc8:	00001617          	auipc	a2,0x1
ffffffffc0200dcc:	46060613          	addi	a2,a2,1120 # ffffffffc0202228 <commands+0x638>
ffffffffc0200dd0:	0b900593          	li	a1,185
ffffffffc0200dd4:	00001517          	auipc	a0,0x1
ffffffffc0200dd8:	46c50513          	addi	a0,a0,1132 # ffffffffc0202240 <commands+0x650>
ffffffffc0200ddc:	d0eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200de0:	00001697          	auipc	a3,0x1
ffffffffc0200de4:	5d868693          	addi	a3,a3,1496 # ffffffffc02023b8 <commands+0x7c8>
ffffffffc0200de8:	00001617          	auipc	a2,0x1
ffffffffc0200dec:	44060613          	addi	a2,a2,1088 # ffffffffc0202228 <commands+0x638>
ffffffffc0200df0:	0b400593          	li	a1,180
ffffffffc0200df4:	00001517          	auipc	a0,0x1
ffffffffc0200df8:	44c50513          	addi	a0,a0,1100 # ffffffffc0202240 <commands+0x650>
ffffffffc0200dfc:	ceeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e00:	00001697          	auipc	a3,0x1
ffffffffc0200e04:	59868693          	addi	a3,a3,1432 # ffffffffc0202398 <commands+0x7a8>
ffffffffc0200e08:	00001617          	auipc	a2,0x1
ffffffffc0200e0c:	42060613          	addi	a2,a2,1056 # ffffffffc0202228 <commands+0x638>
ffffffffc0200e10:	0ab00593          	li	a1,171
ffffffffc0200e14:	00001517          	auipc	a0,0x1
ffffffffc0200e18:	42c50513          	addi	a0,a0,1068 # ffffffffc0202240 <commands+0x650>
ffffffffc0200e1c:	cceff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e20:	00001697          	auipc	a3,0x1
ffffffffc0200e24:	55868693          	addi	a3,a3,1368 # ffffffffc0202378 <commands+0x788>
ffffffffc0200e28:	00001617          	auipc	a2,0x1
ffffffffc0200e2c:	40060613          	addi	a2,a2,1024 # ffffffffc0202228 <commands+0x638>
ffffffffc0200e30:	0aa00593          	li	a1,170
ffffffffc0200e34:	00001517          	auipc	a0,0x1
ffffffffc0200e38:	40c50513          	addi	a0,a0,1036 # ffffffffc0202240 <commands+0x650>
ffffffffc0200e3c:	caeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(count == 0);
ffffffffc0200e40:	00001697          	auipc	a3,0x1
ffffffffc0200e44:	6c068693          	addi	a3,a3,1728 # ffffffffc0202500 <commands+0x910>
ffffffffc0200e48:	00001617          	auipc	a2,0x1
ffffffffc0200e4c:	3e060613          	addi	a2,a2,992 # ffffffffc0202228 <commands+0x638>
ffffffffc0200e50:	11b00593          	li	a1,283
ffffffffc0200e54:	00001517          	auipc	a0,0x1
ffffffffc0200e58:	3ec50513          	addi	a0,a0,1004 # ffffffffc0202240 <commands+0x650>
ffffffffc0200e5c:	c8eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200e60:	00001697          	auipc	a3,0x1
ffffffffc0200e64:	5b868693          	addi	a3,a3,1464 # ffffffffc0202418 <commands+0x828>
ffffffffc0200e68:	00001617          	auipc	a2,0x1
ffffffffc0200e6c:	3c060613          	addi	a2,a2,960 # ffffffffc0202228 <commands+0x638>
ffffffffc0200e70:	11000593          	li	a1,272
ffffffffc0200e74:	00001517          	auipc	a0,0x1
ffffffffc0200e78:	3cc50513          	addi	a0,a0,972 # ffffffffc0202240 <commands+0x650>
ffffffffc0200e7c:	c6eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e80:	00001697          	auipc	a3,0x1
ffffffffc0200e84:	53868693          	addi	a3,a3,1336 # ffffffffc02023b8 <commands+0x7c8>
ffffffffc0200e88:	00001617          	auipc	a2,0x1
ffffffffc0200e8c:	3a060613          	addi	a2,a2,928 # ffffffffc0202228 <commands+0x638>
ffffffffc0200e90:	10a00593          	li	a1,266
ffffffffc0200e94:	00001517          	auipc	a0,0x1
ffffffffc0200e98:	3ac50513          	addi	a0,a0,940 # ffffffffc0202240 <commands+0x650>
ffffffffc0200e9c:	c4eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ea0:	00001697          	auipc	a3,0x1
ffffffffc0200ea4:	64068693          	addi	a3,a3,1600 # ffffffffc02024e0 <commands+0x8f0>
ffffffffc0200ea8:	00001617          	auipc	a2,0x1
ffffffffc0200eac:	38060613          	addi	a2,a2,896 # ffffffffc0202228 <commands+0x638>
ffffffffc0200eb0:	10900593          	li	a1,265
ffffffffc0200eb4:	00001517          	auipc	a0,0x1
ffffffffc0200eb8:	38c50513          	addi	a0,a0,908 # ffffffffc0202240 <commands+0x650>
ffffffffc0200ebc:	c2eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ec0:	00001697          	auipc	a3,0x1
ffffffffc0200ec4:	61068693          	addi	a3,a3,1552 # ffffffffc02024d0 <commands+0x8e0>
ffffffffc0200ec8:	00001617          	auipc	a2,0x1
ffffffffc0200ecc:	36060613          	addi	a2,a2,864 # ffffffffc0202228 <commands+0x638>
ffffffffc0200ed0:	10100593          	li	a1,257
ffffffffc0200ed4:	00001517          	auipc	a0,0x1
ffffffffc0200ed8:	36c50513          	addi	a0,a0,876 # ffffffffc0202240 <commands+0x650>
ffffffffc0200edc:	c0eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ee0:	00001697          	auipc	a3,0x1
ffffffffc0200ee4:	5d868693          	addi	a3,a3,1496 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc0200ee8:	00001617          	auipc	a2,0x1
ffffffffc0200eec:	34060613          	addi	a2,a2,832 # ffffffffc0202228 <commands+0x638>
ffffffffc0200ef0:	10000593          	li	a1,256
ffffffffc0200ef4:	00001517          	auipc	a0,0x1
ffffffffc0200ef8:	34c50513          	addi	a0,a0,844 # ffffffffc0202240 <commands+0x650>
ffffffffc0200efc:	beeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f00:	00001697          	auipc	a3,0x1
ffffffffc0200f04:	59868693          	addi	a3,a3,1432 # ffffffffc0202498 <commands+0x8a8>
ffffffffc0200f08:	00001617          	auipc	a2,0x1
ffffffffc0200f0c:	32060613          	addi	a2,a2,800 # ffffffffc0202228 <commands+0x638>
ffffffffc0200f10:	0ff00593          	li	a1,255
ffffffffc0200f14:	00001517          	auipc	a0,0x1
ffffffffc0200f18:	32c50513          	addi	a0,a0,812 # ffffffffc0202240 <commands+0x650>
ffffffffc0200f1c:	bceff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f20:	00001697          	auipc	a3,0x1
ffffffffc0200f24:	54868693          	addi	a3,a3,1352 # ffffffffc0202468 <commands+0x878>
ffffffffc0200f28:	00001617          	auipc	a2,0x1
ffffffffc0200f2c:	30060613          	addi	a2,a2,768 # ffffffffc0202228 <commands+0x638>
ffffffffc0200f30:	0fd00593          	li	a1,253
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	30c50513          	addi	a0,a0,780 # ffffffffc0202240 <commands+0x650>
ffffffffc0200f3c:	baeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f40:	00001697          	auipc	a3,0x1
ffffffffc0200f44:	51068693          	addi	a3,a3,1296 # ffffffffc0202450 <commands+0x860>
ffffffffc0200f48:	00001617          	auipc	a2,0x1
ffffffffc0200f4c:	2e060613          	addi	a2,a2,736 # ffffffffc0202228 <commands+0x638>
ffffffffc0200f50:	0fc00593          	li	a1,252
ffffffffc0200f54:	00001517          	auipc	a0,0x1
ffffffffc0200f58:	2ec50513          	addi	a0,a0,748 # ffffffffc0202240 <commands+0x650>
ffffffffc0200f5c:	b8eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f60:	00001697          	auipc	a3,0x1
ffffffffc0200f64:	45868693          	addi	a3,a3,1112 # ffffffffc02023b8 <commands+0x7c8>
ffffffffc0200f68:	00001617          	auipc	a2,0x1
ffffffffc0200f6c:	2c060613          	addi	a2,a2,704 # ffffffffc0202228 <commands+0x638>
ffffffffc0200f70:	0f000593          	li	a1,240
ffffffffc0200f74:	00001517          	auipc	a0,0x1
ffffffffc0200f78:	2cc50513          	addi	a0,a0,716 # ffffffffc0202240 <commands+0x650>
ffffffffc0200f7c:	b6eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f80:	00001697          	auipc	a3,0x1
ffffffffc0200f84:	4b868693          	addi	a3,a3,1208 # ffffffffc0202438 <commands+0x848>
ffffffffc0200f88:	00001617          	auipc	a2,0x1
ffffffffc0200f8c:	2a060613          	addi	a2,a2,672 # ffffffffc0202228 <commands+0x638>
ffffffffc0200f90:	0e700593          	li	a1,231
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	2ac50513          	addi	a0,a0,684 # ffffffffc0202240 <commands+0x650>
ffffffffc0200f9c:	b4eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(p0 != NULL);
ffffffffc0200fa0:	00001697          	auipc	a3,0x1
ffffffffc0200fa4:	48868693          	addi	a3,a3,1160 # ffffffffc0202428 <commands+0x838>
ffffffffc0200fa8:	00001617          	auipc	a2,0x1
ffffffffc0200fac:	28060613          	addi	a2,a2,640 # ffffffffc0202228 <commands+0x638>
ffffffffc0200fb0:	0e600593          	li	a1,230
ffffffffc0200fb4:	00001517          	auipc	a0,0x1
ffffffffc0200fb8:	28c50513          	addi	a0,a0,652 # ffffffffc0202240 <commands+0x650>
ffffffffc0200fbc:	b2eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(nr_free == 0);
ffffffffc0200fc0:	00001697          	auipc	a3,0x1
ffffffffc0200fc4:	45868693          	addi	a3,a3,1112 # ffffffffc0202418 <commands+0x828>
ffffffffc0200fc8:	00001617          	auipc	a2,0x1
ffffffffc0200fcc:	26060613          	addi	a2,a2,608 # ffffffffc0202228 <commands+0x638>
ffffffffc0200fd0:	0c800593          	li	a1,200
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	26c50513          	addi	a0,a0,620 # ffffffffc0202240 <commands+0x650>
ffffffffc0200fdc:	b0eff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe0:	00001697          	auipc	a3,0x1
ffffffffc0200fe4:	3d868693          	addi	a3,a3,984 # ffffffffc02023b8 <commands+0x7c8>
ffffffffc0200fe8:	00001617          	auipc	a2,0x1
ffffffffc0200fec:	24060613          	addi	a2,a2,576 # ffffffffc0202228 <commands+0x638>
ffffffffc0200ff0:	0c600593          	li	a1,198
ffffffffc0200ff4:	00001517          	auipc	a0,0x1
ffffffffc0200ff8:	24c50513          	addi	a0,a0,588 # ffffffffc0202240 <commands+0x650>
ffffffffc0200ffc:	aeeff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201000:	00001697          	auipc	a3,0x1
ffffffffc0201004:	3f868693          	addi	a3,a3,1016 # ffffffffc02023f8 <commands+0x808>
ffffffffc0201008:	00001617          	auipc	a2,0x1
ffffffffc020100c:	22060613          	addi	a2,a2,544 # ffffffffc0202228 <commands+0x638>
ffffffffc0201010:	0c500593          	li	a1,197
ffffffffc0201014:	00001517          	auipc	a0,0x1
ffffffffc0201018:	22c50513          	addi	a0,a0,556 # ffffffffc0202240 <commands+0x650>
ffffffffc020101c:	aceff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201020 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201020:	1141                	addi	sp,sp,-16
ffffffffc0201022:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201024:	18058063          	beqz	a1,ffffffffc02011a4 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201028:	00259693          	slli	a3,a1,0x2
ffffffffc020102c:	96ae                	add	a3,a3,a1
ffffffffc020102e:	068e                	slli	a3,a3,0x3
ffffffffc0201030:	96aa                	add	a3,a3,a0
ffffffffc0201032:	02d50d63          	beq	a0,a3,ffffffffc020106c <best_fit_free_pages+0x4c>
ffffffffc0201036:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201038:	8b85                	andi	a5,a5,1
ffffffffc020103a:	14079563          	bnez	a5,ffffffffc0201184 <best_fit_free_pages+0x164>
ffffffffc020103e:	651c                	ld	a5,8(a0)
ffffffffc0201040:	8385                	srli	a5,a5,0x1
ffffffffc0201042:	8b85                	andi	a5,a5,1
ffffffffc0201044:	14079063          	bnez	a5,ffffffffc0201184 <best_fit_free_pages+0x164>
ffffffffc0201048:	87aa                	mv	a5,a0
ffffffffc020104a:	a809                	j	ffffffffc020105c <best_fit_free_pages+0x3c>
ffffffffc020104c:	6798                	ld	a4,8(a5)
ffffffffc020104e:	8b05                	andi	a4,a4,1
ffffffffc0201050:	12071a63          	bnez	a4,ffffffffc0201184 <best_fit_free_pages+0x164>
ffffffffc0201054:	6798                	ld	a4,8(a5)
ffffffffc0201056:	8b09                	andi	a4,a4,2
ffffffffc0201058:	12071663          	bnez	a4,ffffffffc0201184 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc020105c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201060:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201064:	02878793          	addi	a5,a5,40
ffffffffc0201068:	fed792e3          	bne	a5,a3,ffffffffc020104c <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc020106c:	2581                	sext.w	a1,a1
ffffffffc020106e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201070:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201074:	4789                	li	a5,2
ffffffffc0201076:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020107a:	00005697          	auipc	a3,0x5
ffffffffc020107e:	3be68693          	addi	a3,a3,958 # ffffffffc0206438 <free_area>
ffffffffc0201082:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201084:	669c                	ld	a5,8(a3)
ffffffffc0201086:	9db9                	addw	a1,a1,a4
ffffffffc0201088:	00005717          	auipc	a4,0x5
ffffffffc020108c:	3cb72023          	sw	a1,960(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201090:	08d78f63          	beq	a5,a3,ffffffffc020112e <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201094:	fe878713          	addi	a4,a5,-24
ffffffffc0201098:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020109a:	4801                	li	a6,0
ffffffffc020109c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010a0:	00e56a63          	bltu	a0,a4,ffffffffc02010b4 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02010a4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010a6:	02d70563          	beq	a4,a3,ffffffffc02010d0 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010aa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010ac:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b0:	fee57ae3          	bleu	a4,a0,ffffffffc02010a4 <best_fit_free_pages+0x84>
ffffffffc02010b4:	00080663          	beqz	a6,ffffffffc02010c0 <best_fit_free_pages+0xa0>
ffffffffc02010b8:	00005817          	auipc	a6,0x5
ffffffffc02010bc:	38b83023          	sd	a1,896(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c0:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010c2:	e390                	sd	a2,0(a5)
ffffffffc02010c4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010c8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010ca:	02d59163          	bne	a1,a3,ffffffffc02010ec <best_fit_free_pages+0xcc>
ffffffffc02010ce:	a091                	j	ffffffffc0201112 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010d0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010d2:	f114                	sd	a3,32(a0)
ffffffffc02010d4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010d6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010d8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010da:	00d70563          	beq	a4,a3,ffffffffc02010e4 <best_fit_free_pages+0xc4>
ffffffffc02010de:	4805                	li	a6,1
ffffffffc02010e0:	87ba                	mv	a5,a4
ffffffffc02010e2:	b7e9                	j	ffffffffc02010ac <best_fit_free_pages+0x8c>
ffffffffc02010e4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010e6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010e8:	02d78163          	beq	a5,a3,ffffffffc020110a <best_fit_free_pages+0xea>
        if (p + p->property == base){
ffffffffc02010ec:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010f0:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base){
ffffffffc02010f4:	02081713          	slli	a4,a6,0x20
ffffffffc02010f8:	9301                	srli	a4,a4,0x20
ffffffffc02010fa:	00271793          	slli	a5,a4,0x2
ffffffffc02010fe:	97ba                	add	a5,a5,a4
ffffffffc0201100:	078e                	slli	a5,a5,0x3
ffffffffc0201102:	97b2                	add	a5,a5,a2
ffffffffc0201104:	02f50e63          	beq	a0,a5,ffffffffc0201140 <best_fit_free_pages+0x120>
ffffffffc0201108:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020110a:	fe878713          	addi	a4,a5,-24
ffffffffc020110e:	00d78d63          	beq	a5,a3,ffffffffc0201128 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201112:	490c                	lw	a1,16(a0)
ffffffffc0201114:	02059613          	slli	a2,a1,0x20
ffffffffc0201118:	9201                	srli	a2,a2,0x20
ffffffffc020111a:	00261693          	slli	a3,a2,0x2
ffffffffc020111e:	96b2                	add	a3,a3,a2
ffffffffc0201120:	068e                	slli	a3,a3,0x3
ffffffffc0201122:	96aa                	add	a3,a3,a0
ffffffffc0201124:	04d70063          	beq	a4,a3,ffffffffc0201164 <best_fit_free_pages+0x144>
}
ffffffffc0201128:	60a2                	ld	ra,8(sp)
ffffffffc020112a:	0141                	addi	sp,sp,16
ffffffffc020112c:	8082                	ret
ffffffffc020112e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201130:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201134:	e398                	sd	a4,0(a5)
ffffffffc0201136:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201138:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020113a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020113c:	0141                	addi	sp,sp,16
ffffffffc020113e:	8082                	ret
            p->property += base->property;
ffffffffc0201140:	491c                	lw	a5,16(a0)
ffffffffc0201142:	0107883b          	addw	a6,a5,a6
ffffffffc0201146:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020114a:	57f5                	li	a5,-3
ffffffffc020114c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201150:	01853803          	ld	a6,24(a0)
ffffffffc0201154:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc0201156:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201158:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020115c:	659c                	ld	a5,8(a1)
ffffffffc020115e:	01073023          	sd	a6,0(a4)
ffffffffc0201162:	b765                	j	ffffffffc020110a <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201164:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201168:	ff078693          	addi	a3,a5,-16
ffffffffc020116c:	9db9                	addw	a1,a1,a4
ffffffffc020116e:	c90c                	sw	a1,16(a0)
ffffffffc0201170:	5775                	li	a4,-3
ffffffffc0201172:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201176:	6398                	ld	a4,0(a5)
ffffffffc0201178:	679c                	ld	a5,8(a5)
}
ffffffffc020117a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020117c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020117e:	e398                	sd	a4,0(a5)
ffffffffc0201180:	0141                	addi	sp,sp,16
ffffffffc0201182:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201184:	00001697          	auipc	a3,0x1
ffffffffc0201188:	39c68693          	addi	a3,a3,924 # ffffffffc0202520 <commands+0x930>
ffffffffc020118c:	00001617          	auipc	a2,0x1
ffffffffc0201190:	09c60613          	addi	a2,a2,156 # ffffffffc0202228 <commands+0x638>
ffffffffc0201194:	06200593          	li	a1,98
ffffffffc0201198:	00001517          	auipc	a0,0x1
ffffffffc020119c:	0a850513          	addi	a0,a0,168 # ffffffffc0202240 <commands+0x650>
ffffffffc02011a0:	94aff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02011a4:	00001697          	auipc	a3,0x1
ffffffffc02011a8:	07c68693          	addi	a3,a3,124 # ffffffffc0202220 <commands+0x630>
ffffffffc02011ac:	00001617          	auipc	a2,0x1
ffffffffc02011b0:	07c60613          	addi	a2,a2,124 # ffffffffc0202228 <commands+0x638>
ffffffffc02011b4:	05f00593          	li	a1,95
ffffffffc02011b8:	00001517          	auipc	a0,0x1
ffffffffc02011bc:	08850513          	addi	a0,a0,136 # ffffffffc0202240 <commands+0x650>
ffffffffc02011c0:	92aff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02011c4 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011c4:	1141                	addi	sp,sp,-16
ffffffffc02011c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011c8:	c1f5                	beqz	a1,ffffffffc02012ac <best_fit_init_memmap+0xe8>
    for (; p != base + n; p ++) {
ffffffffc02011ca:	00259693          	slli	a3,a1,0x2
ffffffffc02011ce:	96ae                	add	a3,a3,a1
ffffffffc02011d0:	068e                	slli	a3,a3,0x3
ffffffffc02011d2:	96aa                	add	a3,a3,a0
ffffffffc02011d4:	02d50463          	beq	a0,a3,ffffffffc02011fc <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011d8:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011da:	87aa                	mv	a5,a0
ffffffffc02011dc:	8b05                	andi	a4,a4,1
ffffffffc02011de:	e709                	bnez	a4,ffffffffc02011e8 <best_fit_init_memmap+0x24>
ffffffffc02011e0:	a07d                	j	ffffffffc020128e <best_fit_init_memmap+0xca>
ffffffffc02011e2:	6798                	ld	a4,8(a5)
ffffffffc02011e4:	8b05                	andi	a4,a4,1
ffffffffc02011e6:	c745                	beqz	a4,ffffffffc020128e <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02011e8:	0007a823          	sw	zero,16(a5)
ffffffffc02011ec:	0007b423          	sd	zero,8(a5)
ffffffffc02011f0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011f4:	02878793          	addi	a5,a5,40
ffffffffc02011f8:	fed795e3          	bne	a5,a3,ffffffffc02011e2 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc02011fc:	2581                	sext.w	a1,a1
ffffffffc02011fe:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201200:	4789                	li	a5,2
ffffffffc0201202:	00850713          	addi	a4,a0,8
ffffffffc0201206:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020120a:	00005697          	auipc	a3,0x5
ffffffffc020120e:	22e68693          	addi	a3,a3,558 # ffffffffc0206438 <free_area>
ffffffffc0201212:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201214:	669c                	ld	a5,8(a3)
ffffffffc0201216:	9db9                	addw	a1,a1,a4
ffffffffc0201218:	00005717          	auipc	a4,0x5
ffffffffc020121c:	22b72823          	sw	a1,560(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201220:	04d78a63          	beq	a5,a3,ffffffffc0201274 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201224:	fe878713          	addi	a4,a5,-24
ffffffffc0201228:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020122a:	4801                	li	a6,0
ffffffffc020122c:	01850613          	addi	a2,a0,24
            if (base < page){
ffffffffc0201230:	00e56a63          	bltu	a0,a4,ffffffffc0201244 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201234:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list){
ffffffffc0201236:	02d70563          	beq	a4,a3,ffffffffc0201260 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020123a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020123c:	fe878713          	addi	a4,a5,-24
            if (base < page){
ffffffffc0201240:	fee57ae3          	bleu	a4,a0,ffffffffc0201234 <best_fit_init_memmap+0x70>
ffffffffc0201244:	00080663          	beqz	a6,ffffffffc0201250 <best_fit_init_memmap+0x8c>
ffffffffc0201248:	00005717          	auipc	a4,0x5
ffffffffc020124c:	1eb73823          	sd	a1,496(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201250:	6398                	ld	a4,0(a5)
}
ffffffffc0201252:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201254:	e390                	sd	a2,0(a5)
ffffffffc0201256:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201258:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020125a:	ed18                	sd	a4,24(a0)
ffffffffc020125c:	0141                	addi	sp,sp,16
ffffffffc020125e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201260:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201262:	f114                	sd	a3,32(a0)
ffffffffc0201264:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201266:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201268:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020126a:	00d70e63          	beq	a4,a3,ffffffffc0201286 <best_fit_init_memmap+0xc2>
ffffffffc020126e:	4805                	li	a6,1
ffffffffc0201270:	87ba                	mv	a5,a4
ffffffffc0201272:	b7e9                	j	ffffffffc020123c <best_fit_init_memmap+0x78>
}
ffffffffc0201274:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201276:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020127a:	e398                	sd	a4,0(a5)
ffffffffc020127c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020127e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201280:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201282:	0141                	addi	sp,sp,16
ffffffffc0201284:	8082                	ret
ffffffffc0201286:	60a2                	ld	ra,8(sp)
ffffffffc0201288:	e290                	sd	a2,0(a3)
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020128e:	00001697          	auipc	a3,0x1
ffffffffc0201292:	2ba68693          	addi	a3,a3,698 # ffffffffc0202548 <commands+0x958>
ffffffffc0201296:	00001617          	auipc	a2,0x1
ffffffffc020129a:	f9260613          	addi	a2,a2,-110 # ffffffffc0202228 <commands+0x638>
ffffffffc020129e:	45dd                	li	a1,23
ffffffffc02012a0:	00001517          	auipc	a0,0x1
ffffffffc02012a4:	fa050513          	addi	a0,a0,-96 # ffffffffc0202240 <commands+0x650>
ffffffffc02012a8:	842ff0ef          	jal	ra,ffffffffc02002ea <__panic>
    assert(n > 0);
ffffffffc02012ac:	00001697          	auipc	a3,0x1
ffffffffc02012b0:	f7468693          	addi	a3,a3,-140 # ffffffffc0202220 <commands+0x630>
ffffffffc02012b4:	00001617          	auipc	a2,0x1
ffffffffc02012b8:	f7460613          	addi	a2,a2,-140 # ffffffffc0202228 <commands+0x638>
ffffffffc02012bc:	45d1                	li	a1,20
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	f8250513          	addi	a0,a0,-126 # ffffffffc0202240 <commands+0x650>
ffffffffc02012c6:	824ff0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc02012ca <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ca:	100027f3          	csrr	a5,sstatus
ffffffffc02012ce:	8b89                	andi	a5,a5,2
ffffffffc02012d0:	eb89                	bnez	a5,ffffffffc02012e2 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012d2:	00005797          	auipc	a5,0x5
ffffffffc02012d6:	18678793          	addi	a5,a5,390 # ffffffffc0206458 <pmm_manager>
ffffffffc02012da:	639c                	ld	a5,0(a5)
ffffffffc02012dc:	0187b303          	ld	t1,24(a5)
ffffffffc02012e0:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012e2:	1141                	addi	sp,sp,-16
ffffffffc02012e4:	e406                	sd	ra,8(sp)
ffffffffc02012e6:	e022                	sd	s0,0(sp)
ffffffffc02012e8:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012ea:	97aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012ee:	00005797          	auipc	a5,0x5
ffffffffc02012f2:	16a78793          	addi	a5,a5,362 # ffffffffc0206458 <pmm_manager>
ffffffffc02012f6:	639c                	ld	a5,0(a5)
ffffffffc02012f8:	8522                	mv	a0,s0
ffffffffc02012fa:	6f9c                	ld	a5,24(a5)
ffffffffc02012fc:	9782                	jalr	a5
ffffffffc02012fe:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201300:	95eff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	60a2                	ld	ra,8(sp)
ffffffffc0201308:	6402                	ld	s0,0(sp)
ffffffffc020130a:	0141                	addi	sp,sp,16
ffffffffc020130c:	8082                	ret

ffffffffc020130e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020130e:	100027f3          	csrr	a5,sstatus
ffffffffc0201312:	8b89                	andi	a5,a5,2
ffffffffc0201314:	eb89                	bnez	a5,ffffffffc0201326 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201316:	00005797          	auipc	a5,0x5
ffffffffc020131a:	14278793          	addi	a5,a5,322 # ffffffffc0206458 <pmm_manager>
ffffffffc020131e:	639c                	ld	a5,0(a5)
ffffffffc0201320:	0207b303          	ld	t1,32(a5)
ffffffffc0201324:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201326:	1101                	addi	sp,sp,-32
ffffffffc0201328:	ec06                	sd	ra,24(sp)
ffffffffc020132a:	e822                	sd	s0,16(sp)
ffffffffc020132c:	e426                	sd	s1,8(sp)
ffffffffc020132e:	842a                	mv	s0,a0
ffffffffc0201330:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201332:	932ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201336:	00005797          	auipc	a5,0x5
ffffffffc020133a:	12278793          	addi	a5,a5,290 # ffffffffc0206458 <pmm_manager>
ffffffffc020133e:	639c                	ld	a5,0(a5)
ffffffffc0201340:	85a6                	mv	a1,s1
ffffffffc0201342:	8522                	mv	a0,s0
ffffffffc0201344:	739c                	ld	a5,32(a5)
ffffffffc0201346:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201348:	6442                	ld	s0,16(sp)
ffffffffc020134a:	60e2                	ld	ra,24(sp)
ffffffffc020134c:	64a2                	ld	s1,8(sp)
ffffffffc020134e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201350:	90eff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201354 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201354:	100027f3          	csrr	a5,sstatus
ffffffffc0201358:	8b89                	andi	a5,a5,2
ffffffffc020135a:	eb89                	bnez	a5,ffffffffc020136c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020135c:	00005797          	auipc	a5,0x5
ffffffffc0201360:	0fc78793          	addi	a5,a5,252 # ffffffffc0206458 <pmm_manager>
ffffffffc0201364:	639c                	ld	a5,0(a5)
ffffffffc0201366:	0287b303          	ld	t1,40(a5)
ffffffffc020136a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020136c:	1141                	addi	sp,sp,-16
ffffffffc020136e:	e406                	sd	ra,8(sp)
ffffffffc0201370:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201372:	8f2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201376:	00005797          	auipc	a5,0x5
ffffffffc020137a:	0e278793          	addi	a5,a5,226 # ffffffffc0206458 <pmm_manager>
ffffffffc020137e:	639c                	ld	a5,0(a5)
ffffffffc0201380:	779c                	ld	a5,40(a5)
ffffffffc0201382:	9782                	jalr	a5
ffffffffc0201384:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201386:	8d8ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020138a:	8522                	mv	a0,s0
ffffffffc020138c:	60a2                	ld	ra,8(sp)
ffffffffc020138e:	6402                	ld	s0,0(sp)
ffffffffc0201390:	0141                	addi	sp,sp,16
ffffffffc0201392:	8082                	ret

ffffffffc0201394 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201394:	00001797          	auipc	a5,0x1
ffffffffc0201398:	1c478793          	addi	a5,a5,452 # ffffffffc0202558 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020139c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020139e:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013a0:	00001517          	auipc	a0,0x1
ffffffffc02013a4:	20850513          	addi	a0,a0,520 # ffffffffc02025a8 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013a8:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013aa:	00005717          	auipc	a4,0x5
ffffffffc02013ae:	0af73723          	sd	a5,174(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02013b2:	e822                	sd	s0,16(sp)
ffffffffc02013b4:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013b6:	00005417          	auipc	s0,0x5
ffffffffc02013ba:	0a240413          	addi	s0,s0,162 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013be:	fc7fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    pmm_manager->init();
ffffffffc02013c2:	601c                	ld	a5,0(s0)
ffffffffc02013c4:	679c                	ld	a5,8(a5)
ffffffffc02013c6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013c8:	57f5                	li	a5,-3
ffffffffc02013ca:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013cc:	00001517          	auipc	a0,0x1
ffffffffc02013d0:	1f450513          	addi	a0,a0,500 # ffffffffc02025c0 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013d4:	00005717          	auipc	a4,0x5
ffffffffc02013d8:	08f73623          	sd	a5,140(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013dc:	fa9fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013e0:	46c5                	li	a3,17
ffffffffc02013e2:	06ee                	slli	a3,a3,0x1b
ffffffffc02013e4:	40100613          	li	a2,1025
ffffffffc02013e8:	16fd                	addi	a3,a3,-1
ffffffffc02013ea:	0656                	slli	a2,a2,0x15
ffffffffc02013ec:	07e005b7          	lui	a1,0x7e00
ffffffffc02013f0:	00001517          	auipc	a0,0x1
ffffffffc02013f4:	1e850513          	addi	a0,a0,488 # ffffffffc02025d8 <best_fit_pmm_manager+0x80>
ffffffffc02013f8:	f8dfe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013fc:	777d                	lui	a4,0xfffff
ffffffffc02013fe:	00006797          	auipc	a5,0x6
ffffffffc0201402:	07178793          	addi	a5,a5,113 # ffffffffc020746f <end+0xfff>
ffffffffc0201406:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201408:	00088737          	lui	a4,0x88
ffffffffc020140c:	00005697          	auipc	a3,0x5
ffffffffc0201410:	00e6b623          	sd	a4,12(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201414:	4601                	li	a2,0
ffffffffc0201416:	00005717          	auipc	a4,0x5
ffffffffc020141a:	04f73923          	sd	a5,82(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020141e:	4681                	li	a3,0
ffffffffc0201420:	00005897          	auipc	a7,0x5
ffffffffc0201424:	ff888893          	addi	a7,a7,-8 # ffffffffc0206418 <npage>
ffffffffc0201428:	00005597          	auipc	a1,0x5
ffffffffc020142c:	04058593          	addi	a1,a1,64 # ffffffffc0206468 <pages>
ffffffffc0201430:	4805                	li	a6,1
ffffffffc0201432:	fff80537          	lui	a0,0xfff80
ffffffffc0201436:	a011                	j	ffffffffc020143a <pmm_init+0xa6>
ffffffffc0201438:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020143a:	97b2                	add	a5,a5,a2
ffffffffc020143c:	07a1                	addi	a5,a5,8
ffffffffc020143e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201442:	0008b703          	ld	a4,0(a7)
ffffffffc0201446:	0685                	addi	a3,a3,1
ffffffffc0201448:	02860613          	addi	a2,a2,40
ffffffffc020144c:	00a707b3          	add	a5,a4,a0
ffffffffc0201450:	fef6e4e3          	bltu	a3,a5,ffffffffc0201438 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201454:	6190                	ld	a2,0(a1)
ffffffffc0201456:	00271793          	slli	a5,a4,0x2
ffffffffc020145a:	97ba                	add	a5,a5,a4
ffffffffc020145c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201460:	078e                	slli	a5,a5,0x3
ffffffffc0201462:	96b2                	add	a3,a3,a2
ffffffffc0201464:	96be                	add	a3,a3,a5
ffffffffc0201466:	c02007b7          	lui	a5,0xc0200
ffffffffc020146a:	08f6e863          	bltu	a3,a5,ffffffffc02014fa <pmm_init+0x166>
ffffffffc020146e:	00005497          	auipc	s1,0x5
ffffffffc0201472:	ff248493          	addi	s1,s1,-14 # ffffffffc0206460 <va_pa_offset>
ffffffffc0201476:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201478:	45c5                	li	a1,17
ffffffffc020147a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020147c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020147e:	04b6e963          	bltu	a3,a1,ffffffffc02014d0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201482:	601c                	ld	a5,0(s0)
ffffffffc0201484:	7b9c                	ld	a5,48(a5)
ffffffffc0201486:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201488:	00001517          	auipc	a0,0x1
ffffffffc020148c:	1e850513          	addi	a0,a0,488 # ffffffffc0202670 <best_fit_pmm_manager+0x118>
ffffffffc0201490:	ef5fe0ef          	jal	ra,ffffffffc0200384 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201494:	00004697          	auipc	a3,0x4
ffffffffc0201498:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020149c:	00005797          	auipc	a5,0x5
ffffffffc02014a0:	f8d7b223          	sd	a3,-124(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02014a8:	06f6e563          	bltu	a3,a5,ffffffffc0201512 <pmm_init+0x17e>
ffffffffc02014ac:	609c                	ld	a5,0(s1)
}
ffffffffc02014ae:	6442                	ld	s0,16(sp)
ffffffffc02014b0:	60e2                	ld	ra,24(sp)
ffffffffc02014b2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014b4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014b6:	8e9d                	sub	a3,a3,a5
ffffffffc02014b8:	00005797          	auipc	a5,0x5
ffffffffc02014bc:	f8d7bc23          	sd	a3,-104(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014c0:	00001517          	auipc	a0,0x1
ffffffffc02014c4:	1d050513          	addi	a0,a0,464 # ffffffffc0202690 <best_fit_pmm_manager+0x138>
ffffffffc02014c8:	8636                	mv	a2,a3
}
ffffffffc02014ca:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014cc:	eb9fe06f          	j	ffffffffc0200384 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014d0:	6785                	lui	a5,0x1
ffffffffc02014d2:	17fd                	addi	a5,a5,-1
ffffffffc02014d4:	96be                	add	a3,a3,a5
ffffffffc02014d6:	77fd                	lui	a5,0xfffff
ffffffffc02014d8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014da:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014de:	04e7f663          	bleu	a4,a5,ffffffffc020152a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02014e2:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014e4:	97aa                	add	a5,a5,a0
ffffffffc02014e6:	00279513          	slli	a0,a5,0x2
ffffffffc02014ea:	953e                	add	a0,a0,a5
ffffffffc02014ec:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014ee:	8d95                	sub	a1,a1,a3
ffffffffc02014f0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014f2:	81b1                	srli	a1,a1,0xc
ffffffffc02014f4:	9532                	add	a0,a0,a2
ffffffffc02014f6:	9782                	jalr	a5
ffffffffc02014f8:	b769                	j	ffffffffc0201482 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014fa:	00001617          	auipc	a2,0x1
ffffffffc02014fe:	10e60613          	addi	a2,a2,270 # ffffffffc0202608 <best_fit_pmm_manager+0xb0>
ffffffffc0201502:	06e00593          	li	a1,110
ffffffffc0201506:	00001517          	auipc	a0,0x1
ffffffffc020150a:	12a50513          	addi	a0,a0,298 # ffffffffc0202630 <best_fit_pmm_manager+0xd8>
ffffffffc020150e:	dddfe0ef          	jal	ra,ffffffffc02002ea <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201512:	00001617          	auipc	a2,0x1
ffffffffc0201516:	0f660613          	addi	a2,a2,246 # ffffffffc0202608 <best_fit_pmm_manager+0xb0>
ffffffffc020151a:	08900593          	li	a1,137
ffffffffc020151e:	00001517          	auipc	a0,0x1
ffffffffc0201522:	11250513          	addi	a0,a0,274 # ffffffffc0202630 <best_fit_pmm_manager+0xd8>
ffffffffc0201526:	dc5fe0ef          	jal	ra,ffffffffc02002ea <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020152a:	00001617          	auipc	a2,0x1
ffffffffc020152e:	11660613          	addi	a2,a2,278 # ffffffffc0202640 <best_fit_pmm_manager+0xe8>
ffffffffc0201532:	06b00593          	li	a1,107
ffffffffc0201536:	00001517          	auipc	a0,0x1
ffffffffc020153a:	12a50513          	addi	a0,a0,298 # ffffffffc0202660 <best_fit_pmm_manager+0x108>
ffffffffc020153e:	dadfe0ef          	jal	ra,ffffffffc02002ea <__panic>

ffffffffc0201542 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201542:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201546:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201548:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020154c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020154e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201552:	f022                	sd	s0,32(sp)
ffffffffc0201554:	ec26                	sd	s1,24(sp)
ffffffffc0201556:	e84a                	sd	s2,16(sp)
ffffffffc0201558:	f406                	sd	ra,40(sp)
ffffffffc020155a:	e44e                	sd	s3,8(sp)
ffffffffc020155c:	84aa                	mv	s1,a0
ffffffffc020155e:	892e                	mv	s2,a1
ffffffffc0201560:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201564:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201566:	03067e63          	bleu	a6,a2,ffffffffc02015a2 <printnum+0x60>
ffffffffc020156a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020156c:	00805763          	blez	s0,ffffffffc020157a <printnum+0x38>
ffffffffc0201570:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201572:	85ca                	mv	a1,s2
ffffffffc0201574:	854e                	mv	a0,s3
ffffffffc0201576:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201578:	fc65                	bnez	s0,ffffffffc0201570 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020157a:	1a02                	slli	s4,s4,0x20
ffffffffc020157c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201580:	00001797          	auipc	a5,0x1
ffffffffc0201584:	2e078793          	addi	a5,a5,736 # ffffffffc0202860 <error_string+0x38>
ffffffffc0201588:	9a3e                	add	s4,s4,a5
}
ffffffffc020158a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020158c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201590:	70a2                	ld	ra,40(sp)
ffffffffc0201592:	69a2                	ld	s3,8(sp)
ffffffffc0201594:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201596:	85ca                	mv	a1,s2
ffffffffc0201598:	8326                	mv	t1,s1
}
ffffffffc020159a:	6942                	ld	s2,16(sp)
ffffffffc020159c:	64e2                	ld	s1,24(sp)
ffffffffc020159e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015a0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015a2:	03065633          	divu	a2,a2,a6
ffffffffc02015a6:	8722                	mv	a4,s0
ffffffffc02015a8:	f9bff0ef          	jal	ra,ffffffffc0201542 <printnum>
ffffffffc02015ac:	b7f9                	j	ffffffffc020157a <printnum+0x38>

ffffffffc02015ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015ae:	7119                	addi	sp,sp,-128
ffffffffc02015b0:	f4a6                	sd	s1,104(sp)
ffffffffc02015b2:	f0ca                	sd	s2,96(sp)
ffffffffc02015b4:	e8d2                	sd	s4,80(sp)
ffffffffc02015b6:	e4d6                	sd	s5,72(sp)
ffffffffc02015b8:	e0da                	sd	s6,64(sp)
ffffffffc02015ba:	fc5e                	sd	s7,56(sp)
ffffffffc02015bc:	f862                	sd	s8,48(sp)
ffffffffc02015be:	f06a                	sd	s10,32(sp)
ffffffffc02015c0:	fc86                	sd	ra,120(sp)
ffffffffc02015c2:	f8a2                	sd	s0,112(sp)
ffffffffc02015c4:	ecce                	sd	s3,88(sp)
ffffffffc02015c6:	f466                	sd	s9,40(sp)
ffffffffc02015c8:	ec6e                	sd	s11,24(sp)
ffffffffc02015ca:	892a                	mv	s2,a0
ffffffffc02015cc:	84ae                	mv	s1,a1
ffffffffc02015ce:	8d32                	mv	s10,a2
ffffffffc02015d0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015d2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015d4:	00001a17          	auipc	s4,0x1
ffffffffc02015d8:	0fca0a13          	addi	s4,s4,252 # ffffffffc02026d0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015dc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015e0:	00001c17          	auipc	s8,0x1
ffffffffc02015e4:	248c0c13          	addi	s8,s8,584 # ffffffffc0202828 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015e8:	000d4503          	lbu	a0,0(s10)
ffffffffc02015ec:	02500793          	li	a5,37
ffffffffc02015f0:	001d0413          	addi	s0,s10,1
ffffffffc02015f4:	00f50e63          	beq	a0,a5,ffffffffc0201610 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02015f8:	c521                	beqz	a0,ffffffffc0201640 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015fa:	02500993          	li	s3,37
ffffffffc02015fe:	a011                	j	ffffffffc0201602 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201600:	c121                	beqz	a0,ffffffffc0201640 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201602:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201604:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201606:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201608:	fff44503          	lbu	a0,-1(s0)
ffffffffc020160c:	ff351ae3          	bne	a0,s3,ffffffffc0201600 <vprintfmt+0x52>
ffffffffc0201610:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201614:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201618:	4981                	li	s3,0
ffffffffc020161a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020161c:	5cfd                	li	s9,-1
ffffffffc020161e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201620:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201624:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201626:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020162a:	0ff6f693          	andi	a3,a3,255
ffffffffc020162e:	00140d13          	addi	s10,s0,1
ffffffffc0201632:	20d5e563          	bltu	a1,a3,ffffffffc020183c <vprintfmt+0x28e>
ffffffffc0201636:	068a                	slli	a3,a3,0x2
ffffffffc0201638:	96d2                	add	a3,a3,s4
ffffffffc020163a:	4294                	lw	a3,0(a3)
ffffffffc020163c:	96d2                	add	a3,a3,s4
ffffffffc020163e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201640:	70e6                	ld	ra,120(sp)
ffffffffc0201642:	7446                	ld	s0,112(sp)
ffffffffc0201644:	74a6                	ld	s1,104(sp)
ffffffffc0201646:	7906                	ld	s2,96(sp)
ffffffffc0201648:	69e6                	ld	s3,88(sp)
ffffffffc020164a:	6a46                	ld	s4,80(sp)
ffffffffc020164c:	6aa6                	ld	s5,72(sp)
ffffffffc020164e:	6b06                	ld	s6,64(sp)
ffffffffc0201650:	7be2                	ld	s7,56(sp)
ffffffffc0201652:	7c42                	ld	s8,48(sp)
ffffffffc0201654:	7ca2                	ld	s9,40(sp)
ffffffffc0201656:	7d02                	ld	s10,32(sp)
ffffffffc0201658:	6de2                	ld	s11,24(sp)
ffffffffc020165a:	6109                	addi	sp,sp,128
ffffffffc020165c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020165e:	4705                	li	a4,1
ffffffffc0201660:	008a8593          	addi	a1,s5,8
ffffffffc0201664:	01074463          	blt	a4,a6,ffffffffc020166c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201668:	26080363          	beqz	a6,ffffffffc02018ce <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020166c:	000ab603          	ld	a2,0(s5)
ffffffffc0201670:	46c1                	li	a3,16
ffffffffc0201672:	8aae                	mv	s5,a1
ffffffffc0201674:	a06d                	j	ffffffffc020171e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201676:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020167a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020167c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020167e:	b765                	j	ffffffffc0201626 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201680:	000aa503          	lw	a0,0(s5)
ffffffffc0201684:	85a6                	mv	a1,s1
ffffffffc0201686:	0aa1                	addi	s5,s5,8
ffffffffc0201688:	9902                	jalr	s2
            break;
ffffffffc020168a:	bfb9                	j	ffffffffc02015e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020168c:	4705                	li	a4,1
ffffffffc020168e:	008a8993          	addi	s3,s5,8
ffffffffc0201692:	01074463          	blt	a4,a6,ffffffffc020169a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201696:	22080463          	beqz	a6,ffffffffc02018be <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020169a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020169e:	24044463          	bltz	s0,ffffffffc02018e6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016a2:	8622                	mv	a2,s0
ffffffffc02016a4:	8ace                	mv	s5,s3
ffffffffc02016a6:	46a9                	li	a3,10
ffffffffc02016a8:	a89d                	j	ffffffffc020171e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016aa:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ae:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016b0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016b2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016b6:	8fb5                	xor	a5,a5,a3
ffffffffc02016b8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016bc:	1ad74363          	blt	a4,a3,ffffffffc0201862 <vprintfmt+0x2b4>
ffffffffc02016c0:	00369793          	slli	a5,a3,0x3
ffffffffc02016c4:	97e2                	add	a5,a5,s8
ffffffffc02016c6:	639c                	ld	a5,0(a5)
ffffffffc02016c8:	18078d63          	beqz	a5,ffffffffc0201862 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02016cc:	86be                	mv	a3,a5
ffffffffc02016ce:	00001617          	auipc	a2,0x1
ffffffffc02016d2:	24260613          	addi	a2,a2,578 # ffffffffc0202910 <error_string+0xe8>
ffffffffc02016d6:	85a6                	mv	a1,s1
ffffffffc02016d8:	854a                	mv	a0,s2
ffffffffc02016da:	240000ef          	jal	ra,ffffffffc020191a <printfmt>
ffffffffc02016de:	b729                	j	ffffffffc02015e8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02016e0:	00144603          	lbu	a2,1(s0)
ffffffffc02016e4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016e6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016e8:	bf3d                	j	ffffffffc0201626 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02016ea:	4705                	li	a4,1
ffffffffc02016ec:	008a8593          	addi	a1,s5,8
ffffffffc02016f0:	01074463          	blt	a4,a6,ffffffffc02016f8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02016f4:	1e080263          	beqz	a6,ffffffffc02018d8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02016f8:	000ab603          	ld	a2,0(s5)
ffffffffc02016fc:	46a1                	li	a3,8
ffffffffc02016fe:	8aae                	mv	s5,a1
ffffffffc0201700:	a839                	j	ffffffffc020171e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201702:	03000513          	li	a0,48
ffffffffc0201706:	85a6                	mv	a1,s1
ffffffffc0201708:	e03e                	sd	a5,0(sp)
ffffffffc020170a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020170c:	85a6                	mv	a1,s1
ffffffffc020170e:	07800513          	li	a0,120
ffffffffc0201712:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201714:	0aa1                	addi	s5,s5,8
ffffffffc0201716:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020171a:	6782                	ld	a5,0(sp)
ffffffffc020171c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020171e:	876e                	mv	a4,s11
ffffffffc0201720:	85a6                	mv	a1,s1
ffffffffc0201722:	854a                	mv	a0,s2
ffffffffc0201724:	e1fff0ef          	jal	ra,ffffffffc0201542 <printnum>
            break;
ffffffffc0201728:	b5c1                	j	ffffffffc02015e8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020172a:	000ab603          	ld	a2,0(s5)
ffffffffc020172e:	0aa1                	addi	s5,s5,8
ffffffffc0201730:	1c060663          	beqz	a2,ffffffffc02018fc <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201734:	00160413          	addi	s0,a2,1
ffffffffc0201738:	17b05c63          	blez	s11,ffffffffc02018b0 <vprintfmt+0x302>
ffffffffc020173c:	02d00593          	li	a1,45
ffffffffc0201740:	14b79263          	bne	a5,a1,ffffffffc0201884 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201744:	00064783          	lbu	a5,0(a2)
ffffffffc0201748:	0007851b          	sext.w	a0,a5
ffffffffc020174c:	c905                	beqz	a0,ffffffffc020177c <vprintfmt+0x1ce>
ffffffffc020174e:	000cc563          	bltz	s9,ffffffffc0201758 <vprintfmt+0x1aa>
ffffffffc0201752:	3cfd                	addiw	s9,s9,-1
ffffffffc0201754:	036c8263          	beq	s9,s6,ffffffffc0201778 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201758:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020175a:	18098463          	beqz	s3,ffffffffc02018e2 <vprintfmt+0x334>
ffffffffc020175e:	3781                	addiw	a5,a5,-32
ffffffffc0201760:	18fbf163          	bleu	a5,s7,ffffffffc02018e2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201764:	03f00513          	li	a0,63
ffffffffc0201768:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020176a:	0405                	addi	s0,s0,1
ffffffffc020176c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201770:	3dfd                	addiw	s11,s11,-1
ffffffffc0201772:	0007851b          	sext.w	a0,a5
ffffffffc0201776:	fd61                	bnez	a0,ffffffffc020174e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201778:	e7b058e3          	blez	s11,ffffffffc02015e8 <vprintfmt+0x3a>
ffffffffc020177c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020177e:	85a6                	mv	a1,s1
ffffffffc0201780:	02000513          	li	a0,32
ffffffffc0201784:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201786:	e60d81e3          	beqz	s11,ffffffffc02015e8 <vprintfmt+0x3a>
ffffffffc020178a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020178c:	85a6                	mv	a1,s1
ffffffffc020178e:	02000513          	li	a0,32
ffffffffc0201792:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201794:	fe0d94e3          	bnez	s11,ffffffffc020177c <vprintfmt+0x1ce>
ffffffffc0201798:	bd81                	j	ffffffffc02015e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020179a:	4705                	li	a4,1
ffffffffc020179c:	008a8593          	addi	a1,s5,8
ffffffffc02017a0:	01074463          	blt	a4,a6,ffffffffc02017a8 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017a4:	12080063          	beqz	a6,ffffffffc02018c4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017a8:	000ab603          	ld	a2,0(s5)
ffffffffc02017ac:	46a9                	li	a3,10
ffffffffc02017ae:	8aae                	mv	s5,a1
ffffffffc02017b0:	b7bd                	j	ffffffffc020171e <vprintfmt+0x170>
ffffffffc02017b2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017b6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ba:	846a                	mv	s0,s10
ffffffffc02017bc:	b5ad                	j	ffffffffc0201626 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017be:	85a6                	mv	a1,s1
ffffffffc02017c0:	02500513          	li	a0,37
ffffffffc02017c4:	9902                	jalr	s2
            break;
ffffffffc02017c6:	b50d                	j	ffffffffc02015e8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017c8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02017cc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017d0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017d2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02017d4:	e40dd9e3          	bgez	s11,ffffffffc0201626 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02017d8:	8de6                	mv	s11,s9
ffffffffc02017da:	5cfd                	li	s9,-1
ffffffffc02017dc:	b5a9                	j	ffffffffc0201626 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02017de:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02017e2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017e6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017e8:	bd3d                	j	ffffffffc0201626 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02017ea:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02017ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017f2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02017f4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02017f8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017fc:	fcd56ce3          	bltu	a0,a3,ffffffffc02017d4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201800:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201802:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201806:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020180a:	0196873b          	addw	a4,a3,s9
ffffffffc020180e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201812:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201816:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020181a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020181e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201822:	fcd57fe3          	bleu	a3,a0,ffffffffc0201800 <vprintfmt+0x252>
ffffffffc0201826:	b77d                	j	ffffffffc02017d4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201828:	fffdc693          	not	a3,s11
ffffffffc020182c:	96fd                	srai	a3,a3,0x3f
ffffffffc020182e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201832:	00144603          	lbu	a2,1(s0)
ffffffffc0201836:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201838:	846a                	mv	s0,s10
ffffffffc020183a:	b3f5                	j	ffffffffc0201626 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020183c:	85a6                	mv	a1,s1
ffffffffc020183e:	02500513          	li	a0,37
ffffffffc0201842:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201844:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201848:	02500793          	li	a5,37
ffffffffc020184c:	8d22                	mv	s10,s0
ffffffffc020184e:	d8f70de3          	beq	a4,a5,ffffffffc02015e8 <vprintfmt+0x3a>
ffffffffc0201852:	02500713          	li	a4,37
ffffffffc0201856:	1d7d                	addi	s10,s10,-1
ffffffffc0201858:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020185c:	fee79de3          	bne	a5,a4,ffffffffc0201856 <vprintfmt+0x2a8>
ffffffffc0201860:	b361                	j	ffffffffc02015e8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201862:	00001617          	auipc	a2,0x1
ffffffffc0201866:	09e60613          	addi	a2,a2,158 # ffffffffc0202900 <error_string+0xd8>
ffffffffc020186a:	85a6                	mv	a1,s1
ffffffffc020186c:	854a                	mv	a0,s2
ffffffffc020186e:	0ac000ef          	jal	ra,ffffffffc020191a <printfmt>
ffffffffc0201872:	bb9d                	j	ffffffffc02015e8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201874:	00001617          	auipc	a2,0x1
ffffffffc0201878:	08460613          	addi	a2,a2,132 # ffffffffc02028f8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020187c:	00001417          	auipc	s0,0x1
ffffffffc0201880:	07d40413          	addi	s0,s0,125 # ffffffffc02028f9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201884:	8532                	mv	a0,a2
ffffffffc0201886:	85e6                	mv	a1,s9
ffffffffc0201888:	e032                	sd	a2,0(sp)
ffffffffc020188a:	e43e                	sd	a5,8(sp)
ffffffffc020188c:	1c2000ef          	jal	ra,ffffffffc0201a4e <strnlen>
ffffffffc0201890:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201894:	6602                	ld	a2,0(sp)
ffffffffc0201896:	01b05d63          	blez	s11,ffffffffc02018b0 <vprintfmt+0x302>
ffffffffc020189a:	67a2                	ld	a5,8(sp)
ffffffffc020189c:	2781                	sext.w	a5,a5
ffffffffc020189e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018a0:	6522                	ld	a0,8(sp)
ffffffffc02018a2:	85a6                	mv	a1,s1
ffffffffc02018a4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018a6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018a8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018aa:	6602                	ld	a2,0(sp)
ffffffffc02018ac:	fe0d9ae3          	bnez	s11,ffffffffc02018a0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018b0:	00064783          	lbu	a5,0(a2)
ffffffffc02018b4:	0007851b          	sext.w	a0,a5
ffffffffc02018b8:	e8051be3          	bnez	a0,ffffffffc020174e <vprintfmt+0x1a0>
ffffffffc02018bc:	b335                	j	ffffffffc02015e8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018be:	000aa403          	lw	s0,0(s5)
ffffffffc02018c2:	bbf1                	j	ffffffffc020169e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018c4:	000ae603          	lwu	a2,0(s5)
ffffffffc02018c8:	46a9                	li	a3,10
ffffffffc02018ca:	8aae                	mv	s5,a1
ffffffffc02018cc:	bd89                	j	ffffffffc020171e <vprintfmt+0x170>
ffffffffc02018ce:	000ae603          	lwu	a2,0(s5)
ffffffffc02018d2:	46c1                	li	a3,16
ffffffffc02018d4:	8aae                	mv	s5,a1
ffffffffc02018d6:	b5a1                	j	ffffffffc020171e <vprintfmt+0x170>
ffffffffc02018d8:	000ae603          	lwu	a2,0(s5)
ffffffffc02018dc:	46a1                	li	a3,8
ffffffffc02018de:	8aae                	mv	s5,a1
ffffffffc02018e0:	bd3d                	j	ffffffffc020171e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02018e2:	9902                	jalr	s2
ffffffffc02018e4:	b559                	j	ffffffffc020176a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02018e6:	85a6                	mv	a1,s1
ffffffffc02018e8:	02d00513          	li	a0,45
ffffffffc02018ec:	e03e                	sd	a5,0(sp)
ffffffffc02018ee:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018f0:	8ace                	mv	s5,s3
ffffffffc02018f2:	40800633          	neg	a2,s0
ffffffffc02018f6:	46a9                	li	a3,10
ffffffffc02018f8:	6782                	ld	a5,0(sp)
ffffffffc02018fa:	b515                	j	ffffffffc020171e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02018fc:	01b05663          	blez	s11,ffffffffc0201908 <vprintfmt+0x35a>
ffffffffc0201900:	02d00693          	li	a3,45
ffffffffc0201904:	f6d798e3          	bne	a5,a3,ffffffffc0201874 <vprintfmt+0x2c6>
ffffffffc0201908:	00001417          	auipc	s0,0x1
ffffffffc020190c:	ff140413          	addi	s0,s0,-15 # ffffffffc02028f9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201910:	02800513          	li	a0,40
ffffffffc0201914:	02800793          	li	a5,40
ffffffffc0201918:	bd1d                	j	ffffffffc020174e <vprintfmt+0x1a0>

ffffffffc020191a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020191a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020191c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201920:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201922:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201924:	ec06                	sd	ra,24(sp)
ffffffffc0201926:	f83a                	sd	a4,48(sp)
ffffffffc0201928:	fc3e                	sd	a5,56(sp)
ffffffffc020192a:	e0c2                	sd	a6,64(sp)
ffffffffc020192c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020192e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201930:	c7fff0ef          	jal	ra,ffffffffc02015ae <vprintfmt>
}
ffffffffc0201934:	60e2                	ld	ra,24(sp)
ffffffffc0201936:	6161                	addi	sp,sp,80
ffffffffc0201938:	8082                	ret

ffffffffc020193a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020193a:	715d                	addi	sp,sp,-80
ffffffffc020193c:	e486                	sd	ra,72(sp)
ffffffffc020193e:	e0a2                	sd	s0,64(sp)
ffffffffc0201940:	fc26                	sd	s1,56(sp)
ffffffffc0201942:	f84a                	sd	s2,48(sp)
ffffffffc0201944:	f44e                	sd	s3,40(sp)
ffffffffc0201946:	f052                	sd	s4,32(sp)
ffffffffc0201948:	ec56                	sd	s5,24(sp)
ffffffffc020194a:	e85a                	sd	s6,16(sp)
ffffffffc020194c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020194e:	c901                	beqz	a0,ffffffffc020195e <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201950:	85aa                	mv	a1,a0
ffffffffc0201952:	00001517          	auipc	a0,0x1
ffffffffc0201956:	fbe50513          	addi	a0,a0,-66 # ffffffffc0202910 <error_string+0xe8>
ffffffffc020195a:	a2bfe0ef          	jal	ra,ffffffffc0200384 <cprintf>
readline(const char *prompt) {
ffffffffc020195e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201960:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201962:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201964:	4aa9                	li	s5,10
ffffffffc0201966:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201968:	00004b97          	auipc	s7,0x4
ffffffffc020196c:	6a8b8b93          	addi	s7,s7,1704 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201970:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201974:	a89fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc0201978:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020197a:	00054b63          	bltz	a0,ffffffffc0201990 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020197e:	00a95b63          	ble	a0,s2,ffffffffc0201994 <readline+0x5a>
ffffffffc0201982:	029a5463          	ble	s1,s4,ffffffffc02019aa <readline+0x70>
        c = getchar();
ffffffffc0201986:	a77fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc020198a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020198c:	fe0559e3          	bgez	a0,ffffffffc020197e <readline+0x44>
            return NULL;
ffffffffc0201990:	4501                	li	a0,0
ffffffffc0201992:	a099                	j	ffffffffc02019d8 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201994:	03341463          	bne	s0,s3,ffffffffc02019bc <readline+0x82>
ffffffffc0201998:	e8b9                	bnez	s1,ffffffffc02019ee <readline+0xb4>
        c = getchar();
ffffffffc020199a:	a63fe0ef          	jal	ra,ffffffffc02003fc <getchar>
ffffffffc020199e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019a0:	fe0548e3          	bltz	a0,ffffffffc0201990 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019a4:	fea958e3          	ble	a0,s2,ffffffffc0201994 <readline+0x5a>
ffffffffc02019a8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019aa:	8522                	mv	a0,s0
ffffffffc02019ac:	a0dfe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            buf[i ++] = c;
ffffffffc02019b0:	009b87b3          	add	a5,s7,s1
ffffffffc02019b4:	00878023          	sb	s0,0(a5)
ffffffffc02019b8:	2485                	addiw	s1,s1,1
ffffffffc02019ba:	bf6d                	j	ffffffffc0201974 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019bc:	01540463          	beq	s0,s5,ffffffffc02019c4 <readline+0x8a>
ffffffffc02019c0:	fb641ae3          	bne	s0,s6,ffffffffc0201974 <readline+0x3a>
            cputchar(c);
ffffffffc02019c4:	8522                	mv	a0,s0
ffffffffc02019c6:	9f3fe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            buf[i] = '\0';
ffffffffc02019ca:	00004517          	auipc	a0,0x4
ffffffffc02019ce:	64650513          	addi	a0,a0,1606 # ffffffffc0206010 <edata>
ffffffffc02019d2:	94aa                	add	s1,s1,a0
ffffffffc02019d4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019d8:	60a6                	ld	ra,72(sp)
ffffffffc02019da:	6406                	ld	s0,64(sp)
ffffffffc02019dc:	74e2                	ld	s1,56(sp)
ffffffffc02019de:	7942                	ld	s2,48(sp)
ffffffffc02019e0:	79a2                	ld	s3,40(sp)
ffffffffc02019e2:	7a02                	ld	s4,32(sp)
ffffffffc02019e4:	6ae2                	ld	s5,24(sp)
ffffffffc02019e6:	6b42                	ld	s6,16(sp)
ffffffffc02019e8:	6ba2                	ld	s7,8(sp)
ffffffffc02019ea:	6161                	addi	sp,sp,80
ffffffffc02019ec:	8082                	ret
            cputchar(c);
ffffffffc02019ee:	4521                	li	a0,8
ffffffffc02019f0:	9c9fe0ef          	jal	ra,ffffffffc02003b8 <cputchar>
            i --;
ffffffffc02019f4:	34fd                	addiw	s1,s1,-1
ffffffffc02019f6:	bfbd                	j	ffffffffc0201974 <readline+0x3a>

ffffffffc02019f8 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02019f8:	00004797          	auipc	a5,0x4
ffffffffc02019fc:	61078793          	addi	a5,a5,1552 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a00:	6398                	ld	a4,0(a5)
ffffffffc0201a02:	4781                	li	a5,0
ffffffffc0201a04:	88ba                	mv	a7,a4
ffffffffc0201a06:	852a                	mv	a0,a0
ffffffffc0201a08:	85be                	mv	a1,a5
ffffffffc0201a0a:	863e                	mv	a2,a5
ffffffffc0201a0c:	00000073          	ecall
ffffffffc0201a10:	87aa                	mv	a5,a0
}
ffffffffc0201a12:	8082                	ret

ffffffffc0201a14 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a14:	00005797          	auipc	a5,0x5
ffffffffc0201a18:	a1478793          	addi	a5,a5,-1516 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a1c:	6398                	ld	a4,0(a5)
ffffffffc0201a1e:	4781                	li	a5,0
ffffffffc0201a20:	88ba                	mv	a7,a4
ffffffffc0201a22:	852a                	mv	a0,a0
ffffffffc0201a24:	85be                	mv	a1,a5
ffffffffc0201a26:	863e                	mv	a2,a5
ffffffffc0201a28:	00000073          	ecall
ffffffffc0201a2c:	87aa                	mv	a5,a0
}
ffffffffc0201a2e:	8082                	ret

ffffffffc0201a30 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a30:	00004797          	auipc	a5,0x4
ffffffffc0201a34:	5d078793          	addi	a5,a5,1488 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a38:	639c                	ld	a5,0(a5)
ffffffffc0201a3a:	4501                	li	a0,0
ffffffffc0201a3c:	88be                	mv	a7,a5
ffffffffc0201a3e:	852a                	mv	a0,a0
ffffffffc0201a40:	85aa                	mv	a1,a0
ffffffffc0201a42:	862a                	mv	a2,a0
ffffffffc0201a44:	00000073          	ecall
ffffffffc0201a48:	852a                	mv	a0,a0
ffffffffc0201a4a:	2501                	sext.w	a0,a0
ffffffffc0201a4c:	8082                	ret

ffffffffc0201a4e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a4e:	c185                	beqz	a1,ffffffffc0201a6e <strnlen+0x20>
ffffffffc0201a50:	00054783          	lbu	a5,0(a0)
ffffffffc0201a54:	cf89                	beqz	a5,ffffffffc0201a6e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a56:	4781                	li	a5,0
ffffffffc0201a58:	a021                	j	ffffffffc0201a60 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a5a:	00074703          	lbu	a4,0(a4)
ffffffffc0201a5e:	c711                	beqz	a4,ffffffffc0201a6a <strnlen+0x1c>
        cnt ++;
ffffffffc0201a60:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a62:	00f50733          	add	a4,a0,a5
ffffffffc0201a66:	fef59ae3          	bne	a1,a5,ffffffffc0201a5a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201a6a:	853e                	mv	a0,a5
ffffffffc0201a6c:	8082                	ret
    size_t cnt = 0;
ffffffffc0201a6e:	4781                	li	a5,0
}
ffffffffc0201a70:	853e                	mv	a0,a5
ffffffffc0201a72:	8082                	ret

ffffffffc0201a74 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a74:	00054783          	lbu	a5,0(a0)
ffffffffc0201a78:	0005c703          	lbu	a4,0(a1)
ffffffffc0201a7c:	cb91                	beqz	a5,ffffffffc0201a90 <strcmp+0x1c>
ffffffffc0201a7e:	00e79c63          	bne	a5,a4,ffffffffc0201a96 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201a82:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a84:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201a88:	0585                	addi	a1,a1,1
ffffffffc0201a8a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a8e:	fbe5                	bnez	a5,ffffffffc0201a7e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a90:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a92:	9d19                	subw	a0,a0,a4
ffffffffc0201a94:	8082                	ret
ffffffffc0201a96:	0007851b          	sext.w	a0,a5
ffffffffc0201a9a:	9d19                	subw	a0,a0,a4
ffffffffc0201a9c:	8082                	ret

ffffffffc0201a9e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a9e:	00054783          	lbu	a5,0(a0)
ffffffffc0201aa2:	cb91                	beqz	a5,ffffffffc0201ab6 <strchr+0x18>
        if (*s == c) {
ffffffffc0201aa4:	00b79563          	bne	a5,a1,ffffffffc0201aae <strchr+0x10>
ffffffffc0201aa8:	a809                	j	ffffffffc0201aba <strchr+0x1c>
ffffffffc0201aaa:	00b78763          	beq	a5,a1,ffffffffc0201ab8 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201aae:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201ab0:	00054783          	lbu	a5,0(a0)
ffffffffc0201ab4:	fbfd                	bnez	a5,ffffffffc0201aaa <strchr+0xc>
    }
    return NULL;
ffffffffc0201ab6:	4501                	li	a0,0
}
ffffffffc0201ab8:	8082                	ret
ffffffffc0201aba:	8082                	ret

ffffffffc0201abc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201abc:	ca01                	beqz	a2,ffffffffc0201acc <memset+0x10>
ffffffffc0201abe:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201ac0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ac2:	0785                	addi	a5,a5,1
ffffffffc0201ac4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201ac8:	fec79de3          	bne	a5,a2,ffffffffc0201ac2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201acc:	8082                	ret
