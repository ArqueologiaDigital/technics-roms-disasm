; ---------------------------------------------------------------------
; Task2_CallbackDispatcher -- kernel task 2: wait, take a callback, call it
;
; Called from: NOT called -- it is a TASK ENTRY POINT.  EntryPoint_Records[2]
;          at 0xF85E96 holds PC = 0x00F42E88, and prom_b 0xF42E88 is
;          `jp 0xF8DA00`.  (The records are at 0xF85E8A with the kernel's
;          one-based bias; see notes/FINDINGS-prom_a-kernel-lifecycle.md §2.)
;          That is also why the directory slot naming it has ZERO references:
;          nothing calls it, the scheduler dispatches it.
;          Its record gives it stack 0x0060E980 and priority 3.
; Inputs:  none.
; Outputs: never returns.
; Evidence: the body is a three-instruction loop and every step is literal --
;          `ld A,0x01 / call 0xF42D90` is Kernel_SemaWait on semaphore 1
;          (0xF42D90 is `jp 0xF85A96`, and 0xF85A96 is Kernel_SemaWait in
;          notes/FINDINGS-prom_a-kernel-lifecycle.md §5.2); `call
;          CallbackQueue_Take`; `cp XIY,0xffffffff / jr Z` back to the wait when
;          the queue was empty; and `call T,XIY`, an INDIRECT call through the
;          value the queue returned.  A queue whose elements are called is a
;          queue of function pointers.
; Unknown: ★ CallbackQueue_Post does NOT signal semaphore 1, and nothing else in
;          this module does either.  Whatever wakes this task is outside the
;          module, and this tree has not found it.  Until it does, "one signal
;          per callback" is NOT established -- only that the task consumes one
;          signal per iteration.
; ---------------------------------------------------------------------
Task2_CallbackDispatcher:
	ld a, 0x01:opc                                          ; F8DA00  21 01
	call T_Kernel_SemaWait                               ; F8DA02  1d 90 2d f4
	call CallbackQueue_Take                              ; F8DA06  1d 49 da f8
	cp XIY,0xffffffff                                    ; F8DA0A  ed cf ff ff ff ff
	jr z, Task2_CallbackDispatcher                       ; F8DA10  66 ee
	call (xiy)                                           ; F8DA12  b5 e8
	jr Task2_CallbackDispatcher                          ; F8DA14  68 ea
; ---------------------------------------------------------------------
; CallbackQueue_Post -- append one 32-bit callback to the queue
;
; Called from: directory slot T_CallbackQueue_Post (T_F42E84), which carries the highest reference
;          upper bound of any prom_a slot: 188.
; Inputs:  one 32-bit stack argument at (XIZ+0x08) -- the callback.
; Outputs: WA = 0 on success, 0xFFFF when the queue is full and nothing was
;          stored.  A full queue DROPS.
; Evidence: `cp WA,5 / jr C` against the free-byte count refuses when fewer
;          than five bytes are free, which is the four-byte element plus the
;          one byte the ring never uses; the store is the register-indexed
;          `ld (XBC+IY),XWA`, a 32-bit write at the write index; `minc4_16
;          iy,0x01fc` advances it by four modulo 0x200; `decw 4,(XBC-2)` takes
;          four bytes off the free count.  Element size and capacity are both
;          read straight off those two instructions.
; Notes:   `ei 0x06` on entry and `ei 0x00` on exit are the critical section --
;          the interrupt mask raised and then lowered again.  ⚠ `ei 0` ENABLES
;          interrupts; this tree has documented it backwards before.
; ---------------------------------------------------------------------
CallbackQueue_Post:
	link XIZ,0x0000                                      ; F8DA16  ee 0c 00 00
	ld XBC,0x00600416                                    ; F8DA1A  41 16 04 60 00
	ei 0x06                                              ; F8DA1F  06 06
	ld wa, (xbc-2)                                       ; F8DA21  99 fe 20
	cp wa, 0x05:i3                                         ; F8DA24  d8 dd
	jr c, .LF8DA44                                       ; F8DA26  67 1c
	ld iy, (xbc-4)                                       ; F8DA28  99 fc 25
	ld XWA,(XIZ+0x08)                                    ; F8DA2B  ae 08 20
	ld	(xbc+iy), xwa                                ; F8DA2E  f3 07 e4 f4 60
	minc4_16 iy, 0x01fc                                  ; F8DA33  dd 3a fc 01
	ld (xbc-4), iy                                       ; F8DA37  b9 fc 55
	decm 0x04, (xbc-2)                                   ; F8DA3A  99 fe 6c
	xor WA,WA                                            ; F8DA3D  d8 d0
.LF8DA3F:
	ei 0x00                                              ; F8DA3F  06 00
	unlk XIZ                                             ; F8DA41  ee 0d
	ret                                                  ; F8DA43  0e
.LF8DA44:
	ldw wa, 0xffff                                       ; F8DA44  30 ff ff
	jr .LF8DA3F                                          ; F8DA47  68 f6
