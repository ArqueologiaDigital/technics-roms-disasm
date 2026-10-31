# floppy/tools/pc_boot_stub.s -- the PC boot code of the nine SX-WSA1R softlist diskettes (16-bit x86).
#
# Assembled on its own by floppy/Makefile (llvm-mc -triple=i386, then llvm-objcopy -O binary) into
# build/pc_boot_stub.bin, which each WSA1R disk's boot.s includes as Boot_Code, bytes 0x3E..0x1FD of
# sector 0 (after the FAT12 extended BPB).  It is not instrument code: the WSA1R never runs it.  The disks
# carry OEM name "MSWIN4.1" and this stub; notes/open-items/probes/wsa1_boot_sectors.py shows all nine hold
# the same 448 bytes (SHA-1 631c4b94c3526e28a7382af72f54f3907065fa22).  [INFERENCE] the tool that made the
# images wrote it; the instrument's own formatter writes `jmp $` instead (the KN5000's
# FDC_Format2HD_BootSectorHead, floppy/kn5000/*/boot.s).
#
# What it does, when a PC BIOS boots the diskette (loaded at 0000:7C00, so this code starts at 0x7C3E):
# print the message with INT 10h function 0Eh (teletype, page 0, colour 7), wait for a key with INT 16h
# function 0, then INT 19h (bootstrap loader: try the boot devices again).  If INT 19h returns, it spins.
#
# Two instructions are spelled as bytes: llvm-mc encodes `andb %al, %al` / `xorb %ah, %ah` with opcodes
# 0x20 / 0x30 (r/m8, r8) and has no way to ask for the 0x22 / 0x32 forms (r8, r/m8) the disks hold: its
# x86 parser knows no {load} pseudo-prefix and the _REV forms are disassembler-only.

	.code16
	.text
Stub_Start:
	pushw	%cs
	popw	%ds
	movw	$(0x7c3e + Stub_Message - Stub_Start), %si
Stub_PrintNext:
	lodsb
	.byte	0x22, 0xc0			# and al, al  (0x22: AND r8, r/m8)
	je	Stub_WaitKey
	pushw	%si
	movb	$0x0e, %ah			# INT 10h AH=0Eh: teletype output of AL
	movw	$0x0007, %bx			# BH = page 0, BL = colour 7
	int	$0x10
	popw	%si
	jmp	Stub_PrintNext
Stub_WaitKey:
	.byte	0x32, 0xe4			# xor ah, ah  (0x32: XOR r8, r/m8); INT 16h AH=0: read a key
	int	$0x16
	int	$0x19				# reboot through the BIOS bootstrap loader
Stub_Spin:
	jmp	Stub_Spin
Stub_Message:
	.asciz	"This is not a bootable disk. Please insert a bootable floppy and press any key to try again ...\n"
	.fill	0x1fe - 0x3e - (. - Stub_Start), 1, 0	# zero to the boot signature
