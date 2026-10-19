; ============================================================================
; debugger_memdump.asm -- Technics SX-KN7000 hidden factory debugger:
;                         the MEMORY DUMP hex viewer
;
; Panasonic MN10300/AM33.  Bytes are from baserom/kn7000_program.rom
; (PROGRAM 941); program-flash file offset = CPU address - 0x48400000.
; Disassembly by MAME unidasm -arch mn10300, with unidasm's F4-page length bug
; repaired from the ROM bytes exactly as tools/gen_program_s.py does.
;
; This listing is byte-exact: every "addr: bytes" pair below was read straight
; out of the image, and tools/verify_listing.py re-checks the whole file
; against the ROM.  Only the labels and comments are interpretation.
;
; WHAT THIS SCREEN IS
;   Holding UP+DOWN together on balance columns 1, 4, 5 and 8 makes the
;   index-switch handler's accumulator at 0x50021FE0 equal 0x99, and
;   IndexSwChordDispatch (below) opens title _TT_MEMDUMP (0xF2) -- a 16 x 16
;   hex viewer over the CPU address space, with an ASCII column, four
;   user-settable byte highlights and four independent address slots.
;
; ROUTINE MAP
;   0x484148C0  IndexSwChordDispatch    the 0x99 / 0xA1 / 0x110000 chord test
;   0x484D7928  GetRomConfigByte        *(0x4840000F), the gate
;   0x484878AC  DbMemoryDumpProc        window proc: prologue + hash dispatch
;   0x48487903    DbMemDumpEvShow       EV_SHOW      cold init + timer flush
;   0x48487993    DbMemDumpEvHide       EV_HIDE      conditional timer kill
;   0x484879EC    DbMemDumpMtDraw       MT_Draw      background + start repaint
;   0x48487A28    DbMemDumpMtSeleDraw   MT_SeleDraw  repaint tick, re-arms 0x78
;   0x48487A58    DbMemDumpMtParaDraw   MT_ParaDraw  THE renderer
;   0x48487E00    DbMemDumpEvIamSelected EV_IAMSELECTED  selection latch
;   0x48487E60    DbMemDumpEvIndexSw    EV_INDEXSW_UP/DOWN  the editor
;   0x48487FA7    DbMemDumpEvMemdump    EV_MEMDUMP   kick the repaint cycle
;   0x48487FBC    DbMemDumpMtGetColor   MT_GetColor  byte -> palette index
;   0x48487FEA    DbMemDumpDefault      base-class fallthrough
;   0x48456EBB  func_48456EBB           provides ADR3's 0x501A5920 default
;   0x4841005C  DataSectionCopy         boot .data copy (the power-on values)
;
; STATE (all in work RAM; every reference in the whole image is inside
; DbMemoryDumpProc -- verified by a byte scan for each absolute address)
;   0x500012EC  uint32 ADR[0..3]          the four inspected addresses
;   0x500012FC  int16  HighlightByte[0..3] -1 = off, else 0x00..0xFF
;   0x50001304  uint32 ColdFlag            1 from .data, cleared by EV_SHOW
;   0x5006B524  uint16 SlotIndex           0..3, which ADR is displayed
;   0x5006B528  uint32 SelectLatch         EV_IAMSELECTED group-8 toggle
;
; READ-ONLY: once a2 holds the inspected row address (set at 0x48487B1C),
; every access through it is a load -- "movbu (dN,a2), dM" at 0x48487B8C,
; 0x48487B97, 0x48487C5A, 0x48487C67 and 0x48487C6C, and nothing else.  Every
; store in the whole proc targets the stack frame or the five cells above.
; (The one other a2 use, 0x48487AB4, is a2 = &view.rect during layout.)
;
; See kn7000_mame/notes/FINDINGS-kn7000-debug-screens.md for the runtime
; behaviour (chord constants, measured panel-column mapping, hazards).
; ============================================================================

; ============================================================================
; Static data used by the viewer  (program flash, region 0x485Dxxxx)
; ============================================================================

; ---- DbMemDumpLegendColors: five palette indices, four legend labels -------
; The fifth entry is the fall-through colour returned by MT_GetColor when a
; byte matches none of the four highlights.
485d6708: fe 00                 .short  0x00FE          ; [0] CL_Aqua
485d670a: fb 00                 .short  0x00FB          ; [1] CL_Yellow
485d670c: fa 00                 .short  0x00FA          ; [2] CL_Lime
485d670e: fd 00                 .short  0x00FD          ; [3] CL_Fuchsia
485d6710: f7 00                 .short  0x00F7          ; [4] CL_Transparent (no match)
485d6712: ff ff                 .short  0xFFFF          ; padding

; ---- format strings -------------------------------------------------------
485d6714: 25 30 34 58 25 30 34 58 20 20 00   .asciz "%04X%04X  "   ; row address
485d6720: 25 30 32 58 00        .asciz  "%02X"          ; hex cell
485d6728: 2d 00                 .asciz  "-"             ; hex mid separator
485d672c: 20 00                 .asciz  " "             ; hex cell separator
485d6730: 20 00                 .asciz  " "             ; hex block -> ASCII gap
485d6734: 2d 00                 .asciz  "-"             ; ASCII mid separator
485d6738: 41 71 75 61 00        .asciz  "Aqua"
485d673d: 59 65 6c 6c 6f 77 00  .asciz  "Yellow"
485d6744: 4c 69 6d 65 00        .asciz  "Lime"
485d6749: 46 75 63 68 73 69 61 00   .asciz "Fuchsia"

; ---- DbMemDumpLegendNames: index-parallel with DbMemDumpLegendColors ------
485d6754: 38 67 5d 48           .long   0x485D6738      ; "Aqua"
485d6758: 3d 67 5d 48           .long   0x485D673D      ; "Yellow"
485d675c: 44 67 5d 48           .long   0x485D6744      ; "Lime"
485d6760: 49 67 5d 48           .long   0x485D6749      ; "Fuchsia"

485d6764: 20 25 73 20 3d 20 25 30 32 58 20 20 00   .asciz " %s = %02X  "
485d6774: 20 25 73 20 3d 20 58 58 20 20 00   .asciz " %s = XX  "
485d6780: 20 44 55 4d 50 20 41 44 52 25 64 20 3d 20 25 30 34 58 25 30 34 58 20 20 00   .asciz " DUMP ADR%d = %04X%04X  "

; ---- DbMemDumpEventTable: 16 open-addressed buckets, { key, handler } ------
; key = event id - 0x50000; bucket = key & 0xF, linear probe by 8 with wrap.
485d6830: 10 00 00 00 60 7e 48 48   .long   0x00000010, 0x48487E60   ; 0x50010 EV_INDEXSW_DOWN -> DbMemDumpEvIndexSw
485d6838: 01 00 00 00 03 79 48 48   .long   0x00000001, 0x48487903   ; 0x50001 EV_SHOW         -> DbMemDumpEvShow
485d6840: 02 00 00 00 93 79 48 48   .long   0x00000002, 0x48487993   ; 0x50002 EV_HIDE         -> DbMemDumpEvHide
485d6848: b2 00 01 00 ec 79 48 48   .long   0x000100B2, 0x484879EC   ; 0x600B2 MT_Draw         -> DbMemDumpMtDraw
485d6850: b3 00 01 00 28 7a 48 48   .long   0x000100B3, 0x48487A28   ; 0x600B3 MT_SeleDraw     -> DbMemDumpMtSeleDraw
485d6858: b4 00 01 00 58 7a 48 48   .long   0x000100B4, 0x48487A58   ; 0x600B4 MT_ParaDraw     -> DbMemDumpMtParaDraw
485d6860: 21 00 00 00 00 7e 48 48   .long   0x00000021, 0x48487E00   ; 0x50021 EV_IAMSELECTED  -> DbMemDumpEvIamSelected
485d6868: 33 00 00 00 a7 7f 48 48   .long   0x00000033, 0x48487FA7   ; 0x50033 EV_MEMDUMP      -> DbMemDumpEvMemdump
485d6870: b0 00 01 00 bc 7f 48 48   .long   0x000100B0, 0x48487FBC   ; 0x600B0 MT_GetColor     -> DbMemDumpMtGetColor
485d6878: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty                   -> DbMemDumpDefault
485d6880: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty
485d6888: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty
485d6890: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty
485d6898: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty
485d68a0: 00 00 00 00 ea 7f 48 48   .long   0x00000000, 0x48487FEA   ; empty
485d68a8: 0f 00 00 00 60 7e 48 48   .long   0x0000000F, 0x48487E60   ; 0x5000F EV_INDEXSW_UP   -> DbMemDumpEvIndexSw

; ---- external helpers referenced above ------------------------------------
;   0x4842D91A  GetViewInstance     0x484261A1  DrawDesignBox
;   0x48425393  DrawString          0x48429564  InheritedProc
;   0x48429388  SendEvent           0x48429C95  SetApTimer
;   0x48429FD0  KillApTimer         0x4841773B  SetAutoInc
;   0x4842B49B  InterruptTitle      0x4842B343  ChangeMode
;   0x4842989B  ApPostEvent         0x4841567D  CaptureLcd
;   0x4C001A48  sprintf (library window; program flash 0x487BAA19)
;   0x4C0032F7  strlen  (library window; program flash 0x487BC2C8)


