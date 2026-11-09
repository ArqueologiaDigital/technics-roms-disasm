; Entry for the phase 2 exit test: interrupts off (di = ei 7), a private stack inside the loaded area, run the
; test, then wait in a loop; the Lua script detects the end by reading R.magic.
	.text
	.globl _start
_start:
	di
	ld	xsp, 0xe8000
	call	cc900_test
done:	jr	done		; a named label: llvm-mc resolves a backward numeric label (1: / jr 1b) wrongly (phase2.md)