; ---------------------------------------------------------------------
; CallbackQueue_Take -- remove one callback, or report the queue empty
;
; Called from: Task2_CallbackDispatcher, and nothing else names it.
; Inputs:  none.
; Outputs: XIY = the callback, or 0xFFFFFFFF when the queue was empty.
; Evidence: empty is `cp WA,(XBC-4)` -- read index against write index, the same
;          test the ring class's Get uses -- and the empty answer is built, not
;          loaded: `xor XIY,XIY` then `dec 1,XIY`, which is 0xFFFFFFFF and is
;          exactly the value Task2_CallbackDispatcher compares against.
;          `incw 4,(XBC-2)` returns the four bytes to the free count, the
;          inverse of Post's `decw 4`.
; ---------------------------------------------------------------------
CallbackQueue_Take:
	ld XBC,0x00600416                                    ; F8DA49  41 16 04 60 00
	ei 0x06                                              ; F8DA4E  06 06
	ld wa, (xbc-8)                                       ; F8DA50  99 f8 20
	cp	wa, (xbc-4)                                  ; F8DA53  99 fc f0
	jr z, .LF8DA6A                                       ; F8DA56  66 12
	ld	xiy, (xbc+wa)                                ; F8DA58  e3 07 e4 e0 25
	minc4_16 wa, 0x01fc                                  ; F8DA5D  d8 3a fc 01
	ld (xbc-8), wa                                       ; F8DA61  b9 f8 50
	incw 0x04, (xbc-2)                                   ; F8DA64  99 fe 64
.LF8DA67:
	ei 0x00                                              ; F8DA67  06 00
	ret                                                  ; F8DA69  0e
.LF8DA6A:
	xor XIY,XIY                                          ; F8DA6A  ed d5
	dec 1,XIY                                            ; F8DA6C  ed 69
	jr .LF8DA67                                          ; F8DA6E  68 f7
; ---------------------------------------------------------------------
; CallbackQueue_Init -- empty the queue
;
; Called from: CallbackQueue_ResetAndRestartTask2, by `calr`, and nothing else.
; Inputs:  none.
; Outputs: read and write indices zeroed, free count seeded with 0x01FF.
; Evidence: three stores through XBC = 0x00600416 at -8, -4 and -2.  The seed
;          0x01FF is capacity-1 for a 0x200-byte ring, the same rule
;          Ring_Init_0200 follows at 0xF84291.
; ---------------------------------------------------------------------
CallbackQueue_Init:
	ld XBC,0x00600416                                    ; F8DA70  41 16 04 60 00
	xor WA,WA                                            ; F8DA75  d8 d0
	ld (xbc-8), wa                                       ; F8DA77  b9 f8 50
	ld (xbc-4), wa                                       ; F8DA7A  b9 fc 50
	ldw	(xbc-2), 0x01ff                              ; F8DA7D  b9 fe 02 ff 01
	ret                                                  ; F8DA82  0e
; ---------------------------------------------------------------------
; CallbackQueue_ResetAndRestartTask2 -- throw the queue away and restart its task
;
; Called from: directory slot T_CallbackQueue_ResetAndRestartTask2 (T_F42E80), reference upper bound 141.
; Inputs:  none.
; Outputs: the queue empty, semaphore 1 drained to zero, and task 2 started
;          again from its entry record.
; Evidence: every step is a kernel call through a slot this tree has already
;          identified (notes/FINDINGS-prom_a-kernel-lifecycle.md, and the slot
;          targets are in prom_b's directory):
;            calr CallbackQueue_Init
;            A=4, A=2  -> 0xF42D90 = 0xF85A96  Kernel_SemaWait   (take two locks)
;            A=2       -> 0xF42DA8 = 0xF85E5E, the entry the kernel note lists
;                         as a writer of state 0 -- "not live" -- so this stops
;                         task 2
;            A=4, A=2  -> 0xF42D88 = 0xF859AE  Kernel_SemaSignal (release them)
;            loop      -> 0xF42DD8 = 0xF85AEF  Kernel_SemaTryWait on semaphore 1,
;                         repeated while it succeeds: a DRAIN.  Try-wait answers
;                         0xFFFF when the count is already zero, and the loop's
;                         `cp WA,0xffff / jr NZ` is exactly that test
;            A=2       -> 0xF42D6C = 0xF857D9  Kernel_StartTask
;          Semaphores 2 and 4 are the two that
;          notes/FINDINGS-prom_a-kernel-lifecycle.md §5.2 shows starting at 1 in
;          the ROM image at 0xF85EBA -- the two binary semaphores -- which is
;          what a pair of locks looks like.
; Unknown: what 0xF85E5E does beyond writing state 0 is not converted yet, so
;          "stops task 2" rests on the kernel note's state-byte table, not on
;          the routine's own text.
; ---------------------------------------------------------------------
CallbackQueue_ResetAndRestartTask2:
	calr CallbackQueue_Init                              ; F8DA83  1e ea ff
	ld a, 0x04:opc                                          ; F8DA86  21 04
	call T_Kernel_SemaWait                               ; F8DA88  1d 90 2d f4
	ld a, 0x02:opc                                          ; F8DA8C  21 02
	call T_Kernel_SemaWait                               ; F8DA8E  1d 90 2d f4
	ld a, 0x02:opc                                          ; F8DA92  21 02
	call T_Kernel_KillTask                                        ; F8DA94  1d a8 2d f4
	ld a, 0x04:opc                                          ; F8DA98  21 04
	call T_Kernel_SemaSignal                             ; F8DA9A  1d 88 2d f4
	ld a, 0x02:opc                                          ; F8DA9E  21 02
	call T_Kernel_SemaSignal                             ; F8DAA0  1d 88 2d f4
.LF8DAA4:
	pushw 0x01                                           ; F8DAA4  0b 01 00
	call T_Kernel_SemaTryWait                            ; F8DAA7  1d d8 2d f4
	inc 2,XSP                                            ; F8DAAB  ef 62
	cp WA,0xffff                                         ; F8DAAD  d8 cf ff ff
	jr nz, .LF8DAA4                                      ; F8DAB1  6e f1
	ld a, 0x02:opc                                          ; F8DAB3  21 02
	call T_Kernel_StartTask                              ; F8DAB5  1d 6c 2d f4
	ret                                                  ; F8DAB9  0e

; 0xF8DABA-0xF8DBFF -- 326 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 326, 1, 0x0E
