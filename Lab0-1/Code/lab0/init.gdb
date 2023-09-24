# 在退出gdb的时候自动关闭QEMU
define hook-quit
    kill
end

# 与远程连接
target remote localhost:1234
# 加载bin/kernel文件
file bin/kernel
# 设置体系结构为RISC-V的64版本
set arch riscv:rv64
# 执行gdb命令