; ----------------------------------------------------------------------------
; IndexSwChordDispatch -- the hidden-chord test, inline in the balance-button
;                        (index-switch) handler
;
; Purpose : after every balance UP/DOWN event the handler recomputes the
;           both-buttons-held accumulator at 0x50021FE0 (see 0x48414842);
;           this tail compares it against exactly three magic constants and
;           opens a hidden factory screen on a match.  Bit N of the
;           accumulator is balance column N+1 (index->mask table 0x4859E1A0
;           is a plain 1 << N).  The test is an EQUALITY, so one extra held
;           column silently kills the chord.
; Inputs  : (0x50021FE0) = columns with BOTH buttons held
; Outputs : none (opens a title); falls through to the handler's epilogue
; Callers : reached by fall-through from 0x48414885 / 0x48414896 /
;           0x484148B0 / 0x484148B9 inside the index-switch handler that
;           begins at 0x48414735.  There is no other comparison site: a byte
;           scan for the absolute address 0x50021FE0 over the whole 4 MB image
;           finds five references and no more -- 0x48414844 and 0x4841485A
;           (the accumulator rebuild at 0x48414842) and 0x484148C2 (the read
;           below), plus two plain STORES that reset it to zero,
;           "mov d0, (0x50021fe0)" at 0x48414C05 and 0x48414CA8.
; ----------------------------------------------------------------------------
IndexSwChordDispatch:
484148c0: fc a4 e0 1f 02 50     mov     (0x50021fe0), d0
484148c6: fa c8 99 00           cmp     0x99, d0                              ; 0x99 = columns 1,4,5,8  -> MEMORY DUMP
484148ca: c8 12                 beq     0x484148dc
484148cc: fa c8 a1 00           cmp     0xa1, d0                              ; 0xA1 = columns 1,6,8    -> SOFT VERSION
484148d0: c8 49                 beq     0x48414919
484148d2: fc c8 00 00 11 00     cmp     0x110000, d0                          ; LCD soft-key rows 1+5   -> screen capture
484148d8: c8 4e                 beq     0x48414926
484148da: ca 5f                 bra     0x48414939                            ; no chord: fall through to the epilogue
; --- 0x99: gated.  Config byte 0xFF -> Panel Simulator, else hex viewer.
484148dc: dd 4c 30 0c 00 00 00  call    0x484d7928, 0, 0                      ; d0 = *(0x4840000F)
484148e3: 14                    extbu   d0
484148e4: fa c8 ff 00           cmp     0xff, d0
484148e8: c9 0d                 bne     0x484148f5
484148ea: 00                    clr     d0
484148eb: 04                    clr     d1
484148ec: dd 5c 6a 01 00 e0 20  call    0x4842b348, [d2,d3,a2], 0x20          ; ChangeMode(0, 0) -> Panel Simulator 2.1
484148f3: ca 46                 bra     0x48414939
484148f5: 2c f2 00              mov     0xf2, d0                              ; _TT_MEMDUMP
484148f8: 04                    clr     d1
484148f9: dd a7 6b 01 00 e0 20  call    0x4842b4a0, [d2,d3,a2], 0x20          ; InterruptTitle(0xF2, 0)
48414900: 80 01                 mov     1, d0
48414902: 42 10                 mov     d0, (0x10, sp)
48414904: fc cc f2 00 0f 00     mov     0x000f00f2, d0                        ; object 0x000F00F2
4841490a: fc cd a4 00 06 00     mov     0x000600a4, d1                        ; MT_SetKeep
48414910: dd 90 4f 01 00 80 1c  call    0x484298a0, [d2], 0x1c                ; ApPostEvent(obj, MT_SetKeep, 1)
48414917: ca 22                 bra     0x48414939
; --- 0xA1: ungated.
48414919: 2c f0 00              mov     0xf0, d0                              ; _TT_SOFTVER
4841491c: 04                    clr     d1
4841491d: dd 83 6b 01 00 e0 20  call    0x4842b4a0, [d2,d3,a2], 0x20          ; InterruptTitle(0xF0, 0)
48414924: ca 15                 bra     0x48414939
; --- 0x110000: inverse gate -- needs the config byte to BE 0xFF, so LCD
;     capture is dead on a PROGRAM 941 image (its byte is 0x16).
48414926: dd 02 30 0c 00 00 00  call    0x484d7928, 0, 0                      ; GetRomConfigByte
4841492d: 14                    extbu   d0
4841492e: fa c8 ff 00           cmp     0xff, d0
48414932: c9 07                 bne     0x48414939
48414934: cd 4c 0d 00 08        call    0x48415680, 0, 8                      ; CaptureLcd() -> LCDCAP%02d.BMP
48414939: df f0 28              ret     [d2,d3,a2,a3], 0x28

; ----------------------------------------------------------------------------
; GetRomConfigByte -- read the lone configuration byte in the flash header
;
; Purpose : returns *(uint8*)0x4840000F.  In the PROGRAM 941 image the boot
;           header reads DC 7E FF 00 00 CB CB CB CB CB DC C5 77 0D 00 **16**,
;           so this returns 0x16.  The same byte is compared against 0x77 at
;           0x484A508C, so it is a configuration/destination code, not a
;           debug-only flag.
; Inputs  : none          Outputs: d0 = the byte (zero extended)
; Callers : exactly six, found by decoding every call displacement in the
;           image: 0x484148DC and 0x48414926 (the two gated chords below),
;           0x48414A27, 0x48488829, 0x4848A8E1 and 0x484A5084 (the 0x77 test).
; ----------------------------------------------------------------------------
GetRomConfigByte:
484d7928: fc a8 0f 00 40 48     movbu   (0x4840000f), d0
484d792e: de 00 00              retf    0, 0

; ============================================================================
; DbMemoryDumpProc -- window procedure of the MEMORY DUMP hex viewer
;
; Purpose : the whole viewer.  Paints a 16 x 16 hex dump with an ASCII column
;           and a four-entry colour legend, edits the inspected address one
;           hex digit at a time from the balance (index-switch) rockers, and
;           keeps four independent address slots.
; Inputs  : d0        = self (MILK object id)
;           d1        = event id  (0x00050001 .. 0x000600B4)
;           (0x10,sp) = event parameter   [reached as (0x9C,sp) inside]
; Outputs : d0 = 0 for every handler except MT_GetColor, which returns a
;           palette index.
; Callers : the MILK event dispatcher.  The proc is entry 1 of the 24-byte
;           class-descriptor array at 0x487424A0 (friendly name
;           "DbMemoryDump" @0x485D592C) and entry 1 of the class-0x11
;           instance-proc array at 0x487425FC (reflection name
;           "DbMemoryDumpProc" @0x485D59E3).  The screen is reached as title
;           _TT_MEMDUMP (id 0xF2, registered at 0x484875E5, root object
;           0x00100015 whose template at 0x485D5EF8 carries the caption
;           "MEMORY DUMP" @0x485D5F28).
;
; Frame   : movm pushes 0x10, then -0x7C  =>  0x8C.  Caller argument home
;           slots therefore land at (0x94,sp) = arg0 and (0x9C,sp) = arg2.
;           Locals used by the painter:
;             (0x20,sp) char/str buffer ptr   (0x24,sp) row counter
;             (0x28,sp) &rect                 (0x2C,sp) &point
;             (0x30,sp) rect.x0  (0x32) rect.y0  (0x34) rect.x1  (0x36) rect.y1
;             (0x38,sp) pen.x    (0x3A) pen.y
;             (0x3C,sp) sprintf scratch buffer
;
; The event ids are the firmware's own EV_*/MT_* enumeration: the name table
; at 0x485B25FC is index-parallel with the pointer array at 0x48726BF0 (1275
; entries).  An event id's class is its high halfword and its ordinal the low
; one; class 0x0005 indexes the array from entry 0 (EV_NONE .. EV_SWIN_MODE,
; entries 0..59) and class 0x0006 from entry **61**, the first MT_ name --
; entry 60 is a NUL separator between the two runs, so the rule is
; index = 61 + ordinal, NOT 60 + ordinal.
; That mapping is self-checking three ways: 0x5001E decodes to EV_AUTOINC and
; is the very constant SetAutoInc tests at 0x48417763; 0x50033 decodes to
; EV_MEMDUMP, which is this viewer's own event; and 0x600B0 decodes to
; MT_GetColor and lands exactly on the handler that maps a byte to a colour.
; ============================================================================

