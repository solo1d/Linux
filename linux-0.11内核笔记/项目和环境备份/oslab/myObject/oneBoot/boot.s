!
! boot.s
!
.globl	begtext, begdata, begbss, endtext, enddata, endbss    !gloab  sin  ld86
.text   ! text 
begtext:
.data  
begdata:
.bss
begbss:
.text
BOOTESG = 0x07c0    !! BIOS loader bootesect text , duan pos

entry  start    ! start  progream
start:
	jmpi	go,BOOTESG	! go is  offset ,go=0x5, default  CS:IP = 0x0000:0x7c00 ->  CS:IP= 0x07c0:0x0005
go:	mov	ax,cs		! cs -> as
	mov	ds,ax
	mov	es,ax
	mov	[msg1+17],ah	! replace  string msg1+17= . 
	mov	cx,#20		! 20  sum
	mov	dx,#0x1004	! show pos
	mov	bx,#0x000c	! red
	mov	bp,#msg1
	mov	ax,#0x1301	!start  end pos
	int	0x10		!BIOS  RIQ 0x10   0x13  01
loop1:	jmp	loop1		! no jmp
msg1:	.ascii	"Loading system ..." ! show message
	.byte	13,10
.org 510
	.word 0xAA55
.text
endtext:
.data
enddata:
.bss
endbss:
