
; SysexBulkDump_PhaseVector: the boot phase vector of module 9 -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
SysexBulkDump_PhaseVector:
	jp SysexBulkDump_BootPhase0                                        ; F99800  1b 18 98 f9
	ret                                                  ; F99804  0e
	nop                                                  ; F99805  00
	nop                                                  ; F99806  00
	nop                                                  ; F99807  00
	ret                                                  ; F99808  0e
	nop                                                  ; F99809  00
	nop                                                  ; F9980A  00
	nop                                                  ; F9980B  00
	ret                                                  ; F9980C  0e
	nop                                                  ; F9980D  00
	nop                                                  ; F9980E  00
	nop                                                  ; F9980F  00
	ret                                                  ; F99810  0e
	nop                                                  ; F99811  00
	nop                                                  ; F99812  00
	nop                                                  ; F99813  00
	ret                                                  ; F99814  0e
	nop                                                  ; F99815  00
	nop                                                  ; F99816  00
	nop                                                  ; F99817  00
; SysexBulkDump_BootPhase0: module 9's boot phase 0 handler (vector 0xF99800, the block that publishes
;   Paint_/ScreenLeave_/ScreenButton_SysexBulkDump_Entry): MidiOutProgramChange_ResetState.
SysexBulkDump_BootPhase0:
	calr PanelScreen_RequestRedrawIfFieldQueued_Nop                                      ; F99818  1e 05 00
	call MidiOutProgramChange_ResetState                                      ; F9981B  1d a1 b4 f9
	ret                                                  ; F9981F  0e
PanelScreen_RequestRedrawIfFieldQueued_Nop:
	ret                                                  ; F99820  0e
T_F41660_Nop:
	ret                                                  ; F99821  0e
T_F416E0_Nop:
	ret                                                  ; F99822  0e
T_F416F0_Nop:
	ret                                                  ; F99823  0e
T_F41700_Nop:
	ret                                                  ; F99824  0e
T_F41670_Nop:
	ret                                                  ; F99825  0e
T_F41680_Nop:
	ret                                                  ; F99826  0e
T_F416A0_Nop:
	ret                                                  ; F99827  0e
T_F416B0_Nop:
	ret                                                  ; F99828  0e
	ret                                                  ; F99829  0e
	ret                                                  ; F9982A  0e
T_F416C0_Nop:
	ret                                                  ; F9982B  0e
T_F416D0_Nop:
	ret                                                  ; F9982C  0e
; ---------------------------------------------------------------------
; Paint_SysexBulkDump_Entry -- a PURE WRAPPER for Paint_SysexBulkDump: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF99831, where the next top-level label begins.
; Evidence: the `calr` at 0xF9982D targets 0xF99A04, which carries the
;          label Paint_SysexBulkDump.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Paint_SysexBulkDump_Entry:
	calr Paint_SysexBulkDump                                          ; F9982D  1e d4 01
	ret                                                  ; F99830  0e
; ---------------------------------------------------------------------
; ScreenLeave_SysexBulkDump_Entry -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x99, i.e. SCREEN ID 0x79 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x99 -> the screen object at
;          0xF41710, whose +4 slot is `jp 0xF99831`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   SysexBulkDump_Entry -- the same object's +0 ENTER method carries
;          the label Paint_SysexBulkDump_Entry, a name an earlier round
;          derived from the screen's own text.
; Was `sub_F99831`.
; ---------------------------------------------------------------------
ScreenLeave_SysexBulkDump_Entry:
	calr ScreenLeave_SysexBulkDump                                          ; F99831  1e 1a 02
	ret                                                  ; F99834  0e
; ---------------------------------------------------------------------
; ScreenButton_SysexBulkDump_Entry -- the BUTTON method of the screen object
;          at PanelScreen_VtableTable entry 0x99, i.e. SCREEN ID 0x79 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x99 -> the screen object at
;          0xF41710, whose +8 slot is `jp 0xF99835`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   SysexBulkDump_Entry -- the same object's +0 ENTER method carries
;          the label Paint_SysexBulkDump_Entry, a name an earlier round
;          derived from the screen's own text.
; Was `sub_F99835`.
; ---------------------------------------------------------------------
ScreenButton_SysexBulkDump_Entry:
	ld XIX,ScreenButtonRow_SysexBulkDump                        ; F99835  44 70 98 f9 00
	ld e, (0x2740:16)                                   ; F9983A  c1 40 27 25
	call T_PanelButton_CallPageTableEntry                                        ; F9983E  1d 0c 1b f4
	ret                                                  ; F99842  0e
T_F4171C_Nop:
	ret                                                  ; F99843  0e
; ---------------------------------------------------------------------
; Paint_GeneralMidiMode_Entry -- a PURE WRAPPER for Paint_GeneralMidiMode: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF99848, where the next top-level label begins.
; Evidence: the `calr` at 0xF99844 targets 0xF99D0C, which carries the
;          label Paint_GeneralMidiMode.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Paint_GeneralMidiMode_Entry:
	calr Paint_GeneralMidiMode                                          ; F99844  1e c5 04
	ret                                                  ; F99847  0e
; ---------------------------------------------------------------------
; ScreenLeave_GeneralMidiMode_Entry -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0x9A, i.e. SCREEN ID 0x7A through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9A -> the screen object at
;          0xF41720, whose +4 slot is `jp 0xF99848`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   GeneralMidiMode_Entry -- the same object's +0 ENTER method
;          carries the label Paint_GeneralMidiMode_Entry, a name an earlier
;          round derived from the screen's own text.
; Was `sub_F99848`.
; ---------------------------------------------------------------------
ScreenLeave_GeneralMidiMode_Entry:
	calr ScreenLeave_GeneralMidiMode                                          ; F99848  1e 7b 05
	ret                                                  ; F9984B  0e
; ---------------------------------------------------------------------
; ScreenButton_GeneralMidiMode_Entry -- the BUTTON method of the screen
;          object at PanelScreen_VtableTable entry 0x9A, i.e. SCREEN ID 0x7A
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9A -> the screen object at
;          0xF41720, whose +8 slot is `jp 0xF9984C`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   GeneralMidiMode_Entry -- the same object's +0 ENTER method
;          carries the label Paint_GeneralMidiMode_Entry, a name an earlier
;          round derived from the screen's own text.
; Was `sub_F9984C`.
; ---------------------------------------------------------------------
ScreenButton_GeneralMidiMode_Entry:
	ld XIX,ScreenButtonRow_GeneralMidi_Page0                   ; F9984C  44 f0 98 f9 00
	ld e, (0x2740:16)                                   ; F99851  c1 40 27 25
	call T_PanelButton_CallPageTableEntry                                        ; F99855  1d 0c 1b f4
	ret                                                  ; F99859  0e
T_F4172C_Nop:
	ret                                                  ; F9985A  0e
; ---------------------------------------------------------------------
; Paint_Sending_Entry -- a PURE WRAPPER for Paint_Sending: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF9985F, where the next top-level label begins.
; Evidence: the `calr` at 0xF9985B targets 0xF99B82, which carries the
;          label Paint_Sending.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Paint_Sending_Entry:
	calr Paint_Sending                                          ; F9985B  1e 24 03
	ret                                                  ; F9985E  0e
; ---------------------------------------------------------------------
; Paint_SystemExclusivePleaseWait_Entry -- a PURE WRAPPER for Paint_SystemExclusivePleaseWait: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF99863, where the next top-level label begins.
; Evidence: the `calr` at 0xF9985F targets 0xF99CA1, which carries the
;          label Paint_SystemExclusivePleaseWait.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Paint_SystemExclusivePleaseWait_Entry:
	calr Paint_SystemExclusivePleaseWait                                          ; F9985F  1e 3f 04
	ret                                                  ; F99862  0e
T_F41738_Nop:
	ret                                                  ; F99863  0e
; ExitKey_SysexGeneralMidiShared -- shared EXIT body of the SysexBulkDump and GeneralMidiMode screens:
; request panel mode 0x12 ((0x2070) = 0x12, (0x2071) = 0x02) when bit 7 of W is clear
; Evidence: `bit 7,W / jr nz / ldw (0x2070),0x0212` (0xF99864-0xF99869); called only by ExitKey_SysexBulkDump
; (0xF99B6E) and ExitKey_GeneralMidiMode_Page0 (0xF99E67). Flag 0x02 is the request bit ExitKey_DiskMenu and
; PanelEvent_Code20_SetScreen also write.
ExitKey_SysexGeneralMidiShared:
	bit 0x07,W                                           ; F99864  c8 33 07
	jr nz, .LF9986F                                      ; F99867  6e 06
	ldw (UI_Request:16), 0x0212                              ; F99869  f1 70 20 02 12 02
.LF9986F:
	ret                                                  ; F9986F  0e
; ---------------------------------------------------------------------
; ScreenButtonRow_SysexBulkDump -- 96 LE32 handler pointers = THREE 32-entry ROWS
;          end to end; this was ScreenButtonRow_SysexBulkDump (they are routines,
;          not display lists: every entry is an instruction start, check W5).
;
; Read by: TWO located sites, both the same three instructions --
;          0xF99835 `ld XIX,0x00F99870 / ld E,(0x2740) / call T_PanelButton_CallPageTableEntry` and
;          0xF9984C `ld XIX,0x00F998F0 / ld E,(0x2740) / call T_PanelButton_CallPageTableEntry`.
;          0xF99970, the third 32-entry block, has no located reader.
; ENTRY COUNT 32 per table, and it is NOT a guess: T_PanelButton_CallPageTableEntry resolves to prom_a
;          0xF8BDF8, whose FIRST instruction is `cp HL,0x001F / jr ugt` -- 0x1F
;          is the last index it lets through, so 32 entries.  (T_PanelButton_CallTableEntry ->
;          0xF8BDC5 opens with the same two instructions.)  3 x 32 = 96 is
;          exactly the run notes/prom_a_ptr_tables.py measures, 0xF99870-0xF999EF.
;          ★ LAST-ENTRY TEST: the word at 0xF999F0 is 0x0C210023, not
;          pointer-shaped, and it is where the decode resumes.
; Evidence: the two readers, the callee's own bound, and the shape run; the
;          three agree.  notes/prom_a_uiblock_checks.py.
; ★ CORRECTED 2026-09-25 (lane proma).  This line listed what (0x2740)
;          selects and what the third block is for as open.  PanelButton_CallPageTableEntry
;          adds E * 128 to the base before indexing by the button code
;          (`xor XDE,XDE / pop E / sla 7,DE / add XIX,XDE`), so (0x2740) picks
;          a ROW -- the screen's PAGE -- and each reader's base is its page 0:
;            0xF99870  SysexBulkDump page 0 (its paint writes (0x2740) = 0 and
;                      that screen writes nothing else);
;            0xF998F0  GeneralMidiMode page 0 -- ScreenButtonRow_GeneralMidi_Page0;
;            0xF99970  GeneralMidiMode page 1, the YES/NO page --
;                      ScreenButtonRow_GeneralMidi_YesNo.
;          (notes/proma-2026-09-25/gen_button_rows.py, checks W1-W5)
; ---------------------------------------------------------------------
ScreenButtonRow_SysexBulkDump:
	.long ScreenButtonRow_SysexBulkDump_Nop0                                 ; F99870  [  0]
	.long ScreenButtonRow_SysexBulkDump_Nop1                                 ; F99874  [  1]
	.long ScreenButtonRow_SysexBulkDump_Nop2                                 ; F99878  [  2]
	.long ScreenButtonRow_SysexBulkDump_Nop3                                 ; F9987C  [  3]
	.long ScreenButtonRow_SysexBulkDump_Nop4                                 ; F99880  [  4]
	.long ScreenButtonRow_SysexBulkDump_Nop5                                 ; F99884  [  5]
	.long ScreenButtonRow_SysexBulkDump_Nop6                                 ; F99888  [  6]
	.long ScreenButtonRow_SysexBulkDump_Nop7                                 ; F9988C  [  7]
	.long LcdKeyRow1_SysexBulkDump                                 ; F99890  [  8]
	.long LcdKeyRow2_SysexBulkDump                                 ; F99894  [  9]
	.long LcdKeyRow2_SysexBulkDump__F99AEB                                 ; F99898  [ 10]
	.long LcdKeyRow4_SysexBulkDump                                 ; F9989C  [ 11]
	.long LcdKeyRow5_SysexBulkDump                                 ; F998A0  [ 12]
	.long ScreenButtonRow_SysexBulkDump_Nop13                                 ; F998A4  [ 13]
	.long ScreenButtonRow_SysexBulkDump_Nop14                                 ; F998A8  [ 14]
	.long ExitKey_SysexBulkDump                                 ; F998AC  [ 15]
	.long ScreenButtonRow_SysexBulkDump_Nop16                                 ; F998B0  [ 16]
	.long ScreenButtonRow_SysexBulkDump_Nop17                                 ; F998B4  [ 17]
	.long ScreenButtonRow_SysexBulkDump_Nop18                                 ; F998B8  [ 18]
	.long ScreenButtonRow_SysexBulkDump_Nop19                                 ; F998BC  [ 19]
	.long ScreenButtonRow_SysexBulkDump_Nop20                                 ; F998C0  [ 20]
	.long ScreenButtonRow_SysexBulkDump_Nop21                                 ; F998C4  [ 21]
	.long ScreenButtonRow_SysexBulkDump_Nop22                                 ; F998C8  [ 22]
	.long ScreenButtonRow_SysexBulkDump_Nop23                                 ; F998CC  [ 23]
	.long ScreenButtonRow_SysexBulkDump_Nop24                                 ; F998D0  [ 24]
	.long ScreenButtonRow_SysexBulkDump_Nop25                                 ; F998D4  [ 25]
	.long ScreenButtonRow_SysexBulkDump_Nop26                                 ; F998D8  [ 26]
	.long ScreenButtonRow_SysexBulkDump_Nop27                                 ; F998DC  [ 27]
	.long ScreenButtonRow_SysexBulkDump_Nop28                                 ; F998E0  [ 28]
	.long ScreenButtonRow_SysexBulkDump_Nop29                                 ; F998E4  [ 29]
	.long ScreenButtonRow_SysexBulkDump_Nop30                                 ; F998E8  [ 30]
	.long ScreenButtonRow_SysexBulkDump_Nop31                                 ; F998EC  [ 31]
; ---------------------------------------------------------------------
; ScreenButtonRow_GeneralMidi_Page0 -- 32 handlers, GeneralMidiMode's main
;          page: ScreenButton_GeneralMidiMode_Entry's base, row (0x2740) = 0,
;          drawn by Paint_GeneralMidiMode as DL_GeneralMidiMidiGeneralMidiMode.
;          Its LcdKeyRow1_GeneralMidiMode_Page0 sets (0x2740) = 1 at 0xF99DE8 (check W3).
;          Also row 1 of the SysexBulkDump base, which that screen never
;          selects (its only (0x2740) write is 0).
; (notes/proma-2026-09-25/gen_button_rows.py)
; ---------------------------------------------------------------------
ScreenButtonRow_GeneralMidi_Page0:
	.long ScreenButtonRow_GeneralMidi_Page0_Nop0                                 ; F998F0  [ 32]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop1                                 ; F998F4  [ 33]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop2                                 ; F998F8  [ 34]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop3                                 ; F998FC  [ 35]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop4                                 ; F99900  [ 36]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop5                                 ; F99904  [ 37]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop6                                 ; F99908  [ 38]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop7                                 ; F9990C  [ 39]
	.long LcdKeyRow1_GeneralMidiMode_Page0                                 ; F99910  [ 40]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop9                                 ; F99914  [ 41]
	.long LcdKeyRow3_GeneralMidiMode_Page0                                 ; F99918  [ 42]
	.long LcdKeyRow4_GeneralMidiMode_Page0                                 ; F9991C  [ 43]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop12                                 ; F99920  [ 44]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop13                                 ; F99924  [ 45]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop14                                 ; F99928  [ 46]
	.long ExitKey_GeneralMidiMode_Page0                                 ; F9992C  [ 47]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop16                                 ; F99930  [ 48]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop17                                 ; F99934  [ 49]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop18                                 ; F99938  [ 50]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop19                                 ; F9993C  [ 51]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop20                                 ; F99940  [ 52]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop21                                 ; F99944  [ 53]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop22                                 ; F99948  [ 54]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop23                                 ; F9994C  [ 55]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop24                                 ; F99950  [ 56]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop25                                 ; F99954  [ 57]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop26                                 ; F99958  [ 58]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop27                                 ; F9995C  [ 59]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop28                                 ; F99960  [ 60]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop29                                 ; F99964  [ 61]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop30                                 ; F99968  [ 62]
	.long ScreenButtonRow_GeneralMidi_Page0_Nop31                                 ; F9996C  [ 63]
; ---------------------------------------------------------------------
; ScreenButtonRow_GeneralMidi_YesNo -- 32 handlers, GeneralMidiMode's YES/NO
;          page: row (0x2740) = 1 of ScreenButton_GeneralMidiMode_Entry, drawn
;          as DL_GeneralMidiMidiYesNo; LcdKeyRow3_GeneralMidiYesNo, LcdKeyRow4_GeneralMidiYesNo and ExitKey_GeneralMidiYesNo
;          in this row set (0x2740) back to 0 (check W3).
; (notes/proma-2026-09-25/gen_button_rows.py)
; ---------------------------------------------------------------------
ScreenButtonRow_GeneralMidi_YesNo:
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop0                                 ; F99970  [ 64]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop1                                 ; F99974  [ 65]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop2                                 ; F99978  [ 66]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop3                                 ; F9997C  [ 67]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop4                                 ; F99980  [ 68]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop5                                 ; F99984  [ 69]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop6                                 ; F99988  [ 70]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop7                                 ; F9998C  [ 71]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop8                                 ; F99990  [ 72]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop9                                 ; F99994  [ 73]
	.long LcdKeyRow3_GeneralMidiYesNo                                 ; F99998  [ 74]
	.long LcdKeyRow4_GeneralMidiYesNo                                 ; F9999C  [ 75]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop12                                 ; F999A0  [ 76]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop13                                 ; F999A4  [ 77]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop14                                 ; F999A8  [ 78]
	.long ExitKey_GeneralMidiYesNo                                 ; F999AC  [ 79]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop16                                 ; F999B0  [ 80]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop17                                 ; F999B4  [ 81]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop18                                 ; F999B8  [ 82]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop19                                 ; F999BC  [ 83]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop20                                 ; F999C0  [ 84]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop21                                 ; F999C4  [ 85]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop22                                 ; F999C8  [ 86]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop23                                 ; F999CC  [ 87]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop24                                 ; F999D0  [ 88]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop25                                 ; F999D4  [ 89]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop26                                 ; F999D8  [ 90]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop27                                 ; F999DC  [ 91]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop28                                 ; F999E0  [ 92]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop29                                 ; F999E4  [ 93]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop30                                 ; F999E8  [ 94]
	.long ScreenButtonRow_GeneralMidi_YesNo_Nop31                                 ; F999EC  [ 95]
; ------------------------------------------------------------------------------
; 0xF999F0-0xF99A03 -- LCD_ScreenRedraw_Begin and LCD_ScreenRedraw_End
;
; ★ MOVED to maincpu/shared/lcd_screen_redraw.s, ONE SOURCE included at BOTH of its
; sites: here and prom_b 0xF7E2D9.  The two copies are byte-identical,
; every reference binds to the nearer of them, and the header that used to sit
; here is in that file, verbatim, under a banner saying it came from this one.
; Why the duplication exists at all -- and why the obvious explanation is wrong
; -- is measured by `python3 notes/maincpu_join_probe.py --callers --nearest`.
; ------------------------------------------------------------------------------
	.include "maincpu/shared/lcd_screen_redraw.s"
; ---------------------------------------------------------------------
; Paint_SysexBulkDump -- paint the SYSEX BULK DUMP menu
;
; Called from: prom_a sub_F9982D (`calr`) at 0xF9982D
; Evidence: one interpreter-A site at 0xF99A3D, list 0xF0D6AF-0xF0D77F, which FRAMES
;           exactly and whose text records read `SYSEX BULK DUMP`, `MIDI`,
;           ` TOTAL KEYBOARD`, ` SEND`, ` SOUND`, ` COMBINATION`,
;           ` SYSTEM,PART & MIDI`.  ⚠ 0xF0D6AF carries NO label in prom_b's listing --
;           it is inside a span that is still `.incbin` -- so round 5's label-based
;           painter rule could not see it.  The text is walked out of
;           original_ROMs/wsa1_prom_b.ic13 by this file's dl_walk(); --selftest checks
;           both the framing and the absence of the label.
;           ⚠⚠ THIS CORRECTS THE HEADER ROUND 5 LEFT HERE, which said `Not one of these
;           lists holds an .ascii record`.  It does: seven text records, quoted above.
;           The claim was true of the LABELS round 5 could search and false of the ROM.
;           The bounds themselves are derived exactly as round 5 derived them -- the
;           LAST `ld XIY,imm32` and `ld XIX,imm32` before the cited `call`, with
;           0xF417F0 entering interpreter A and 0xF417F4 interpreter B
;           (notes/FINDINGS-ui-display-list.md).
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_SysexBulkDump:
	call T_CallbackQueue_ResetAndRestartTask2            ; F99A04  1d 80 2e f4
	ld a, (UI_ScreenLatch:16)                                   ; F99A08  c1 7a 20 21
	cp (UI_ScreenLatch_Previous:16), a                                    ; F99A0C  c1 7b 20 f9
	jr z, .LF99A25                                       ; F99A10  66 13
	call T_Transport_StopAllRunning                                        ; F99A12  1d ac 09 f4
	ld (0x2740:16), 0x00                                 ; F99A16  f1 40 27 00 00
	or	(0x2094:16), 0x40                            ; F99A1B  c1 94 20 3e 40
	ld (UI_ScreenItem:16), 0x00                                 ; F99A20  f1 20 27 00 00
.LF99A25:
	calr LCD_ScreenRedraw_Begin                                      ; F99A25  1e c8 ff
	ld XIY,0x00f0d6af                                    ; F99A28  45 af d6 f0 00
	ld XIX,DL_Sending                                    ; F99A2D  44 9c d7 f0 00
	cp	(Variant_Flag:8), 0x02                               ; F99A32  c0 c4 3f 02
	jr nz, .LF99A3D                                      ; F99A36  6e 05
	ld XIX,0x00f0d77f                                    ; F99A38  44 7f d7 f0 00
.LF99A3D:
	call T_DisplayList_Run                               ; F99A3D  1d f0 17 f4
	ld XIY,0x00f0d9a4                                    ; F99A41  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99A46  1d 1c 18 f4
	calr LCD_ScreenRedraw_End                                      ; F99A4A  1e b1 ff
	ret                                                  ; F99A4D  0e