; --- prologue + range check ---
DbMemoryDumpProc:
484878ac: cf f0                 movm    [d2,d3,a2,a3], (sp)
484878ae: f8 fe 84              add     -0x7c, sp
484878b1: 42 94                 mov     d0, (0x94, sp)
484878b3: f1 e7                 mov     d1, a3
484878b5: fc db 01 00 05 00     cmp     0x50001, a3                           ; EV_SHOW
484878bb: c2 05                 bge     0x484878c0
484878bd: cc 2d 07              jmp     0x48487fea
484878c0: fc db b4 00 06 00     cmp     0x600b4, a3                           ; MT_ParaDraw
484878c6: c3 05                 ble     0x484878cb
484878c8: cc 22 07              jmp     0x48487fea
; --- open-addressed hash dispatch on (event - 0x50000) ---
;     16 buckets of 8 bytes at DbMemDumpEventTable; bucket = key & 0xF,
;     linear probe by 8 with wrap at 0x485D68B0, stop on match or on an
;     empty (key == 0) slot.
484878cb: 80 0f                 mov     0xf, d0                               ; bucket mask
484878cd: fc cd 00 00 fb ff     mov     0xfffb0000, d1                        ; -0x50000
484878d3: f1 5d                 add     a3, d1
484878d5: f2 04                 and     d1, d0
484878d7: f8 c0 03              asl     3, d0                                 ; * 8
484878da: f1 e0                 mov     d0, a0
484878dc: fc dd 30 68 5d 48     mov     0x485d6830, a1                        ; DbMemDumpEventTable
484878e2: f1 74                 add     a1, a0
484878e4: 70                    mov     (a0), d0
484878e5: a4                    cmp     d1, d0
484878e6: c8 18                 beq     0x484878fe
484878e8: db                    setlb   
484878e9: a0 00                 cmp     0, d0
484878eb: c9 05                 bne     0x484878f0
484878ed: cc fd 06              jmp     0x48487fea                            ; empty slot -> default handler
484878f0: 20 08                 add     8, a0
484878f2: fc d8 b0 68 5d 48     cmp     0x485d68b0, a0                        ; end of table?
484878f8: c4 03                 bcs     0x484878fb
484878fa: 94                    mov     a1, a0                                ; wrap to the first bucket
484878fb: 70                    mov     (a0), d0
484878fc: a4                    cmp     d1, d0
484878fd: d9                    lne     
484878fe: f8 20 04              mov     (4, a0), a0                           ; entry[1] = handler
48487901: f0 f4                 jmp     (a0)

