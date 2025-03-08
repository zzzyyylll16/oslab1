# TODO: This is lab1.2
/* Protected Mode Hello World */
.code16

.global start
start:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	# TODO:关闭中断
	cli

	# 启动A20总线
	inb $0x92, %al 
	orb $0x02, %al
	outb %al, $0x92

	# 加载GDTR
	data32 addr32 lgdt gdtDesc # loading gdtr, data32, addr32

	# TODO：设置CR0的PE位（第0位）为1
	movl %cr0, %eax
	orl $1, %eax
	movl %eax, %cr0


	# 长跳转切换至保护模式
	data32 ljmp $0x08, $start32 # reload code segment selector and ljmp to start32, data32

.code32
start32:
	movw $0x10, %ax # setting data segment selector
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %ss
	movw $0x18, %ax # setting graphics data segment selector
	movw %ax, %gs
	
	movl $0x8000, %eax # setting esp
	movl %eax, %esp
	# TODO:输出Hello World
	movl $message, %esi     # 字符串地址
	movl $0, %edi           # 显存起始位置（第0行第0列）
	movb $0x0C, %ah         # 属性：红底黑字

print_loop:
    lodsb               # 加载字符到 AL
    cmpb $0, %al        # 检测字符串结束符
    je .print_done
    movw %ax, %gs:(%edi) # 写入显存（使用图形段选择子0x18）
    addl $2, %edi       # 移动到下一个字符位置
    jmp print_loop

.print_done:
    ret


loop32:
	jmp loop32

message:
	.string "Hello, World!\0"



.p2align 2
gdt: # 8 bytes for each table entry, at least 1 entry
	# .word limit[15:0],base[15:0]
	# .byte base[23:16],(0x90|(type)),(0xc0|(limit[19:16])),base[31:24]
	# GDT第一个表项为空
	.word 0,0
	.byte 0,0,0,0

	# TODO：code segment entry
	.word 0xFFFF      # 段限长（低16位）
    .word 0x0000      # 基地址（低16位）
    .byte 0x00        # 基地址（16-23位）
    .byte 0b10011010  # 访问权限（P=1, DPL=0, S=1, Type=1010）
    .byte 0b11001111  # 标志（G=1, D/B=1, AVL=0, Limit[19:16]=0xF）
    .byte 0x00        # 基地址（24-31位）

	# TODO：data segment entry
	.word 0xFFFF, 0x0000
    .byte 0x00, 0x92, 0xCF, 0x00

	# TODO：graphics segment entry
	.word 0x0FFF, 0x8000
    .byte 0x0B, 0x92, 0x40, 0x00

gdtDesc: 
	.word (gdtDesc - gdt -1) 
	.long gdt 