; ScreenLeave_SysexBulkDump -- the SysexBulkDump LEAVE body: clear bit 6 of (0x2094) unless (0x207A) ==
; (0x207B)
; Evidence: only caller ScreenLeave_SysexBulkDump_Entry (0xF99831, the object's +4 slot); Paint_SysexBulkDump
; sets the same bit (`or (0x2094),0x40`, 0xF99A1B) under the same (0x207A) != (0x207B) test.
ScreenLeave_SysexBulkDump:
	ld a, (UI_ScreenLatch:16)                                   ; F99A4E  c1 7a 20 21
	cp (UI_ScreenLatch_Previous:16), a                                    ; F99A52  c1 7b 20 f9
	jr z, .LF99A5D                                       ; F99A56  66 05
	and	(0x2094:16), 0xbf                            ; F99A58  c1 94 20 3c bf
.LF99A5D:
	ret                                                  ; F99A5D  0e
ScreenButtonRow_SysexBulkDump_Nop0:   ; entry: named by 1 `.long` operand, first at 0xF99870
	ret                                                  ; F99A5E  0e
ScreenButtonRow_SysexBulkDump_Nop1:   ; entry: named by 1 `.long` operand, first at 0xF99874
	ret                                                  ; F99A5F  0e
ScreenButtonRow_SysexBulkDump_Nop2:   ; entry: named by 1 `.long` operand, first at 0xF99878
	ret                                                  ; F99A60  0e
ScreenButtonRow_SysexBulkDump_Nop3:   ; entry: named by 1 `.long` operand, first at 0xF9987C
	ret                                                  ; F99A61  0e
ScreenButtonRow_SysexBulkDump_Nop4:   ; entry: named by 1 `.long` operand, first at 0xF99880
	ret                                                  ; F99A62  0e
ScreenButtonRow_SysexBulkDump_Nop5:   ; entry: named by 1 `.long` operand, first at 0xF99884
	ret                                                  ; F99A63  0e
ScreenButtonRow_SysexBulkDump_Nop6:   ; entry: named by 1 `.long` operand, first at 0xF99888
	ret                                                  ; F99A64  0e
ScreenButtonRow_SysexBulkDump_Nop7:   ; entry: named by 1 `.long` operand, first at 0xF9988C
	ret                                                  ; F99A65  0e
; LcdKeyRow1_SysexBulkDump -- LCD row 1, left key (bit 7 of W set): select item 0, TOTAL KEYBOARD
; Evidence: ScreenButtonRow_SysexBulkDump[8] (code 0x08); unless (0x2720) is already 0:
; cursor move (0x2540) = 1, Array6(0xF0D9D7), (0x2720) = k, T_F4181C(0xF0D9A4), k = 0.
; The menu list 0xF0D6AF draws ' TOTAL KEYBOARD' at LCD 0x061B, ' SOUND' at 0x0C33, ' COMBINATION' 0x124B,
; ' SYSTEM,PART & MIDI' 0x1863, ' SEQUENCER' 0x1E7B -- rows 1-5, column 3.
LcdKeyRow1_SysexBulkDump:   ; entry: named by 1 `.long` operand, first at 0xF99890
	bit 0x07,W                                           ; F99A66  c8 33 07
	jr z, .LF99A8E                                       ; F99A69  66 23
	cp	(UI_ScreenItem:16), 0x00                            ; F99A6B  c1 20 27 3f 00
	jr z, .LF99A8E                                       ; F99A70  66 1c
	ld (LCD_CurrentLayer:16), 0x01                                 ; F99A72  f1 40 25 00 01
	ld XIY,0x00f0d9d7                                    ; F99A77  45 d7 d9 f0 00
	call T_DLB_Handler_Array6                            ; F99A7C  1d 24 18 f4
	ld (UI_ScreenItem:16), 0x00                                 ; F99A80  f1 20 27 00 00
	ld XIY,0x00f0d9a4                                    ; F99A85  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99A8A  1d 1c 18 f4
.LF99A8E:
	ret                                                  ; F99A8E  0e
; LcdKeyRow2_SysexBulkDump -- LCD row 2: right key (bit 7 of W clear) = SEND; left key selects item 1, SOUND
; Evidence: ScreenButtonRow_SysexBulkDump[9]. SEND: `and (0x2075),0x6F`; (0x60F802) = byte [(0x2720) & 7] of
; the table at 0xF99AE3 (00 03 05 04 02 00 00 00) | 0x80; T_SysExDump_RunSendJob (prom_a 0xFB2049), T_F40F1C
; (SC1_Entry_F40F1C). ' SEND' is at LCD 0x0BB1, the right end of row 2. Select: as row 1 with k = 1.
LcdKeyRow2_SysexBulkDump:   ; entry: named by 1 `.long` operand, first at 0xF99894
	bit 0x07,W                                           ; F99A8F  c8 33 07
	jr nz, .LF99ABF                                      ; F99A92  6e 2b
	and	(UI_RequestBits:16), 0x6f                            ; F99A94  c1 75 20 3c 6f
	ld XIY,LcdKeyRow2_SysexBulkDump__F99AE3                                    ; F99A99  45 e3 9a f9 00
	ld a, (UI_ScreenItem:16)                                   ; F99A9E  c1 20 27 21
	and A,0x07                                           ; F99AA2  c9 cc 07
	ld	a, (xiy+a)                                   ; F99AA5  c3 03 f4 e0 21
	ld (0x60f802:24), a                                 ; F99AAA  f2 02 f8 60 41
	or	(0x60f802:24), 0x80                          ; F99AAF  c2 02 f8 60 3e 80
	call T_SysExDump_RunSendJob                                        ; F99AB5  1d e4 08 f4
	call T_F40F1C                                        ; F99AB9  1d 1c 0f f4
	jr .LF99AE2                                          ; F99ABD  68 23
.LF99ABF:
	cp	(UI_ScreenItem:16), 0x01                            ; F99ABF  c1 20 27 3f 01
	jr z, .LF99AE2                                       ; F99AC4  66 1c
	ld (LCD_CurrentLayer:16), 0x01                                 ; F99AC6  f1 40 25 00 01
	ld XIY,0x00f0d9d7                                    ; F99ACB  45 d7 d9 f0 00
	call T_DLB_Handler_Array6                            ; F99AD0  1d 24 18 f4
	ld (UI_ScreenItem:16), 0x01                                 ; F99AD4  f1 20 27 00 01
	ld XIY,0x00f0d9a4                                    ; F99AD9  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99ADE  1d 1c 18 f4
.LF99AE2:
	ret                                                  ; F99AE2  0e
LcdKeyRow2_SysexBulkDump__F99AE3:
	nop                                                  ; F99AE3  00
	pop SR                                               ; F99AE4  03
	halt                                                 ; F99AE5  05
	max                                                  ; F99AE6  04
	push SR                                              ; F99AE7  02
	nop                                                  ; F99AE8  00
	nop                                                  ; F99AE9  00
	nop                                                  ; F99AEA  00
LcdKeyRow2_SysexBulkDump__F99AEB:
	bit 0x07,W                                           ; F99AEB  c8 33 07
	jr z, .LF99B13                                       ; F99AEE  66 23
	cp	(UI_ScreenItem:16), 0x02                            ; F99AF0  c1 20 27 3f 02
	jr z, .LF99B13                                       ; F99AF5  66 1c
	ld (LCD_CurrentLayer:16), 0x01                                 ; F99AF7  f1 40 25 00 01
	ld XIY,0x00f0d9d7                                    ; F99AFC  45 d7 d9 f0 00
	call T_DLB_Handler_Array6                            ; F99B01  1d 24 18 f4
	ld (UI_ScreenItem:16), 0x02                                 ; F99B05  f1 20 27 00 02
	ld XIY,0x00f0d9a4                                    ; F99B0A  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99B0F  1d 1c 18 f4
.LF99B13:
	ret                                                  ; F99B13  0e
; LcdKeyRow4_SysexBulkDump -- LCD row 4, left key (bit 7 of W set): select item 3, SYSTEM,PART & MIDI
; Evidence: ScreenButtonRow_SysexBulkDump[11] (code 0x0B); unless (0x2720) is already 3,
; cursor move (0x2540) = 1, Array6(0xF0D9D7), (0x2720) = k, T_F4181C(0xF0D9A4), k = 3.
LcdKeyRow4_SysexBulkDump:   ; entry: named by 1 `.long` operand, first at 0xF9989C
	bit 0x07,W                                           ; F99B14  c8 33 07
	jr z, .LF99B3C                                       ; F99B17  66 23
	cp	(UI_ScreenItem:16), 0x03                            ; F99B19  c1 20 27 3f 03
	jr z, .LF99B3C                                       ; F99B1E  66 1c
	ld (LCD_CurrentLayer:16), 0x01                                 ; F99B20  f1 40 25 00 01
	ld XIY,0x00f0d9d7                                    ; F99B25  45 d7 d9 f0 00
	call T_DLB_Handler_Array6                            ; F99B2A  1d 24 18 f4
	ld (UI_ScreenItem:16), 0x03                                 ; F99B2E  f1 20 27 00 03
	ld XIY,0x00f0d9a4                                    ; F99B33  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99B38  1d 1c 18 f4
.LF99B3C:
	ret                                                  ; F99B3C  0e
; LcdKeyRow5_SysexBulkDump -- LCD row 5, left key: select item 4, SEQUENCER -- nothing when (0xC4) == 2
; Evidence: ScreenButtonRow_SysexBulkDump[12] (code 0x0C); `cp (0xc4),0x02 / jr z` returns first;
; else cursor move (0x2540) = 1, Array6(0xF0D9D7), (0x2720) = k, T_F4181C(0xF0D9A4), k = 4.
; Paint_SysexBulkDump ends the list before ' SEQUENCER' (XIX = 0xF0D77F) when (0xC4) == 2, the SX-WSA1R
; rack (FINDINGS-prom_a-panel-control-map.md section 2).
LcdKeyRow5_SysexBulkDump:   ; entry: named by 1 `.long` operand, first at 0xF998A0
	cp	(Variant_Flag:8), 0x02                               ; F99B3D  c0 c4 3f 02
	jr z, .LF99B6B                                       ; F99B41  66 28
	bit 0x07,W                                           ; F99B43  c8 33 07
	jr z, .LF99B6B                                       ; F99B46  66 23
	cp	(UI_ScreenItem:16), 0x04                            ; F99B48  c1 20 27 3f 04
	jr z, .LF99B6B                                       ; F99B4D  66 1c
	ld (LCD_CurrentLayer:16), 0x01                                 ; F99B4F  f1 40 25 00 01
	ld XIY,0x00f0d9d7                                    ; F99B54  45 d7 d9 f0 00
	call T_DLB_Handler_Array6                            ; F99B59  1d 24 18 f4
	ld (UI_ScreenItem:16), 0x04                                 ; F99B5D  f1 20 27 00 04
	ld XIY,0x00f0d9a4                                    ; F99B62  45 a4 d9 f0 00
	call T_DLB_Handler_Array8                                        ; F99B67  1d 1c 18 f4
.LF99B6B:
	ret                                                  ; F99B6B  0e
ScreenButtonRow_SysexBulkDump_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF998A4
	ret                                                  ; F99B6C  0e
ScreenButtonRow_SysexBulkDump_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF998A8
	ret                                                  ; F99B6D  0e
; ExitKey_SysexBulkDump -- EXIT (panel code 0x0F) on the SysexBulkDump screen: `calr
; ExitKey_SysexGeneralMidiShared / ret`
; Evidence: ScreenButtonRow_SysexBulkDump[15].
ExitKey_SysexBulkDump:   ; entry: named by 1 `.long` operand, first at 0xF998AC
	calr ExitKey_SysexGeneralMidiShared                                          ; F99B6E  1e f3 fc
	ret                                                  ; F99B71  0e
ScreenButtonRow_SysexBulkDump_Nop16:   ; entry: named by 1 `.long` operand, first at 0xF998B0
	ret                                                  ; F99B72  0e
ScreenButtonRow_SysexBulkDump_Nop17:   ; entry: named by 1 `.long` operand, first at 0xF998B4
	ret                                                  ; F99B73  0e
ScreenButtonRow_SysexBulkDump_Nop18:   ; entry: named by 1 `.long` operand, first at 0xF998B8
	ret                                                  ; F99B74  0e
ScreenButtonRow_SysexBulkDump_Nop19:   ; entry: named by 1 `.long` operand, first at 0xF998BC
	ret                                                  ; F99B75  0e
ScreenButtonRow_SysexBulkDump_Nop20:   ; entry: named by 1 `.long` operand, first at 0xF998C0
	ret                                                  ; F99B76  0e
ScreenButtonRow_SysexBulkDump_Nop21:   ; entry: named by 1 `.long` operand, first at 0xF998C4
	ret                                                  ; F99B77  0e
ScreenButtonRow_SysexBulkDump_Nop22:   ; entry: named by 1 `.long` operand, first at 0xF998C8
	ret                                                  ; F99B78  0e
ScreenButtonRow_SysexBulkDump_Nop23:   ; entry: named by 1 `.long` operand, first at 0xF998CC
	ret                                                  ; F99B79  0e
ScreenButtonRow_SysexBulkDump_Nop24:   ; entry: named by 1 `.long` operand, first at 0xF998D0
	ret                                                  ; F99B7A  0e
ScreenButtonRow_SysexBulkDump_Nop25:   ; entry: named by 1 `.long` operand, first at 0xF998D4
	ret                                                  ; F99B7B  0e
ScreenButtonRow_SysexBulkDump_Nop26:   ; entry: named by 1 `.long` operand, first at 0xF998D8
	ret                                                  ; F99B7C  0e
ScreenButtonRow_SysexBulkDump_Nop27:   ; entry: named by 1 `.long` operand, first at 0xF998DC
	ret                                                  ; F99B7D  0e
ScreenButtonRow_SysexBulkDump_Nop28:   ; entry: named by 1 `.long` operand, first at 0xF998E0
	ret                                                  ; F99B7E  0e
ScreenButtonRow_SysexBulkDump_Nop29:   ; entry: named by 1 `.long` operand, first at 0xF998E4
	ret                                                  ; F99B7F  0e
ScreenButtonRow_SysexBulkDump_Nop30:   ; entry: named by 1 `.long` operand, first at 0xF998E8
	ret                                                  ; F99B80  0e
ScreenButtonRow_SysexBulkDump_Nop31:   ; entry: named by 1 `.long` operand, first at 0xF998EC
	ret                                                  ; F99B81  0e
; Paint_Sending -- paints the screen whose own text reads "SENDING"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF99B96  interpreter A  list 0xF0D79C  DL_Sending
;        text: "SENDING"
; Evidence: the list address is the `ld XIY,0x00F0D79C` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_Sending:
	bit	0, (0x60f810:24)                             ; F99B82  f2 10 f8 60 c8
	jr z, .LF99BA0                                       ; F99B87  66 17
	calr LCD_ScreenRedraw_Begin                                      ; F99B89  1e 64 fe
	ld XIY,DL_Sending                                    ; F99B8C  45 9c d7 f0 00
	ld XIX,0x00f0d7d5                                    ; F99B91  44 d5 d7 f0 00
	call T_DisplayList_Run                               ; F99B96  1d f0 17 f4
	and	(0x60f810:24), 0xfe                          ; F99B9A  c2 10 f8 60 3c fe
.LF99BA0:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F99BA0  f1 40 25 00 02
	xor XHL,XHL                                          ; F99BA5  eb d3
	ld l, (0x60f806:24)                                 ; F99BA7  c2 06 f8 60 27
	bit 0x07,L                                           ; F99BAC  cf 33 07
	jr z, .LF99BBA                                       ; F99BAF  66 09
	calr SysexProgressBar_DrawDots                                      ; F99BB1  1e 39 00
	and	(0x60f806:24), 0x7f                          ; F99BB4  c2 06 f8 60 3c 7f
.LF99BBA:
	xor XHL,XHL                                          ; F99BBA  eb d3
	ld l, (0x60f808:24)                                 ; F99BBC  c2 08 f8 60 27
	bit 0x07,L                                           ; F99BC1  cf 33 07
	jr z, .LF99BCF                                       ; F99BC4  66 09
	calr SysexProgressBar_FillCells                                      ; F99BC6  1e 69 00
	and	(0x60f808:24), 0x7f                          ; F99BC9  c2 08 f8 60 3c 7f
.LF99BCF:
	xor XHL,XHL                                          ; F99BCF  eb d3
	ld l, (0x60f804:24)                                 ; F99BD1  c2 04 f8 60 27
	bit 0x07,L                                           ; F99BD6  cf 33 07
	jr z, .LF99BE9                                       ; F99BD9  66 0e
	ld XIY,DLPtrTable_F0D942                             ; F99BDB  45 42 d9 f0 00
	calr Paint_SysPartMidiSoundCombination                                      ; F99BE0  1e 79 00
	and	(0x60f804:24), 0x7f                          ; F99BE3  c2 04 f8 60 3c 7f
.LF99BE9:
	calr LCD_ScreenRedraw_End                                      ; F99BE9  1e 12 fe
	ret                                                  ; F99BEC  0e
; SysexProgressBar_DrawDots -- draw an empty progress bar: run SysexProgressBar_DrawDots_DL (0xF0D99C-0xF0D9A4, interpreter A,
; site 0xF99BF8), then L & 0x7F '.' glyphs centred on the row at LCD 0x0ED8, saving the start in (0x2640)
; Evidence: callers Paint_Sending (0xF99BB1, L = (0x60F806)) and Paint_SystemExclusivePleaseWait (0xF99CD0,
; L = (0x60F80C)), when bit 7 is set; prom_a 0xFB7CDD/0xFB7CF6 store 0xA0 there (32 cells | 0x80). Start =
; 0x0ED8 + (0x28 - L)/2 (0xF99C04-0xF99C12); svc 7 (LCD_Svc_07_DrawText8x16), XIY = Chars_F0D99A, HL = 0.
SysexProgressBar_DrawDots:
	push XHL                                             ; F99BED  3b
	ld XIY,SysexProgressBar_DrawDots_DL                                     ; F99BEE  45 9c d9 f0 00
	ld XIX,0x00f0d9a4                                    ; F99BF3  44 a4 d9 f0 00
	call T_DisplayList_Run                               ; F99BF8  1d f0 17 f4
	pop XHL                                              ; F99BFC  5b
	and L,0x7f                                           ; F99BFD  cf cc 7f
	jr z, .LF99C31                                       ; F99C00  66 2f
	xor XIX,XIX                                          ; F99C02  ec d4
	ldw ix, 0x0ed8                                       ; F99C04  34 d8 0e
	xor WA,WA                                            ; F99C07  d8 d0
	ld a, 0x28:opc                                          ; F99C09  21 28
	sub A,L                                              ; F99C0B  cf a1
	srl a, 0x01                                          ; F99C0D  c9 ef 01
	add IX,WA                                            ; F99C10  d8 84
	ld (UI_DrawScratch:16), ix                                  ; F99C12  f1 40 26 54
.LF99C16:
	push XIX                                             ; F99C16  3c
	push XHL                                             ; F99C17  3b
	xor XBC,XBC                                          ; F99C18  e9 d1
	ldw bc, 0x01                                         ; F99C1A  31 01 00
	xor XHL,XHL                                          ; F99C1D  eb d3
	ld XIY,Chars_F0D99A                                  ; F99C1F  45 9a d9 f0 00
	ld a, 0x07:opc                                          ; F99C24  21 07
	swi 7                                                ; F99C26  ff
	pop XHL                                              ; F99C27  5b
	pop XIX                                              ; F99C28  5c
	dec 1,L                                              ; F99C29  cf 69
	jr z, .LF99C31                                       ; F99C2B  66 04
	inc 1,IX                                             ; F99C2D  dc 61
	jr .LF99C16                                          ; F99C2F  68 e5
.LF99C31:
	ret                                                  ; F99C31  0e
; SysexProgressBar_FillCells -- overdraw the first L & 0x7F cells of the progress bar, from (0x2640), with
; glyph 0x92
; Evidence: callers Paint_Sending (0xF99BC6, L = (0x60F808)) and Paint_SystemExclusivePleaseWait (0xF99CE5,
; L = (0x60F80E)), when bit 7 is set; svc 7 with XIY = Chars_F0D99A and HL = 1 selects its second byte 0x92;
; IX starts at (0x2640), the start SysexProgressBar_DrawDots stored.
SysexProgressBar_FillCells:
	and L,0x7f                                           ; F99C32  cf cc 7f
	jr z, .LF99C5B                                       ; F99C35  66 24
	xor XIX,XIX                                          ; F99C37  ec d4
	ld ix, (UI_DrawScratch:16)                                 ; F99C39  d1 40 26 24
.LF99C3D:
	push XIX                                             ; F99C3D  3c
	push XHL                                             ; F99C3E  3b
	xor XBC,XBC                                          ; F99C3F  e9 d1
	xor XHL,XHL                                          ; F99C41  eb d3
	ldw bc, 0x01                                         ; F99C43  31 01 00
	ldw hl, 0x01                                         ; F99C46  33 01 00
	ld XIY,Chars_F0D99A                                  ; F99C49  45 9a d9 f0 00
	ld a, 0x07:opc                                          ; F99C4E  21 07
	swi 7                                                ; F99C50  ff
	pop XHL                                              ; F99C51  5b
	pop XIX                                              ; F99C52  5c
	dec 1,L                                              ; F99C53  cf 69
	jr z, .LF99C5B                                       ; F99C55  66 04
	inc 1,IX                                             ; F99C57  dc 61
	jr .LF99C3D                                          ; F99C59  68 e2
.LF99C5B:
	ret                                                  ; F99C5B  0e
; ---------------------------------------------------------------------
; Paint_SysPartMidiSoundCombination -- paint the three-row label block of that menu
;
; Called from: prom_a Paint_Sending (`calr`) at 0xF99BE0
;          prom_a Paint_SystemExclusivePleaseWait (`calr`) at 0xF99CFF
; Evidence: one interpreter-A site at 0xF99C76, list 0xF0D7E2-0xF0D81B, which FRAMES
;           exactly and draws `SYS,PART&MIDI :`, `SOUND         :` and
;           `COMBINATION   :`.  Every morpheme of the name is in that text.  ⚠ What the
;           three rows' VALUES are is not established -- they are drawn elsewhere.
;           ⚠⚠ THIS TOO CORRECTS ROUND 5's `Not one of these lists holds an .ascii
;           record` on this label; it holds three.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_SysPartMidiSoundCombination:
	and L,0x7f                                           ; F99C5C  cf cc 7f
	jr nz, .LF99C7C                                      ; F99C5F  6e 1b
	ld XIY,Paint_SysPartMidiSoundCombination_DL                                     ; F99C61  45 e2 d7 f0 00
	ld XIX,DL_F0D82E                                     ; F99C66  44 2e d8 f0 00
	cp	(Variant_Flag:8), 0x02                               ; F99C6B  c0 c4 3f 02
	jr nz, .LF99C76                                      ; F99C6F  6e 05
	ld XIX,DL_F0D81B                                     ; F99C71  44 1b d8 f0 00
.LF99C76:
	call T_DisplayList_Run                               ; F99C76  1d f0 17 f4
	jr .LF99CA0                                          ; F99C7A  68 24
.LF99C7C:
	cp	(Variant_Flag:8), 0x02                               ; F99C7C  c0 c4 3f 02
	jr nz, .LF99C94                                      ; F99C80  6e 12
	cp l, 0x07:i3                                          ; F99C82  cf df
	jr z, .LF99CA0                                       ; F99C84  66 1a
	cp L,0x08                                            ; F99C86  cf cf 08
	jr z, .LF99CA0                                       ; F99C89  66 15
	cp l, 0x07:i3                                          ; F99C8B  cf df
	jr z, .LF99CA0                                       ; F99C8D  66 11
	cp L,0x08                                            ; F99C8F  cf cf 08
	jr z, .LF99CA0                                       ; F99C92  66 0c
.LF99C94:
	sla hl, 0x02                                         ; F99C94  db ec 02
	ld	iy, (xiy+hl)                                 ; F99C97  d3 07 f4 ec 25
	call T_DLHandler_IX_Text                             ; F99C9C  1d 2c 18 f4
.LF99CA0:
	ret                                                  ; F99CA0  0e
; Paint_SystemExclusivePleaseWait -- paints the screen whose own text reads "SYSTEM EXCLUSIVE", "PLEASE WAIT!", "RECEIVING"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF99CB5  interpreter A  list 0xF0D7A7  DL_SystemExclusivePleaseWait
;        text: "SYSTEM EXCLUSIVE"; "PLEASE WAIT!"; "RECEIVING"
; Evidence: the list address is the `ld XIY,0x00F0D7A7` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_SystemExclusivePleaseWait:
	bit	1, (0x60f810:24)                             ; F99CA1  f2 10 f8 60 c9
	jr z, .LF99CBF                                       ; F99CA6  66 17
	calr LCD_ScreenRedraw_Begin                                      ; F99CA8  1e 45 fd
	ld XIY,DL_SystemExclusivePleaseWait                  ; F99CAB  45 a7 d7 f0 00
	ld XIX,Paint_SysPartMidiSoundCombination_DL                                     ; F99CB0  44 e2 d7 f0 00
	call T_DisplayList_Run                               ; F99CB5  1d f0 17 f4
	and	(0x60f810:24), 0xfd                          ; F99CB9  c2 10 f8 60 3c fd
.LF99CBF:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F99CBF  f1 40 25 00 02
	xor XHL,XHL                                          ; F99CC4  eb d3
	ld l, (0x60f80c:24)                                 ; F99CC6  c2 0c f8 60 27
	bit 0x07,L                                           ; F99CCB  cf 33 07
	jr z, .LF99CD9                                       ; F99CCE  66 09
	calr SysexProgressBar_DrawDots                                      ; F99CD0  1e 1a ff
	and	(0x60f80c:24), 0x7f                          ; F99CD3  c2 0c f8 60 3c 7f
.LF99CD9:
	xor XHL,XHL                                          ; F99CD9  eb d3
	ld l, (0x60f80e:24)                                 ; F99CDB  c2 0e f8 60 27
	bit 0x07,L                                           ; F99CE0  cf 33 07
	jr z, .LF99CEE                                       ; F99CE3  66 09
	calr SysexProgressBar_FillCells                                      ; F99CE5  1e 4a ff
	and	(0x60f80e:24), 0x7f                          ; F99CE8  c2 0e f8 60 3c 7f
.LF99CEE:
	xor XHL,XHL                                          ; F99CEE  eb d3
	ld l, (0x60f80a:24)                                 ; F99CF0  c2 0a f8 60 27
	bit 0x07,L                                           ; F99CF5  cf 33 07
	jr z, .LF99D08                                       ; F99CF8  66 0e
	ld XIY,DLPtrTable_F0D96E                             ; F99CFA  45 6e d9 f0 00
	calr Paint_SysPartMidiSoundCombination                                      ; F99CFF  1e 5a ff
	and	(0x60f80a:24), 0x7f                          ; F99D02  c2 0a f8 60 3c 7f
.LF99D08:
	calr LCD_ScreenRedraw_End                                      ; F99D08  1e f3 fc
	ret                                                  ; F99D0B  0e
; Paint_GeneralMidiMode -- paints the screen whose own text reads "GENERAL MIDI", "MIDI", " GENERAL MIDI MODE  :  "
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 5 time(s); XIY = list start, XIX = list end.  2 of those 5 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF99D67  interpreter A  list 0xF0D9E2  DL_GeneralMidiMidiGeneralMidiMode
;        text: "GENERAL MIDI"; "MIDI"; " GENERAL MIDI MODE  :  "; " ON"; " OFF"
;     site 0xF99D80  interpreter A  list 0xF0DAA2  DL_GeneralMidiMidiYesNo
;        text: "GENERAL MIDI"; "MIDI"; " YES"; " NO"
; Evidence: the list address is the `ld XIY,0x00F0D9E2` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_GeneralMidiMode:
	call T_CallbackQueue_ResetAndRestartTask2            ; F99D0C  1d 80 2e f4
	ld a, (UI_ScreenLatch:16)                                   ; F99D10  c1 7a 20 21
	cp	a, (UI_ScreenLatch_Previous:16)                               ; F99D14  c1 7b 20 f1
	jr z, .LF99D30                                       ; F99D18  66 16
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; F99D1A  1d 94 25 f4
	ld (0x2740:16), 0x00                                 ; F99D1E  f1 40 27 00 00
	ld (0x274c:16), 0x00                                 ; F99D23  f1 4c 27 00 00
	ld a, (0x7f4d:16)                                   ; F99D28  c1 4d 7f 21
	ld (UI_ScreenItem:16), a                                   ; F99D2C  f1 20 27 41
.LF99D30:
	bit	2, (0x274c:16)                               ; F99D30  f1 4c 27 ca
	jr z, .LF99D3F                                       ; F99D34  66 09
	ldw (UI_Request:16), 0x0201                              ; F99D36  f1 70 20 02 01 02
	jrl .LF99DC5                                         ; F99D3C  78 86 00
.LF99D3F:
	calr LCD_ScreenRedraw_Begin                                      ; F99D3F  1e ae fc
	cp	(0x2740:16), 0x00                            ; F99D42  c1 40 27 3f 00
	jr nz, .LF99D76                                      ; F99D47  6e 2d
	bit	1, (0x274c:16)                               ; F99D49  f1 4c 27 c9
	jr z, .LF99D5D                                       ; F99D4D  66 0e
	ld XIY,DL_F0DA73                                     ; F99D4F  45 73 da f0 00
	ld XIX,DL_F0DA93                                     ; F99D54  44 93 da f0 00
	call T_DisplayList_Run                               ; F99D59  1d f0 17 f4
.LF99D5D:
	ld XIY,DL_GeneralMidiMidiGeneralMidiMode             ; F99D5D  45 e2 d9 f0 00
	ld XIX,DL_F0DA73                                     ; F99D62  44 73 da f0 00
	call T_DisplayList_Run                               ; F99D67  1d f0 17 f4
	ld XIY,DL_F0DA93                                     ; F99D6B  45 93 da f0 00
	call T_DLB_Handler_StringTable                       ; F99D70  1d f8 17 f4
	jr .LF99DC2                                          ; F99D74  68 4c
.LF99D76:
	ld XIY,DL_GeneralMidiMidiYesNo                       ; F99D76  45 a2 da f0 00
	ld XIX,PTR_F0DB18                                    ; F99D7B  44 18 db f0 00
	call T_DisplayList_Run                               ; F99D80  1d f0 17 f4
	xor XDE,XDE                                          ; F99D84  ea d2
	xor XBC,XBC                                          ; F99D86  e9 d1
	ld e, (0x7fc1:16)                                   ; F99D88  c1 c1 7f 25
	ld c, 0x04:opc                                          ; F99D8C  23 04
	mul bc, e                                          ; F99D8E  cd 43
	push XBC                                             ; F99D90  39
	ld XHL,PTR_F0DB18                                    ; F99D91  43 18 db f0 00
	ld	xiy, (xhl+bc)                                ; F99D96  e3 07 ec e4 25
	ld XHL,0x00f0db2c                                    ; F99D9B  43 2c db f0 00
	ld	xix, (xhl+bc)                                ; F99DA0  e3 07 ec e4 24
	call T_DisplayList_Run                               ; F99DA5  1d f0 17 f4
	pop XBC                                              ; F99DA9  59
	ld XHL,0x00f0db40                                    ; F99DAA  43 40 db f0 00
	ld	xiy, (xhl+bc)                                ; F99DAF  e3 07 ec e4 25
	ld XHL,0x00f0db54                                    ; F99DB4  43 54 db f0 00
	ld	xix, (xhl+bc)                                ; F99DB9  e3 07 ec e4 24
	call T_DisplayListB_Run                              ; F99DBE  1d f4 17 f4
.LF99DC2:
	calr LCD_ScreenRedraw_End                                      ; F99DC2  1e 39 fc
.LF99DC5:
	ret                                                  ; F99DC5  0e
; ScreenLeave_GeneralMidiMode -- the GeneralMidiMode LEAVE body: call T_Playback_AcceptMidiStartAgain (prom_a 0xFE1CA7) unless
; (0x207A) == (0x207B)
; Evidence: only caller ScreenLeave_GeneralMidiMode_Entry (0xF99848, the object's +4 slot);
; Paint_GeneralMidiMode makes the paired call T_Playback_StopAllAndIgnoreMidiStart under the same test (0xF99D1A).
ScreenLeave_GeneralMidiMode:
	ld a, (UI_ScreenLatch:16)                                   ; F99DC6  c1 7a 20 21
	cp	a, (UI_ScreenLatch_Previous:16)                               ; F99DCA  c1 7b 20 f1
	jr z, .LF99DD4                                       ; F99DCE  66 04
	call T_Playback_AcceptMidiStartAgain                                        ; F99DD0  1d dc 25 f4
.LF99DD4:
	ret                                                  ; F99DD4  0e
ScreenButtonRow_GeneralMidi_Page0_Nop0:   ; entry: named by 1 `.long` operand, first at 0xF998F0
	ret                                                  ; F99DD5  0e
ScreenButtonRow_GeneralMidi_Page0_Nop1:   ; entry: named by 1 `.long` operand, first at 0xF998F4
	ret                                                  ; F99DD6  0e
ScreenButtonRow_GeneralMidi_Page0_Nop2:   ; entry: named by 1 `.long` operand, first at 0xF998F8
	ret                                                  ; F99DD7  0e
ScreenButtonRow_GeneralMidi_Page0_Nop3:   ; entry: named by 1 `.long` operand, first at 0xF998FC
	ret                                                  ; F99DD8  0e
ScreenButtonRow_GeneralMidi_Page0_Nop4:   ; entry: named by 1 `.long` operand, first at 0xF99900
	ret                                                  ; F99DD9  0e
ScreenButtonRow_GeneralMidi_Page0_Nop5:   ; entry: named by 1 `.long` operand, first at 0xF99904
	ret                                                  ; F99DDA  0e
ScreenButtonRow_GeneralMidi_Page0_Nop6:   ; entry: named by 1 `.long` operand, first at 0xF99908
	ret                                                  ; F99DDB  0e
ScreenButtonRow_GeneralMidi_Page0_Nop7:   ; entry: named by 1 `.long` operand, first at 0xF9990C
	ret                                                  ; F99DDC  0e
; LcdKeyRow1_GeneralMidiMode_Page0 -- LCD row 1, right key (bit 7 of W clear) = OK: once OK is shown (bit 1
; of (0x274C)) switch to the YES/NO page, (0x2740) = 1, and request a redraw, (0x2071) = 0x10
; Evidence: ScreenButtonRow_GeneralMidi_Page0[8]; DL_F0DA73 draws ' OK' at LCD 0x059B (row 1, right end) and
; is drawn, with (0x274C) |= 2, by LcdKeyRow3/4_GeneralMidiMode_Page0; (0x2740) picks the button row and the
; page Paint_GeneralMidiMode draws (ScreenButtonRow_GeneralMidi_YesNo / DL_GeneralMidiMidiYesNo).
LcdKeyRow1_GeneralMidiMode_Page0:   ; entry: named by 1 `.long` operand, first at 0xF99910
	bit	1, (0x274c:16)                               ; F99DDD  f1 4c 27 c9
	jr z, .LF99DF2                                       ; F99DE1  66 0f
	bit 0x07,W                                           ; F99DE3  c8 33 07
	jr nz, .LF99DF2                                      ; F99DE6  6e 0a
	ld (0x2740:16), 0x01                                 ; F99DE8  f1 40 27 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; F99DED  f1 71 20 00 10
.LF99DF2:
	ret                                                  ; F99DF2  0e
ScreenButtonRow_GeneralMidi_Page0_Nop9:   ; entry: named by 1 `.long` operand, first at 0xF99914
	ret                                                  ; F99DF3  0e
; LcdKeyRow3_GeneralMidiMode_Page0 -- LCD row 3, right key = ON: set bit 2 of (0x2720), redraw the value
; (DL_F0DA93 via T_DLB_Handler_StringTable) and, the first time, show ' OK' (DL_F0DA73, (0x274C) |= 2)
; Evidence: ScreenButtonRow_GeneralMidi_Page0[10] (code 0x0A), guarded by `bit 7,W` and `bit 2,(0x2720)`;
; DL_GeneralMidiMidiGeneralMidiMode draws ' ON' at LCD 0x11CA and ' OFF' at 0x17E2 (rows 3 and 4,
; right end); Paint_GeneralMidiMode loads (0x2720) from (0x7F4D), record 0x91 byte 3.
LcdKeyRow3_GeneralMidiMode_Page0:   ; entry: named by 1 `.long` operand, first at 0xF99918
	bit 0x07,W                                           ; F99DF4  c8 33 07
	jr nz, .LF99E2B                                      ; F99DF7  6e 32
	bit	2, (UI_ScreenItem:16)                               ; F99DF9  f1 20 27 ca
	jr nz, .LF99E2B                                      ; F99DFD  6e 2c
	or	(UI_ScreenItem:16), 0x04                            ; F99DFF  c1 20 27 3e 04
	ld (LCD_CurrentLayer:16), 0x00                                 ; F99E04  f1 40 25 00 00
	ld XIY,DL_F0DA93                                     ; F99E09  45 93 da f0 00
	call T_DLB_Handler_StringTable                       ; F99E0E  1d f8 17 f4
	bit	1, (0x274c:16)                               ; F99E12  f1 4c 27 c9
	jr nz, .LF99E2B                                      ; F99E16  6e 13
	ld XIY,DL_F0DA73                                     ; F99E18  45 73 da f0 00
	ld XIX,DL_F0DA93                                     ; F99E1D  44 93 da f0 00
	call T_DisplayList_Run                               ; F99E22  1d f0 17 f4
	or	(0x274c:16), 0x02                            ; F99E26  c1 4c 27 3e 02
.LF99E2B:
	ret                                                  ; F99E2B  0e
; LcdKeyRow4_GeneralMidiMode_Page0 -- LCD row 4, right key = OFF: clear bit 2 of (0x2720), redraw the value
; (DL_F0DA93) and, the first time, show ' OK' (DL_F0DA73, (0x274C) |= 2)
; Evidence: ScreenButtonRow_GeneralMidi_Page0[11] (code 0x0B); `and (0x2720),0xFB` at 0xF99E37;
; DL_GeneralMidiMidiGeneralMidiMode draws ' ON' at LCD 0x11CA and ' OFF' at 0x17E2 (rows 3 and 4,
; right end); Paint_GeneralMidiMode loads (0x2720) from (0x7F4D), record 0x91 byte 3.
LcdKeyRow4_GeneralMidiMode_Page0:   ; entry: named by 1 `.long` operand, first at 0xF9991C
	bit 0x07,W                                           ; F99E2C  c8 33 07
	jr nz, .LF99E63                                      ; F99E2F  6e 32
	bit	2, (UI_ScreenItem:16)                               ; F99E31  f1 20 27 ca
	jr z, .LF99E63                                       ; F99E35  66 2c
	and	(UI_ScreenItem:16), 0xfb                            ; F99E37  c1 20 27 3c fb
	ld (LCD_CurrentLayer:16), 0x00                                 ; F99E3C  f1 40 25 00 00
	ld XIY,DL_F0DA93                                     ; F99E41  45 93 da f0 00
	call T_DLB_Handler_StringTable                       ; F99E46  1d f8 17 f4
	bit	1, (0x274c:16)                               ; F99E4A  f1 4c 27 c9
	jr nz, .LF99E63                                      ; F99E4E  6e 13
	ld XIY,DL_F0DA73                                     ; F99E50  45 73 da f0 00
	ld XIX,DL_F0DA93                                     ; F99E55  44 93 da f0 00
	call T_DisplayList_Run                               ; F99E5A  1d f0 17 f4
	or	(0x274c:16), 0x02                            ; F99E5E  c1 4c 27 3e 02
.LF99E63:
	ret                                                  ; F99E63  0e
ScreenButtonRow_GeneralMidi_Page0_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF99920
	ret                                                  ; F99E64  0e
ScreenButtonRow_GeneralMidi_Page0_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF99924
	ret                                                  ; F99E65  0e
ScreenButtonRow_GeneralMidi_Page0_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF99928
	ret                                                  ; F99E66  0e
; ExitKey_GeneralMidiMode_Page0 -- EXIT (panel code 0x0F) on GeneralMidiMode's main page: `calr
; ExitKey_SysexGeneralMidiShared / ret`
; Evidence: ScreenButtonRow_GeneralMidi_Page0[15].
ExitKey_GeneralMidiMode_Page0:   ; entry: named by 1 `.long` operand, first at 0xF9992C
	calr ExitKey_SysexGeneralMidiShared                                          ; F99E67  1e fa f9
	ret                                                  ; F99E6A  0e
ScreenButtonRow_GeneralMidi_Page0_Nop16:   ; entry: named by 1 `.long` operand, first at 0xF99930
	ret                                                  ; F99E6B  0e
ScreenButtonRow_GeneralMidi_Page0_Nop17:   ; entry: named by 1 `.long` operand, first at 0xF99934
	ret                                                  ; F99E6C  0e
ScreenButtonRow_GeneralMidi_Page0_Nop18:   ; entry: named by 1 `.long` operand, first at 0xF99938
	ret                                                  ; F99E6D  0e
ScreenButtonRow_GeneralMidi_Page0_Nop19:   ; entry: named by 1 `.long` operand, first at 0xF9993C
	ret                                                  ; F99E6E  0e
ScreenButtonRow_GeneralMidi_Page0_Nop20:   ; entry: named by 1 `.long` operand, first at 0xF99940
	ret                                                  ; F99E6F  0e
ScreenButtonRow_GeneralMidi_Page0_Nop21:   ; entry: named by 1 `.long` operand, first at 0xF99944
	ret                                                  ; F99E70  0e
ScreenButtonRow_GeneralMidi_Page0_Nop22:   ; entry: named by 1 `.long` operand, first at 0xF99948
	ret                                                  ; F99E71  0e
ScreenButtonRow_GeneralMidi_Page0_Nop23:   ; entry: named by 1 `.long` operand, first at 0xF9994C
	ret                                                  ; F99E72  0e
ScreenButtonRow_GeneralMidi_Page0_Nop24:   ; entry: named by 1 `.long` operand, first at 0xF99950
	ret                                                  ; F99E73  0e
ScreenButtonRow_GeneralMidi_Page0_Nop25:   ; entry: named by 1 `.long` operand, first at 0xF99954
	ret                                                  ; F99E74  0e
ScreenButtonRow_GeneralMidi_Page0_Nop26:   ; entry: named by 1 `.long` operand, first at 0xF99958
	ret                                                  ; F99E75  0e
ScreenButtonRow_GeneralMidi_Page0_Nop27:   ; entry: named by 1 `.long` operand, first at 0xF9995C
	ret                                                  ; F99E76  0e
ScreenButtonRow_GeneralMidi_Page0_Nop28:   ; entry: named by 1 `.long` operand, first at 0xF99960
	ret                                                  ; F99E77  0e
ScreenButtonRow_GeneralMidi_Page0_Nop29:   ; entry: named by 1 `.long` operand, first at 0xF99964
	ret                                                  ; F99E78  0e
ScreenButtonRow_GeneralMidi_Page0_Nop30:   ; entry: named by 1 `.long` operand, first at 0xF99968
	ret                                                  ; F99E79  0e
ScreenButtonRow_GeneralMidi_Page0_Nop31:   ; entry: named by 1 `.long` operand, first at 0xF9996C
	ret                                                  ; F99E7A  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop0:   ; entry: named by 1 `.long` operand, first at 0xF99970
	ret                                                  ; F99E7B  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop1:   ; entry: named by 1 `.long` operand, first at 0xF99974
	ret                                                  ; F99E7C  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop2:   ; entry: named by 1 `.long` operand, first at 0xF99978
	ret                                                  ; F99E7D  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop3:   ; entry: named by 1 `.long` operand, first at 0xF9997C
	ret                                                  ; F99E7E  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop4:   ; entry: named by 1 `.long` operand, first at 0xF99980
	ret                                                  ; F99E7F  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop5:   ; entry: named by 1 `.long` operand, first at 0xF99984
	ret                                                  ; F99E80  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop6:   ; entry: named by 1 `.long` operand, first at 0xF99988
	ret                                                  ; F99E81  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop7:   ; entry: named by 1 `.long` operand, first at 0xF9998C
	ret                                                  ; F99E82  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop8:   ; entry: named by 1 `.long` operand, first at 0xF99990
	ret                                                  ; F99E83  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop9:   ; entry: named by 1 `.long` operand, first at 0xF99994
	ret                                                  ; F99E84  0e
; LcdKeyRow3_GeneralMidiYesNo -- YES on the GENERAL MIDI confirm page: commit the GM-mode choice, then leave
; Evidence: ScreenButtonRow_GeneralMidi_YesNo [74] = page 1, code 0x0A (LCD row 3); " YES" is drawn at 0x11CA by the
;   row-3 right arrow.  Right-hand key only (W bit 7 clear).  (0x2720) bit 2 -- Paint_GeneralMidiMode's copy of
;   (0x7F4D) -- goes to (0x7F4D) bit 2 if it differs, posting {0x91,3,A,4} by T_Queue2C00_AppendRegs (as at
;   0xF818C5); then (0x2740)=0, (0x2880)=0x23, (0x274C)|=4, and (0x2070)=0xAB/(0x2071)=0x40 requests screen 0xAB.
LcdKeyRow3_GeneralMidiYesNo:   ; entry: named by 1 `.long` operand, first at 0xF99998
	bit 0x07,W                                           ; F99E85  c8 33 07
	jr nz, .LF99ED0                                      ; F99E88  6e 46
	and	(UI_RequestBits:16), 0x6f                            ; F99E8A  c1 75 20 3c 6f
	bit	2, (UI_ScreenItem:16)                               ; F99E8F  f1 20 27 ca
	jr z, .LF99EA4                                       ; F99E93  66 0f
	bit	2, (0x7f4d:16)                               ; F99E95  f1 4d 7f ca
	jr nz, .LF99EBB                                      ; F99E99  6e 20
	or	(0x7f4d:16), 0x04                            ; F99E9B  c1 4d 7f 3e 04
	ld a, 0x04:opc                                          ; F99EA0  21 04
	jr .LF99EB1                                          ; F99EA2  68 0d
.LF99EA4:
	bit	2, (0x7f4d:16)                               ; F99EA4  f1 4d 7f ca
	jr z, .LF99EBB                                       ; F99EA8  66 11
	and	(0x7f4d:16), 0xfb                            ; F99EAA  c1 4d 7f 3c fb
	ld a, 0x00:opc                                          ; F99EAF  21 00
.LF99EB1:
	ld w, 0x04:opc                                          ; F99EB1  20 04
	ld e, 0x91:opc                                          ; F99EB3  25 91
	ld d, 0x03:opc                                          ; F99EB5  24 03
	call T_Queue2C00_AppendRegs                          ; F99EB7  1d 38 0f f4
.LF99EBB:
	ld (0x2740:16), 0x00                                 ; F99EBB  f1 40 27 00 00
	ld (UI_StatusCode:16), 0x23                                 ; F99EC0  f1 80 28 00 23
	or	(0x274c:16), 0x04                            ; F99EC5  c1 4c 27 3e 04
	ldw (UI_Request:16), 0x40ab                              ; F99ECA  f1 70 20 02 ab 40
.LF99ED0:
	ret                                                  ; F99ED0  0e
; LcdKeyRow4_GeneralMidiYesNo -- NO on the GENERAL MIDI confirm page: back to page 0 without touching (0x7F4D)
; Evidence: ScreenButtonRow_GeneralMidi_YesNo entry [75] = code 0x0B (LCD row 4); " NO" is drawn at 0x17E2 beside
;   the row-4 right arrow (0x17BF).  Right-hand key only (W bit 7 clear): (0x2740)=0 selects the page-0 row, and
;   (0x2071)=0x10 is bit 4, which PanelButton_Route (0xF86230) turns into the redraw bit of (0x2072).
LcdKeyRow4_GeneralMidiYesNo:   ; entry: named by 1 `.long` operand, first at 0xF9999C
	bit 0x07,W                                           ; F99ED1  c8 33 07
	jr nz, .LF99EE0                                      ; F99ED4  6e 0a
	ld (0x2740:16), 0x00                                 ; F99ED6  f1 40 27 00 00
	ld (UI_Request_Hi:16), 0x10                                 ; F99EDB  f1 71 20 00 10
.LF99EE0:
	ret                                                  ; F99EE0  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF999A0
	ret                                                  ; F99EE1  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF999A4
	ret                                                  ; F99EE2  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF999A8
	ret                                                  ; F99EE3  0e
; ExitKey_GeneralMidiYesNo -- EXIT on the GENERAL MIDI confirm page: back to page 0, as NO does
; Evidence: ScreenButtonRow_GeneralMidi_YesNo entry [79] = code 0x0F (EXIT); byte-for-byte the body of
;   LcdKeyRow4_GeneralMidiYesNo: guard W bit 7 clear, (0x2740)=0, (0x2071)=0x10 (redraw).
ExitKey_GeneralMidiYesNo:   ; entry: named by 1 `.long` operand, first at 0xF999AC
	bit 0x07,W                                           ; F99EE4  c8 33 07
	jr nz, .LF99EF3                                      ; F99EE7  6e 0a
	ld (0x2740:16), 0x00                                 ; F99EE9  f1 40 27 00 00
	ld (UI_Request_Hi:16), 0x10                                 ; F99EEE  f1 71 20 00 10
.LF99EF3:
	ret                                                  ; F99EF3  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop16:   ; entry: named by 1 `.long` operand, first at 0xF999B0
	ret                                                  ; F99EF4  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop17:   ; entry: named by 1 `.long` operand, first at 0xF999B4
	ret                                                  ; F99EF5  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop18:   ; entry: named by 1 `.long` operand, first at 0xF999B8
	ret                                                  ; F99EF6  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop19:   ; entry: named by 1 `.long` operand, first at 0xF999BC
	ret                                                  ; F99EF7  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop20:   ; entry: named by 1 `.long` operand, first at 0xF999C0
	ret                                                  ; F99EF8  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop21:   ; entry: named by 1 `.long` operand, first at 0xF999C4
	ret                                                  ; F99EF9  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop22:   ; entry: named by 1 `.long` operand, first at 0xF999C8
	ret                                                  ; F99EFA  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop23:   ; entry: named by 1 `.long` operand, first at 0xF999CC
	ret                                                  ; F99EFB  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop24:   ; entry: named by 1 `.long` operand, first at 0xF999D0
	ret                                                  ; F99EFC  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop25:   ; entry: named by 1 `.long` operand, first at 0xF999D4
	ret                                                  ; F99EFD  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop26:   ; entry: named by 1 `.long` operand, first at 0xF999D8
	ret                                                  ; F99EFE  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop27:   ; entry: named by 1 `.long` operand, first at 0xF999DC
	ret                                                  ; F99EFF  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop28:   ; entry: named by 1 `.long` operand, first at 0xF999E0
	ret                                                  ; F99F00  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop29:   ; entry: named by 1 `.long` operand, first at 0xF999E4
	ret                                                  ; F99F01  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop30:   ; entry: named by 1 `.long` operand, first at 0xF999E8
	ret                                                  ; F99F02  0e
ScreenButtonRow_GeneralMidi_YesNo_Nop31:   ; entry: named by 1 `.long` operand, first at 0xF999EC
	ret                                                  ; F99F03  0e
; PanelMode_MidiEnter -- Enter method of panel MODE 0x12 (MIDI): flag the mode change and run T_SoundGroup_ReloadSelection
; Evidence: view-A entry 18 of PanelScreen_VtableTable (0xF86F09) -> object 0xF41640, +0 `jp 0xF99F04`, called by
;   PanelScreen_CallEnter_A with the mode (0x2078).  PanelMode_ToScreenIdMap[0x12] = 0x70, Paint_MidiMenu's screen,
;   and MidiSubmenu_ExitToMidiMenu requests mode 0x12.  Body: `set 1,(0x2134)` (the bit PanelState_ClearOnChange
;   sets on a mode change), then T_SoundGroup_ReloadSelection (sub_F9433A), XDE/XHL/XIX/XIZ kept -- the shape of mode 0x0A's Enter,
;   0xF9FED1.
PanelMode_MidiEnter:
	set	1, (0x2134:16)                               ; F99F04  f1 34 21 b9
	push XDE                                             ; F99F08  3a
	push XHL                                             ; F99F09  3b
	push XIX                                             ; F99F0A  3c
	push XIZ                                             ; F99F0B  3e
	call T_SoundGroup_ReloadSelection                                        ; F99F0C  1d c8 15 f4
	pop XIZ                                              ; F99F10  5e
	pop XIX                                              ; F99F11  5c
	pop XHL                                              ; F99F12  5b
	pop XDE                                              ; F99F13  5a
	ret                                                  ; F99F14  0e
; PanelMode_MidiLeave -- Leave method of panel MODE 0x12 (MIDI): only `set 1,(0x2134)`
; Evidence: object 0xF41640's +4 slot T_PanelMode_MidiLeave is `jp 0xF99F15`; PanelScreen_CallLeave_A calls +4 with the mode that
;   stopped being current.  Same body as mode 0x0A's Leave at 0xF9FEE2.
PanelMode_MidiLeave:
	set	1, (0x2134:16)                               ; F99F15  f1 34 21 b9
	ret                                                  ; F99F19  0e
; Var2134_SetBit1: m_set 1, MD16, 0x2134 (single-cell template; the cell's meaning is not established unless it is named)
Var2134_SetBit1:
	set	1, (0x2134:16)                               ; F99F1A  f1 34 21 b9
	ret                                                  ; F99F1E  0e
; Var2134_SetBit1_2: m_set 1, MD16, 0x2134 (single-cell template; the cell's meaning is not established unless it is named)
Var2134_SetBit1_2:
	set	1, (0x2134:16)                               ; F99F1F  f1 34 21 b9
	ret                                                  ; F99F23  0e
; Paint_MidiMenu -- ENTER method of screen 0x70, the MIDI menu: paints its index of MIDI sub-screens
; Evidence: ViewB [112] (0xF87101) -> object 0xF41650, +0 `jp 0xF99F24`; PanelMode_ToScreenIdMap[0x12] = 0x70. Lists
;   on the stack: site 0xF99F45 0xF0C800-0xF0C8D5 when (0xC4)==2 ("INPUT&0UTPUT" "FILTER" "MIDI" "T0TAL M0DE"
;   "C0NFIGURE" "PR0G" "CHANGE" "MIDI 0UT" "SYSEX" ...), else site 0xF99F37 0xF0C81F-0xF0C917 (adds "REALTIME"). The
;   title is op-0x1C "MIDI"; ScreenButton_MidiMenu's row keys request exactly the captioned screens. Named like
;   Paint_DiskMenu, after the MENU -- round 7's refusal of a CAPTION name still holds.
Paint_MidiMenu:
	call T_CallbackQueue_ResetAndRestartTask2            ; F99F24  1d 80 2e f4
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F99F28  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F99F2C  f1 40 25 00 00
	cp	(Variant_Flag:8), 0x02                               ; F99F31  c0 c4 3f 02
	jr z, .LF99F45                                       ; F99F35  66 0e
	lda xbc, (DL_F0C917:24)                              ; F99F37  f2 17 c9 f0 31
	push XBC                                             ; F99F3C  39
	lda xwa, (0xf0c81f:24)                               ; F99F3D  f2 1f c8 f0 30
	push XWA                                             ; F99F42  38
	jr .LF99F51                                          ; F99F43  68 0c
.LF99F45:
	lda xbc, (DL_RealtimeMessageInput0utput:24)          ; F99F45  f2 d5 c8 f0 31
	push XBC                                             ; F99F4A  39
	lda xwa, (DL_Input0utputFilterMidiT0talM0de:24)      ; F99F4B  f2 00 c8 f0 30
	push XWA                                             ; F99F50  38
.LF99F51:
	call T_DisplayList_Run_Stack                         ; F99F51  1d 00 2e f4
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F99F55  1d 14 2e f4
	inc 8,XSP                                            ; F99F59  ef 60
	ret                                                  ; F99F5B  0e
T_F41654_Nop:
	ret                                                  ; F99F5C  0e
T_F4165C_Nop:
	ret                                                  ; F99F5D  0e
; ScreenButton_MidiMenu -- BUTTON method of screen 0x70 (the MIDI menu): dispatch the panel code via
;   JumpTable_F99F96
; Evidence: object 0xF41650's +8 slot T_ScreenButton_MidiMenu is `jp 0xF99F5E` (PanelButton_Route calls +8).  H = 1 when bit 7 of
;   the forwarded flag (XIZ+0x0A) is set (pair position 0, the left-hand LCD key) and is handed to the arm.
; Live codes: 0x08-0x0B -> LcdKeyRow1..4_MidiMenu, 0x0F -> ExitKey_MidiMenu; the other 27 -> IgnoredKeys_MidiMenu.
ScreenButton_MidiMenu:
	link XIZ,0x0000                                      ; F99F5E  ee 0c 00 00
	pushw hl                                             ; F99F62  2b
	cpw	(xiz+8), 0x001f                              ; F99F63  9e 08 3f 1f 00
	jrl ugt, .LF9A047                                        ; F99F68  7b dc 00
	ld L,(XIZ+0x08)                                      ; F99F6B  8e 08 27
	ld C,(XIZ+0x0a)                                      ; F99F6E  8e 0a 23
	and C,0x80                                           ; F99F71  cb cc 80
	jr nz, .LF99F7A                                      ; F99F74  6e 04
	ld h, 0x00:opc                                          ; F99F76  26 00
	jr .LF99F7C                                          ; F99F78  68 02
.LF99F7A:
	ld h, 0x01:opc                                          ; F99F7A  26 01
.LF99F7C:
	ld C,L                                               ; F99F7C  cf 8b
	extz BC                                              ; F99F7E  d9 12
	extz XBC                                             ; F99F80  e9 12
	cp BC,0x001f                                         ; F99F82  d9 cf 1f 00
	jrl ugt, .LF9A047                                        ; F99F86  7b be 00
	sll bc, 0x02                                         ; F99F89  d9 ee 02
	add XBC,JumpTable_F99F96                             ; F99F8C  e9 c8 96 9f f9 00
	ld XBC,(XBC)                                         ; F99F92  a1 21
	jp (xbc)                                             ; F99F94  b1 d8
; ---------------------------------------------------------------------
; JumpTable_F99F96 -- 32 LE32 branch targets
;
; Read by: ONE site, `cp BC,0x001F / jrl UGT,0xF9A047 / sll 0x02,BC /
;          add XBC,0x00F99F96 / ld XBC,(XBC) / jp T,XBC` at 0xF99F82-0xF99F95.
; ENTRY COUNT 32, from the reader's own `cp BC,0x001F`.  ★ LAST-ENTRY TEST:
;          0xF99F96 + 32*4 = 0xF9A016, and 0xF9A016 is the MINIMUM value any
;          entry holds -- the table abuts its own first arm.  31 or 33 entries
;          break that.  Re-derived by notes/prom_a_jumptables.py.
; Evidence: the reader shape, the bound, and the abutment above.
; Selector: the panel BUTTON CODE.  ScreenButton_MidiMenu (0xF99F5E) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x90 (prom_b
;          slot 0xF41658); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld L,(XIZ+0x08)` ... `ld C,L / cp BC,0x001F / sll 2,BC /
;          add XBC,<this> / ld XBC,(XBC) / jp (XBC)`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Six distinct arms among the 32 slots.
; ---------------------------------------------------------------------
JumpTable_F99F96:
	.long IgnoredKeys_MidiMenu                                 ; F99F96  [  0]
	.long IgnoredKeys_MidiMenu                                 ; F99F9A  [  1]
	.long IgnoredKeys_MidiMenu                                 ; F99F9E  [  2]
	.long IgnoredKeys_MidiMenu                                 ; F99FA2  [  3]
	.long IgnoredKeys_MidiMenu                                 ; F99FA6  [  4]
	.long IgnoredKeys_MidiMenu                                 ; F99FAA  [  5]
	.long IgnoredKeys_MidiMenu                                 ; F99FAE  [  6]
	.long IgnoredKeys_MidiMenu                                 ; F99FB2  [  7]
	.long LcdKeyRow1_MidiMenu                                 ; F99FB6  [  8]
	.long LcdKeyRow2_MidiMenu                                 ; F99FBA  [  9]
	.long LcdKeyRow3_MidiMenu                                 ; F99FBE  [ 10]
	.long LcdKeyRow4_MidiMenu                                 ; F99FC2  [ 11]
	.long IgnoredKeys_MidiMenu                                 ; F99FC6  [ 12]
	.long IgnoredKeys_MidiMenu                                 ; F99FCA  [ 13]
	.long IgnoredKeys_MidiMenu                                 ; F99FCE  [ 14]
	.long ExitKey_MidiMenu                                 ; F99FD2  [ 15]
	.long IgnoredKeys_MidiMenu                                 ; F99FD6  [ 16]
	.long IgnoredKeys_MidiMenu                                 ; F99FDA  [ 17]
	.long IgnoredKeys_MidiMenu                                 ; F99FDE  [ 18]
	.long IgnoredKeys_MidiMenu                                 ; F99FE2  [ 19]
	.long IgnoredKeys_MidiMenu                                 ; F99FE6  [ 20]
	.long IgnoredKeys_MidiMenu                                 ; F99FEA  [ 21]
	.long IgnoredKeys_MidiMenu                                 ; F99FEE  [ 22]
	.long IgnoredKeys_MidiMenu                                 ; F99FF2  [ 23]
	.long IgnoredKeys_MidiMenu                                 ; F99FF6  [ 24]
	.long IgnoredKeys_MidiMenu                                 ; F99FFA  [ 25]
	.long IgnoredKeys_MidiMenu                                 ; F99FFE  [ 26]
	.long IgnoredKeys_MidiMenu                                 ; F9A002  [ 27]
	.long IgnoredKeys_MidiMenu                                 ; F9A006  [ 28]
	.long IgnoredKeys_MidiMenu                                 ; F9A00A  [ 29]
	.long IgnoredKeys_MidiMenu                                 ; F9A00E  [ 30]
	.long IgnoredKeys_MidiMenu                                 ; F9A012  [ 31]
; LcdKeyRow1_MidiMenu -- switch arm of ScreenButton_MidiMenu for code 0x08 (LCD row 1):
;   MidiMenu_RequestRow1Screen(H)
; Evidence: JumpTable_F99F96 entry [8], its only slot; the arm ends `jr 0xF9A041` into ScreenButton_MidiMenu's own
;   `popw bc / popw hl / unlk / ret`, so it is a case of that routine, not a routine of its own.
LcdKeyRow1_MidiMenu:   ; entry: named by 1 `.long` operand, first at 0xF99FB6
	push 0x00                                            ; F9A016  09 00
	push H                                               ; F9A018  ce 04
	calr MidiMenu_RequestRow1Screen                                      ; F9A01A  1e 2e 00
	jr .LF9A041                                          ; F9A01D  68 22
; LcdKeyRow2_MidiMenu -- switch arm of ScreenButton_MidiMenu for code 0x09 (LCD row 2):
;   MidiMenu_RequestRow2Screen(H)
; Evidence: JumpTable_F99F96 entry [9], its only slot; the arm ends `jr 0xF9A041` into ScreenButton_MidiMenu's own
;   `popw bc / popw hl / unlk / ret`, so it is a case of that routine, not a routine of its own.
LcdKeyRow2_MidiMenu:   ; entry: named by 1 `.long` operand, first at 0xF99FBA
	push 0x00                                            ; F9A01F  09 00
	push H                                               ; F9A021  ce 04
	calr MidiMenu_RequestRow2Screen                                      ; F9A023  1e 41 00
	jr .LF9A041                                          ; F9A026  68 19
; LcdKeyRow3_MidiMenu -- switch arm of ScreenButton_MidiMenu for code 0x0A (LCD row 3):
;   MidiMenu_RequestRow3Screen(H)
; Evidence: JumpTable_F99F96 entry [10], its only slot; the arm ends `jr 0xF9A041` into ScreenButton_MidiMenu's own
;   `popw bc / popw hl / unlk / ret`, so it is a case of that routine, not a routine of its own.
LcdKeyRow3_MidiMenu:   ; entry: named by 1 `.long` operand, first at 0xF99FBE
	push 0x00                                            ; F9A028  09 00
	push H                                               ; F9A02A  ce 04
	calr MidiMenu_RequestRow3Screen                                      ; F9A02C  1e 61 00
	jr .LF9A041                                          ; F9A02F  68 10
; LcdKeyRow4_MidiMenu -- switch arm of ScreenButton_MidiMenu for code 0x0B (LCD row 4):
;   MidiMenu_RequestRow4Screen(H)
; Evidence: JumpTable_F99F96 entry [11], its only slot; the arm ends `jr 0xF9A041` into ScreenButton_MidiMenu's own
;   `popw bc / popw hl / unlk / ret`, so it is a case of that routine, not a routine of its own.
LcdKeyRow4_MidiMenu:   ; entry: named by 1 `.long` operand, first at 0xF99FC2
	push 0x00                                            ; F9A031  09 00
	push H                                               ; F9A033  ce 04
	calr MidiMenu_RequestRow4Screen                                      ; F9A035  1e 81 00
	jr .LF9A041                                          ; F9A038  68 07
; ExitKey_MidiMenu -- switch arm of ScreenButton_MidiMenu for code 0x0F (EXIT): MidiMenu_ExitToPowerOnMode(H)
; Evidence: JumpTable_F99F96 entry [15]; falls into ScreenButton_MidiMenu's shared epilogue at 0xF9A041.
ExitKey_MidiMenu:   ; entry: named by 1 `.long` operand, first at 0xF99FD2
	push 0x00                                            ; F9A03A  09 00
	push H                                               ; F9A03C  ce 04
	calr MidiMenu_ExitToPowerOnMode                                      ; F9A03E  1e 8f 00
.LF9A041:
	popw bc                                              ; F9A041  49
	jr .LF9A047                                          ; F9A042  68 03
; IgnoredKeys_MidiMenu -- default arm of ScreenButton_MidiMenu: calls MidiScreen_NopKeyHandler and returns
; Evidence: 27 of JumpTable_F99F96's 32 slots ([0]-[7], [12]-[14], [16]-[31]); continues at 0xF9A047, the epilogue.
IgnoredKeys_MidiMenu:   ; entry: named by 27 `.long` operands, first at 0xF99F96
	calr IgnoredKeys_MidiMenu_Nop                                      ; F9A044  1e eb 00
.LF9A047:
	popw hl                                              ; F9A047  4b
	unlk XIZ                                             ; F9A048  ee 0d
	ret                                                  ; F9A04A  0e
; MidiMenu_RequestRow1Screen -- MIDI menu LCD row 1: left key -> screen 0x7D (MIDI TOTAL MODE), right key -> screen
;   0xB2
; Evidence: (0x2071)=0x80 (PanelScreen_ApplyRequestForced) with (0x2070)=0x7D, replaced by 0xB2 when (XIZ+8)==0. Row
;   1 of the menu draws "T0TAL M0DE" at x=5 (0x05A5) and "C0NFIGURE" at x=23 (0x05B7); screen 0x7D's Enter is
;   Paint_MidiTotalMode, screen 0xB2 (object 0xF41868, Enter ScreenEnter_CombiEditConfigure_B2) is not yet named.
; In: (XIZ+8) = 1 for the left-hand key (flag bit 7 set), 0 for the right-hand one.
MidiMenu_RequestRow1Screen:
	link XIZ,0x0000                                      ; F9A04B  ee 0c 00 00
	ld (UI_Request_Hi:16), 0x80                                 ; F9A04F  f1 71 20 00 80
	ld (UI_Request:16), 0x7d                                 ; F9A054  f1 70 20 00 7d
	cp (XIZ+0x08),0x00                                   ; F9A059  8e 08 3f 00
	jr nz, .LF9A064                                      ; F9A05D  6e 05
	ld (UI_Request:16), 0xb2                                 ; F9A05F  f1 70 20 00 b2
.LF9A064:
	unlk XIZ                                             ; F9A064  ee 0d
	ret                                                  ; F9A066  0e
; MidiMenu_RequestRow2Screen -- MIDI menu LCD row 2: right -> screen 0x7F (MIDI OUT PROGRAM CHANGE); left -> 0x7E
;   (INPUT&OUTPUT FILTER) when (0xC4)==2, else 0x75 (REALTIME MESSAGES)
; Evidence: (0x2071)=0x80; `ld (XIX),0x7f` / `0x7e` / `0x75` at 0xF9A07B / 0xF9A080 / 0xF9A089 behind `cp (0xc4),2`.
;   Row-2 right of both lists reads "PR0G" "CHANGE" "MIDI 0UT"; row-2 left (0x0AA5) reads "INPUT&0UTPUT" "FILTER" in
;   the variant-2 list and "REALTIME" "MESSAGE" in the other.
MidiMenu_RequestRow2Screen:
	link XIZ,0x0000                                      ; F9A067  ee 0c 00 00
	push XIX                                             ; F9A06B  3c
	lda xix, (UI_Request:16)                                ; F9A06C  f1 70 20 34
	ld (UI_Request_Hi:16), 0x80                                 ; F9A070  f1 71 20 00 80
	cp (XIZ+0x08),0x00                                   ; F9A075  8e 08 3f 00
	jr nz, .LF9A080                                      ; F9A079  6e 05
	ld (XIX),0x7f                                        ; F9A07B  b4 00 7f
	jr .LF9A08C                                          ; F9A07E  68 0c
.LF9A080:
	ld (XIX),0x7e                                        ; F9A080  b4 00 7e
	cp	(Variant_Flag:8), 0x02                               ; F9A083  c0 c4 3f 02
	jr z, .LF9A08C                                       ; F9A087  66 03
	ld (XIX),0x75                                        ; F9A089  b4 00 75
.LF9A08C:
	pop XIX                                              ; F9A08C  5c
	unlk XIZ                                             ; F9A08D  ee 0d
	ret                                                  ; F9A08F  0e
; MidiMenu_RequestRow3Screen -- MIDI menu LCD row 3: right -> screen 0x79 (SYSEX BULK DUMP); left -> 0x7E
;   (INPUT&OUTPUT FILTER) only when (0xC4)!=2, nothing on variant 2
; Evidence: (0x2071)=0x80 with (0x2070)=0x79 (ViewB[121] -> Paint_SysexBulkDump_Entry) or 0x7E; "SYSEX" "BULK DUMP"
;   is drawn at row-3 right (0x10CF), and "INPUT&0UTPUT" "FILTER" at row-3 left (0x10BD) only in the variant-1 list.
MidiMenu_RequestRow3Screen:
	link XIZ,0x0000                                      ; F9A090  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9A094  8e 08 3f 00
	jr nz, .LF9A0A6                                      ; F9A098  6e 0c
	ld (UI_Request_Hi:16), 0x80                                 ; F9A09A  f1 71 20 00 80
	ld (UI_Request:16), 0x79                                 ; F9A09F  f1 70 20 00 79
	jr .LF9A0B6                                          ; F9A0A4  68 10
.LF9A0A6:
	cp	(Variant_Flag:8), 0x02                               ; F9A0A6  c0 c4 3f 02
	jr z, .LF9A0B6                                       ; F9A0AA  66 0a
	ld (UI_Request_Hi:16), 0x80                                 ; F9A0AC  f1 71 20 00 80
	ld (UI_Request:16), 0x7e                                 ; F9A0B1  f1 70 20 00 7e
.LF9A0B6:
	unlk XIZ                                             ; F9A0B6  ee 0d
	ret                                                  ; F9A0B8  0e
; MidiMenu_RequestRow4Screen -- MIDI menu LCD row 4: right key -> screen 0x7A (GENERAL MIDI); left key does nothing
; Evidence: (0x2071)=0x80 / (0x2070)=0x7A only when (XIZ+8)==0; ViewB[122] -> Paint_GeneralMidiMode_Entry, and
;   "GENERAL MIDI" is drawn at row-4 right (0x17FF) with the right-edge arrow at y=0x9B.
MidiMenu_RequestRow4Screen:
	link XIZ,0x0000                                      ; F9A0B9  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9A0BD  8e 08 3f 00
	jr nz, .LF9A0CD                                      ; F9A0C1  6e 0a
	ld (UI_Request_Hi:16), 0x80                                 ; F9A0C3  f1 71 20 00 80
	ld (UI_Request:16), 0x7a                                 ; F9A0C8  f1 70 20 00 7a
.LF9A0CD:
	unlk XIZ                                             ; F9A0CD  ee 0d
	ret                                                  ; F9A0CF  0e
; MidiMenu_ExitToPowerOnMode -- EXIT on the MIDI menu: request panel mode 1, the mode PanelState_Init starts in
; Evidence: (0x2071)=0x02 -- the bit PanelScreen_ApplyModeChange consumes -- with (0x2070)=0x01, only when
;   (XIZ+8)==0; PanelMode_Normalise maps 1 to 1 or 2 by the same (0x7F02) test PanelState_Init makes.
MidiMenu_ExitToPowerOnMode:
	link XIZ,0x0000                                      ; F9A0D0  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9A0D4  8e 08 3f 00
	jr nz, .LF9A0E4                                      ; F9A0D8  6e 0a
	ld (UI_Request_Hi:16), 0x02                                 ; F9A0DA  f1 71 20 00 02
	ld (UI_Request:16), 0x01                                 ; F9A0DF  f1 70 20 00 01
.LF9A0E4:
	unlk XIZ                                             ; F9A0E4  ee 0d
	ret                                                  ; F9A0E6  0e
; MidiSubmenu_ExitToMidiMenu -- EXIT on a MIDI sub-screen: request panel mode 0x12, i.e. back to the MIDI menu
; Evidence: (0x2071)=0x02 / (0x2070)=0x12 when (XIZ+8)==0; PanelMode_ToScreenIdMap[0x12] = 0x70, Paint_MidiMenu's
;   screen. Called from slot [15] (EXIT) of the MidiTotalMode (unlabelled arm 0xF9A327), MidiRealtimeMessages,
;   MidiInputOutputFilter and MidiOutProgramChange handler tables.
MidiSubmenu_ExitToMidiMenu:
	link XIZ,0x0000                                      ; F9A0E7  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9A0EB  8e 08 3f 00
	jr nz, .LF9A0FB                                      ; F9A0EF  6e 0a
	ld (UI_Request_Hi:16), 0x02                                 ; F9A0F1  f1 71 20 00 02
	ld (UI_Request:16), 0x12                                 ; F9A0F6  f1 70 20 00 12
.LF9A0FB:
	unlk XIZ                                             ; F9A0FB  ee 0d
	ret                                                  ; F9A0FD  0e
; StepValue_IncDecClamped -- A = value+1 (dir==0) or value-1 (dir!=0), clamped to [min,max]
; Evidence: `cp H,(XIZ+0x0a) / jr c` -> `inc 1,C`, else A = max; `cp H,(XIZ+0x0c) / jr ugt` -> `dec 1,C`, else A =
;   min. 11 callers: every item and value stepper of the four MIDI sub-screens.
; In: (XIZ+8) dir byte, (XIZ+0x0A) max, (XIZ+0x0C) min, (XIZ+0x0E) current value.  Out: A.
StepValue_IncDecClamped:
	link XIZ,0x0000                                      ; F9A0FE  ee 0c 00 00
	pushw hl                                             ; F9A102  2b
	ld H,(XIZ+0x0e)                                      ; F9A103  8e 0e 26
	cp (XIZ+0x08),0x00                                   ; F9A106  8e 08 3f 00
	jr nz, .LF9A11E                                      ; F9A10A  6e 12
	cp H,(XIZ+0x0a)                                      ; F9A10C  8e 0a f6
	jr c, .LF9A116                                       ; F9A10F  67 05
	ld A,(XIZ+0x0a)                                      ; F9A111  8e 0a 21
	jr .LF9A12E                                          ; F9A114  68 18
.LF9A116:
	ld C,H                                               ; F9A116  ce 8b
	inc 1,C                                              ; F9A118  cb 61
	ld A,C                                               ; F9A11A  cb 89
	jr .LF9A12E                                          ; F9A11C  68 10
.LF9A11E:
	cp H,(XIZ+0x0c)                                      ; F9A11E  8e 0c f6
	jr ugt, .LF9A128                                     ; F9A121  6b 05
	ld A,(XIZ+0x0c)                                      ; F9A123  8e 0c 21
	jr .LF9A12E                                          ; F9A126  68 06
.LF9A128:
	ld C,H                                               ; F9A128  ce 8b
	dec 1,C                                              ; F9A12A  cb 69
	ld A,C                                               ; F9A12C  cb 89
.LF9A12E:
	popw hl                                              ; F9A12E  4b
	unlk XIZ                                             ; F9A12F  ee 0d
	ret                                                  ; F9A131  0e
IgnoredKeys_MidiMenu_Nop:
	ret                                                  ; F9A132  0e
; ByteField_WriteMaskedIfChanged -- put `value` into the `mask` bits of a byte unless they already hold it
; Evidence: `and C,H / cp C,(XIZ+0x0c) / jr z` -> A=1; otherwise `cpl` the mask, `and L,H`, `or C,L`, `ld (XIX),C`,
;   `sub A,A`.
; In: (XIZ+8) pointer, (XIZ+0x0C) value, (XIZ+0x0E) mask.  Out: A = 0 written, 1 unchanged.
ByteField_WriteMaskedIfChanged:
	link XIZ,0x0000                                      ; F9A133  ee 0c 00 00
	pushw hl                                             ; F9A137  2b
	push XIX                                             ; F9A138  3c
	ld XIX,(XIZ+0x08)                                    ; F9A139  ae 08 24
	ld H,(XIX)                                           ; F9A13C  84 26
	ld C,(XIZ+0x0e)                                      ; F9A13E  8e 0e 23
	and C,H                                              ; F9A141  ce c3
	cp C,(XIZ+0x0c)                                      ; F9A143  8e 0c f3
	jr z, .LF9A15E                                       ; F9A146  66 16
	ld C,(XIZ+0x0e)                                      ; F9A148  8e 0e 23
	cpl C                                                ; F9A14B  cb 06
	ld L,C                                               ; F9A14D  cb 8f
	and L,H                                              ; F9A14F  ce c7
	ld (XIX),L                                           ; F9A151  b4 47
	ld C,(XIZ+0x0c)                                      ; F9A153  8e 0c 23
	or C,L                                               ; F9A156  cf e3
	ld (XIX),C                                           ; F9A158  b4 43
	sub A,A                                              ; F9A15A  c9 a1
	jr .LF9A160                                          ; F9A15C  68 02
.LF9A15E:
	ld a, 0x01:opc                                          ; F9A15E  21 01
.LF9A160:
	pop XIX                                              ; F9A160  5c
	popw hl                                              ; F9A161  4b
	unlk XIZ                                             ; F9A162  ee 0d
	ret                                                  ; F9A164  0e
; ByteField_SetOrClearMask -- set (flag==1) or clear (otherwise) the mask bits of a byte; A=0 if it changed
; Evidence: the `cp (XIZ+8),1` arm pushes the mask as the value, the other pushes 0, both to
;   ByteField_WriteMaskedIfChanged. Callers: the eight MidiInputOutputFilter_Edit* routines.
; In: (XIZ+8) flag, (XIZ+0x0A) pointer, (XIZ+0x0E) mask.
ByteField_SetOrClearMask:
	link XIZ,0x0000                                      ; F9A165  ee 0c 00 00
	pushw hl                                             ; F9A169  2b
	ld H,(XIZ+0x0e)                                      ; F9A16A  8e 0e 26
	cp (XIZ+0x08),0x01                                   ; F9A16D  8e 08 3f 01
	jr nz, .LF9A18A                                      ; F9A171  6e 17
	push 0x00                                            ; F9A173  09 00
	push H                                               ; F9A175  ce 04
	push 0x00                                            ; F9A177  09 00
	push H                                               ; F9A179  ce 04
	ld XBC,(XIZ+0x0a)                                    ; F9A17B  ae 0a 21
	push XBC                                             ; F9A17E  39
	calr ByteField_WriteMaskedIfChanged                                      ; F9A17F  1e b1 ff
	inc 8,XSP                                            ; F9A182  ef 60
	cp a, 0x00:i3                                          ; F9A184  c9 d8
	jr nz, .LF9A1A2                                      ; F9A186  6e 1a
	jr .LF9A19E                                          ; F9A188  68 14
.LF9A18A:
	push 0x00                                            ; F9A18A  09 00
	push H                                               ; F9A18C  ce 04
	pushw 0x00                                           ; F9A18E  0b 00 00
	ld XBC,(XIZ+0x0a)                                    ; F9A191  ae 0a 21
	push XBC                                             ; F9A194  39
	calr ByteField_WriteMaskedIfChanged                                      ; F9A195  1e 9b ff
	inc 8,XSP                                            ; F9A198  ef 60
	cp a, 0x00:i3                                          ; F9A19A  c9 d8
	jr nz, .LF9A1A2                                      ; F9A19C  6e 04
.LF9A19E:
	sub A,A                                              ; F9A19E  c9 a1
	jr .LF9A1A4                                          ; F9A1A0  68 02
.LF9A1A2:
	ld a, 0x01:opc                                          ; F9A1A2  21 01
.LF9A1A4:
	popw hl                                              ; F9A1A4  4b
	unlk XIZ                                             ; F9A1A5  ee 0d
	ret                                                  ; F9A1A7  0e
; ---------------------------------------------------------------------
; Paint_MidiTotalMode -- paints the screen whose own text reads "MIDI" / "TOTAL" / "MODE"
;
; Called from: prom_b T_F4173C (`jp`)
;
; It hands 4 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9A202  list 0xF0C96E-0xF0CA2F (193 B, leaves by jr)
;        text: "TOTAL"; "MODE"; "MIDI"; "MIDI INPUT MODE :"; "MIDI OUTPUT MODE:"; ...
;     site 0xF9A210  list 0xF0C964-0xF0CA19 (181 B, leaves by call)
;        text: "TOTAL"; "MODE"; "MIDI"; "MIDI INPUT MODE :"; "MIDI OUTPUT MODE:"; ...
;     site 0xF9A220  list 0xF0C917-0xF0C964 (77 B, leaves by call)
;        text: "ITEM"; "$ VALUE"
;     site 0xF9A24B  list 0xF0CA89-0xF0CA9F (22 B, leaves by call)
; From the captions: "MIDI"; "TOTAL"; "MODE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiTotalMode:
	link XIZ,0xfffc                                      ; F9A1A8  ee 0c fc ff
	push XIX                                             ; F9A1AC  3c
	lda xix, (UI_ScreenFlags:16)                                ; F9A1AD  f1 95 20 34
	ld c, (UI_ScreenLatch:16)                                   ; F9A1B1  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; F9A1B5  c1 7b 20 f3
	jr z, .LF9A1C8                                       ; F9A1B9  66 0d
	and (XIX),0xef                                       ; F9A1BB  84 3c ef
	ld (UI_ScreenItem:16), 0x00                                 ; F9A1BE  f1 20 27 00 00
	ld (0x2721:16), 0x00                                 ; F9A1C3  f1 21 27 00 00
.LF9A1C8:
	call T_CallbackQueue_ResetAndRestartTask2            ; F9A1C8  1d 80 2e f4
	sub XBC,XBC                                          ; F9A1CC  e9 a1
	dec 1,XBC                                            ; F9A1CE  e9 69
	ld (xiz-4), xbc                                      ; F9A1D0  be fc 61
	ld (0x2666:16), xbc                                 ; F9A1D3  f1 66 26 61
	ld xwa, (xiz-4)                                      ; F9A1D7  ae fc 20
	ld (0x266a:16), xwa                                 ; F9A1DA  f1 6a 26 60
	set	0, (UI_RequestBits:16)                               ; F9A1DE  f1 75 20 b8
	ld (PanelDial_UpButton:16), 0x04                                 ; F9A1E2  f1 9c 20 00 04
	ld (PanelDial_DownButton:16), 0x84                                 ; F9A1E7  f1 9b 20 00 84
	ld C,(XIX)                                           ; F9A1EC  84 23
	and C,0x10                                           ; F9A1EE  cb cc 10
	jr nz, .LF9A234                                      ; F9A1F1  6e 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A1F3  f1 40 25 00 00
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F9A1F8  1d 10 2e f4
	cp	(Variant_Flag:8), 0x02                               ; F9A1FC  c0 c4 3f 02
	jr z, .LF9A210                                       ; F9A200  66 0e
	lda xbc, (DL_MultiSingleOmni:24)                     ; F9A202  f2 2f ca f0 31
	push XBC                                             ; F9A207  39
	lda xwa, (0xf0c96e:24)                               ; F9A208  f2 6e c9 f0 30
	push XWA                                             ; F9A20D  38
	jr .LF9A21C                                          ; F9A20E  68 0c
.LF9A210:
	lda xbc, (DL_LocalTotal:24)                          ; F9A210  f2 19 ca f0 31
	push XBC                                             ; F9A215  39
	lda xwa, (DL_TotalModeMidiMidiInputMode:24)          ; F9A216  f2 64 c9 f0 30
	push XWA                                             ; F9A21B  38
.LF9A21C:
	call T_DisplayList_Run_Stack                         ; F9A21C  1d 00 2e f4
	lda xbc, (DL_TotalModeMidiMidiInputMode:24)          ; F9A220  f2 64 c9 f0 31
	push XBC                                             ; F9A225  39
	lda xwa, (DL_F0C917:24)                              ; F9A226  f2 17 c9 f0 30
	push XWA                                             ; F9A22B  38
	call T_DisplayList_Run_Stack                         ; F9A22C  1d 00 2e f4
	inc 8,XSP                                            ; F9A230  ef 60
	inc 8,XSP                                            ; F9A232  ef 60
.LF9A234:
	calr Draw_MultiSingleOmni                                          ; F9A234  1e e1 01
	calr Draw_MultiSingle                                          ; F9A237  1e 01 02
	calr MidiTotalMode_PaintSingleChannel                                          ; F9A23A  1e 24 02
	calr MidiTotalMode_PaintLocalTotal                                          ; F9A23D  1e 44 02
	calr Draw_NormalTechRemap                                          ; F9A240  1e 6d 02
	calr MidiTotalMode_PaintSingleChProgChange                                          ; F9A243  1e 8d 02
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9A246  f1 40 25 00 01
	lda xbc, (DLTable_MultiSingleOmni:24)                ; F9A24B  f2 9f ca f0 31
	push XBC                                             ; F9A250  39
	lda xwa, (DL_F0CA89:24)                              ; F9A251  f2 89 ca f0 30
	push XWA                                             ; F9A256  38
	call T_DisplayListB_Run_Stack                        ; F9A257  1d 04 2e f4
	ld c, (UI_ScreenItem:16)                                   ; F9A25B  c1 20 27 23
	ld (0x2721:16), c                                   ; F9A25F  f1 21 27 43
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F9A263  1d 14 2e f4
	inc 8,XSP                                            ; F9A267  ef 60
	pop XIX                                              ; F9A269  5c
	unlk XIZ                                             ; F9A26A  ee 0d
	ret                                                  ; F9A26C  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiTotalMode -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x9D, i.e. SCREEN ID 0x7D through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9D -> the screen object at
;          0xF4173C, whose +4 slot is `jp 0xF9A26D`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiTotalMode -- the same object's +0 ENTER method carries the
;          label Paint_MidiTotalMode, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F9A26D`.
; ---------------------------------------------------------------------
ScreenLeave_MidiTotalMode:
	ret                                                  ; F9A26D  0e
T_F41748_Nop:
	ret                                                  ; F9A26E  0e
; ---------------------------------------------------------------------
; ScreenButton_MidiTotalMode -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0x9D, i.e. SCREEN ID 0x7D through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9D -> the screen object at
;          0xF4173C, whose +8 slot is `jp 0xF9A26F`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiTotalMode -- the same object's +0 ENTER method carries the
;          label Paint_MidiTotalMode, a name an earlier round derived from
;          the screen's own text.
; Was `sub_F9A26F`.
; ---------------------------------------------------------------------
ScreenButton_MidiTotalMode:
	link XIZ,0x0000                                      ; F9A26F  ee 0c 00 00
	pushw hl                                             ; F9A273  2b
	cpw	(xiz+8), 0x001f                              ; F9A274  9e 08 3f 1f 00
	jrl ugt, .LF9A346                                        ; F9A279  7b ca 00
	ld L,(XIZ+0x08)                                      ; F9A27C  8e 08 27
	ld C,(XIZ+0x0a)                                      ; F9A27F  8e 0a 23
	and C,0x80                                           ; F9A282  cb cc 80
	jr nz, .LF9A28B                                      ; F9A285  6e 04
	ld h, 0x00:opc                                          ; F9A287  26 00
	jr .LF9A28D                                          ; F9A289  68 02
.LF9A28B:
	ld h, 0x01:opc                                          ; F9A28B  26 01
.LF9A28D:
	ld C,L                                               ; F9A28D  cf 8b
	extz BC                                              ; F9A28F  d9 12
	extz XBC                                             ; F9A291  e9 12
	cp BC,0x001f                                         ; F9A293  d9 cf 1f 00
	jrl ugt, .LF9A346                                        ; F9A297  7b ac 00
	sll bc, 0x02                                         ; F9A29A  d9 ee 02
	add XBC,ScreenButtonHandlers_MidiTotalMode                             ; F9A29D  e9 c8 a7 a2 f9 00
	ld XBC,(XBC)                                         ; F9A2A3  a1 21
	jp (xbc)                                             ; F9A2A5  b1 d8
; ---------------------------------------------------------------------
; ScreenButtonHandlers_MidiTotalMode -- 32 LE32 branch targets, same reader shape
;
; Read by: `cp BC,0x001F / ... / add XBC,0x00F9A2A7 / ld XBC,(XBC) / jp T,XBC`
;          at 0xF9A293-0xF9A2A6.  Default arm 0xF9A346.
; ENTRY COUNT 32 from that `cp`.  ★ LAST-ENTRY TEST: base + 128 = 0xF9A327 =
;          the minimum entry value.  Four distinct arms.
; Selector: the panel BUTTON CODE.  ScreenButton_MidiTotalMode (0xF9A26F) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x9D (prom_b
;          slot 0xF41744); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld L,(XIZ+0x08)` ... `ld C,L / cp BC,0x001F / sll 2,BC /
;          add XBC,<this> / ld XBC,(XBC) / jp (XBC)`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as JumpTable_F99F96.
; ---------------------------------------------------------------------
ScreenButtonHandlers_MidiTotalMode:
	.long ItemKeys_MidiTotalMode                                 ; F9A2A7  [  0]
	.long ItemKeys_MidiTotalMode                                 ; F9A2AB  [  1]
	.long ItemKeys_MidiTotalMode                                 ; F9A2AF  [  2]
	.long ItemKeys_MidiTotalMode                                 ; F9A2B3  [  3]
	.long ValueKeys_MidiTotalMode                                 ; F9A2B7  [  4]
	.long ValueKeys_MidiTotalMode                                 ; F9A2BB  [  5]
	.long ValueKeys_MidiTotalMode                                 ; F9A2BF  [  6]
	.long ValueKeys_MidiTotalMode                                 ; F9A2C3  [  7]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2C7  [  8]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2CB  [  9]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2CF  [ 10]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2D3  [ 11]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2D7  [ 12]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2DB  [ 13]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2DF  [ 14]
	.long ScreenButtonHandlers_MidiTotalMode__F9A327                                 ; F9A2E3  [ 15]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A2E7  [ 16]
	.long ItemKeys_MidiTotalMode                                 ; F9A2EB  [ 17]
	.long ItemKeys_MidiTotalMode                                 ; F9A2EF  [ 18]
	.long ItemKeys_MidiTotalMode                                 ; F9A2F3  [ 19]
	.long ItemKeys_MidiTotalMode                                 ; F9A2F7  [ 20]
	.long ValueKeys_MidiTotalMode                                 ; F9A2FB  [ 21]
	.long ValueKeys_MidiTotalMode                                 ; F9A2FF  [ 22]
	.long ValueKeys_MidiTotalMode                                 ; F9A303  [ 23]
	.long ValueKeys_MidiTotalMode                                 ; F9A307  [ 24]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A30B  [ 25]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A30F  [ 26]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A313  [ 27]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A317  [ 28]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A31B  [ 29]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A31F  [ 30]
	.long IgnoredKeys_MidiTotalMode                                 ; F9A323  [ 31]
ScreenButtonHandlers_MidiTotalMode__F9A327:
	push 0x00                                            ; F9A327  09 00
	push H                                               ; F9A329  ce 04
	calr MidiSubmenu_ExitToMidiMenu                                          ; F9A32B  1e b9 fd
	jr .LF9A340                                          ; F9A32E  68 10
; ItemKeys_MidiTotalMode -- switch arm of ScreenButton_MidiTotalMode for codes 0x00-0x03 / 0x11-0x14:
;   MidiTotalMode_StepItem(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiTotalMode; the screen draws "ITEM" (DL_F0C917) over these
;   keys; the arm ends in the reader's epilogue (0xF9A340).  Named for its function, not for one control: 0x11-0x14
;   are the variant-1 `+0x11` remap of 0x00-0x03.
ItemKeys_MidiTotalMode:   ; entry: named by 8 `.long` operands, first at 0xF9A2A7
	push 0x00                                            ; F9A330  09 00
	push H                                               ; F9A332  ce 04
	calr MidiTotalMode_StepItem                                      ; F9A334  1e 13 00
	jr .LF9A340                                          ; F9A337  68 07
; ValueKeys_MidiTotalMode -- switch arm of ScreenButton_MidiTotalMode for codes 0x04-0x07 / 0x15-0x18:
;   MidiTotalMode_StepValue(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiTotalMode; DL_F0C917 draws "VALUE" over them;
;   Paint_MidiTotalMode sets (0x209C)=0x04 / (0x209B)=0x84 and `set 0,(0x2075)`, so PanelEvent_Code21_Dial routes
;   the dial here as code 4.
ValueKeys_MidiTotalMode:   ; entry: named by 8 `.long` operands, first at 0xF9A2B7
	push 0x00                                            ; F9A339  09 00
	push H                                               ; F9A33B  ce 04
	calr MidiTotalMode_StepValue                                      ; F9A33D  1e 62 00
.LF9A340:
	popw bc                                              ; F9A340  49
	jr .LF9A346                                          ; F9A341  68 03
; IgnoredKeys_MidiTotalMode -- default arm of ScreenButton_MidiTotalMode: MidiScreen_NopKeyHandler, then the
;   epilogue
; Evidence: 15 slots ([8]-[14], [16], [25]-[31]) of ScreenButtonHandlers_MidiTotalMode.
IgnoredKeys_MidiTotalMode:   ; entry: named by 15 `.long` operands, first at 0xF9A2C7
	calr IgnoredKeys_MidiMenu_Nop                                          ; F9A343  1e ec fd
.LF9A346:
	popw hl                                              ; F9A346  4b
	unlk XIZ                                             ; F9A347  ee 0d
	ret                                                  ; F9A349  0e
; MidiTotalMode_StepItem -- move the item cursor (0x2720) one row within 0..5, skipping row 3 (LOCAL TOTAL) on
;   variant 2
; Evidence: StepValue_IncDecClamped(dir = (XIZ+8)==0, max 5, min 0) stored to (0x2720), repeated once when (0xC4)==2
;   and the result is 3 -- the variant-2 list (0xF0C964-0xF0CA19) omits DL_LocalTotal.  Then `set 4,(0x2095)`, the
;   bit Paint_MidiTotalMode tests to skip its static lists.
MidiTotalMode_StepItem:
	link XIZ,0x0000                                      ; F9A34A  ee 0c 00 00
	pushw hl                                             ; F9A34E  2b
	push XIX                                             ; F9A34F  3c
	lda xix, (UI_ScreenItem:16)                                ; F9A350  f1 20 27 34
	ld H,(XIZ+0x08)                                      ; F9A354  8e 08 26
	set	3, (UI_RequestBits:16)                               ; F9A357  f1 75 20 bb
	ld L,(XIX)                                           ; F9A35B  84 27
	cp h, 0x00:i3                                          ; F9A35D  ce d8
	jr nz, .LF9A365                                      ; F9A35F  6e 04
	ld h, 0x01:opc                                          ; F9A361  26 01
	jr .LF9A367                                          ; F9A363  68 02
.LF9A365:
	ld h, 0x00:opc                                          ; F9A365  26 00
.LF9A367:
	pushw hl                                             ; F9A367  2b
	pushw 0x00                                           ; F9A368  0b 00 00
	pushw 0x05                                           ; F9A36B  0b 05 00
	push 0x00                                            ; F9A36E  09 00
	push H                                               ; F9A370  ce 04
	calr StepValue_IncDecClamped                                          ; F9A372  1e 89 fd
	ld (XIX),A                                           ; F9A375  b4 41
	inc 8,XSP                                            ; F9A377  ef 60
	cp	(Variant_Flag:8), 0x02                               ; F9A379  c0 c4 3f 02
	jr nz, .LF9A399                                      ; F9A37D  6e 1a
	ld C,(XIX)                                           ; F9A37F  84 23
	cp c, 0x03:i3                                          ; F9A381  cb db
	jr nz, .LF9A399                                      ; F9A383  6e 14
	ld C,(XIX)                                           ; F9A385  84 23
	pushw bc                                             ; F9A387  29
	pushw 0x00                                           ; F9A388  0b 00 00
	pushw 0x05                                           ; F9A38B  0b 05 00
	push 0x00                                            ; F9A38E  09 00
	push H                                               ; F9A390  ce 04
	calr StepValue_IncDecClamped                                          ; F9A392  1e 69 fd
	ld (XIX),A                                           ; F9A395  b4 41
	inc 8,XSP                                            ; F9A397  ef 60
.LF9A399:
	set	4, (UI_ScreenFlags:16)                               ; F9A399  f1 95 20 bc
	pop XIX                                              ; F9A39D  5c
	popw hl                                              ; F9A39E  4b
	unlk XIZ                                             ; F9A39F  ee 0d
	ret                                                  ; F9A3A1  0e
; MidiTotalMode_StepValue -- step the value of the row under the cursor: JumpTable_F9A3C7[(0x2720)], rows 0..5
; Evidence: `ld BC,(0x2720) / cp BC,5 / jr ugt / ... add XBC,JumpTable_F9A3C7 / jp (XBC)`; the six arms call
;   MidiTotalMode_EditInputMode .. _EditSingleChProgChange in screen order.
MidiTotalMode_StepValue:
	link XIZ,0x0000                                      ; F9A3A2  ee 0c 00 00
	pushw hl                                             ; F9A3A6  2b
	ld H,(XIZ+0x08)                                      ; F9A3A7  8e 08 26
	set	3, (UI_RequestBits:16)                               ; F9A3AA  f1 75 20 bb
	ld bc, (UI_ScreenItem:16)                                 ; F9A3AE  d1 20 27 21
	extz BC                                              ; F9A3B2  d9 12
	extz XBC                                             ; F9A3B4  e9 12
	cp bc, 0x05:i3                                         ; F9A3B6  d9 dd
	jr ugt, JumpTable_F9A3C7_Code_Skip                                         ; F9A3B8  6b 5a
	sll bc, 0x02                                         ; F9A3BA  d9 ee 02
	add XBC,JumpTable_F9A3C7                             ; F9A3BD  e9 c8 c7 a3 f9 00
	ld XBC,(XBC)                                         ; F9A3C3  a1 21
	jp (xbc)                                             ; F9A3C5  b1 d8
; ---------------------------------------------------------------------
; JumpTable_F9A3C7 -- 6 LE32 branch targets
;
; Read by: `ld BC,(0x2720) / extz BC / extz XBC / cp BC,5 / jr UGT,0xF9A414 /
;          sll 0x02,BC / add XBC,0x00F9A3C7 / ld XBC,(XBC) / jp T,XBC` at
;          0xF9A3AE-0xF9A3C6.
; Inputs:  the selector is the RAM byte (0x2720).
; ENTRY COUNT 6, from `cp BC,5` -- 5 is the last index allowed.  ★ LAST-ENTRY
;          TEST: 0xF9A3C7 + 6*4 = 0xF9A3DF = the minimum entry value.
; Evidence / Unknown: as JumpTable_F99F96.
; ---------------------------------------------------------------------
JumpTable_F9A3C7:
	.long MidiTotalMode_ValueCase_InputMode                                 ; F9A3C7  [  0]
	.long MidiTotalMode_ValueCase_OutputMode                                 ; F9A3CB  [  1]
	.long MidiTotalMode_ValueCase_SingleChannel                                 ; F9A3CF  [  2]
	.long MidiTotalMode_ValueCase_LocalTotal                                 ; F9A3D3  [  3]
	.long MidiTotalMode_ValueCase_ProgChangeMode                                 ; F9A3D7  [  4]
	.long MidiTotalMode_ValueCase_SingleChProgChange                                 ; F9A3DB  [  5]
; MidiTotalMode_ValueCase_InputMode -- case 0 of MidiTotalMode_StepValue: MidiTotalMode_EditInputMode(H)
; Evidence: JumpTable_F9A3C7 entry [0]; row 0 of the screen is "MIDI INPUT MODE :" (IX 0x06E6); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_InputMode:   ; entry: named by 1 `.long` operand, first at 0xF9A3C7
	push 0x00                                            ; F9A3DF  09 00
	push H                                               ; F9A3E1  ce 04
	calr MidiTotalMode_EditInputMode                                      ; F9A3E3  1e 13 01
	jr .LF9A413                                          ; F9A3E6  68 2b
; MidiTotalMode_ValueCase_OutputMode -- case 1 of MidiTotalMode_StepValue: MidiTotalMode_EditOutputMode(H)
; Evidence: JumpTable_F9A3C7 entry [1]; row 1 of the screen is "MIDI OUTPUT MODE:" (IX 0x0AA6); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_OutputMode:   ; entry: named by 1 `.long` operand, first at 0xF9A3CB
	push 0x00                                            ; F9A3E8  09 00
	push H                                               ; F9A3EA  ce 04
	calr MidiTotalMode_EditOutputMode                                      ; F9A3EC  1e 55 01
	jr .LF9A413                                          ; F9A3EF  68 22
; MidiTotalMode_ValueCase_SingleChannel -- case 2 of MidiTotalMode_StepValue: MidiTotalMode_EditSingleChannel(H)
; Evidence: JumpTable_F9A3C7 entry [2]; row 2 of the screen is "SINGLE CHANNEL  :" (IX 0x0E66); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_SingleChannel:   ; entry: named by 1 `.long` operand, first at 0xF9A3CF
	push 0x00                                            ; F9A3F1  09 00
	push H                                               ; F9A3F3  ce 04
	calr MidiTotalMode_EditSingleChannel                                      ; F9A3F5  1e a2 01
	jr .LF9A413                                          ; F9A3F8  68 19
; MidiTotalMode_ValueCase_LocalTotal -- case 3 of MidiTotalMode_StepValue: MidiTotalMode_EditLocalTotal(H)
; Evidence: JumpTable_F9A3C7 entry [3]; row 3 of the screen is "LOCAL TOTAL     :" (IX 0x1226); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_LocalTotal:   ; entry: named by 1 `.long` operand, first at 0xF9A3D3
	push 0x00                                            ; F9A3FA  09 00
	push H                                               ; F9A3FC  ce 04
	calr MidiTotalMode_EditLocalTotal                                      ; F9A3FE  1e e4 01
	jr .LF9A413                                          ; F9A401  68 10
; MidiTotalMode_ValueCase_ProgChangeMode -- case 4 of MidiTotalMode_StepValue: MidiTotalMode_EditProgChangeMode(H)
; Evidence: JumpTable_F9A3C7 entry [4]; row 4 of the screen is "PROG CHANGE MODE:" (IX 0x15E6); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_ProgChangeMode:   ; entry: named by 1 `.long` operand, first at 0xF9A3D7
	push 0x00                                            ; F9A403  09 00
	push H                                               ; F9A405  ce 04
	calr MidiTotalMode_EditProgChangeMode                                      ; F9A407  1e 23 02
	jr .LF9A413                                          ; F9A40A  68 07
; MidiTotalMode_ValueCase_SingleChProgChange -- case 5 of MidiTotalMode_StepValue:
;   MidiTotalMode_EditSingleChProgChange(H)
; Evidence: JumpTable_F9A3C7 entry [5]; row 5 of the screen is "SINGLE CH PROG CHANGE:" (IX 0x19A6); the arm ends in
;   MidiTotalMode_StepValue's epilogue (0xF9A413).
MidiTotalMode_ValueCase_SingleChProgChange:   ; entry: named by 1 `.long` operand, first at 0xF9A3DB
	push 0x00                                            ; F9A40C  09 00
	push H                                               ; F9A40E  ce 04
	calr MidiTotalMode_EditSingleChProgChange                                      ; F9A410  1e 65 02
.LF9A413:
	popw bc                                              ; F9A413  49
JumpTable_F9A3C7_Code_Skip:
	popw hl                                              ; F9A414  4b
	unlk XIZ                                             ; F9A415  ee 0d
	ret                                                  ; F9A417  0e
Draw_MultiSingleOmni:
	ld c, (MidiCfg_InOutMode:16)                                   ; F9A418  c1 35 7f 23
	and C,0x0f                                           ; F9A41C  cb cc 0f
	ld (0x2740:16), c                                   ; F9A41F  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A423  f1 40 25 00 00
	lda xbc, (DL_MultiSingle:24)                         ; F9A428  f2 3e ca f0 31
	push XBC                                             ; F9A42D  39
	lda xwa, (DL_MultiSingleOmni:24)                     ; F9A42E  f2 2f ca f0 30
	push XWA                                             ; F9A433  38
	call T_DisplayListB_Run_Stack                        ; F9A434  1d 04 2e f4
	inc 8,XSP                                            ; F9A438  ef 60
	ret                                                  ; F9A43A  0e
Draw_MultiSingle:
	ld c, (MidiCfg_InOutMode:16)                                   ; F9A43B  c1 35 7f 23
	and C,0xf0                                           ; F9A43F  cb cc f0
	srl c, 0x04                                          ; F9A442  cb ef 04
	ld (0x2740:16), c                                   ; F9A445  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A449  f1 40 25 00 00
	lda xbc, (DL_F0CA4D:24)                              ; F9A44E  f2 4d ca f0 31
	push XBC                                             ; F9A453  39
	lda xwa, (DL_MultiSingle:24)                         ; F9A454  f2 3e ca f0 30
	push XWA                                             ; F9A459  38
	call T_DisplayListB_Run_Stack                        ; F9A45A  1d 04 2e f4
	inc 8,XSP                                            ; F9A45E  ef 60
	ret                                                  ; F9A460  0e
; MidiTotalMode_PaintSingleChannel -- draw the SINGLE CHANNEL value: (0x7F36) & 0x0F -> (0x2740), then DL_F0CA4D
;   (DLTable_F0CABD, "1 - 1".."2 - 16")
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x0E78, the text row of "SINGLE CHANNEL  :" (IX
;   0x0E66) in DL_TotalModeMidiMidiInputMode/DL_LocalTotal.  Called by Paint_MidiTotalMode and
;   MidiTotalMode_EditSingleChannel.
MidiTotalMode_PaintSingleChannel:
	ld c, (MidiCfg_SingleChannel:16)                                   ; F9A461  c1 36 7f 23
	and C,0x0f                                           ; F9A465  cb cc 0f
	ld (0x2740:16), c                                   ; F9A468  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A46C  f1 40 25 00 00
	lda xbc, (MidiTotalMode_PaintSingleChannel_DL:24)                              ; F9A471  f2 5c ca f0 31
	push XBC                                             ; F9A476  39
	lda xwa, (DL_F0CA4D:24)                              ; F9A477  f2 4d ca f0 30
	push XWA                                             ; F9A47C  38
	call T_DisplayListB_Run_Stack                        ; F9A47D  1d 04 2e f4
	inc 8,XSP                                            ; F9A481  ef 60
	ret                                                  ; F9A483  0e
; MidiTotalMode_PaintLocalTotal -- draw the LOCAL TOTAL value: (0x7F36) bit 5 -> (0x2740) -> MidiTotalMode_PaintSingleChannel_DL (0 "ON", 1
;   "OFF")
; Evidence: MidiTotalMode_PaintSingleChannel_DL reads (0x2740) through DLTable_OnOff and draws at IX 0x1238, the row of "LOCAL TOTAL     : "
;   (DL_LocalTotal, 0x1226).  Skipped when (0xC4)==2 -- only the variant-1 list draws DL_LocalTotal. Called by
;   Paint_MidiTotalMode and MidiTotalMode_EditLocalTotal.
MidiTotalMode_PaintLocalTotal:
	cp	(Variant_Flag:8), 0x02                               ; F9A484  c0 c4 3f 02
	jr z, .LF9A4AF                                       ; F9A488  66 25
	ld c, (MidiCfg_SingleChannel:16)                                   ; F9A48A  c1 36 7f 23
	and C,0x20                                           ; F9A48E  cb cc 20
	srl c, 0x05                                          ; F9A491  cb ef 05
	ld (0x2740:16), c                                   ; F9A494  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A498  f1 40 25 00 00
	lda xbc, (DL_NormalTechRemap:24)                     ; F9A49D  f2 6b ca f0 31
	push XBC                                             ; F9A4A2  39
	lda xwa, (MidiTotalMode_PaintSingleChannel_DL:24)                              ; F9A4A3  f2 5c ca f0 30
; (sub_F9A4A8 removed 2026-10-04: no code names it and the line above falls through into it -- part of MidiTotalMode_PaintLocalTotal;
;  notes/prom_a_stray_label_removal.py)
	push XWA                                             ; F9A4A8  38
	call T_DisplayListB_Run_Stack                        ; F9A4A9  1d 04 2e f4
	inc 8,XSP                                            ; F9A4AD  ef 60
.LF9A4AF:
	ret                                                  ; F9A4AF  0e
Draw_NormalTechRemap:
	ld c, (MidiCfg_ModeBits:16)                                   ; F9A4B0  c1 32 7f 23
	and C,0x03                                           ; F9A4B4  cb cc 03
	ld (0x2740:16), c                                   ; F9A4B7  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A4BB  f1 40 25 00 00
	lda xbc, (DL_F0CA7A:24)                              ; F9A4C0  f2 7a ca f0 31
	push XBC                                             ; F9A4C5  39
	lda xwa, (DL_NormalTechRemap:24)                     ; F9A4C6  f2 6b ca f0 30
	push XWA                                             ; F9A4CB  38
	call T_DisplayListB_Run_Stack                        ; F9A4CC  1d 04 2e f4
	inc 8,XSP                                            ; F9A4D0  ef 60
	ret                                                  ; F9A4D2  0e
; MidiTotalMode_PaintSingleChProgChange -- draw the SINGLE CH PROG CHANGE value: (0x7F32) bit 3 -> (0x2740), then
;   DL_F0CA7A (DLTable_SoundCombi: SOUND/COMBI)
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x19BD, the text row of "SINGLE CH PROG CHANGE:"
;   (IX 0x19A6) in DL_TotalModeMidiMidiInputMode/DL_LocalTotal.  Called by Paint_MidiTotalMode and
;   MidiTotalMode_EditSingleChProgChange.
MidiTotalMode_PaintSingleChProgChange:
	ld c, (MidiCfg_ModeBits:16)                                   ; F9A4D3  c1 32 7f 23
	and C,0x08                                           ; F9A4D7  cb cc 08
	srl c, 0x03                                          ; F9A4DA  cb ef 03
	ld (0x2740:16), c                                   ; F9A4DD  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A4E1  f1 40 25 00 00
	lda xbc, (DL_F0CA89:24)                              ; F9A4E6  f2 89 ca f0 31
	push XBC                                             ; F9A4EB  39
	lda xwa, (DL_F0CA7A:24)                              ; F9A4EC  f2 7a ca f0 30
	push XWA                                             ; F9A4F1  38
	call T_DisplayListB_Run_Stack                        ; F9A4F2  1d 04 2e f4
	inc 8,XSP                                            ; F9A4F6  ef 60
	ret                                                  ; F9A4F8  0e
; MidiTotalMode_EditInputMode -- change the MIDI INPUT MODE setting; if it changed, post it and repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0x0F, D=3, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintInputMode.
; Field: (0x7F35) bits 0-3, stepped 0..2 (MULTI/SINGLE/OMNI).
MidiTotalMode_EditInputMode:
	link XIZ,0x0000                                      ; F9A4F9  ee 0c 00 00
	pushw hl                                             ; F9A4FD  2b
	push XIX                                             ; F9A4FE  3c
	lda xix, (MidiCfg_InOutMode:16)                                ; F9A4FF  f1 35 7f 34
	ld C,(XIX)                                           ; F9A503  84 23
	ld L,C                                               ; F9A505  cb 8f
	and L,0x0f                                           ; F9A507  cf cc 0f
	and (XIX),0xf0                                       ; F9A50A  84 3c f0
	pushw hl                                             ; F9A50D  2b
	pushw 0x00                                           ; F9A50E  0b 00 00
	pushw 0x02                                           ; F9A511  0b 02 00
	push 0x00                                            ; F9A514  09 00
	push	(xiz+8)                                      ; F9A516  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9A519  1e e2 fb
	or (XIX),A                                           ; F9A51C  84 e9
	ld H,(XIX)                                           ; F9A51E  84 26
	and H,0x0f                                           ; F9A520  ce cc 0f
	inc 8,XSP                                            ; F9A523  ef 60
	cp L,H                                               ; F9A525  ce f7
	jr z, .LF9A53F                                       ; F9A527  66 16
	pushw 0x0f                                           ; F9A529  0b 0f 00
	push 0x00                                            ; F9A52C  09 00
	push H                                               ; F9A52E  ce 04
	pushw 0x03                                           ; F9A530  0b 03 00
	pushw 0x80                                           ; F9A533  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A536  1d 18 1b f4
	calr Draw_MultiSingleOmni                                      ; F9A53A  1e db fe
	inc 8,XSP                                            ; F9A53D  ef 60
.LF9A53F:
	pop XIX                                              ; F9A53F  5c
	popw hl                                              ; F9A540  4b
	unlk XIZ                                             ; F9A541  ee 0d
	ret                                                  ; F9A543  0e
; MidiTotalMode_EditOutputMode -- change the MIDI OUTPUT MODE setting; if it changed, post it and repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0xF0, D=3, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintOutputMode.
; Field: (0x7F35) bits 4-7, stepped 0..1 (MULTI/SINGLE).
MidiTotalMode_EditOutputMode:
	link XIZ,0x0000                                      ; F9A544  ee 0c 00 00
	pushw hl                                             ; F9A548  2b
	push XIX                                             ; F9A549  3c
	lda xix, (MidiCfg_InOutMode:16)                                ; F9A54A  f1 35 7f 34
	ld C,(XIX)                                           ; F9A54E  84 23
	and C,0xf0                                           ; F9A550  cb cc f0
	ld L,C                                               ; F9A553  cb 8f
	srl l, 0x04                                          ; F9A555  cf ef 04
	and (XIX),0x0f                                       ; F9A558  84 3c 0f
	pushw hl                                             ; F9A55B  2b
	pushw 0x00                                           ; F9A55C  0b 00 00
	pushw 0x01                                           ; F9A55F  0b 01 00
	push 0x00                                            ; F9A562  09 00
	push	(xiz+8)                                      ; F9A564  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9A567  1e 94 fb
	sll a, 0x04                                          ; F9A56A  c9 ee 04
	or (XIX),A                                           ; F9A56D  84 e9
	ld H,(XIX)                                           ; F9A56F  84 26
	and H,0xf0                                           ; F9A571  ce cc f0
	ld C,H                                               ; F9A574  ce 8b
	srl c, 0x04                                          ; F9A576  cb ef 04
	inc 8,XSP                                            ; F9A579  ef 60
	cp L,C                                               ; F9A57B  cb f7
	jr z, .LF9A595                                       ; F9A57D  66 16
	pushw 0xf0                                           ; F9A57F  0b f0 00
	push 0x00                                            ; F9A582  09 00
	push H                                               ; F9A584  ce 04
	pushw 0x03                                           ; F9A586  0b 03 00
	pushw 0x80                                           ; F9A589  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A58C  1d 18 1b f4
	calr Draw_MultiSingle                                      ; F9A590  1e a8 fe
	inc 8,XSP                                            ; F9A593  ef 60
.LF9A595:
	pop XIX                                              ; F9A595  5c
	popw hl                                              ; F9A596  4b
	unlk XIZ                                             ; F9A597  ee 0d
	ret                                                  ; F9A599  0e
; MidiTotalMode_EditSingleChannel -- change the SINGLE CHANNEL setting; if it changed, post it and repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0x0F, D=4, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintSingleChannel.
; Field: (0x7F36) bits 0-3, stepped 0..15.
MidiTotalMode_EditSingleChannel:
	link XIZ,0x0000                                      ; F9A59A  ee 0c 00 00
	pushw hl                                             ; F9A59E  2b
	push XIX                                             ; F9A59F  3c
	lda xix, (MidiCfg_SingleChannel:16)                                ; F9A5A0  f1 36 7f 34
	ld C,(XIX)                                           ; F9A5A4  84 23
	ld L,C                                               ; F9A5A6  cb 8f
	and L,0x0f                                           ; F9A5A8  cf cc 0f
	and (XIX),0xf0                                       ; F9A5AB  84 3c f0
	pushw hl                                             ; F9A5AE  2b
	pushw 0x00                                           ; F9A5AF  0b 00 00
	pushw 0x0f                                           ; F9A5B2  0b 0f 00
	push 0x00                                            ; F9A5B5  09 00
	push	(xiz+8)                                      ; F9A5B7  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9A5BA  1e 41 fb
	or (XIX),A                                           ; F9A5BD  84 e9
	ld H,(XIX)                                           ; F9A5BF  84 26
	and H,0x0f                                           ; F9A5C1  ce cc 0f
	inc 8,XSP                                            ; F9A5C4  ef 60
	cp L,H                                               ; F9A5C6  ce f7
	jr z, .LF9A5E0                                       ; F9A5C8  66 16
	pushw 0x0f                                           ; F9A5CA  0b 0f 00
	push 0x00                                            ; F9A5CD  09 00
	push H                                               ; F9A5CF  ce 04
	pushw 0x04                                           ; F9A5D1  0b 04 00
	pushw 0x80                                           ; F9A5D4  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A5D7  1d 18 1b f4
	calr MidiTotalMode_PaintSingleChannel                                      ; F9A5DB  1e 83 fe
	inc 8,XSP                                            ; F9A5DE  ef 60
.LF9A5E0:
	pop XIX                                              ; F9A5E0  5c
	popw hl                                              ; F9A5E1  4b
	unlk XIZ                                             ; F9A5E2  ee 0d
	ret                                                  ; F9A5E4  0e
; MidiTotalMode_EditLocalTotal -- change the LOCAL TOTAL setting; if it changed, post it and repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0x20, D=4, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintLocalTotal.
; Field: (0x7F36) bit 5: (XIZ+8)==0 clears it ("ON"), otherwise sets it ("OFF").
MidiTotalMode_EditLocalTotal:
	link XIZ,0x0000                                      ; F9A5E5  ee 0c 00 00
	pushw hl                                             ; F9A5E9  2b
	push XIX                                             ; F9A5EA  3c
	lda xix, (MidiCfg_SingleChannel:16)                                ; F9A5EB  f1 36 7f 34
	cp (XIZ+0x08),0x00                                   ; F9A5EF  8e 08 3f 00
	jr nz, .LF9A601                                      ; F9A5F3  6e 0c
	ld C,(XIX)                                           ; F9A5F5  84 23
	and C,0x20                                           ; F9A5F7  cb cc 20
	jr z, .LF9A628                                       ; F9A5FA  66 2c
	and (XIX),0xdf                                       ; F9A5FC  84 3c df
	jr .LF9A60B                                          ; F9A5FF  68 0a
.LF9A601:
	ld C,(XIX)                                           ; F9A601  84 23
	and C,0x20                                           ; F9A603  cb cc 20
	jr nz, .LF9A628                                      ; F9A606  6e 20
	or	(xix), 0x20                                  ; F9A608  84 3e 20
.LF9A60B:
	ld C,(XIX)                                           ; F9A60B  84 23
	ld H,C                                               ; F9A60D  cb 8e
	and H,0x20                                           ; F9A60F  ce cc 20
	pushw 0x20                                           ; F9A612  0b 20 00
	push 0x00                                            ; F9A615  09 00
	push H                                               ; F9A617  ce 04
	pushw 0x04                                           ; F9A619  0b 04 00
	pushw 0x80                                           ; F9A61C  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A61F  1d 18 1b f4
	calr MidiTotalMode_PaintLocalTotal                                      ; F9A623  1e 5e fe
	inc 8,XSP                                            ; F9A626  ef 60
.LF9A628:
	pop XIX                                              ; F9A628  5c
	popw hl                                              ; F9A629  4b
	unlk XIZ                                             ; F9A62A  ee 0d
	ret                                                  ; F9A62C  0e
; MidiTotalMode_EditProgChangeMode -- change the PROG CHANGE MODE setting; if it changed, post it and repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0x03, D=0, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintProgChangeMode.
; Field: (0x7F32) bits 0-1, stepped 0..1 (NORMAL/TECH; REMAP is not reachable here).
MidiTotalMode_EditProgChangeMode:
	link XIZ,0x0000                                      ; F9A62D  ee 0c 00 00
	pushw hl                                             ; F9A631  2b
	push XIX                                             ; F9A632  3c
	lda xix, (MidiCfg_ModeBits:16)                                ; F9A633  f1 32 7f 34
	ld C,(XIX)                                           ; F9A637  84 23
	ld L,C                                               ; F9A639  cb 8f
	and L,0x03                                           ; F9A63B  cf cc 03
	and (XIX),0xfc                                       ; F9A63E  84 3c fc
	pushw hl                                             ; F9A641  2b
	pushw 0x00                                           ; F9A642  0b 00 00
	pushw 0x01                                           ; F9A645  0b 01 00
	push 0x00                                            ; F9A648  09 00
	push	(xiz+8)                                      ; F9A64A  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9A64D  1e ae fa
	or (XIX),A                                           ; F9A650  84 e9
	ld H,(XIX)                                           ; F9A652  84 26
	and H,0x03                                           ; F9A654  ce cc 03
	inc 8,XSP                                            ; F9A657  ef 60
	cp L,H                                               ; F9A659  ce f7
	jr z, .LF9A673                                       ; F9A65B  66 16
	pushw 0x03                                           ; F9A65D  0b 03 00
	push 0x00                                            ; F9A660  09 00
	push H                                               ; F9A662  ce 04
	pushw 0x00                                           ; F9A664  0b 00 00
	pushw 0x80                                           ; F9A667  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A66A  1d 18 1b f4
	calr Draw_NormalTechRemap                                      ; F9A66E  1e 3f fe
	inc 8,XSP                                            ; F9A671  ef 60
.LF9A673:
	pop XIX                                              ; F9A673  5c
	popw hl                                              ; F9A674  4b
	unlk XIZ                                             ; F9A675  ee 0d
	ret                                                  ; F9A677  0e
; MidiTotalMode_EditSingleChProgChange -- change the SINGLE CH PROG CHANGE setting; if it changed, post it and
;   repaint
; Evidence: on change, T_PendingEventQueue_AppendStackArgs (-> sub_F8BF07 -> Queue2E00_AppendRegs) posts E=0x80, W=0x08, D=0, A = new bits (D =
;   the byte's offset from 0x7F32, as in every MIDI-screen editor), then MidiTotalMode_PaintSingleChProgChange.
; Field: (0x7F32) bit 3: (XIZ+8)==0 sets it (COMBI), otherwise clears it (SOUND).
MidiTotalMode_EditSingleChProgChange:
	link XIZ,0x0000                                      ; F9A678  ee 0c 00 00
	pushw hl                                             ; F9A67C  2b
	push XIX                                             ; F9A67D  3c
	lda xix, (MidiCfg_ModeBits:16)                                ; F9A67E  f1 32 7f 34
	cp (XIZ+0x08),0x00                                   ; F9A682  8e 08 3f 00
	jr nz, .LF9A694                                      ; F9A686  6e 0c
	ld C,(XIX)                                           ; F9A688  84 23
	and C,0x08                                           ; F9A68A  cb cc 08
	jr nz, .LF9A6BB                                      ; F9A68D  6e 2c
	or	(xix), 0x08                                  ; F9A68F  84 3e 08
	jr .LF9A69E                                          ; F9A692  68 0a
.LF9A694:
	ld C,(XIX)                                           ; F9A694  84 23
	and C,0x08                                           ; F9A696  cb cc 08
	jr z, .LF9A6BB                                       ; F9A699  66 20
	and (XIX),0xf7                                       ; F9A69B  84 3c f7
.LF9A69E:
	ld C,(XIX)                                           ; F9A69E  84 23
	ld H,C                                               ; F9A6A0  cb 8e
	and H,0x08                                           ; F9A6A2  ce cc 08
	pushw 0x08                                           ; F9A6A5  0b 08 00
	push 0x00                                            ; F9A6A8  09 00
	push H                                               ; F9A6AA  ce 04
	pushw 0x00                                           ; F9A6AC  0b 00 00
	pushw 0x80                                           ; F9A6AF  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A6B2  1d 18 1b f4
	calr MidiTotalMode_PaintSingleChProgChange                                      ; F9A6B6  1e 1a fe
	inc 8,XSP                                            ; F9A6B9  ef 60
.LF9A6BB:
	pop XIX                                              ; F9A6BB  5c
	popw hl                                              ; F9A6BC  4b
	unlk XIZ                                             ; F9A6BD  ee 0d
	ret                                                  ; F9A6BF  0e
; ---------------------------------------------------------------------
; Paint_MidiRealtimeMessages -- paints the screen whose own text reads "REALTIME MESSAGES" / "MIDI"
;
; Called from: prom_b T_F41690 (`jp`)
;
; It hands 2 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9A6EB  list 0xF0CBCF-0xF0CC75 (166 B, leaves by call)
;        text: "REALTIME MESSAGES"; "MIDI"; "REALTIME COMMANDS :"; "CLOCK  :"
;     site 0xF9A6FD  list 0xF0CC91-0xF0CCBA (41 B, leaves by call)
; From the captions: "MIDI"; "REALTIME MESSAGES"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiRealtimeMessages:
	push XIX                                             ; F9A6C0  3c
	lda xix, (UI_ScreenFlags:16)                                ; F9A6C1  f1 95 20 34
	ld c, (UI_ScreenLatch:16)                                   ; F9A6C5  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; F9A6C9  c1 7b 20 f3
	jr z, .LF9A6D7                                       ; F9A6CD  66 08
	and (XIX),0xef                                       ; F9A6CF  84 3c ef
	ld (UI_ScreenItem:16), 0x00                                 ; F9A6D2  f1 20 27 00 00
.LF9A6D7:
	call T_CallbackQueue_ResetAndRestartTask2            ; F9A6D7  1d 80 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A6DB  f1 40 25 00 00
	ld C,(XIX)                                           ; F9A6E0  84 23
	and C,0x10                                           ; F9A6E2  cb cc 10
	jr nz, .LF9A6FD                                      ; F9A6E5  6e 16
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F9A6E7  1d 10 2e f4
	lda xbc, (DL_F0CC75:24)                              ; F9A6EB  f2 75 cc f0 31
	push XBC                                             ; F9A6F0  39
	lda xwa, (DL_RealtimeMessagesMidiRealtimeCommands:24) ; F9A6F1  f2 cf cb f0 30
	push XWA                                             ; F9A6F6  38
	call T_DisplayList_Run_Stack                         ; F9A6F7  1d 00 2e f4
	inc 8,XSP                                            ; F9A6FB  ef 60
.LF9A6FD:
	lda xbc, (DL_F0CCBA:24)                              ; F9A6FD  f2 ba cc f0 31
	push XBC                                             ; F9A702  39
	lda xwa, (DL_RealtimeCommandsClock:24)               ; F9A703  f2 91 cc f0 30
	push XWA                                             ; F9A708  38
	call T_DisplayListB_Run_Stack                        ; F9A709  1d 04 2e f4
	inc 8,XSP                                            ; F9A70D  ef 60
	cp	(UI_ScreenItem:16), 0x00                            ; F9A70F  c1 20 27 3f 00
	jr nz, .LF9A71B                                      ; F9A714  6e 05
	calr DisplayList_Run_Stack_Wrap                                      ; F9A716  1e 0b 00
	jr .LF9A71E                                          ; F9A719  68 03
.LF9A71B:
	calr MidiRealtimeMessages_PaintClockKeyGlyphs                                      ; F9A71B  1e 1e 00
.LF9A71E:
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F9A71E  1d 14 2e f4
	pop XIX                                              ; F9A722  5c
	ret                                                  ; F9A723  0e
; ---------------------------------------------------------------------
; DisplayList_Run_Stack_Wrap -- a screen painter this round REFUSED to name.
;
; It hands 1 display list(s) to the interpreter ON THE STACK.
;     site 0xF9A729  list 0xF0CC83-0xF0CC91 (14 B, leaves by call)
;        text: "ON"; "OFF"
; Evidence: the two 24-bit immediates of the 12-byte push idiom at
;          the cited site; the record walk from <start> lands exactly
;          on <end>; the text is the `.ascii` the interpreter draws.
; NOT NAMED because the only text it draws is `ON` / `OFF`, a two-state
;          field and not a screen.
;          A wrong name passes the byte gate forever, so this keeps
;          sub_XXXXXX and states the gap.
; Recorded by notes/prom_a_understanding_round7.py --apply.
; ---------------------------------------------------------------------
DisplayList_Run_Stack_Wrap:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F9A724  f1 40 25 00 02
	lda xbc, (DL_RealtimeCommandsClock:24)               ; F9A729  f2 91 cc f0 31
	push XBC                                             ; F9A72E  39
	lda xwa, (DL_OnOff:24)                               ; F9A72F  f2 83 cc f0 30
	push XWA                                             ; F9A734  38
	call T_DisplayList_Run_Stack                         ; F9A735  1d 00 2e f4
	inc 8,XSP                                            ; F9A739  ef 60
	ret                                                  ; F9A73B  0e
; MidiRealtimeMessages_PaintClockKeyGlyphs -- draw DL_F0CC75 in place of ON/OFF while CLOCK (item 1) is selected
; Evidence: DL_F0CC75 puts glyph 0x8D at 0x0BDB and 0x8E at 0x117B, beside the row-2/row-3 right keys; called by
;   Paint_MidiRealtimeMessages when (0x2720)!=0 and by MidiRealtimeMessages_SelectClock; (0x2540)=2 as in its
;   sibling.
MidiRealtimeMessages_PaintClockKeyGlyphs:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F9A73C  f1 40 25 00 02
	lda xbc, (DL_OnOff:24)                               ; F9A741  f2 83 cc f0 31
	push XBC                                             ; F9A746  39
	lda xwa, (DL_F0CC75:24)                              ; F9A747  f2 75 cc f0 30
	push XWA                                             ; F9A74C  38
	call T_DisplayList_Run_Stack                         ; F9A74D  1d 00 2e f4
	inc 8,XSP                                            ; F9A751  ef 60
	ret                                                  ; F9A753  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiRealtimeMessages -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0x95, i.e. SCREEN ID 0x75 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x95 -> the screen object at
;          0xF41690, whose +4 slot is `jp 0xF9A754`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiRealtimeMessages -- the same object's +0 ENTER method carries
;          the label Paint_MidiRealtimeMessages, a name an earlier round
;          derived from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F9A754`.
; ---------------------------------------------------------------------
ScreenLeave_MidiRealtimeMessages:
	ret                                                  ; F9A754  0e
T_F4169C_Nop:
	ret                                                  ; F9A755  0e
; ---------------------------------------------------------------------
; ScreenButton_MidiRealtimeMessages -- the BUTTON method of the screen object
;          at PanelScreen_VtableTable entry 0x95, i.e. SCREEN ID 0x75 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x95 -> the screen object at
;          0xF41690, whose +8 slot is `jp 0xF9A756`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiRealtimeMessages -- the same object's +0 ENTER method carries
;          the label Paint_MidiRealtimeMessages, a name an earlier round
;          derived from the screen's own text.
; Was `sub_F9A756`.
; ---------------------------------------------------------------------
ScreenButton_MidiRealtimeMessages:
	link XIZ,0x0000                                      ; F9A756  ee 0c 00 00
	pushw hl                                             ; F9A75A  2b
	cpw	(xiz+8), 0x001f                              ; F9A75B  9e 08 3f 1f 00
	jrl ugt, .LF9A836                                        ; F9A760  7b d3 00
	ld L,(XIZ+0x08)                                      ; F9A763  8e 08 27
	ld C,(XIZ+0x0a)                                      ; F9A766  8e 0a 23
	and C,0x80                                           ; F9A769  cb cc 80
	jr nz, .LF9A772                                      ; F9A76C  6e 04
	ld h, 0x00:opc                                          ; F9A76E  26 00
	jr .LF9A774                                          ; F9A770  68 02
.LF9A772:
	ld h, 0x01:opc                                          ; F9A772  26 01
.LF9A774:
	ld C,L                                               ; F9A774  cf 8b
	extz BC                                              ; F9A776  d9 12
	extz XBC                                             ; F9A778  e9 12
	cp BC,0x001f                                         ; F9A77A  d9 cf 1f 00
	jrl ugt, .LF9A836                                        ; F9A77E  7b b5 00
	sll bc, 0x02                                         ; F9A781  d9 ee 02
	add XBC,ScreenButtonHandlers_MidiRealtimeMessages                             ; F9A784  e9 c8 8e a7 f9 00
	ld XBC,(XBC)                                         ; F9A78A  a1 21
	jp (xbc)                                             ; F9A78C  b1 d8
; ---------------------------------------------------------------------
; ScreenButtonHandlers_MidiRealtimeMessages -- 32 LE32 branch targets, same reader shape
;
; Read by: `cp BC,0x001F / ... / add XBC,0x00F9A78E` at 0xF9A77A-0xF9A78D.
; ENTRY COUNT 32 from that `cp`.  ★ base + 128 = 0xF9A80E = the minimum entry.
; Selector: the panel BUTTON CODE.  ScreenButton_MidiRealtimeMessages (0xF9A756) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x95 (prom_b
;          slot 0xF41698); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld L,(XIZ+0x08)` ... `ld C,L / cp BC,0x001F / sll 2,BC /
;          add XBC,<this> / ld XBC,(XBC) / jp (XBC)`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as JumpTable_F99F96.
; ---------------------------------------------------------------------
ScreenButtonHandlers_MidiRealtimeMessages:
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A78E  [  0]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A792  [  1]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A796  [  2]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A79A  [  3]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A79E  [  4]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7A2  [  5]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7A6  [  6]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7AA  [  7]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7AE  [  8]
	.long LcdKeyRow2_MidiRealtimeMessages                                 ; F9A7B2  [  9]
	.long LcdKeyRow3_MidiRealtimeMessages                                 ; F9A7B6  [ 10]
	.long LcdKeyRow4_MidiRealtimeMessages                                 ; F9A7BA  [ 11]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7BE  [ 12]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7C2  [ 13]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7C6  [ 14]
	.long ExitKey_MidiRealtimeMessages                                 ; F9A7CA  [ 15]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7CE  [ 16]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7D2  [ 17]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7D6  [ 18]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7DA  [ 19]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7DE  [ 20]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7E2  [ 21]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7E6  [ 22]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7EA  [ 23]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7EE  [ 24]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7F2  [ 25]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7F6  [ 26]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7FA  [ 27]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A7FE  [ 28]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A802  [ 29]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A806  [ 30]
	.long IgnoredKeys_MidiRealtimeMessages                                 ; F9A80A  [ 31]
; LcdKeyRow2_MidiRealtimeMessages -- switch arm of ScreenButton_MidiRealtimeMessages for code 0x09 (LCD row 2):
;   MidiRealtimeMessages_SetOnOrSelectCommands(H)
; Evidence: ScreenButtonHandlers_MidiRealtimeMessages entry [9], its only slot; ends in the reader's epilogue
;   (0xF9A830).
LcdKeyRow2_MidiRealtimeMessages:   ; entry: named by 1 `.long` operand, first at 0xF9A7B2
	push 0x00                                            ; F9A80E  09 00
	push H                                               ; F9A810  ce 04
	calr Draw_RealtimeCommandsClock                                      ; F9A812  1e 25 00
	jr .LF9A830                                          ; F9A815  68 19
; LcdKeyRow3_MidiRealtimeMessages -- switch arm of ScreenButton_MidiRealtimeMessages for code 0x0A (LCD row 3):
;   MidiRealtimeMessages_SetOff(H)
; Evidence: ScreenButtonHandlers_MidiRealtimeMessages entry [10], its only slot; ends in the reader's epilogue
;   (0xF9A830).
LcdKeyRow3_MidiRealtimeMessages:   ; entry: named by 1 `.long` operand, first at 0xF9A7B6
	push 0x00                                            ; F9A817  09 00
	push H                                               ; F9A819  ce 04
	calr Draw_RealtimeCommandsClock_2                                      ; F9A81B  1e c6 00
	jr .LF9A830                                          ; F9A81E  68 10
; LcdKeyRow4_MidiRealtimeMessages -- switch arm of ScreenButton_MidiRealtimeMessages for code 0x0B (LCD row 4):
;   MidiRealtimeMessages_SelectClock(H)
; Evidence: ScreenButtonHandlers_MidiRealtimeMessages entry [11], its only slot; ends in the reader's epilogue
;   (0xF9A830).
LcdKeyRow4_MidiRealtimeMessages:   ; entry: named by 1 `.long` operand, first at 0xF9A7BA
	push 0x00                                            ; F9A820  09 00
	push H                                               ; F9A822  ce 04
	calr MidiRealtimeMessages_SelectClock                                      ; F9A824  1e 2d 01
	jr .LF9A830                                          ; F9A827  68 07
; ExitKey_MidiRealtimeMessages -- switch arm of ScreenButton_MidiRealtimeMessages for code 0x0F (EXIT):
;   MidiSubmenu_ExitToMidiMenu(H)
; Evidence: ScreenButtonHandlers_MidiRealtimeMessages entry [15], its only slot; ends in the reader's epilogue
;   (0xF9A830).
ExitKey_MidiRealtimeMessages:   ; entry: named by 1 `.long` operand, first at 0xF9A7CA
	push 0x00                                            ; F9A829  09 00
	push H                                               ; F9A82B  ce 04
	calr MidiSubmenu_ExitToMidiMenu                                          ; F9A82D  1e b7 f8
.LF9A830:
	popw bc                                              ; F9A830  49
	jr .LF9A836                                          ; F9A831  68 03
; IgnoredKeys_MidiRealtimeMessages -- default arm of ScreenButton_MidiRealtimeMessages: MidiScreen_NopKeyHandler
; Evidence: 28 slots of ScreenButtonHandlers_MidiRealtimeMessages ([0]-[8], [12]-[14], [16]-[31]); LCD row 1 is
;   inert here.
IgnoredKeys_MidiRealtimeMessages:   ; entry: named by 28 `.long` operands, first at 0xF9A78E
	calr IgnoredKeys_MidiMenu_Nop                                          ; F9A833  1e fc f8
.LF9A836:
	popw hl                                              ; F9A836  4b
	unlk XIZ                                             ; F9A837  ee 0d
	ret                                                  ; F9A839  0e
Draw_RealtimeCommandsClock:
	link XIZ,0x0000                                      ; F9A83A  ee 0c 00 00
	push XIX                                             ; F9A83E  3c
	lda xix, (MidiCfg_ModeBits:16)                                ; F9A83F  f1 32 7f 34
	cp (XIZ+0x08),0x00                                   ; F9A843  8e 08 3f 00
	jr nz, .LF9A8A9                                      ; F9A847  6e 60
	cp	(UI_ScreenItem:16), 0x00                            ; F9A849  c1 20 27 3f 00
	jr nz, .LF9A870                                      ; F9A84E  6e 20
	ld c, (0x7f34:16)                                   ; F9A850  c1 34 7f 23
	and C,0x04                                           ; F9A854  cb cc 04
	jrl nz, .LF9A8E0                                     ; F9A857  7e 86 00
	set	2, (0x7f34:16)                               ; F9A85A  f1 34 7f ba
	pushw 0x04                                           ; F9A85E  0b 04 00
	pushw 0x04                                           ; F9A861  0b 04 00
	pushw 0x02                                           ; F9A864  0b 02 00
	pushw 0x80                                           ; F9A867  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A86A  1d 18 1b f4
	jr .LF9A88E                                          ; F9A86E  68 1e
.LF9A870:
	ld C,(XIX)                                           ; F9A870  84 23
	and C,0x04                                           ; F9A872  cb cc 04
	jr nz, .LF9A8E0                                      ; F9A875  6e 69
	or	(xix), 0x04                                  ; F9A877  84 3e 04
	pushw 0x04                                           ; F9A87A  0b 04 00
	pushw 0x04                                           ; F9A87D  0b 04 00
	pushw 0x00                                           ; F9A880  0b 00 00
	pushw 0x80                                           ; F9A883  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A886  1d 18 1b f4
	call T_Tempo_ApplyBpm                                        ; F9A88A  1d 94 07 f4
.LF9A88E:
	inc 8,XSP                                            ; F9A88E  ef 60
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A890  f1 40 25 00 00
	lda xbc, (DL_F0CCAF:24)                              ; F9A895  f2 af cc f0 31
	push XBC                                             ; F9A89A  39
	lda xwa, (DL_RealtimeCommandsClock:24)               ; F9A89B  f2 91 cc f0 30
	push XWA                                             ; F9A8A0  38
	call T_DisplayListB_Run_Stack                        ; F9A8A1  1d 04 2e f4
	inc 8,XSP                                            ; F9A8A5  ef 60
	jr .LF9A8E0                                          ; F9A8A7  68 37
.LF9A8A9:
	cp	(UI_ScreenItem:16), 0x00                            ; F9A8A9  c1 20 27 3f 00
	jr z, .LF9A8E0                                       ; F9A8AE  66 30
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9A8B0  f1 40 25 00 01
	lda xbc, (DL_F0CCBA:24)                              ; F9A8B5  f2 ba cc f0 31
	push XBC                                             ; F9A8BA  39
	call T_DisplayListB_RunOne_Stack                     ; F9A8BB  1d 0c 2e f4
	ld (UI_ScreenItem:16), 0x00                                 ; F9A8BF  f1 20 27 00 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A8C4  f1 40 25 00 00
	lda xbc, (DL_F0CCBA:24)                              ; F9A8C9  f2 ba cc f0 31
	push XBC                                             ; F9A8CE  39
	lda xwa, (DL_F0CCAF:24)                              ; F9A8CF  f2 af cc f0 30
	push XWA                                             ; F9A8D4  38
	call T_DisplayListB_Run_Stack                        ; F9A8D5  1d 04 2e f4
	calr DisplayList_Run_Stack_Wrap                                          ; F9A8D9  1e 48 fe
	inc 8,XSP                                            ; F9A8DC  ef 60
	inc 4,XSP                                            ; F9A8DE  ef 64
.LF9A8E0:
	pop XIX                                              ; F9A8E0  5c
	unlk XIZ                                             ; F9A8E1  ee 0d
	ret                                                  ; F9A8E3  0e
Draw_RealtimeCommandsClock_2:
	link XIZ,0x0000                                      ; F9A8E4  ee 0c 00 00
	push XIX                                             ; F9A8E8  3c
	lda xix, (MidiCfg_ModeBits:16)                                ; F9A8E9  f1 32 7f 34
	cp (XIZ+0x08),0x00                                   ; F9A8ED  8e 08 3f 00
	jr nz, .LF9A950                                      ; F9A8F1  6e 5d
	cp	(UI_ScreenItem:16), 0x00                            ; F9A8F3  c1 20 27 3f 00
	jr nz, .LF9A919                                      ; F9A8F8  6e 1f
	ld c, (0x7f34:16)                                   ; F9A8FA  c1 34 7f 23
	and C,0x04                                           ; F9A8FE  cb cc 04
	jr z, .LF9A950                                       ; F9A901  66 4d
	res	2, (0x7f34:16)                               ; F9A903  f1 34 7f b2
	pushw 0x04                                           ; F9A907  0b 04 00
	pushw 0xfb                                           ; F9A90A  0b fb 00
	pushw 0x02                                           ; F9A90D  0b 02 00
	pushw 0x80                                           ; F9A910  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A913  1d 18 1b f4
	jr .LF9A937                                          ; F9A917  68 1e
.LF9A919:
	ld C,(XIX)                                           ; F9A919  84 23
	and C,0x04                                           ; F9A91B  cb cc 04
	jr z, .LF9A950                                       ; F9A91E  66 30
	and (XIX),0xfb                                       ; F9A920  84 3c fb
	pushw 0x04                                           ; F9A923  0b 04 00
	pushw 0xfb                                           ; F9A926  0b fb 00
	pushw 0x00                                           ; F9A929  0b 00 00
	pushw 0x80                                           ; F9A92C  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9A92F  1d 18 1b f4
	call T_Tempo_ApplyBpm                                        ; F9A933  1d 94 07 f4
.LF9A937:
	inc 8,XSP                                            ; F9A937  ef 60
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A939  f1 40 25 00 00
	lda xbc, (DL_F0CCAF:24)                              ; F9A93E  f2 af cc f0 31
	push XBC                                             ; F9A943  39
	lda xwa, (DL_RealtimeCommandsClock:24)               ; F9A944  f2 91 cc f0 30
	push XWA                                             ; F9A949  38
	call T_DisplayListB_Run_Stack                        ; F9A94A  1d 04 2e f4
	inc 8,XSP                                            ; F9A94E  ef 60
.LF9A950:
	pop XIX                                              ; F9A950  5c
	unlk XIZ                                             ; F9A951  ee 0d
	ret                                                  ; F9A953  0e
; MidiRealtimeMessages_SelectClock -- LCD row 4, left key: select the CLOCK item
; Evidence: when (XIZ+8)!=0 and (0x2720)!=1: erase/draw the cursor box (DL_F0CCBA, DL_F0CCAF), (0x2720)=1, then
;   MidiRealtimeMessages_PaintClockKeyGlyphs.  "CLOCK  :" carries the row-4 left arrow (0x1798).
MidiRealtimeMessages_SelectClock:
	link XIZ,0x0000                                      ; F9A954  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9A958  8e 08 3f 00
	jr z, .LF9A995                                       ; F9A95C  66 37
	cp	(UI_ScreenItem:16), 0x01                            ; F9A95E  c1 20 27 3f 01
	jr z, .LF9A995                                       ; F9A963  66 30
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9A965  f1 40 25 00 01
	lda xbc, (DL_F0CCBA:24)                              ; F9A96A  f2 ba cc f0 31
	push XBC                                             ; F9A96F  39
	call T_DisplayListB_RunOne_Stack                     ; F9A970  1d 0c 2e f4
	ld (UI_ScreenItem:16), 0x01                                 ; F9A974  f1 20 27 00 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A979  f1 40 25 00 00
	lda xbc, (DL_F0CCBA:24)                              ; F9A97E  f2 ba cc f0 31
	push XBC                                             ; F9A983  39
	lda xwa, (DL_F0CCAF:24)                              ; F9A984  f2 af cc f0 30
	push XWA                                             ; F9A989  38
	call T_DisplayListB_Run_Stack                        ; F9A98A  1d 04 2e f4
	calr MidiRealtimeMessages_PaintClockKeyGlyphs                                          ; F9A98E  1e ab fd
	inc 8,XSP                                            ; F9A991  ef 60
	inc 4,XSP                                            ; F9A993  ef 64
.LF9A995:
	unlk XIZ                                             ; F9A995  ee 0d
	ret                                                  ; F9A997  0e
; ---------------------------------------------------------------------
; Paint_MidiInputOutputFilter -- paints the screen whose own text reads "INPUT&OUTPUT" / "FILTER" / "MIDI"
;
; Called from: prom_b T_F4174C (`jp`)
;
; It hands 3 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9A9EC  list 0xF0CCEE-0xF0CDE7 (249 B, leaves by call)
;        text: "INPUT&OUTPUT"; "FILTER"; "MIDI"; "PR0GRAM CHANGE   :"; ...
;     site 0xF9A9FC  list 0xF0C917-0xF0C964 (77 B, leaves by call)
;        text: "ITEM"; "$ VALUE"
;     site 0xF9AA2D  list 0xF0CE5F-0xF0CE75 (22 B, leaves by call)
; From the captions: "MIDI"; "INPUT&OUTPUT"; "FILTER"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiInputOutputFilter:
	link XIZ,0xfffc                                      ; F9A998  ee 0c fc ff
	push XIX                                             ; F9A99C  3c
	lda xix, (UI_ScreenFlags:16)                                ; F9A99D  f1 95 20 34
	ld c, (UI_ScreenLatch:16)                                   ; F9A9A1  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; F9A9A5  c1 7b 20 f3
	jr z, .LF9A9B8                                       ; F9A9A9  66 0d
	and (XIX),0xef                                       ; F9A9AB  84 3c ef
	ld (UI_ScreenItem:16), 0x00                                 ; F9A9AE  f1 20 27 00 00
	ld (0x2721:16), 0x00                                 ; F9A9B3  f1 21 27 00 00
.LF9A9B8:
	call T_CallbackQueue_ResetAndRestartTask2            ; F9A9B8  1d 80 2e f4
	sub XBC,XBC                                          ; F9A9BC  e9 a1
	dec 1,XBC                                            ; F9A9BE  e9 69
	ld (xiz-4), xbc                                      ; F9A9C0  be fc 61
	ld (0x2666:16), xbc                                 ; F9A9C3  f1 66 26 61
	ld xwa, (xiz-4)                                      ; F9A9C7  ae fc 20
	ld (0x266a:16), xwa                                 ; F9A9CA  f1 6a 26 60
	set	0, (UI_RequestBits:16)                               ; F9A9CE  f1 75 20 b8
	ld (PanelDial_UpButton:16), 0x80                                 ; F9A9D2  f1 9c 20 00 80
	ld (PanelDial_DownButton:16), 0x00                                 ; F9A9D7  f1 9b 20 00 00
	ld C,(XIX)                                           ; F9A9DC  84 23
	and C,0x10                                           ; F9A9DE  cb cc 10
	jr nz, .LF9AA10                                      ; F9A9E1  6e 2d
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9A9E3  f1 40 25 00 00
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F9A9E8  1d 10 2e f4
	lda xbc, (DL_F0CDE7:24)                              ; F9A9EC  f2 e7 cd f0 31
	push XBC                                             ; F9A9F1  39
	lda xwa, (DL_InputOutputFilterMidiPr0gramChange:24)  ; F9A9F2  f2 ee cc f0 30
	push XWA                                             ; F9A9F7  38
	call T_DisplayList_Run_Stack                         ; F9A9F8  1d 00 2e f4
	lda xbc, (DL_TotalModeMidiMidiInputMode:24)          ; F9A9FC  f2 64 c9 f0 31
	push XBC                                             ; F9AA01  39
	lda xwa, (DL_F0C917:24)                              ; F9AA02  f2 17 c9 f0 30
	push XWA                                             ; F9AA07  38
	call T_DisplayList_Run_Stack                         ; F9AA08  1d 00 2e f4
	inc 8,XSP                                            ; F9AA0C  ef 60
	inc 8,XSP                                            ; F9AA0E  ef 60
.LF9AA10:
	calr MidiInputOutputFilter_PaintProgramChange                                          ; F9AA10  1e dc 01
	calr MidiInputOutputFilter_PaintBankSelect                                          ; F9AA13  1e ff 01
	calr MidiInputOutputFilter_PaintPitchBend                                          ; F9AA16  1e 22 02
	calr MidiInputOutputFilter_PaintControlChange                                          ; F9AA19  1e 45 02
	calr MidiInputOutputFilter_PaintResetAllCtrl                                          ; F9AA1C  1e 68 02
	calr MidiInputOutputFilter_PaintChannelPressure                                          ; F9AA1F  1e 88 02
	calr MidiInputOutputFilter_PaintSongSelect                                          ; F9AA22  1e ab 02
	calr MidiInputOutputFilter_PaintExclusive                                          ; F9AA25  1e ce 02
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9AA28  f1 40 25 00 01
	lda xbc, (DLTable_OffOn:24)                          ; F9AA2D  f2 75 ce f0 31
	push XBC                                             ; F9AA32  39
	lda xwa, (DL_F0CE5F:24)                              ; F9AA33  f2 5f ce f0 30
	push XWA                                             ; F9AA38  38
	call T_DisplayListB_Run_Stack                        ; F9AA39  1d 04 2e f4
	ld c, (UI_ScreenItem:16)                                   ; F9AA3D  c1 20 27 23
	ld (0x2721:16), c                                   ; F9AA41  f1 21 27 43
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F9AA45  1d 14 2e f4
	inc 8,XSP                                            ; F9AA49  ef 60
	pop XIX                                              ; F9AA4B  5c
	unlk XIZ                                             ; F9AA4C  ee 0d
	ret                                                  ; F9AA4E  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiInputOutputFilter -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0x9E, i.e. SCREEN ID 0x7E through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9E -> the screen object at
;          0xF4174C, whose +4 slot is `jp 0xF9AA4F`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiInputOutputFilter -- the same object's +0 ENTER method
;          carries the label Paint_MidiInputOutputFilter, a name an earlier
;          round derived from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F9AA4F`.
; ---------------------------------------------------------------------
ScreenLeave_MidiInputOutputFilter:
	ret                                                  ; F9AA4F  0e
T_F41758_Nop:
	ret                                                  ; F9AA50  0e
; ---------------------------------------------------------------------
; ScreenButton_MidiInputOutputFilter -- the BUTTON method of the screen
;          object at PanelScreen_VtableTable entry 0x9E, i.e. SCREEN ID 0x7E
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9E -> the screen object at
;          0xF4174C, whose +8 slot is `jp 0xF9AA51`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiInputOutputFilter -- the same object's +0 ENTER method
;          carries the label Paint_MidiInputOutputFilter, a name an earlier
;          round derived from the screen's own text.
; Was `sub_F9AA51`.
; ---------------------------------------------------------------------
ScreenButton_MidiInputOutputFilter:
	link XIZ,0x0000                                      ; F9AA51  ee 0c 00 00
	pushw hl                                             ; F9AA55  2b
	cpw	(xiz+8), 0x001f                              ; F9AA56  9e 08 3f 1f 00
	jrl ugt, .LF9AB28                                        ; F9AA5B  7b ca 00
	ld L,(XIZ+0x08)                                      ; F9AA5E  8e 08 27
	ld C,(XIZ+0x0a)                                      ; F9AA61  8e 0a 23
	and C,0x80                                           ; F9AA64  cb cc 80
	jr nz, .LF9AA6D                                      ; F9AA67  6e 04
	ld h, 0x00:opc                                          ; F9AA69  26 00
	jr .LF9AA6F                                          ; F9AA6B  68 02
.LF9AA6D:
	ld h, 0x01:opc                                          ; F9AA6D  26 01
.LF9AA6F:
	ld C,L                                               ; F9AA6F  cf 8b
	extz BC                                              ; F9AA71  d9 12
	extz XBC                                             ; F9AA73  e9 12
	cp BC,0x001f                                         ; F9AA75  d9 cf 1f 00
	jrl ugt, .LF9AB28                                        ; F9AA79  7b ac 00
	sll bc, 0x02                                         ; F9AA7C  d9 ee 02
	add XBC,ScreenButtonHandlers_MidiInputOutputFilter                             ; F9AA7F  e9 c8 89 aa f9 00
	ld XBC,(XBC)                                         ; F9AA85  a1 21
	jp (xbc)                                             ; F9AA87  b1 d8
; ---------------------------------------------------------------------
; ScreenButtonHandlers_MidiInputOutputFilter -- 32 LE32 branch targets, same reader shape
;
; Read by: `cp BC,0x001F / ... / add XBC,0x00F9AA89` at 0xF9AA75-0xF9AA88.
; ENTRY COUNT 32 from that `cp`.  ★ base + 128 = 0xF9AB09 = the minimum entry.
; Selector: the panel BUTTON CODE.  ScreenButton_MidiInputOutputFilter (0xF9AA51) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x9E (prom_b
;          slot 0xF41754); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld L,(XIZ+0x08)` ... `ld C,L / cp BC,0x001F / sll 2,BC /
;          add XBC,<this> / ld XBC,(XBC) / jp (XBC)`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as JumpTable_F99F96.
; ---------------------------------------------------------------------
ScreenButtonHandlers_MidiInputOutputFilter:
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AA89  [  0]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AA8D  [  1]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AA91  [  2]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AA95  [  3]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AA99  [  4]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AA9D  [  5]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AAA1  [  6]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AAA5  [  7]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAA9  [  8]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAAD  [  9]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAB1  [ 10]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAB5  [ 11]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAB9  [ 12]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AABD  [ 13]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAC1  [ 14]
	.long ExitKey_MidiInputOutputFilter                                 ; F9AAC5  [ 15]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAC9  [ 16]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AACD  [ 17]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AAD1  [ 18]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AAD5  [ 19]
	.long ItemKeys_MidiInputOutputFilter                                 ; F9AAD9  [ 20]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AADD  [ 21]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AAE1  [ 22]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AAE5  [ 23]
	.long ValueKeys_MidiInputOutputFilter                                 ; F9AAE9  [ 24]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAED  [ 25]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAF1  [ 26]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAF5  [ 27]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAF9  [ 28]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AAFD  [ 29]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AB01  [ 30]
	.long IgnoredKeys_MidiInputOutputFilter                                 ; F9AB05  [ 31]
; ExitKey_MidiInputOutputFilter -- switch arm of ScreenButton_MidiInputOutputFilter for code 0x0F (EXIT):
;   MidiSubmenu_ExitToMidiMenu(H)
; Evidence: ScreenButtonHandlers_MidiInputOutputFilter entry [15]; ends in the reader's epilogue (0xF9AB22).
ExitKey_MidiInputOutputFilter:   ; entry: named by 1 `.long` operand, first at 0xF9AAC5
	push 0x00                                            ; F9AB09  09 00
	push H                                               ; F9AB0B  ce 04
	calr MidiSubmenu_ExitToMidiMenu                                          ; F9AB0D  1e d7 f5
	jr .LF9AB22                                          ; F9AB10  68 10
; ItemKeys_MidiInputOutputFilter -- switch arm for codes 0x00-0x03 / 0x11-0x14: MidiInputOutputFilter_StepItem(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiInputOutputFilter; the screen draws "ITEM" (DL_F0C917);
;   Paint_MidiInputOutputFilter sets (0x209C)=0x80 / (0x209B)=0x00, so the dial reaches this arm as code 0.
ItemKeys_MidiInputOutputFilter:   ; entry: named by 8 `.long` operands, first at 0xF9AA89
	push 0x00                                            ; F9AB12  09 00
	push H                                               ; F9AB14  ce 04
	calr MidiInputOutputFilter_StepItem                                      ; F9AB16  1e 13 00
	jr .LF9AB22                                          ; F9AB19  68 07
; ValueKeys_MidiInputOutputFilter -- switch arm for codes 0x04-0x07 / 0x15-0x18: MidiInputOutputFilter_StepValue(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiInputOutputFilter; DL_F0C917 draws "VALUE" over them.
ValueKeys_MidiInputOutputFilter:   ; entry: named by 8 `.long` operands, first at 0xF9AA99
	push 0x00                                            ; F9AB1B  09 00
	push H                                               ; F9AB1D  ce 04
	calr MidiInputOutputFilter_StepValue                                      ; F9AB1F  1e 40 00
.LF9AB22:
	popw bc                                              ; F9AB22  49
	jr .LF9AB28                                          ; F9AB23  68 03
; IgnoredKeys_MidiInputOutputFilter -- default arm of ScreenButton_MidiInputOutputFilter: MidiScreen_NopKeyHandler
; Evidence: 15 slots ([8]-[14], [16], [25]-[31]) of ScreenButtonHandlers_MidiInputOutputFilter.
IgnoredKeys_MidiInputOutputFilter:   ; entry: named by 15 `.long` operands, first at 0xF9AAA9
	calr IgnoredKeys_MidiMenu_Nop                                          ; F9AB25  1e 0a f6
.LF9AB28:
	popw hl                                              ; F9AB28  4b
	unlk XIZ                                             ; F9AB29  ee 0d
	ret                                                  ; F9AB2B  0e
; MidiInputOutputFilter_StepItem -- move the item cursor (0x2720) one row within 0..7
; Evidence: StepValue_IncDecClamped(dir = (XIZ+8)==0, max 7, min 0) -> (0x2720); DL_F0CE5F boxes the row from
;   DLTable_F0CE7B's eight entries; then `set 4,(0x2095)`.
MidiInputOutputFilter_StepItem:
	link XIZ,0x0000                                      ; F9AB2C  ee 0c 00 00
	pushw hl                                             ; F9AB30  2b
	ld H,(XIZ+0x08)                                      ; F9AB31  8e 08 26
	set	3, (UI_RequestBits:16)                               ; F9AB34  f1 75 20 bb
	ld l, (UI_ScreenItem:16)                                   ; F9AB38  c1 20 27 27
	cp h, 0x00:i3                                          ; F9AB3C  ce d8
	jr nz, .LF9AB44                                      ; F9AB3E  6e 04
	ld h, 0x01:opc                                          ; F9AB40  26 01
	jr .LF9AB46                                          ; F9AB42  68 02
.LF9AB44:
	ld h, 0x00:opc                                          ; F9AB44  26 00
.LF9AB46:
	pushw hl                                             ; F9AB46  2b
	pushw 0x00                                           ; F9AB47  0b 00 00
	pushw 0x07                                           ; F9AB4A  0b 07 00
	push 0x00                                            ; F9AB4D  09 00
	push H                                               ; F9AB4F  ce 04
	calr StepValue_IncDecClamped                                          ; F9AB51  1e aa f5
	ld (UI_ScreenItem:16), a                                   ; F9AB54  f1 20 27 41
	set	4, (UI_ScreenFlags:16)                               ; F9AB58  f1 95 20 bc
	inc 8,XSP                                            ; F9AB5C  ef 60
	popw hl                                              ; F9AB5E  4b
	unlk XIZ                                             ; F9AB5F  ee 0d
	ret                                                  ; F9AB61  0e
; MidiInputOutputFilter_StepValue -- toggle the filter under the cursor: JumpTable_F9AB84[(0x2720)], rows 0..7
; Evidence: `ld BC,(0x2720) / cp BC,7 / jrl ugt / ... add XBC,JumpTable_F9AB84 / jp (XBC)`.
MidiInputOutputFilter_StepValue:
	link XIZ,0x0000                                      ; F9AB62  ee 0c 00 00
	pushw hl                                             ; F9AB66  2b
	ld H,(XIZ+0x08)                                      ; F9AB67  8e 08 26
	ld bc, (UI_ScreenItem:16)                                 ; F9AB6A  d1 20 27 21
	extz BC                                              ; F9AB6E  d9 12
	extz XBC                                             ; F9AB70  e9 12
	cp bc, 0x07:i3                                         ; F9AB72  d9 df
	jrl ugt, JumpTable_F9AB84_Code_Skip                                        ; F9AB74  7b 74 00
	sll bc, 0x02                                         ; F9AB77  d9 ee 02
	add XBC,JumpTable_F9AB84                             ; F9AB7A  e9 c8 84 ab f9 00
	ld XBC,(XBC)                                         ; F9AB80  a1 21
	jp (xbc)                                             ; F9AB82  b1 d8
; ---------------------------------------------------------------------
; JumpTable_F9AB84 -- 8 LE32 branch targets
;
; Read by: `ld BC,(0x2720) / extz / cp BC,7 / jrl UGT,0xF9ABEB / sll 0x02,BC /
;          add XBC,0x00F9AB84 / ld XBC,(XBC) / jp T,XBC` at 0xF9AB6A-0xF9AB83.
; Inputs:  the same selector (0x2720) as JumpTable_F9A3C7.
; ENTRY COUNT 8, from `cp BC,7`.  ★ base + 32 = 0xF9ABA4 = the minimum entry.
; Evidence / Unknown: as JumpTable_F99F96.
; ---------------------------------------------------------------------
JumpTable_F9AB84:
	.long MidiInputOutputFilter_ValueCase_ProgramChange                                 ; F9AB84  [  0]
	.long MidiInputOutputFilter_ValueCase_BankSelect                                 ; F9AB88  [  1]
	.long MidiInputOutputFilter_ValueCase_PitchBend                                 ; F9AB8C  [  2]
	.long MidiInputOutputFilter_ValueCase_ControlChange                                 ; F9AB90  [  3]
	.long MidiInputOutputFilter_ValueCase_ResetAllCtrl                                 ; F9AB94  [  4]
	.long MidiInputOutputFilter_ValueCase_ChannelPressure                                 ; F9AB98  [  5]
	.long MidiInputOutputFilter_ValueCase_SongSelect                                 ; F9AB9C  [  6]
	.long MidiInputOutputFilter_ValueCase_Exclusive                                 ; F9ABA0  [  7]
; MidiInputOutputFilter_ValueCase_ProgramChange -- case 0 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditProgramChange(H)
; Evidence: JumpTable_F9AB84 entry [0]; row 0 of DL_InputOutputFilterMidiPr0gramChange is "PR0GRAM CHANGE   :" (IX
;   0x0739).
MidiInputOutputFilter_ValueCase_ProgramChange:   ; entry: named by 1 `.long` operand, first at 0xF9AB84
	push 0x00                                            ; F9ABA4  09 00
	push H                                               ; F9ABA6  ce 04
	calr MidiInputOutputFilter_EditProgramChange                                      ; F9ABA8  1e 76 01
	jr .LF9ABEA                                          ; F9ABAB  68 3d
; MidiInputOutputFilter_ValueCase_BankSelect -- case 1 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditBankSelect(H)
; Evidence: JumpTable_F9AB84 entry [1]; row 1 of DL_InputOutputFilterMidiPr0gramChange is "BANK SELECT      :" (IX
;   0x0A09).
MidiInputOutputFilter_ValueCase_BankSelect:   ; entry: named by 1 `.long` operand, first at 0xF9AB88
	push 0x00                                            ; F9ABAD  09 00
	push H                                               ; F9ABAF  ce 04
	calr MidiInputOutputFilter_EditBankSelect                                      ; F9ABB1  1e b5 01
	jr .LF9ABEA                                          ; F9ABB4  68 34
; MidiInputOutputFilter_ValueCase_PitchBend -- case 2 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditPitchBend(H)
; Evidence: JumpTable_F9AB84 entry [2]; row 2 of DL_InputOutputFilterMidiPr0gramChange is "PITCH BEND       :" (IX
;   0x0CD9).
MidiInputOutputFilter_ValueCase_PitchBend:   ; entry: named by 1 `.long` operand, first at 0xF9AB8C
	push 0x00                                            ; F9ABB6  09 00
	push H                                               ; F9ABB8  ce 04
	calr MidiInputOutputFilter_EditPitchBend                                      ; F9ABBA  1e f4 01
	jr .LF9ABEA                                          ; F9ABBD  68 2b
; MidiInputOutputFilter_ValueCase_ControlChange -- case 3 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditControlChange(H)
; Evidence: JumpTable_F9AB84 entry [3]; row 3 of DL_InputOutputFilterMidiPr0gramChange is "C0NTR0L CHANGE   :" (IX
;   0x0FA9).
MidiInputOutputFilter_ValueCase_ControlChange:   ; entry: named by 1 `.long` operand, first at 0xF9AB90
	push 0x00                                            ; F9ABBF  09 00
	push H                                               ; F9ABC1  ce 04
	calr MidiInputOutputFilter_EditControlChange                                      ; F9ABC3  1e 33 02
	jr .LF9ABEA                                          ; F9ABC6  68 22
; MidiInputOutputFilter_ValueCase_ResetAllCtrl -- case 4 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditResetAllCtrl(H)
; Evidence: JumpTable_F9AB84 entry [4]; row 4 of DL_InputOutputFilterMidiPr0gramChange is "RESET ALL CTRL" (IX
;   0x1279).
MidiInputOutputFilter_ValueCase_ResetAllCtrl:   ; entry: named by 1 `.long` operand, first at 0xF9AB94
	push 0x00                                            ; F9ABC8  09 00
	push H                                               ; F9ABCA  ce 04
	calr MidiInputOutputFilter_EditResetAllCtrl                                      ; F9ABCC  1e 72 02
	jr .LF9ABEA                                          ; F9ABCF  68 19
; MidiInputOutputFilter_ValueCase_ChannelPressure -- case 5 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditChannelPressure(H)
; Evidence: JumpTable_F9AB84 entry [5]; row 5 of DL_InputOutputFilterMidiPr0gramChange is "CHANNEL PRESSURE :" (IX
;   0x1549).
MidiInputOutputFilter_ValueCase_ChannelPressure:   ; entry: named by 1 `.long` operand, first at 0xF9AB98
	push 0x00                                            ; F9ABD1  09 00
	push H                                               ; F9ABD3  ce 04
	calr MidiInputOutputFilter_EditChannelPressure                                      ; F9ABD5  1e b1 02
	jr .LF9ABEA                                          ; F9ABD8  68 10
; MidiInputOutputFilter_ValueCase_SongSelect -- case 6 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditSongSelect(H)
; Evidence: JumpTable_F9AB84 entry [6]; row 6 of DL_InputOutputFilterMidiPr0gramChange is "S0NG SELECT      :" (IX
;   0x1819).
MidiInputOutputFilter_ValueCase_SongSelect:   ; entry: named by 1 `.long` operand, first at 0xF9AB9C
	push 0x00                                            ; F9ABDA  09 00
	push H                                               ; F9ABDC  ce 04
	calr MidiInputOutputFilter_EditSongSelect                                      ; F9ABDE  1e f0 02
	jr .LF9ABEA                                          ; F9ABE1  68 07
; MidiInputOutputFilter_ValueCase_Exclusive -- case 7 of MidiInputOutputFilter_StepValue:
;   MidiInputOutputFilter_EditExclusive(H)
; Evidence: JumpTable_F9AB84 entry [7]; row 7 of DL_InputOutputFilterMidiPr0gramChange is "EXCLUSIVE        :" (IX
;   0x1AE9).
MidiInputOutputFilter_ValueCase_Exclusive:   ; entry: named by 1 `.long` operand, first at 0xF9ABA0
	push 0x00                                            ; F9ABE3  09 00
	push H                                               ; F9ABE5  ce 04
	calr MidiInputOutputFilter_EditExclusive                                      ; F9ABE7  1e 2f 03
.LF9ABEA:
	popw bc                                              ; F9ABEA  49
JumpTable_F9AB84_Code_Skip:
	popw hl                                              ; F9ABEB  4b
	unlk XIZ                                             ; F9ABEC  ee 0d
	ret                                                  ; F9ABEE  0e
; MidiInputOutputFilter_PaintProgramChange -- draw the PR0GRAM CHANGE filter state: (0x7F39) bit 4 -> (0x2740) ->
;   DL_F0CDE7 (DLTable_OffOn)
; Evidence: DL_F0CDE7 reads (0x2740) and draws at IX 0x074C, the text row of "PR0GRAM CHANGE   :" (IX 0x0739);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditProgramChange.
MidiInputOutputFilter_PaintProgramChange:
	ld c, (MidiFilter_ChannelMsgs:16)                                   ; F9ABEF  c1 39 7f 23
	and C,0x10                                           ; F9ABF3  cb cc 10
	srl c, 0x04                                          ; F9ABF6  cb ef 04
	ld (0x2740:16), c                                   ; F9ABF9  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9ABFD  f1 40 25 00 00
	lda xbc, (DL_F0CDF6:24)                              ; F9AC02  f2 f6 cd f0 31
	push XBC                                             ; F9AC07  39
	lda xwa, (DL_F0CDE7:24)                              ; F9AC08  f2 e7 cd f0 30
	push XWA                                             ; F9AC0D  38
	call T_DisplayListB_Run_Stack                        ; F9AC0E  1d 04 2e f4
	inc 8,XSP                                            ; F9AC12  ef 60
	ret                                                  ; F9AC14  0e
; MidiInputOutputFilter_PaintBankSelect -- draw the BANK SELECT filter state: (0x7F3A) bit 7 -> (0x2740) ->
;   DL_F0CDF6 (DLTable_OffOn)
; Evidence: DL_F0CDF6 reads (0x2740) and draws at IX 0x0A1C, the text row of "BANK SELECT      :" (IX 0x0A09);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditBankSelect.
MidiInputOutputFilter_PaintBankSelect:
	ld c, (MidiFilter_BankSelect:16)                                   ; F9AC15  c1 3a 7f 23
	and C,0x80                                           ; F9AC19  cb cc 80
	srl c, 0x07                                          ; F9AC1C  cb ef 07
	ld (0x2740:16), c                                   ; F9AC1F  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AC23  f1 40 25 00 00
	lda xbc, (DL_F0CE05:24)                              ; F9AC28  f2 05 ce f0 31
	push XBC                                             ; F9AC2D  39
	lda xwa, (DL_F0CDF6:24)                              ; F9AC2E  f2 f6 cd f0 30
	push XWA                                             ; F9AC33  38
	call T_DisplayListB_Run_Stack                        ; F9AC34  1d 04 2e f4
	inc 8,XSP                                            ; F9AC38  ef 60
	ret                                                  ; F9AC3A  0e
; MidiInputOutputFilter_PaintPitchBend -- draw the PITCH BEND filter state: (0x7F39) bit 6 -> (0x2740) -> DL_F0CE05
;   (DLTable_OffOn)
; Evidence: DL_F0CE05 reads (0x2740) and draws at IX 0x0CEC, the text row of "PITCH BEND       :" (IX 0x0CD9);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditPitchBend.
MidiInputOutputFilter_PaintPitchBend:
	ld c, (MidiFilter_ChannelMsgs:16)                                   ; F9AC3B  c1 39 7f 23
	and C,0x40                                           ; F9AC3F  cb cc 40
	srl c, 0x06                                          ; F9AC42  cb ef 06
	ld (0x2740:16), c                                   ; F9AC45  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AC49  f1 40 25 00 00
	lda xbc, (DL_F0CE14:24)                              ; F9AC4E  f2 14 ce f0 31
	push XBC                                             ; F9AC53  39
	lda xwa, (DL_F0CE05:24)                              ; F9AC54  f2 05 ce f0 30
	push XWA                                             ; F9AC59  38
	call T_DisplayListB_Run_Stack                        ; F9AC5A  1d 04 2e f4
	inc 8,XSP                                            ; F9AC5E  ef 60
	ret                                                  ; F9AC60  0e
; MidiInputOutputFilter_PaintControlChange -- draw the C0NTR0L CHANGE filter state: (0x7F39) bit 3 -> (0x2740) ->
;   DL_F0CE14 (DLTable_OffOn)
; Evidence: DL_F0CE14 reads (0x2740) and draws at IX 0x0FBC, the text row of "C0NTR0L CHANGE   :" (IX 0x0FA9);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditControlChange.
MidiInputOutputFilter_PaintControlChange:
	ld c, (MidiFilter_ChannelMsgs:16)                                   ; F9AC61  c1 39 7f 23
	and C,0x08                                           ; F9AC65  cb cc 08
	srl c, 0x03                                          ; F9AC68  cb ef 03
	ld (0x2740:16), c                                   ; F9AC6B  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AC6F  f1 40 25 00 00
	lda xbc, (DL_F0CE23:24)                              ; F9AC74  f2 23 ce f0 31
	push XBC                                             ; F9AC79  39
	lda xwa, (DL_F0CE14:24)                              ; F9AC7A  f2 14 ce f0 30
	push XWA                                             ; F9AC7F  38
	call T_DisplayListB_Run_Stack                        ; F9AC80  1d 04 2e f4
	inc 8,XSP                                            ; F9AC84  ef 60
	ret                                                  ; F9AC86  0e
; MidiInputOutputFilter_PaintResetAllCtrl -- draw the RESET ALL CTRL filter state: (0x7F3B) bit 0 -> (0x2740) ->
;   DL_F0CE23 (DLTable_OffOn)
; Evidence: DL_F0CE23 reads (0x2740) and draws at IX 0x128C, the text row of "RESET ALL CTRL" (IX 0x1279); called by
;   Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditResetAllCtrl.
MidiInputOutputFilter_PaintResetAllCtrl:
	ld c, (MidiFilter_ResetAllCtrl:16)                                   ; F9AC87  c1 3b 7f 23
	and C,0x01                                           ; F9AC8B  cb cc 01
	ld (0x2740:16), c                                   ; F9AC8E  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AC92  f1 40 25 00 00
	lda xbc, (DL_F0CE32:24)                              ; F9AC97  f2 32 ce f0 31
	push XBC                                             ; F9AC9C  39
	lda xwa, (DL_F0CE23:24)                              ; F9AC9D  f2 23 ce f0 30
	push XWA                                             ; F9ACA2  38
	call T_DisplayListB_Run_Stack                        ; F9ACA3  1d 04 2e f4
	inc 8,XSP                                            ; F9ACA7  ef 60
	ret                                                  ; F9ACA9  0e
; MidiInputOutputFilter_PaintChannelPressure -- draw the CHANNEL PRESSURE filter state: (0x7F39) bit 5 -> (0x2740)
;   -> DL_F0CE32 (DLTable_OffOn)
; Evidence: DL_F0CE32 reads (0x2740) and draws at IX 0x155C, the text row of "CHANNEL PRESSURE :" (IX 0x1549);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditChannelPressure.
MidiInputOutputFilter_PaintChannelPressure:
	ld c, (MidiFilter_ChannelMsgs:16)                                   ; F9ACAA  c1 39 7f 23
	and C,0x20                                           ; F9ACAE  cb cc 20
	srl c, 0x05                                          ; F9ACB1  cb ef 05
	ld (0x2740:16), c                                   ; F9ACB4  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9ACB8  f1 40 25 00 00
	lda xbc, (DL_F0CE41:24)                              ; F9ACBD  f2 41 ce f0 31
	push XBC                                             ; F9ACC2  39
	lda xwa, (DL_F0CE32:24)                              ; F9ACC3  f2 32 ce f0 30
	push XWA                                             ; F9ACC8  38
	call T_DisplayListB_Run_Stack                        ; F9ACC9  1d 04 2e f4
	inc 8,XSP                                            ; F9ACCD  ef 60
	ret                                                  ; F9ACCF  0e
; MidiInputOutputFilter_PaintSongSelect -- draw the S0NG SELECT filter state: (0x7F33) bit 3 -> (0x2740) ->
;   DL_F0CE41 (DLTable_OffOn)
; Evidence: DL_F0CE41 reads (0x2740) and draws at IX 0x182C, the text row of "S0NG SELECT      :" (IX 0x1819);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditSongSelect.
MidiInputOutputFilter_PaintSongSelect:
	ld c, (MidiFilter_SongSelect:16)                                   ; F9ACD0  c1 33 7f 23
	and C,0x08                                           ; F9ACD4  cb cc 08
	srl c, 0x03                                          ; F9ACD7  cb ef 03
	ld (0x2740:16), c                                   ; F9ACDA  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9ACDE  f1 40 25 00 00
	lda xbc, (DL_F0CE50:24)                              ; F9ACE3  f2 50 ce f0 31
	push XBC                                             ; F9ACE8  39
	lda xwa, (DL_F0CE41:24)                              ; F9ACE9  f2 41 ce f0 30
	push XWA                                             ; F9ACEE  38
	call T_DisplayListB_Run_Stack                        ; F9ACEF  1d 04 2e f4
	inc 8,XSP                                            ; F9ACF3  ef 60
	ret                                                  ; F9ACF5  0e
; MidiInputOutputFilter_PaintExclusive -- draw the EXCLUSIVE filter state: ON when (0x7F38) & 0x0F != 0 -> (0x2740)
;   -> DL_F0CE50 (DLTable_OffOn)
; Evidence: DL_F0CE50 reads (0x2740) and draws at IX 0x1AFC, the text row of "EXCLUSIVE        :" (IX 0x1AE9);
;   called by Paint_MidiInputOutputFilter and MidiInputOutputFilter_EditExclusive.
MidiInputOutputFilter_PaintExclusive:
	ld (0x2740:16), 0x01                                 ; F9ACF6  f1 40 27 00 01
	ld c, (MidiFilter_Exclusive:16)                                   ; F9ACFB  c1 38 7f 23
	and C,0x0f                                           ; F9ACFF  cb cc 0f
	jr nz, .LF9AD09                                      ; F9AD02  6e 05
	ld (0x2740:16), 0x00                                 ; F9AD04  f1 40 27 00 00
.LF9AD09:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AD09  f1 40 25 00 00
	lda xbc, (DL_F0CE5F:24)                              ; F9AD0E  f2 5f ce f0 31
	push XBC                                             ; F9AD13  39
	lda xwa, (DL_F0CE50:24)                              ; F9AD14  f2 50 ce f0 30
	push XWA                                             ; F9AD19  38
	call T_DisplayListB_Run_Stack                        ; F9AD1A  1d 04 2e f4
	inc 8,XSP                                            ; F9AD1E  ef 60
	ret                                                  ; F9AD20  0e
; MidiInputOutputFilter_EditProgramChange -- set (key arg 0) or clear (0x7F39) bit 4, the PR0GRAM CHANGE filter;
;   post and repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x10, D=7, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintProgramChange.  Reached through
;   JumpTable_F9AB84[0].
MidiInputOutputFilter_EditProgramChange:
	link XIZ,0x0000                                      ; F9AD21  ee 0c 00 00
	pushw hl                                             ; F9AD25  2b
	ld H,(XIZ+0x08)                                      ; F9AD26  8e 08 26
	cp h, 0x00:i3                                          ; F9AD29  ce d8
	jr nz, .LF9AD31                                      ; F9AD2B  6e 04
	ld h, 0x01:opc                                          ; F9AD2D  26 01
	jr .LF9AD33                                          ; F9AD2F  68 02
.LF9AD31:
	ld h, 0x00:opc                                          ; F9AD31  26 00
.LF9AD33:
	pushw 0x10                                           ; F9AD33  0b 10 00
	lda xbc, (MidiFilter_ChannelMsgs:16)                                ; F9AD36  f1 39 7f 31
	push XBC                                             ; F9AD3A  39
	push 0x00                                            ; F9AD3B  09 00
	push H                                               ; F9AD3D  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AD3F  1e 23 f4
	inc 8,XSP                                            ; F9AD42  ef 60
	cp a, 0x00:i3                                          ; F9AD44  c9 d8
	jr nz, .LF9AD65                                      ; F9AD46  6e 1d
	ld h, (MidiFilter_ChannelMsgs:16)                                   ; F9AD48  c1 39 7f 26
	and H,0x10                                           ; F9AD4C  ce cc 10
	pushw 0x10                                           ; F9AD4F  0b 10 00
	push 0x00                                            ; F9AD52  09 00
	push H                                               ; F9AD54  ce 04
	pushw 0x07                                           ; F9AD56  0b 07 00
	pushw 0x80                                           ; F9AD59  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AD5C  1d 18 1b f4
	calr MidiInputOutputFilter_PaintProgramChange                                      ; F9AD60  1e 8c fe
	inc 8,XSP                                            ; F9AD63  ef 60
.LF9AD65:
	popw hl                                              ; F9AD65  4b
	unlk XIZ                                             ; F9AD66  ee 0d
	ret                                                  ; F9AD68  0e
; MidiInputOutputFilter_EditBankSelect -- set (key arg 0) or clear (0x7F3A) bit 7, the BANK SELECT filter; post and
;   repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x80, D=8, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintBankSelect.  Reached through JumpTable_F9AB84[1].
MidiInputOutputFilter_EditBankSelect:
	link XIZ,0x0000                                      ; F9AD69  ee 0c 00 00
	pushw hl                                             ; F9AD6D  2b
	ld H,(XIZ+0x08)                                      ; F9AD6E  8e 08 26
	cp h, 0x00:i3                                          ; F9AD71  ce d8
	jr nz, .LF9AD79                                      ; F9AD73  6e 04
	ld h, 0x01:opc                                          ; F9AD75  26 01
	jr .LF9AD7B                                          ; F9AD77  68 02
.LF9AD79:
	ld h, 0x00:opc                                          ; F9AD79  26 00
.LF9AD7B:
	pushw 0x80                                           ; F9AD7B  0b 80 00
	lda xbc, (MidiFilter_BankSelect:16)                                ; F9AD7E  f1 3a 7f 31
	push XBC                                             ; F9AD82  39
	push 0x00                                            ; F9AD83  09 00
	push H                                               ; F9AD85  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AD87  1e db f3
	inc 8,XSP                                            ; F9AD8A  ef 60
; (sub_F9AD8C removed 2026-10-04: no code names it and the line above falls through into it -- part of MidiInputOutputFilter_EditBankSelect;
;  notes/prom_a_stray_label_removal.py)
	cp a, 0x00:i3                                          ; F9AD8C  c9 d8
	jr nz, .LF9ADAD                                      ; F9AD8E  6e 1d
	ld h, (MidiFilter_BankSelect:16)                                   ; F9AD90  c1 3a 7f 26
	and H,0x80                                           ; F9AD94  ce cc 80
	pushw 0x80                                           ; F9AD97  0b 80 00
	push 0x00                                            ; F9AD9A  09 00
	push H                                               ; F9AD9C  ce 04
	pushw 0x08                                           ; F9AD9E  0b 08 00
	pushw 0x80                                           ; F9ADA1  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9ADA4  1d 18 1b f4
	calr MidiInputOutputFilter_PaintBankSelect                                      ; F9ADA8  1e 6a fe
	inc 8,XSP                                            ; F9ADAB  ef 60
.LF9ADAD:
	popw hl                                              ; F9ADAD  4b
	unlk XIZ                                             ; F9ADAE  ee 0d
	ret                                                  ; F9ADB0  0e
; MidiInputOutputFilter_EditPitchBend -- set (key arg 0) or clear (0x7F39) bit 6, the PITCH BEND filter; post and
;   repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x40, D=7, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintPitchBend.  Reached through JumpTable_F9AB84[2].
MidiInputOutputFilter_EditPitchBend:
	link XIZ,0x0000                                      ; F9ADB1  ee 0c 00 00
	pushw hl                                             ; F9ADB5  2b
	ld H,(XIZ+0x08)                                      ; F9ADB6  8e 08 26
	cp h, 0x00:i3                                          ; F9ADB9  ce d8
	jr nz, .LF9ADC1                                      ; F9ADBB  6e 04
	ld h, 0x01:opc                                          ; F9ADBD  26 01
	jr .LF9ADC3                                          ; F9ADBF  68 02
.LF9ADC1:
	ld h, 0x00:opc                                          ; F9ADC1  26 00
.LF9ADC3:
	pushw 0x40                                           ; F9ADC3  0b 40 00
	lda xbc, (MidiFilter_ChannelMsgs:16)                                ; F9ADC6  f1 39 7f 31
	push XBC                                             ; F9ADCA  39
	push 0x00                                            ; F9ADCB  09 00
	push H                                               ; F9ADCD  ce 04
	calr ByteField_SetOrClearMask                                          ; F9ADCF  1e 93 f3
	inc 8,XSP                                            ; F9ADD2  ef 60
	cp a, 0x00:i3                                          ; F9ADD4  c9 d8
	jr nz, .LF9ADF5                                      ; F9ADD6  6e 1d
	ld h, (MidiFilter_ChannelMsgs:16)                                   ; F9ADD8  c1 39 7f 26
	and H,0x40                                           ; F9ADDC  ce cc 40
	pushw 0x40                                           ; F9ADDF  0b 40 00
	push 0x00                                            ; F9ADE2  09 00
	push H                                               ; F9ADE4  ce 04
	pushw 0x07                                           ; F9ADE6  0b 07 00
	pushw 0x80                                           ; F9ADE9  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9ADEC  1d 18 1b f4
	calr MidiInputOutputFilter_PaintPitchBend                                      ; F9ADF0  1e 48 fe
	inc 8,XSP                                            ; F9ADF3  ef 60
.LF9ADF5:
	popw hl                                              ; F9ADF5  4b
	unlk XIZ                                             ; F9ADF6  ee 0d
	ret                                                  ; F9ADF8  0e
; MidiInputOutputFilter_EditControlChange -- set (key arg 0) or clear (0x7F39) bit 3, the C0NTR0L CHANGE filter;
;   post and repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x08, D=7, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintControlChange.  Reached through
;   JumpTable_F9AB84[3].
MidiInputOutputFilter_EditControlChange:
	link XIZ,0x0000                                      ; F9ADF9  ee 0c 00 00
	pushw hl                                             ; F9ADFD  2b
	ld H,(XIZ+0x08)                                      ; F9ADFE  8e 08 26
	cp h, 0x00:i3                                          ; F9AE01  ce d8
	jr nz, .LF9AE09                                      ; F9AE03  6e 04
	ld h, 0x01:opc                                          ; F9AE05  26 01
	jr .LF9AE0B                                          ; F9AE07  68 02
.LF9AE09:
	ld h, 0x00:opc                                          ; F9AE09  26 00
.LF9AE0B:
	pushw 0x08                                           ; F9AE0B  0b 08 00
	lda xbc, (MidiFilter_ChannelMsgs:16)                                ; F9AE0E  f1 39 7f 31
	push XBC                                             ; F9AE12  39
	push 0x00                                            ; F9AE13  09 00
	push H                                               ; F9AE15  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AE17  1e 4b f3
	inc 8,XSP                                            ; F9AE1A  ef 60
	cp a, 0x00:i3                                          ; F9AE1C  c9 d8
	jr nz, .LF9AE3D                                      ; F9AE1E  6e 1d
	ld h, (MidiFilter_ChannelMsgs:16)                                   ; F9AE20  c1 39 7f 26
	and H,0x08                                           ; F9AE24  ce cc 08
	pushw 0x08                                           ; F9AE27  0b 08 00
	push 0x00                                            ; F9AE2A  09 00
	push H                                               ; F9AE2C  ce 04
	pushw 0x07                                           ; F9AE2E  0b 07 00
	pushw 0x80                                           ; F9AE31  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AE34  1d 18 1b f4
	calr MidiInputOutputFilter_PaintControlChange                                      ; F9AE38  1e 26 fe
	inc 8,XSP                                            ; F9AE3B  ef 60
.LF9AE3D:
	popw hl                                              ; F9AE3D  4b
	unlk XIZ                                             ; F9AE3E  ee 0d
	ret                                                  ; F9AE40  0e
; MidiInputOutputFilter_EditResetAllCtrl -- set (key arg 0) or clear (0x7F3B) bit 0, the RESET ALL CTRL filter; post
;   and repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x01, D=9, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintResetAllCtrl.  Reached through
;   JumpTable_F9AB84[4].
MidiInputOutputFilter_EditResetAllCtrl:
	link XIZ,0x0000                                      ; F9AE41  ee 0c 00 00
	pushw hl                                             ; F9AE45  2b
	ld H,(XIZ+0x08)                                      ; F9AE46  8e 08 26
	cp h, 0x00:i3                                          ; F9AE49  ce d8
	jr nz, .LF9AE51                                      ; F9AE4B  6e 04
	ld h, 0x01:opc                                          ; F9AE4D  26 01
	jr .LF9AE53                                          ; F9AE4F  68 02
.LF9AE51:
	ld h, 0x00:opc                                          ; F9AE51  26 00
.LF9AE53:
	pushw 0x01                                           ; F9AE53  0b 01 00
	lda xbc, (MidiFilter_ResetAllCtrl:16)                                ; F9AE56  f1 3b 7f 31
	push XBC                                             ; F9AE5A  39
	push 0x00                                            ; F9AE5B  09 00
	push H                                               ; F9AE5D  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AE5F  1e 03 f3
	inc 8,XSP                                            ; F9AE62  ef 60
	cp a, 0x00:i3                                          ; F9AE64  c9 d8
	jr nz, .LF9AE85                                      ; F9AE66  6e 1d
	ld h, (MidiFilter_ResetAllCtrl:16)                                   ; F9AE68  c1 3b 7f 26
	and H,0x01                                           ; F9AE6C  ce cc 01
	pushw 0x01                                           ; F9AE6F  0b 01 00
	push 0x00                                            ; F9AE72  09 00
	push H                                               ; F9AE74  ce 04
	pushw 0x09                                           ; F9AE76  0b 09 00
	pushw 0x80                                           ; F9AE79  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AE7C  1d 18 1b f4
	calr MidiInputOutputFilter_PaintResetAllCtrl                                      ; F9AE80  1e 04 fe
	inc 8,XSP                                            ; F9AE83  ef 60
.LF9AE85:
	popw hl                                              ; F9AE85  4b
	unlk XIZ                                             ; F9AE86  ee 0d
	ret                                                  ; F9AE88  0e
; MidiInputOutputFilter_EditChannelPressure -- set (key arg 0) or clear (0x7F39) bit 5, the CHANNEL PRESSURE filter;
;   post and repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x20, D=7, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintChannelPressure.  Reached through
;   JumpTable_F9AB84[5]. ⚠ the posted A is read from (0x7F3B) & 0x20 (`ld H,(0x7f3b)` at 0xF9AEB0) while the edit
;   and D=7 name 0x7F39.
MidiInputOutputFilter_EditChannelPressure:
	link XIZ,0x0000                                      ; F9AE89  ee 0c 00 00
	pushw hl                                             ; F9AE8D  2b
	ld H,(XIZ+0x08)                                      ; F9AE8E  8e 08 26
	cp h, 0x00:i3                                          ; F9AE91  ce d8
	jr nz, .LF9AE99                                      ; F9AE93  6e 04
	ld h, 0x01:opc                                          ; F9AE95  26 01
	jr .LF9AE9B                                          ; F9AE97  68 02
.LF9AE99:
	ld h, 0x00:opc                                          ; F9AE99  26 00
.LF9AE9B:
	pushw 0x20                                           ; F9AE9B  0b 20 00
	lda xbc, (MidiFilter_ChannelMsgs:16)                                ; F9AE9E  f1 39 7f 31
	push XBC                                             ; F9AEA2  39
	push 0x00                                            ; F9AEA3  09 00
	push H                                               ; F9AEA5  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AEA7  1e bb f2
	inc 8,XSP                                            ; F9AEAA  ef 60
	cp a, 0x00:i3                                          ; F9AEAC  c9 d8
	jr nz, .LF9AECD                                      ; F9AEAE  6e 1d
	ld h, (MidiFilter_ResetAllCtrl:16)                                   ; F9AEB0  c1 3b 7f 26
	and H,0x20                                           ; F9AEB4  ce cc 20
	pushw 0x20                                           ; F9AEB7  0b 20 00
	push 0x00                                            ; F9AEBA  09 00
	push H                                               ; F9AEBC  ce 04
	pushw 0x07                                           ; F9AEBE  0b 07 00
	pushw 0x80                                           ; F9AEC1  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AEC4  1d 18 1b f4
	calr MidiInputOutputFilter_PaintChannelPressure                                      ; F9AEC8  1e df fd
	inc 8,XSP                                            ; F9AECB  ef 60
.LF9AECD:
	popw hl                                              ; F9AECD  4b
	unlk XIZ                                             ; F9AECE  ee 0d
	ret                                                  ; F9AED0  0e
; MidiInputOutputFilter_EditSongSelect -- set (key arg 0) or clear (0x7F33) bit 3, the S0NG SELECT filter; post and
;   repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x08, D=1, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintSongSelect.  Reached through JumpTable_F9AB84[6].
MidiInputOutputFilter_EditSongSelect:
	link XIZ,0x0000                                      ; F9AED1  ee 0c 00 00
	pushw hl                                             ; F9AED5  2b
	ld H,(XIZ+0x08)                                      ; F9AED6  8e 08 26
	cp h, 0x00:i3                                          ; F9AED9  ce d8
	jr nz, .LF9AEE1                                      ; F9AEDB  6e 04
	ld h, 0x01:opc                                          ; F9AEDD  26 01
	jr .LF9AEE3                                          ; F9AEDF  68 02
.LF9AEE1:
	ld h, 0x00:opc                                          ; F9AEE1  26 00
.LF9AEE3:
	pushw 0x08                                           ; F9AEE3  0b 08 00
	lda xbc, (MidiFilter_SongSelect:16)                                ; F9AEE6  f1 33 7f 31
	push XBC                                             ; F9AEEA  39
	push 0x00                                            ; F9AEEB  09 00
	push H                                               ; F9AEED  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AEEF  1e 73 f2
	inc 8,XSP                                            ; F9AEF2  ef 60
	cp a, 0x00:i3                                          ; F9AEF4  c9 d8
	jr nz, .LF9AF15                                      ; F9AEF6  6e 1d
	ld h, (MidiFilter_SongSelect:16)                                   ; F9AEF8  c1 33 7f 26
	and H,0x08                                           ; F9AEFC  ce cc 08
	pushw 0x08                                           ; F9AEFF  0b 08 00
	push 0x00                                            ; F9AF02  09 00
	push H                                               ; F9AF04  ce 04
	pushw 0x01                                           ; F9AF06  0b 01 00
	pushw 0x80                                           ; F9AF09  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AF0C  1d 18 1b f4
	calr MidiInputOutputFilter_PaintSongSelect                                      ; F9AF10  1e bd fd
	inc 8,XSP                                            ; F9AF13  ef 60
.LF9AF15:
	popw hl                                              ; F9AF15  4b
	unlk XIZ                                             ; F9AF16  ee 0d
	ret                                                  ; F9AF18  0e
; MidiInputOutputFilter_EditExclusive -- set (key arg 0) or clear (0x7F38) bits 0-3, the EXCLUSIVE filter; post and
;   repaint if it changed
; Evidence: ByteField_SetOrClearMask(flag = (XIZ+8)==0, ptr, mask); on A==0 T_PendingEventQueue_AppendStackArgs posts {E=0x80, W=0x0F, D=6, A =
;   new bits} (D = byte - 0x7F32), then MidiInputOutputFilter_PaintExclusive.  Reached through JumpTable_F9AB84[7].
;   The mask is the whole low nibble: all four bits are set or cleared together.
MidiInputOutputFilter_EditExclusive:
	link XIZ,0x0000                                      ; F9AF19  ee 0c 00 00
	pushw hl                                             ; F9AF1D  2b
	ld H,(XIZ+0x08)                                      ; F9AF1E  8e 08 26
	cp h, 0x00:i3                                          ; F9AF21  ce d8
	jr nz, .LF9AF29                                      ; F9AF23  6e 04
	ld h, 0x01:opc                                          ; F9AF25  26 01
	jr .LF9AF2B                                          ; F9AF27  68 02
.LF9AF29:
	ld h, 0x00:opc                                          ; F9AF29  26 00
.LF9AF2B:
	pushw 0x0f                                           ; F9AF2B  0b 0f 00
	lda xbc, (MidiFilter_Exclusive:16)                                ; F9AF2E  f1 38 7f 31
	push XBC                                             ; F9AF32  39
	push 0x00                                            ; F9AF33  09 00
	push H                                               ; F9AF35  ce 04
	calr ByteField_SetOrClearMask                                          ; F9AF37  1e 2b f2
	inc 8,XSP                                            ; F9AF3A  ef 60
	cp a, 0x00:i3                                          ; F9AF3C  c9 d8
	jr nz, .LF9AF5D                                      ; F9AF3E  6e 1d
	ld h, (MidiFilter_Exclusive:16)                                   ; F9AF40  c1 38 7f 26
	and H,0x0f                                           ; F9AF44  ce cc 0f
	pushw 0x0f                                           ; F9AF47  0b 0f 00
	push 0x00                                            ; F9AF4A  09 00
	push H                                               ; F9AF4C  ce 04
	pushw 0x06                                           ; F9AF4E  0b 06 00
	pushw 0x80                                           ; F9AF51  0b 80 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F9AF54  1d 18 1b f4
	calr MidiInputOutputFilter_PaintExclusive                                      ; F9AF58  1e 9b fd
	inc 8,XSP                                            ; F9AF5B  ef 60
.LF9AF5D:
	popw hl                                              ; F9AF5D  4b
	unlk XIZ                                             ; F9AF5E  ee 0d
	ret                                                  ; F9AF60  0e
; ---------------------------------------------------------------------
; Paint_MidiOutProgramChange -- paints the screen whose own text reads "PROGRAM" / "CHANGE" / "MIDI" / "OUT"
;
; Called from: prom_b T_F4175C (`jp`)
;
; It hands 3 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9AFE6  list 0xF0CEBB-0xF0CFF6 (315 B, leaves by call)
;        text: "PROGRAM"; "CHANGE"; "MIDI"; "OUT"; "MIDI"; "MIDI CH     :"; ...
;     site 0xF9AFF6  list 0xF0C917-0xF0C964 (77 B, leaves by call)
;        text: "ITEM"; "$ VALUE"
;     site 0xF9B031  list 0xF0D04B-0xF0D061 (22 B, leaves by call)
; From the captions: "MIDI"; "OUT"; "PROGRAM"; "CHANGE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiOutProgramChange:
	link XIZ,0xffe9                                      ; F9AF61  ee 0c e9 ff
	push XIX                                             ; F9AF65  3c
	lda xix, (0x2741:16)                                ; F9AF66  f1 41 27 34
	ld xbc, (MidiOutPC_Paint_InitBox:24)                               ; F9AF6A  e2 7f b6 f9 21
	ld (xiz-8), xbc                                      ; F9AF6F  be f8 61
	ld xbc, (MidiOutPC_Paint_InitBox+4:24)                               ; F9AF72  e2 83 b6 f9 21
	ld (xiz-4), xbc                                      ; F9AF77  be fc 61
	push XIX                                             ; F9AF7A  3c
	ldw bc, 0x0b                                         ; F9AF7B  31 0b 00
	lda xiy, (MidiOutPC_Paint_InitRecord:24)                               ; F9AF7E  f2 87 b6 f9 35
	lda xix, (xiz-19)                                    ; F9AF83  be ed 34
	ldir85                                               ; F9AF86  85 11
	pop XIX                                              ; F9AF88  5c
	lda xbc, (xiz-8)                                     ; F9AF89  be f8 31
	ld (xiz-12), xbc                                     ; F9AF8C  be f4 61
	ld c, (UI_ScreenLatch:16)                                   ; F9AF8F  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; F9AF93  c1 7b 20 f3
	jr z, .LF9AFAA                                       ; F9AF97  66 11
	res	4, (UI_ScreenFlags:16)                               ; F9AF99  f1 95 20 b4
	ld (UI_ScreenItem:16), 0x00                                 ; F9AF9D  f1 20 27 00 00
	ld (0x2721:16), 0x00                                 ; F9AFA2  f1 21 27 00 00
	ld (XIX),0x00                                        ; F9AFA7  b4 00 00
.LF9AFAA:
	call T_CallbackQueue_ResetAndRestartTask2            ; F9AFAA  1d 80 2e f4
	sub XBC,XBC                                          ; F9AFAE  e9 a1
	dec 1,XBC                                            ; F9AFB0  e9 69
	ld (xiz-23), xbc                                     ; F9AFB2  be e9 61
	ld (0x2666:16), xbc                                 ; F9AFB5  f1 66 26 61
	ld xwa, (xiz-23)                                     ; F9AFB9  ae e9 20
	ld (0x266a:16), xwa                                 ; F9AFBC  f1 6a 26 60
	set	0, (UI_RequestBits:16)                               ; F9AFC0  f1 75 20 b8
	ld (PanelDial_UpButton:16), 0x04                                 ; F9AFC4  f1 9c 20 00 04
	ld (PanelDial_DownButton:16), 0x84                                 ; F9AFC9  f1 9b 20 00 84
	ld c, (UI_ScreenFlags:16)                                   ; F9AFCE  c1 95 20 23
	and C,0x10                                           ; F9AFD2  cb cc 10
	jr nz, .LF9B00C                                      ; F9AFD5  6e 35
	ld C,(XIX)                                           ; F9AFD7  84 23
	cp c, 0x00:i3                                          ; F9AFD9  cb d8
	jr nz, .LF9B00C                                      ; F9AFDB  6e 2f
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9AFDD  f1 40 25 00 00
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F9AFE2  1d 10 2e f4
	lda xbc, (DL_F0CFF6:24)                              ; F9AFE6  f2 f6 cf f0 31
	push XBC                                             ; F9AFEB  39
	lda xwa, (DL_ProgramChangeMidiOutMidi:24)            ; F9AFEC  f2 bb ce f0 30
	push XWA                                             ; F9AFF1  38
	call T_DisplayList_Run_Stack                         ; F9AFF2  1d 00 2e f4
	lda xbc, (DL_TotalModeMidiMidiInputMode:24)          ; F9AFF6  f2 64 c9 f0 31
	push XBC                                             ; F9AFFB  39
	lda xwa, (DL_F0C917:24)                              ; F9AFFC  f2 17 c9 f0 30
	push XWA                                             ; F9B001  38
	call T_DisplayList_Run_Stack                         ; F9B002  1d 00 2e f4
	inc 8,XSP                                            ; F9B006  ef 60
	inc 8,XSP                                            ; F9B008  ef 60
	jr .LF9B01D                                          ; F9B00A  68 11
.LF9B00C:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9B00C  f1 40 25 00 01
	lda xbc, (xiz-19)                                    ; F9B011  be ed 31
	push XBC                                             ; F9B014  39
	call T_DisplayListB_RunOne_Stack                     ; F9B015  1d 0c 2e f4
	ld (XIX),0x00                                        ; F9B019  b4 00 00
	pop XIY                                              ; F9B01C  5d
.LF9B01D:
	calr MidiOutProgramChange_PaintMidiCh                                          ; F9B01D  1e 40 02
	calr MidiOutProgramChange_PaintProgram                                          ; F9B020  1e 5d 02
	calr MidiOutProgramChange_PaintBankMsb                                          ; F9B023  1e 7c 02
	calr MidiOutProgramChange_PaintBankLsb                                          ; F9B026  1e 99 02
	calr MidiOutProgramChange_PaintBankSelect                                          ; F9B029  1e b6 02
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9B02C  f1 40 25 00 01
	lda xbc, (Data_F0D061:24)                            ; F9B031  f2 61 d0 f0 31
	push XBC                                             ; F9B036  39
	lda xwa, (DL_F0D04B:24)                              ; F9B037  f2 4b d0 f0 30
	push XWA                                             ; F9B03C  38
	call T_DisplayListB_Run_Stack                        ; F9B03D  1d 04 2e f4
	ld c, (UI_ScreenItem:16)                                   ; F9B041  c1 20 27 23
	ld (0x2721:16), c                                   ; F9B045  f1 21 27 43
	push 0x00                                            ; F9B049  09 00
	push	(UI_ScreenItem:16)                                  ; F9B04B  c1 20 27 04
	calr MidiOutProgramChange_EnableBlinkForItem                                          ; F9B04F  1e 00 06
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F9B052  1d 14 2e f4
	inc 8,XSP                                            ; F9B056  ef 60
	inc 2,XSP                                            ; F9B058  ef 62
	pop XIX                                              ; F9B05A  5c
	unlk XIZ                                             ; F9B05B  ee 0d
	ret                                                  ; F9B05D  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiOutProgramChange -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0x9F, i.e. SCREEN ID 0x7F through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9F -> the screen object at
;          0xF4175C, whose +4 slot is `jp 0xF9B05E`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiOutProgramChange -- the same object's +0 ENTER method carries
;          the label Paint_MidiOutProgramChange, a name an earlier round
;          derived from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F9B05E`.
; ---------------------------------------------------------------------
ScreenLeave_MidiOutProgramChange:
	ret                                                  ; F9B05E  0e
T_F41768_Nop:
	ret                                                  ; F9B05F  0e
; ---------------------------------------------------------------------
; ScreenButton_MidiOutProgramChange -- the BUTTON method of the screen object
;          at PanelScreen_VtableTable entry 0x9F, i.e. SCREEN ID 0x7F through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x9F -> the screen object at
;          0xF4175C, whose +8 slot is `jp 0xF9B060`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiOutProgramChange -- the same object's +0 ENTER method carries
;          the label Paint_MidiOutProgramChange, a name an earlier round
;          derived from the screen's own text.
; Was `sub_F9B060`.
; ---------------------------------------------------------------------
ScreenButton_MidiOutProgramChange:
	link XIZ,0x0000                                      ; F9B060  ee 0c 00 00
	pushw hl                                             ; F9B064  2b
	cpw	(xiz+8), 0x001f                              ; F9B065  9e 08 3f 1f 00
	jrl ugt, .LF9B145                                        ; F9B06A  7b d8 00
	ld L,(XIZ+0x08)                                      ; F9B06D  8e 08 27
	ld C,(XIZ+0x0a)                                      ; F9B070  8e 0a 23
	and C,0x80                                           ; F9B073  cb cc 80
	jr nz, .LF9B07C                                      ; F9B076  6e 04
	ld h, 0x00:opc                                          ; F9B078  26 00
	jr .LF9B07E                                          ; F9B07A  68 02
.LF9B07C:
	ld h, 0x01:opc                                          ; F9B07C  26 01
.LF9B07E:
	ld C,L                                               ; F9B07E  cf 8b
	extz BC                                              ; F9B080  d9 12
	extz XBC                                             ; F9B082  e9 12
	cp BC,0x001f                                         ; F9B084  d9 cf 1f 00
	jrl ugt, .LF9B145                                        ; F9B088  7b ba 00
	sll bc, 0x02                                         ; F9B08B  d9 ee 02
	add XBC,ScreenButtonHandlers_MidiOutProgramChange                             ; F9B08E  e9 c8 98 b0 f9 00
	ld XBC,(XBC)                                         ; F9B094  a1 21
	jp (xbc)                                             ; F9B096  b1 d8
; ---------------------------------------------------------------------
; ScreenButtonHandlers_MidiOutProgramChange -- 32 LE32 branch targets, same reader shape
;
; Read by: `cp BC,0x001F / ... / add XBC,0x00F9B098` at 0xF9B084-0xF9B097.
; ENTRY COUNT 32 from that `cp`.  ★ base + 128 = 0xF9B118 = the minimum entry.
; Selector: the panel BUTTON CODE.  ScreenButton_MidiOutProgramChange (0xF9B060) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x9F (prom_b
;          slot 0xF41764); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld L,(XIZ+0x08)` ... `ld C,L / cp BC,0x001F / sll 2,BC /
;          add XBC,<this> / ld XBC,(XBC) / jp (XBC)`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as JumpTable_F99F96.  This is the last of the five
;          32-entry tables notes/prom_a_jumptables.py finds in the span.
; ---------------------------------------------------------------------
ScreenButtonHandlers_MidiOutProgramChange:
	.long ItemKeys_MidiOutProgramChange                                 ; F9B098  [  0]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B09C  [  1]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0A0  [  2]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0A4  [  3]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0A8  [  4]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0AC  [  5]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0B0  [  6]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0B4  [  7]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0B8  [  8]
	.long LcdKeyRow2_MidiOutProgramChange                                 ; F9B0BC  [  9]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0C0  [ 10]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0C4  [ 11]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0C8  [ 12]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0CC  [ 13]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0D0  [ 14]
	.long ExitKey_MidiOutProgramChange                                 ; F9B0D4  [ 15]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0D8  [ 16]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0DC  [ 17]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0E0  [ 18]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0E4  [ 19]
	.long ItemKeys_MidiOutProgramChange                                 ; F9B0E8  [ 20]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0EC  [ 21]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0F0  [ 22]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0F4  [ 23]
	.long ValueKeys_MidiOutProgramChange                                 ; F9B0F8  [ 24]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B0FC  [ 25]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B100  [ 26]
	.long NumberPadKey_MidiOutProgramChange                                 ; F9B104  [ 27]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B108  [ 28]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B10C  [ 29]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B110  [ 30]
	.long IgnoredKeys_MidiOutProgramChange                                 ; F9B114  [ 31]
; LcdKeyRow2_MidiOutProgramChange -- switch arm for code 0x09 (LCD row 2, "SEND"): MidiOutProgramChange_Send(H)
; Evidence: ScreenButtonHandlers_MidiOutProgramChange entry [9], its only slot; "SEND" is drawn at 0x0BB2 beside the
;   row-2 right arrow (0x0B8F); ends in the reader's epilogue (0xF9B13A).
LcdKeyRow2_MidiOutProgramChange:   ; entry: named by 1 `.long` operand, first at 0xF9B0BC
	push 0x00                                            ; F9B118  09 00
	push H                                               ; F9B11A  ce 04
	calr MidiOutProgramChange_Send                                      ; F9B11C  1e b6 00
	jr .LF9B13A                                          ; F9B11F  68 19
; ExitKey_MidiOutProgramChange -- switch arm for code 0x0F (EXIT): MidiSubmenu_ExitToMidiMenu(H)
; Evidence: ScreenButtonHandlers_MidiOutProgramChange entry [15]; ends in the reader's epilogue (0xF9B13A).
ExitKey_MidiOutProgramChange:   ; entry: named by 1 `.long` operand, first at 0xF9B0D4
	push 0x00                                            ; F9B121  09 00
	push H                                               ; F9B123  ce 04
	calr MidiSubmenu_ExitToMidiMenu                                          ; F9B125  1e bf ef
	jr .LF9B13A                                          ; F9B128  68 10
; ItemKeys_MidiOutProgramChange -- switch arm for codes 0x00-0x03 / 0x11-0x14: MidiOutProgramChange_StepItem(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiOutProgramChange; the screen draws "ITEM" (DL_F0C917).
ItemKeys_MidiOutProgramChange:   ; entry: named by 8 `.long` operands, first at 0xF9B098
	push 0x00                                            ; F9B12A  09 00
	push H                                               ; F9B12C  ce 04
	calr MidiOutProgramChange_StepItem                                      ; F9B12E  1e 18 00
	jr .LF9B13A                                          ; F9B131  68 07
; ValueKeys_MidiOutProgramChange -- switch arm for codes 0x04-0x07 / 0x15-0x18: MidiOutProgramChange_StepValue(H)
; Evidence: those 8 slots of ScreenButtonHandlers_MidiOutProgramChange; "VALUE" (DL_F0C917);
;   Paint_MidiOutProgramChange sets (0x209C)=0x04 / (0x209B)=0x84, so the dial arrives here as code 4.
ValueKeys_MidiOutProgramChange:   ; entry: named by 8 `.long` operands, first at 0xF9B0A8
	push 0x00                                            ; F9B133  09 00
	push H                                               ; F9B135  ce 04
	calr MidiOutProgramChange_StepValue                                      ; F9B137  1e 50 00
.LF9B13A:
	popw bc                                              ; F9B13A  49
	jr .LF9B145                                          ; F9B13B  68 08
; NumberPadKey_MidiOutProgramChange -- switch arm for code 0x1B (the number pad):
;   MidiOutProgramChange_NumberPadEntry
; Evidence: ScreenButtonHandlers_MidiOutProgramChange entry [27], its only slot (0x1B - 0x11 = slot [10] is ignored
;   here); the callee parses the ASCII digit cells 0x2821-0x2823.  No argument is pushed; ends at 0xF9B145.
NumberPadKey_MidiOutProgramChange:   ; entry: named by 1 `.long` operand, first at 0xF9B104
	calr MidiOutProgramChange_NumberPadEntry                                      ; F9B13D  1e fa 00
	jr .LF9B145                                          ; F9B140  68 03
; IgnoredKeys_MidiOutProgramChange -- default arm of ScreenButton_MidiOutProgramChange: MidiScreen_NopKeyHandler
; Evidence: 13 slots ([8], [10]-[14], [16], [25], [26], [28]-[31]) of ScreenButtonHandlers_MidiOutProgramChange.
IgnoredKeys_MidiOutProgramChange:   ; entry: named by 13 `.long` operands, first at 0xF9B0B8
	calr IgnoredKeys_MidiMenu_Nop                                          ; F9B142  1e ed ef
.LF9B145:
	popw hl                                              ; F9B145  4b
	unlk XIZ                                             ; F9B146  ee 0d
	ret                                                  ; F9B148  0e
; MidiOutProgramChange_StepItem -- move the item cursor (0x2720) within 0..3 and re-arm the field blink
; Evidence: StepValue_IncDecClamped(dir = (XIZ+8)==0, max 3, min 0) -> (0x2720), then
;   MidiOutProgramChange_EnableBlinkForItem; rows: "MIDI CH", "PR0G CHANGE", "BANK MSB", "BANK LSB", boxed from
;   DLBoxes_F0D061's four entries.
MidiOutProgramChange_StepItem:
	link XIZ,0x0000                                      ; F9B149  ee 0c 00 00
	pushw hl                                             ; F9B14D  2b
	ld H,(XIZ+0x08)                                      ; F9B14E  8e 08 26
	set	3, (UI_RequestBits:16)                               ; F9B151  f1 75 20 bb
	ld l, (UI_ScreenItem:16)                                   ; F9B155  c1 20 27 27
	cp h, 0x00:i3                                          ; F9B159  ce d8
	jr nz, .LF9B161                                      ; F9B15B  6e 04
	ld h, 0x01:opc                                          ; F9B15D  26 01
	jr .LF9B163                                          ; F9B15F  68 02
.LF9B161:
	ld h, 0x00:opc                                          ; F9B161  26 00
.LF9B163:
	pushw hl                                             ; F9B163  2b
	pushw 0x00                                           ; F9B164  0b 00 00
	pushw 0x03                                           ; F9B167  0b 03 00
	push 0x00                                            ; F9B16A  09 00
	push H                                               ; F9B16C  ce 04
	calr StepValue_IncDecClamped                                          ; F9B16E  1e 8d ef
	ld H,A                                               ; F9B171  c9 8e
	ld (UI_ScreenItem:16), a                                   ; F9B173  f1 20 27 41
	push 0x00                                            ; F9B177  09 00
	push H                                               ; F9B179  ce 04
	calr MidiOutProgramChange_EnableBlinkForItem                                      ; F9B17B  1e d4 04
	set	4, (UI_ScreenFlags:16)                               ; F9B17E  f1 95 20 bc
	inc 8,XSP                                            ; F9B182  ef 60
	inc 2,XSP                                            ; F9B184  ef 62
	popw hl                                              ; F9B186  4b
	unlk XIZ                                             ; F9B187  ee 0d
	ret                                                  ; F9B189  0e
; MidiOutProgramChange_StepValue -- step the field under the cursor: (0x2720) 0..3 -> Edit
;   MidiCh/Program/BankMsb/BankLsb
; Evidence: the `cp BC,0..3 / jr z` chain at 0xF9B19C-0xF9B1AA; sets bit 3 of (0x2075).
MidiOutProgramChange_StepValue:
	link XIZ,0x0000                                      ; F9B18A  ee 0c 00 00
	pushw hl                                             ; F9B18E  2b
	ld H,(XIZ+0x08)                                      ; F9B18F  8e 08 26
	set	3, (UI_RequestBits:16)                               ; F9B192  f1 75 20 bb
	ld bc, (UI_ScreenItem:16)                                 ; F9B196  d1 20 27 21
	extz BC                                              ; F9B19A  d9 12
	cp bc, 0x00:i3                                         ; F9B19C  d9 d8
	jr z, .LF9B1AE                                       ; F9B19E  66 0e
	cp bc, 0x01:i3                                         ; F9B1A0  d9 d9
	jr z, .LF9B1B7                                       ; F9B1A2  66 13
	cp bc, 0x02:i3                                         ; F9B1A4  d9 da
	jr z, .LF9B1C0                                       ; F9B1A6  66 18
	cp bc, 0x03:i3                                         ; F9B1A8  d9 db
	jr z, .LF9B1C9                                       ; F9B1AA  66 1d
	jr .LF9B1D1                                          ; F9B1AC  68 23
.LF9B1AE:
	push 0x00                                            ; F9B1AE  09 00
	push H                                               ; F9B1B0  ce 04
	calr MidiOutProgramChange_EditMidiCh                                      ; F9B1B2  1e e4 01
	jr .LF9B1D0                                          ; F9B1B5  68 19
.LF9B1B7:
	push 0x00                                            ; F9B1B7  09 00
	push H                                               ; F9B1B9  ce 04
	calr MidiOutProgramChange_EditProgram                                      ; F9B1BB  1e 09 02
	jr .LF9B1D0                                          ; F9B1BE  68 10
.LF9B1C0:
	push 0x00                                            ; F9B1C0  09 00
	push H                                               ; F9B1C2  ce 04
	calr MidiOutProgramChange_EditBankMsb                                      ; F9B1C4  1e 28 02
	jr .LF9B1D0                                          ; F9B1C7  68 07
.LF9B1C9:
	push 0x00                                            ; F9B1C9  09 00
	push H                                               ; F9B1CB  ce 04
	calr MidiOutProgramChange_EditBankLsb                                      ; F9B1CD  1e 6b 02
.LF9B1D0:
	popw bc                                              ; F9B1D0  49
.LF9B1D1:
	popw hl                                              ; F9B1D1  4b
	unlk XIZ                                             ; F9B1D2  ee 0d
	ret                                                  ; F9B1D4  0e
; MidiOutProgramChange_Send -- LCD row 2 right key ("SEND"): transmit Bank Select + Program Change from the fields
; Evidence: (XIZ+8)==0 -> T_MIDI_SendBankAndProgram(ch/port (0x2746), program (0x2747), bank (0x274A) or 0xFFFF);
;   then an op-03 box record (template 0xF9B692/0xF9B69A, box 0x10E,0x48-0x132,0x55 around "SEND") by
;   T_DisplayListB_RunOne_Stack, (0x20AB)=2, (0x2741)=1 (Paint_MidiOutProgramChange then erases it), T_Blink_Stop.
MidiOutProgramChange_Send:
	link XIZ,0xffed                                      ; F9B1D5  ee 0c ed ff
	push XIX                                             ; F9B1D9  3c
	ld xbc, (MidiOutPC_Send_InitBox:24)                               ; F9B1DA  e2 92 b6 f9 21
	ld (xiz-8), xbc                                      ; F9B1DF  be f8 61
	ld xbc, (MidiOutPC_Send_InitBox+4:24)                               ; F9B1E2  e2 96 b6 f9 21
	ld (xiz-4), xbc                                      ; F9B1E7  be fc 61
	ldw bc, 0x0b                                         ; F9B1EA  31 0b 00
	lda xiy, (MidiOutPC_Send_InitRecord:24)                               ; F9B1ED  f2 9a b6 f9 35
	lda xix, (xiz-19)                                    ; F9B1F2  be ed 34
	ldir85                                               ; F9B1F5  85 11
	lda xbc, (xiz-8)                                     ; F9B1F7  be f8 31
	ld (xiz-12), xbc                                     ; F9B1FA  be f4 61
	cp (XIZ+0x08),0x00                                   ; F9B1FD  8e 08 3f 00
	jr nz, .LF9B236                                      ; F9B201  6e 33
	pushw	(MidiOutPgm_BankSelect:16)                                  ; F9B203  d1 4a 27 04
	push 0x00                                            ; F9B207  09 00
	push	(MidiOutPgm_Program:16)                                  ; F9B209  c1 47 27 04
	push 0x00                                            ; F9B20D  09 00
	push	(MidiOutPgm_Channel:16)                                  ; F9B20F  c1 46 27 04
	call T_MIDI_SendBankAndProgram                       ; F9B213  1d 2c 07 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9B217  f1 40 25 00 01
	lda xbc, (xiz-19)                                    ; F9B21C  be ed 31
	push XBC                                             ; F9B21F  39
	call T_DisplayListB_RunOne_Stack                     ; F9B220  1d 0c 2e f4
	ld (0x20ab:16), 0x02                                 ; F9B224  f1 ab 20 00 02
	ld (0x2741:16), 0x01                                 ; F9B229  f1 41 27 00 01
	call T_Blink_Stop                                    ; F9B22E  1d 24 2e f4
	inc 8,XSP                                            ; F9B232  ef 60
	inc 2,XSP                                            ; F9B234  ef 62
.LF9B236:
	pop XIX                                              ; F9B236  5c
	unlk XIZ                                             ; F9B237  ee 0d
	ret                                                  ; F9B239  0e
; MidiOutProgramChange_NumberPadEntry -- route a number-pad entry to the field under the cursor
; Evidence: (0x2720)==1 -> MidiOutProgramChange_NumberPadProgram, 2 -> _NumberPadBankMsb, 3 -> _NumberPadBankLsb; 0
;   (MIDI CH) is ignored.  Reached only from NumberPadKey_MidiOutProgramChange.
MidiOutProgramChange_NumberPadEntry:
	ld bc, (UI_ScreenItem:16)                                 ; F9B23A  d1 20 27 21
	extz BC                                              ; F9B23E  d9 12
	cp bc, 0x00:i3                                         ; F9B240  d9 d8
	jr z, .LF9B25F                                       ; F9B242  66 1b
	cp bc, 0x01:i3                                         ; F9B244  d9 d9
	jr z, .LF9B252                                       ; F9B246  66 0a
	cp bc, 0x02:i3                                         ; F9B248  d9 da
	jr z, .LF9B257                                       ; F9B24A  66 0b
	cp bc, 0x03:i3                                         ; F9B24C  d9 db
	jr z, .LF9B25C                                       ; F9B24E  66 0c
	jr .LF9B25F                                          ; F9B250  68 0d
.LF9B252:
	calr MidiOutProgramChange_NumberPadProgram                                      ; F9B252  1e 67 02
	jr .LF9B25F                                          ; F9B255  68 08
.LF9B257:
	calr MidiOutProgramChange_NumberPadBankMsb                                      ; F9B257  1e c1 02
	jr .LF9B25F                                          ; F9B25A  68 03
.LF9B25C:
	calr MidiOutProgramChange_NumberPadBankLsb                                      ; F9B25C  1e 3f 03
.LF9B25F:
	ret                                                  ; F9B25F  0e
; MidiOutProgramChange_PaintMidiCh -- draw the MIDI CH field: (0x2746) -> (0x2740) -> DL_F0CFF6 ("1 - 1".."2 - 16")
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x0836, the row of "MIDI CH     :" (IX 0x0828)
;   in DL_ProgramChangeMidiOutMidi; called by Paint_MidiOutProgramChange and the field's editors.
MidiOutProgramChange_PaintMidiCh:
	ld c, (MidiOutPgm_Channel:16)                                   ; F9B260  c1 46 27 23
	ld (0x2740:16), c                                   ; F9B264  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B268  f1 40 25 00 00
	lda xbc, (DL_F0D005:24)                              ; F9B26D  f2 05 d0 f0 31
	push XBC                                             ; F9B272  39
	lda xwa, (DL_F0CFF6:24)                              ; F9B273  f2 f6 cf f0 30
	push XWA                                             ; F9B278  38
	call T_DisplayListB_Run_Stack                        ; F9B279  1d 04 2e f4
	inc 8,XSP                                            ; F9B27D  ef 60
	ret                                                  ; F9B27F  0e
; MidiOutProgramChange_PaintProgram -- draw the PR0G CHANGE field: (0x2747) + 1 -> (0x2740) -> DL_F0D005 (3-digit
;   decimal)
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x0B06, the row of "PR0G CHANGE" (IX 0x0AF8) in
;   DL_ProgramChangeMidiOutMidi; called by Paint_MidiOutProgramChange and the field's editors.
MidiOutProgramChange_PaintProgram:
	ld c, (MidiOutPgm_Program:16)                                   ; F9B280  c1 47 27 23
	inc 1,C                                              ; F9B284  cb 61
	ld (0x2740:16), c                                   ; F9B286  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B28A  f1 40 25 00 00
	lda xbc, (DL_F0D00F:24)                              ; F9B28F  f2 0f d0 f0 31
	push XBC                                             ; F9B294  39
	lda xwa, (DL_F0D005:24)                              ; F9B295  f2 05 d0 f0 30
	push XWA                                             ; F9B29A  38
	call T_DisplayListB_Run_Stack                        ; F9B29B  1d 04 2e f4
	inc 8,XSP                                            ; F9B29F  ef 60
	ret                                                  ; F9B2A1  0e
; MidiOutProgramChange_PaintBankMsb -- draw the BANK MSB field: (0x2748) -> (0x2740) -> DL_F0D00F (3-digit decimal)
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x0DD6, the row of "BANK MSB    :" (IX 0x0DC8)
;   in DL_ProgramChangeMidiOutMidi; called by Paint_MidiOutProgramChange and the field's editors.
MidiOutProgramChange_PaintBankMsb:
	ld c, (MidiOutPgm_BankMsb:16)                                   ; F9B2A2  c1 48 27 23
	ld (0x2740:16), c                                   ; F9B2A6  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B2AA  f1 40 25 00 00
	lda xbc, (DL_F0D019:24)                              ; F9B2AF  f2 19 d0 f0 31
	push XBC                                             ; F9B2B4  39
	lda xwa, (DL_F0D00F:24)                              ; F9B2B5  f2 0f d0 f0 30
	push XWA                                             ; F9B2BA  38
	call T_DisplayListB_Run_Stack                        ; F9B2BB  1d 04 2e f4
	inc 8,XSP                                            ; F9B2BF  ef 60
	ret                                                  ; F9B2C1  0e
; MidiOutProgramChange_PaintBankLsb -- draw the BANK LSB field: (0x2749) -> (0x2740) -> DL_F0D019 (3-digit decimal)
; Evidence: the interpreter-B record reads (0x2740) and draws at IX 0x10A6, the row of "BANK LSB    ;" (IX 0x1098)
;   in DL_ProgramChangeMidiOutMidi; called by Paint_MidiOutProgramChange and the field's editors.
MidiOutProgramChange_PaintBankLsb:
	ld c, (MidiOutPgm_BankLsb:16)                                   ; F9B2C2  c1 49 27 23
	ld (0x2740:16), c                                   ; F9B2C6  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B2CA  f1 40 25 00 00
	lda xbc, (MidiOutProgramChange_PaintBankLsb_DL:24)                              ; F9B2CF  f2 23 d0 f0 31
	push XBC                                             ; F9B2D4  39
	lda xwa, (DL_F0D019:24)                              ; F9B2D5  f2 19 d0 f0 30
	push XWA                                             ; F9B2DA  38
	call T_DisplayListB_Run_Stack                        ; F9B2DB  1d 04 2e f4
	inc 8,XSP                                            ; F9B2DF  ef 60
	ret                                                  ; F9B2E1  0e
; MidiOutProgramChange_PaintBankSelect -- draw the "(BANK SEL#= )" readout of (0x274A), or the bank-OFF state
; Evidence: (0x274A)==0xFFFF -> site 0xF9B30B 0xF0D02D-0xF0D036 (blanks at 0x1374) and site 0xF9B31B
;   0xF0D036-0xF0D04B (DL_OffOff: "---" over BANK MSB, "OFF" over BANK LSB and BANK SEL#); otherwise five decimal
;   digits (`divs BC,10`, `add L,0x30`) in a frame copy of the record at 0xF9B6A5, drawn at IX 0x1374 by
;   T_DisplayListB_RunOne_Stack. Round 7 refused a caption name (its first list draws `---`); this names the field.
MidiOutProgramChange_PaintBankSelect:
	link XIZ,0xffe9                                      ; F9B2E2  ee 0c e9 ff
	pushw hl                                             ; F9B2E6  2b
	pushw de                                             ; F9B2E7  2a
	push XIX                                             ; F9B2E8  3c
	lda xix, (xiz-6)                                     ; F9B2E9  be fa 34
	push XIX                                             ; F9B2EC  3c
	ldw bc, 0x0f                                         ; F9B2ED  31 0f 00
	lda xiy, (MidiOutPC_BankSelect_InitRecord:24)                               ; F9B2F0  f2 a5 b6 f9 35
	lda xix, (xiz-21)                                    ; F9B2F5  be eb 34
	ldir85                                               ; F9B2F8  85 11
	pop XIX                                              ; F9B2FA  5c
	ld (xiz-14), xix                                     ; F9B2FB  be f2 64
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B2FE  f1 40 25 00 00
	cpw	(MidiOutPgm_BankSelect:16), 0xffff                          ; F9B303  d1 4a 27 3f ff ff
	jr nz, .LF9B331                                      ; F9B309  6e 26
	lda xbc, (DL_OffOff:24)                              ; F9B30B  f2 36 d0 f0 31
	push XBC                                             ; F9B310  39
	lda xwa, (MidiOutProgramChange_PaintBankSelect_DL:24)                              ; F9B311  f2 2d d0 f0 30
	push XWA                                             ; F9B316  38
	call T_DisplayList_Run_Stack                         ; F9B317  1d 00 2e f4
	lda xbc, (DL_F0D04B:24)                              ; F9B31B  f2 4b d0 f0 31
	push XBC                                             ; F9B320  39
	lda xwa, (DL_OffOff:24)                              ; F9B321  f2 36 d0 f0 30
	push XWA                                             ; F9B326  38
	call T_DisplayList_Run_Stack                         ; F9B327  1d 00 2e f4
	inc 8,XSP                                            ; F9B32B  ef 60
	inc 8,XSP                                            ; F9B32D  ef 60
	jr .LF9B393                                          ; F9B32F  68 62
.LF9B331:
	ld h, 0x00:opc                                          ; F9B331  26 00
.LF9B333:
	ld C,H                                               ; F9B333  ce 8b
	extz BC                                              ; F9B335  d9 12
	extz XBC                                             ; F9B337  e9 12
	add XBC,XIX                                          ; F9B339  ec 81
	ld (XBC),0x20                                        ; F9B33B  b1 00 20
	inc 1,H                                              ; F9B33E  ce 61
	cp h, 0x05:i3                                          ; F9B340  ce dd
	jr c, .LF9B333                                       ; F9B342  67 ef
	ld (XIX+0x04),0x30                                   ; F9B344  bc 04 00 30
	ld de, (MidiOutPgm_BankSelect:16)                                 ; F9B348  d1 4a 27 22
	ld h, 0x00:opc                                          ; F9B34C  26 00
.LF9B34E:
	cp de, 0x00:i3                                         ; F9B34E  da d8
	jr z, .LF9B384                                       ; F9B350  66 32
	ld BC,DE                                             ; F9B352  da 89
	exts XBC                                             ; F9B354  e9 13
	divs BC,0x000a                                       ; F9B356  d9 0b 0a 00
	.byte 0xd7, 0xe6, 0xb9                               ; F9B35A  d7 e6 b9   ex BC,QBC
	ld (xiz-23), bc                                      ; F9B35D  be e9 51
	ld L,C                                               ; F9B360  cb 8f
	add L,0x30                                           ; F9B362  cf c8 30
	ld C,H                                               ; F9B365  ce 8b
	extz BC                                              ; F9B367  d9 12
	extz XBC                                             ; F9B369  e9 12
	sub XWA,XWA                                          ; F9B36B  e8 a0
	inc 4,XWA                                            ; F9B36D  e8 64
	sub XWA,XBC                                          ; F9B36F  e9 a0
	add XWA,XIX                                          ; F9B371  ec 80
	ld (XWA),L                                           ; F9B373  b0 47
	ld bc, (xiz-23)                                      ; F9B375  9e e9 21
	sub DE,BC                                            ; F9B378  d9 a2
	ld BC,DE                                             ; F9B37A  da 89
	exts XBC                                             ; F9B37C  e9 13
	divs BC,0x000a                                       ; F9B37E  d9 0b 0a 00
	ld DE,BC                                             ; F9B382  d9 8a
.LF9B384:
	inc 1,H                                              ; F9B384  ce 61
	cp h, 0x05:i3                                          ; F9B386  ce dd
	jr c, .LF9B34E                                       ; F9B388  67 c4
	lda xbc, (xiz-21)                                    ; F9B38A  be eb 31
	push XBC                                             ; F9B38D  39
	call T_DisplayListB_RunOne_Stack                     ; F9B38E  1d 0c 2e f4
	pop XIY                                              ; F9B392  5d
.LF9B393:
	pop XIX                                              ; F9B393  5c
	popw de                                              ; F9B394  4a
	popw hl                                              ; F9B395  4b
	unlk XIZ                                             ; F9B396  ee 0d
	ret                                                  ; F9B398  0e
; MidiOutProgramChange_EditMidiCh -- step MIDI CH (0x2746) within 0..31 and repaint it if it changed
; Evidence: StepValue_IncDecClamped(dir=(XIZ+8), max 0x1F, min 0) -> (0x2746), then
;   MidiOutProgramChange_PaintMidiCh; bits 0-3 are the channel and bit 4 the port in MIDI_SendBankAndProgram's first
;   argument ("1 - n" / "2 - n").
MidiOutProgramChange_EditMidiCh:
	link XIZ,0x0000                                      ; F9B399  ee 0c 00 00
	pushw hl                                             ; F9B39D  2b
	ld h, (MidiOutPgm_Channel:16)                                   ; F9B39E  c1 46 27 26
	push 0x00                                            ; F9B3A2  09 00
	push H                                               ; F9B3A4  ce 04
	pushw 0x00                                           ; F9B3A6  0b 00 00
	pushw 0x1f                                           ; F9B3A9  0b 1f 00
	push 0x00                                            ; F9B3AC  09 00
	push	(xiz+8)                                      ; F9B3AE  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9B3B1  1e 4a ed
	ld L,A                                               ; F9B3B4  c9 8f
	ld (MidiOutPgm_Channel:16), a                                   ; F9B3B6  f1 46 27 41
	inc 8,XSP                                            ; F9B3BA  ef 60
	cp H,L                                               ; F9B3BC  cf f6
	jr z, .LF9B3C3                                       ; F9B3BE  66 03
	calr MidiOutProgramChange_PaintMidiCh                                      ; F9B3C0  1e 9d fe
.LF9B3C3:
	popw hl                                              ; F9B3C3  4b
	unlk XIZ                                             ; F9B3C4  ee 0d
	ret                                                  ; F9B3C6  0e
; MidiOutProgramChange_EditProgram -- step the program number (0x2747) within 0..127 and repaint
; Evidence: StepValue_IncDecClamped(dir=(XIZ+8), max 0x7F, min 0) -> (0x2747), T_Blink_Stop,
;   MidiOutProgramChange_PaintProgram.
MidiOutProgramChange_EditProgram:
	link XIZ,0x0000                                      ; F9B3C7  ee 0c 00 00
	push 0x00                                            ; F9B3CB  09 00
	push	(MidiOutPgm_Program:16)                                  ; F9B3CD  c1 47 27 04
	pushw 0x00                                           ; F9B3D1  0b 00 00
	pushw 0x7f                                           ; F9B3D4  0b 7f 00
	push 0x00                                            ; F9B3D7  09 00
	push	(xiz+8)                                      ; F9B3D9  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9B3DC  1e 1f ed
	ld (MidiOutPgm_Program:16), a                                   ; F9B3DF  f1 47 27 41
	call T_Blink_Stop                                    ; F9B3E3  1d 24 2e f4
	calr MidiOutProgramChange_PaintProgram                                      ; F9B3E7  1e 96 fe
	inc 8,XSP                                            ; F9B3EA  ef 60
	unlk XIZ                                             ; F9B3EC  ee 0d
	ret                                                  ; F9B3EE  0e
; MidiOutProgramChange_EditBankMsb -- step BANK MSB (0x2748) within 0..127 and rebuild the bank number; inert while
;   bank is OFF
; Evidence: returns at once when (0x274A)==0xFFFF; else StepValue_IncDecClamped -> (0x2748), (0x274A) = MSB<<7 +
;   (0x2749), T_Blink_Stop, MidiOutProgramChange_PaintBankMsb and _PaintBankSelect.
MidiOutProgramChange_EditBankMsb:
	link XIZ,0x0000                                      ; F9B3EF  ee 0c 00 00
	pushw hl                                             ; F9B3F3  2b
	pushw de                                             ; F9B3F4  2a
	cpw	(MidiOutPgm_BankSelect:16), 0xffff                          ; F9B3F5  d1 4a 27 3f ff ff
	jr z, .LF9B436                                       ; F9B3FB  66 39
	push 0x00                                            ; F9B3FD  09 00
	push	(MidiOutPgm_BankMsb:16)                                  ; F9B3FF  c1 48 27 04
	pushw 0x00                                           ; F9B403  0b 00 00
	pushw 0x7f                                           ; F9B406  0b 7f 00
	push 0x00                                            ; F9B409  09 00
	push	(xiz+8)                                      ; F9B40B  8e 08 04
	calr StepValue_IncDecClamped                                          ; F9B40E  1e ed ec
	ld H,A                                               ; F9B411  c9 8e
	ld (MidiOutPgm_BankMsb:16), a                                   ; F9B413  f1 48 27 41
	ld de, (MidiOutPgm_BankLsb:16)                                 ; F9B417  d1 49 27 22
	extz DE                                              ; F9B41B  da 12
	ld C,H                                               ; F9B41D  ce 8b
	extz BC                                              ; F9B41F  d9 12
	sll bc, 0x07                                         ; F9B421  d9 ee 07
	add BC,DE                                            ; F9B424  da 81
	ld (MidiOutPgm_BankSelect:16), bc                                  ; F9B426  f1 4a 27 51
	call T_Blink_Stop                                    ; F9B42A  1d 24 2e f4
	calr MidiOutProgramChange_PaintBankMsb                                      ; F9B42E  1e 71 fe
	calr MidiOutProgramChange_PaintBankSelect                                      ; F9B431  1e ae fe
	inc 8,XSP                                            ; F9B434  ef 60
.LF9B436:
	popw de                                              ; F9B436  4a
	popw hl                                              ; F9B437  4b
	unlk XIZ                                             ; F9B438  ee 0d
	ret                                                  ; F9B43A  0e
; MidiOutProgramChange_EditBankLsb -- step BANK LSB (0x2749); below 0 turns the bank OFF, stepping up from OFF turns
;   it on
; Evidence: LSB==0 with dir 1 -> (0x274A)=0xFFFF; OFF with dir 0 -> no step, bank rebuilt at LSB 0; otherwise
;   StepValue_IncDecClamped(max 0x7F) and (0x274A) = (0x2748)<<7 + LSB.  Then T_Blink_Stop and repaint MSB, LSB,
;   BANK SEL#.
MidiOutProgramChange_EditBankLsb:
	link XIZ,0x0000                                      ; F9B43B  ee 0c 00 00
	pushw hl                                             ; F9B43F  2b
	push XIX                                             ; F9B440  3c
	lda xix, (MidiOutPgm_BankLsb:16)                                ; F9B441  f1 49 27 34
	ld L,(XIZ+0x08)                                      ; F9B445  8e 08 27
	ld H,(XIX)                                           ; F9B448  84 26
	ld C,(XIX)                                           ; F9B44A  84 23
	cp c, 0x00:i3                                          ; F9B44C  cb d8
	jr nz, .LF9B45C                                      ; F9B44E  6e 0c
	cp l, 0x01:i3                                          ; F9B450  cf d9
	jr nz, .LF9B45C                                      ; F9B452  6e 08
	ldw (MidiOutPgm_BankSelect:16), 0xffff                              ; F9B454  f1 4a 27 02 ff ff
	jr .LF9B48F                                          ; F9B45A  68 33
.LF9B45C:
	cpw	(MidiOutPgm_BankSelect:16), 0xffff                          ; F9B45C  d1 4a 27 3f ff ff
	jr nz, .LF9B468                                      ; F9B462  6e 04
	cp l, 0x00:i3                                          ; F9B464  cf d8
	jr z, .LF9B47A                                       ; F9B466  66 12
.LF9B468:
	push 0x00                                            ; F9B468  09 00
	push H                                               ; F9B46A  ce 04
	pushw 0x00                                           ; F9B46C  0b 00 00
	pushw 0x7f                                           ; F9B46F  0b 7f 00
	pushw hl                                             ; F9B472  2b
	calr StepValue_IncDecClamped                                          ; F9B473  1e 88 ec
	ld (XIX),A                                           ; F9B476  b4 41
	inc 8,XSP                                            ; F9B478  ef 60
.LF9B47A:
	ld C,(XIX)                                           ; F9B47A  84 23
	extz BC                                              ; F9B47C  d9 12
	ld HL,BC                                             ; F9B47E  d9 8b
	ld wa, (MidiOutPgm_BankMsb:16)                                 ; F9B480  d1 48 27 20
	extz WA                                              ; F9B484  d8 12
	sll wa, 0x07                                         ; F9B486  d8 ee 07
	add BC,WA                                            ; F9B489  d8 81
	ld (MidiOutPgm_BankSelect:16), bc                                  ; F9B48B  f1 4a 27 51
.LF9B48F:
	call T_Blink_Stop                                    ; F9B48F  1d 24 2e f4
	calr MidiOutProgramChange_PaintBankMsb                                      ; F9B493  1e 0c fe
	calr MidiOutProgramChange_PaintBankLsb                                      ; F9B496  1e 29 fe
	calr MidiOutProgramChange_PaintBankSelect                                      ; F9B499  1e 46 fe
	pop XIX                                              ; F9B49C  5c
	popw hl                                              ; F9B49D  4b
	unlk XIZ                                             ; F9B49E  ee 0d
	ret                                                  ; F9B4A0  0e
; MidiOutProgramChange_ResetState -- channel, program, MSB, LSB = 0 and the bank number = 0xFFFF (OFF)
; Evidence: stores to (0x2746)..(0x2749) and `ldw (0x274A),0xFFFF`, the fields MidiOutProgramChange_Send transmits;
;   called only by sub_F99818, the target of the module-head `jp` at 0xF99800 that prom_b's `.long 0x00F99800`
;   (0xF4176C) names.
MidiOutProgramChange_ResetState:
	ld (MidiOutPgm_Channel:16), 0x00                                 ; F9B4A1  f1 46 27 00 00
	ld (MidiOutPgm_Program:16), 0x00                                 ; F9B4A6  f1 47 27 00 00
	ld (MidiOutPgm_BankMsb:16), 0x00                                 ; F9B4AB  f1 48 27 00 00
	ld (MidiOutPgm_BankLsb:16), 0x00                                 ; F9B4B0  f1 49 27 00 00
	ldw (MidiOutPgm_BankSelect:16), 0xffff                              ; F9B4B5  f1 4a 27 02 ff ff
	ret                                                  ; F9B4BB  0e
; MidiOutProgramChange_NumberPadProgram -- take a number-pad entry into PROG CHANGE
; Evidence: when (0x2267)&0x0F == 0x0F: (0x2826)=3, T_AsciiDigits3_ToValue, and if Word_IsOutOfRange says in range:
;   1..128, stored as value-1 in (0x2747). Then T_Blink_Command(DL_F0D005) blinks the field; a blank last digit cell
;   ((0x2823)==' ') only stops the blink.
MidiOutProgramChange_NumberPadProgram:
	pushw hl                                             ; F9B4BC  2b
	ld c, (0x2823:16)                                   ; F9B4BD  c1 23 28 23
	cp C,0x20                                            ; F9B4C1  cb cf 20
	jr nz, .LF9B4CC                                      ; F9B4C4  6e 06
	call T_Blink_Stop                                    ; F9B4C6  1d 24 2e f4
	jr .LF9B519                                          ; F9B4CA  68 4d
.LF9B4CC:
	ld c, (0x2267:16)                                   ; F9B4CC  c1 67 22 23
	and C,0x0f                                           ; F9B4D0  cb cc 0f
	cp C,0x0f                                            ; F9B4D3  cb cf 0f
	jr nz, .LF9B4FF                                      ; F9B4D6  6e 27
	ld (0x2826:16), 0x03                                 ; F9B4D8  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F9B4DD  1d f0 32 f4
	ld HL,WA                                             ; F9B4E1  d8 8b
	pushw 0x01                                           ; F9B4E3  0b 01 00
	pushw 0x80                                           ; F9B4E6  0b 80 00
	pushw wa                                             ; F9B4E9  28
	calr Word_IsOutOfRange                                      ; F9B4EA  1e 4b 01
	inc 6,XSP                                            ; F9B4ED  ef 66
	cp a, 0x00:i3                                          ; F9B4EF  c9 d8
	jr nz, .LF9B4FF                                      ; F9B4F1  6e 0c
	ld C,L                                               ; F9B4F3  cf 8b
	dec 1,C                                              ; F9B4F5  cb 69
	ld (MidiOutPgm_Program:16), c                                   ; F9B4F7  f1 47 27 43
	call T_Blink_Stop                                    ; F9B4FB  1d 24 2e f4
.LF9B4FF:
	ld c, (MidiOutPgm_Program:16)                                   ; F9B4FF  c1 47 27 23
	inc 1,C                                              ; F9B503  cb 61
	ld (0x2740:16), c                                   ; F9B505  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B509  f1 40 25 00 00
	lda xbc, (DL_F0D005:24)                              ; F9B50E  f2 05 d0 f0 31
	push XBC                                             ; F9B513  39
	call T_Blink_Command                                 ; F9B514  1d 20 2e f4
	pop XIY                                              ; F9B518  5d
.LF9B519:
	popw hl                                              ; F9B519  4b
	ret                                                  ; F9B51A  0e
; MidiOutProgramChange_NumberPadBankMsb -- take a number-pad entry into BANK MSB
; Evidence: when (0x2267)&0x0F == 0x0F: (0x2826)=3, T_AsciiDigits3_ToValue, and if Word_IsOutOfRange says in range:
;   0..127 into (0x2748), only while the bank is not OFF; (0x274A) rebuilt and BANK SEL# repainted. Then
;   T_Blink_Command(DL_F0D00F) blinks the field; a blank last digit cell ((0x2823)==' ') only stops the blink.
MidiOutProgramChange_NumberPadBankMsb:
	pushw hl                                             ; F9B51B  2b
	pushw de                                             ; F9B51C  2a
	push XIX                                             ; F9B51D  3c
	lda xix, (MidiOutPgm_BankMsb:16)                                ; F9B51E  f1 48 27 34
	ld c, (0x2823:16)                                   ; F9B522  c1 23 28 23
	cp C,0x20                                            ; F9B526  cb cf 20
	jr nz, .LF9B531                                      ; F9B529  6e 06
	call T_Blink_Stop                                    ; F9B52B  1d 24 2e f4
	jr .LF9B59A                                          ; F9B52F  68 69
.LF9B531:
	cpw	(MidiOutPgm_BankSelect:16), 0xffff                          ; F9B531  d1 4a 27 3f ff ff
	jr z, .LF9B584                                       ; F9B537  66 4b
	ld c, (0x2267:16)                                   ; F9B539  c1 67 22 23
	and C,0x0f                                           ; F9B53D  cb cc 0f
	cp C,0x0f                                            ; F9B540  cb cf 0f
	jr nz, .LF9B584                                      ; F9B543  6e 3f
	ld (0x2826:16), 0x03                                 ; F9B545  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F9B54A  1d f0 32 f4
	ld DE,WA                                             ; F9B54E  d8 8a
	pushw 0x00                                           ; F9B550  0b 00 00
	pushw 0x7f                                           ; F9B553  0b 7f 00
	pushw wa                                             ; F9B556  28
	calr Word_IsOutOfRange                                      ; F9B557  1e de 00
	inc 6,XSP                                            ; F9B55A  ef 66
	cp a, 0x00:i3                                          ; F9B55C  c9 d8
	jr nz, .LF9B584                                      ; F9B55E  6e 24
	ld H,E                                               ; F9B560  cd 8e
	ld C,(XIX)                                           ; F9B562  84 23
	cp H,C                                               ; F9B564  cb f6
	jr z, .LF9B580                                       ; F9B566  66 18
	ld (XIX),H                                           ; F9B568  b4 46
	ld de, (MidiOutPgm_BankLsb:16)                                 ; F9B56A  d1 49 27 22
	extz DE                                              ; F9B56E  da 12
	ld C,H                                               ; F9B570  ce 8b
	extz BC                                              ; F9B572  d9 12
	sll bc, 0x07                                         ; F9B574  d9 ee 07
	add BC,DE                                            ; F9B577  da 81
	ld (MidiOutPgm_BankSelect:16), bc                                  ; F9B579  f1 4a 27 51
	calr MidiOutProgramChange_PaintBankSelect                                      ; F9B57D  1e 62 fd
.LF9B580:
	call T_Blink_Stop                                    ; F9B580  1d 24 2e f4
.LF9B584:
	ld C,(XIX)                                           ; F9B584  84 23
	ld (0x2740:16), c                                   ; F9B586  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B58A  f1 40 25 00 00
	lda xbc, (DL_F0D00F:24)                              ; F9B58F  f2 0f d0 f0 31
	push XBC                                             ; F9B594  39
	call T_Blink_Command                                 ; F9B595  1d 20 2e f4
	pop XIY                                              ; F9B599  5d
.LF9B59A:
	pop XIX                                              ; F9B59A  5c
	popw de                                              ; F9B59B  4a
	popw hl                                              ; F9B59C  4b
	ret                                                  ; F9B59D  0e
; MidiOutProgramChange_NumberPadBankLsb -- take a number-pad entry into BANK LSB
; Evidence: when (0x2267)&0x0F == 0x0F: (0x2826)=3, T_AsciiDigits3_ToValue, and if Word_IsOutOfRange says in range:
;   0..127 into (0x2749); (0x274A) = (0x2748)<<7 + LSB (this turns an OFF bank on); MSB and BANK SEL# repainted.
;   Then T_Blink_Command(DL_F0D019) blinks the field; a blank last digit cell ((0x2823)==' ') only stops the blink.
MidiOutProgramChange_NumberPadBankLsb:
	link XIZ,0xfffc                                      ; F9B59E  ee 0c fc ff
	pushw hl                                             ; F9B5A2  2b
	pushw de                                             ; F9B5A3  2a
	push XIX                                             ; F9B5A4  3c
	lda xix, (MidiOutPgm_BankLsb:16)                                ; F9B5A5  f1 49 27 34
	ld c, (0x2823:16)                                   ; F9B5A9  c1 23 28 23
	cp C,0x20                                            ; F9B5AD  cb cf 20
	jr nz, .LF9B5B9                                      ; F9B5B0  6e 07
	call T_Blink_Stop                                    ; F9B5B2  1d 24 2e f4
	jrl .LF9B632                                         ; F9B5B6  78 79 00
.LF9B5B9:
	ld c, (0x2267:16)                                   ; F9B5B9  c1 67 22 23
	and C,0x0f                                           ; F9B5BD  cb cc 0f
	cp C,0x0f                                            ; F9B5C0  cb cf 0f
	jr nz, .LF9B61C                                      ; F9B5C3  6e 57
	ld (0x2826:16), 0x03                                 ; F9B5C5  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F9B5CA  1d f0 32 f4
	ld HL,WA                                             ; F9B5CE  d8 8b
	pushw 0x00                                           ; F9B5D0  0b 00 00
	pushw 0x7f                                           ; F9B5D3  0b 7f 00
	pushw wa                                             ; F9B5D6  28
	calr Word_IsOutOfRange                                      ; F9B5D7  1e 5e 00
	inc 6,XSP                                            ; F9B5DA  ef 66
	cp a, 0x00:i3                                          ; F9B5DC  c9 d8
	jr nz, .LF9B61C                                      ; F9B5DE  6e 3c
	ld C,(XIX)                                           ; F9B5E0  84 23
	ld (xiz-2), c                                        ; F9B5E2  be fe 43
	ld de, (MidiOutPgm_BankSelect:16)                                 ; F9B5E5  d1 4a 27 22
	ld (xiz-4), l                                        ; F9B5E9  be fc 47
	ld a, (xiz-4)                                        ; F9B5EC  8e fc 21
	ld (XIX),A                                           ; F9B5EF  b4 41
	ld hl, (xiz-4)                                       ; F9B5F1  9e fc 23
	extz HL                                              ; F9B5F4  db 12
	ld bc, (MidiOutPgm_BankMsb:16)                                 ; F9B5F6  d1 48 27 21
	extz BC                                              ; F9B5FA  d9 12
	sll bc, 0x07                                         ; F9B5FC  d9 ee 07
	add BC,HL                                            ; F9B5FF  db 81
	ld (MidiOutPgm_BankSelect:16), bc                                  ; F9B601  f1 4a 27 51
	call T_Blink_Stop                                    ; F9B605  1d 24 2e f4
	ld C,(XIX)                                           ; F9B609  84 23
	cp (xiz-2), c                                        ; F9B60B  8e fe fb
	jr nz, .LF9B616                                      ; F9B60E  6e 06
	cp	de, (MidiOutPgm_BankSelect:16)                              ; F9B610  d1 4a 27 f2
	jr z, .LF9B61C                                       ; F9B614  66 06
.LF9B616:
	calr MidiOutProgramChange_PaintBankMsb                                      ; F9B616  1e 89 fc
	calr MidiOutProgramChange_PaintBankSelect                                      ; F9B619  1e c6 fc
.LF9B61C:
	ld C,(XIX)                                           ; F9B61C  84 23
	ld (0x2740:16), c                                   ; F9B61E  f1 40 27 43
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9B622  f1 40 25 00 00
	lda xbc, (DL_F0D019:24)                              ; F9B627  f2 19 d0 f0 31
	push XBC                                             ; F9B62C  39
	call T_Blink_Command                                 ; F9B62D  1d 20 2e f4
	pop XIY                                              ; F9B631  5d
.LF9B632:
	pop XIX                                              ; F9B632  5c
	popw de                                              ; F9B633  4a
	popw hl                                              ; F9B634  4b
	unlk XIZ                                             ; F9B635  ee 0d
	ret                                                  ; F9B637  0e
; Word_IsOutOfRange -- A = 1 if a word is below min or above max, else 0
; Evidence: `cp BC,(XIZ+0x0c) / jr c` and `cp BC,(XIZ+0x0a) / jr ugt` -> A=1; `sub A,A` otherwise.
; In: (XIZ+8) value, (XIZ+0x0A) max, (XIZ+0x0C) min (callers push min, max, value).
Word_IsOutOfRange:
	link XIZ,0x0000                                      ; F9B638  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; F9B63C  9e 08 21
	cp BC,(XIZ+0x0c)                                     ; F9B63F  9e 0c f1
	jr c, .LF9B64D                                       ; F9B642  67 09
	cp BC,(XIZ+0x0a)                                     ; F9B644  9e 0a f1
	jr ugt, .LF9B64D                                     ; F9B647  6b 04
	sub A,A                                              ; F9B649  c9 a1
	jr .LF9B64F                                          ; F9B64B  68 02
.LF9B64D:
	ld a, 0x01:opc                                          ; F9B64D  21 01
.LF9B64F:
	unlk XIZ                                             ; F9B64F  ee 0d
	ret                                                  ; F9B651  0e
; MidiOutProgramChange_EnableBlinkForItem -- stop the field blink, then allow blinking only for the numeric rows 1-3
; Evidence: T_Blink_Stop, then T_Blink_SetEnable(1) for argument 1, 2 or 3 (PROG CHANGE, BANK MSB, BANK LSB -- the
;   number-pad fields), else 0.  Called by Paint_MidiOutProgramChange and _StepItem with (0x2720). ⚠ It ends at
;   0xF9B67E; 0xF9B67F-0xF9B6EA are DL-B record templates framed as code, not part of it.
MidiOutProgramChange_EnableBlinkForItem:
	link XIZ,0x0000                                      ; F9B652  ee 0c 00 00
	pushw hl                                             ; F9B656  2b
	ld H,(XIZ+0x08)                                      ; F9B657  8e 08 26
	cp h, 0x01:i3                                          ; F9B65A  ce d9
	jr z, .LF9B666                                       ; F9B65C  66 08
	cp h, 0x02:i3                                          ; F9B65E  ce da
	jr z, .LF9B666                                       ; F9B660  66 04
	cp h, 0x03:i3                                          ; F9B662  ce db
	jr nz, .LF9B66F                                      ; F9B664  6e 09
.LF9B666:
	call T_Blink_Stop                                    ; F9B666  1d 24 2e f4
	pushw 0x01                                           ; F9B66A  0b 01 00
	jr .LF9B676                                          ; F9B66D  68 07
.LF9B66F:
	call T_Blink_Stop                                    ; F9B66F  1d 24 2e f4
	pushw 0x00                                           ; F9B673  0b 00 00
.LF9B676:
	call T_Blink_SetEnable                               ; F9B676  1d 28 2e f4
	popw bc                                              ; F9B67A  49
	popw hl                                              ; F9B67B  4b
	unlk XIZ                                             ; F9B67C  ee 0d
	ret                                                  ; F9B67E  0e
; ---------------------------------------------------------------------
; 0xF9B67F-0xF9B6B3 -- initial values the MIDI OUT program-change routines above copy into their stack frames,
; the C compiler's initializers for local records; then an older copy of the same 53 bytes.  Was decoded as code.
; The box is (270,72)-(306,85), the field MidiOutProgramChange_Send outlines around "SEND"; each routine reads it
; as two longs, `ld xbc,(box)` and `ld xbc,(box+4)`.  The records are display-list interpreter-B records
; (wsa1/notes/FINDINGS-ui-display-list-interpreter-b.md): op 08 and op 03 are 11 bytes with a long at +7, op 02
; is 15 bytes with the draw position IX at +0x0D.  Each routine copies its record into its frame with `ldir`.
; ---------------------------------------------------------------------
MidiOutPC_Paint_InitBox:		.short	270, 72, 306, 85	; F9B67F
MidiOutPC_Paint_InitRecord:		.byte	0x08, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00	; F9B687  op 08
MidiOutPC_Send_InitBox:			.short	270, 72, 306, 85	; F9B692
MidiOutPC_Send_InitRecord:		.byte	0x03, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00	; F9B69A  op 03
MidiOutPC_BankSelect_InitRecord:	.byte	0x02, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00	; F9B6A5  op 02
					.short	0x1374	; F9B6B2  IX
	.byte	0x0e	; F9B6B4  fill
; An older copy of the 53 bytes above, which nothing references.  Only the op-02 record's IX differs:
; 0x1734 here, 0x1374 in the live record.
	.byte	0x0e, 0x01, 0x48, 0x00, 0x32, 0x01, 0x55, 0x00, 0x08, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00	; F9B6B5
	.byte	0x0e, 0x01, 0x48, 0x00, 0x32, 0x01, 0x55, 0x00, 0x03, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00	; F9B6C8
	.byte	0x02, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00	; F9B6DB
	.short	0x1734	; F9B6E8
	.byte	0x0e	; F9B6EA  first byte of the padding below

; 0xF9B6EB-0xF9BFFF -- 2325 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 2325, 1, 0x0E