; ---------------------------------------------------------------- EV_SHOW
; One-shot cold initialisation of the four address slots, then flush any
; MT_SeleDraw repaint timer left over from a previous visit.
;
; The cold flag at 0x50001304 is NOT bss: the boot loader at 0x4841005C
; copies 0x7F34 bytes of .data from ROM 0x487B0B78 to RAM 0x50000010, and
; the image of this widget's cells lives at ROM 0x487B1E54:
;     0x500012EC ADR0 = 0x84000000   0x500012F0 ADR1 = 0x50000000
;     0x500012F4 ADR2 = 0x4C000000   0x500012F8 ADR3 = 0x48400000
;     0x500012FC..0x50001303 highlight bytes = 00F0 00F7 00FF FFFF
;     0x50001304 cold flag = 1
; So the LINKED defaults are one address per memory region, but the first
; EV_SHOW overwrites three of them with the values below and clears the flag,
; which is why every unit shows 0x84000000 / 0x84000770 / 0x84000814 /
; 0x501A5920 the first time the screen is opened.  The highlight bytes are
; never touched here, so F0 / F7 / FF / XX come straight from ROM.
DbMemDumpEvShow:
48487903: fc a4 04 13 00 50     mov     (0x50001304), d0                      ; cold flag
48487909: a0 00                 cmp     0, d0
4848790b: c8 39                 beq     0x48487944
4848790d: fc cc 00 00 00 84     mov     0x84000000, d0                        ; ADR0 = ram44 alias base
48487913: fc 81 ec 12 00 50     mov     d0, (0x500012ec)
48487919: fa c0 70 07           add     0x770, d0                             ; ADR1 = 0x84000770
4848791d: fc 81 f0 12 00 50     mov     d0, (0x500012f0)
48487923: fc cc 14 08 00 84     mov     0x84000814, d0                        ; ADR2 = 0x84000814
48487929: fc 81 f4 12 00 50     mov     d0, (0x500012f4)
4848792f: 00                    clr     d0
48487930: dd 8b f5 fc ff 00 00  call    0x48456ebb, 0, 0                      ; func_48456EBB(0) -> 0x501A5920
48487937: fc 80 f8 12 00 50     mov     a0, (0x500012f8)                      ; ADR3 = sequencer song-slot 0 + 0x120
4848793d: 00                    clr     d0
4848793e: fc 81 04 13 00 50     mov     d0, (0x50001304)
; --- kill every pending MT_SeleDraw repaint timer (loop until none left) ---
48487944: 58 94                 mov     (0x94, sp), d0
48487946: 42 10                 mov     d0, (0x10, sp)
48487948: fc cc b3 00 06 00     mov     0x000600b3, d0                        ; MT_SeleDraw
4848794e: 42 14                 mov     d0, (0x14, sp)
48487950: 00                    clr     d0
48487951: 42 18                 mov     d0, (0x18, sp)
48487953: 59 94                 mov     (0x94, sp), d1
48487955: 80 78                 mov     0x78, d0                              ; timer period 0x78
48487957: dd 7e 26 fa ff f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30       ; KillApTimer(0x78, self, self, MT_SeleDraw, 0)
4848795e: a0 00                 cmp     0, d0
48487960: c8 20                 beq     0x48487980
48487962: 58 94                 mov     (0x94, sp), d0
48487964: 42 10                 mov     d0, (0x10, sp)
48487966: fc cc b3 00 06 00     mov     0x000600b3, d0
4848796c: 42 14                 mov     d0, (0x14, sp)
4848796e: 00                    clr     d0
4848796f: 42 18                 mov     d0, (0x18, sp)
48487971: 59 94                 mov     (0x94, sp), d1
48487973: 80 78                 mov     0x78, d0
48487975: dd 60 26 fa ff f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30       ; KillApTimer
4848797c: a0 00                 cmp     0, d0
4848797e: c9 e4                 bne     0x48487962
48487980: 5c 9c                 mov     (0x9c, sp), a0
48487982: f1 dd                 mov     a3, d1
48487984: 43 10                 mov     a0, (0x10, sp)
48487986: 58 94                 mov     (0x94, sp), d0
48487988: dd e1 1b fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, param)
4848798f: 00                    clr     d0
48487990: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ---------------------------------------------------------------- EV_HIDE
; Leaving the screen.  The repaint timer is only cancelled when the
; selection latch at 0x5006B528 is CLEAR; if the latch is set the 0x78-tick
; MT_SeleDraw timer survives the hide and keeps firing.  (Mechanism proven
; from the code; the intent behind the latch is inferred -- see
; DbMemDumpEvIamSelected.)
DbMemDumpEvHide:
48487993: fc a4 28 b5 06 50     mov     (0x5006b528), d0                      ; selection latch
48487999: a0 00                 cmp     0, d0
4848799b: c9 3e                 bne     0x484879d9
4848799d: 58 94                 mov     (0x94, sp), d0
4848799f: 42 10                 mov     d0, (0x10, sp)
484879a1: fc cc b3 00 06 00     mov     0x000600b3, d0
484879a7: 42 14                 mov     d0, (0x14, sp)
484879a9: 00                    clr     d0
484879aa: 42 18                 mov     d0, (0x18, sp)
484879ac: 59 94                 mov     (0x94, sp), d1
484879ae: 80 78                 mov     0x78, d0
484879b0: dd 25 26 fa ff f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30       ; KillApTimer(0x78, self, self, MT_SeleDraw, 0)
484879b7: a0 00                 cmp     0, d0
484879b9: c8 20                 beq     0x484879d9
484879bb: 58 94                 mov     (0x94, sp), d0
484879bd: 42 10                 mov     d0, (0x10, sp)
484879bf: fc cc b3 00 06 00     mov     0x000600b3, d0
484879c5: 42 14                 mov     d0, (0x14, sp)
484879c7: 00                    clr     d0
484879c8: 42 18                 mov     d0, (0x18, sp)
484879ca: 59 94                 mov     (0x94, sp), d1
484879cc: 80 78                 mov     0x78, d0
484879ce: dd 07 26 fa ff f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30       ; KillApTimer
484879d5: a0 00                 cmp     0, d0
484879d7: c9 e4                 bne     0x484879bb
484879d9: 5c 9c                 mov     (0x9c, sp), a0
484879db: f1 dd                 mov     a3, d1
484879dd: 43 10                 mov     a0, (0x10, sp)
484879df: 58 94                 mov     (0x94, sp), d0
484879e1: dd 88 1b fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc
484879e8: 00                    clr     d0
484879e9: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ---------------------------------------------------------------- MT_Draw
; Background pass: let the base class draw, stamp design box style 0xC5 in
; CL_Silver over the view rect (view instance + 0x0E), then start the
; repaint cycle by sending MT_SeleDraw to self.
DbMemDumpMtDraw:
484879ec: 5c 9c                 mov     (0x9c, sp), a0
484879ee: f1 dd                 mov     a3, d1
484879f0: 43 10                 mov     a0, (0x10, sp)
484879f2: 58 94                 mov     (0x94, sp), d0
484879f4: dd 75 1b fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, param)
484879fb: 58 94                 mov     (0x94, sp), d0
484879fd: dd 1d 5f fa ff 00 00  call    0x4842d91a, 0, 0                      ; GetViewInstance(self)
48487a04: 20 0e                 add     0xe, a0                               ; a0 = &view.rect
48487a06: 2c c5 00              mov     0xc5, d0                              ; design-box style 0xC5
48487a09: 85 07                 mov     7, d1                                 ; CL_Silver
48487a0b: dd 9b e7 f9 ff e0 20  call    0x484261a6, [d2,d3,a2], 0x20          ; DrawDesignBox
48487a12: 00                    clr     d0
48487a13: 42 10                 mov     d0, (0x10, sp)
48487a15: 58 94                 mov     (0x94, sp), d0
48487a17: fc cd b3 00 06 00     mov     0x000600b3, d1                        ; MT_SeleDraw
48487a1d: dd 70 19 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent
48487a24: 00                    clr     d0
48487a25: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ------------------------------------------------------------ MT_SeleDraw
; The repaint tick: redraw the contents (MT_ParaDraw) and re-arm a 0x78-tick
; timer that will deliver MT_SeleDraw again.  This is why the viewer re-reads
; the inspected address forever while the screen is up -- parking it on a
; volatile I/O window is a live hazard on real hardware.
DbMemDumpMtSeleDraw:
48487a28: 00                    clr     d0
48487a29: 42 10                 mov     d0, (0x10, sp)
48487a2b: 58 94                 mov     (0x94, sp), d0
48487a2d: fc cd b4 00 06 00     mov     0x000600b4, d1                        ; MT_ParaDraw
48487a33: dd 5a 19 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent
48487a3a: 58 94                 mov     (0x94, sp), d0
48487a3c: 42 10                 mov     d0, (0x10, sp)
48487a3e: fc cc b3 00 06 00     mov     0x000600b3, d0                        ; MT_SeleDraw
48487a44: 42 14                 mov     d0, (0x14, sp)
48487a46: 00                    clr     d0
48487a47: 42 18                 mov     d0, (0x18, sp)
48487a49: 59 94                 mov     (0x94, sp), d1
48487a4b: 80 78                 mov     0x78, d0
48487a4d: dd 4d 22 fa ff f0 34  call    0x48429c9a, [d2,d3,a2,a3], 0x34       ; SetApTimer(0x78, self, self, MT_SeleDraw, 0)
48487a54: 00                    clr     d0
48487a55: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ------------------------------------------------------------ MT_ParaDraw
; THE renderer.  Layout, in the view rect:
;   * a design box (style 0xC6, CL_Silver) inset 4 px on all sides;
;   * the text area inset 5 px; rows are 9 px apart, glyphs 6 px wide;
;   * 16 rows x { "%04X%04X  " address, 16 x "%02X" + separator, ' ',
;     16 x one ASCII character + separator };
;   * a trailer line: the four legend items, then the slot caption.
; Every byte is fetched with movbu (dN,a2) -- the viewer never writes to the
; inspected address.
DbMemDumpMtParaDraw:
48487a58: 58 94                 mov     (0x94, sp), d0
48487a5a: dd c0 5e fa ff 00 00  call    0x4842d91a, 0, 0                      ; GetViewInstance(self)
48487a61: 92                    mov     a0, a2
48487a62: 22 0e                 add     0xe, a2                               ; a2 = &view.rect
48487a64: 99                    mov     a2, a1
;     copy the view rect into the local rect at (0x30,sp)
48487a65: 3c                    mov     sp, a0
48487a66: 20 30                 add     0x30, a0
48487a68: 85 fc                 mov     -4, d1
48487a6a: db                    setlb   
48487a6b: f0 61                 movhu   (a1), d0
48487a6d: 21 02                 add     2, a1
48487a6f: f0 70                 movhu   d0, (a0)
48487a71: 20 02                 add     2, a0
48487a73: 44                    inc     d1
48487a74: d9                    lne     
;     inset by 4 and draw the frame
48487a75: 3c                    mov     sp, a0
48487a76: f1 d0                 mov     a0, d0
48487a78: 28 30                 add     0x30, d0
48487a7a: 42 28                 mov     d0, (0x28, sp)
48487a7c: f8 bc 32              movhu   (0x32, sp), d0
48487a7f: 85 07                 mov     7, d1
48487a81: 18                    exth    d0
48487a82: 28 04                 add     4, d0
48487a84: f8 93 32              movhu   d0, (0x32, sp)
48487a87: f8 bc 30              movhu   (0x30, sp), d0
48487a8a: 18                    exth    d0
48487a8b: 28 04                 add     4, d0
48487a8d: f8 93 30              movhu   d0, (0x30, sp)
48487a90: f8 bc 34              movhu   (0x34, sp), d0
48487a93: 18                    exth    d0
48487a94: 28 fc                 add     -4, d0
48487a96: f8 93 34              movhu   d0, (0x34, sp)
48487a99: f8 bc 36              movhu   (0x36, sp), d0
48487a9c: 18                    exth    d0
48487a9d: 28 fc                 add     -4, d0
48487a9f: f8 93 36              movhu   d0, (0x36, sp)
48487aa2: 5c 28                 mov     (0x28, sp), a0
48487aa4: 2c c6 00              mov     0xc6, d0                              ; design-box style 0xC6
48487aa7: dd ff e6 f9 ff e0 20  call    0x484261a6, [d2,d3,a2], 0x20          ; DrawDesignBox
;     re-copy the rect and inset by 5 -> the text clip rect
48487aae: 3c                    mov     sp, a0
48487aaf: 20 30                 add     0x30, a0
48487ab1: 85 fc                 mov     -4, d1
48487ab3: db                    setlb   
48487ab4: f0 62                 movhu   (a2), d0
48487ab6: 22 02                 add     2, a2
48487ab8: f0 70                 movhu   d0, (a0)
48487aba: 20 02                 add     2, a0
48487abc: 44                    inc     d1
48487abd: d9                    lne     
48487abe: f8 bc 32              movhu   (0x32, sp), d0
48487ac1: 3f                    mov     sp, a3                                ; a3 = &pen
48487ac2: 18                    exth    d0
48487ac3: 28 05                 add     5, d0
48487ac5: f8 93 32              movhu   d0, (0x32, sp)
48487ac8: f8 bc 30              movhu   (0x30, sp), d0
48487acb: 23 38                 add     0x38, a3
48487acd: 18                    exth    d0
48487ace: 28 05                 add     5, d0
48487ad0: f8 93 30              movhu   d0, (0x30, sp)
48487ad3: f8 bc 34              movhu   (0x34, sp), d0
48487ad6: 3c                    mov     sp, a0
48487ad7: 18                    exth    d0
48487ad8: 28 fb                 add     -5, d0
48487ada: f8 93 34              movhu   d0, (0x34, sp)
48487add: f8 bc 36              movhu   (0x36, sp), d0
48487ae0: 18                    exth    d0
48487ae1: 28 fb                 add     -5, d0
48487ae3: f8 93 36              movhu   d0, (0x36, sp)
48487ae6: f1 d0                 mov     a0, d0                                ; (0x20,sp) = &scratch buffer
48487ae8: 28 3c                 add     0x3c, d0
48487aea: 42 20                 mov     d0, (0x20, sp)
48487aec: 00                    clr     d0                                    ; row = 0
48487aed: 42 24                 mov     d0, (0x24, sp)
;     --- per row: pen = (rect.x0, rect.y0 + row*9 + 1) ---
DbMemDumpRowLoop:
48487aef: 58 24                 mov     (0x24, sp), d0
48487af1: f8 bd 32              movhu   (0x32, sp), d1
48487af4: 8a 09                 mov     9, d2                                 ; row pitch = 9 px
48487af6: 19                    exth    d1
48487af7: cb                    nop     
48487af8: cb                    nop     
48487af9: f2 48                 mul     d2, d0
48487afb: e1                    add     d0, d1
48487afc: f8 bc 30              movhu   (0x30, sp), d0
48487aff: 44                    inc     d1
48487b00: f8 97 3a              movhu   d1, (0x3a, sp)
48487b03: f8 93 38              movhu   d0, (0x38, sp)
48487b06: fc ac 24 b5 06 50     movhu   (0x5006b524), d0                      ; slot index 0..3
48487b0c: 59 24                 mov     (0x24, sp), d1
48487b0e: 54                    asl2    d0
48487b0f: fc dc ec 12 00 50     mov     0x500012ec, a0                        ; ADR[] base
48487b15: f3 00                 mov     (d0, a0), d0
48487b17: f8 c1 04              asl     4, d1                                 ; row * 16
48487b1a: f1 e6                 mov     d1, a2
48487b1c: f1 62                 add     d0, a2
48487b1e: fc da f0 ff ff bf     cmp     0xbffffff0, a2                        ; keep the whole row below 0xC0000000
48487b24: c4 0c                 bcs     0x48487b30
48487b26: f1 d8                 mov     a2, d0
48487b28: fc e0 ff ff ff 0f     and     0x0fffffff, d0                        ; wrap into 0x0xxxxxxx
48487b2e: f1 e2                 mov     d0, a2
48487b30: 58 20                 mov     (0x20, sp), d0
48487b32: f1 d9                 mov     a2, d1
48487b34: 42 08                 mov     d0, (8, sp)
48487b36: 1d                    exthu   d1
48487b37: fc cc 14 67 5d 48     mov     0x485d6714, d0                        ; "%04X%04X  "
48487b3d: 42 0c                 mov     d0, (0xc, sp)
48487b3f: f1 d8                 mov     a2, d0
48487b41: f8 c4 10              lsr     16, d0
48487b44: 1c                    exthu   d0
48487b45: 42 10                 mov     d0, (0x10, sp)
48487b47: 46 14                 mov     d1, (0x14, sp)
48487b49: dd ff 9e b7 03 20 20  call    0x4c001a48, [a2], 0x20                ; sprintf(buf, fmt, hi16, lo16)
48487b50: 58 20                 mov     (0x20, sp), d0
48487b52: 9d                    mov     a3, a1
48487b53: 42 10                 mov     d0, (0x10, sp)
48487b55: 2c f7 00              mov     0xf7, d0                              ; CL_Transparent
48487b58: 42 1c                 mov     d0, (0x1c, sp)
48487b5a: 5c 28                 mov     (0x28, sp), a0
48487b5c: 80 03                 mov     3, d0
48487b5e: 04                    clr     d1
48487b5f: dd 39 d8 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString(3, 0, &rect, &pen, buf, CL_Transparent)
48487b66: 5c 20                 mov     (0x20, sp), a0
48487b68: dd 8f b7 b7 03 00 00  call    0x4c0032f7, 0, 0                      ; strlen(buf)
48487b6f: f8 bd 38              movhu   (0x38, sp), d1
48487b72: 8a 06                 mov     6, d2                                 ; glyph width = 6 px
48487b74: 19                    exth    d1
48487b75: cb                    nop     
48487b76: cb                    nop     
48487b77: f2 58                 mulu    d2, d0
48487b79: e1                    add     d0, d1
48487b7a: f8 97 38              movhu   d1, (0x38, sp)
48487b7d: 08                    clr     d2                                    ; col = 0
48487b7e: 0c                    clr     d3
;     --- per byte: "%02X" in the colour MT_GetColor picks ---
DbMemDumpHexLoop:
48487b7f: 58 20                 mov     (0x20, sp), d0
48487b81: 1e                    exthu   d2
48487b82: 42 08                 mov     d0, (8, sp)
48487b84: fc cc 20 67 5d 48     mov     0x485d6720, d0                        ; "%02X"
48487b8a: 42 0c                 mov     d0, (0xc, sp)
48487b8c: f4 0a                 movbu   (d2, a2), d0                          ; byte = *(addr + col)   -- a READ of target memory
48487b8e: 42 10                 mov     d0, (0x10, sp)
48487b90: dd b8 9e b7 03 20 20  call    0x4c001a48, [a2], 0x20                ; sprintf
48487b97: f4 0a                 movbu   (d2, a2), d0
48487b99: fc cd b0 00 06 00     mov     0x000600b0, d1                        ; MT_GetColor
48487b9f: 42 10                 mov     d0, (0x10, sp)
48487ba1: 58 94                 mov     (0x94, sp), d0
48487ba3: dd ea 17 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent(self, MT_GetColor, byte) -> colour
48487baa: 59 20                 mov     (0x20, sp), d1
48487bac: 18                    exth    d0
48487bad: 46 10                 mov     d1, (0x10, sp)
48487baf: 42 1c                 mov     d0, (0x1c, sp)
48487bb1: 5c 28                 mov     (0x28, sp), a0
48487bb3: 9d                    mov     a3, a1
48487bb4: 80 03                 mov     3, d0
48487bb6: 04                    clr     d1
48487bb7: dd e1 d7 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString(...)
48487bbe: 5c 20                 mov     (0x20, sp), a0
48487bc0: dd 37 b7 b7 03 00 00  call    0x4c0032f7, 0, 0                      ; strlen
48487bc7: f8 bd 38              movhu   (0x38, sp), d1
48487bca: 8a 06                 mov     6, d2
48487bcc: 19                    exth    d1
48487bcd: cb                    nop     
48487bce: cb                    nop     
48487bcf: f2 58                 mulu    d2, d0
48487bd1: e1                    add     d0, d1
48487bd2: f8 97 38              movhu   d1, (0x38, sp)
;     separator after byte 7 (but not after byte 15)
48487bd5: 8c                    mov     d3, d0
48487bd6: f2 d0                 ext     d0
48487bd8: 85 08                 mov     8, d1
48487bda: f2 64                 div     d1, d0
48487bdc: f2 e0                 mov     mdr, d0
48487bde: a0 07                 cmp     7, d0
48487be0: c9 24                 bne     0x48487c04
48487be2: 8c                    mov     d3, d0
48487be3: 40                    inc     d0
48487be4: a0 10                 cmp     0x10, d0
48487be6: c8 1e                 beq     0x48487c04
48487be8: fc cc 28 67 5d 48     mov     0x485d6728, d0                        ; "-"
48487bee: 42 10                 mov     d0, (0x10, sp)
48487bf0: 2c f7 00              mov     0xf7, d0
48487bf3: 42 1c                 mov     d0, (0x1c, sp)
48487bf5: 5c 28                 mov     (0x28, sp), a0
48487bf7: 9d                    mov     a3, a1
48487bf8: 80 03                 mov     3, d0
48487bfa: 04                    clr     d1
48487bfb: dd 9d d7 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487c02: ca 1c                 bra     0x48487c1e
48487c04: fc cc 2c 67 5d 48     mov     0x485d672c, d0                        ; " "
48487c0a: 42 10                 mov     d0, (0x10, sp)
48487c0c: 2c f7 00              mov     0xf7, d0
48487c0f: 42 1c                 mov     d0, (0x1c, sp)
48487c11: 5c 28                 mov     (0x28, sp), a0
48487c13: 9d                    mov     a3, a1
48487c14: 80 03                 mov     3, d0
48487c16: 04                    clr     d1
48487c17: dd 81 d7 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487c1e: f8 bc 38              movhu   (0x38, sp), d0
48487c21: 4c                    inc     d3
48487c22: 18                    exth    d0
48487c23: 28 06                 add     6, d0
48487c25: f8 93 38              movhu   d0, (0x38, sp)
48487c28: 8e                    mov     d3, d2
48487c29: 1f                    exthu   d3
48487c2a: af 10                 cmp     0x10, d3                              ; 16 bytes per row
48487c2c: c2 05                 bge     0x48487c31
48487c2e: cc 51 ff              jmp     0x48487b7f
;     gap between the hex block and the ASCII block
48487c31: 9d                    mov     a3, a1
48487c32: fc cc 30 67 5d 48     mov     0x485d6730, d0                        ; " "
48487c38: 42 10                 mov     d0, (0x10, sp)
48487c3a: 2c f7 00              mov     0xf7, d0
48487c3d: 42 1c                 mov     d0, (0x1c, sp)
48487c3f: 5c 28                 mov     (0x28, sp), a0
48487c41: 80 03                 mov     3, d0
48487c43: 04                    clr     d1
48487c44: dd 54 d7 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487c4b: f8 bc 38              movhu   (0x38, sp), d0
48487c4e: 08                    clr     d2
48487c4f: 18                    exth    d0
48487c50: 28 06                 add     6, d0
48487c52: f8 93 38              movhu   d0, (0x38, sp)
48487c55: 00                    clr     d0
48487c56: f8 92 3d              movbu   d0, (0x3d, sp)                        ; buf[1] = NUL (once)
;     --- per byte: one ASCII glyph, '.' below 0x20 ---
DbMemDumpAsciiLoop:
48487c59: 1c                    exthu   d0
48487c5a: f4 12                 movbu   (d0, a2), d1                          ; byte = *(addr + col)   -- a READ of target memory
48487c5c: a5 20                 cmp     0x20, d1
48487c5e: c2 09                 bge     0x48487c67
48487c60: 85 2e                 mov     0x2e, d1                              ; '.'
48487c62: f8 96 3c              movbu   d1, (0x3c, sp)
48487c65: ca 07                 bra     0x48487c6c
48487c67: f4 12                 movbu   (d0, a2), d1
48487c69: f8 96 3c              movbu   d1, (0x3c, sp)
48487c6c: f4 02                 movbu   (d0, a2), d0
48487c6e: fc cd b0 00 06 00     mov     0x000600b0, d1                        ; MT_GetColor
48487c74: 42 10                 mov     d0, (0x10, sp)
48487c76: 58 94                 mov     (0x94, sp), d0
48487c78: dd 15 17 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent(self, MT_GetColor, byte) -> colour
48487c7f: 59 20                 mov     (0x20, sp), d1
48487c81: 18                    exth    d0
48487c82: 46 10                 mov     d1, (0x10, sp)
48487c84: 42 1c                 mov     d0, (0x1c, sp)
48487c86: 5c 28                 mov     (0x28, sp), a0
48487c88: 9d                    mov     a3, a1
48487c89: 80 03                 mov     3, d0
48487c8b: 04                    clr     d1
48487c8c: dd 0c d7 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487c93: f8 bc 38              movhu   (0x38, sp), d0
48487c96: 85 08                 mov     8, d1
48487c98: 18                    exth    d0
48487c99: 28 06                 add     6, d0
48487c9b: f8 93 38              movhu   d0, (0x38, sp)
;     separator after column 7 (but not after column 15)
48487c9e: 88                    mov     d2, d0
48487c9f: f2 d0                 ext     d0
48487ca1: f2 64                 div     d1, d0
48487ca3: f2 e0                 mov     mdr, d0
48487ca5: a0 07                 cmp     7, d0
48487ca7: c9 2b                 bne     0x48487cd2
48487ca9: 88                    mov     d2, d0
48487caa: 40                    inc     d0
48487cab: a0 10                 cmp     0x10, d0
48487cad: c8 25                 beq     0x48487cd2
48487caf: 9d                    mov     a3, a1
48487cb0: fc cc 34 67 5d 48     mov     0x485d6734, d0                        ; "-"
48487cb6: 42 10                 mov     d0, (0x10, sp)
48487cb8: 2c f7 00              mov     0xf7, d0
48487cbb: 42 1c                 mov     d0, (0x1c, sp)
48487cbd: 5c 28                 mov     (0x28, sp), a0
48487cbf: 80 03                 mov     3, d0
48487cc1: 04                    clr     d1
48487cc2: dd d6 d6 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487cc9: f8 bc 38              movhu   (0x38, sp), d0
48487ccc: 18                    exth    d0
48487ccd: 28 06                 add     6, d0
48487ccf: f8 93 38              movhu   d0, (0x38, sp)
48487cd2: 48                    inc     d2
48487cd3: 88                    mov     d2, d0
48487cd4: 1e                    exthu   d2
48487cd5: aa 10                 cmp     0x10, d2                              ; 16 columns
48487cd7: c2 04                 bge     0x48487cdb
48487cd9: ca 80                 bra     0x48487c59
48487cdb: 58 24                 mov     (0x24, sp), d0
48487cdd: 40                    inc     d0
48487cde: 1c                    exthu   d0
48487cdf: 42 24                 mov     d0, (0x24, sp)
48487ce1: a0 10                 cmp     0x10, d0                              ; 16 rows
48487ce3: c2 05                 bge     0x48487ce8
48487ce5: cc 0a fe              jmp     0x48487aef

;     --- trailer line: pen = (rect.x0, rect.y0 + 16*9 + 1) ---
;     four legend items " <name> = <XX> ", each drawn in its own colour;
;     a highlight value of -1 prints "XX" and can never match a byte.
DbMemDumpLegend:
48487ce8: 58 24                 mov     (0x24, sp), d0
48487cea: f8 bd 32              movhu   (0x32, sp), d1
48487ced: 3c                    mov     sp, a0
48487cee: 19                    exth    d1
48487cef: 8a 09                 mov     9, d2
48487cf1: cb                    nop     
48487cf2: cb                    nop     
48487cf3: f2 48                 mul     d2, d0
48487cf5: e1                    add     d0, d1
48487cf6: f8 bc 30              movhu   (0x30, sp), d0
48487cf9: 44                    inc     d1
48487cfa: f8 97 3a              movhu   d1, (0x3a, sp)
48487cfd: f8 93 38              movhu   d0, (0x38, sp)
48487d00: f1 d0                 mov     a0, d0
48487d02: 28 38                 add     0x38, d0
48487d04: 42 2c                 mov     d0, (0x2c, sp)
48487d06: f1 d1                 mov     a0, d1
48487d08: 29 3c                 add     0x3c, d1
48487d0a: 46 20                 mov     d1, (0x20, sp)
48487d0c: 00                    clr     d0
48487d0d: 0c                    clr     d3
48487d0e: fc df fc 12 00 50     mov     0x500012fc, a3                        ; &HighlightByte[0]
48487d14: 82                    mov     d0, d2
48487d15: 1e                    exthu   d2
48487d16: f1 e8                 mov     d2, a0
48487d18: f1 70                 add     a0, a0
48487d1a: f1 d0                 mov     a0, d0
48487d1c: f4 83                 movhu   (d0, a3), d0
48487d1e: 18                    exth    d0
48487d1f: a0 ff                 cmp     -1, d0                                ; -1 -> disabled
48487d21: c8 2a                 beq     0x48487d4b
48487d23: 5e 20                 mov     (0x20, sp), a2
48487d25: 89                    mov     d2, d1
48487d26: 4b 08                 mov     a2, (8, sp)
48487d28: 55                    asl2    d1
48487d29: fc cc 64 67 5d 48     mov     0x485d6764, d0                        ; " %s = %02X  "
48487d2f: 42 0c                 mov     d0, (0xc, sp)
48487d31: fc dc 54 67 5d 48     mov     0x485d6754, a0                        ; DbMemDumpLegendNames
48487d37: f3 04                 mov     (d1, a0), d0
48487d39: 42 10                 mov     d0, (0x10, sp)
48487d3b: 88                    mov     d2, d0
48487d3c: e0                    add     d0, d0
48487d3d: f4 83                 movhu   (d0, a3), d0
48487d3f: 18                    exth    d0
48487d40: 42 14                 mov     d0, (0x14, sp)
48487d42: dd 06 9d b7 03 20 20  call    0x4c001a48, [a2], 0x20                ; sprintf
48487d49: ca 28                 bra     0x48487d71
48487d4b: 5e 20                 mov     (0x20, sp), a2
48487d4d: fc cc 74 67 5d 48     mov     0x485d6774, d0                        ; " %s = XX  "
48487d53: 4b 08                 mov     a2, (8, sp)
48487d55: 42 0c                 mov     d0, (0xc, sp)
48487d57: 88                    mov     d2, d0
48487d58: 54                    asl2    d0
48487d59: fc dc 54 67 5d 48     mov     0x485d6754, a0
48487d5f: f3 00                 mov     (d0, a0), d0
48487d61: 42 10                 mov     d0, (0x10, sp)
48487d63: 88                    mov     d2, d0
48487d64: e0                    add     d0, d0
48487d65: f4 83                 movhu   (d0, a3), d0
48487d67: 18                    exth    d0
48487d68: 42 14                 mov     d0, (0x14, sp)
48487d6a: dd de 9c b7 03 20 20  call    0x4c001a48, [a2], 0x20                ; sprintf
48487d71: 88                    mov     d2, d0
48487d72: 4b 10                 mov     a2, (0x10, sp)
48487d74: e0                    add     d0, d0
48487d75: fc dc 08 67 5d 48     mov     0x485d6708, a0                        ; DbMemDumpLegendColors
48487d7b: f4 80                 movhu   (d0, a0), d0
48487d7d: 04                    clr     d1
48487d7e: 18                    exth    d0
48487d7f: 42 1c                 mov     d0, (0x1c, sp)
48487d81: 5c 28                 mov     (0x28, sp), a0
48487d83: 5d 2c                 mov     (0x2c, sp), a1
48487d85: 80 03                 mov     3, d0
48487d87: dd 11 d6 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString(...)
48487d8e: 98                    mov     a2, a0
48487d8f: dd 68 b5 b7 03 00 00  call    0x4c0032f7, 0, 0                      ; strlen
48487d96: f8 bd 38              movhu   (0x38, sp), d1
48487d99: 4c                    inc     d3
48487d9a: 19                    exth    d1
48487d9b: 8a 06                 mov     6, d2
48487d9d: cb                    nop     
48487d9e: cb                    nop     
48487d9f: f2 58                 mulu    d2, d0
48487da1: e1                    add     d0, d1
48487da2: f8 97 38              movhu   d1, (0x38, sp)
48487da5: 8c                    mov     d3, d0
48487da6: 1f                    exthu   d3
48487da7: af 03                 cmp     3, d3                                 ; four legend items
48487da9: c1 05                 bgt     0x48487dae
48487dab: cc 69 ff              jmp     0x48487d14

;     --- " DUMP ADR%d = %04X%04X  ", drawn in CL_FireRed at the end of the
;         same trailer line ---
DbMemDumpSlotCaption:
48487dae: 3c                    mov     sp, a0
48487daf: f1 d2                 mov     a0, d2
48487db1: 2a 3c                 add     0x3c, d2
48487db3: 4a 08                 mov     d2, (8, sp)
48487db5: fc cc 80 67 5d 48     mov     0x485d6780, d0                        ; " DUMP ADR%d = %04X%04X  "
48487dbb: 42 0c                 mov     d0, (0xc, sp)
48487dbd: fc ac 24 b5 06 50     movhu   (0x5006b524), d0
48487dc3: fc dc ec 12 00 50     mov     0x500012ec, a0
48487dc9: 42 10                 mov     d0, (0x10, sp)
48487dcb: fc ad 24 b5 06 50     movhu   (0x5006b524), d1
48487dd1: 84                    mov     d1, d0
48487dd2: 54                    asl2    d0
48487dd3: f3 00                 mov     (d0, a0), d0
48487dd5: 55                    asl2    d1
48487dd6: f8 c4 10              lsr     16, d0
48487dd9: 1c                    exthu   d0
48487dda: 42 14                 mov     d0, (0x14, sp)
48487ddc: f3 04                 mov     (d1, a0), d0
48487dde: 1c                    exthu   d0
48487ddf: 42 18                 mov     d0, (0x18, sp)
48487de1: dd 67 9c b7 03 20 20  call    0x4c001a48, [a2], 0x20                ; sprintf
48487de8: 4a 10                 mov     d2, (0x10, sp)
48487dea: 80 0a                 mov     0xa, d0                               ; CL_FireRed
48487dec: 42 1c                 mov     d0, (0x1c, sp)
48487dee: 5c 28                 mov     (0x28, sp), a0
48487df0: 5d 2c                 mov     (0x2c, sp), a1
48487df2: 80 03                 mov     3, d0
48487df4: 04                    clr     d1
48487df5: dd a3 d5 f9 ff f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30       ; DrawString
48487dfc: 00                    clr     d0
48487dfd: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; --------------------------------------------------------- EV_IAMSELECTED
; The framework broadcasts EV_IAMSELECTED to object -1 with the parameter
; packed as (group << 16) | index (idiom visible at 0x484197F1 and
; 0x4849ABED).  This viewer reacts only to group 8 and then TOGGLES the latch
; at 0x5006B528: 0 -> 1 on one notification, and on the next it clears the
; latch and re-broadcasts EV_INDEXSELECT(index) to object -1.
; The toggle and the re-broadcast are proven from the bytes; what selector
; group 8 denotes is not (the window template at 0x485D5EF8 holds an 8 at
; +0x0C, which is suggestive but unconfirmed).
DbMemDumpEvIamSelected:
48487e00: 5e 9c                 mov     (0x9c, sp), a2
48487e02: f1 dd                 mov     a3, d1
48487e04: 4b 10                 mov     a2, (0x10, sp)
48487e06: 58 94                 mov     (0x94, sp), d0
48487e08: dd 61 17 fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, param)
48487e0f: f1 d8                 mov     a2, d0
48487e11: f8 c4 10              lsr     16, d0                                ; d0 = param >> 16 = selector group
48487e14: fa e0 ff ff           and     0xffff, d0
48487e18: 1c                    exthu   d0
48487e19: a0 08                 cmp     8, d0                                 ; only group 8
48487e1b: c9 35                 bne     0x48487e50
48487e1d: fc a4 28 b5 06 50     mov     (0x5006b528), d0                      ; latch
48487e23: a0 00                 cmp     0, d0
48487e25: c8 1f                 beq     0x48487e44
48487e27: 00                    clr     d0
48487e28: fc 81 28 b5 06 50     mov     d0, (0x5006b528)
48487e2e: f1 d8                 mov     a2, d0
48487e30: 1c                    exthu   d0
48487e31: 42 10                 mov     d0, (0x10, sp)
48487e33: 80 ff                 mov     -1, d0                                ; broadcast target
48487e35: fc cd 13 00 05 00     mov     0x00050013, d1                        ; EV_INDEXSELECT
48487e3b: dd 52 15 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent(-1, EV_INDEXSELECT, index)
48487e42: ca 0a                 bra     0x48487e4c
48487e44: 80 01                 mov     1, d0
48487e46: fc 81 28 b5 06 50     mov     d0, (0x5006b528)
48487e4c: 00                    clr     d0
48487e4d: df f0 8c              ret     [d2,d3,a2,a3], 0x8c
48487e50: 4b 10                 mov     a2, (0x10, sp)
48487e52: 58 94                 mov     (0x94, sp), d0
48487e54: f1 dd                 mov     a3, d1
48487e56: dd 13 17 fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, param)
48487e5d: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ------------------------------- EV_INDEXSW_UP (0x5000F) / _DOWN (0x50010)
; The editor.  One handler for both directions; the event id alone selects
; add vs subtract.  Control index i = (0x9C,sp):
;   i = 0..7   address nibble: ADR[slot] +/- (1 << (4*i)).  i=0 is the
;              least-significant hex digit, i=7 the most significant, so the
;              on-screen digits read left to right as i = 7..0.  (The
;              measured panel mapping in FINDINGS-kn7000-debug-screens.md is
;              balance column 1 -> i=7 ... column 8 -> i=0.)
;   i = 8      no case: falls through to InheritedProc (inert)
;   i = 9..12  highlight byte 0..3, clamped to -1..0xFF (-1 shows as "XX")
;   i = 13     ADR slot selector, clamped to 0..3
;   otherwise  InheritedProc only
; After every accepted edit: MT_ParaDraw to self (instant redraw) and
; SetAutoInc(self, event, i) to arm the panel auto-repeat -- SetAutoInc
; (0x4841773B) only proceeds when the originating switch event is EV_SWIN /
; EV_SWON / EV_SWOFF / EV_AUTOINC, so holding the rocker repeats the step.
;
; Address clamp: after the edit, values >= 0xC0000000 are folded with
; & 0x0FFFFFFF.  Everything below that is dialable, including the whole
; program flash 0x48000000..0x487FFFFF, VRAM 0x9xxxxxxx and the I/O windows.
; No store in this handler touches the inspected address -- only ADR[],
; the highlight bytes and the slot index.
DbMemDumpEvIndexSw:
48487e60: 5e 9c                 mov     (0x9c, sp), a2                        ; a2 = control index
48487e62: ba 07                 cmp     7, a2                                 ; i <= 7 -> address digit
48487e64: c5 7a                 bhi     0x48487ede
48487e66: f1 d8                 mov     a2, d0
48487e68: 54                    asl2    d0
48487e69: 8f 01                 mov     1, d3                                 ; d3 = 1 << (4*i)
48487e6b: f2 93                 asl     d0, d3
48487e6d: fc db 10 00 05 00     cmp     0x50010, a3                           ; EV_INDEXSW_DOWN
48487e73: c9 1a                 bne     0x48487e8d
;     DOWN: ADR[slot] -= step
48487e75: fc ae 24 b5 06 50     movhu   (0x5006b524), d2
48487e7b: fc dc ec 12 00 50     mov     0x500012ec, a0
48487e81: 88                    mov     d2, d0
48487e82: 54                    asl2    d0
48487e83: f3 10                 mov     (d0, a0), d1
48487e85: 88                    mov     d2, d0
48487e86: f1 0d                 sub     d3, d1
48487e88: 54                    asl2    d0
48487e89: f3 50                 mov     d1, (d0, a0)
48487e8b: ca 17                 bra     0x48487ea2
;     UP: ADR[slot] += step
48487e8d: fc ae 24 b5 06 50     movhu   (0x5006b524), d2
48487e93: fc dc ec 12 00 50     mov     0x500012ec, a0
48487e99: 88                    mov     d2, d0
48487e9a: 54                    asl2    d0
48487e9b: f3 00                 mov     (d0, a0), d0
48487e9d: 89                    mov     d2, d1
48487e9e: ec                    add     d3, d0
48487e9f: 55                    asl2    d1
48487ea0: f3 44                 mov     d0, (d1, a0)
;     clamp
48487ea2: 88                    mov     d2, d0
48487ea3: 54                    asl2    d0
48487ea4: f3 00                 mov     (d0, a0), d0
48487ea6: fc c8 00 00 00 c0     cmp     0xc0000000, d0
48487eac: c4 0f                 bcs     0x48487ebb
48487eae: 88                    mov     d2, d0
48487eaf: 54                    asl2    d0
48487eb0: f3 00                 mov     (d0, a0), d0
48487eb2: 56                    asl2    d2
48487eb3: fc e0 ff ff ff 0f     and     0x0fffffff, d0
48487eb9: f3 48                 mov     d0, (d2, a0)
48487ebb: 00                    clr     d0
48487ebc: 42 10                 mov     d0, (0x10, sp)
48487ebe: 58 94                 mov     (0x94, sp), d0
48487ec0: fc cd b4 00 06 00     mov     0x000600b4, d1                        ; MT_ParaDraw
48487ec6: dd c7 14 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent(self, MT_ParaDraw, 0)
48487ecd: 4b 10                 mov     a2, (0x10, sp)
48487ecf: 58 94                 mov     (0x94, sp), d0
48487ed1: f1 dd                 mov     a3, d1
48487ed3: dd 6d f8 f8 ff f0 2c  call    0x48417740, [d2,d3,a2,a3], 0x2c       ; SetAutoInc(self, event, i)
48487eda: 00                    clr     d0
48487edb: df f0 8c              ret     [d2,d3,a2,a3], 0x8c
;     --- i = 9..12: highlight byte 0..3, range -1..0xFF ---
48487ede: ba 09                 cmp     9, a2
48487ee0: c4 68                 bcs     0x48487f48
48487ee2: ba 0c                 cmp     0xc, a2
48487ee4: c5 64                 bhi     0x48487f48
48487ee6: fc db 10 00 05 00     cmp     0x50010, a3                           ; EV_INDEXSW_DOWN
48487eec: c9 1f                 bne     0x48487f0b
48487eee: f1 d9                 mov     a2, d1
48487ef0: 29 f7                 add     -9, d1
48487ef2: e5                    add     d1, d1
48487ef3: f1 e4                 mov     d1, a0
48487ef5: fc d0 fc 12 00 50     add     0x500012fc, a0                        ; &HighlightByte[i-9]
48487efb: f0 60                 movhu   (a0), d0
48487efd: 18                    exth    d0
48487efe: a0 00                 cmp     0, d0                                 ; already -1 -> leave
48487f00: c0 27                 blt     0x48487f27
48487f02: f0 60                 movhu   (a0), d0
48487f04: 18                    exth    d0
48487f05: 28 ff                 add     -1, d0
48487f07: f0 70                 movhu   d0, (a0)
48487f09: ca 1e                 bra     0x48487f27
48487f0b: f1 d9                 mov     a2, d1
48487f0d: 29 f7                 add     -9, d1
48487f0f: e5                    add     d1, d1
48487f10: f1 e4                 mov     d1, a0
48487f12: fc d0 fc 12 00 50     add     0x500012fc, a0                        ; &HighlightByte[i-9]
48487f18: f0 60                 movhu   (a0), d0
48487f1a: 18                    exth    d0
48487f1b: fa c8 ff 00           cmp     0xff, d0                              ; already 0xFF -> leave
48487f1f: c2 08                 bge     0x48487f27
48487f21: f0 60                 movhu   (a0), d0
48487f23: 18                    exth    d0
48487f24: 40                    inc     d0
48487f25: f0 70                 movhu   d0, (a0)
48487f27: 00                    clr     d0
48487f28: 42 10                 mov     d0, (0x10, sp)
48487f2a: 58 94                 mov     (0x94, sp), d0
48487f2c: fc cd b4 00 06 00     mov     0x000600b4, d1                        ; MT_ParaDraw
48487f32: dd 5b 14 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent
48487f39: 4b 10                 mov     a2, (0x10, sp)
48487f3b: 58 94                 mov     (0x94, sp), d0
48487f3d: f1 dd                 mov     a3, d1
48487f3f: dd 01 f8 f8 ff f0 2c  call    0x48417740, [d2,d3,a2,a3], 0x2c       ; SetAutoInc(self, event, i)
48487f46: ca 52                 bra     0x48487f98
;     --- i = 13: ADR slot selector, range 0..3 ---
48487f48: ba 0d                 cmp     0xd, a2
48487f4a: c9 4e                 bne     0x48487f98
48487f4c: fc db 10 00 05 00     cmp     0x50010, a3                           ; EV_INDEXSW_DOWN
48487f52: c9 16                 bne     0x48487f68
48487f54: fc ac 24 b5 06 50     movhu   (0x5006b524), d0
48487f5a: a0 00                 cmp     0, d0
48487f5c: c3 1d                 ble     0x48487f79                            ; already 0
48487f5e: 28 ff                 add     -1, d0
48487f60: fc 83 24 b5 06 50     movhu   d0, (0x5006b524)
48487f66: ca 13                 bra     0x48487f79
48487f68: fc ac 24 b5 06 50     movhu   (0x5006b524), d0
48487f6e: a0 03                 cmp     3, d0
48487f70: c2 09                 bge     0x48487f79                            ; already 3
48487f72: 40                    inc     d0
48487f73: fc 83 24 b5 06 50     movhu   d0, (0x5006b524)
48487f79: 00                    clr     d0
48487f7a: 42 10                 mov     d0, (0x10, sp)
48487f7c: 58 94                 mov     (0x94, sp), d0
48487f7e: fc cd b4 00 06 00     mov     0x000600b4, d1                        ; MT_ParaDraw
48487f84: dd 09 14 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent
48487f8b: 4b 10                 mov     a2, (0x10, sp)
48487f8d: 58 94                 mov     (0x94, sp), d0
48487f8f: f1 dd                 mov     a3, d1
48487f91: dd af f7 f8 ff f0 2c  call    0x48417740, [d2,d3,a2,a3], 0x2c       ; SetAutoInc(self, event, i)
48487f98: 4b 10                 mov     a2, (0x10, sp)
48487f9a: 58 94                 mov     (0x94, sp), d0
48487f9c: f1 dd                 mov     a3, d1
48487f9e: dd cb 15 fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, i)
48487fa5: ca 54                 bra     0x48487ff9

; ------------------------------------------------------------- EV_MEMDUMP
; The firmware's own name for event 0x50033 (name table index 51).  Sent by
; the DEBUG TOOLS page / title machinery; all it does here is kick the
; MT_SeleDraw repaint cycle.
DbMemDumpEvMemdump:
48487fa7: 00                    clr     d0
48487fa8: 42 10                 mov     d0, (0x10, sp)
48487faa: 58 94                 mov     (0x94, sp), d0
48487fac: fc cd b3 00 06 00     mov     0x000600b3, d1                        ; MT_SeleDraw
48487fb2: dd db 13 fa ff c0 24  call    0x4842938d, [d2,d3], 0x24             ; SendEvent
48487fb9: 00                    clr     d0
48487fba: ca 3f                 bra     0x48487ff9

; ------------------------------------------------------------ MT_GetColor
; Byte -> palette index for both the hex and the ASCII column.
;
; Purpose : linear scan of the four highlight bytes; the first match returns
;           DbMemDumpLegendColors[i], no match falls out of the loop with
;           i = 4 and returns the FIFTH entry, CL_Transparent.  That fifth
;           entry is why the colour table has five words for four legend
;           labels.  A highlight of -1 is sign-extended before the compare
;           and can never equal a 0..255 byte, so "XX" really is off.
; Inputs  : (0x9C,sp) = the byte     Outputs: d0 = palette index
; Callers : DbMemDumpMtParaDraw, twice per byte (hex cell + ASCII cell)
DbMemDumpMtGetColor:
48487fbc: 08                    clr     d2
48487fbd: 00                    clr     d0
48487fbe: db                    setlb   
48487fbf: fc dc fc 12 00 50     mov     0x500012fc, a0                        ; &HighlightByte[0]
48487fc5: 89                    mov     d2, d1
48487fc6: 1d                    exthu   d1
48487fc7: e5                    add     d1, d1
48487fc8: f4 94                 movhu   (d1, a0), d1
48487fca: 5c 9c                 mov     (0x9c, sp), a0                        ; a0 = the byte under test
48487fcc: 19                    exth    d1
48487fcd: f1 a4                 cmp     d1, a0
48487fcf: c8 09                 beq     0x48487fd8
48487fd1: 82                    mov     d0, d2
48487fd2: 48                    inc     d2
48487fd3: 88                    mov     d2, d0
48487fd4: 1c                    exthu   d0
48487fd5: a0 03                 cmp     3, d0                                 ; i <= 3
48487fd7: d3                    lle     
48487fd8: 1e                    exthu   d2
48487fd9: f1 e9                 mov     d2, a1
48487fdb: f1 75                 add     a1, a1
48487fdd: f1 d4                 mov     a1, d0
48487fdf: fc dc 08 67 5d 48     mov     0x485d6708, a0                        ; DbMemDumpLegendColors
48487fe5: f4 80                 movhu   (d0, a0), d0
48487fe7: 18                    exth    d0
48487fe8: ca 11                 bra     0x48487ff9

