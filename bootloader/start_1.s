# TODO: This is lab1.1
/* Real Mode Hello World */
.code16

.global start
start:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $0x7d00, %ax
	movw %ax, %sp # setting stack pointer to 0x7d00
	# TODO:通过中断输出Hello World, 并且间隔1000ms打印新的一行
	cli
	movw $clock_handler, %ax
    	movw %ax, 0x70          # 偏移地址存入0x70
    	movw %cs, %ax
    	movw %ax, 0x72          # 段地址存入0x72

    	# 配置8254定时器（20ms触发一次中断）
    	movb $0x36, %al         # 控制字：通道0，模式3，二进制计数
    	outb %al, $0x43
    	movw $23863, %ax        # 计数值=1193180/(50Hz)-1=23863
    	outb %al, $0x40         # 写入低字节
    	movb %ah, %al
    	outb %al, $0x40         # 写入高字节
	sti                     # 开启中断
loop:
	jmp loop
clock_handler:
    	pusha                   # 保存所有通用寄存器
    	push %ds                # 保存数据段寄存器
    	movw %cs, %ax
    	movw %ax, %ds           # 设置DS=CS

    	incl (counter)           # 中断次数+1
    	cmpl $50, (counter)      # 检查是否达到50次（20ms*50=1s）
    	jne .end

    	movl $0, (counter)       # 重置计数器
    	call print_hello        # 调用打印函数

.end:
    	movb $0x20, %al         # 发送EOI（中断结束命令）
    	outb %al, $0x20
    	pop %ds                 # 恢复数据段寄存器
    	popa                    # 恢复通用寄存器
    	iret                    # 中断返回
print_hello:
  	movw $message, %si      # 字符串地址
.print_loop:
    	lodsb                   # 加载字符到AL
    	cmpb $0, %al            # 检查字符串结束符
    	je .done
    	movb $0x0E, %ah         # BIOS功能0x0E（打印字符）
    	int $0x10               # 调用BIOS中断
    	jmp .print_loop
.done:
    	ret

# 数据段
counter:
    	.long 0                 # 32位计数器（50次=1秒）

message:
	.string "Hello, World!\n\0"