; --------------------------------------------------------------- default
; Out-of-range event, or an empty hash bucket: hand it to the base class.
; EXIT is NOT handled here -- dismissing the screen is the title framework's
; job (InterruptTitle / ChangeMode), and the viewer only sees the resulting
; EV_HIDE.
DbMemDumpDefault:
48487fea: 5c 9c                 mov     (0x9c, sp), a0
48487fec: f1 dd                 mov     a3, d1
48487fee: 43 10                 mov     a0, (0x10, sp)
48487ff0: 58 94                 mov     (0x94, sp), d0
48487ff2: dd 77 15 fa ff f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28       ; InheritedProc(self, event, param)
48487ff9: df f0 8c              ret     [d2,d3,a2,a3], 0x8c

; ----------------------------------------------------------------------------
; func_48456EBB -- sequencer song-slot field accessor (only its default value
;                  matters here)
;
; Purpose : returns 0x501A5800 + (index & 0xFF) * 0x8E0 + 0x120 for index
;           0..10, and the constant 0x501A5920 for index >= 11.  The song
;           slots at 0x501A5800 + n*0x8E0 are the sequencer's per-song RAM
;           records (kn7000_mame/notes/demo-and-sequencer-engine.md).
; Inputs  : d0 = song index        Outputs: a0 = field pointer
; Callers : 24 call sites; DbMemDumpEvShow calls it with 0, which is exactly
;           how ADR3 acquires its 0x501A5920 default.
; ----------------------------------------------------------------------------
func_48456EBB:
48456ebb: 81                    mov     d0, d1
48456ebc: 15                    extbu   d1
48456ebd: a5 0b                 cmp     0xb, d1
48456ebf: c2 17                 bge     0x48456ed6
48456ec1: 14                    extbu   d0
48456ec2: 2d e0 08              mov     0x8e0, d1                             ; slot stride
48456ec5: cb                    nop     
48456ec6: cb                    nop     
48456ec7: f2 54                 mulu    d1, d0
48456ec9: fc c0 00 58 1a 50     add     0x501a5800, d0                        ; song-slot array base
48456ecf: 24 20 01              mov     0x120, a0                             ; field offset
48456ed2: f1 60                 add     d0, a0
48456ed4: f0 fc                 rets    
48456ed6: fc dc 20 59 1a 50     mov     0x501a5920, a0
48456edc: f0 fc                 rets    

; ----------------------------------------------------------------------------
; DataSectionCopy -- boot-time .data initialiser (excerpt of the crt0)
;
; Purpose : copies 0x7F34 bytes from ROM 0x487B0B78 to RAM 0x50000010.  This
;           is what gives the viewer's cells their power-on values: the image
;           of 0x500012EC..0x50001307 sits at ROM 0x487B1E54 and reads
;             00 00 00 84 | 00 00 00 50 | 00 00 00 4C | 00 00 40 48
;             F0 00 F7 00 FF 00 FF FF | 01 00 00 00
;           i.e. ADR0..ADR3 = 0x84000000 / 0x50000000 / 0x4C000000 /
;           0x48400000, highlight bytes F0 F7 FF (none), cold flag = 1.
; Included here as the evidence for DbMemDumpEvShow's cold-flag test.
; ----------------------------------------------------------------------------
DataSectionCopy:
48410055: 2d 34 7f              mov     0x7f34, d1                            ; 0x7F34 bytes
48410058: a5 00                 cmp     0, d1
4841005a: c3 16                 ble     0x48410070
4841005c: fc dc 78 0b 7b 48     mov     0x487b0b78, a0                        ; ROM image
48410062: fc dd 10 00 00 50     mov     0x50000010, a1                        ; RAM destination
48410068: 70                    mov     (a0), d0
48410069: 50                    inc4    a0
4841006a: 61                    mov     d0, (a1)
4841006b: 51                    inc4    a1
4841006c: 29 fc                 add     -4, d1
4841006e: c1 fa                 bgt     0x48410068
