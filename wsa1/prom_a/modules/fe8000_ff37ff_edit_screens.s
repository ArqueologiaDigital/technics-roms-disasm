
; ==============================================================================
; 0xFE8000-0xFEB32F -- CPU 1's SCREEN AND DISPATCH module
; ==============================================================================
;
; The last .incbin of prom_a's 0xFE0000 half, and the neighbour of the
; block-device layer at 0xFE0000-0xFE54B5 and the floppy driver at
; 0xFE54B6-0xFE68F2.  It is built like the 0xFEF746 screen module: routines that
; load a DISPLAY LIST into XIY and a data table into XIX and call the
; interpreter veneer at 0xF417F0/0xF417F4, plus six POINTER DISPATCH tables read
; with one five-instruction idiom.
;
; WHAT IS ESTABLISHED
;   * 35 display lists, every one named by BOTH ends in immediates, and every
;     one passing the record-length walk -- 35/35, checked by
;     `python3 notes/gen_prom_a_fe8000_module.py --check`.
;   * 8 data tables, each named by exactly one `ld XIX,imm32`; four of the six
;     pointer tables have their entry count from the READER'S OWN BOUND.
;   * The module is reached from prom_b: 27 slots of the thunk directory run
;     T_F402A4-T_F4030C name targets from 0xFE8000 up to 0xFE9B8D
;     (`python3 notes/prom_a_module_frontier.py`).
;
; ⚠ WHAT IS NOT
;   Almost every routine here is `sub_XXXXXX`.  This pass CONVERTED the module
;   and framed its data; it did not work out what the screens are.  Names are
;   only on the objects whose reader or whose literal text says what they are.
; ==============================================================================

; EditScreen_Tick_Call: calls EditScreen_Tick and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
EditScreen_Tick_Call:
	call EditScreen_Tick                                      ; FE8000  1d d7 82 fe
	ret                                                  ; FE8004  0e
; PowerFail_PrepareSongWorkspace: Power-fail step: on screen 0x45 (MIDI FILE DIRECT PLAY) puts BStore_TrackToPart back
;   from the copy at 0x34BC that the screen's entry saved (16 bytes, as ScreenLeave_MidiFileDirectPlay would); then
;   workspace (0x6034D5) := BStore_CurrentBank, which BStore_BootPhase3 restores into BStore_CurrentBank at the next
;   boot. NMI_PowerFail_SaveAndHalt calls it (slot T_PowerFail_PrepareSongWorkspace) before the checksums. Basis: caller + body + the
;   save/restore pair + the boot reader. (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
PowerFail_PrepareSongWorkspace:
	cp	(UI_ScreenLatch:16), 0x45                            ; FE8005  c1 7a 20 3f 45
	jr nz, .LFE801C                                      ; FE800A  6e 10
	xor BC,BC                                            ; FE800C  d9 d1
	ld c, 0x10:opc                                          ; FE800E  23 10
	ld XIX,BStore_TrackToPart                                    ; FE8010  44 22 34 60 00
	ld XIY,0x000034bc                                    ; FE8015  45 bc 34 00 00
	ldir85                                               ; FE801A  85 11
.LFE801C:
	ld a, (BStore_CurrentBank:16)                                   ; FE801C  c1 0a 36 21
	ld (0x6034d5:24), a                                 ; FE8020  f2 d5 34 60 41
	ret                                                  ; FE8025  0e
; Transport_ResetAndStartBC: with interrupts masked: TransportB_Beat, Seq_BeatTick (B's tick), TransportC_Beat and TransportC_Tick = 0, then
;   TransportB_State and TransportC_State = 0x01 (the documented start value).  Reached through prom_b slot T_Transport_ResetAndStartBC.
;   Basis: body (named RAM, wsa1_ram.inc).
Transport_ResetAndStartBC:
	ei 0x06                                              ; FE8026  06 06
	xor WA,WA                                            ; FE8028  d8 d0
	ld	(TransportB_Beat:8), wa                                     ; FE802A  f0 91 50
	ld	(Seq_BeatTick:8), a                                      ; FE802D  f0 93 41
	ld	(TransportC_Beat:8), wa                                     ; FE8030  f0 8e 50
	ld	(TransportC_Tick:8), a                                      ; FE8033  f0 8d 41
	ld (TransportB_State:8), 0x01:io                                      ; FE8036  08 96 01
	ld (TransportC_State:8), 0x01:io                                      ; FE8039  08 95 01
	ei 0x00                                              ; FE803C  06 00
	ret                                                  ; FE803E  0e
Transport_ResetAndStartBC_Nop:
	ret                                                  ; FE803F  0e
; NoteRouting_RebuildForSong_Call: calls T_NoteRouting_RebuildForSong and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
NoteRouting_RebuildForSong_Call:
	call T_NoteRouting_RebuildForSong                                        ; FE8040  1d b8 11 f4
	ret                                                  ; FE8044  0e
; ---------------------------------------------------------------------
; ScreenLeave_DrumEditPartSelect -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x47, i.e. SCREEN ID 0x27 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x47 -> the screen object at
;          0xF402DC, whose +4 slot is `jp 0xFE8045`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   DrumEditPartSelect -- inherited from the +0 ENTER label
;          ShowScreen_DrumEditPartSelect, not from any text this pass read.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing on
;          leave; the slot exists to keep the three-method shape.
; Was `sub_FE8045`.
; ---------------------------------------------------------------------
ScreenLeave_DrumEditPartSelect:
	ret                                                  ; FE8045  0e
; EditScreen_PhaseVector: the boot phase vector of module 24, the NOTE / DRUM EDIT module -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
EditScreen_PhaseVector:
	jp EditScreen_PhaseVector_Ret                                        ; FE8046  1b 5e 80 fe
	jp EditScreen_PhaseVector_Ret                                        ; FE804A  1b 5e 80 fe
	jp EditScreen_BootPhase2And4                                        ; FE804E  1b 3f 83 fe
	jp EditScreen_PhaseVector_Ret                                        ; FE8052  1b 5e 80 fe
	jp EditScreen_BootPhase2And4                                        ; FE8056  1b 3f 83 fe
	jp EditScreen_PhaseVector_Ret                                        ; FE805A  1b 5e 80 fe
EditScreen_PhaseVector_Ret:
	ret                                                  ; FE805E  0e
T_F402B8_Nop:
	ret                                                  ; FE805F  0e
; ---------------------------------------------------------------------
; ScreenButton_Sequencer -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0x24, i.e. SCREEN ID 0x04 through
;          PanelScreen_VtableTable_ViewB -- and also mode index 0x24 of the
;          other view, which overlaps here
;
; Reached from: PanelScreen_VtableTable entry 0x24 -> the screen object at
;          0xF402AC, whose +8 slot is `jp 0xFE8060`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   Sequencer -- the same object's +0 ENTER method carries the label
;          Paint_Sequencer, a name an earlier round derived from the screen's
;          own text.
; Was `sub_FE8060`.
; ---------------------------------------------------------------------
ScreenButton_Sequencer:
	cp HL,0x001f                                         ; FE8060  db cf 1f 00
	jr gt, .LFE8076                                      ; FE8064  6a 10
; (sub_FE8066 removed 2026-10-04: no code names it and the line above falls through into it -- part of ScreenButton_Sequencer;
;  notes/prom_a_stray_label_removal.py)
	ld XIX,Sequencer_ButtonTable                         ; FE8066  44 77 80 fe 00
	sll hl, 0x02                                         ; FE806B  db ee 02
	extz XHL                                             ; FE806E  eb 12
	add XIX,XHL                                          ; FE8070  eb 84
	ld XIX,(XIX)                                         ; FE8072  a4 24
	call (xix)                                           ; FE8074  b4 e8
.LFE8076:
	ret                                                  ; FE8076  0e
; ---------------------------------------------------------------------
; ★ A SHAPE THAT FITS THE PANEL CODE -- offered as an observation, NOT as an
;          answer to the "Unknown" below.
;
; The 5-bit panel event code is now mapped to the physical controls
;          (notes/FINDINGS-prom_a-panel-control-map.md), and this table's
;          shape is what that map predicts of a screen: [00]-[07] all one
;          target (the eight SOFT KEY columns do the same thing), [08]-[0C]
;          five DISTINCT targets (the five LCD-row buttons), [0D]/[0E] one
;          target (-1/+1, and a code nothing on this panel raises), [0F] its
;          own (EXIT), [10]-[1F] all one target.
;
; ⚠ WHY THAT IS NOT ENOUGH. The reader is published as prom_b thunk slot
;          T_ScreenButton_Sequencer and NOTHING in either image names that slot
;          (notes/prom_a_xref.py), so no caller establishes what HL holds. A
;          shape that fits is a coincidence until a caller says otherwise,
;          and the handlers here are deliberately left `sub_XXXXXX` for that
;          reason. The shortest path to closing it is a caller of T_ScreenButton_Sequencer.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Sequencer_ButtonTable -- 32 pointers to routines in this module
; Read by: 0xFE8060 -- `cp HL,0x001F / jr ugt,<skip> / ld XIX,0x00FE8077 /
;          sll HL,2 / extz XHL / add XIX,XHL / ld XIX,(XIX) / call (XIX)`.
; ENTRY COUNT 32 is the READER'S OWN BOUND, not an extent: `cp HL,0x001F`
;          followed by an unsigned-greater-than branch admits indices
;          0..31 and no more.  The extent agrees -- 32 x 4 = 128 bytes
;          ends at 0xFE80F7, where code resumes -- but the bound is what
;          establishes it.
; Evidence: all 32 values are inside this module, the lowest 0xFE8165 and the
;          highest 0xFE81E5, and
;          the entry WIDTH 4 is the reader's `sll HL,2`.
; Unknown:  what the index in HL selects.  Entries 0..7 are all one routine
;          (0xFE8165) and entries 16..31 are all another (0xFE81E5), so
;          24 of the 32 slots carry two values; the eight in between hold
;          seven more (13 and 14 are the same), NINE distinct targets in
;          all.  Counted by `--check`, not by eye.
; ---------------------------------------------------------------------

Sequencer_ButtonTable:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol2,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol3,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol4,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol5,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol6,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol7,	ScreenLeave_Sequencer
	on_key	KEY_SoftKeyCol8,	ScreenLeave_Sequencer
	on_key	KEY_LcdRow1,		LcdKeyRow1_Sequencer
	on_key	KEY_LcdRow2,		LcdKeyRow2_Sequencer
	on_key	KEY_LcdRow3,		LcdKeyRow3_Sequencer
	on_key	KEY_LcdRow4,		LcdKeyRow4_Sequencer
	on_key	KEY_LcdRow5,		LcdKeyRow5_Sequencer
	on_key	KEY_MinusPlus,		Sequencer_ButtonTable_Nop13
	on_key	KEY_Code0E,		Sequencer_ButtonTable_Nop13
	on_key	KEY_Exit,		ExitKey_Sequencer
	on_key	KEY_Page,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code11,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code12,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code13,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code14,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code15,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code16,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code17,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code18,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code19,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code1A,		Sequencer_ButtonTable_Nop16
	on_key	KEY_NumberPad,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code1C,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code1D,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Compare,		Sequencer_ButtonTable_Nop16
	on_key	KEY_Code1F,		Sequencer_ButtonTable_Nop16
	keymap_end
; ---------------------------------------------------------------------
; LCD_ScreenRedraw_Begin_Copy -- a second, byte-identical copy of LCD_ScreenRedraw_Begin
;
; Called from: prom_a Paint_Sequencer (`calr`) at 0xFE8130
; Issues:  SWI7 service 0x0C at 0xFE80FB -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x10 at 0xFE80FE -- LCD_Svc_10_SetPanel3Layer, re-issue SYSTEM SET for a three-layer panel
; Evidence: the fourteen ROM bytes at 0xFE80F7 equal the fourteen at 0xF999F0 exactly
;           (checked byte for byte by --selftest).  Its one caller, Paint_Sequencer,
;           calls it at 0xFE8130 and the End copy at 0xFE8161, in that order.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ScreenRedraw_Begin_Copy:
	ld c, 0x00:opc                                          ; FE80F7  23 00
	ld a, 0x0c:opc                                          ; FE80F9  21 0c
	swi 7                                                ; FE80FB  ff
	ld a, 0x10:opc                                          ; FE80FC  21 10
	swi 7                                                ; FE80FE  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FE80FF  f1 40 25 00 00
	ret                                                  ; FE8104  0e
; ---------------------------------------------------------------------
; LCD_ScreenRedraw_End_Copy -- a second, byte-identical copy of LCD_ScreenRedraw_End
;
; Called from: prom_a Paint_Sequencer (`calr`) at 0xFE8161
; Issues:  SWI7 service 0x0C at 0xFE8109 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: the six ROM bytes at 0xFE8105 equal the six at 0xF999FE exactly.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ScreenRedraw_End_Copy:
	ld c, 0x07:opc                                          ; FE8105  23 07
	ld a, 0x0c:opc                                          ; FE8107  21 0c
	swi 7                                                ; FE8109  ff
	ret                                                  ; FE810A  0e
; ModeEnter_Sequencer: the +0 ENTER of panel mode 3 (PanelScreen_VtableTable[3] = T_ModeEnter_Sequencer); PanelMode_ToScreenIdMap[3] =
;   0x04, the screen whose vtable is T_Paint_Sequencer.  T_SoundGroup_ReloadSelection, (0x2134) |= 2.
ModeEnter_Sequencer:
	call T_SoundGroup_ReloadSelection                                        ; FE810B  1d c8 15 f4
	orw	(0x2134:16), 0x0002                  ; FE810F  d1 34 21 3e 02 00
	ret                                                  ; FE8115  0e
sub_FE8116:
	orw	(0x2134:16), 0x0002                  ; FE8116  d1 34 21 3e 02 00
	and	(0x34bb:16), 0xfb                            ; FE811C  c1 bb 34 3c fb
	and	(0x3614:16), 0xfe                            ; FE8121  c1 14 36 3c fe
	and	(0x34d1:16), 0xef                            ; FE8126  c1 d1 34 3c ef
	ret                                                  ; FE812B  0e
; Paint_Sequencer -- paints the screen whose own text reads "SEQUENCER", "REALTIME", "EDIT"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xFE8142  interpreter A  list 0xFF0E2B  DisplayList_SequencerRealtimeEdit
;        text: "SEQUENCER"; "REALTIME"; "EDIT"; "MASTER"; "REC0RD"; "TRACK"
; Evidence: the list address is the `ld XIY,0x00FF0E2B` IMMEDIATE at the
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
Paint_Sequencer:
	call T_CallbackQueue_ResetAndRestartTask2            ; FE812C  1d 80 2e f4
	calr LCD_ScreenRedraw_Begin_Copy                                      ; FE8130  1e c4 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FE8133  f1 40 25 00 00
	ld XIY,DisplayList_SequencerRealtimeEdit             ; FE8138  45 2b 0e ff 00
	ld XIX,DisplayList_NoteEditTrackSong                 ; FE813D  44 11 0f ff 00
	call T_DisplayList_Run                               ; FE8142  1d f0 17 f4
	calr Sequencer_DrawTitleIcon                                      ; FE8146  1e 9e 00
	calr Sequencer_DrawRealtimeIcon                                      ; FE8149  1e aa 00
	calr Sequencer_DrawMasterRecordIcon                                      ; FE814C  1e b6 00
	calr Sequencer_DrawStepIcon                                      ; FE814F  1e c2 00
	calr Sequencer_DrawSongSelectIcon                                      ; FE8152  1e ce 00
	calr Sequencer_DrawEditIcon                                      ; FE8155  1e e9 00
	calr Sequencer_DrawTrackAssignIcon                                      ; FE8158  1e f5 00
	calr Sequencer_DrawMedleyIcon                                      ; FE815B  1e 01 01
	calr Sequencer_DrawAfterTouchSetIcon                                      ; FE815E  1e 0d 01
	calr LCD_ScreenRedraw_End_Copy                                      ; FE8161  1e a1 ff
	ret                                                  ; FE8164  0e
; ---------------------------------------------------------------------
; ScreenLeave_Sequencer -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x24, i.e. SCREEN ID 0x04 through
;          PanelScreen_VtableTable_ViewB -- and also mode index 0x24 of the
;          other view, which overlaps here
;
; Reached from: PanelScreen_VtableTable entry 0x24 -> the screen object at
;          0xF402AC, whose +4 slot is `jp 0xFE8165`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   Sequencer -- the same object's +0 ENTER method carries the label
;          Paint_Sequencer, a name an earlier round derived from the screen's
;          own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_FE8165`.
; ---------------------------------------------------------------------
ScreenLeave_Sequencer:
	ret                                                  ; FE8165  0e
; LcdKeyRow1_Sequencer: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); Sequencer_ButtonTable slot 0x08.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow1_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE8097
	bit 0x07,W                                           ; FE8166  c8 33 07
	jr nz, .LFE8173                                      ; FE8169  6e 08
	ldw (UI_Request:16), 0x0207                              ; FE816B  f1 70 20 02 07 02
	jr .LFE8179                                          ; FE8171  68 06
.LFE8173:
	ldw (UI_Request:16), 0x0205                              ; FE8173  f1 70 20 02 05 02
.LFE8179:
	call T_Transport_StopAllRunning                                        ; FE8179  1d ac 09 f4
	ret                                                  ; FE817D  0e
; LcdKeyRow2_Sequencer: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); Sequencer_ButtonTable slot 0x09.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow2_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE809B
	bit 0x07,W                                           ; FE817E  c8 33 07
	jr nz, .LFE818B                                      ; FE8181  6e 08
	ldw (UI_Request:16), 0x8010                              ; FE8183  f1 70 20 02 10 80
	jr .LFE8196                                          ; FE8189  68 0b
.LFE818B:
	ld (0x0e5c:16), 0x11                                 ; FE818B  f1 5c 0e 00 11
	ldw (UI_Request:16), 0x800e                              ; FE8190  f1 70 20 02 0e 80
.LFE8196:
	call T_Transport_StopAllRunning                                        ; FE8196  1d ac 09 f4
	ret                                                  ; FE819A  0e
; LcdKeyRow3_Sequencer: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); Sequencer_ButtonTable slot 0x0A.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow3_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE809F
	bit 0x07,W                                           ; FE819B  c8 33 07
	jr nz, .LFE81A8                                      ; FE819E  6e 08
	ldw (UI_Request:16), 0x8013                              ; FE81A0  f1 70 20 02 13 80
	jr .LFE81AE                                          ; FE81A6  68 06
.LFE81A8:
	ldw (UI_Request:16), 0x0206                              ; FE81A8  f1 70 20 02 06 02
.LFE81AE:
	call T_Transport_StopAllRunning                                        ; FE81AE  1d ac 09 f4
	ret                                                  ; FE81B2  0e
; LcdKeyRow4_Sequencer: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); Sequencer_ButtonTable slot 0x0B.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow4_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE80A3
	bit 0x07,W                                           ; FE81B3  c8 33 07
	jr nz, .LFE81C0                                      ; FE81B6  6e 08
	ldw (UI_Request:16), 0x800b                              ; FE81B8  f1 70 20 02 0b 80
	jr .LFE81C6                                          ; FE81BE  68 06
.LFE81C0:
	ldw (UI_Request:16), 0x800d                              ; FE81C0  f1 70 20 02 0d 80
.LFE81C6:
	call T_Transport_StopAllRunning                                        ; FE81C6  1d ac 09 f4
	ret                                                  ; FE81CA  0e
; LcdKeyRow5_Sequencer: row 5 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); Sequencer_ButtonTable slot 0x0C.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow5_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE80A7
	bit 0x07,W                                           ; FE81CB  c8 33 07
	jr nz, .LFE81D2                                      ; FE81CE  6e 02
	jr .LFE81D2                                          ; FE81D0  68 00
.LFE81D2:
	ret                                                  ; FE81D2  0e
Sequencer_ButtonTable_Nop13:   ; entry: named by 2 `.long` operands, first at 0xFE80AB
	ret                                                  ; FE81D3  0e
; ExitKey_Sequencer: the EXIT key; Sequencer_ButtonTable slot 0x0F.  Slot -> control: wave7_panel_names_round11.CONTROL.
ExitKey_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFE80B3
	bit 0x07,W                                           ; FE81D4  c8 33 07
	jr nz, .LFE81E1                                      ; FE81D7  6e 08
	ldw (UI_Request:16), 0x0201                              ; FE81D9  f1 70 20 02 01 02
	jr .LFE81E4                                          ; FE81DF  68 03
.LFE81E1:
	calr ExitKey_Sequencer_Nop                                      ; FE81E1  1e 02 00
.LFE81E4:
	ret                                                  ; FE81E4  0e
Sequencer_ButtonTable_Nop16:   ; entry: named by 16 `.long` operands, first at 0xFE80B7
	ret                                                  ; FE81E5  0e
ExitKey_Sequencer_Nop:
	ret                                                  ; FE81E6  0e
; Sequencer_DrawTitleIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE81F1  interpreter A  list 0xFE829B-0xFE82A0
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawTitleIcon: Draws the SEQUENCER screen's title icon (the image reads "SEQ."): one op-0x23 record, icon-
;   sheet cell 49 (prom_b/images/DLGlyph_049_*.png) at LCD address 0x0034. Paint_Sequencer draws it right after
;   DisplayList_SequencerRealtimeEdit, whose title 'SEQUENCER' starts at pixel x 0x7A, y 5 -- the icon sits just left
;   of it (row 1, column 12). Basis: caller + body + icon image + position. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawTitleIcon:
	ld XIY,Sequencer_DrawTitleIcon_DL                            ; FE81E7  45 9b 82 fe 00
	ld XIX,Sequencer_DrawRealtimeIcon_DL                            ; FE81EC  44 a0 82 fe 00
	call T_DisplayList_Run                               ; FE81F1  1d f0 17 f4
	ret                                                  ; FE81F5  0e
; Sequencer_DrawRealtimeIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE8200  interpreter A  list 0xFE82A0-0xFE82A5
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawRealtimeIcon: Draws the REALTIME item's icon (a stopwatch), left edge of LCD key row 1: one op-0x23
;   record, icon-sheet cell 50 (prom_b/images/DLGlyph_050_*.png) at LCD address 0x0411. Paint_Sequencer draws it after
;   DisplayList_SequencerRealtimeEdit, where the item text 'REALTIME' sits at 0x05A5 (row 36, column 5); the icon
;   covers rows 26-49 at column 1. Basis: caller + body + icon image + position. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawRealtimeIcon:
	ld XIY,Sequencer_DrawRealtimeIcon_DL                            ; FE81F6  45 a0 82 fe 00
	ld XIX,Sequencer_DrawMasterRecordIcon_DL                            ; FE81FB  44 a5 82 fe 00
	call T_DisplayList_Run                               ; FE8200  1d f0 17 f4
	ret                                                  ; FE8204  0e
; Sequencer_DrawMasterRecordIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE820F  interpreter A  list 0xFE82A5-0xFE82AA
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawMasterRecordIcon: Draws the MASTER RECORD item's icon, left edge of LCD key row 2: one op-0x23 record,
;   icon-sheet cell 58 (prom_b/images/DLGlyph_058_*.png) at LCD address 0x0AF1. Paint_Sequencer draws it after
;   DisplayList_SequencerRealtimeEdit, where the item text 'MASTER REC0RD' sits at 0x0BE5 (row 76, column 5); the icon
;   covers rows 70-93 at column 1. Basis: caller + body + icon image + position. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawMasterRecordIcon:
	ld XIY,Sequencer_DrawMasterRecordIcon_DL                            ; FE8205  45 a5 82 fe 00
	ld XIX,Sequencer_DrawStepIcon_DL                            ; FE820A  44 aa 82 fe 00
	call T_DisplayList_Run                               ; FE820F  1d f0 17 f4
	ret                                                  ; FE8213  0e
; Sequencer_DrawStepIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE821E  interpreter A  list 0xFE82AA-0xFE82AF
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawStepIcon: Draws the STEP item's icon (footprints), left edge of LCD key row 3: one op-0x23 record,
;   icon-sheet cell 52 (prom_b/images/DLGlyph_052_*.png) at LCD address 0x10B9. Paint_Sequencer draws it after
;   DisplayList_SequencerRealtimeEdit, where the item text 'STEP' sits at 0x11D5 (row 114, column 5); the icon covers
;   rows 107-130 at column 1. Basis: caller + body + icon image + position. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawStepIcon:
	ld XIY,Sequencer_DrawStepIcon_DL                            ; FE8214  45 aa 82 fe 00
	ld XIX,Sequencer_DrawSongSelectIcon_DL1                            ; FE8219  44 af 82 fe 00
	call T_DisplayList_Run                               ; FE821E  1d f0 17 f4
	ret                                                  ; FE8222  0e
; Sequencer_DrawSongSelectIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE822D  interpreter A  list 0xFE82AF-0xFE82B4
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawSongSelectIcon: Draws the SONG SELECT /NAME item's icon (a clef and a "1"), left edge of LCD key row
;   4: one op-0x23 record, icon-sheet cell 53 (prom_b/images/DLGlyph_053_*.png) at LCD address 0x16D1. Paint_Sequencer
;   draws it after DisplayList_SequencerRealtimeEdit, where the item text 'S0NG SELECT /NAME' sits at 0x16D5 (row 146,
;   column 5); the icon covers rows 146-169 at column 1. The next stub (0xFE8232, cell 54, row 186) has no caller.
;   Basis: caller + body + icon image + position. (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawSongSelectIcon:
	ld XIY,Sequencer_DrawSongSelectIcon_DL1                            ; FE8223  45 af 82 fe 00
	ld XIX,Sequencer_DrawSongSelectIcon_DL2                            ; FE8228  44 b4 82 fe 00
	call T_DisplayList_Run                               ; FE822D  1d f0 17 f4
	ret                                                  ; FE8231  0e
	ld XIY,Sequencer_DrawSongSelectIcon_DL2                            ; FE8232  45 b4 82 fe 00
	ld XIX,Sequencer_DrawEditIcon_DL                            ; FE8237  44 b9 82 fe 00
	call T_DisplayList_Run                               ; FE823C  1d f0 17 f4
	ret                                                  ; FE8240  0e
; Sequencer_DrawEditIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE824B  interpreter A  list 0xFE82B9-0xFE82BE
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawEditIcon: Draws the EDIT item's icon (the image reads "EDIT"), right edge of LCD key row 1: one
;   op-0x23 record, icon-sheet cell 16 (prom_b/images/DLGlyph_016_*.png) at LCD address 0x0434. Paint_Sequencer draws
;   it after DisplayList_SequencerRealtimeEdit, where the item text 'EDIT' sits at 0x05B7 (row 36, column 23); the
;   icon covers rows 26-49 at column 36. Basis: caller + body + icon image + position. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawEditIcon:
	ld XIY,Sequencer_DrawEditIcon_DL                            ; FE8241  45 b9 82 fe 00
	ld XIX,Sequencer_DrawTrackAssignIcon_DL                            ; FE8246  44 be 82 fe 00
	call T_DisplayList_Run                               ; FE824B  1d f0 17 f4
	ret                                                  ; FE824F  0e
; Sequencer_DrawTrackAssignIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE825A  interpreter A  list 0xFE82BE-0xFE82C3
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawTrackAssignIcon: Draws the TRACK ASSIGN item's icon (a clef over tracks 1-4 and an arrow), right edge
;   of LCD key row 2: one op-0x23 record, icon-sheet cell 55 (prom_b/images/DLGlyph_055_*.png) at LCD address 0x0B14.
;   Paint_Sequencer draws it after DisplayList_SequencerRealtimeEdit, where the item text 'TRACK ASSIGN' sits at
;   0x0BF7 (row 76, column 23); the icon covers rows 70-93 at column 36. Basis: caller + body + icon image + position.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawTrackAssignIcon:
	ld XIY,Sequencer_DrawTrackAssignIcon_DL                            ; FE8250  45 be 82 fe 00
	ld XIX,Sequencer_DrawMedleyIcon_DL                            ; FE8255  44 c3 82 fe 00
	call T_DisplayList_Run                               ; FE825A  1d f0 17 f4
	ret                                                  ; FE825E  0e
; Sequencer_DrawMedleyIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE8269  interpreter A  list 0xFE82C3-0xFE82C8
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawMedleyIcon: Draws the MEDLEY item's icon (the image reads "SONGS" in a loop of arrows), right edge of
;   LCD key row 3: one op-0x23 record, icon-sheet cell 56 (prom_b/images/DLGlyph_056_*.png) at LCD address 0x10DC.
;   Paint_Sequencer draws it after DisplayList_SequencerRealtimeEdit, where the item text 'MEDLEY' sits at 0x11E7 (row
;   114, column 23); the icon covers rows 107-130 at column 36. Basis: caller + body + icon image + position.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawMedleyIcon:
	ld XIY,Sequencer_DrawMedleyIcon_DL                            ; FE825F  45 c3 82 fe 00
	ld XIX,Sequencer_DrawAfterTouchSetIcon_DL                            ; FE8264  44 c8 82 fe 00
	call T_DisplayList_Run                               ; FE8269  1d f0 17 f4
	ret                                                  ; FE826D  0e
; Sequencer_DrawAfterTouchSetIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE8278  interpreter A  list 0xFE82C8-0xFE82CD
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; Sequencer_DrawAfterTouchSetIcon: Draws the AFTER TOUCH SET item's icon (a hand pressing keys), right edge of LCD key
;   row 4: one op-0x23 record, icon-sheet cell 57 (prom_b/images/DLGlyph_057_*.png) at LCD address 0x16F4.
;   Paint_Sequencer draws it after DisplayList_SequencerRealtimeEdit, where the item text 'AFTER T0UCH SET' sits at
;   0x16E7 (row 146, column 23); the icon covers rows 146-169 at column 36. Basis: caller + body + icon image +
;   position. (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
Sequencer_DrawAfterTouchSetIcon:
	ld XIY,Sequencer_DrawAfterTouchSetIcon_DL                            ; FE826E  45 c8 82 fe 00
	ld XIX,NoteEditPartSelect_DrawTitleIcon_DL                            ; FE8273  44 cd 82 fe 00
	call T_DisplayList_Run                               ; FE8278  1d f0 17 f4
	ret                                                  ; FE827C  0e
; NoteEditPartSelect_DrawTitleIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE8287  interpreter A  list 0xFE82CD-0xFE82D2
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; NoteEditPartSelect_DrawTitleIcon: Draws the NOTE EDIT part-select title icon (piano keys): one op-0x23 record, icon-
;   sheet cell 2 (prom_b/images/DLGlyph_002_*.png) at LCD address 0x007E. The icon covers x 48-71, y 3-26, just left
;   of the title 'NOTE' (pixel x 0x50, y 6) DisplayList_NoteEditPartSelect draws. Basis: caller + body + icon image +
;   position. (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
NoteEditPartSelect_DrawTitleIcon:
	ld XIY,NoteEditPartSelect_DrawTitleIcon_DL                            ; FE827D  45 cd 82 fe 00
	ld XIX,DrumEditPartSelect_DrawTitleIcon_DL                            ; FE8282  44 d2 82 fe 00
	call T_DisplayList_Run                               ; FE8287  1d f0 17 f4
	ret                                                  ; FE828B  0e
; DrumEditPartSelect_DrawTitleIcon -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFE8296  interpreter A  list 0xFE82D2-0xFE82D7
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEditPartSelect_DrawTitleIcon: Draws the DRUM EDIT part-select title icon (a drum kit): one op-0x23 record, icon-
;   sheet cell 15 (prom_b/images/DLGlyph_015_*.png) at LCD address 0x007E. The same cell position as
;   NoteEditPartSelect_DrawTitleIcon, left of the title 'DRUM' (pixel x 0x50, y 6). Its list-end operand is spelled
;   EditScreen_Tick only because that routine starts at 0xFE82D7. Basis: caller + body + icon image + position.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
DrumEditPartSelect_DrawTitleIcon:
	ld XIY,DrumEditPartSelect_DrawTitleIcon_DL                            ; FE828C  45 d2 82 fe 00
	ld XIX,EditScreen_Tick                                    ; FE8291  44 d7 82 fe 00
	call T_DisplayList_Run                               ; FE8296  1d f0 17 f4
	ret                                                  ; FE829A  0e

; Sequencer_DrawTitleIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE829B and land exactly on 0xFE82A0.
Sequencer_DrawTitleIcon_DL:
; ; drawn (start operand) by Sequencer_DrawTitleIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=49, x=96, y=1

; Sequencer_DrawRealtimeIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82A0 and land exactly on 0xFE82A5.
Sequencer_DrawRealtimeIcon_DL:
; ; drawn (start operand) by Sequencer_DrawRealtimeIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=50, x=8, y=26

; Sequencer_DrawMasterRecordIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82A5 and land exactly on 0xFE82AA.
Sequencer_DrawMasterRecordIcon_DL:
; ; drawn (start operand) by Sequencer_DrawMasterRecordIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=58, x=8, y=70

; Sequencer_DrawStepIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82AA and land exactly on 0xFE82AF.
Sequencer_DrawStepIcon_DL:
; ; drawn (start operand) by Sequencer_DrawStepIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=52, x=8, y=107

; Sequencer_DrawSongSelectIcon_DL1 -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82AF and land exactly on 0xFE82B4.
Sequencer_DrawSongSelectIcon_DL1:
; ; drawn (start operand) by Sequencer_DrawSongSelectIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=53, x=8, y=146

; Sequencer_DrawSongSelectIcon_DL2 -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82B4 and land exactly on 0xFE82B9.
Sequencer_DrawSongSelectIcon_DL2:
; ; drawn (start operand) by Sequencer_DrawSongSelectIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=54, x=8, y=186

; Sequencer_DrawEditIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82B9 and land exactly on 0xFE82BE.
Sequencer_DrawEditIcon_DL:
; ; drawn (start operand) by Sequencer_DrawEditIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=16, x=288, y=26

; Sequencer_DrawTrackAssignIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82BE and land exactly on 0xFE82C3.
Sequencer_DrawTrackAssignIcon_DL:
; ; drawn (start operand) by Sequencer_DrawTrackAssignIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=55, x=288, y=70

; Sequencer_DrawMedleyIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82C3 and land exactly on 0xFE82C8.
Sequencer_DrawMedleyIcon_DL:
; ; drawn (start operand) by Sequencer_DrawMedleyIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=56, x=288, y=107

; Sequencer_DrawAfterTouchSetIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82C8 and land exactly on 0xFE82CD.
Sequencer_DrawAfterTouchSetIcon_DL:
; ; drawn (start operand) by Sequencer_DrawAfterTouchSetIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=57, x=288, y=146

; NoteEditPartSelect_DrawTitleIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82CD and land exactly on 0xFE82D2.
NoteEditPartSelect_DrawTitleIcon_DL:
; ; drawn (start operand) by NoteEditPartSelect_DrawTitleIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=2, x=48, y=3

; DrumEditPartSelect_DrawTitleIcon_DL -- 1 record(s), 5 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE82D2 and land exactly on 0xFE82D7.
DrumEditPartSelect_DrawTitleIcon_DL:
; ; drawn (start operand) by DrumEditPartSelect_DrawTitleIcon -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_value_glyph	glyph=15, x=48, y=3
; EditScreen_Tick: T_EditScreen_Tick: NoteEdit_TakeKeyboardInput, then the two countdown timers (EditScreen_CountDownAction,
;   _RunDueAction, _CountDownAction2, _RunDueAction2), then T_SeqCycle_TickDeferredAction.
EditScreen_Tick:
	calr NoteEdit_TakeKeyboardInput                                          ; FE82D7  1e 23 0d
	calr EditScreen_CountDownAction                                          ; FE82DA  1e e4 0f
	calr EditScreen_RunDueAction                                          ; FE82DD  1e 0d 10
	calr EditScreen_CountDownAction2                                          ; FE82E0  1e f4 0f
	calr EditScreen_RunDueAction2                                          ; FE82E3  1e 47 10
	call T_SeqCycle_TickDeferredAction                                        ; FE82E6  1d 3c 0a f4
	ret                                                  ; FE82EA  0e
; BStoreCursor_SeekPrevTag -- move the block-store cursor BACKWARD to the
; previous byte with bit 7 set, and return it in A; the mirror of
; BStoreCursor_SeekNextTag (0xFF21F6), which see for the cursor pair
; ((0x345C) block number, (0x345E) offset 5..0xFF).
; While the offset is above 5 it is decremented; at 5 the cursor moves to the
; block's +1 PREVIOUS link (`ld WA,(XIY)` with XIY = block + 1, 0xFE831C) with
; the offset set to 0xFF.  A previous link of 0 means the start of the chain:
; the routine then sets (0x0D4A) = 0xFF and returns without a tag (it clears
; (0x0D4A) to 0 on entry, so (0x0D4A) is the "ran off the start" flag).
; Called from 3 sites (0xFE8F86, 0xFE979A, 0xFEA931).
BStoreCursor_SeekPrevTag:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE82EB  f1 4a 0d 00 00
.LFE82F0:
	cpw	(BStore_CursorOffset:16), 0x0005                          ; FE82F0  d1 5e 34 3f 05 00
	jr ule, .LFE8306                                     ; FE82F6  63 0e
	decw 0x01, (BStore_CursorOffset:16)                               ; FE82F8  d1 5e 34 69
.LFE82FC:
	call BStoreCursor_ReadByte                                        ; FE82FC  1d 32 22 ff
	bit 0x07,A                                           ; FE8300  c9 33 07
	jr z, .LFE82F0                                       ; FE8303  66 eb
	ret                                                  ; FE8305  0e
.LFE8306:
	calr BStore_GetHeapBase                                      ; FE8306  1e 2b 00
	ld ix, (BStore_CursorBlock:16)                                 ; FE8309  d1 5c 34 24
	extz XIX                                             ; FE830D  ec 12
	dec 1,XIX                                            ; FE830F  ec 69
	sll xix, 0x08                                        ; FE8311  ec ee 08
	add XIY,XIX                                          ; FE8314  ec 85
	add XIY,0x00000001                                   ; FE8316  ed c8 01 00 00 00
	ld WA,(XIY)                                          ; FE831C  95 20
	cp wa, 0x00:i3                                         ; FE831E  d8 d8
	jr z, .LFE832E                                       ; FE8320  66 0c
	ld (BStore_CursorBlock:16), wa                                  ; FE8322  f1 5c 34 50
	ldw (BStore_CursorOffset:16), 0xff                                ; FE8326  f1 5e 34 02 ff 00
	jr .LFE82FC                                          ; FE832C  68 ce
.LFE832E:
	ld (BStore_ErrorCode:16), 0xff                                 ; FE832E  f1 4a 0d 00 ff
	ret                                                  ; FE8333  0e
; BStore_GetHeapBase -- XIY = the long at (0x3604), the base of the block
; store's 256-byte-block heap (0x00617800 per
; wsa1/notes/FINDINGS-prom_b-block-store.md, which derives it from prom_b's
; inverse arithmetic).  The `add XIY,0` is the ROM's own (a compiler adding a
; zero field offset).  Called by the four BStoreCursor_* routines at
; 0xFF21F6-0xFF2269, by BStoreCursor_SeekPrevTag and from 0xFE89B6.
BStore_GetHeapBase:
	ld xiy, (BStore_HeapBase:16)                                 ; FE8334  e1 04 36 25
	add XIY,0x00000000                                   ; FE8338  ed c8 00 00 00 00
	ret                                                  ; FE833E  0e
; EditScreen_BootPhase2And4: module 24's boot phase 2/4 handler -- ModuleInitDirectory_F82641[24]'s vector 0xFE8046, slots 2, 4
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
EditScreen_BootPhase2And4:
	ldw (0x601f4f:24), 0x30                             ; FE833F  f2 4f 1f 60 02 30 00
	ldw (0x601f51:24), 0x30                             ; FE8346  f2 51 1f 60 02 30 00
	ldw (0x601f4b:24), 0x26                             ; FE834D  f2 4b 1f 60 02 26 00
	ld (NoteEdit_RulerPosition:24), 0x05                             ; FE8354  f2 53 1f 60 00 05
	ldw (DrumEdit_TopRowNote:24), 0x28                             ; FE835A  f2 71 1f 60 02 28 00
	ldw (EditScreen_CursorRow:24), 0x05                             ; FE8361  f2 73 1f 60 02 05 00
	ld (EditField_NewNoteVelocity:24), 0x64                             ; FE8368  f2 46 1f 60 00 64
	ret                                                  ; FE836E  0e
; ---------------------------------------------------------------------
; ShowScreen_NoteEditPartSelect -- blank, re-init the panel, run the NOTE EDIT part-select painter, show it
;
; Called from: prom_b T_ShowScreen_NoteEditPartSelect (T_F402BC) (`jp`) at 
; Issues:  SWI7 service 0x0C at 0xFE8381 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x10 at 0xFE8384 -- LCD_Svc_10_SetPanel3Layer, re-issue SYSTEM SET for a three-layer panel
; Issues:  SWI7 service 0x0C at 0xFE8392 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: `xor C,C` + service 0x0C, service 0x10, then `calr Paint_NoteEditPartSelect`
;           -- a name this tree already carries -- and finally `ld C,0x07` + service
;           0x0C.  The bracket is LCD_ScreenRedraw_Begin's and _End's, written out
;           inline.  It also clears bit 0 of (0x601F70), EditScreen_Mode: 0 = NOTE EDIT,
;           1 = DRUM EDIT -- ShowScreen_DrumEditPartSelect SETS it (FINDINGS-prom_a-
;           screen-module.md section 8).
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
ShowScreen_NoteEditPartSelect:
	or	(0x34bb:16), 0x04                            ; FE836F  c1 bb 34 3e 04
	call T_CallbackQueue_ResetAndRestartTask2            ; FE8374  1d 80 2e f4
	res	0, (EditScreen_Mode:24)                             ; FE8378  f2 70 1f 60 b0
	xor C,C                                              ; FE837D  cb d3
	ld a, 0x0c:opc                                          ; FE837F  21 0c
	swi 7                                                ; FE8381  ff
	ld a, 0x10:opc                                          ; FE8382  21 10
	swi 7                                                ; FE8384  ff
	calr Paint_NoteEditPartSelect                                      ; FE8385  1e 0c 00
	calr EditPartSelect_DrawPartLabels                                      ; FE8388  1e 51 00
	calr NoteEditPartSelect_DrawTitleIcon                                          ; FE838B  1e ef fe
	ld c, 0x07:opc                                          ; FE838E  23 07
	ld a, 0x0c:opc                                          ; FE8390  21 0c
	swi 7                                                ; FE8392  ff
	ret                                                  ; FE8393  0e
; Paint_NoteEditPartSelect -- paints the screen whose own text reads "NOTE", "EDIT", "PART"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xFE839E  interpreter A  list 0xFF1332  DisplayList_NoteEditPartSelect
;        text: "NOTE"; "EDIT"; "PART"; "SELECT"; "Press"; "the"
; Evidence: the list address is the `ld XIY,0x00FF1332` IMMEDIATE at the
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
Paint_NoteEditPartSelect:
	ld XIY,DisplayList_NoteEditPartSelect                ; FE8394  45 32 13 ff 00
	ld XIX,DisplayList_DrumEditPartSelect                ; FE8399  44 8a 15 ff 00
	call T_DisplayList_Run                               ; FE839E  1d f0 17 f4
	ret                                                  ; FE83A2  0e
; ---------------------------------------------------------------------
; ShowScreen_DrumEditPartSelect -- the same sequence around the DRUM EDIT part-select painter
;
; Called from: prom_b T_ShowScreen_DrumEditPartSelect (T_F402DC) (`jp`) at 
; Issues:  SWI7 service 0x0C at 0xFE83BA -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x10 at 0xFE83BD -- LCD_Svc_10_SetPanel3Layer, re-issue SYSTEM SET for a three-layer panel
; Issues:  SWI7 service 0x0C at 0xFE83CB -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: identical in shape to ShowScreen_NoteEditPartSelect, calling
;           Paint_DrumEditPartSelect instead, and SETTING bit 0 of (0x601F70) where
;           the other clears it.  It also clears bit 0 of (0x601F77), which the note
;           one does not touch.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
ShowScreen_DrumEditPartSelect:
	res	0, (0x601f77:24)                             ; FE83A3  f2 77 1f 60 b0
	or	(0x34bb:16), 0x04                            ; FE83A8  c1 bb 34 3e 04
	call T_CallbackQueue_ResetAndRestartTask2            ; FE83AD  1d 80 2e f4
	set	0, (EditScreen_Mode:24)                             ; FE83B1  f2 70 1f 60 b8
	xor C,C                                              ; FE83B6  cb d3
	ld a, 0x0c:opc                                          ; FE83B8  21 0c
	swi 7                                                ; FE83BA  ff
	ld a, 0x10:opc                                          ; FE83BB  21 10
	swi 7                                                ; FE83BD  ff
	calr Paint_DrumEditPartSelect                                      ; FE83BE  1e 0c 00
	calr EditPartSelect_DrawPartLabels                                      ; FE83C1  1e 18 00
	calr DrumEditPartSelect_DrawTitleIcon                                          ; FE83C4  1e c5 fe
	ld c, 0x07:opc                                          ; FE83C7  23 07
	ld a, 0x0c:opc                                          ; FE83C9  21 0c
	swi 7                                                ; FE83CB  ff
	ret                                                  ; FE83CC  0e
; Paint_DrumEditPartSelect -- paints the screen whose own text reads "DRUM", "EDIT", "PART"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xFE83D7  interpreter A  list 0xFF158A  DisplayList_DrumEditPartSelect
;        text: "DRUM"; "EDIT"; "PART"; "SELECT"; "Press"; "the"
; Evidence: the list address is the `ld XIY,0x00FF158A` IMMEDIATE at the
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
Paint_DrumEditPartSelect:
	ld XIY,DisplayList_DrumEditPartSelect                ; FE83CD  45 8a 15 ff 00
	ld XIX,KeyboardRuler_Strip0                          ; FE83D2  44 e2 17 ff 00
	call T_DisplayList_Run                               ; FE83D7  1d f0 17 f4
	ret                                                  ; FE83DB  0e
; EditPartSelect_DrawPartLabels -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 14
; instructions to its first `ret`:
;     site 0xFE8400  interpreter B  list 0xFE8405-0xFE84F5
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditPartSelect_DrawPartLabels: the 16 bytes at 0x603422 copied to DisplayListB_Stage, then EditPartSelect_DrawPartLabels_DL with PartLabels_FE84F5.  Called
;   by ShowScreen_NoteEditPartSelect / _DrumEditPartSelect.
EditPartSelect_DrawPartLabels:
	ld XIY,BStore_TrackToPart                                    ; FE83DC  45 22 34 60 00
	ld XIX,DisplayListB_Stage                                    ; FE83E1  44 f6 12 00 00
	ld c, 0x10:opc                                          ; FE83E6  23 10
.LFE83E8:
	ld A,(XIY)                                           ; FE83E8  85 21
	ld (XIX),A                                           ; FE83EA  b4 41
	dec 1,C                                              ; FE83EC  cb 69
	jr z, .LFE83F6                                       ; FE83EE  66 06
	inc 1,IY                                             ; FE83F0  dd 61
	inc 1,IX                                             ; FE83F2  dc 61
	jr .LFE83E8                                          ; FE83F4  68 f2
.LFE83F6:
	ld XIY,EditPartSelect_DrawPartLabels_DL                            ; FE83F6  45 05 84 fe 00
	ld XIX,PartLabels_FE84F5                             ; FE83FB  44 f5 84 fe 00
	call T_DisplayListB_Run                              ; FE8400  1d f4 17 f4
	ret                                                  ; FE8404  0e

; EditPartSelect_DrawPartLabels_DL -- 16 record(s), 240 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFE8405 and land exactly on 0xFE84F5.
EditPartSelect_DrawPartLabels_DL:
; ; drawn (start operand) by EditPartSelect_DrawPartLabels -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=DisplayListB_Stage, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=8, y=175
	dlb_string	var=DisplayListB_Stage+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=48, y=175
	dlb_string	var=DisplayListB_Stage+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=88, y=175
	dlb_string	var=DisplayListB_Stage+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=128, y=175
	dlb_string	var=DisplayListB_Stage+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=168, y=175
	dlb_string	var=DisplayListB_Stage+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=208, y=175
	dlb_string	var=DisplayListB_Stage+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=248, y=175
	dlb_string	var=DisplayListB_Stage+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=288, y=175
	dlb_string	var=DisplayListB_Stage+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=8, y=222
	dlb_string	var=DisplayListB_Stage+9, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=48, y=222
	dlb_string	var=DisplayListB_Stage+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=88, y=222
	dlb_string	var=DisplayListB_Stage+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=128, y=222
	dlb_string	var=DisplayListB_Stage+12, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=168, y=222
	dlb_string	var=DisplayListB_Stage+13, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=208, y=222
	dlb_string	var=DisplayListB_Stage+14, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=248, y=222
	dlb_string	var=DisplayListB_Stage+15, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, table=PartLabels_FE84F5, width=3, x=288, y=222
; ---------------------------------------------------------------------
; PartLabels_FE84F5 -- 37 three-character labels, "P 1" .. "P32"
; Read by: the display list at 0xFE8405, whose 16 records all carry this
;          address as their SOURCE field and 0x20/0x0003 as their COUNT
;          and STRIDE -- see EditPartSelect_DrawPartLabels_DL below.  So 32 entries and
;          a 3-byte stride are the READER'S, in a field the interpreter
;          reads, not an extent.
; ENTRY COUNT 37 is 32 from the reader plus an EXTENT of five more: the
;          table runs to 0xFE8564, where the next routine's 0x0E begins,
;          and those five extra entries all read "P 1".
; ★ CORROBORATION, and it is a different object: IndexMap_FE87B8 is also
;          37 entries and is 0x00..0x1F followed by five 0x00 -- five
;          slots that alias slot 0, exactly where this table has five
;          slots that alias "P 1".  Two tables, two readers, the same
;          37-with-5-aliases shape.
;          ⚠ That is corroboration of the FRAMING, not of the count: both
;          37s are extents.  What is bounded is the 32.
; Unknown:  what P stands for.  "Part" is the obvious reading and is NOT
;          claimed here -- nothing in either image spells the word next to
;          this table.
; ---------------------------------------------------------------------

PartLabels_FE84F5:
	.byte 0x50, 0x20, 0x31, 0x50, 0x20, 0x32, 0x50, 0x20, 0x33, 0x50, 0x20, 0x34, 0x50, 0x20, 0x35, 0x50  ; FE84F5
	.byte 0x20, 0x36, 0x50, 0x20, 0x37, 0x50, 0x20, 0x38, 0x50, 0x20, 0x39, 0x50, 0x31, 0x30, 0x50, 0x31  ; FE8505
	.byte 0x31, 0x50, 0x31, 0x32, 0x50, 0x31, 0x33, 0x50, 0x31, 0x34, 0x50, 0x31, 0x35, 0x50, 0x31, 0x36  ; FE8515
	.byte 0x50, 0x31, 0x37, 0x50, 0x31, 0x38, 0x50, 0x31, 0x39, 0x50, 0x32, 0x30, 0x50, 0x32, 0x31, 0x50  ; FE8525
	.byte 0x32, 0x32, 0x50, 0x32, 0x33, 0x50, 0x32, 0x34, 0x50, 0x32, 0x35, 0x50, 0x32, 0x36, 0x50, 0x32  ; FE8535
	.byte 0x37, 0x50, 0x32, 0x38, 0x50, 0x32, 0x39, 0x50, 0x33, 0x30, 0x50, 0x33, 0x31, 0x50, 0x33, 0x32  ; FE8545
	.byte 0x50, 0x20, 0x31, 0x50, 0x20, 0x31, 0x50, 0x20, 0x31, 0x50, 0x20, 0x31, 0x50, 0x20, 0x31  ; FE8555
; ---------------------------------------------------------------------
; ScreenLeave_NoteEditPartSelect -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x44, i.e. SCREEN ID 0x24 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x44 -> the screen object at
;          0xF402BC, whose +4 slot is `jp 0xFE8564`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   NoteEditPartSelect -- inherited from the +0 ENTER label
;          ShowScreen_NoteEditPartSelect, not from any text this pass read.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing on
;          leave; the slot exists to keep the three-method shape.
; Was `sub_FE8564`.
; ---------------------------------------------------------------------
ScreenLeave_NoteEditPartSelect:
	ret                                                  ; FE8564  0e
ScreenButton_EditPartSelect:
	cp HL,0x001f                                         ; FE8565  db cf 1f 00
	jr gt, .LFE857B                                      ; FE8569  6a 10
	ld XIX,EditPartSelect_ButtonTable                         ; FE856B  44 7c 85 fe 00
	sll hl, 0x02                                         ; FE8570  db ee 02
	extz XHL                                             ; FE8573  eb 12
	add XIX,XHL                                          ; FE8575  eb 84
	ld XIX,(XIX)                                         ; FE8577  a4 24
	call (xix)                                           ; FE8579  b4 e8
.LFE857B:
	ret                                                  ; FE857B  0e
; ---------------------------------------------------------------------
; EditPartSelect_ButtonTable -- 32 pointers, the same shape as 0xFE8077
; Read by: 0xFE8565 -- `cp HL,0x001F / jr ugt / ld XIX,0x00FE857C / ...`,
;          instruction for instruction the same idiom.
; ENTRY COUNT 32 is the reader's bound `cp HL,0x001F`.
; Evidence: all 32 values are inside this module, the lowest 0xFE8621 and
;          the highest 0xFE8772.
; ---------------------------------------------------------------------

EditPartSelect_ButtonTable:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_EditPartSelect
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_EditPartSelect
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_EditPartSelect
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_EditPartSelect
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_EditPartSelect
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_EditPartSelect
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_EditPartSelect
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_EditPartSelect
	on_key	KEY_LcdRow1,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_LcdRow2,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_LcdRow3,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_LcdRow4,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_LcdRow5,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_MinusPlus,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_Code0E,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_Exit,		ExitKey_EditPartSelect
	on_key	KEY_Page,		SoftKeyCol8_EditPartSelect_Nop8
	on_key	KEY_Code11,		SoftKeyCol1_EditPartSelect
	on_key	KEY_Code12,		SoftKeyCol2_EditPartSelect
	on_key	KEY_Code13,		SoftKeyCol3_EditPartSelect
	on_key	KEY_Code14,		SoftKeyCol4_EditPartSelect
	on_key	KEY_Code15,		SoftKeyCol5_EditPartSelect
	on_key	KEY_Code16,		SoftKeyCol6_EditPartSelect
	on_key	KEY_Code17,		SoftKeyCol7_EditPartSelect
	on_key	KEY_Code18,		SoftKeyCol8_EditPartSelect
	on_key	KEY_Code19,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_Code1A,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_NumberPad,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_Code1C,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_Code1D,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_Compare,		ExitKey_EditPartSelect_Nop25
	on_key	KEY_Code1F,		ExitKey_EditPartSelect_Nop25
	keymap_end
; EditPartSelect_PartRefused_Always0(part): `xor A,A / ret` -- every SoftKeyCol<n>_EditPartSelect asks it before EditPartSelect_OpenEditor and
;   opens the editor only on A == 0, so in this build no part is ever refused.
EditPartSelect_PartRefused_Always0:
	xor A,A                                              ; FE85FC  c9 d1
	ret                                                  ; FE85FE  0e
; ---------------------------------------------------------------------
; 17 little-endian words, 1 << p for p = 0..15 and then 0x0001 again.  EditPartSelect_OpenEditor
; indexes it by the part number its SoftKeyCol<n>_EditPartSelect caller passes (`sll bc,1`, word
; load) and keeps the word as that part's bit.  It was decoded as instructions (`normal`, `push SR`,
; `max` ...) until 2026-10-03; the bytes are unchanged.
; ---------------------------------------------------------------------
EditPartSelect_PartBitMask:
	.short 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080  ; FE85FF  [ 0]
	.short 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000  ; FE860F  [ 8]
	.short 0x0001                                                          ; FE861F  [16]
; SoftKeyCol1_EditPartSelect: the 1st of the eight soft keys under the LCD; EditPartSelect_ButtonTable slots 0x00, 0x11.  Slot -> control:
;   wave7_panel_names_round11.CONTROL.
SoftKeyCol1_EditPartSelect:
	bit 0x07,W                                           ; FE8621  c8 33 07
	jr nz, .LFE8638                                      ; FE8624  6e 12
	ldw bc, 0x00                                         ; FE8626  31 00 00
	pushw bc                                             ; FE8629  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE862A  1e cf ff
	popw bc                                              ; FE862D  49
	cp a, 0x00:i3                                          ; FE862E  c9 d8
	jr nz, .LFE8648                                      ; FE8630  6e 16
	call EditPartSelect_OpenEditor                                      ; FE8632  1d 73 87 fe
	jr .LFE8648                                          ; FE8636  68 10
.LFE8638:
	ldw bc, 0x08                                         ; FE8638  31 08 00
	pushw bc                                             ; FE863B  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE863C  1e bd ff
	popw bc                                              ; FE863F  49
	cp a, 0x00:i3                                          ; FE8640  c9 d8
	jr nz, .LFE8648                                      ; FE8642  6e 04
	call EditPartSelect_OpenEditor                                      ; FE8644  1d 73 87 fe
.LFE8648:
	ret                                                  ; FE8648  0e
; SoftKeyCol2_EditPartSelect: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x01; EditPartSelect_ButtonTable slot 0x12.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol2_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8580
	bit 0x07,W                                           ; FE8649  c8 33 07
	jr nz, .LFE8660                                      ; FE864C  6e 12
	ldw bc, 0x01                                         ; FE864E  31 01 00
	pushw bc                                             ; FE8651  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE8652  1e a7 ff
	popw bc                                              ; FE8655  49
	cp a, 0x00:i3                                          ; FE8656  c9 d8
	jr nz, .LFE8670                                      ; FE8658  6e 16
	call EditPartSelect_OpenEditor                                      ; FE865A  1d 73 87 fe
	jr .LFE8670                                          ; FE865E  68 10
.LFE8660:
	ldw bc, 0x09                                         ; FE8660  31 09 00
	pushw bc                                             ; FE8663  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE8664  1e 95 ff
	popw bc                                              ; FE8667  49
	cp a, 0x00:i3                                          ; FE8668  c9 d8
	jr nz, .LFE8670                                      ; FE866A  6e 04
	call EditPartSelect_OpenEditor                                      ; FE866C  1d 73 87 fe
.LFE8670:
	ret                                                  ; FE8670  0e
; SoftKeyCol3_EditPartSelect: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x02; EditPartSelect_ButtonTable slot 0x13.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol3_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8584
	bit 0x07,W                                           ; FE8671  c8 33 07
	jr nz, .LFE8688                                      ; FE8674  6e 12
	ldw bc, 0x02                                         ; FE8676  31 02 00
	pushw bc                                             ; FE8679  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE867A  1e 7f ff
	popw bc                                              ; FE867D  49
	cp a, 0x00:i3                                          ; FE867E  c9 d8
	jr nz, .LFE8698                                      ; FE8680  6e 16
	call EditPartSelect_OpenEditor                                      ; FE8682  1d 73 87 fe
	jr .LFE8698                                          ; FE8686  68 10
.LFE8688:
	ldw bc, 0x0a                                         ; FE8688  31 0a 00
	pushw bc                                             ; FE868B  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE868C  1e 6d ff
	popw bc                                              ; FE868F  49
	cp a, 0x00:i3                                          ; FE8690  c9 d8
	jr nz, .LFE8698                                      ; FE8692  6e 04
	call EditPartSelect_OpenEditor                                      ; FE8694  1d 73 87 fe
.LFE8698:
	ret                                                  ; FE8698  0e
; SoftKeyCol4_EditPartSelect: the 4th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x03; EditPartSelect_ButtonTable slot 0x14.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol4_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8588
	bit 0x07,W                                           ; FE8699  c8 33 07
	jr nz, .LFE86B0                                      ; FE869C  6e 12
	ldw bc, 0x03                                         ; FE869E  31 03 00
	pushw bc                                             ; FE86A1  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE86A2  1e 57 ff
	popw bc                                              ; FE86A5  49
	cp a, 0x00:i3                                          ; FE86A6  c9 d8
	jr nz, .LFE86C0                                      ; FE86A8  6e 16
	call EditPartSelect_OpenEditor                                      ; FE86AA  1d 73 87 fe
	jr .LFE86C0                                          ; FE86AE  68 10
.LFE86B0:
	ldw bc, 0x0b                                         ; FE86B0  31 0b 00
	pushw bc                                             ; FE86B3  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE86B4  1e 45 ff
	popw bc                                              ; FE86B7  49
	cp a, 0x00:i3                                          ; FE86B8  c9 d8
	jr nz, .LFE86C0                                      ; FE86BA  6e 04
	call EditPartSelect_OpenEditor                                      ; FE86BC  1d 73 87 fe
.LFE86C0:
	ret                                                  ; FE86C0  0e
; SoftKeyCol5_EditPartSelect: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x04; EditPartSelect_ButtonTable slot 0x15.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol5_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE858C
	bit 0x07,W                                           ; FE86C1  c8 33 07
	jr nz, .LFE86D8                                      ; FE86C4  6e 12
	ldw bc, 0x04                                         ; FE86C6  31 04 00
	pushw bc                                             ; FE86C9  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE86CA  1e 2f ff
	popw bc                                              ; FE86CD  49
	cp a, 0x00:i3                                          ; FE86CE  c9 d8
	jr nz, .LFE86E8                                      ; FE86D0  6e 16
	call EditPartSelect_OpenEditor                                      ; FE86D2  1d 73 87 fe
	jr .LFE86E8                                          ; FE86D6  68 10
.LFE86D8:
	ldw bc, 0x0c                                         ; FE86D8  31 0c 00
	pushw bc                                             ; FE86DB  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE86DC  1e 1d ff
	popw bc                                              ; FE86DF  49
	cp a, 0x00:i3                                          ; FE86E0  c9 d8
	jr nz, .LFE86E8                                      ; FE86E2  6e 04
	call EditPartSelect_OpenEditor                                      ; FE86E4  1d 73 87 fe
.LFE86E8:
	ret                                                  ; FE86E8  0e
; SoftKeyCol6_EditPartSelect: the 6th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x05; EditPartSelect_ButtonTable slot 0x16.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol6_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8590
	bit 0x07,W                                           ; FE86E9  c8 33 07
	jr nz, .LFE8700                                      ; FE86EC  6e 12
	ldw bc, 0x05                                         ; FE86EE  31 05 00
	pushw bc                                             ; FE86F1  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE86F2  1e 07 ff
	popw bc                                              ; FE86F5  49
	cp a, 0x00:i3                                          ; FE86F6  c9 d8
	jr nz, .LFE8710                                      ; FE86F8  6e 16
	call EditPartSelect_OpenEditor                                      ; FE86FA  1d 73 87 fe
	jr T,.LFE8710                                        ; FE86FE  68 10
.LFE8700:
	ldw bc, 0x0d                                         ; FE8700  31 0d 00
	pushw bc                                             ; FE8703  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE8704  1e f5 fe
	popw bc                                              ; FE8707  49
	cp a, 0x00:i3                                          ; FE8708  c9 d8
	jr nz, .LFE8710                                      ; FE870A  6e 04
	call EditPartSelect_OpenEditor                                      ; FE870C  1d 73 87 fe
.LFE8710:
	ret                                                  ; FE8710  0e
; SoftKeyCol7_EditPartSelect: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x06; EditPartSelect_ButtonTable slot 0x17.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol7_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8594
	bit 0x07,W                                           ; FE8711  c8 33 07
	jr nz, .LFE8728                                      ; FE8714  6e 12
	ldw bc, 0x06                                         ; FE8716  31 06 00
	pushw bc                                             ; FE8719  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE871A  1e df fe
	popw bc                                              ; FE871D  49
	cp a, 0x00:i3                                          ; FE871E  c9 d8
	jr nz, .LFE8738                                      ; FE8720  6e 16
	call EditPartSelect_OpenEditor                                      ; FE8722  1d 73 87 fe
	jr .LFE8738                                          ; FE8726  68 10
.LFE8728:
	ldw bc, 0x0e                                         ; FE8728  31 0e 00
	pushw bc                                             ; FE872B  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE872C  1e cd fe
	popw bc                                              ; FE872F  49
	cp a, 0x00:i3                                          ; FE8730  c9 d8
	jr nz, .LFE8738                                      ; FE8732  6e 04
	call EditPartSelect_OpenEditor                                      ; FE8734  1d 73 87 fe
.LFE8738:
	ret                                                  ; FE8738  0e
; SoftKeyCol8_EditPartSelect: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; EditPartSelect_ButtonTable slot 0x07; EditPartSelect_ButtonTable slot 0x18.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol8_EditPartSelect:   ; entry: named by 2 `.long` operands, first at 0xFE8598
	bit 0x07,W                                           ; FE8739  c8 33 07
	jr nz, .LFE8750                                      ; FE873C  6e 12
	ldw bc, 0x07                                         ; FE873E  31 07 00
	pushw bc                                             ; FE8741  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE8742  1e b7 fe
	popw bc                                              ; FE8745  49
	cp a, 0x00:i3                                          ; FE8746  c9 d8
	jr nz, .LFE8760                                      ; FE8748  6e 16
	call EditPartSelect_OpenEditor                                      ; FE874A  1d 73 87 fe
	jr .LFE8760                                          ; FE874E  68 10
.LFE8750:
	ldw bc, 0x0f                                         ; FE8750  31 0f 00
	pushw bc                                             ; FE8753  29
	calr EditPartSelect_PartRefused_Always0                                      ; FE8754  1e a5 fe
	popw bc                                              ; FE8757  49
	cp a, 0x00:i3                                          ; FE8758  c9 d8
	jr nz, .LFE8760                                      ; FE875A  6e 04
	call EditPartSelect_OpenEditor                                      ; FE875C  1d 73 87 fe
.LFE8760:
	ret                                                  ; FE8760  0e
SoftKeyCol8_EditPartSelect_Nop8:   ; entry: named by 8 `.long` operands, first at 0xFE859C
	ret                                                  ; FE8761  0e
; ExitKey_EditPartSelect: the EXIT key; EditPartSelect_ButtonTable slot 0x0F.  Slot -> control: wave7_panel_names_round11.CONTROL.
ExitKey_EditPartSelect:   ; entry: named by 1 `.long` operand, first at 0xFE85B8
	bit 0x07,W                                           ; FE8762  c8 33 07
	jr nz, .LFE876E                                      ; FE8765  6e 07
	ldw (UI_Request:16), 0x801a                              ; FE8767  f1 70 20 02 1a 80
	ret                                                  ; FE876D  0e
.LFE876E:
	calr ExitKey_Sequencer_Nop                                          ; FE876E  1e 75 fa
	ret                                                  ; FE8771  0e
ExitKey_EditPartSelect_Nop25:   ; entry: named by 7 `.long` operands, first at 0xFE85E0
	ret                                                  ; FE8772  0e
; EditPartSelect_OpenEditor(BC = part 1..16): (0x601F00) = part, (0x601F01) = the long for that part from the word table
;   after EditPartSelect_PartRefused_Always0; UI_Request = 0x8028 (DRUM EDIT, screen 0x28) when EditScreen_Mode bit 0 is set, else 0x8025
;   (NOTE EDIT, screen 0x25); then EditPartSelect_SelectUiPart.
EditPartSelect_OpenEditor:
	ld (EditScreen_Part:24), bc                                ; FE8773  f2 00 1f 60 51
	ld XIX,EditPartSelect_PartBitMask                                    ; FE8778  44 ff 85 fe 00
	sll bc, 0x01                                         ; FE877D  d9 ee 01
	xor XWA,XWA                                          ; FE8780  e8 d0
	ld	wa, (xix+bc)                                 ; FE8782  d3 07 f0 e4 20
	ld (0x1336:16), xwa                                 ; FE8787  f1 36 13 60
	bit	0, (EditScreen_Mode:24)                             ; FE878B  f2 70 1f 60 c8
	jr z, .LFE87A5                                       ; FE8790  66 13
	ldw (UI_Request:16), 0x8028                              ; FE8792  f1 70 20 02 28 80
	ld xwa, (0x1336:16)                                 ; FE8798  e1 36 13 20
	ld (EditScreen_PartMask:24), xwa                               ; FE879C  f2 01 1f 60 60
	calr EditPartSelect_SelectUiPart                                            ; FE87A1  1e 39 00
	ret                                                  ; FE87A4  0e
.LFE87A5:
	ldw (UI_Request:16), 0x8025                              ; FE87A5  f1 70 20 02 25 80
	ld xwa, (0x1336:16)                                 ; FE87AB  e1 36 13 20
	ld (EditScreen_PartMask:24), xwa                               ; FE87AF  f2 01 1f 60 60
	calr EditPartSelect_SelectUiPart                                            ; FE87B4  1e 26 00
	ret                                                  ; FE87B7  0e
; ---------------------------------------------------------------------
; IndexMap_FE87B8 -- 37 bytes: 0x00..0x1F, then five 0x00
; Read by: 0xFE8811 `ld XIX,0x00FE87B8` then `ld A,(XIX+IY)` (0xFE8816),
;          where IY is itself a byte fetched from a RAM table two
;          instructions earlier; the result is stored to (0x2250).
;          So it is a TRANSLATION table indexed by another table's output.
; ENTRY COUNT 37 is the EXTENT -- the reader has no bound, and code
;          resumes at 0xFE87DD.  The first 32 entries are the identity.
; ★ See PartLabels_FE84F5: that table is also 37 entries with its last
;          five aliased onto entry 0, which is what these five 0x00 do.
; Unknown:  what the index means, and therefore what the identity is FOR.
; ---------------------------------------------------------------------

IndexMap_FE87B8:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FE87B8
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FE87C8
	.byte 0x00, 0x00, 0x00, 0x00, 0x00                                        ; FE87D8
; EditPartSelect_SelectUiPart: (0x0DB5) bit 0 cleared; the first part set in the mask (0x1336) (up to 17) maps through 0x603422 and
;   IndexMap_FE87B8 to UI_PartIndex; (0x0DB5) bit 0 set; a Queue2E00 record (W 0xFF, DE 0x1090).  Called by
;   EditPartSelect_OpenEditor.
EditPartSelect_SelectUiPart:
	and	(0x0db5:16), 0xfe                            ; FE87DD  c1 b5 0d 3c fe
	xor BC,BC                                            ; FE87E2  d9 d1
	xor WA,WA                                            ; FE87E4  d8 d0
	ld xwa, (0x1336:16)                                 ; FE87E6  e1 36 13 20
.LFE87EA:
	.byte 0xd7, 0x3e, 0x98                               ; FE87EA  d7 3e 98   ld QHL3,WA
	ld A,C                                               ; FE87ED  cb 89
	scf                                                  ; FE87EF  11
	.byte 0xd7, 0x3e, 0x2a                               ; FE87F0  d7 3e 2a   xorcf A,QHL3
	.byte 0xd7, 0x3e, 0x88                               ; FE87F3  d7 3e 88   ld WA,QHL3
	jr c, .LFE87FA                                       ; FE87F6  67 02
; (sub_FE87F8 removed 2026-10-04: no code names it and the line above falls through into it -- part of EditPartSelect_SelectUiPart;
;  notes/prom_a_stray_label_removal.py)
	jr .LFE8801                                          ; FE87F8  68 07
.LFE87FA:
	inc 1,C                                              ; FE87FA  cb 61
	cp C,0x11                                            ; FE87FC  cb cf 11
	jr c, .LFE87EA                                       ; FE87FF  67 e9
.LFE8801:
	ld XHL,BStore_TrackToPart                                    ; FE8801  43 22 34 60 00
	ld IY,BC                                             ; FE8806  d9 8d
	ld	a, (xhl+iy)                                  ; FE8808  c3 07 ec f4 21
	xor W,W                                              ; FE880D  c8 d0
	ld IY,WA                                             ; FE880F  d8 8d
	ld XIX,IndexMap_FE87B8                               ; FE8811  44 b8 87 fe 00
	ld	a, (xix+iy)                                  ; FE8816  c3 07 f0 f4 21
	ld (UI_PartIndex:16), a                                   ; FE881B  f1 50 22 41
	or	(0x0db5:16), 0x01                            ; FE881F  c1 b5 0d 3e 01
	ld w, 0xff:opc                                          ; FE8824  20 ff
	ldw de, 0x1090                                       ; FE8826  32 90 10
	call T_Queue2E00_AppendRegs                          ; FE8829  1d 3c 0f f4
	jr .LFE882F                                          ; FE882D  68 00
.LFE882F:
	ret                                                  ; FE882F  0e
; EditScreen_PartKitIsUserOrExt: the edited part's entry in 0x603422 selects a record (RecordPtrs_RAM76A2); A = 0 when its kit code (+1) is
;   0x28, 0x29 or 0x30 -- the User 1 / User 2 / Ext codes of KitCategoryLegend_SelectByKitCode -- else 0xFF.
;   Called by EditScreen_EnterDrumEdit.
EditScreen_PartKitIsUserOrExt:
	ld XIX,BStore_TrackToPart                                    ; FE8830  44 22 34 60 00
	ld a, (EditScreen_Part:24)                                 ; FE8835  c2 00 1f 60 21
	ld	a, (xix+a)                                   ; FE883A  c3 03 f0 e0 21
	ld XIY,RecordPtrs_RAM76A2                            ; FE883F  45 30 b3 fe 00
	xor W,W                                              ; FE8844  c8 d0
	sll wa, 0x02                                         ; FE8846  d8 ee 02
	ld	xix, (xiy+a)                                 ; FE8849  e3 03 f4 e0 24
	ld A,(XIX+0x01)                                      ; FE884E  8c 01 21
	cp A,0x28                                            ; FE8851  c9 cf 28
	jr z, .LFE8862                                       ; FE8854  66 0c
	cp A,0x29                                            ; FE8856  c9 cf 29
	jr z, .LFE8862                                       ; FE8859  66 07
	cp A,0x30                                            ; FE885B  c9 cf 30
	jr z, .LFE8862                                       ; FE885E  66 02
	jr nz, .LFE8865                                      ; FE8860  6e 03
.LFE8862:
	xor A,A                                              ; FE8862  c9 d1
	ret                                                  ; FE8864  0e
.LFE8865:
	ld a, 0xff:opc                                          ; FE8865  21 ff
	ret                                                  ; FE8867  0e
; EditScreen_EnterDrumEdit: unless refused by EditScreen_PartKitIsUserOrExt, set EditScreen_Mode bit 0 (DRUM EDIT), (0x601F4D) = (0x601F51),
;   (0x601F49) = 10, (0x601F75) = 7, (0x601F76) = 8; then the shared tail.
EditScreen_EnterDrumEdit:
	bit	0, (0x601f77:24)                             ; FE8868  f2 77 1f 60 c8
	jr z, .LFE8871                                       ; FE886D  66 02
	jr .LFE8882                                          ; FE886F  68 11
.LFE8871:
	calr EditScreen_PartKitIsUserOrExt                                      ; FE8871  1e bc ff
	cp a, 0x00:i3                                          ; FE8874  c9 d8
	jr nz, .LFE8882                                      ; FE8876  6e 0a
	set	0, (0x601f77:24)                             ; FE8878  f2 77 1f 60 b8
	call T_DrumSoundNames_FetchNext                                        ; FE887D  1d ac 2f f4
	ret                                                  ; FE8881  0e
.LFE8882:
	call T_CallbackQueue_ResetAndRestartTask2            ; FE8882  1d 80 2e f4
	ldw (EditField_NewNoteLength:24), 0x0a                             ; FE8886  f2 49 1f 60 02 0a 00
	ld wa, (0x601f51:24)                                ; FE888D  d2 51 1f 60 20
	ld (EditField_Inc:24), wa                                ; FE8892  f2 4d 1f 60 50
	set	0, (EditScreen_Mode:24)                             ; FE8897  f2 70 1f 60 b8
	ld (EditMeasure_Beats:24), 0x07                             ; FE889C  f2 75 1f 60 00 07
	ld (0x601f76:24), 0x08                             ; FE88A2  f2 76 1f 60 00 08
	jr .LFE88D3                                          ; FE88A8  68 29
; EditScreen_EnterNoteEdit: clear EditScreen_Mode bit 0 (NOTE EDIT), (0x601F4D) = (0x601F4F), (0x601F49) = (0x601F4B), (0x601F75) = 10,
;   (0x601F76) = 11; then the tail shared with EditScreen_EnterDrumEdit (FINDINGS-prom_a-screen-module.md section 8).
EditScreen_EnterNoteEdit:
	call T_CallbackQueue_ResetAndRestartTask2            ; FE88AA  1d 80 2e f4
	ld wa, (0x601f4f:24)                                ; FE88AE  d2 4f 1f 60 20
	ld (EditField_Inc:24), wa                                ; FE88B3  f2 4d 1f 60 50
	ld wa, (0x601f4b:24)                                ; FE88B8  d2 4b 1f 60 20
	ld (EditField_NewNoteLength:24), wa                                ; FE88BD  f2 49 1f 60 50
	res	0, (EditScreen_Mode:24)                             ; FE88C2  f2 70 1f 60 b0
	ld (EditMeasure_Beats:24), 0x0a                             ; FE88C7  f2 75 1f 60 00 0a
	ld (0x601f76:24), 0x0b                             ; FE88CD  f2 76 1f 60 00 0b
.LFE88D3:
	cpw	(EditField_Inc:24), 0x0000                        ; FE88D3  d2 4d 1f 60 3f 00 00
	jr nz, .LFE88E3                                      ; FE88DA  6e 07
	ldw (EditField_Inc:24), 0x30                             ; FE88DC  f2 4d 1f 60 02 30 00
.LFE88E3:
	ld a, (UI_ScreenLatch:16)                                   ; FE88E3  c1 7a 20 21
	cp	a, (UI_ScreenLatch_Previous:16)                               ; FE88E7  c1 7b 20 f1
	jr nz, .LFE8912                                      ; FE88EB  6e 25
	ld a, (UI_ScreenId:16)                                   ; FE88ED  c1 7c 20 21
	cp	a, (UI_ScreenId_Previous:16)                               ; FE88F1  c1 7d 20 f1
	jr z, .LFE8912                                       ; FE88F5  66 1b
	bit	4, (0x34d1:16)                               ; FE88F7  f1 d1 34 cc
	jr z, .LFE8912                                       ; FE88FB  66 15
	ld (UI_Request:16), 0x01                                 ; FE88FD  f1 70 20 00 01
	ld (UI_Request_Hi:16), 0x02                                 ; FE8902  f1 71 20 00 02
	and	(0x34d1:16), 0xef                            ; FE8907  c1 d1 34 3c ef
	and	(0x3614:16), 0xfe                            ; FE890C  c1 14 36 3c fe
	ret                                                  ; FE8911  0e
.LFE8912:
	cp	(TransportA_BeatsPerBar:24), 0x00                          ; FE8912  c2 00 50 60 3f 00
	jr nz, .LFE8920                                      ; FE8918  6e 06
	ld (TransportA_BeatsPerBar:24), 0x04                             ; FE891A  f2 00 50 60 00 04
.LFE8920:
	or	(0x3614:16), 0x01                            ; FE8920  c1 14 36 3e 01
	or	(0x0db5:16), 0x01                            ; FE8925  c1 b5 0d 3e 01
	call T_Transport_StopAllRunning                                        ; FE892A  1d ac 09 f4
	or	(0x34bb:16), 0x04                            ; FE892E  c1 bb 34 3e 04
	or	(UI_RequestBits:16), 0x01                            ; FE8933  c1 75 20 3e 01
	ld (EditScreen_ActionTimer:24), 0x00                             ; FE8938  f2 58 1f 60 00 00
	ld xwa, (EditScreen_PartMask:24)                               ; FE893E  e2 01 1f 60 20
	ld (0x1336:16), xwa                                 ; FE8943  f1 36 13 60
	ld (0x133a:16), xwa                                 ; FE8947  f1 3a 13 60
	cp	(UI_ScreenId_Previous:16), 0x26                            ; FE894B  c1 7d 20 3f 26
	jrl z, .LFE8A1F                                      ; FE8950  76 cc 00
	cp	(UI_ScreenId_Previous:16), 0x29                            ; FE8953  c1 7d 20 3f 29
	jrl z, .LFE8A1F                                      ; FE8958  76 c4 00
	cp	(UI_ScreenId_Previous:16), 0x24                            ; FE895B  c1 7d 20 3f 24
	jr z, .LFE8980                                       ; FE8960  66 1e
	cp	(UI_ScreenId_Previous:16), 0x27                            ; FE8962  c1 7d 20 3f 27
	jr z, .LFE8980                                       ; FE8967  66 17
	bit	0, (EditScreen_Mode:24)                             ; FE8969  f2 70 1f 60 c8
	jrl z, .LFE8A7E                                      ; FE896E  76 0d 01
	bit	0, (0x601f77:24)                             ; FE8971  f2 77 1f 60 c8
	jrl z, .LFE8A7E                                      ; FE8976  76 05 01
	res	0, (0x601f77:24)                             ; FE8979  f2 77 1f 60 b0
	jr .LFE898F                                          ; FE897E  68 0f
.LFE8980:
	or	(0x20a9:16), 0x01                            ; FE8980  c1 a9 20 3e 01
	ld (PanelDial_UpButton:16), 0x00                                 ; FE8985  f1 9c 20 00 00
	ld (PanelDial_DownButton:16), 0x80                                 ; FE898A  f1 9b 20 00 80
.LFE898F:
	xor XWA,XWA                                          ; FE898F  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE8991  c2 00 1f 60 21
	mul A,0x03                                           ; FE8996  c9 08 03
	ld XIX,0x00603500                                    ; FE8999  44 00 35 60 00
	add XIX,XWA                                          ; FE899E  e8 84
	bit 7,(XIX)                                          ; FE89A0  b4 cf
	jrl nz, .LFE8A1F                                     ; FE89A2  7e 7a 00
	cpw	(BStore_FreeCount:24), 0x0000                        ; FE89A5  d2 ba 34 60 3f 00 00
	jrl z, .LFE8A54                                      ; FE89AC  76 a5 00
	push XIX                                             ; FE89AF  3c
	call T_BStore_AllocBlock_B_Veneer                                        ; FE89B0  1d 88 0c f4
	ld HL,IX                                             ; FE89B4  dc 8b
	calr BStore_GetHeapBase                                          ; FE89B6  1e 7b f9
	extz XIX                                             ; FE89B9  ec 12
	dec 1,XIX                                            ; FE89BB  ec 69
	sll xix, 0x08                                        ; FE89BD  ec ee 08
	add XIY,XIX                                          ; FE89C0  ec 85
	set 7,(XIY)                                          ; FE89C2  b5 bf
	add XIY,0x00000001                                   ; FE89C4  ed c8 01 00 00 00
	ldw	(xiy), 0x0000                                ; FE89CA  b5 02 00 00
	add XIY,0x00000002                                   ; FE89CE  ed c8 02 00 00 00
	ldw	(xiy), 0xffff                                ; FE89D4  b5 02 ff ff
	pop XIX                                              ; FE89D8  5c
	set 7,(XIX)                                          ; FE89D9  b4 bf
	add XIX,0x00000001                                   ; FE89DB  ec c8 01 00 00 00
	ld (XIX),HL                                          ; FE89E1  b4 53
	ld XIX,0x0060347e                                    ; FE89E3  44 7e 34 60 00
	xor XWA,XWA                                          ; FE89E8  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE89EA  c2 00 1f 60 21
	sll xwa, 0x01                                        ; FE89EF  e8 ee 01
	add XIX,XWA                                          ; FE89F2  e8 84
	ld (XIX),HL                                          ; FE89F4  b4 53
	ld XIX,0x006034a0                                    ; FE89F6  44 a0 34 60 00
	xor XWA,XWA                                          ; FE89FB  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE89FD  c2 00 1f 60 21
	add XIX,XWA                                          ; FE8A02  e8 84
	ld (XIX),0x05                                        ; FE8A04  b4 00 05
	ld (BStore_CursorBlock:16), hl                                  ; FE8A07  f1 5c 34 53
	ldw (BStore_CursorOffset:16), 0x05                                ; FE8A0B  f1 5e 34 02 05 00
	calr EditScreen_AppendBeatMarker                                      ; FE8A11  1e 75 01
	addw	(BStore_CursorOffset:16), 0x0001                          ; FE8A14  d1 5e 34 38 01 00
	calr EditScreen_AppendBeatMarker                                      ; FE8A1A  1e 6c 01
	jr .LFE8A28                                          ; FE8A1D  68 09
.LFE8A1F:
	ld wa, (0x3552:16)                                 ; FE8A1F  d1 52 35 20
	ld (EditCursor_Measure:24), wa                                ; FE8A23  f2 3f 1f 60 50
.LFE8A28:
	calr EditScreen_EndAudition                                          ; FE8A28  1e 24 1b
	call T_SeqBufRing_Discard                                        ; FE8A2B  1d 10 0a f4
	call T_TimedEventRing_Discard                                        ; FE8A2F  1d 14 0a f4
	calr NoteEdit_ClearHeldKeyNotes                                          ; FE8A33  1e 12 07
	calr NoteEdit_ClearHeldKeys                                      ; FE8A36  1e aa 01
	calr EditScreen_OpenCursorMeasure                                          ; FE8A39  1e 6d 04
	cp	(BStore_ErrorCode:16), 0x00                            ; FE8A3C  c1 4a 0d 3f 00
	jr z, .LFE8A58                                       ; FE8A41  66 15
	ldw (EditCursor_Measure:24), 0x01                             ; FE8A43  f2 3f 1f 60 02 01 00
	calr EditScreen_OpenCursorMeasure                                          ; FE8A4A  1e 5c 04
	cp	(BStore_ErrorCode:16), 0x00                            ; FE8A4D  c1 4a 0d 3f 00
	jr z, .LFE8A58                                       ; FE8A52  66 04
.LFE8A54:
	calr EditScreen_FlagMemoryFull                                      ; FE8A54  1e 7d 01
	ret                                                  ; FE8A57  0e
.LFE8A58:
	ldw (EditCursor_TickInMeasure:24), 0x00                             ; FE8A58  f2 54 1f 60 02 00 00
	calr BStore_CursorSlot_RestoreMark                                      ; FE8A5F  1e 96 01
	calr DrumEdit_CursorNoteFromRow                                          ; FE8A62  1e 52 25
	calr EditPos_SeekShownNoteAtTickZero                                      ; FE8A65  1e 4c 02
	calr EditPos_LoadTickIfShownNote                                      ; FE8A68  1e 30 00
	calr EditScreen_SelectEventAtCursor                                          ; FE8A6B  1e a3 04
	ldw (EditCursor_Beat:24), 0x00                             ; FE8A6E  f2 41 1f 60 02 00 00
	ld (EditCursor_Tick:24), 0x00                             ; FE8A75  f2 43 1f 60 00 00
	calr EditScreen_BuildBeatTable                                      ; FE8A7B  1e 6b 00
.LFE8A7E:
	calr NoteRouting_RebuildForSong_Call                                          ; FE8A7E  1e bf f5
	xor C,C                                              ; FE8A81  cb d3
	ld a, 0x0c:opc                                          ; FE8A83  21 0c
	swi 7                                                ; FE8A85  ff
	ld a, 0x10:opc                                          ; FE8A86  21 10
	swi 7                                                ; FE8A88  ff
	calr EditScreen_PaintLayer0                                          ; FE8A89  1e 20 6e
	calr EditScreen_PaintLayer1                                          ; FE8A8C  1e 2f 6e
	calr EditScreen_PaintLayer2                                          ; FE8A8F  1e 38 6e
	ld c, 0x07:opc                                          ; FE8A92  23 07
	ld a, 0x0c:opc                                          ; FE8A94  21 0c
	swi 7                                                ; FE8A96  ff
	set	0, (0xc6:8)                                   ; FE8A97  f0 c6 b8
	ret                                                  ; FE8A9A  0e
; EditPos_LoadTickIfShownNote: EditPos_LoadEventTick when the event at the cursor is a note-on DrumEdit_IsOtherNote passes.
EditPos_LoadTickIfShownNote:
	call BStoreCursor_ReadByte                                        ; FE8A9B  1d 32 22 ff
	and A,0xf0                                           ; FE8A9F  c9 cc f0
	cp A,0x90                                            ; FE8AA2  c9 cf 90
	jr z, .LFE8AA8                                       ; FE8AA5  66 01
	ret                                                  ; FE8AA7  0e
.LFE8AA8:
	calr DrumEdit_IsOtherNote                                      ; FE8AA8  1e 08 00
	cp a, 0x00:i3                                          ; FE8AAB  c9 d8
	jr nz, .LFE8AB2                                      ; FE8AAD  6e 03
	calr EditPos_LoadEventTick                                          ; FE8AAF  1e 9d 1d
.LFE8AB2:
	ret                                                  ; FE8AB2  0e
; DrumEdit_IsOtherNote: in DRUM EDIT (EditScreen_Mode bit 0) reads the note two bytes into the event at the cursor (cursor restored)
;   and returns 0xFF when it differs from (0x601F44); 0 when it matches, and always 0 in NOTE EDIT.
DrumEdit_IsOtherNote:
	bit	0, (EditScreen_Mode:24)                             ; FE8AB3  f2 70 1f 60 c8
	jr z, .LFE8AE3                                       ; FE8AB8  66 29
	ld wa, (BStore_CursorBlock:16)                                 ; FE8ABA  d1 5c 34 20
	ld bc, (BStore_CursorOffset:16)                                 ; FE8ABE  d1 5e 34 21
	pushw wa                                             ; FE8AC2  28
	pushw bc                                             ; FE8AC3  29
	call BStoreCursor_Step                                        ; FE8AC4  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE8AC8  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8ACC  1d 32 22 ff
	ld E,A                                               ; FE8AD0  c9 8d
	popw bc                                              ; FE8AD2  49
	popw wa                                              ; FE8AD3  48
	ld (BStore_CursorBlock:16), wa                                  ; FE8AD4  f1 5c 34 50
	ld (BStore_CursorOffset:16), bc                                  ; FE8AD8  f1 5e 34 51
	cp	e, (EditCursor_Note:24)                             ; FE8ADC  c2 44 1f 60 f5
	jr nz, .LFE8AE6                                      ; FE8AE1  6e 03
.LFE8AE3:
	xor A,A                                              ; FE8AE3  c9 d1
	ret                                                  ; FE8AE5  0e
.LFE8AE6:
	ld a, 0xff:opc                                          ; FE8AE6  21 ff
	ret                                                  ; FE8AE8  0e
; EditScreen_BuildBeatTable: for the (0x601F76) measures from EditCursor_Measure, seeks each one (T_BStore_SeekChainToMeasure) and fills the byte table at
;   0x601F5F that EditCursor_BeatsInMeasure reads; the cursor is saved and restored around it.
EditScreen_BuildBeatTable:
	calr BStore_CursorSlot_Save                                      ; FE8AE9  1e 02 02
	ld wa, (EditCursor_Measure:24)                                ; FE8AEC  d2 3f 1f 60 20
	ld (EditScreen_FirstMeasure:24), wa                                ; FE8AF1  f2 5d 1f 60 50
	ld (0x0c90:16), wa                                  ; FE8AF6  f1 90 0c 50
	ld XIX,EditScreen_BeatTable                                    ; FE8AFA  44 5f 1f 60 00
	xor E,E                                              ; FE8AFF  cd d5
.LFE8B01:
	pushw de                                             ; FE8B01  2a
	push XIX                                             ; FE8B02  3c
	calr EditScreen_FindMasterTrack                                          ; FE8B03  1e 06 04
	pop XIX                                              ; FE8B06  5c
	popw de                                              ; FE8B07  4a
	ld a, (EditScreen_Part:24)                                 ; FE8B08  c2 00 1f 60 21
	add A,0x01                                           ; FE8B0D  c9 c8 01
	bit	2, (0x0c8a:16)                               ; FE8B10  f1 8a 0c ca
	jr z, .LFE8B18                                       ; FE8B14  66 02
	ld A,W                                               ; FE8B16  c8 89
.LFE8B18:
	pushw de                                             ; FE8B18  2a
	push XIX                                             ; FE8B19  3c
	call T_BStore_SeekChainToMeasure                                        ; FE8B1A  1d 5c 0c f4
	pop XIX                                              ; FE8B1E  5c
	popw de                                              ; FE8B1F  4a
	cp	(BStore_ErrorCode:16), 0x00                            ; FE8B20  c1 4a 0d 3f 00
	jr nz, .LFE8B5B                                      ; FE8B25  6e 34
	add E,0x01                                           ; FE8B27  cd c8 01
	ld (XIX),E                                           ; FE8B2A  b4 45
	jr .LFE8B37                                          ; FE8B2C  68 09
.LFE8B2E:
	cp a, 0x01:i3                                          ; FE8B2E  c9 d9
	jr z, .LFE8B53                                       ; FE8B30  66 21
	ld (XIX),0x00                                        ; FE8B32  b4 00 00
	dec 1,A                                              ; FE8B35  c9 69
.LFE8B37:
	add XIX,0x00000001                                   ; FE8B37  ec c8 01 00 00 00
	ld XHL,EditScreen_BeatTable                                    ; FE8B3D  43 5f 1f 60 00
	xor XBC,XBC                                          ; FE8B42  e9 d1
	ld c, (0x601f76:24)                                 ; FE8B44  c2 76 1f 60 23
	add XHL,XBC                                          ; FE8B49  e9 83
	cp XIX,XHL                                           ; FE8B4B  eb f4
	jr c, .LFE8B2E                                       ; FE8B4D  67 df
.LFE8B4F:
	calr BStore_CursorSlot_Restore                                      ; FE8B4F  1e c3 01
	ret                                                  ; FE8B52  0e
.LFE8B53:
	addw	(0x0c90:16), 0x0001                          ; FE8B53  d1 90 0c 38 01 00
	jr .LFE8B01                                          ; FE8B59  68 a6
.LFE8B5B:
	ld a, (0x0d1c:16)                                   ; FE8B5B  c1 1c 0d 21
	add E,0x01                                           ; FE8B5F  cd c8 01
	ld (XIX),E                                           ; FE8B62  b4 45
	jr .LFE8B6F                                          ; FE8B64  68 09
.LFE8B66:
	cp a, 0x01:i3                                          ; FE8B66  c9 d9
	jr z, .LFE8B5B                                       ; FE8B68  66 f1
	ld (XIX),0x00                                        ; FE8B6A  b4 00 00
	dec 1,A                                              ; FE8B6D  c9 69
.LFE8B6F:
	add XIX,0x00000001                                   ; FE8B6F  ec c8 01 00 00 00
	ld XHL,EditScreen_BeatTable                                    ; FE8B75  43 5f 1f 60 00
	xor XBC,XBC                                          ; FE8B7A  e9 d1
	ld c, (0x601f76:24)                                 ; FE8B7C  c2 76 1f 60 23
	add XHL,XBC                                          ; FE8B81  e9 83
	cp XIX,XHL                                           ; FE8B83  eb f4
	jr c, .LFE8B66                                       ; FE8B85  67 df
	jr .LFE8B4F                                          ; FE8B87  68 c6
; EditScreen_AppendBeatMarker: EditScreen_SaveTrackCursor, then one 0x81 byte (from 0x601F37) appended to chain (0x601F00) + 1 with
;   BStore_AppendBytes.
EditScreen_AppendBeatMarker:
	calr EditScreen_SaveTrackCursor                                      ; FE8B89  1e 1c 00
	ld XIY,0x00601f37                                    ; FE8B8C  45 37 1f 60 00
	ld (XIY),0x81                                        ; FE8B91  b5 00 81
	ld a, (EditScreen_Part:24)                                 ; FE8B94  c2 00 1f 60 21
	add A,0x01                                           ; FE8B99  c9 c8 01
	ld w, 0x01:opc                                          ; FE8B9C  20 01
	ld (BStore_ErrorCode:16), 0x00                                 ; FE8B9E  f1 4a 0d 00 00
	call T_BStore_AppendBytes_Veneer                     ; FE8BA3  1d 94 28 f4
	ret                                                  ; FE8BA7  0e
; EditScreen_SaveTrackCursor: BStore_CursorBlock -> word 0x3460[(0x601F00)], BStore_CursorOffset -> byte 0x3482[(0x601F00)]: the edited
;   part's saved block-store cursor.
EditScreen_SaveTrackCursor:
	xor HL,HL                                            ; FE8BA8  db d3
	ld l, (EditScreen_Part:24)                                 ; FE8BAA  c2 00 1f 60 27
	sll l, 0x01                                          ; FE8BAF  cf ee 01
	ld wa, (BStore_CursorBlock:16)                                 ; FE8BB2  d1 5c 34 20
	ld XIX,0x00003460                                    ; FE8BB6  44 60 34 00 00
	ld	(xix+hl), wa                                 ; FE8BBB  f3 07 f0 ec 50
	ld l, (EditScreen_Part:24)                                 ; FE8BC0  c2 00 1f 60 27
	ld wa, (BStore_CursorOffset:16)                                 ; FE8BC5  d1 5e 34 20
	ld XIX,0x00003482                                    ; FE8BC9  44 82 34 00 00
	ld	(xix+hl), a                                  ; FE8BCE  f3 07 f0 ec 41
	ret                                                  ; FE8BD3  0e
; EditScreen_FlagMemoryFull: Clears (0x20A9) bit 0, sets (0x34D1) bits 5+4: prom_b Seq_ShowMemoryFullOnRequest then shows status 0x0F /
;   request 0x40AB, the song-memory-full pair (prom_b twin SeqRecord_AllocTakeChains). Every edit-screen caller reaches it only on a
;   BStore error, zero free blocks or a failed chain extension. Basis: callers + body + prom_b twin.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
EditScreen_FlagMemoryFull:
	and	(0x20a9:16), 0xfe                            ; FE8BD4  c1 a9 20 3c fe
	call T_Var34D1_SetBits20                                        ; FE8BD9  1d 08 0a f4
	or	(0x34d1:16), 0x10                            ; FE8BDD  c1 d1 34 3e 10
	ret                                                  ; FE8BE2  0e
; NoteEdit_ClearHeldKeys: clears the flag byte of all 8 three-byte NoteEdit_HeldKeys slots; called once, from EditScreen_EnterNoteEdit.
;   Basis: body + caller.
NoteEdit_ClearHeldKeys:
	ld c, 0x08:opc                                          ; FE8BE3  23 08
	ld XIX,NoteEdit_HeldKeys                                    ; FE8BE5  44 1c 1f 60 00
	xor A,A                                              ; FE8BEA  c9 d1
.LFE8BEC:
	ld (XIX),A                                           ; FE8BEC  b4 41
	add XIX,0x00000003                                   ; FE8BEE  ec c8 03 00 00 00
	djnz8 c, .LFE8BEC                                    ; FE8BF4  cb 1c f5
	ret                                                  ; FE8BF7  0e
; BStore_CursorSlot_RestoreMark: the same restore from the 0x601F0F slot, which the code at 0xFE8EB9 fills (a mark).
BStore_CursorSlot_RestoreMark:
	ld wa, (EditMeasure_StartBeat:24)                                ; FE8BF8  d2 0f 1f 60 20
	ld (EditPos_Beat:24), wa                                ; FE8BFD  f2 05 1f 60 50
	ld a, (EditMeasure_StartTick:24)                                 ; FE8C02  c2 11 1f 60 21
	ld (EditPos_Tick:24), a                                 ; FE8C07  f2 07 1f 60 41
	ld wa, (EditMeasure_MarkBlock:24)                                ; FE8C0C  d2 12 1f 60 20
	ld (BStore_CursorBlock:16), wa                                  ; FE8C11  f1 5c 34 50
	ld wa, (EditMeasure_MarkOffset:24)                                ; FE8C15  d2 14 1f 60 20
	ld (BStore_CursorOffset:16), wa                                  ; FE8C1A  f1 5e 34 50
	ret                                                  ; FE8C1E  0e
; ScreenLeave_DrumEdit: the +4 LEAVE method of the screen object for screen id 0x28 -- PanelScreen_VtableTable entry 0x48
;   (ViewB entry 0x28) points at the thunk triple starting at T_EditScreen_EnterDrumEdit, and slot T_ScreenLeave_DrumEdit jumps here.
ScreenLeave_DrumEdit:
	ld wa, (EditField_Inc:24)                                ; FE8C1F  d2 4d 1f 60 20
	ld (0x601f51:24), wa                                ; FE8C24  f2 51 1f 60 50
	cp	(UI_ScreenLatch:16), 0x28                            ; FE8C29  c1 7a 20 3f 28
	jr z, .LFE8C38                                       ; FE8C2E  66 08
	calr Queue2E00_AppendRegs_0_255_4240                                      ; FE8C30  1e 64 00
	or	(0x34d4:16), 0x10                            ; FE8C33  c1 d4 34 3e 10
.LFE8C38:
	jr .LFE8C5D                                          ; FE8C38  68 23
; ScreenLeave_NoteEdit: the +4 LEAVE method of the screen object for screen id 0x25 -- PanelScreen_VtableTable entry 0x45
;   (ViewB entry 0x25) points at the thunk triple starting at T_EditScreen_EnterNoteEdit, and slot T_ScreenLeave_NoteEdit jumps here.
ScreenLeave_NoteEdit:
	cp	(UI_ScreenLatch:16), 0x25                            ; FE8C3A  c1 7a 20 3f 25
	jr z, .LFE8C49                                       ; FE8C3F  66 08
	calr Queue2E00_AppendRegs_0_255_4240                                      ; FE8C41  1e 53 00
	or	(0x34d4:16), 0x10                            ; FE8C44  c1 d4 34 3e 10
.LFE8C49:
	ld wa, (EditField_Inc:24)                                ; FE8C49  d2 4d 1f 60 20
	ld (0x601f4f:24), wa                                ; FE8C4E  f2 4f 1f 60 50
	ld wa, (EditField_NewNoteLength:24)                                ; FE8C53  d2 49 1f 60 20
	ld (0x601f4b:24), wa                                ; FE8C58  f2 4b 1f 60 50
.LFE8C5D:
	and	(0x34bb:16), 0xfb                            ; FE8C5D  c1 bb 34 3c fb
	ld (EditScreen_ActionTimer:24), 0x00                             ; FE8C62  f2 58 1f 60 00 00
	ld xwa, (0x360c:16)                                 ; FE8C68  e1 0c 36 20
	or	xwa, (0x1336:16)                             ; FE8C6C  e1 36 13 e0
	ld (0x360c:16), xwa                                 ; FE8C70  f1 0c 36 60
	calr NoteEdit_RestorePlayingTrackMask                                      ; FE8C74  1e 30 00
	xor XWA,XWA                                          ; FE8C77  e8 d0
	ld (0x1336:16), xwa                                 ; FE8C79  f1 36 13 60
	ld (0x133a:16), xwa                                 ; FE8C7D  f1 3a 13 60
	ld wa, (EditCursor_Measure:24)                                ; FE8C81  d2 3f 1f 60 20
	ld (0x3552:16), wa                                  ; FE8C86  f1 52 35 50
	and	(UI_RequestBits:16), 0xfe                            ; FE8C8A  c1 75 20 3c fe
	call NoteRouting_RebuildForSong_Call                                      ; FE8C8F  1d 40 80 fe
	res	0, (0xc6:8)                                   ; FE8C93  f0 c6 b0
	ret                                                  ; FE8C96  0e
Queue2E00_AppendRegs_0_255_4240:
	ld a, 0x00:opc                                          ; FE8C97  21 00
	ld (UI_PartIndex:16), a                                   ; FE8C99  f1 50 22 41
	ld w, 0xff:opc                                          ; FE8C9D  20 ff
	ldw de, 0x1090                                       ; FE8C9F  32 90 10
	call T_Queue2E00_AppendRegs                          ; FE8CA2  1d 3c 0f f4
	ret                                                  ; FE8CA6  0e
; NoteEdit_RestorePlayingTrackMask: Playing-track mask (0x60341E) := (0x360C), its saved copy, XWA preserved --
;   Seq_RestorePlayingTrackMask without the T_NoteRouting_RebuildForSong. ScreenLeave_NoteEdit runs it right after OR-
;   ing (0x1336) into (0x360C), and calls NoteRouting_RebuildForSong_Call itself a few lines later. Basis: caller +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave9_c9.json)
NoteEdit_RestorePlayingTrackMask:
	push XWA                                             ; FE8CA7  38
	ld xwa, (0x360c:16)                                 ; FE8CA8  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; FE8CAC  f2 1e 34 60 60
	pop XWA                                              ; FE8CB1  58
	ret                                                  ; FE8CB2  0e
T_F402D8_Nop:
	ret                                                  ; FE8CB3  0e
; EditPos_SeekShownNoteAtTickZero: within the beat (to the next 0x81 / 0x82), stops on the first note-on DrumEdit_IsOtherNote passes whose tick
;   byte (+1) is 0, backed onto its tag; otherwise the cursor is restored.
EditPos_SeekShownNoteAtTickZero:
	calr BStore_CursorSlot_Save                                      ; FE8CB4  1e 37 00
.LFE8CB7:
	call BStoreCursor_ReadByte                                        ; FE8CB7  1d 32 22 ff
	cp A,0x81                                            ; FE8CBB  c9 cf 81
	jr z, .LFE8CEA                                       ; FE8CBE  66 2a
	cp A,0x82                                            ; FE8CC0  c9 cf 82
	jr z, .LFE8CEA                                       ; FE8CC3  66 25
	and A,0xf0                                           ; FE8CC5  c9 cc f0
	cp A,0x90                                            ; FE8CC8  c9 cf 90
	jr nz, .LFE8CE4                                      ; FE8CCB  6e 17
	calr DrumEdit_IsOtherNote                                      ; FE8CCD  1e e3 fd
	cp a, 0x00:i3                                          ; FE8CD0  c9 d8
	jr nz, .LFE8CE4                                      ; FE8CD2  6e 10
	call BStoreCursor_Step                                        ; FE8CD4  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8CD8  1d 32 22 ff
	cp a, 0x00:i3                                          ; FE8CDC  c9 d8
	jr nz, .LFE8CEA                                      ; FE8CDE  6e 0a
	calr BStoreCursor_SeekPrevTag                                          ; FE8CE0  1e 08 f6
	ret                                                  ; FE8CE3  0e
.LFE8CE4:
	call BStoreCursor_SeekNextTag                                        ; FE8CE4  1d f6 21 ff
	jr .LFE8CB7                                          ; FE8CE8  68 cd
.LFE8CEA:
	calr BStore_CursorSlot_Restore                                      ; FE8CEA  1e 28 00
	ret                                                  ; FE8CED  0e
; BStore_CursorSlot_Save: copies (0x601F05..0x601F07), BStore_CursorBlock and BStore_CursorOffset to the save slot at 0x601F08..0x601F0E.
BStore_CursorSlot_Save:
	ld wa, (EditPos_Beat:24)                                ; FE8CEE  d2 05 1f 60 20
	ld (0x601f08:24), wa                                ; FE8CF3  f2 08 1f 60 50
	ld a, (EditPos_Tick:24)                                 ; FE8CF8  c2 07 1f 60 21
	ld (0x601f0a:24), a                                 ; FE8CFD  f2 0a 1f 60 41
	ld wa, (BStore_CursorBlock:16)                                 ; FE8D02  d1 5c 34 20
	ld (0x601f0b:24), wa                                ; FE8D06  f2 0b 1f 60 50
	ld wa, (BStore_CursorOffset:16)                                 ; FE8D0B  d1 5e 34 20
	ld (0x601f0d:24), wa                                ; FE8D0F  f2 0d 1f 60 50
	ret                                                  ; FE8D14  0e
; BStore_CursorSlot_Restore: the reverse, from the 0x601F08 slot back to (0x601F05..07), BStore_CursorBlock, BStore_CursorOffset.
BStore_CursorSlot_Restore:
	ld wa, (0x601f08:24)                                ; FE8D15  d2 08 1f 60 20
	ld (EditPos_Beat:24), wa                                ; FE8D1A  f2 05 1f 60 50
	ld a, (0x601f0a:24)                                 ; FE8D1F  c2 0a 1f 60 21
	ld (EditPos_Tick:24), a                                 ; FE8D24  f2 07 1f 60 41
	ld wa, (0x601f0b:24)                                ; FE8D29  d2 0b 1f 60 20
	ld (BStore_CursorBlock:16), wa                                  ; FE8D2E  f1 5c 34 50
	ld wa, (0x601f0d:24)                                ; FE8D32  d2 0d 1f 60 20
	ld (BStore_CursorOffset:16), wa                                  ; FE8D37  f1 5e 34 50
	ret                                                  ; FE8D3B  0e
; NoteEdit_DrawKeyboardRuler: NOTE EDIT: layer 2, ScreenDispatch_FE8D6B[(0x601F53)], (0x601F53) being the ruler's
;   scroll position 0..9 that NoteEdit_LcdKeyRow2 / _LcdKeyRow3 step; DRUM EDIT: only 0xFEAFB7.
NoteEdit_DrawKeyboardRuler:
	bit	0, (EditScreen_Mode:24)                             ; FE8D3C  f2 70 1f 60 c8
	jr nz, .LFE8D5E                                      ; FE8D41  6e 1b
	ld (LCD_CurrentLayer:16), 0x02                                 ; FE8D43  f1 40 25 00 02
	ld XIX,ScreenDispatch_FE8D6B                         ; FE8D48  44 6b 8d fe 00
	xor XWA,XWA                                          ; FE8D4D  e8 d0
	ld a, (NoteEdit_RulerPosition:24)                                 ; FE8D4F  c2 53 1f 60 21
	sll wa, 0x02                                         ; FE8D54  d8 ee 02
	add XIX,XWA                                          ; FE8D57  e8 84
	ld XIX,(XIX)                                         ; FE8D59  a4 24
	call (xix)                                           ; FE8D5B  b4 e8
	ret                                                  ; FE8D5D  0e
.LFE8D5E:
	calr DrumEdit_CursorNoteFromRow                                          ; FE8D5E  1e 56 22
	calr EditScreen_EraseLeftColumn_Layer1                                          ; FE8D61  1e 09 6b
	calr EditScreen_HighlightCursorRow                                          ; FE8D64  1e d6 22
	calr DrumEdit_RedrawRowList                                          ; FE8D67  1e ff 22
	ret                                                  ; FE8D6A  0e
; ---------------------------------------------------------------------
; ScreenDispatch_FE8D6B -- 12 pointers, indexed by (0x601F53)
; Read by: 0xFE8D48 -- `ld XIX,0x00FE8D6B / xor XWA,XWA /
;          ld A,(0x601F53) / sll WA,2 / add XIX,XWA / ld XIX,(XIX) /
;          call (XIX)`.
; ⚠ ENTRY COUNT 12 is the EXTENT, not a bound: there is NO compare on the
;          index, so a value above 11 would run off the end of the table.
;          12 is where the next object starts (0xFE8D9B, an instruction
;          that loads the display list at 0xFE8E31).  That is weaker than
;          a bound and is stated as such.
; Evidence: all 12 values are inside this module, the lowest 0xFE8D9B and
;          the highest 0xFE8E22.
; ---------------------------------------------------------------------

ScreenDispatch_FE8D6B:
	.long KeyboardRuler_DrawStrip0                                 ; FE8D6B  [  0]
	.long KeyboardRuler_DrawStrip1                                 ; FE8D6F  [  1]
	.long KeyboardRuler_DrawStrip2                                 ; FE8D73  [  2]
	.long KeyboardRuler_DrawStrip3                                 ; FE8D77  [  3]
	.long KeyboardRuler_DrawStrip4                                 ; FE8D7B  [  4]
	.long KeyboardRuler_DrawStrip5                                 ; FE8D7F  [  5]
	.long KeyboardRuler_DrawStrip6                                 ; FE8D83  [  6]
	.long KeyboardRuler_DrawStrip7                                 ; FE8D87  [  7]
	.long KeyboardRuler_DrawStrip8                                 ; FE8D8B  [  8]
	.long KeyboardRuler_DrawStrip9                                 ; FE8D8F  [  9]
	.long KeyboardRuler_DrawStrip9                                 ; FE8D93  [ 10]
	.long KeyboardRuler_DrawStrip9                                 ; FE8D97  [ 11]
; KeyboardRuler_DrawStrip0: NOTE EDIT's keyboard ruler at scroll position 0 --
;   ScreenDispatch_FE8D6B[0]; draws KeyboardRuler_Strip0 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip0:   ; entry: named by 1 `.long` operand, first at 0xFE8D6B
	ld XIY,KeyboardRuler_DrawStrip0_DL                            ; FE8D9B  45 31 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip1_DL                            ; FE8DA0  44 3d 8e fe 00
	call T_DisplayList_Run                               ; FE8DA5  1d f0 17 f4
	ret                                                  ; FE8DA9  0e
; KeyboardRuler_DrawStrip1: NOTE EDIT's keyboard ruler at scroll position 1 --
;   ScreenDispatch_FE8D6B[1]; draws KeyboardRuler_Strip1 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip1:   ; entry: named by 1 `.long` operand, first at 0xFE8D6F
	ld XIY,KeyboardRuler_DrawStrip1_DL                            ; FE8DAA  45 3d 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip2_DL                            ; FE8DAF  44 49 8e fe 00
	call T_DisplayList_Run                               ; FE8DB4  1d f0 17 f4
	ret                                                  ; FE8DB8  0e
; KeyboardRuler_DrawStrip2: NOTE EDIT's keyboard ruler at scroll position 2 --
;   ScreenDispatch_FE8D6B[2]; draws KeyboardRuler_Strip2 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip2:   ; entry: named by 1 `.long` operand, first at 0xFE8D73
	ld XIY,KeyboardRuler_DrawStrip2_DL                            ; FE8DB9  45 49 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip3_DL                            ; FE8DBE  44 55 8e fe 00
	call T_DisplayList_Run                               ; FE8DC3  1d f0 17 f4
	ret                                                  ; FE8DC7  0e
; KeyboardRuler_DrawStrip3: NOTE EDIT's keyboard ruler at scroll position 3 --
;   ScreenDispatch_FE8D6B[3]; draws KeyboardRuler_Strip3 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip3:   ; entry: named by 1 `.long` operand, first at 0xFE8D77
	ld XIY,KeyboardRuler_DrawStrip3_DL                            ; FE8DC8  45 55 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip4_DL                            ; FE8DCD  44 61 8e fe 00
	call T_DisplayList_Run                               ; FE8DD2  1d f0 17 f4
	ret                                                  ; FE8DD6  0e
; KeyboardRuler_DrawStrip4: NOTE EDIT's keyboard ruler at scroll position 4 --
;   ScreenDispatch_FE8D6B[4]; draws KeyboardRuler_Strip4 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip4:   ; entry: named by 1 `.long` operand, first at 0xFE8D7B
	ld XIY,KeyboardRuler_DrawStrip4_DL                            ; FE8DD7  45 61 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip5_DL                            ; FE8DDC  44 6d 8e fe 00
	call T_DisplayList_Run                               ; FE8DE1  1d f0 17 f4
	ret                                                  ; FE8DE5  0e
; KeyboardRuler_DrawStrip5: NOTE EDIT's keyboard ruler at scroll position 5 --
;   ScreenDispatch_FE8D6B[5]; draws KeyboardRuler_Strip5 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip5:   ; entry: named by 1 `.long` operand, first at 0xFE8D7F
	ld XIY,KeyboardRuler_DrawStrip5_DL                            ; FE8DE6  45 6d 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip6_DL                            ; FE8DEB  44 79 8e fe 00
	call T_DisplayList_Run                               ; FE8DF0  1d f0 17 f4
	ret                                                  ; FE8DF4  0e
; KeyboardRuler_DrawStrip6: NOTE EDIT's keyboard ruler at scroll position 6 --
;   ScreenDispatch_FE8D6B[6]; draws KeyboardRuler_Strip6 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip6:   ; entry: named by 1 `.long` operand, first at 0xFE8D83
	ld XIY,KeyboardRuler_DrawStrip6_DL                            ; FE8DF5  45 79 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip7_DL                            ; FE8DFA  44 85 8e fe 00
	call T_DisplayList_Run                               ; FE8DFF  1d f0 17 f4
	ret                                                  ; FE8E03  0e
; KeyboardRuler_DrawStrip7: NOTE EDIT's keyboard ruler at scroll position 7 --
;   ScreenDispatch_FE8D6B[7]; draws KeyboardRuler_Strip7 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip7:   ; entry: named by 1 `.long` operand, first at 0xFE8D87
	ld XIY,KeyboardRuler_DrawStrip7_DL                            ; FE8E04  45 85 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip8_DL                            ; FE8E09  44 91 8e fe 00
	call T_DisplayList_Run                               ; FE8E0E  1d f0 17 f4
	ret                                                  ; FE8E12  0e
; KeyboardRuler_DrawStrip8: NOTE EDIT's keyboard ruler at scroll position 8 --
;   ScreenDispatch_FE8D6B[8]; draws KeyboardRuler_Strip8 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip8:   ; entry: named by 1 `.long` operand, first at 0xFE8D8B
	ld XIY,KeyboardRuler_DrawStrip8_DL                            ; FE8E13  45 91 8e fe 00
	ld XIX,KeyboardRuler_DrawStrip9_DL                            ; FE8E18  44 9d 8e fe 00
	call T_DisplayList_Run                               ; FE8E1D  1d f0 17 f4
	ret                                                  ; FE8E21  0e
; KeyboardRuler_DrawStrip9: NOTE EDIT's keyboard ruler at scroll position 9 --
;   ScreenDispatch_FE8D6B[9] (and [10], [11]); draws KeyboardRuler_Strip9 (notes/prom_a_note_edit_keyboard_ruler.py).
KeyboardRuler_DrawStrip9:   ; entry: named by 3 `.long` operands, first at 0xFE8D8F
	ld XIY,KeyboardRuler_DrawStrip9_DL                            ; FE8E22  45 9d 8e fe 00
	ld XIX,EditScreen_OpenCursorMeasure                                    ; FE8E27  44 a9 8e fe 00
	call T_DisplayList_Run                               ; FE8E2C  1d f0 17 f4
	ret                                                  ; FE8E30  0e

; KeyboardRuler_DrawStrip0_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E31 and land exactly on 0xFE8E3D.
KeyboardRuler_DrawStrip0_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip0 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip0, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip1_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E3D and land exactly on 0xFE8E49.
KeyboardRuler_DrawStrip1_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip1, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip2_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E49 and land exactly on 0xFE8E55.
KeyboardRuler_DrawStrip2_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip2, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip3_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E55 and land exactly on 0xFE8E61.
KeyboardRuler_DrawStrip3_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip3 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip3, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip4_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E61 and land exactly on 0xFE8E6D.
KeyboardRuler_DrawStrip4_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip4 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip4, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip5_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E6D and land exactly on 0xFE8E79.
KeyboardRuler_DrawStrip5_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip5 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip5, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip6_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E79 and land exactly on 0xFE8E85.
KeyboardRuler_DrawStrip6_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip6 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip6, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip7_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E85 and land exactly on 0xFE8E91.
KeyboardRuler_DrawStrip7_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip7 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip7, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip8_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E91 and land exactly on 0xFE8E9D.
KeyboardRuler_DrawStrip8_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip8, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows

; KeyboardRuler_DrawStrip9_DL -- 1 record(s), 12 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFE8E9D and land exactly on 0xFE8EA9.
KeyboardRuler_DrawStrip9_DL:
; ; drawn (start operand) by KeyboardRuler_DrawStrip9 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_bitmap	bitmap=KeyboardRuler_Strip9, x=0, y=41, w=16, h=129	; bitmap (16x129, 258 bytes); IX VRAM byte offset, BC columns, HL rows
; EditScreen_OpenCursorMeasure: EditScreen_SeekCursorMeasure; when it found the measure: EditMeasure_StartBeat = IX, EditMeasure_StartTick = 0,
;   and the mark (0x601F12) = BStore_CursorBlock, (0x601F14) = IY -- what BStore_CursorSlot_RestoreMark returns to.
EditScreen_OpenCursorMeasure:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE8EA9  f1 4a 0d 00 00
	calr EditScreen_SeekCursorMeasure                                      ; FE8EAE  1e 42 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE8EB1  c1 4a 0d 3f 00
	jr z, .LFE8EB9                                       ; FE8EB6  66 01
	ret                                                  ; FE8EB8  0e
.LFE8EB9:
	ld (EditMeasure_StartBeat:24), ix                                ; FE8EB9  f2 0f 1f 60 54
	ld (EditMeasure_StartTick:24), 0x00                             ; FE8EBE  f2 11 1f 60 00 00
	ld wa, (BStore_CursorBlock:16)                                 ; FE8EC4  d1 5c 34 20
	ld (EditMeasure_MarkBlock:24), wa                                ; FE8EC8  f2 12 1f 60 50
	ld (EditMeasure_MarkOffset:24), iy                                ; FE8ECD  f2 14 1f 60 55
	ret                                                  ; FE8ED2  0e
; EditScreen_SeekCursorMeasureStart: EditScreen_SeekCursorMeasure; when found: EditPos_Beat = IX, EditPos_Tick = 0, BStore_CursorOffset = IY.
EditScreen_SeekCursorMeasureStart:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE8ED3  f1 4a 0d 00 00
	calr EditScreen_SeekCursorMeasure                                      ; FE8ED8  1e 18 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE8EDB  c1 4a 0d 3f 00
	jr z, .LFE8EE3                                       ; FE8EE0  66 01
	ret                                                  ; FE8EE2  0e
.LFE8EE3:
	ld (EditPos_Beat:24), ix                                ; FE8EE3  f2 05 1f 60 54
	ld (EditPos_Tick:24), 0x00                             ; FE8EE8  f2 07 1f 60 00 00
	ld (BStore_CursorOffset:16), iy                                  ; FE8EEE  f1 5e 34 55
	ret                                                  ; FE8EF2  0e
; EditScreen_SeekCursorMeasure: (0x0C90) = EditCursor_Measure, EditScreen_FindMasterTrack (T_SeqMasterTrack_UpdateActiveFromSavedMask), then T_BStore_SeekChainToMeasure on chain EditScreen_Part + 1: prom_b's
;   seek to that measure, which returns IX = its first beat and IY = the offset.
EditScreen_SeekCursorMeasure:
	ld wa, (EditCursor_Measure:24)                                ; FE8EF3  d2 3f 1f 60 20
	ld (0x0c90:16), wa                                  ; FE8EF8  f1 90 0c 50
	calr EditScreen_FindMasterTrack                                      ; FE8EFC  1e 0d 00
	ld a, (EditScreen_Part:24)                                 ; FE8EFF  c2 00 1f 60 21
	add A,0x01                                           ; FE8F04  c9 c8 01
	call T_BStore_SeekChainToMeasure                                        ; FE8F07  1d 5c 0c f4
	ret                                                  ; FE8F0B  0e
; EditScreen_FindMasterTrack: T_SeqMasterTrack_UpdateActiveFromSavedMask -> prom_b SeqMasterTrack_UpdateActiveFromSavedMask: W := 1 + the track mapped to part 0x20 (the master track)
;   and (0x0E51)/(0x0E4F) bit 0/(0x0C8A) bit 2 set, when that track's bit is set in the saved playing-track mask
;   (0x360C)/(0x360E), (0x3752) = 1 and its chain exists; else all cleared and W = 0. The edit screens run it before
;   seeking a measure. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
EditScreen_FindMasterTrack:
	call T_SeqMasterTrack_UpdateActiveFromSavedMask                                        ; FE8F0C  1d 70 0a f4
	ret                                                  ; FE8F10  0e
; EditScreen_SelectEventAtCursor: (0x601F5B) bit 0 = 0; when the event at the cursor sits on EditCursor_TickInMeasure (EditScreen_PositionAndMeasureStartTicks) and is a
;   note-on that DrumEdit_IsOtherNote passes: bit 0 = 1, EditCursor_Note = +2, (0x601F45) = +3, EditField_Length =
;   (+5 & 0x7F) x 0x60 + (+4 & 0x7F), (0x601F6F) = the note, NoteEdit_ScrollRulerToNote.
EditScreen_SelectEventAtCursor:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FE8F11  c2 5b 1f 60 3c fe
	calr EditScreen_PositionAndMeasureStartTicks                                          ; FE8F17  1e 0e 17
	sub XWA,XBC                                          ; FE8F1A  e9 a0
	xor XBC,XBC                                          ; FE8F1C  e9 d1
	ld bc, (EditCursor_TickInMeasure:24)                                ; FE8F1E  d2 54 1f 60 21
	cp XWA,XBC                                           ; FE8F23  e9 f0
	jr nz, .LFE8F96                                      ; FE8F25  6e 6f
	call BStoreCursor_ReadByte                                        ; FE8F27  1d 32 22 ff
	and A,0xf0                                           ; FE8F2B  c9 cc f0
	cp A,0x90                                            ; FE8F2E  c9 cf 90
	jr z, .LFE8F34                                       ; FE8F31  66 01
	ret                                                  ; FE8F33  0e
.LFE8F34:
	calr DrumEdit_IsOtherNote                                          ; FE8F34  1e 7c fb
	cp a, 0x00:i3                                          ; FE8F37  c9 d8
	jr nz, .LFE8F96                                      ; FE8F39  6e 5b
	or	(EditScreen_CursorFlags:24), 0x01                          ; FE8F3B  c2 5b 1f 60 3e 01
	call BStoreCursor_Step                                        ; FE8F41  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE8F45  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8F49  1d 32 22 ff
	ld (EditCursor_Note:24), a                                 ; FE8F4D  f2 44 1f 60 41
	call BStoreCursor_Step                                        ; FE8F52  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8F56  1d 32 22 ff
	ld (EditField_EventVelocity:24), a                                 ; FE8F5A  f2 45 1f 60 41
	call BStoreCursor_Step                                        ; FE8F5F  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8F63  1d 32 22 ff
	xor BC,BC                                            ; FE8F67  d9 d1
	ld C,A                                               ; FE8F69  c9 8b
	pushw bc                                             ; FE8F6B  29
	call BStoreCursor_Step                                        ; FE8F6C  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE8F70  1d 32 22 ff
	popw bc                                              ; FE8F74  49
	and BC,0x007f                                        ; FE8F75  d9 cc 7f 00
	and A,0x7f                                           ; FE8F79  c9 cc 7f
	mul A,0x60                                           ; FE8F7C  c9 08 60
	add WA,BC                                            ; FE8F7F  d9 80
	ld (EditField_Length:24), wa                                ; FE8F81  f2 47 1f 60 50
	calr BStoreCursor_SeekPrevTag                                          ; FE8F86  1e 62 f3
	ld a, (EditCursor_Note:24)                                 ; FE8F89  c2 44 1f 60 21
	ld (0x601f6f:24), a                                 ; FE8F8E  f2 6f 1f 60 41
	calr NoteEdit_ScrollRulerToNote                                      ; FE8F93  1e 01 00
.LFE8F96:
	ret                                                  ; FE8F96  0e
; NoteEdit_ScrollRulerToNote: NOTE EDIT only: moves (0x601F53), 0..9, one step at a time until (0x601F6F) is inside the range EditScreen_VisibleNoteRange
;   returns (A low, W high); when it moved, NoteEdit_DrawKeyboardRuler and the edit area redrawn.
NoteEdit_ScrollRulerToNote:
	bit	0, (EditScreen_Mode:24)                             ; FE8F97  f2 70 1f 60 c8
	jr nz, .LFE8FDC                                      ; FE8F9C  6e 3e
	ld a, (NoteEdit_RulerPosition:24)                                 ; FE8F9E  c2 53 1f 60 21
	ld (0x601f6e:24), a                                 ; FE8FA3  f2 6e 1f 60 41
.LFE8FA8:
	calr EditScreen_VisibleNoteRange                                          ; FE8FA8  1e 09 70
	ld h, (0x601f6f:24)                                 ; FE8FAB  c2 6f 1f 60 26
	cp H,A                                               ; FE8FB0  c9 f6
	jr c, .LFE8FED                                       ; FE8FB2  67 39
	cp H,W                                               ; FE8FB4  c8 f6
	jr ugt, .LFE8FDD                                     ; FE8FB6  6b 25
	ld a, (0x601f6e:24)                                 ; FE8FB8  c2 6e 1f 60 21
	cp	a, (NoteEdit_RulerPosition:24)                             ; FE8FBD  c2 53 1f 60 f1
	jr z, .LFE8FDC                                       ; FE8FC2  66 18
	calr NoteEdit_DrawKeyboardRuler                                          ; FE8FC4  1e 75 fd
	ld (EditScreen_ActionTimer:24), 0x81                             ; FE8FC7  f2 58 1f 60 00 81
	ld (EditScreen_ActionIndex:24), 0x04                             ; FE8FCD  f2 59 1f 60 00 04
	calr EditScreen_EraseEditArea_Layer0                                          ; FE8FD3  1e fc 67
	calr EditScreen_EraseEditArea_Layer1                                          ; FE8FD6  1e 80 68
	calr EditScreen_DrawVisibleNotes                                          ; FE8FD9  1e e3 6e
.LFE8FDC:
	ret                                                  ; FE8FDC  0e
.LFE8FDD:
	cp	(NoteEdit_RulerPosition:24), 0x09                          ; FE8FDD  c2 53 1f 60 3f 09
	jr nc, .LFE8FDC                                      ; FE8FE3  6f f7
	add	(NoteEdit_RulerPosition:24), 0x01                          ; FE8FE5  c2 53 1f 60 38 01
	jr .LFE8FA8                                          ; FE8FEB  68 bb
.LFE8FED:
	cp	(NoteEdit_RulerPosition:24), 0x00                          ; FE8FED  c2 53 1f 60 3f 00
	jr ule, .LFE8FDC                                     ; FE8FF3  63 e7
	sub	(NoteEdit_RulerPosition:24), 0x01                  ; FE8FF5  c2 53 1f 60 3a 01
	jr .LFE8FA8                                          ; FE8FFB  68 ab
; NoteEdit_TakeKeyboardInput: on screens 0x25 / 0x28, with the edit area idle and free blocks: drains the sequencer input ring
;   (T_SeqBufRing_Get); a note-on (0x9n) with velocity -> NoteEdit_HoldKey, velocity 0 -> NoteEdit_ReleaseKey; when
;   no key is held any more (NoteEdit_AnyKeyHeld): selection cleared, NoteEdit_ScrollRulerToNote,
;   NoteEdit_EnterHeldNotes, EditScreen_AppendMissingBeatMarkers, redraw.
NoteEdit_TakeKeyboardInput:
	call T_SeqBufRing_IsEmpty                            ; FE8FFD  1d 90 1d f4
	cp wa, 0x00:i3                                         ; FE9001  d8 d8
	jr nz, .LFE9006                                      ; FE9003  6e 01
	ret                                                  ; FE9005  0e
.LFE9006:
	ld a, (UI_ScreenId:16)                                   ; FE9006  c1 7c 20 21
	cp A,0x25                                            ; FE900A  c9 cf 25
	jr z, .LFE9015                                       ; FE900D  66 06
	cp A,0x28                                            ; FE900F  c9 cf 28
	jr z, .LFE9015                                       ; FE9012  66 01
	ret                                                  ; FE9014  0e
.LFE9015:
	bit	7, (EditScreen_ActionTimer:24)                             ; FE9015  f2 58 1f 60 cf
	jr z, .LFE901D                                       ; FE901A  66 01
	ret                                                  ; FE901C  0e
.LFE901D:
	cpw	(BStore_FreeCount:24), 0x0000                        ; FE901D  d2 ba 34 60 3f 00 00
	jrl z, .LFE90AE                                      ; FE9024  76 87 00
.LFE9027:
	call T_SeqBufRing_IsEmpty                            ; FE9027  1d 90 1d f4
	cp wa, 0x00:i3                                         ; FE902B  d8 d8
	jr nz, .LFE9030                                      ; FE902D  6e 01
	ret                                                  ; FE902F  0e
.LFE9030:
	call T_SeqBufRing_Get                                ; FE9030  1d 84 1d f4
	bit 0x07,A                                           ; FE9034  c9 33 07
	jr z, .LFE9027                                       ; FE9037  66 ee
	and A,0xf0                                           ; FE9039  c9 cc f0
	cp A,0x90                                            ; FE903C  c9 cf 90
	jr z, .LFE9043                                       ; FE903F  66 02
	jr .LFE9027                                          ; FE9041  68 e4
.LFE9043:
	call T_SeqBufRing_Get                                ; FE9043  1d 84 1d f4
	call T_SeqBufRing_Get                                ; FE9047  1d 84 1d f4
	ld (NoteEdit_InputNote:24), a                                 ; FE904B  f2 34 1f 60 41
	call T_SeqBufRing_Get                                ; FE9050  1d 84 1d f4
	ld (NoteEdit_InputVelocity:24), a                                 ; FE9054  f2 35 1f 60 41
	call T_SeqBufRing_Get                                ; FE9059  1d 84 1d f4
	ld a, (NoteEdit_InputVelocity:24)                                 ; FE905D  c2 35 1f 60 21
	cp a, 0x00:i3                                          ; FE9062  c9 d8
	jr z, .LFE906B                                       ; FE9064  66 05
	calr NoteEdit_HoldKey                                      ; FE9066  1e 4f 00
	jr .LFE9027                                          ; FE9069  68 bc
.LFE906B:
	calr NoteEdit_ReleaseKey                                      ; FE906B  1e 8a 00
	cp A,0xff                                            ; FE906E  c9 cf ff
	jr z, .LFE9027                                       ; FE9071  66 b4
	calr NoteEdit_AnyKeyHeld                                      ; FE9073  1e b5 00
	cp a, 0x00:i3                                          ; FE9076  c9 d8
	jr z, .LFE907C                                       ; FE9078  66 02
	jr .LFE9027                                          ; FE907A  68 ab
.LFE907C:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FE907C  c2 5b 1f 60 3c fe
	calr EditScreen_EraseEditArea_Layer1                                          ; FE9082  1e d4 67
	ld a, (NoteEdit_InputNote:24)                                 ; FE9085  c2 34 1f 60 21
	ld (0x601f6f:24), a                                 ; FE908A  f2 6f 1f 60 41
	calr NoteEdit_ScrollRulerToNote                                      ; FE908F  1e 05 ff
	calr NoteEdit_EnterHeldNotes                                      ; FE9092  1e c8 00
	calr EditScreen_AppendMissingBeatMarkers                                          ; FE9095  1e 47 07
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9098  c1 4a 0d 3f 00
	jr nz, .LFE90AE                                      ; FE909D  6e 0f
	calr EditScreen_StepCursorAfterEntry                                      ; FE909F  1e ee 01
	calr NoteEdit_ClearHeldKeyNotes                                      ; FE90A2  1e a3 00
	calr EditScreen_EraseEditArea_Layer0                                          ; FE90A5  1e 2a 67
	calr EditScreen_DrawVisibleNotes                                          ; FE90A8  1e 14 6e
	jrl .LFE9027                                         ; FE90AB  78 79 ff
.LFE90AE:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FE90AE  c2 5b 1f 60 3c fe
	calr EditScreen_FlagMemoryFull                                          ; FE90B4  1e 1d fb
	ret                                                  ; FE90B7  0e
; NoteEdit_HoldKey: the first free slot of 0x601F1C (8 x {flag 0x80, note, velocity}; 1 slot in DRUM EDIT) takes (0x601F34) /
;   (0x601F35).
NoteEdit_HoldKey:
	ld c, 0x08:opc                                          ; FE90B8  23 08
	bit	0, (EditScreen_Mode:24)                             ; FE90BA  f2 70 1f 60 c8
	jr z, .LFE90C3                                       ; FE90BF  66 02
	ld c, 0x01:opc                                          ; FE90C1  23 01
.LFE90C3:
	ld XIX,NoteEdit_HeldKeys                                    ; FE90C3  44 1c 1f 60 00
.LFE90C8:
	ld A,(XIX)                                           ; FE90C8  84 21
	bit 0x07,A                                           ; FE90CA  c9 33 07
	jr nz, .LFE90EE                                      ; FE90CD  6e 1f
	or	(xix), 0x80                                  ; FE90CF  84 3e 80
	add XIX,0x00000001                                   ; FE90D2  ec c8 01 00 00 00
	ld a, (NoteEdit_InputNote:24)                                 ; FE90D8  c2 34 1f 60 21
	ld (XIX),A                                           ; FE90DD  b4 41
	add XIX,0x00000001                                   ; FE90DF  ec c8 01 00 00 00
	ld a, (NoteEdit_InputVelocity:24)                                 ; FE90E5  c2 35 1f 60 21
	ld (XIX),A                                           ; FE90EA  b4 41
	jr .LFE90F7                                          ; FE90EC  68 09
.LFE90EE:
	add XIX,0x00000003                                   ; FE90EE  ec c8 03 00 00 00
	djnz8 c, .LFE90C8                                    ; FE90F4  cb 1c d1
.LFE90F7:
	ret                                                  ; FE90F7  0e
; NoteEdit_ReleaseKey: clears the flag of the slot holding note (0x601F34); A = 0xFF when none does.
NoteEdit_ReleaseKey:
	ld c, 0x08:opc                                          ; FE90F8  23 08
	bit	0, (EditScreen_Mode:24)                             ; FE90FA  f2 70 1f 60 c8
	jr z, .LFE9103                                       ; FE90FF  66 02
	ld c, 0x01:opc                                          ; FE9101  23 01
.LFE9103:
	ld XIX,NoteEdit_HeldKeys                                    ; FE9103  44 1c 1f 60 00
.LFE9108:
	bit 7,(XIX)                                          ; FE9108  b4 cf
	jr z, .LFE9119                                       ; FE910A  66 0d
	inc 1,XIX                                            ; FE910C  ec 61
	ld A,(XIX)                                           ; FE910E  84 21
	cp	a, (NoteEdit_InputNote:24)                             ; FE9110  c2 34 1f 60 f1
	jr z, .LFE9125                                       ; FE9115  66 0e
	dec 1,XIX                                            ; FE9117  ec 69
.LFE9119:
	add XIX,0x00000003                                   ; FE9119  ec c8 03 00 00 00
	djnz8 c, .LFE9108                                    ; FE911F  cb 1c e6
	ld a, 0xff:opc                                          ; FE9122  21 ff
	ret                                                  ; FE9124  0e
.LFE9125:
	dec 1,XIX                                            ; FE9125  ec 69
	and (XIX),0x7f                                       ; FE9127  84 3c 7f
	ret                                                  ; FE912A  0e
; NoteEdit_AnyKeyHeld: A = 0xFF when any of the 8 slots at 0x601F1C is flagged, else 0.
NoteEdit_AnyKeyHeld:
	ld c, 0x08:opc                                          ; FE912B  23 08
	ld XIX,NoteEdit_HeldKeys                                    ; FE912D  44 1c 1f 60 00
.LFE9132:
	ld A,(XIX)                                           ; FE9132  84 21
	bit 0x07,A                                           ; FE9134  c9 33 07
	jr z, .LFE913C                                       ; FE9137  66 03
	ld a, 0xff:opc                                          ; FE9139  21 ff
	ret                                                  ; FE913B  0e
.LFE913C:
	add XIX,0x00000003                                   ; FE913C  ec c8 03 00 00 00
	djnz8 c, .LFE9132                                    ; FE9142  cb 1c ed
	xor A,A                                              ; FE9145  c9 d1
	ret                                                  ; FE9147  0e
; NoteEdit_ClearHeldKeyNotes: the note byte of each of the 8 NoteEdit_HeldKeys slots = 0.
NoteEdit_ClearHeldKeyNotes:
	ld c, 0x08:opc                                          ; FE9148  23 08
	ld XIX,0x00601f1d                                    ; FE914A  44 1d 1f 60 00
	xor A,A                                              ; FE914F  c9 d1
.LFE9151:
	ld (XIX),A                                           ; FE9151  b4 41
	add XIX,0x00000003                                   ; FE9153  ec c8 03 00 00 00
	djnz8 c, .LFE9151                                    ; FE9159  cb 1c f5
	ret                                                  ; FE915C  0e
; NoteEdit_EnterHeldNotes: DRUM EDIT: one note, EditCursor_Note with slot 0's velocity (NoteEdit_InsertNoteAndSync); NOTE EDIT: every slot with a note
;   through NoteEdit_InsertNoteEvent then EditCursor_SyncBeatAndTick, stopping on a BStore error (EditScreen_FlagMemoryFull).
NoteEdit_EnterHeldNotes:
	bit	0, (EditScreen_Mode:24)                             ; FE915D  f2 70 1f 60 c8
	jr z, .LFE917E                                       ; FE9162  66 1a
	ld a, (EditCursor_Note:24)                                 ; FE9164  c2 44 1f 60 21
	ld (NoteEdit_InputNote:24), a                                 ; FE9169  f2 34 1f 60 41
	ld XIX,0x00601f1e                                    ; FE916E  44 1e 1f 60 00
	ld A,(XIX)                                           ; FE9173  84 21
	ld (NoteEdit_InputVelocity:24), a                                 ; FE9175  f2 35 1f 60 41
	calr NoteEdit_InsertNoteAndSync                                      ; FE917A  1e 43 00
	ret                                                  ; FE917D  0e
.LFE917E:
	ld c, 0x08:opc                                          ; FE917E  23 08
	ld XIX,0x00601f1d                                    ; FE9180  44 1d 1f 60 00
.LFE9185:
	ld A,(XIX)                                           ; FE9185  84 21
	cp a, 0x00:i3                                          ; FE9187  c9 d8
	jr z, .LFE91B2                                       ; FE9189  66 27
	push XIX                                             ; FE918B  3c
	pushw bc                                             ; FE918C  29
	ld (NoteEdit_InputNote:24), a                                 ; FE918D  f2 34 1f 60 41
	add XIX,0x00000001                                   ; FE9192  ec c8 01 00 00 00
	ld A,(XIX)                                           ; FE9198  84 21
	ld (NoteEdit_InputVelocity:24), a                                 ; FE919A  f2 35 1f 60 41
	calr NoteEdit_InsertNoteEvent                                      ; FE919F  1e 30 00
	popw bc                                              ; FE91A2  49
	pop XIX                                              ; FE91A3  5c
	cp	(BStore_ErrorCode:16), 0x00                            ; FE91A4  c1 4a 0d 3f 00
	jr nz, .LFE91BC                                      ; FE91A9  6e 11
	push XIX                                             ; FE91AB  3c
	pushw bc                                             ; FE91AC  29
	calr EditCursor_SyncBeatAndTick                                      ; FE91AD  1e c6 00
	popw bc                                              ; FE91B0  49
	pop XIX                                              ; FE91B1  5c
.LFE91B2:
	add XIX,0x00000003                                   ; FE91B2  ec c8 03 00 00 00
	djnz8 c, .LFE9185                                    ; FE91B8  cb 1c ca
	ret                                                  ; FE91BB  0e
.LFE91BC:
	calr EditScreen_FlagMemoryFull                                          ; FE91BC  1e 15 fa
	ret                                                  ; FE91BF  0e
; NoteEdit_InsertNoteAndSync: NoteEdit_InsertNoteEvent then EditCursor_SyncBeatAndTick, or EditScreen_FlagMemoryFull on a BStore error.  Called by
;   DrumEdit_SoftKeyCol8 and NoteEdit_EnterHeldNotes.
NoteEdit_InsertNoteAndSync:
	calr NoteEdit_InsertNoteEvent                                      ; FE91C0  1e 0f 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE91C3  c1 4a 0d 3f 00
	jr nz, .LFE91CE                                      ; FE91C8  6e 04
	calr EditCursor_SyncBeatAndTick                                      ; FE91CA  1e a9 00
	ret                                                  ; FE91CD  0e
.LFE91CE:
	calr EditScreen_FlagMemoryFull                                          ; FE91CE  1e 03 fa
	ret                                                  ; FE91D1  0e
; NoteEdit_InsertNoteEvent: NoteEdit_SeekInsertPoint, then the 6-byte event at 0x601F16 -- 0x90, EditCursor_TickInMeasure mod 0x60,
;   NoteEdit_InputNote, NoteEdit_InputVelocity, (0x601F49) mod 0x60, (0x601F49) / 0x60 -- inserted into chain
;   EditScreen_Part + 1 (EditScreen_SaveTrackCursor, BStore_AppendBytes, 6 bytes).  So (0x601F49) is the
;   length a new note gets.
NoteEdit_InsertNoteEvent:
	calr NoteEdit_SeekInsertPoint                                      ; FE91D2  1e 4e 00
	ld XIY,0x00601f16                                    ; FE91D5  45 16 1f 60 00
	ld (xiy+), 0x90                                  ; FE91DA  f5 f4 00 90
	ld wa, (EditCursor_TickInMeasure:24)                                ; FE91DE  d2 54 1f 60 20
	div A,0x60                                           ; FE91E3  c9 0a 60
	ld (xiy+), w                                    ; FE91E6  f5 f4 40
	ld a, (NoteEdit_InputNote:24)                                 ; FE91E9  c2 34 1f 60 21
	ld (xiy+), a                                    ; FE91EE  f5 f4 41
	ld a, (NoteEdit_InputVelocity:24)                                 ; FE91F1  c2 35 1f 60 21
	ld (xiy+), a                                    ; FE91F6  f5 f4 41
	ld wa, (EditField_NewNoteLength:24)                                ; FE91F9  d2 49 1f 60 20
	div A,0x60                                           ; FE91FE  c9 0a 60
	and W,0x7f                                           ; FE9201  c8 cc 7f
	ld (xiy+), w                                    ; FE9204  f5 f4 40
	and A,0x7f                                           ; FE9207  c9 cc 7f
	ld (XIY),A                                           ; FE920A  b5 41
	calr EditScreen_SaveTrackCursor                                          ; FE920C  1e 99 f9
	ld a, (EditScreen_Part:24)                                 ; FE920F  c2 00 1f 60 21
	add A,0x01                                           ; FE9214  c9 c8 01
	ld w, 0x06:opc                                          ; FE9217  20 06
	ld XIY,0x00601f16                                    ; FE9219  45 16 1f 60 00
	call T_BStore_AppendBytes_Veneer                     ; FE921E  1d 94 28 f4
	ret                                                  ; FE9222  0e
; NoteEdit_SeekInsertPoint: from the measure's mark, steps over events and beat markers until the position passes
;   EditCursor_TickInMeasure, or to the end tag 0x82.
NoteEdit_SeekInsertPoint:
	calr BStore_CursorSlot_RestoreMark                                          ; FE9223  1e d2 f9
	cpw	(EditCursor_TickInMeasure:24), 0x0000                        ; FE9226  d2 54 1f 60 3f 00 00
	jr z, .LFE9275                                       ; FE922D  66 46
.LFE922F:
	call BStoreCursor_ReadByte                                        ; FE922F  1d 32 22 ff
	cp A,0x81                                            ; FE9233  c9 cf 81
	jr z, .LFE9256                                       ; FE9236  66 1e
	cp A,0x82                                            ; FE9238  c9 cf 82
	jr z, .LFE9275                                       ; FE923B  66 38
	calr EditPos_LoadEventTick                                          ; FE923D  1e 0f 16
	calr EditScreen_PositionAndMeasureStartTicks                                          ; FE9240  1e e5 13
	sub XWA,XBC                                          ; FE9243  e9 a0
	xor XBC,XBC                                          ; FE9245  e9 d1
	ld bc, (EditCursor_TickInMeasure:24)                                ; FE9247  d2 54 1f 60 21
	cp XWA,XBC                                           ; FE924C  e9 f0
	jr ugt, .LFE9275                                     ; FE924E  6b 25
.LFE9250:
	call BStoreCursor_SeekNextTag                                        ; FE9250  1d f6 21 ff
	jr .LFE922F                                          ; FE9254  68 d9
.LFE9256:
	ld (EditPos_Tick:24), 0x00                             ; FE9256  f2 07 1f 60 00 00
	addw	(EditPos_Beat:24), 0x0001                        ; FE925C  d2 05 1f 60 38 01 00
	calr EditScreen_PositionAndMeasureStartTicks                                          ; FE9263  1e c2 13
	sub XWA,XBC                                          ; FE9266  e9 a0
	xor XBC,XBC                                          ; FE9268  e9 d1
	ld bc, (EditCursor_TickInMeasure:24)                                ; FE926A  d2 54 1f 60 21
	cp XWA,XBC                                           ; FE926F  e9 f0
	jr ugt, .LFE9275                                     ; FE9271  6b 02
	jr .LFE9250                                          ; FE9273  68 db
.LFE9275:
	ret                                                  ; FE9275  0e
; EditCursor_SyncBeatAndTick: (0x601F07) = EditCursor_TickInMeasure mod 0x60, (0x601F05) = its beat + (0x601F0F), the measure's first beat.
EditCursor_SyncBeatAndTick:
	ld wa, (EditCursor_TickInMeasure:24)                                ; FE9276  d2 54 1f 60 20
	div A,0x60                                           ; FE927B  c9 0a 60
	ld (EditPos_Tick:24), w                                 ; FE927E  f2 07 1f 60 40
	xor W,W                                              ; FE9283  c8 d0
	add wa, (EditMeasure_StartBeat:24)                            ; FE9285  d2 0f 1f 60 80
	ld (EditPos_Beat:24), wa                                ; FE928A  f2 05 1f 60 50
	ret                                                  ; FE928F  0e
; EditScreen_StepCursorAfterEntry: EditCursor_AdvanceToNextIncStep and EditScreen_ExtendChainToCursorBeat; inside the measure the fields are
;   redrawn, past its end EditScreen_WrapAndShowCursorMeasure; EditScreen_CursorFlags bit 2 (extension failed) -> EditScreen_FlagMemoryFull.
EditScreen_StepCursorAfterEntry:
	calr EditCursor_AdvanceToNextIncStep                                          ; FE9290  1e 76 14
	calr EditScreen_ExtendChainToCursorBeat                                          ; FE9293  1e b7 13
	bit	2, (EditScreen_CursorFlags:24)                             ; FE9296  f2 5b 1f 60 ca
	jr nz, .LFE92BD                                      ; FE929B  6e 20
	ld a, (EditMeasure_Beats:24)                                 ; FE929D  c2 75 1f 60 21
	mul A,0x60                                           ; FE92A2  c9 08 60
	cp (EditCursor_TickInMeasure:24), wa                             ; FE92A5  d2 54 1f 60 f8
	jr nc, .LFE92B9                                      ; FE92AA  6f 0d
	calr EditCursor_SplitViewTick                                          ; FE92AC  1e 94 14
	calr EditScreen_EraseFieldRow                                          ; FE92AF  1e c6 64
	calr EditScreen_DrawFields                                          ; FE92B2  1e 21 66
	calr EditScreen_RedrawCursorLayer                                          ; FE92B5  1e d2 6a
	ret                                                  ; FE92B8  0e
.LFE92B9:
	calr EditScreen_WrapAndShowCursorMeasure                                          ; FE92B9  1e a1 02
	ret                                                  ; FE92BC  0e
.LFE92BD:
	calr EditScreen_FlagMemoryFull                                          ; FE92BD  1e 14 f9
	ret                                                  ; FE92C0  0e
; EditScreen_CountDownAction: (0x601F58) - 1 while bit 7 is set and it is above 0x80.
EditScreen_CountDownAction:
	bit	7, (EditScreen_ActionTimer:24)                             ; FE92C1  f2 58 1f 60 cf
	jr nz, .LFE92C9                                      ; FE92C6  6e 01
	ret                                                  ; FE92C8  0e
.LFE92C9:
	ld XIX,EditScreen_ActionTimer                                    ; FE92C9  44 58 1f 60 00
	cp (XIX),0x80                                        ; FE92CE  84 3f 80
	jr nz, .LFE92D4                                      ; FE92D1  6e 01
	ret                                                  ; FE92D3  0e
.LFE92D4:
	decm8 0x01, (xix)                                    ; FE92D4  84 69
	ret                                                  ; FE92D6  0e
; EditScreen_CountDownAction2: the same countdown on (0x601F5A).
EditScreen_CountDownAction2:
	bit	7, (EditScreen_ActionTimer2:24)                             ; FE92D7  f2 5a 1f 60 cf
	jr nz, .LFE92DF                                      ; FE92DC  6e 01
	ret                                                  ; FE92DE  0e
.LFE92DF:
	ld XIX,EditScreen_ActionTimer2                                    ; FE92DF  44 5a 1f 60 00
	cp (XIX),0x80                                        ; FE92E4  84 3f 80
	jr nz, .LFE92EA                                      ; FE92E7  6e 01
	ret                                                  ; FE92E9  0e
.LFE92EA:
	decm8 0x01, (xix)                                    ; FE92EA  84 69
	ret                                                  ; FE92EC  0e
; EditScreen_RunDueAction: when (0x601F58) has reached 0x80: it is cleared and EditScreen_DeferredActions[(0x601F59)] runs.  The note
;   steppers queue action 2 three ticks ahead (0x83 / 2), the DRUM EDIT scroll 5, the ruler scroll 4.
EditScreen_RunDueAction:
	ld XIX,EditScreen_ActionTimer                                    ; FE92ED  44 58 1f 60 00
	cp (XIX),0x80                                        ; FE92F2  84 3f 80
	jr z, .LFE92F8                                       ; FE92F5  66 01
	ret                                                  ; FE92F7  0e
.LFE92F8:
	ld (XIX),0x00                                        ; FE92F8  b4 00 00
	xor XWA,XWA                                          ; FE92FB  e8 d0
	ld XIX,EditScreen_DeferredActions                         ; FE92FD  44 11 93 fe 00
	ld a, (EditScreen_ActionIndex:24)                                 ; FE9302  c2 59 1f 60 21
	sll xwa, 0x02                                        ; FE9307  e8 ee 02
	add XIX,XWA                                          ; FE930A  e8 84
	ld XIX,(XIX)                                         ; FE930C  a4 24
	call (xix)                                           ; FE930E  b4 e8
	ret                                                  ; FE9310  0e
; ---------------------------------------------------------------------
; EditScreen_DeferredActions -- 7 pointers, indexed by (0x601F59)
; Read by: 0xFE92FB -- the same idiom as 0xFE8D6B, with `sll XWA,2`.
; ⚠ ENTRY COUNT 7 is the EXTENT.  There is no bound on (0x601F59) here
;          either, and 7 is not a round number, so this is the weakest
;          framing of the six dispatch tables.  What supports it: all 7
;          values are inside prom_a's 0xFE0000 half, the lowest
;          0xFE933F and the highest 0xFEAFF1,
;          and the byte at 0xFE932D starts a clean decode.
; ---------------------------------------------------------------------

; EditScreen_DeferredActions: the NOTE / DRUM EDIT deferred actions, run by EditScreen_RunDueAction when EditScreen_ActionTimer reaches 0x80 (notes/prom_ab_read_names_2026_10_04.py)
EditScreen_DeferredActions:
	.long EditScreen_ReloadMeasureView                                 ; FE9311  [  0]
	.long EditScreen_DeferredInsertSelectedAtCursor                                 ; FE9315  [  1]
	.long EditScreen_DeferredReselectAndRedraw                                 ; FE9319  [  2]
	.long EditScreen_DeferredRedrawAndExtend                                 ; FE931D  [  3]
	.long EditScreen_DeferredRedraw                                 ; FE9321  [  4]
	.long EditScreen_DeferredReselectAndRedraw5                                 ; FE9325  [  5]
	.long EditScreen_ReloadMeasureView                                 ; FE9329  [  6]
; EditScreen_RunDueAction2: when (0x601F5A) has reached 0x80: cleared, EditScreen_EndAudition_Call (EditScreen_EndAudition).
EditScreen_RunDueAction2:
	ld XIX,EditScreen_ActionTimer2                                    ; FE932D  44 5a 1f 60 00
	cp (XIX),0x80                                        ; FE9332  84 3f 80
	jr z, .LFE9338                                       ; FE9335  66 01
	ret                                                  ; FE9337  0e
.LFE9338:
	ld (XIX),0x00                                        ; FE9338  b4 00 00
	calr EditScreen_EndAudition_Call                                      ; FE933B  1e fa 03
	ret                                                  ; FE933E  0e
; EditScreen_ReloadMeasureView: EditScreen_DeferredActions[0] and [6]: EditScreen_EndAudition, the measure reopened (EditScreen_OpenCursorMeasure, moving on through
;   EditScreen_ExtendChainToCursorMeasure), its beat table rebuilt (EditScreen_BuildBeatTable), EditScreen_AppendTwoBeatsIfNoneAfterMark, the event at the cursor selected
;   (EditScreen_SelectEventAtCursor), and every part of the screen redrawn.
EditScreen_ReloadMeasureView:   ; entry: named by 2 `.long` operands, first at 0xFE9311
	calr EditScreen_EndAudition                                          ; FE933F  1e 0d 12
	calr EditScreen_OpenCursorMeasure                                          ; FE9342  1e 64 fb
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9345  c1 4a 0d 3f 00
	jr z, .LFE935F                                       ; FE934A  66 13
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE934C  1e 7b 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE934F  c1 4a 0d 3f 00
	jr nz, .LFE935B                                      ; FE9354  6e 05
	calr EditScreen_OpenCursorMeasure                                          ; FE9356  1e 50 fb
	jr .LFE935F                                          ; FE9359  68 04
.LFE935B:
	calr EditScreen_FlagMemoryFull                                          ; FE935B  1e 76 f8
	ret                                                  ; FE935E  0e
.LFE935F:
	calr EditScreen_BuildBeatTable                                          ; FE935F  1e 87 f7
	calr BStore_CursorSlot_RestoreMark                                          ; FE9362  1e 93 f8
	calr EditScreen_AppendTwoBeatsIfNoneAfterMark                                      ; FE9365  1e 26 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9368  c1 4a 0d 3f 00
	jr nz, .LFE935B                                      ; FE936D  6e ec
	calr DrumEdit_CursorNoteFromRow                                          ; FE936F  1e 45 1c
	calr EditPos_SeekShownNoteAtTickZero                                          ; FE9372  1e 3f f9
	calr EditPos_LoadTickIfShownNote                                          ; FE9375  1e 23 f7
	calr EditScreen_SelectEventAtCursor                                          ; FE9378  1e 96 fb
	calr EditScreen_EraseHeaderRow                                          ; FE937B  1e 36 64
	calr EditScreen_DrawHeaderAndGrid                                          ; FE937E  1e a5 65
	calr EditScreen_RedrawCursorLayer                                          ; FE9381  1e 06 6a
	calr EditScreen_DrawVisibleNotes                                          ; FE9384  1e 38 6b
	calr EditScreen_EraseFieldRow                                          ; FE9387  1e ee 63
	calr EditScreen_DrawFields                                          ; FE938A  1e 49 65
	ret                                                  ; FE938D  0e
; EditScreen_AppendTwoBeatsIfNoneAfterMark: From the shown measure's mark (cursor slot saved): when no 0x81 beat
;   marker follows it to the chain end (EditScreen_CountBeatMarkersToEnd, low byte 0), appends two at the part's saved
;   end cursor; cursor restored. EditScreen_ReloadMeasureView runs it right after BStore_CursorSlot_RestoreMark.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_AppendTwoBeatsIfNoneAfterMark:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE938E  f1 4a 0d 00 00
	calr BStore_CursorSlot_Save                                          ; FE9393  1e 58 f9
	calr EditScreen_CountBeatMarkersToEnd                                          ; FE9396  1e 1b 13
	cp	(EditScreen_BeatCounter:24), 0x00                          ; FE9399  c2 6c 1f 60 3f 00
	jr nz, .LFE93C6                                      ; FE939F  6e 25
	ld (EditScreen_BeatCounter:24), 0x02                             ; FE93A1  f2 6c 1f 60 00 02
.LFE93A7:
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE93A7  d2 6c 1f 60 3f 00 00
	jr nz, .LFE93B2                                      ; FE93AE  6e 02
	jr .LFE93C6                                          ; FE93B0  68 14
.LFE93B2:
	calr EditScreen_SeekPartSavedCursor                                      ; FE93B2  1e 2e 03
	calr EditScreen_AppendBeatMarker                                          ; FE93B5  1e d1 f7
	cp	(BStore_ErrorCode:16), 0x00                            ; FE93B8  c1 4a 0d 3f 00
	jr nz, .LFE93C6                                      ; FE93BD  6e 07
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FE93BF  d2 6c 1f 60 69
	jr .LFE93A7                                          ; FE93C4  68 e1
.LFE93C6:
	calr BStore_CursorSlot_Restore                                          ; FE93C6  1e 4c f9
	ret                                                  ; FE93C9  0e
; EditScreen_ExtendChainToCursorMeasure: Appends 0x81 beat markers to EditScreen_Part's chain until it reaches
;   EditCursor_Measure (EditScreen_AppendBeatsUpToCursorMeasure), then EditCursor_Beat + 2 more; EditScreen_FlagMemoryFull on a BStore error. The
;   edit screens call it when the cursor's measure or beat was not found, then retry. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
EditScreen_ExtendChainToCursorMeasure:
	xor XWA,XWA                                          ; FE93CA  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE93CC  c2 00 1f 60 21
	mul A,0x03                                           ; FE93D1  c9 08 03
	ld XIX,0x00603500                                    ; FE93D4  44 00 35 60 00
	add XIX,XWA                                          ; FE93D9  e8 84
	add XIX,0x00000001                                   ; FE93DB  ec c8 01 00 00 00
	ld WA,(XIX)                                          ; FE93E1  94 20
	cp WA,0xffff                                         ; FE93E3  d8 cf ff ff
	jr nz, .LFE93EB                                      ; FE93E7  6e 02
	jr .LFE942A                                          ; FE93E9  68 3f
.LFE93EB:
	ld (BStore_CursorBlock:16), wa                                  ; FE93EB  f1 5c 34 50
	ldw (BStore_CursorOffset:16), 0x05                                ; FE93EF  f1 5e 34 02 05 00
	calr EditScreen_CountBeatMarkersToEnd                                          ; FE93F5  1e bc 12
	calr EditScreen_AppendBeatsUpToCursorMeasure                                      ; FE93F8  1e 35 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE93FB  c1 4a 0d 3f 00
	jr nz, .LFE942B                                      ; FE9400  6e 29
	ld wa, (EditCursor_Beat:24)                                ; FE9402  d2 41 1f 60 20
	add A,0x02                                           ; FE9407  c9 c8 02
	ld (EditScreen_BeatCounter:24), wa                                ; FE940A  f2 6c 1f 60 50
.LFE940F:
	calr EditScreen_SeekPartSavedCursor                                      ; FE940F  1e d1 02
	calr EditScreen_AppendBeatMarker                                          ; FE9412  1e 74 f7
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9415  c1 4a 0d 3f 00
	jr nz, .LFE942B                                      ; FE941A  6e 0f
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FE941C  d2 6c 1f 60 69
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE9421  d2 6c 1f 60 3f 00 00
	jr nz, .LFE940F                                      ; FE9428  6e e5
.LFE942A:
	ret                                                  ; FE942A  0e
.LFE942B:
	calr EditScreen_FlagMemoryFull                                          ; FE942B  1e a6 f7
	jr .LFE942A                                          ; FE942E  68 fa
; EditScreen_AppendBeatsUpToCursorMeasure: With EditScreen_BeatCounter = the chain's beat-marker total: converts it to
;   measure/beat (T_Seq_BeatsToMeasureAndBeat, time signatures followed) and appends 0x81 markers, the rest of the
;   current measure then whole measures, until the total's measure is EditCursor_Measure. The middle step of
;   EditScreen_ExtendChainToCursorMeasure. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_AppendBeatsUpToCursorMeasure:
	ld wa, (EditScreen_BeatCounter:24)                                ; FE9430  d2 6c 1f 60 20
	ld (0x0c55:16), wa                                  ; FE9435  f1 55 0c 50
	ld (EditPos_Beat:24), wa                                ; FE9439  f2 05 1f 60 50
.LFE943E:
	calr EditScreen_FindMasterTrack                                          ; FE943E  1e cb fa
	call T_Seq_BeatsToMeasureAndBeat                                        ; FE9441  1d 60 0c f4
	cp (EditCursor_Measure:24), de                             ; FE9445  d2 3f 1f 60 fa
	jr z, .LFE9491                                       ; FE944A  66 45
	cp c, 0x00:i3                                          ; FE944C  cb d8
	jr z, .LFE9456                                       ; FE944E  66 06
	cp A,C                                               ; FE9450  cb f1
	jr ule, .LFE9456                                     ; FE9452  63 02
	sub A,C                                              ; FE9454  cb a1
.LFE9456:
	xor W,W                                              ; FE9456  c8 d0
	ld (EditScreen_BeatCounter:24), wa                                ; FE9458  f2 6c 1f 60 50
.LFE945D:
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE945D  d2 6c 1f 60 3f 00 00
	jr z, .LFE9486                                       ; FE9464  66 20
	calr EditScreen_SeekPartSavedCursor                                      ; FE9466  1e 7a 02
	calr EditScreen_AppendBeatMarker                                          ; FE9469  1e 1d f7
	cp	(BStore_ErrorCode:16), 0x00                            ; FE946C  c1 4a 0d 3f 00
	jr nz, .LFE9491                                      ; FE9471  6e 1e
	incw 0x01, (EditPos_Beat:24)                          ; FE9473  d2 05 1f 60 61
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FE9478  d2 6c 1f 60 69
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE947D  d2 6c 1f 60 3f 00 00
	jr nz, .LFE945D                                      ; FE9484  6e d7
.LFE9486:
	ld wa, (EditPos_Beat:24)                                ; FE9486  d2 05 1f 60 20
	ld (0x0c55:16), wa                                  ; FE948B  f1 55 0c 50
	jr .LFE943E                                          ; FE948F  68 ad
.LFE9491:
	ret                                                  ; FE9491  0e
; EditCursor_WrapAndRecompute: EditCursor_WrapPastMeasureEnd, then EditCursor_TickInMeasure = EditCursor_Beat x 0x60 + EditCursor_Tick.
EditCursor_WrapAndRecompute:
	calr EditCursor_WrapPastMeasureEnd                                      ; FE9492  1e 33 01
	ld wa, (EditCursor_Beat:24)                                ; FE9495  d2 41 1f 60 20
	mul WA,0x0060                                        ; FE949A  d8 08 60 00
	xor DE,DE                                            ; FE949E  da d2
	ld e, (EditCursor_Tick:24)                                 ; FE94A0  c2 43 1f 60 25
	add WA,DE                                            ; FE94A5  da 80
	ld (EditCursor_TickInMeasure:24), wa                                ; FE94A7  f2 54 1f 60 50
	ret                                                  ; FE94AC  0e
	ld wa, (EditPos_Beat:24)                                ; FE94AD  d2 05 1f 60 20
	ld (0x601f78:24), wa                                ; FE94B2  f2 78 1f 60 50
	ld a, (EditPos_Tick:24)                                 ; FE94B7  c2 07 1f 60 21
	ld (0x601f7a:24), a                                 ; FE94BC  f2 7a 1f 60 41
	ld wa, (BStore_CursorBlock:16)                                 ; FE94C1  d1 5c 34 20
	ld (0x601f7b:24), wa                                ; FE94C5  f2 7b 1f 60 50
	ld wa, (BStore_CursorOffset:16)                                 ; FE94CA  d1 5e 34 20
	ld (0x601f7d:24), wa                                ; FE94CE  f2 7d 1f 60 50
	ret                                                  ; FE94D3  0e
	ld wa, (0x601f78:24)                                ; FE94D4  d2 78 1f 60 20
	ld (EditPos_Beat:24), wa                                ; FE94D9  f2 05 1f 60 50
	ld a, (0x601f7a:24)                                 ; FE94DE  c2 7a 1f 60 21
	ld (EditPos_Tick:24), a                                 ; FE94E3  f2 07 1f 60 41
	ld wa, (0x601f7b:24)                                ; FE94E8  d2 7b 1f 60 20
	ld (BStore_CursorBlock:16), wa                                  ; FE94ED  f1 5c 34 50
	ld wa, (0x601f7d:24)                                ; FE94F1  d2 7d 1f 60 20
	ld (BStore_CursorOffset:16), wa                                  ; FE94F6  f1 5e 34 50
	ret                                                  ; FE94FA  0e
; EditScreen_ShowCursorMeasure: the view rebuilt to start at the cursor's measure: EditScreen_OpenCursorMeasure (moving on through EditScreen_ExtendChainToCursorMeasure
;   when it is missing), EditScreen_SeekCursorBeat, EditScreen_BuildBeatTable, EditCursor_SeekToTick,
;   EditScreen_SelectEventAtCursor, everything redrawn; with a selection, EditScreen_AuditionEvent.
EditScreen_ShowCursorMeasure:
	calr EditScreen_OpenCursorMeasure                                          ; FE94FB  1e ab f9
	cp	(BStore_ErrorCode:16), 0x00                            ; FE94FE  c1 4a 0d 3f 00
	jr z, .LFE9518                                       ; FE9503  66 13
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE9505  1e c2 fe
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9508  c1 4a 0d 3f 00
	jr nz, .LFE9514                                      ; FE950D  6e 05
	calr EditScreen_OpenCursorMeasure                                          ; FE950F  1e 97 f9
	jr z, .LFE9518                                       ; FE9512  66 04
.LFE9514:
	calr EditScreen_FlagMemoryFull                                          ; FE9514  1e bd f6
	ret                                                  ; FE9517  0e
.LFE9518:
	calr BStore_CursorSlot_RestoreMark                                          ; FE9518  1e dd f6
	calr EditScreen_SeekCursorBeat                                      ; FE951B  1e ed 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE951E  c1 4a 0d 3f 00
	jr z, .LFE9531                                       ; FE9523  66 0c
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE9525  1e a2 fe
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9528  c1 4a 0d 3f 00
	jr z, .LFE9531                                       ; FE952D  66 02
	jr .LFE9514                                          ; FE952F  68 e3
.LFE9531:
	calr BStore_CursorSlot_RestoreMark                                          ; FE9531  1e c4 f6
	calr EditScreen_BuildBeatTable                                          ; FE9534  1e b2 f5
	calr EditCursor_SeekToTick                                      ; FE9537  1e ad 03
	calr EditScreen_SelectEventAtCursor                                          ; FE953A  1e d4 f9
	calr EditScreen_EraseHeaderRow                                          ; FE953D  1e 74 62
	calr EditScreen_DrawHeaderAndGrid                                          ; FE9540  1e e3 63
	calr EditScreen_RedrawCursorLayer                                          ; FE9543  1e 44 68
	calr EditScreen_EraseEditArea_Layer0                                          ; FE9546  1e 89 62
	calr EditScreen_DrawVisibleNotes                                          ; FE9549  1e 73 69
	calr EditScreen_EraseFieldRow                                          ; FE954C  1e 29 62
	calr EditScreen_DrawFields                                          ; FE954F  1e 84 63
	bit	0, (EditScreen_CursorFlags:24)                             ; FE9552  f2 5b 1f 60 c8
	jr z, .LFE955C                                       ; FE9557  66 03
	calr EditScreen_AuditionEvent                                          ; FE9559  1e d9 0f
.LFE955C:
	ret                                                  ; FE955C  0e
; EditScreen_WrapAndShowCursorMeasure: EditCursor_WrapAndRecompute, then EditScreen_ShowCursorMeasure's sequence.  Called when a move runs past
;   the view.
EditScreen_WrapAndShowCursorMeasure:
	calr EditCursor_WrapAndRecompute                                      ; FE955D  1e 32 ff
	calr EditScreen_OpenCursorMeasure                                          ; FE9560  1e 46 f9
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9563  c1 4a 0d 3f 00
	jr z, .LFE957D                                       ; FE9568  66 13
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE956A  1e 5d fe
	cp	(BStore_ErrorCode:16), 0x00                            ; FE956D  c1 4a 0d 3f 00
	jr nz, .LFE9579                                      ; FE9572  6e 05
	calr EditScreen_OpenCursorMeasure                                          ; FE9574  1e 32 f9
	jr z, .LFE957D                                       ; FE9577  66 04
.LFE9579:
	calr EditScreen_FlagMemoryFull                                          ; FE9579  1e 58 f6
	ret                                                  ; FE957C  0e
.LFE957D:
	calr BStore_CursorSlot_RestoreMark                                          ; FE957D  1e 78 f6
	calr EditScreen_SeekCursorBeat                                      ; FE9580  1e 88 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9583  c1 4a 0d 3f 00
	jr z, .LFE9596                                       ; FE9588  66 0c
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE958A  1e 3d fe
	cp	(BStore_ErrorCode:16), 0x00                            ; FE958D  c1 4a 0d 3f 00
	jr z, .LFE9596                                       ; FE9592  66 02
	jr .LFE9579                                          ; FE9594  68 e3
.LFE9596:
	calr BStore_CursorSlot_RestoreMark                                          ; FE9596  1e 5f f6
	calr EditScreen_BuildBeatTable                                          ; FE9599  1e 4d f5
	calr EditCursor_SeekToTick                                      ; FE959C  1e 48 03
	calr EditPos_SeekShownNoteAtTickZero                                          ; FE959F  1e 12 f7
	calr EditPos_LoadTickIfShownNote                                          ; FE95A2  1e f6 f4
	calr EditScreen_SelectEventAtCursor                                          ; FE95A5  1e 69 f9
	calr EditScreen_EraseHeaderRow                                          ; FE95A8  1e 09 62
	calr EditScreen_DrawHeaderAndGrid                                          ; FE95AB  1e 78 63
	calr EditScreen_RedrawCursorLayer                                          ; FE95AE  1e d9 67
	calr EditScreen_EraseEditArea_Layer0                                          ; FE95B1  1e 1e 62
	calr EditScreen_DrawVisibleNotes                                          ; FE95B4  1e 08 69
	calr EditScreen_EraseFieldRow                                          ; FE95B7  1e be 61
	calr EditScreen_DrawFields                                          ; FE95BA  1e 19 63
	bit	0, (EditScreen_CursorFlags:24)                             ; FE95BD  f2 5b 1f 60 c8
	jr z, .LFE95C7                                       ; FE95C2  66 03
	calr EditScreen_AuditionEvent                                          ; FE95C4  1e 6e 0f
.LFE95C7:
	ret                                                  ; FE95C7  0e
; EditCursor_WrapPastMeasureEnd: with EditCursor_TickInMeasure past the measure: the next measure at beat 0 when the beat table's last entry
;   is set, else one beat more; EditCursor_Tick = TickInMeasure - EditMeasure_Beats x 0x60.
EditCursor_WrapPastMeasureEnd:
	ld XIX,EditScreen_BeatTable                                    ; FE95C8  44 5f 1f 60 00
	xor XBC,XBC                                          ; FE95CD  e9 d1
	ld c, (0x601f76:24)                                 ; FE95CF  c2 76 1f 60 23
	add XIX,XBC                                          ; FE95D4  e9 84
	dec 1,XIX                                            ; FE95D6  ec 69
	cp (XIX),0x00                                        ; FE95D8  84 3f 00
	jr nz, .LFE95DF                                      ; FE95DB  6e 02
	jr .LFE9602                                          ; FE95DD  68 23
.LFE95DF:
	addw	(EditCursor_Measure:24), 0x0001                        ; FE95DF  d2 3f 1f 60 38 01 00
	ldw (EditCursor_Beat:24), 0x00                             ; FE95E6  f2 41 1f 60 02 00 00
.LFE95ED:
	ld wa, (EditCursor_TickInMeasure:24)                                ; FE95ED  d2 54 1f 60 20
	ld c, (EditMeasure_Beats:24)                                 ; FE95F2  c2 75 1f 60 23
	mul C,0x60                                           ; FE95F7  cb 08 60
	sub WA,BC                                            ; FE95FA  d9 a0
	ld (EditCursor_Tick:24), a                                 ; FE95FC  f2 43 1f 60 41
	ret                                                  ; FE9601  0e
.LFE9602:
	addw	(EditCursor_Beat:24), 0x0001                        ; FE9602  d2 41 1f 60 38 01 00
	jr .LFE95ED                                          ; FE9609  68 e2
; EditScreen_SeekCursorBeat: steps over EditCursor_Beat beat markers from the cursor; BStore_ErrorCode = 0xFF when the end tag comes first.
EditScreen_SeekCursorBeat:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE960B  f1 4a 0d 00 00
	ld wa, (EditCursor_Beat:24)                                ; FE9610  d2 41 1f 60 20
	cp wa, 0x00:i3                                         ; FE9615  d8 d8
	jr nz, .LFE961A                                      ; FE9617  6e 01
	ret                                                  ; FE9619  0e
.LFE961A:
	ld (EditScreen_BeatCounter:24), wa                                ; FE961A  f2 6c 1f 60 50
.LFE961F:
	call BStoreCursor_ReadByte                                        ; FE961F  1d 32 22 ff
	cp A,0x81                                            ; FE9623  c9 cf 81
	jr z, .LFE9633                                       ; FE9626  66 0b
	cp A,0x82                                            ; FE9628  c9 cf 82
	jr z, .LFE9642                                       ; FE962B  66 15
.LFE962D:
	call BStoreCursor_SeekNextTag                                        ; FE962D  1d f6 21 ff
	jr .LFE961F                                          ; FE9631  68 ec
.LFE9633:
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FE9633  d2 6c 1f 60 69
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE9638  d2 6c 1f 60 3f 00 00
	jr nz, .LFE962D                                      ; FE963F  6e ec
	ret                                                  ; FE9641  0e
.LFE9642:
	ld (BStore_ErrorCode:16), 0xff                                 ; FE9642  f1 4a 0d 00 ff
	ret                                                  ; FE9647  0e
; EditScreen_ShowPreviousMeasure: with EditCursor_Measure > 1: the view is rebuilt from the measure before (EditScreen_OpenCursorMeasure and
;   EditScreen_BuildBeatTable with the measure lowered by one, then raised back), the cursor at beat 0 tick 0 of
;   its measure (EditScreen_SeekCursorMeasureStart, EditCursor_ComputeTickInView), selection and screen redrawn.
EditScreen_ShowPreviousMeasure:
	cpw	(EditCursor_Measure:24), 0x0001                        ; FE9648  d2 3f 1f 60 3f 01 00
	jr ugt, .LFE9652                                     ; FE964F  6b 01
	ret                                                  ; FE9651  0e
.LFE9652:
	subw	(EditCursor_Measure:24), 0x0001                ; FE9652  d2 3f 1f 60 3a 01 00
	calr EditScreen_OpenCursorMeasure                                          ; FE9659  1e 4d f8
	calr BStore_CursorSlot_RestoreMark                                          ; FE965C  1e 99 f5
	calr EditScreen_BuildBeatTable                                          ; FE965F  1e 87 f4
	addw	(EditCursor_Measure:24), 0x0001                        ; FE9662  d2 3f 1f 60 38 01 00
	xor WA,WA                                            ; FE9669  d8 d0
	ld (EditCursor_Beat:24), wa                                ; FE966B  f2 41 1f 60 50
	ld (EditCursor_Tick:24), a                                 ; FE9670  f2 43 1f 60 41
	calr EditScreen_SeekCursorMeasureStart                                          ; FE9675  1e 5b f8
	calr EditCursor_ComputeTickInView                                          ; FE9678  1e 5f 08
	calr EditScreen_SelectEventAtCursor                                          ; FE967B  1e 93 f8
	calr EditScreen_EraseHeaderRow                                          ; FE967E  1e 33 61
	calr EditScreen_DrawHeaderAndGrid                                          ; FE9681  1e a2 62
	calr EditScreen_RedrawCursorLayer                                          ; FE9684  1e 03 67
	calr EditScreen_EraseEditArea_Layer0                                          ; FE9687  1e 48 61
	calr EditScreen_DrawVisibleNotes                                          ; FE968A  1e 32 68
	calr EditScreen_EraseFieldRow                                          ; FE968D  1e e8 60
	calr EditScreen_DrawFields                                          ; FE9690  1e 43 62
	ret                                                  ; FE9693  0e
; EditScreen_ShowPreviousMeasureAtTick: EditScreen_ShowPreviousMeasure with EditCursor_SeekToTick before the re-selection.  Called by
;   EditCursor_PrevBeat.
EditScreen_ShowPreviousMeasureAtTick:
	cpw	(EditCursor_Measure:24), 0x0001                        ; FE9694  d2 3f 1f 60 3f 01 00
	jr ugt, .LFE969E                                     ; FE969B  6b 01
	ret                                                  ; FE969D  0e
.LFE969E:
	subw	(EditCursor_Measure:24), 0x0001                ; FE969E  d2 3f 1f 60 3a 01 00
	calr EditScreen_OpenCursorMeasure                                          ; FE96A5  1e 01 f8
	calr BStore_CursorSlot_RestoreMark                                          ; FE96A8  1e 4d f5
	calr EditScreen_BuildBeatTable                                          ; FE96AB  1e 3b f4
	addw	(EditCursor_Measure:24), 0x0001                        ; FE96AE  d2 3f 1f 60 38 01 00
	xor WA,WA                                            ; FE96B5  d8 d0
	ld (EditCursor_Beat:24), wa                                ; FE96B7  f2 41 1f 60 50
	ld (EditCursor_Tick:24), a                                 ; FE96BC  f2 43 1f 60 41
	calr EditScreen_SeekCursorMeasureStart                                          ; FE96C1  1e 0f f8
	calr EditCursor_ComputeTickInView                                          ; FE96C4  1e 13 08
	calr EditCursor_SeekToTick                                      ; FE96C7  1e 1d 02
	calr EditScreen_SelectEventAtCursor                                          ; FE96CA  1e 44 f8
	calr EditScreen_EraseHeaderRow                                          ; FE96CD  1e e4 60
	calr EditScreen_DrawHeaderAndGrid                                          ; FE96D0  1e 53 62
	calr EditScreen_RedrawCursorLayer                                          ; FE96D3  1e b4 66
	calr EditScreen_EraseEditArea_Layer0                                          ; FE96D6  1e f9 60
	calr EditScreen_DrawVisibleNotes                                          ; FE96D9  1e e3 67
	calr EditScreen_EraseFieldRow                                          ; FE96DC  1e 99 60
	calr EditScreen_DrawFields                                          ; FE96DF  1e f4 61
	ret                                                  ; FE96E2  0e
; EditScreen_SeekPartSavedCursor: BStore_CursorBlock = word 0x60347E[EditScreen_Part], BStore_CursorOffset = byte 0x6034A0[EditScreen_Part]: the
;   part's saved cursor (the workspace pair BStore_OpenChainAtSavedCursor checks).
EditScreen_SeekPartSavedCursor:
	ld XIX,0x0060347e                                    ; FE96E3  44 7e 34 60 00
	xor XWA,XWA                                          ; FE96E8  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE96EA  c2 00 1f 60 21
	sll xwa, 0x01                                        ; FE96EF  e8 ee 01
	add XIX,XWA                                          ; FE96F2  e8 84
	ld WA,(XIX)                                          ; FE96F4  94 20
	ld (BStore_CursorBlock:16), wa                                  ; FE96F6  f1 5c 34 50
	ld XIX,0x006034a0                                    ; FE96FA  44 a0 34 60 00
	xor XWA,XWA                                          ; FE96FF  e8 d0
	ld a, (EditScreen_Part:24)                                 ; FE9701  c2 00 1f 60 21
	add XIX,XWA                                          ; FE9706  e8 84
	ld A,(XIX)                                           ; FE9708  84 21
	xor W,W                                              ; FE970A  c8 d0
	ld (BStore_CursorOffset:16), wa                                  ; FE970C  f1 5e 34 50
	ret                                                  ; FE9710  0e
; EditScreen_DeferredInsertSelectedAtCursor: EditScreen_DeferredActions[1], queued by EditScreen_QueueRelocateAfterMove: EditScreen_InsertSelectedEventAtCursor,
;   the selection redone, the notes redrawn, EditCursor_TickInMeasure from the position, the cursor layer redrawn.
EditScreen_DeferredInsertSelectedAtCursor:   ; entry: named by 1 `.long` operand, first at 0xFE9315
	calr EditScreen_InsertSelectedEventAtCursor                                      ; FE9711  1e 4e 00
	calr EditScreen_SelectEventAtCursor                                          ; FE9714  1e fa f7
	calr EditScreen_EraseEditArea_Layer0                                          ; FE9717  1e b8 60
	calr EditScreen_DrawVisibleNotes                                          ; FE971A  1e a2 67
	calr EditScreen_PositionAndMeasureStartTicks                                          ; FE971D  1e 08 0f
	sub XWA,XBC                                          ; FE9720  e9 a0
	ld (EditCursor_TickInMeasure:24), wa                                ; FE9722  f2 54 1f 60 50
	calr EditScreen_RedrawCursorLayer                                          ; FE9727  1e 60 66
	ret                                                  ; FE972A  0e
; EditScreen_DeferredReselectAndRedraw: EditScreen_DeferredActions[2] (queued by the note steppers): EditScreen_SelectEventAtCursor, layer 0 erased,
;   EditScreen_DrawVisibleNotes, EditScreen_RedrawCursorLayer.
EditScreen_DeferredReselectAndRedraw:   ; entry: named by 1 `.long` operand, first at 0xFE9319
	calr EditScreen_SelectEventAtCursor                                          ; FE972B  1e e3 f7
	calr EditScreen_EraseEditArea_Layer0                                          ; FE972E  1e a1 60
	calr EditScreen_DrawVisibleNotes                                          ; FE9731  1e 8b 67
	calr EditScreen_RedrawCursorLayer                                          ; FE9734  1e 53 66
	ret                                                  ; FE9737  0e
; EditScreen_EndAudition_Call: calls EditScreen_EndAudition and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
EditScreen_EndAudition_Call:
	calr EditScreen_EndAudition                                          ; FE9738  1e 14 0e
	ret                                                  ; FE973B  0e
; EditScreen_DeferredRedrawAndExtend: EditScreen_DeferredActions[3]: redraw; with an event selected, EditScreen_AppendMissingBeatMarkers first
;   (EditScreen_FlagMemoryFull on a BStore error).
EditScreen_DeferredRedrawAndExtend:   ; entry: named by 1 `.long` operand, first at 0xFE931D
	calr EditScreen_EraseEditArea_Layer0                                          ; FE973C  1e 93 60
	calr EditScreen_DrawVisibleNotes                                          ; FE973F  1e 7d 67
	bit	0, (EditScreen_CursorFlags:24)                             ; FE9742  f2 5b 1f 60 c8
	jr z, .LFE9753                                       ; FE9747  66 0a
	calr EditScreen_AppendMissingBeatMarkers                                      ; FE9749  1e 93 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE974C  c1 4a 0d 3f 00
	jr nz, .LFE9757                                      ; FE9751  6e 04
.LFE9753:
	calr EditScreen_RedrawCursorLayer                                          ; FE9753  1e 34 66
	ret                                                  ; FE9756  0e
.LFE9757:
	calr EditScreen_FlagMemoryFull                                          ; FE9757  1e 7a f4
	ret                                                  ; FE975A  0e
; EditScreen_DeferredRedraw: EditScreen_DeferredActions[4] (queued by the ruler scroll): EditScreen_DrawVisibleNotes,
;   EditScreen_RedrawCursorLayer.
EditScreen_DeferredRedraw:   ; entry: named by 1 `.long` operand, first at 0xFE9321
	calr EditScreen_DrawVisibleNotes                                          ; FE975B  1e 61 67
	calr EditScreen_RedrawCursorLayer                                          ; FE975E  1e 29 66
	ret                                                  ; FE9761  0e
; EditScreen_InsertSelectedEventAtCursor: copies the selected event's bytes +2..+5 (note, velocity, length) to 0x601F18..0x601F1B, backs onto its tag,
;   runs sub_FE9983 (EditScreen_SaveTrackCursor, BStore_DirEntry = part + 1, T_F42F04 -- whose effect is not read
;   here), seeks the cursor's tick (EditCursor_SeekPastTick) and inserts 0x90, EditCursor_Tick and the four bytes
;   into the part's chain (BStore_AppendBytes, 6), then EditScreen_AppendMissingBeatMarkers.  Called by
;   EditCursor_NextBeat / _PrevBeat and deferred action 1 -- the selected note following the cursor.
EditScreen_InsertSelectedEventAtCursor:
	call BStoreCursor_Step                                        ; FE9762  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9766  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE976A  1d 32 22 ff
	ld (0x601f18:24), a                                 ; FE976E  f2 18 1f 60 41
	call BStoreCursor_Step                                        ; FE9773  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE9777  1d 32 22 ff
	ld (0x601f19:24), a                                 ; FE977B  f2 19 1f 60 41
	call BStoreCursor_Step                                        ; FE9780  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE9784  1d 32 22 ff
	ld (0x601f1a:24), a                                 ; FE9788  f2 1a 1f 60 41
	call BStoreCursor_Step                                        ; FE978D  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE9791  1d 32 22 ff
	ld (0x601f1b:24), a                                 ; FE9795  f2 1b 1f 60 41
	calr BStoreCursor_SeekPrevTag                                          ; FE979A  1e 4e eb
	calr sub_FE9983                                      ; FE979D  1e e3 01
	calr EditCursor_SeekPastTick                                      ; FE97A0  1e a8 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE97A3  c1 4a 0d 3f 00
	jr nz, .LFE97DB                                      ; FE97A8  6e 31
	ld (0x601f16:24), 0x90                             ; FE97AA  f2 16 1f 60 00 90
	ld a, (EditCursor_Tick:24)                                 ; FE97B0  c2 43 1f 60 21
	ld (0x601f17:24), a                                 ; FE97B5  f2 17 1f 60 41
	calr EditScreen_SaveTrackCursor                                          ; FE97BA  1e eb f3
	ld a, (EditScreen_Part:24)                                 ; FE97BD  c2 00 1f 60 21
	add A,0x01                                           ; FE97C2  c9 c8 01
	ld w, 0x06:opc                                          ; FE97C5  20 06
	ld XIY,0x00601f16                                    ; FE97C7  45 16 1f 60 00
	call T_BStore_AppendBytes_Veneer                     ; FE97CC  1d 94 28 f4
	calr EditScreen_AppendMissingBeatMarkers                                      ; FE97D0  1e 0c 00
	cp	(BStore_ErrorCode:16), 0x00                            ; FE97D3  c1 4a 0d 3f 00
	jr nz, .LFE97DB                                      ; FE97D8  6e 01
	ret                                                  ; FE97DA  0e
.LFE97DB:
	calr EditScreen_FlagMemoryFull                                          ; FE97DB  1e f6 f3
	ret                                                  ; FE97DE  0e
; EditScreen_AppendMissingBeatMarkers: appends 0x81 beat markers (EditScreen_AppendBeatMarker) while the target (0x601F6C) exceeds the count
;   EditScreen_ReadNoteLengthBeats returns; BStore_ErrorCode = 0xFF when an append fails; the cursor is restored.
EditScreen_AppendMissingBeatMarkers:
	ld (BStore_ErrorCode:16), 0x00                                 ; FE97DF  f1 4a 0d 00 00
	calr BStore_CursorSlot_Save                                          ; FE97E4  1e 07 f5
	calr EditScreen_ReadNoteLengthBeats                                      ; FE97E7  1e 46 00
	inc 1,WA                                             ; FE97EA  d8 61
	pushw wa                                             ; FE97EC  28
	calr EditScreen_CountBeatMarkersToEnd                                          ; FE97ED  1e c4 0e
	popw wa                                              ; FE97F0  48
	inc 1,WA                                             ; FE97F1  d8 61
	cp	wa, (EditScreen_BeatCounter:24)                            ; FE97F3  d2 6c 1f 60 f0
	jr c, .LFE9825                                       ; FE97F8  67 2b
	sub wa, (EditScreen_BeatCounter:24)                            ; FE97FA  d2 6c 1f 60 a0
	inc 1,WA                                             ; FE97FF  d8 61
	ld (EditScreen_BeatCounter:24), wa                                ; FE9801  f2 6c 1f 60 50
.LFE9806:
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FE9806  d2 6c 1f 60 3f 00 00
	jr nz, .LFE9811                                      ; FE980D  6e 02
	jr .LFE9825                                          ; FE980F  68 14
.LFE9811:
	calr EditScreen_SeekPartSavedCursor                                      ; FE9811  1e cf fe
	calr EditScreen_AppendBeatMarker                                          ; FE9814  1e 72 f3
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9817  c1 4a 0d 3f 00
	jr nz, .LFE9829                                      ; FE981C  6e 0b
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FE981E  d2 6c 1f 60 69
	jr .LFE9806                                          ; FE9823  68 e1
.LFE9825:
	calr BStore_CursorSlot_Restore                                          ; FE9825  1e ed f4
	ret                                                  ; FE9828  0e
.LFE9829:
	ld (BStore_ErrorCode:16), 0xff                                 ; FE9829  f1 4a 0d 00 ff
	jr .LFE9825                                          ; FE982E  68 f5
; EditScreen_ReadNoteLengthBeats: WA = byte +5 of the note event at the block-store cursor (W = 0): the note's length
;   in whole beats, length / 0x60, the byte EditField_StoreLengthInNoteEvent writes there; the cursor is left on it.
;   EditScreen_AppendMissingBeatMarkers turns it into the beat markers the note needs. Basis: caller + body + writer.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_ReadNoteLengthBeats:
	call BStoreCursor_Step                                        ; FE9830  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9834  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9838  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE983C  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9840  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE9844  1d 32 22 ff
	xor W,W                                              ; FE9848  c8 d0
	ret                                                  ; FE984A  0e
; EditCursor_SeekPastTick: opens the edited measure (EditScreen_SeekCursorMeasure, moving on through EditScreen_ExtendChainToCursorMeasure while BStore_ErrorCode is set), counts 0x81
;   markers up to EditCursor_Beat, then steps over every event whose tick is <= EditCursor_Tick (`jr ule`) and
;   backs onto the tag; 0x601F05 += the beat, 0x601F07 = the tick.  Called by EditCursor_NextBeat.
EditCursor_SeekPastTick:
	calr EditScreen_SeekCursorMeasure                                          ; FE984B  1e a5 f6
	cp	(BStore_ErrorCode:16), 0x00                            ; FE984E  c1 4a 0d 3f 00
	jr z, .LFE9863                                       ; FE9853  66 0e
.LFE9855:
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE9855  1e 72 fb
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9858  c1 4a 0d 3f 00
	jrl nz, .LFE98E6                                     ; FE985D  7e 86 00
	calr EditScreen_SeekCursorMeasure                                          ; FE9860  1e 90 f6
.LFE9863:
	ld (EditPos_Beat:24), ix                                ; FE9863  f2 05 1f 60 54
	ld (EditPos_Tick:24), 0x00                             ; FE9868  f2 07 1f 60 00 00
	ld (BStore_CursorOffset:16), iy                                  ; FE986E  f1 5e 34 55
	cpw	(EditCursor_Beat:24), 0x0000                        ; FE9872  d2 41 1f 60 3f 00 00
	jr z, .LFE98AF                                       ; FE9879  66 34
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FE987B  f2 6c 1f 60 02 00 00
.LFE9882:
	call BStoreCursor_ReadByte                                        ; FE9882  1d 32 22 ff
	cp A,0x82                                            ; FE9886  c9 cf 82
	jr z, .LFE9855                                       ; FE9889  66 ca
	cp A,0x81                                            ; FE988B  c9 cf 81
	jr z, .LFE9896                                       ; FE988E  66 06
.LFE9890:
	call BStoreCursor_SeekNextTag                                        ; FE9890  1d f6 21 ff
	jr .LFE9882                                          ; FE9894  68 ec
.LFE9896:
	addw	(EditScreen_BeatCounter:24), 0x0001                        ; FE9896  d2 6c 1f 60 38 01 00
	ld wa, (EditCursor_Beat:24)                                ; FE989D  d2 41 1f 60 20
	cp (EditScreen_BeatCounter:24), wa                             ; FE98A2  d2 6c 1f 60 f8
	jr nc, .LFE98AB                                      ; FE98A7  6f 02
	jr .LFE9890                                          ; FE98A9  68 e5
.LFE98AB:
	call BStoreCursor_SeekNextTag                                        ; FE98AB  1d f6 21 ff
.LFE98AF:
	call BStoreCursor_ReadByte                                        ; FE98AF  1d 32 22 ff
	cp A,0x82                                            ; FE98B3  c9 cf 82
	jr z, .LFE9855                                       ; FE98B6  66 9d
	cp A,0x81                                            ; FE98B8  c9 cf 81
	jr nz, .LFE98BF                                      ; FE98BB  6e 02
	jr .LFE98D1                                          ; FE98BD  68 12
.LFE98BF:
	call BStoreCursor_Step                                        ; FE98BF  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE98C3  1d 32 22 ff
	cp	a, (EditCursor_Tick:24)                             ; FE98C7  c2 43 1f 60 f1
	jr ule, .LFE98AB                                     ; FE98CC  63 dd
	calr BStoreCursor_SeekPrevTag                                          ; FE98CE  1e 1a ea
.LFE98D1:
	ld wa, (EditCursor_Beat:24)                                ; FE98D1  d2 41 1f 60 20
	add (EditPos_Beat:24), wa                            ; FE98D6  d2 05 1f 60 88
	ld a, (EditCursor_Tick:24)                                 ; FE98DB  c2 43 1f 60 21
	ld (EditPos_Tick:24), a                                 ; FE98E0  f2 07 1f 60 41
	ret                                                  ; FE98E5  0e
.LFE98E6:
	ret                                                  ; FE98E6  0e
; EditCursor_SeekToTick: EditCursor_SeekPastTick's twin that stops at the first event whose tick is >= EditCursor_Tick (`jr c`).
EditCursor_SeekToTick:
	calr EditScreen_SeekCursorMeasure                                          ; FE98E7  1e 09 f6
	cp	(BStore_ErrorCode:16), 0x00                            ; FE98EA  c1 4a 0d 3f 00
	jr z, .LFE98FF                                       ; FE98EF  66 0e
.LFE98F1:
	calr EditScreen_ExtendChainToCursorMeasure                                      ; FE98F1  1e d6 fa
	cp	(BStore_ErrorCode:16), 0x00                            ; FE98F4  c1 4a 0d 3f 00
	jrl nz, .LFE9982                                     ; FE98F9  7e 86 00
	calr EditScreen_SeekCursorMeasure                                          ; FE98FC  1e f4 f5
.LFE98FF:
	ld (EditPos_Beat:24), ix                                ; FE98FF  f2 05 1f 60 54
	ld (EditPos_Tick:24), 0x00                             ; FE9904  f2 07 1f 60 00 00
	ld (BStore_CursorOffset:16), iy                                  ; FE990A  f1 5e 34 55
	cpw	(EditCursor_Beat:24), 0x0000                        ; FE990E  d2 41 1f 60 3f 00 00
	jr z, .LFE994B                                       ; FE9915  66 34
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FE9917  f2 6c 1f 60 02 00 00
.LFE991E:
	call BStoreCursor_ReadByte                                        ; FE991E  1d 32 22 ff
	cp A,0x82                                            ; FE9922  c9 cf 82
	jr z, .LFE98F1                                       ; FE9925  66 ca
	cp A,0x81                                            ; FE9927  c9 cf 81
	jr z, .LFE9932                                       ; FE992A  66 06
.LFE992C:
	call BStoreCursor_SeekNextTag                                        ; FE992C  1d f6 21 ff
	jr .LFE991E                                          ; FE9930  68 ec
.LFE9932:
	addw	(EditScreen_BeatCounter:24), 0x0001                        ; FE9932  d2 6c 1f 60 38 01 00
	ld wa, (EditCursor_Beat:24)                                ; FE9939  d2 41 1f 60 20
	cp (EditScreen_BeatCounter:24), wa                             ; FE993E  d2 6c 1f 60 f8
	jr nc, .LFE9947                                      ; FE9943  6f 02
	jr .LFE992C                                          ; FE9945  68 e5
.LFE9947:
	call BStoreCursor_SeekNextTag                                        ; FE9947  1d f6 21 ff
.LFE994B:
	call BStoreCursor_ReadByte                                        ; FE994B  1d 32 22 ff
	cp A,0x82                                            ; FE994F  c9 cf 82
	jr z, .LFE98F1                                       ; FE9952  66 9d
	cp A,0x81                                            ; FE9954  c9 cf 81
	jr nz, .LFE995B                                      ; FE9957  6e 02
	jr .LFE996D                                          ; FE9959  68 12
.LFE995B:
	call BStoreCursor_Step                                        ; FE995B  1d 04 22 ff
	call BStoreCursor_ReadByte                                        ; FE995F  1d 32 22 ff
	cp	a, (EditCursor_Tick:24)                             ; FE9963  c2 43 1f 60 f1
	jr c, .LFE9947                                       ; FE9968  67 dd
	calr BStoreCursor_SeekPrevTag                                          ; FE996A  1e 7e e9
.LFE996D:
	ld wa, (EditCursor_Beat:24)                                ; FE996D  d2 41 1f 60 20
	add (EditPos_Beat:24), wa                            ; FE9972  d2 05 1f 60 88
	ld a, (EditCursor_Tick:24)                                 ; FE9977  c2 43 1f 60 21
	ld (EditPos_Tick:24), a                                 ; FE997C  f2 07 1f 60 41
	ret                                                  ; FE9981  0e
.LFE9982:
	ret                                                  ; FE9982  0e
sub_FE9983:
	calr EditScreen_SaveTrackCursor                                          ; FE9983  1e 22 f2
	ld a, (EditScreen_Part:24)                                 ; FE9986  c2 00 1f 60 21
	add A,0x01                                           ; FE998B  c9 c8 01
	ld (BStore_DirEntry:16), a                                   ; FE998E  f1 08 10 41
	call T_F42F04                                        ; FE9992  1d 04 2f f4
	ret                                                  ; FE9996  0e
; EditCursor_ApplyNoteToEvent: when the event at the block-store cursor is a note-on (0x9n), its note byte (+2) = EditCursor_Note (cursor
;   restored); then EditScreen_AuditionEvent.  Called by all four EditCursor_Note steppers.
EditCursor_ApplyNoteToEvent:
	calr BStore_CursorSlot_Save                                          ; FE9997  1e 54 f3
	call BStoreCursor_ReadByte                                        ; FE999A  1d 32 22 ff
	and A,0xf0                                           ; FE999E  c9 cc f0
	cp A,0x90                                            ; FE99A1  c9 cf 90
	jr z, .LFE99A7                                       ; FE99A4  66 01
	ret                                                  ; FE99A6  0e
.LFE99A7:
	call BStoreCursor_Step                                        ; FE99A7  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE99AB  1d 04 22 ff
	ld a, (EditCursor_Note:24)                                 ; FE99AF  c2 44 1f 60 21
	call BStoreCursor_WriteByte                                        ; FE99B4  1d 4d 22 ff
	calr BStore_CursorSlot_Restore                                          ; FE99B8  1e 5a f3
	calr EditScreen_AuditionEvent                                          ; FE99BB  1e 77 0b
	ret                                                  ; FE99BE  0e
; EditField_StoreLengthInNoteEvent: when the event at the block-store cursor is a note-on (0x9n), steps 4 bytes in and writes EditField_Length as
;   two 7-bit bytes, length mod 0x60 then length / 0x60 (`div A,0x60`); the cursor is saved and restored around it.
;   Called by EditField_LengthUp / _LengthDown / _LengthUp12 / _LengthDown12.
EditField_StoreLengthInNoteEvent:
	calr BStore_CursorSlot_Save                                          ; FE99BF  1e 2c f3
	call BStoreCursor_ReadByte                                        ; FE99C2  1d 32 22 ff
	and A,0xf0                                           ; FE99C6  c9 cc f0
	cp A,0x90                                            ; FE99C9  c9 cf 90
	jr z, .LFE99CF                                       ; FE99CC  66 01
	ret                                                  ; FE99CE  0e
.LFE99CF:
	call BStoreCursor_Step                                        ; FE99CF  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE99D3  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE99D7  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE99DB  1d 04 22 ff
	ld wa, (EditField_Length:24)                                ; FE99DF  d2 47 1f 60 20
	div A,0x60                                           ; FE99E4  c9 0a 60
	and W,0x7f                                           ; FE99E7  c8 cc 7f
	ld A,W                                               ; FE99EA  c8 89
	call BStoreCursor_WriteByte                                        ; FE99EC  1d 4d 22 ff
	call BStoreCursor_Step                                        ; FE99F0  1d 04 22 ff
	ld wa, (EditField_Length:24)                                ; FE99F4  d2 47 1f 60 20
	div A,0x60                                           ; FE99F9  c9 0a 60
	and A,0x7f                                           ; FE99FC  c9 cc 7f
	call BStoreCursor_WriteByte                                        ; FE99FF  1d 4d 22 ff
	calr BStore_CursorSlot_Restore                                          ; FE9A03  1e 0f f3
	ret                                                  ; FE9A06  0e
; EditField_ApplyVelocityToEvent: when the event at the cursor is a note-on, byte +3 = (0x601F45) (cursor restored); then EditScreen_AuditionEvent.  Called by
;   the four steppers of 0x601F45 -- which is therefore the selected event's VELOCITY.
EditField_ApplyVelocityToEvent:
	calr BStore_CursorSlot_Save                                          ; FE9A07  1e e4 f2
	call BStoreCursor_ReadByte                                        ; FE9A0A  1d 32 22 ff
	and A,0xf0                                           ; FE9A0E  c9 cc f0
	cp A,0x90                                            ; FE9A11  c9 cf 90
	jr z, .LFE9A17                                       ; FE9A14  66 01
	ret                                                  ; FE9A16  0e
.LFE9A17:
	call BStoreCursor_Step                                        ; FE9A17  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9A1B  1d 04 22 ff
	call BStoreCursor_Step                                        ; FE9A1F  1d 04 22 ff
	ld a, (EditField_EventVelocity:24)                                 ; FE9A23  c2 45 1f 60 21
	call BStoreCursor_WriteByte                                        ; FE9A28  1d 4d 22 ff
	calr BStore_CursorSlot_Restore                                          ; FE9A2C  1e e6 f2
	calr EditScreen_AuditionEvent                                          ; FE9A2F  1e 03 0b
	ret                                                  ; FE9A32  0e
; ScreenButton_NoteEdit: the +8 BUTTON method of the screen object for screen id 0x25 -- PanelScreen_VtableTable entry 0x45
;   (ViewB entry 0x25) points at the thunk triple starting at T_EditScreen_EnterNoteEdit, and slot T_ScreenButton_NoteEdit jumps here.
ScreenButton_NoteEdit:
	cp HL,0x001f                                         ; FE9A33  db cf 1f 00
	jr gt, .LFE9A49                                      ; FE9A37  6a 10
	ld XIX,NoteEdit_ButtonTable                         ; FE9A39  44 4a 9a fe 00
	sll hl, 0x02                                         ; FE9A3E  db ee 02
	extz XHL                                             ; FE9A41  eb 12
	add XIX,XHL                                          ; FE9A43  eb 84
	ld XIX,(XIX)                                         ; FE9A45  a4 24
; (sub_FE9A47 removed 2026-10-04: no code names it and the line above falls through into it -- part of ScreenButton_NoteEdit;
;  notes/prom_a_stray_label_removal.py)
	call (xix)                                           ; FE9A47  b4 e8
.LFE9A49:
	ret                                                  ; FE9A49  0e
; ---------------------------------------------------------------------
; NoteEdit_ButtonTable -- 32 pointers, bounded reader
; Read by: 0xFE9A33 -- `cp HL,0x001F / jr ugt / ld XIX,0x00FE9A4A / ...`.
; ENTRY COUNT 32 is the reader's bound.
; Evidence: all 32 values are inside this module, the lowest 0xFE9ACA and
;          the highest 0xFE9B8C.
; ---------------------------------------------------------------------

NoteEdit_ButtonTable:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_NoteEdit
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_NoteEdit
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_NoteEdit
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_NoteEdit
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_NoteEdit
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_NoteEdit
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_NoteEdit
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_NoteEdit
	on_key	KEY_LcdRow1,		LcdKeyRow1_NoteEdit
	on_key	KEY_LcdRow2,		LcdKeyRow2_NoteEdit
	on_key	KEY_LcdRow3,		LcdKeyRow3_NoteEdit
	on_key	KEY_LcdRow4,		LcdKeyRow4_NoteEdit
	on_key	KEY_LcdRow5,		LcdKeyRow4_NoteEdit_Nop12
	on_key	KEY_MinusPlus,		LcdKeyRow4_NoteEdit_Nop12
	on_key	KEY_Code0E,		LcdKeyRow4_NoteEdit_Nop12
	on_key	KEY_Exit,		ExitKey_NoteEdit
	on_key	KEY_Page,		LcdKeyRow4_NoteEdit_Nop12
	on_key	KEY_Code11,		NoteEdit_Button17
	on_key	KEY_Code12,		NoteEdit_Button18
	on_key	KEY_Code13,		NoteEdit_Button19
	on_key	KEY_Code14,		NoteEdit_Button20
	on_key	KEY_Code15,		NoteEdit_Button21
	on_key	KEY_Code16,		NoteEdit_Button22
	on_key	KEY_Code17,		NoteEdit_Button23
	on_key	KEY_Code18,		NoteEdit_Button24
	on_key	KEY_Code19,		NoteEdit_Button24_Nop25
	on_key	KEY_Code1A,		NoteEdit_Button24_Nop25
	on_key	KEY_NumberPad,		NoteEdit_Button24_Nop25
	on_key	KEY_Code1C,		NoteEdit_Button24_Nop25
	on_key	KEY_Code1D,		NoteEdit_Button24_Nop25
	on_key	KEY_Compare,		NoteEdit_Button24_Nop25
	on_key	KEY_Code1F,		NoteEdit_Button24_Nop25
	keymap_end
; SoftKeyCol1_NoteEdit: the 1st of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x00.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol1_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A4A
	ld (PanelDial_UpButton:16), 0x00                                 ; FE9ACA  f1 9c 20 00 00
	ld (PanelDial_DownButton:16), 0x80                                 ; FE9ACF  f1 9b 20 00 80
	calr EditScreen_SoftKeyCol1                                          ; FE9AD4  1e 03 02
	ret                                                  ; FE9AD7  0e
; SoftKeyCol2_NoteEdit: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x01.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol2_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A4E
	ld (PanelDial_UpButton:16), 0x01                                 ; FE9AD8  f1 9c 20 00 01
	ld (PanelDial_DownButton:16), 0x81                                 ; FE9ADD  f1 9b 20 00 81
	calr EditScreen_SoftKeyCol2                                          ; FE9AE2  1e ad 02
	ret                                                  ; FE9AE5  0e
; SoftKeyCol3_NoteEdit: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x02.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol3_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A52
	ld (PanelDial_UpButton:16), 0x02                                 ; FE9AE6  f1 9c 20 00 02
	ld (PanelDial_DownButton:16), 0x82                                 ; FE9AEB  f1 9b 20 00 82
	calr EditScreen_SoftKeyCol3                                          ; FE9AF0  1e a4 05
	ret                                                  ; FE9AF3  0e
; SoftKeyCol4_NoteEdit: the 4th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x03.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol4_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A56
	ld (PanelDial_UpButton:16), 0x03                                 ; FE9AF4  f1 9c 20 00 03
	ld (PanelDial_DownButton:16), 0x83                                 ; FE9AF9  f1 9b 20 00 83
	calr EditScreen_SoftKeyCol4                                          ; FE9AFE  1e 4d 06
	ret                                                  ; FE9B01  0e
; SoftKeyCol5_NoteEdit: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x04.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol5_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A5A
	ld (PanelDial_UpButton:16), 0x04                                 ; FE9B02  f1 9c 20 00 04
	ld (PanelDial_DownButton:16), 0x84                                 ; FE9B07  f1 9b 20 00 84
	calr NoteEdit_SoftKeyCol5                                          ; FE9B0C  1e c6 06
	ret                                                  ; FE9B0F  0e
; SoftKeyCol6_NoteEdit: the 6th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x05.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol6_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A5E
	ld (PanelDial_UpButton:16), 0x05                                 ; FE9B10  f1 9c 20 00 05
	ld (PanelDial_DownButton:16), 0x85                                 ; FE9B15  f1 9b 20 00 85
	calr EditField_StepInc                                          ; FE9B1A  1e 88 07
	ret                                                  ; FE9B1D  0e
; SoftKeyCol7_NoteEdit: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x06.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol7_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A62
	ld (PanelDial_UpButton:16), 0x07                                 ; FE9B1E  f1 9c 20 00 07
	ld (PanelDial_DownButton:16), 0x06                                 ; FE9B23  f1 9b 20 00 06
	calr EditScreen_CursorLeft                                          ; FE9B28  1e 44 0d
	ret                                                  ; FE9B2B  0e
; SoftKeyCol8_NoteEdit: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; NoteEdit_ButtonTable slot 0x07.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol8_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A66
	ld (PanelDial_UpButton:16), 0x07                                 ; FE9B2C  f1 9c 20 00 07
	ld (PanelDial_DownButton:16), 0x06                                 ; FE9B31  f1 9b 20 00 06
	calr EditScreen_CursorRight                                          ; FE9B36  1e 33 08
	ret                                                  ; FE9B39  0e
; LcdKeyRow1_NoteEdit: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); NoteEdit_ButtonTable slot 0x08.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow1_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A6A
	calr NoteEdit_LcdKeyRow1                                          ; FE9B3A  1e 42 0e
	ret                                                  ; FE9B3D  0e
; LcdKeyRow2_NoteEdit: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); NoteEdit_ButtonTable slot 0x09.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow2_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A6E
	ld (PanelDial_UpButton:16), 0x09                                 ; FE9B3E  f1 9c 20 00 09
	ld (PanelDial_DownButton:16), 0x0a                                 ; FE9B43  f1 9b 20 00 0a
	calr NoteEdit_LcdKeyRow2                                          ; FE9B48  1e 55 0e
	ret                                                  ; FE9B4B  0e
; LcdKeyRow3_NoteEdit: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); NoteEdit_ButtonTable slot 0x0A.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow3_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A72
	ld (PanelDial_UpButton:16), 0x09                                 ; FE9B4C  f1 9c 20 00 09
	ld (PanelDial_DownButton:16), 0x0a                                 ; FE9B51  f1 9b 20 00 0a
	calr NoteEdit_LcdKeyRow3                                          ; FE9B56  1e 87 0e
	ret                                                  ; FE9B59  0e
; LcdKeyRow4_NoteEdit: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); NoteEdit_ButtonTable slot 0x0B.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow4_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A76
	calr EditScreen_LcdKeyRow4                                          ; FE9B5A  1e c3 0e
	ret                                                  ; FE9B5D  0e
LcdKeyRow4_NoteEdit_Nop12:   ; entry: named by 4 `.long` operands, first at 0xFE9A7A
	ret                                                  ; FE9B5E  0e
; ExitKey_NoteEdit: the EXIT key; NoteEdit_ButtonTable slot 0x0F.  Slot -> control: wave7_panel_names_round11.CONTROL.
ExitKey_NoteEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9A86
	bit 0x07,W                                           ; FE9B5F  c8 33 07
	jr nz, .LFE9B68                                      ; FE9B62  6e 04
	calr UI_GotoNoteEditPartSelect                                          ; FE9B64  1e 1f 0f
	ret                                                  ; FE9B67  0e
.LFE9B68:
	calr ExitKey_Sequencer_Nop                                          ; FE9B68  1e 7b e6
	ret                                                  ; FE9B6B  0e
; NoteEdit_Button17 -- NoteEdit_ButtonTable slot 0x11, NOT NAMED: slot 0x11 is only the VARIANT-1 already-held rewrite of base code 0x00
;   (SoftKeyCol1); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button17:   ; entry: named by 1 `.long` operand, first at 0xFE9A8E
	calr EditCursor_MeasureStepHeld                                          ; FE9B6C  1e 25 0f
	ret                                                  ; FE9B6F  0e
; NoteEdit_Button18 -- NoteEdit_ButtonTable slot 0x12, NOT NAMED: slot 0x12 is only the VARIANT-1 already-held rewrite of base code 0x01
;   (SoftKeyCol2); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button18:   ; entry: named by 1 `.long` operand, first at 0xFE9A92
	calr EditCursor_TickStepHeld                                          ; FE9B70  1e 9b 0f
	ret                                                  ; FE9B73  0e
; NoteEdit_Button19 -- NoteEdit_ButtonTable slot 0x13, NOT NAMED: slot 0x13 is only the VARIANT-1 already-held rewrite of base code 0x02
;   (SoftKeyCol3); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button19:   ; entry: named by 1 `.long` operand, first at 0xFE9A96
	calr EditCursor_NoteStepHeld                                          ; FE9B74  1e b9 0f
	ret                                                  ; FE9B77  0e
; NoteEdit_Button20 -- NoteEdit_ButtonTable slot 0x14, NOT NAMED: slot 0x14 is only the VARIANT-1 already-held rewrite of base code 0x03
;   (SoftKeyCol4); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button20:   ; entry: named by 1 `.long` operand, first at 0xFE9A9A
	calr EditField_VelocityStepHeld                                          ; FE9B78  1e 6e 10
	ret                                                  ; FE9B7B  0e
; NoteEdit_Button21 -- NoteEdit_ButtonTable slot 0x15, NOT NAMED: slot 0x15 is only the VARIANT-1 already-held rewrite of base code 0x04
;   (SoftKeyCol5); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button21:   ; entry: named by 1 `.long` operand, first at 0xFE9A9E
	calr EditField_StepLength12                                          ; FE9B7C  1e 37 11
	ret                                                  ; FE9B7F  0e
; NoteEdit_Button22 -- NoteEdit_ButtonTable slot 0x16, NOT NAMED: slot 0x16 is only the VARIANT-1 already-held rewrite of base code 0x05
;   (SoftKeyCol6); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button22:   ; entry: named by 1 `.long` operand, first at 0xFE9AA2
	calr EditField_StepInc5                                          ; FE9B80  1e 5e 12
	ret                                                  ; FE9B83  0e
; NoteEdit_Button23 -- NoteEdit_ButtonTable slot 0x17, NOT NAMED: slot 0x17 is only the VARIANT-1 already-held rewrite of base code 0x06
;   (SoftKeyCol7); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button23:   ; entry: named by 1 `.long` operand, first at 0xFE9AA6
	calr EditCursor_PrevBeatStart                                          ; FE9B84  1e d1 12
	ret                                                  ; FE9B87  0e
; NoteEdit_Button24 -- NoteEdit_ButtonTable slot 0x18, NOT NAMED: slot 0x18 is only the VARIANT-1 already-held rewrite of base code 0x07
;   (SoftKeyCol8); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
NoteEdit_Button24:   ; entry: named by 1 `.long` operand, first at 0xFE9AAA
	calr EditCursor_NextBeatStart                                          ; FE9B88  1e 70 12
	ret                                                  ; FE9B8B  0e
NoteEdit_Button24_Nop25:   ; entry: named by 7 `.long` operands, first at 0xFE9AAE
	ret                                                  ; FE9B8C  0e
; ScreenButton_DrumEdit: the +8 BUTTON method of the screen object for screen id 0x28 -- PanelScreen_VtableTable entry 0x48
;   (ViewB entry 0x28) points at the thunk triple starting at T_EditScreen_EnterDrumEdit, and slot T_ScreenButton_DrumEdit jumps here.
ScreenButton_DrumEdit:
	cp HL,0x001f                                         ; FE9B8D  db cf 1f 00
	jr gt, .LFE9BA3                                      ; FE9B91  6a 10
	ld XIX,DrumEdit_ButtonTable                         ; FE9B93  44 a4 9b fe 00
	sll hl, 0x02                                         ; FE9B98  db ee 02
	extz XHL                                             ; FE9B9B  eb 12
	add XIX,XHL                                          ; FE9B9D  eb 84
	ld XIX,(XIX)                                         ; FE9B9F  a4 24
	call (xix)                                           ; FE9BA1  b4 e8
.LFE9BA3:
	ret                                                  ; FE9BA3  0e
; ---------------------------------------------------------------------
; DrumEdit_ButtonTable -- 32 pointers, bounded reader
; Read by: 0xFE9B8D -- `cp HL,0x001F / jr ugt / ld XIX,0x00FE9BA4 / ...`.
; ENTRY COUNT 32 is the reader's bound.
; Evidence: all 32 values are inside this module, the lowest 0xFE9C24 and
;          the highest 0xFE9CD9.
; ---------------------------------------------------------------------

DrumEdit_ButtonTable:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_DrumEdit
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_DrumEdit
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_DrumEdit
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_DrumEdit
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_DrumEdit
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_DrumEdit
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_DrumEdit
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_DrumEdit
	on_key	KEY_LcdRow1,		LcdKeyRow1_DrumEdit
	on_key	KEY_LcdRow2,		LcdKeyRow2_DrumEdit
	on_key	KEY_LcdRow3,		LcdKeyRow3_DrumEdit
	on_key	KEY_LcdRow4,		LcdKeyRow4_DrumEdit
	on_key	KEY_LcdRow5,		LcdKeyRow4_DrumEdit_Nop12
	on_key	KEY_MinusPlus,		LcdKeyRow4_DrumEdit_Nop12
	on_key	KEY_Code0E,		LcdKeyRow4_DrumEdit_Nop12
	on_key	KEY_Exit,		ExitKey_DrumEdit
	on_key	KEY_Page,		LcdKeyRow4_DrumEdit_Nop12
	on_key	KEY_Code11,		DrumEdit_Button17
	on_key	KEY_Code12,		DrumEdit_Button18
	on_key	KEY_Code13,		DrumEdit_Button19
	on_key	KEY_Code14,		DrumEdit_Button20
	on_key	KEY_Code15,		DrumEdit_Button21
	on_key	KEY_Code16,		DrumEdit_Button22
	on_key	KEY_Code17,		DrumEdit_Button23
	on_key	KEY_Code18,		DrumEdit_Button23_Nop24
	on_key	KEY_Code19,		DrumEdit_Button23_Nop25
	on_key	KEY_Code1A,		DrumEdit_Button23_Nop25
	on_key	KEY_NumberPad,		DrumEdit_Button23_Nop25
	on_key	KEY_Code1C,		DrumEdit_Button23_Nop25
	on_key	KEY_Code1D,		DrumEdit_Button23_Nop25
	on_key	KEY_Compare,		DrumEdit_Button23_Nop25
	on_key	KEY_Code1F,		DrumEdit_Button23_Nop25
	keymap_end
; SoftKeyCol1_DrumEdit: the 1st of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x00.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol1_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BA4
	ld (PanelDial_UpButton:16), 0x00                                 ; FE9C24  f1 9c 20 00 00
	ld (PanelDial_DownButton:16), 0x80                                 ; FE9C29  f1 9b 20 00 80
	calr EditScreen_SoftKeyCol1                                      ; FE9C2E  1e a9 00
	ret                                                  ; FE9C31  0e
; SoftKeyCol2_DrumEdit: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x01.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol2_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BA8
	ld (PanelDial_UpButton:16), 0x01                                 ; FE9C32  f1 9c 20 00 01
	ld (PanelDial_DownButton:16), 0x81                                 ; FE9C37  f1 9b 20 00 81
	calr EditScreen_SoftKeyCol2                                      ; FE9C3C  1e 53 01
	ret                                                  ; FE9C3F  0e
; SoftKeyCol3_DrumEdit: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x02.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol3_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BAC
	ld (PanelDial_UpButton:16), 0x82                                 ; FE9C40  f1 9c 20 00 82
	ld (PanelDial_DownButton:16), 0x02                                 ; FE9C45  f1 9b 20 00 02
	calr EditScreen_SoftKeyCol3                                      ; FE9C4A  1e 4a 04
	ret                                                  ; FE9C4D  0e
; SoftKeyCol4_DrumEdit: the 4th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x03.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol4_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BB0
	ld (PanelDial_UpButton:16), 0x03                                 ; FE9C4E  f1 9c 20 00 03
	ld (PanelDial_DownButton:16), 0x83                                 ; FE9C53  f1 9b 20 00 83
	calr EditScreen_SoftKeyCol4                                      ; FE9C58  1e f3 04
	ret                                                  ; FE9C5B  0e
; SoftKeyCol5_DrumEdit: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x04.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol5_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BB4
	ld (PanelDial_UpButton:16), 0x04                                 ; FE9C5C  f1 9c 20 00 04
	ld (PanelDial_DownButton:16), 0x84                                 ; FE9C61  f1 9b 20 00 84
	calr EditField_StepInc                                      ; FE9C66  1e 3c 06
	ret                                                  ; FE9C69  0e
; SoftKeyCol6_DrumEdit: the 6th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x05.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol6_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BB8
	ld (PanelDial_UpButton:16), 0x06                                 ; FE9C6A  f1 9c 20 00 06
	ld (PanelDial_DownButton:16), 0x05                                 ; FE9C6F  f1 9b 20 00 05
	calr EditScreen_CursorLeft                                      ; FE9C74  1e f8 0b
	ret                                                  ; FE9C77  0e
; SoftKeyCol7_DrumEdit: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x06.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol7_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BBC
	ld (PanelDial_UpButton:16), 0x06                                 ; FE9C78  f1 9c 20 00 06
	ld (PanelDial_DownButton:16), 0x05                                 ; FE9C7D  f1 9b 20 00 05
	calr EditScreen_CursorRight                                      ; FE9C82  1e e7 06
	ret                                                  ; FE9C85  0e
; SoftKeyCol8_DrumEdit: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER (set) or UPPER (clear) of the column's two switches; DrumEdit_ButtonTable slot 0x07.  Slot -> control: wave7_panel_names_round11.CONTROL.
SoftKeyCol8_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BC0
	calr DrumEdit_SoftKeyCol8                                      ; FE9C86  1e 75 13
	ret                                                  ; FE9C89  0e
; LcdKeyRow1_DrumEdit: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); DrumEdit_ButtonTable slot 0x08.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow1_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BC4
	calr DrumEdit_LcdKeyRow1                                      ; FE9C8A  1e 43 13
	ret                                                  ; FE9C8D  0e
; LcdKeyRow2_DrumEdit: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); DrumEdit_ButtonTable slot 0x09.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow2_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BC8
	ld (PanelDial_UpButton:16), 0x0a                                 ; FE9C8E  f1 9c 20 00 0a
	ld (PanelDial_DownButton:16), 0x09                                 ; FE9C93  f1 9b 20 00 09
	calr DrumEdit_LcdKeyRow2                                      ; FE9C98  1e 8e 12
	ret                                                  ; FE9C9B  0e
; LcdKeyRow3_DrumEdit: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); DrumEdit_ButtonTable slot 0x0A.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow3_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BCC
	ld (PanelDial_UpButton:16), 0x0a                                 ; FE9C9C  f1 9c 20 00 0a
	ld (PanelDial_DownButton:16), 0x09                                 ; FE9CA1  f1 9b 20 00 09
	calr DrumEdit_LcdKeyRow3                                      ; FE9CA6  1e f2 11
	ret                                                  ; FE9CA9  0e
; LcdKeyRow4_DrumEdit: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side (set) or the CP1 side (clear); DrumEdit_ButtonTable slot 0x0B.  Slot -> control: wave7_panel_names_round11.CONTROL.
LcdKeyRow4_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BD0
	calr EditScreen_LcdKeyRow4                                      ; FE9CAA  1e 73 0d
	ret                                                  ; FE9CAD  0e
LcdKeyRow4_DrumEdit_Nop12:   ; entry: named by 4 `.long` operands, first at 0xFE9BD4
	ret                                                  ; FE9CAE  0e
; ExitKey_DrumEdit: the EXIT key; DrumEdit_ButtonTable slot 0x0F.  Slot -> control: wave7_panel_names_round11.CONTROL.
ExitKey_DrumEdit:   ; entry: named by 1 `.long` operand, first at 0xFE9BE0
	bit 0x07,W                                           ; FE9CAF  c8 33 07
	jr nz, .LFE9CB8                                      ; FE9CB2  6e 04
	calr UI_GotoDrumEditPartSelect                                      ; FE9CB4  1e d6 0d
	ret                                                  ; FE9CB7  0e
.LFE9CB8:
	calr ExitKey_Sequencer_Nop                                          ; FE9CB8  1e 2b e5
	ret                                                  ; FE9CBB  0e
; DrumEdit_Button17 -- DrumEdit_ButtonTable slot 0x11, NOT NAMED: slot 0x11 is only the VARIANT-1 already-held rewrite of base code 0x00
;   (SoftKeyCol1); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button17:   ; entry: named by 1 `.long` operand, first at 0xFE9BE8
	calr EditCursor_MeasureStepHeld                                      ; FE9CBC  1e d5 0d
	ret                                                  ; FE9CBF  0e
; DrumEdit_Button18 -- DrumEdit_ButtonTable slot 0x12, NOT NAMED: slot 0x12 is only the VARIANT-1 already-held rewrite of base code 0x01
;   (SoftKeyCol2); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button18:   ; entry: named by 1 `.long` operand, first at 0xFE9BEC
	calr EditCursor_TickStepHeld                                      ; FE9CC0  1e 4b 0e
	ret                                                  ; FE9CC3  0e
; DrumEdit_Button19 -- DrumEdit_ButtonTable slot 0x13, NOT NAMED: slot 0x13 is only the VARIANT-1 already-held rewrite of base code 0x02
;   (SoftKeyCol3); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button19:   ; entry: named by 1 `.long` operand, first at 0xFE9BF0
	calr EditCursor_NoteStepHeld                                      ; FE9CC4  1e 69 0e
	ret                                                  ; FE9CC7  0e
; DrumEdit_Button20 -- DrumEdit_ButtonTable slot 0x14, NOT NAMED: slot 0x14 is only the VARIANT-1 already-held rewrite of base code 0x03
;   (SoftKeyCol4); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button20:   ; entry: named by 1 `.long` operand, first at 0xFE9BF4
	calr EditField_VelocityStepHeld                                      ; FE9CC8  1e 1e 0f
	ret                                                  ; FE9CCB  0e
; DrumEdit_Button21 -- DrumEdit_ButtonTable slot 0x15, NOT NAMED: slot 0x15 is only the VARIANT-1 already-held rewrite of base code 0x04
;   (SoftKeyCol5); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button21:   ; entry: named by 1 `.long` operand, first at 0xFE9BF8
	calr EditField_StepInc5                                      ; FE9CCC  1e 12 11
	ret                                                  ; FE9CCF  0e
; DrumEdit_Button22 -- DrumEdit_ButtonTable slot 0x16, NOT NAMED: slot 0x16 is only the VARIANT-1 already-held rewrite of base code 0x05
;   (SoftKeyCol6); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button22:   ; entry: named by 1 `.long` operand, first at 0xFE9BFC
	calr EditCursor_PrevBeatStart                                      ; FE9CD0  1e 85 11
	ret                                                  ; FE9CD3  0e
; DrumEdit_Button23 -- DrumEdit_ButtonTable slot 0x17, NOT NAMED: slot 0x17 is only the VARIANT-1 already-held rewrite of base code 0x06
;   (SoftKeyCol7); the SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
DrumEdit_Button23:   ; entry: named by 1 `.long` operand, first at 0xFE9C00
	calr EditCursor_NextBeatStart                                      ; FE9CD4  1e 24 11
	ret                                                  ; FE9CD7  0e
DrumEdit_Button23_Nop24:   ; entry: named by 1 `.long` operand, first at 0xFE9C04
	ret                                                  ; FE9CD8  0e
DrumEdit_Button23_Nop25:   ; entry: named by 7 `.long` operands, first at 0xFE9C08
	ret                                                  ; FE9CD9  0e
; EditScreen_SoftKeyCol1: the SoftKeyCol1 action of DrumEdit, NoteEdit -- called only by SoftKeyCol1_DrumEdit, SoftKeyCol1_NoteEdit.
EditScreen_SoftKeyCol1:
	or	(UI_RequestBits:16), 0x08                            ; FE9CDA  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FE9CDF  f2 58 1f 60 cf
	jr z, .LFE9CEF                                       ; FE9CE4  66 09
	cp	(EditScreen_ActionIndex:24), 0x00                          ; FE9CE6  c2 59 1f 60 3f 00
	jr z, .LFE9CEF                                       ; FE9CEC  66 01
	ret                                                  ; FE9CEE  0e
.LFE9CEF:
	bit 0x07,W                                           ; FE9CEF  c8 33 07
	jr nz, .LFE9CF8                                      ; FE9CF2  6e 04
	calr EditCursor_MeasurePlus1                                      ; FE9CF4  1e 05 00
	ret                                                  ; FE9CF7  0e
.LFE9CF8:
	calr EditCursor_MeasureMinus1                                      ; FE9CF8  1e 1b 00
	ret                                                  ; FE9CFB  0e
; EditCursor_MeasurePlus1: EditCursor_Measure + 1 unless it is above 999, then EditCursor_MeasureChanged.  EditScreen_SoftKeyCol1 (MEAS), bit 7 clear.
EditCursor_MeasurePlus1:
	ld wa, (EditCursor_Measure:24)                                ; FE9CFC  d2 3f 1f 60 20
	cp WA,0x03e7                                         ; FE9D01  d8 cf e7 03
	jr ugt, .LFE9D12                                     ; FE9D05  6b 0b
	addw	(EditCursor_Measure:24), 0x0001                        ; FE9D07  d2 3f 1f 60 38 01 00
	calr EditCursor_MeasureChanged                                      ; FE9D0E  1e 1d 00
	ret                                                  ; FE9D11  0e
.LFE9D12:
	calr Transport_ResetAndStartBC_Nop                                          ; FE9D12  1e 2a e3
	ret                                                  ; FE9D15  0e
; EditCursor_MeasureMinus1: EditCursor_Measure - 1 unless it is 1, then EditCursor_MeasureChanged.  EditScreen_SoftKeyCol1 (MEAS), bit 7 set.
EditCursor_MeasureMinus1:
	ld wa, (EditCursor_Measure:24)                                ; FE9D16  d2 3f 1f 60 20
	cp wa, 0x01:i3                                         ; FE9D1B  d8 d9
	jr z, .LFE9D2A                                       ; FE9D1D  66 0b
	subw	(EditCursor_Measure:24), 0x0001                ; FE9D1F  d2 3f 1f 60 3a 01 00
	calr EditCursor_MeasureChanged                                      ; FE9D26  1e 05 00
	ret                                                  ; FE9D29  0e
.LFE9D2A:
	calr Transport_ResetAndStartBC_Nop                                          ; FE9D2A  1e 12 e3
	ret                                                  ; FE9D2D  0e
; EditCursor_MeasureChanged: redraws the measure (EditScreen_DrawMeasure between the bottom-row erases), (0x601F54) = 0, erases the edit area on
;   both layers, EditCursor_Beat = EditCursor_Tick = 0, (0x601F58) = 0x82, (0x601F59) = 0.  Called by the MEAS +-1 / +-10 steps.
EditCursor_MeasureChanged:
	calr EditScreen_EraseFieldRow                                          ; FE9D2E  1e 47 5a
	calr EditScreen_DrawMeasure                                          ; FE9D31  1e 55 6c
	calr EditScreen_EraseMarkerStrip                                          ; FE9D34  1e 5f 5a
	ldw (EditCursor_TickInMeasure:24), 0x00                             ; FE9D37  f2 54 1f 60 02 00 00
	calr EditScreen_EraseHeaderRow                                          ; FE9D3E  1e 73 5a
	calr EditScreen_EraseEditArea_Layer0                                          ; FE9D41  1e 8e 5a
	calr EditScreen_EraseEditArea_Layer1                                          ; FE9D44  1e 12 5b
	xor WA,WA                                            ; FE9D47  d8 d0
	ld (EditCursor_Beat:24), wa                                ; FE9D49  f2 41 1f 60 50
	ld (EditCursor_Tick:24), a                                 ; FE9D4E  f2 43 1f 60 41
	ld (EditScreen_ActionTimer:24), 0x82                             ; FE9D53  f2 58 1f 60 00 82
	ld (EditScreen_ActionIndex:24), 0x00                             ; FE9D59  f2 59 1f 60 00 00
	ret                                                  ; FE9D5F  0e
; EditCursor_MeasureChangedByCursor: the same with (0x601F58) = 0x81; called only by EditScreen_CursorRight.
EditCursor_MeasureChangedByCursor:
	calr EditScreen_EraseFieldRow                                          ; FE9D60  1e 15 5a
	calr EditScreen_DrawMeasure                                          ; FE9D63  1e 23 6c
	calr EditScreen_EraseMarkerStrip                                          ; FE9D66  1e 2d 5a
	ldw (EditCursor_TickInMeasure:24), 0x00                             ; FE9D69  f2 54 1f 60 02 00 00
	calr EditScreen_EraseHeaderRow                                          ; FE9D70  1e 41 5a
	calr EditScreen_EraseEditArea_Layer0                                          ; FE9D73  1e 5c 5a
	calr EditScreen_EraseEditArea_Layer1                                          ; FE9D76  1e e0 5a
	xor WA,WA                                            ; FE9D79  d8 d0
	ld (EditCursor_Beat:24), wa                                ; FE9D7B  f2 41 1f 60 50
	ld (EditCursor_Tick:24), a                                 ; FE9D80  f2 43 1f 60 41
	ld (EditScreen_ActionTimer:24), 0x81                             ; FE9D85  f2 58 1f 60 00 81
	ld (EditScreen_ActionIndex:24), 0x00                             ; FE9D8B  f2 59 1f 60 00 00
	ret                                                  ; FE9D91  0e
; EditScreen_SoftKeyCol2: the SoftKeyCol2 action of DrumEdit, NoteEdit -- called only by SoftKeyCol2_DrumEdit, SoftKeyCol2_NoteEdit.
EditScreen_SoftKeyCol2:
	or	(UI_RequestBits:16), 0x08                            ; FE9D92  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FE9D97  f2 58 1f 60 cf
	jr z, .LFE9DA7                                       ; FE9D9C  66 09
	cp	(EditScreen_ActionIndex:24), 0x01                          ; FE9D9E  c2 59 1f 60 3f 01
	jr z, .LFE9DA7                                       ; FE9DA4  66 01
	ret                                                  ; FE9DA6  0e
.LFE9DA7:
	bit 0x07,W                                           ; FE9DA7  c8 33 07
	jr nz, .LFE9DB0                                      ; FE9DAA  6e 04
	calr EditCursor_TickPlus1                                      ; FE9DAC  1e 05 00
	ret                                                  ; FE9DAF  0e
.LFE9DB0:
	calr EditCursor_TickMinus1                                      ; FE9DB0  1e c1 01
	ret                                                  ; FE9DB3  0e
; EditCursor_TickPlus1: EditCursor_Tick + 1; at 0x5F, EditCursor_NextBeat instead.
EditCursor_TickPlus1:
	cp	(EditCursor_Tick:24), 0x5f                          ; FE9DB4  c2 43 1f 60 3f 5f
	jr nc, .LFE9DBE                                      ; FE9DBA  6f 02
	jr .LFE9DC2                                          ; FE9DBC  68 04
.LFE9DBE:
	calr EditCursor_NextBeat                                      ; FE9DBE  1e 43 00
	ret                                                  ; FE9DC1  0e
.LFE9DC2:
	add	(EditCursor_Tick:24), 0x01                          ; FE9DC2  c2 43 1f 60 38 01
	calr EditScreen_DrawTick                                          ; FE9DC8  1e 87 6c
	calr EditCursor_RecomputeAndRedraw                                      ; FE9DCB  1e ed 00
	calr EditScreen_RedrawAfterTickMove                                          ; FE9DCE  1e 34 64
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9DD1  1e ae 02
	ret                                                  ; FE9DD4  0e
; EditCursor_TickPlus5: EditCursor_Tick + 5, clamped to 0x5F; at 0x5F, EditCursor_NextBeat instead.
EditCursor_TickPlus5:
	cp	(EditCursor_Tick:24), 0x5f                          ; FE9DD5  c2 43 1f 60 3f 5f
	jr nc, .LFE9DDF                                      ; FE9DDB  6f 02
	jr .LFE9DE3                                          ; FE9DDD  68 04
.LFE9DDF:
	calr EditCursor_NextBeat                                      ; FE9DDF  1e 22 00
	ret                                                  ; FE9DE2  0e
.LFE9DE3:
	add	(EditCursor_Tick:24), 0x05                          ; FE9DE3  c2 43 1f 60 38 05
	cp	(EditCursor_Tick:24), 0x5f                          ; FE9DE9  c2 43 1f 60 3f 5f
	jr ule, .LFE9DF7                                     ; FE9DEF  63 06
	ld (EditCursor_Tick:24), 0x5f                             ; FE9DF1  f2 43 1f 60 00 5f
.LFE9DF7:
	calr EditScreen_DrawTick                                          ; FE9DF7  1e 58 6c
	calr EditCursor_RecomputeAndRedraw                                      ; FE9DFA  1e be 00
	calr EditScreen_RedrawAfterTickMove                                          ; FE9DFD  1e 05 64
; EditScreen_QueueRelocateAfterMove_Call: calls EditScreen_QueueRelocateAfterMove and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
EditScreen_QueueRelocateAfterMove_Call:
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9E00  1e 7f 02
	ret                                                  ; FE9E03  0e
; EditCursor_NextBeat: tick 0 and beat + 1, or beat 0 and measure + 1 once the beat reaches EditCursor_BeatsInMeasure;
;   first, when (0x601F54) reaches (0x601F75) * 0x60 - 1, it scrolls instead.
EditCursor_NextBeat:
	ld c, (EditMeasure_Beats:24)                                 ; FE9E04  c2 75 1f 60 23
	mul C,0x60                                           ; FE9E09  cb 08 60
	dec 1,BC                                             ; FE9E0C  d9 69
	cp (EditCursor_TickInMeasure:24), bc                             ; FE9E0E  d2 54 1f 60 f9
	jr nc, .LFE9E17                                      ; FE9E13  6f 02
	jr .LFE9E4C                                          ; FE9E15  68 35
.LFE9E17:
	bit	0, (EditScreen_CursorFlags:24)                             ; FE9E17  f2 5b 1f 60 c8
	jr z, .LFE9E3B                                       ; FE9E1C  66 1d
	ld c, (EditMeasure_Beats:24)                                 ; FE9E1E  c2 75 1f 60 23
	mul C,0x60                                           ; FE9E23  cb 08 60
	ld (EditCursor_TickInMeasure:24), bc                                ; FE9E26  f2 54 1f 60 51
	calr EditCursor_WrapAndRecompute                                          ; FE9E2B  1e 64 f6
	ld (EditScreen_ActionTimer:24), 0x00                             ; FE9E2E  f2 58 1f 60 00 00
	calr EditScreen_InsertSelectedEventAtCursor                                          ; FE9E34  1e 2b f9
	calr EditScreen_ShowCursorMeasure                                          ; FE9E37  1e c1 f6
	ret                                                  ; FE9E3A  0e
.LFE9E3B:
	ld c, (EditMeasure_Beats:24)                                 ; FE9E3B  c2 75 1f 60 23
	mul C,0x60                                           ; FE9E40  cb 08 60
	ld (EditCursor_TickInMeasure:24), bc                                ; FE9E43  f2 54 1f 60 51
	calr EditScreen_WrapAndShowCursorMeasure                                          ; FE9E48  1e 12 f7
	ret                                                  ; FE9E4B  0e
.LFE9E4C:
	calr EditCursor_BeatsInMeasure                                      ; FE9E4C  1e d4 00
	cp A,0xff                                            ; FE9E4F  c9 cf ff
	jr z, .LFE9E5B                                       ; FE9E52  66 07
	cp (EditCursor_Beat:24), a                               ; FE9E54  c2 41 1f 60 f9
	jr nc, .LFE9E89                                      ; FE9E59  6f 2e
.LFE9E5B:
	ld (EditCursor_Tick:24), 0x00                             ; FE9E5B  f2 43 1f 60 00 00
	addw	(EditCursor_Beat:24), 0x0001                        ; FE9E61  d2 41 1f 60 38 01 00
	calr EditScreen_DrawTick                                          ; FE9E68  1e e7 6b
	calr EditScreen_DrawBeat                                          ; FE9E6B  1e 96 6b
	calr EditCursor_RecomputeAndRedraw                                      ; FE9E6E  1e 4a 00
	calr BStore_CursorSlot_Save                                          ; FE9E71  1e 7a ee
	calr EditCursor_SeekPastTick                                          ; FE9E74  1e d4 f9
	calr BStore_CursorSlot_Restore                                          ; FE9E77  1e 9b ee
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9E7A  c1 4a 0d 3f 00
	jr nz, .LFE9E85                                      ; FE9E7F  6e 04
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9E81  1e fe 01
	ret                                                  ; FE9E84  0e
.LFE9E85:
	calr EditScreen_FlagMemoryFull                                          ; FE9E85  1e 4c ed
	ret                                                  ; FE9E88  0e
.LFE9E89:
	ldw (EditCursor_Beat:24), 0x00                             ; FE9E89  f2 41 1f 60 02 00 00
	incw 0x01, (EditCursor_Measure:24)                          ; FE9E90  d2 3f 1f 60 61
	ld (EditCursor_Tick:24), 0x00                             ; FE9E95  f2 43 1f 60 00 00
	calr EditScreen_DrawMeasure                                          ; FE9E9B  1e eb 6a
	calr EditScreen_DrawTick                                          ; FE9E9E  1e b1 6b
	calr EditScreen_DrawBeat                                          ; FE9EA1  1e 60 6b
	calr EditCursor_RecomputeAndRedraw                                      ; FE9EA4  1e 14 00
	calr BStore_CursorSlot_Save                                          ; FE9EA7  1e 44 ee
	calr EditCursor_SeekPastTick                                          ; FE9EAA  1e 9e f9
	calr BStore_CursorSlot_Restore                                          ; FE9EAD  1e 65 ee
	cp	(BStore_ErrorCode:16), 0x00                            ; FE9EB0  c1 4a 0d 3f 00
	jr nz, .LFE9E85                                      ; FE9EB5  6e ce
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9EB7  1e c8 01
	ret                                                  ; FE9EBA  0e
; EditCursor_RecomputeAndRedraw: EditCursor_ComputeTickInView; inside the view: the cursor layer erased (EditScreen_EraseMarkerStrip),
;   EditScreen_DrawCursorTickMarker, the left rule, EditScreen_DrawDataEndMarker.  Called by every EditCursor_Tick* / *Beat move.
EditCursor_RecomputeAndRedraw:
	calr EditCursor_ComputeTickInView                                      ; FE9EBB  1e 1c 00
	ld c, (EditMeasure_Beats:24)                                 ; FE9EBE  c2 75 1f 60 23
	mul C,0x60                                           ; FE9EC3  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FE9EC6  d2 54 1f 60 f9
	jr nc, .LFE9ED9                                      ; FE9ECB  6f 0c
	calr EditScreen_EraseMarkerStrip                                          ; FE9ECD  1e c6 58
	calr EditScreen_DrawCursorTickMarker                                          ; FE9ED0  1e d9 5e
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FE9ED3  1e 83 5f
	calr EditScreen_DrawDataEndMarker                                          ; FE9ED6  1e 0c 5f
.LFE9ED9:
	ret                                                  ; FE9ED9  0e
; EditCursor_ComputeTickInView: EditCursor_TickInMeasure = (EditCursor_Beat + the first column of the cursor's measure) x 0x60 +
;   EditCursor_Tick, the column found as the first EditScreen_BeatTable entry equal to EditCursor_Measure -
;   (0x601F5D) + 1.  So the table holds, per beat column shown, the 1-based measure the column belongs to.
EditCursor_ComputeTickInView:
	ld wa, (EditCursor_Measure:24)                                ; FE9EDA  d2 3f 1f 60 20
	sub wa, (EditScreen_FirstMeasure:24)                            ; FE9EDF  d2 5d 1f 60 a0
	add A,0x01                                           ; FE9EE4  c9 c8 01
	ld E,A                                               ; FE9EE7  c9 8d
	xor BC,BC                                            ; FE9EE9  d9 d1
	ld XIX,EditScreen_BeatTable                                    ; FE9EEB  44 5f 1f 60 00
.LFE9EF0:
	cp (XIX),E                                           ; FE9EF0  84 fd
	jr z, .LFE9F0A                                       ; FE9EF2  66 16
	inc 1,BC                                             ; FE9EF4  d9 61
	inc 1,XIX                                            ; FE9EF6  ec 61
	ld XHL,EditScreen_BeatTable                                    ; FE9EF8  43 5f 1f 60 00
	xor XWA,XWA                                          ; FE9EFD  e8 d0
	ld a, (0x601f76:24)                                 ; FE9EFF  c2 76 1f 60 21
	add XHL,XWA                                          ; FE9F04  e8 83
	cp XIX,XHL                                           ; FE9F06  eb f4
	jr c, .LFE9EF0                                       ; FE9F08  67 e6
.LFE9F0A:
	ld wa, (EditCursor_Beat:24)                                ; FE9F0A  d2 41 1f 60 20
	add WA,BC                                            ; FE9F0F  d9 80
	mul A,0x60                                           ; FE9F11  c9 08 60
	xor HL,HL                                            ; FE9F14  db d3
	ld l, (EditCursor_Tick:24)                                 ; FE9F16  c2 43 1f 60 27
	add WA,HL                                            ; FE9F1B  db 80
	ld (EditCursor_TickInMeasure:24), wa                                ; FE9F1D  f2 54 1f 60 50
	ret                                                  ; FE9F22  0e
; EditCursor_BeatsInMeasure: A = the beat count of EditCursor_Measure, looked up in the table at 0x601F5F
;   ((0x601F76) entries, from measure (0x601F5D)); 0xFF when not found.
EditCursor_BeatsInMeasure:
	ld wa, (EditCursor_Measure:24)                                ; FE9F23  d2 3f 1f 60 20
	sub wa, (EditScreen_FirstMeasure:24)                            ; FE9F28  d2 5d 1f 60 a0
	inc 1,WA                                             ; FE9F2D  d8 61
	ld XIX,EditScreen_BeatTable                                    ; FE9F2F  44 5f 1f 60 00
.LFE9F34:
	cp A,(XIX)                                           ; FE9F34  84 f1
	jr z, .LFE9F4C                                       ; FE9F36  66 14
	inc 1,XIX                                            ; FE9F38  ec 61
	ld XHL,EditScreen_BeatTable                                    ; FE9F3A  43 5f 1f 60 00
	xor XBC,XBC                                          ; FE9F3F  e9 d1
	ld c, (0x601f76:24)                                 ; FE9F41  c2 76 1f 60 23
	add XHL,XBC                                          ; FE9F46  e9 83
	cp XIX,XHL                                           ; FE9F48  eb f4
	jr c, .LFE9F34                                       ; FE9F4A  67 e8
.LFE9F4C:
	inc 1,XIX                                            ; FE9F4C  ec 61
	ld a, 0x00:opc                                          ; FE9F4E  21 00
	cp (XIX),0x00                                        ; FE9F50  84 3f 00
	jr nz, .LFE9F73                                      ; FE9F53  6e 1e
.LFE9F55:
	cp (XIX),0x00                                        ; FE9F55  84 3f 00
	jr nz, .LFE9F73                                      ; FE9F58  6e 19
	inc 1,XIX                                            ; FE9F5A  ec 61
	inc 1,A                                              ; FE9F5C  c9 61
	ld XHL,EditScreen_BeatTable                                    ; FE9F5E  43 5f 1f 60 00
	xor XBC,XBC                                          ; FE9F63  e9 d1
	ld c, (0x601f76:24)                                 ; FE9F65  c2 76 1f 60 23
	add XHL,XBC                                          ; FE9F6A  e9 83
	cp XIX,XHL                                           ; FE9F6C  eb f4
	jr c, .LFE9F55                                       ; FE9F6E  67 e5
	ld a, 0xff:opc                                          ; FE9F70  21 ff
	ret                                                  ; FE9F72  0e
.LFE9F73:
	ret                                                  ; FE9F73  0e
; EditCursor_TickMinus1: EditCursor_Tick - 1, or EditCursor_PrevBeat at tick 0; then EditScreen_DrawTick and the redraws.  EditScreen_SoftKeyCol2
;   (POS) with bit 7 set -- the counterpart of EditCursor_TickPlus1.
EditCursor_TickMinus1:
	cp	(EditCursor_Tick:24), 0x00                          ; FE9F74  c2 43 1f 60 3f 00
	jr z, .LFE9F7E                                       ; FE9F7A  66 02
	jr .LFE9F82                                          ; FE9F7C  68 04
.LFE9F7E:
	calr EditCursor_PrevBeat                                      ; FE9F7E  1e 46 00
	ret                                                  ; FE9F81  0e
.LFE9F82:
	sub	(EditCursor_Tick:24), 0x01                  ; FE9F82  c2 43 1f 60 3a 01
	calr EditScreen_DrawTick                                          ; FE9F88  1e c7 6a
	calr EditCursor_RecomputeAndRedraw                                      ; FE9F8B  1e 2d ff
	calr EditScreen_RedrawAfterTickMove                                          ; FE9F8E  1e 74 62
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9F91  1e ee 00
	ret                                                  ; FE9F94  0e
; EditCursor_TickMinus5: EditCursor_Tick - 5, floored at 0 (EditCursor_PrevBeat at tick 0) -- the counterpart of EditCursor_TickPlus5.
EditCursor_TickMinus5:
	cp	(EditCursor_Tick:24), 0x00                          ; FE9F95  c2 43 1f 60 3f 00
	jr z, .LFE9F9F                                       ; FE9F9B  66 02
	jr .LFE9FA3                                          ; FE9F9D  68 04
.LFE9F9F:
	calr EditCursor_PrevBeat                                      ; FE9F9F  1e 25 00
	ret                                                  ; FE9FA2  0e
.LFE9FA3:
	ld a, (EditCursor_Tick:24)                                 ; FE9FA3  c2 43 1f 60 21
	sub A,0x05                                           ; FE9FA8  c9 ca 05
	jr c, .LFE9FBF                                       ; FE9FAB  67 12
	ld (EditCursor_Tick:24), a                                 ; FE9FAD  f2 43 1f 60 41
.LFE9FB2:
	calr EditScreen_DrawTick                                          ; FE9FB2  1e 9d 6a
	calr EditCursor_RecomputeAndRedraw                                      ; FE9FB5  1e 03 ff
	calr EditScreen_RedrawAfterTickMove                                          ; FE9FB8  1e 4a 62
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9FBB  1e c4 00
	ret                                                  ; FE9FBE  0e
.LFE9FBF:
	ld (EditCursor_Tick:24), 0x00                             ; FE9FBF  f2 43 1f 60 00 00
	jr .LFE9FB2                                          ; FE9FC5  68 eb
; EditCursor_PrevBeat: at beat > 0: EditCursor_Beat - 1 with EditCursor_Tick = 0x5F (the beat's last of 96 ticks); at beat 0, the previous
;   measure's last tick (EditCursor_Measure - 1) or the boundary handling of (0x601F5D) / (0x601F5B).  The counterpart of
;   EditCursor_NextBeat.
EditCursor_PrevBeat:
	cpw	(EditCursor_Beat:24), 0x0000                        ; FE9FC7  d2 41 1f 60 3f 00 00
	jr z, .LFE9FEA                                       ; FE9FCE  66 1a
	ld (EditCursor_Tick:24), 0x5f                             ; FE9FD0  f2 43 1f 60 00 5f
	subw	(EditCursor_Beat:24), 0x0001                ; FE9FD6  d2 41 1f 60 3a 01 00
	calr EditScreen_DrawTick                                          ; FE9FDD  1e 72 6a
	calr EditScreen_DrawBeat                                          ; FE9FE0  1e 21 6a
	calr EditCursor_RecomputeAndRedraw                                      ; FE9FE3  1e d5 fe
	calr EditScreen_QueueRelocateAfterMove                                      ; FE9FE6  1e 99 00
	ret                                                  ; FE9FE9  0e
.LFE9FEA:
	ld wa, (EditCursor_Measure:24)                                ; FE9FEA  d2 3f 1f 60 20
	cp	wa, (EditScreen_FirstMeasure:24)                            ; FE9FEF  d2 5d 1f 60 f0
	jr nz, .LFEA017                                      ; FE9FF4  6e 21
	bit	0, (EditScreen_CursorFlags:24)                             ; FE9FF6  f2 5b 1f 60 c8
	jr z, .LFEA013                                       ; FE9FFB  66 16
	cpw	(EditCursor_Measure:24), 0x0001                        ; FE9FFD  d2 3f 1f 60 3f 01 00
	jr z, .LFEA012                                       ; FEA004  66 0c
	ld (EditScreen_ActionTimer:24), 0x00                             ; FEA006  f2 58 1f 60 00 00
	calr EditScreen_InsertSelectedEventAtCursor                                          ; FEA00C  1e 53 f7
	calr EditScreen_ShowPreviousMeasureAtTick                                          ; FEA00F  1e 82 f6
.LFEA012:
	ret                                                  ; FEA012  0e
.LFEA013:
	calr EditScreen_ShowPreviousMeasure                                          ; FEA013  1e 32 f6
	ret                                                  ; FEA016  0e
.LFEA017:
	calr EditCursor_SetLastBeatOfPrevMeasure                                      ; FEA017  1e 1d 00
	subw	(EditCursor_Measure:24), 0x0001                ; FEA01A  d2 3f 1f 60 3a 01 00
	ld (EditCursor_Tick:24), 0x5f                             ; FEA021  f2 43 1f 60 00 5f
	calr EditScreen_DrawMeasure                                          ; FEA027  1e 5f 69
	calr EditScreen_DrawTick                                          ; FEA02A  1e 25 6a
	calr EditScreen_DrawBeat                                          ; FEA02D  1e d4 69
	calr EditCursor_RecomputeAndRedraw                                      ; FEA030  1e 88 fe
	calr EditScreen_QueueRelocateAfterMove                                      ; FEA033  1e 4c 00
	ret                                                  ; FEA036  0e
; EditCursor_SetLastBeatOfPrevMeasure: EditCursor_Beat := the last beat (0-based) of the measure before the cursor's,
;   counted in EditScreen_BeatTable: finds the column holding the cursor measure's ordinal, then counts the zero
;   entries before it back to the previous ordinal. EditCursor_PrevBeat's beat-0 step when the view has an earlier
;   measure; it then decrements EditCursor_Measure. Basis: caller + body + table. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
EditCursor_SetLastBeatOfPrevMeasure:
	ld wa, (EditCursor_Measure:24)                                ; FEA037  d2 3f 1f 60 20
	sub wa, (EditScreen_FirstMeasure:24)                            ; FEA03C  d2 5d 1f 60 a0
	inc 1,WA                                             ; FEA041  d8 61
	ld XIX,EditScreen_BeatTable                                    ; FEA043  44 5f 1f 60 00
.LFEA048:
	cp A,(XIX)                                           ; FEA048  84 f1
	jr z, .LFEA060                                       ; FEA04A  66 14
	inc 1,XIX                                            ; FEA04C  ec 61
	ld XHL,EditScreen_BeatTable                                    ; FEA04E  43 5f 1f 60 00
	xor XBC,XBC                                          ; FEA053  e9 d1
	ld c, (0x601f76:24)                                 ; FEA055  c2 76 1f 60 23
	add XHL,XBC                                          ; FEA05A  e9 83
	cp XIX,XHL                                           ; FEA05C  eb f4
	jr c, .LFEA048                                       ; FEA05E  67 e8
.LFEA060:
	xor WA,WA                                            ; FEA060  d8 d0
	ld a, 0x00:opc                                          ; FEA062  21 00
	dec 1,XIX                                            ; FEA064  ec 69
	cp (XIX),0x00                                        ; FEA066  84 3f 00
	jr nz, .LFEA07C                                      ; FEA069  6e 11
.LFEA06B:
	cp (XIX),0x00                                        ; FEA06B  84 3f 00
	jr nz, .LFEA07C                                      ; FEA06E  6e 0c
	inc 1,A                                              ; FEA070  c9 61
	dec 1,XIX                                            ; FEA072  ec 69
	cp XIX,EditScreen_BeatTable                                    ; FEA074  ec cf 5f 1f 60 00
	jr nc, .LFEA06B                                      ; FEA07A  6f ef
.LFEA07C:
	ld (EditCursor_Beat:24), wa                                ; FEA07C  f2 41 1f 60 50
	ret                                                  ; FEA081  0e
; EditScreen_QueueRelocateAfterMove: with an event selected: EditScreen_ActionTimer = 0x85, EditScreen_ActionIndex = 1 -- deferred action 1 five
;   ticks later.
EditScreen_QueueRelocateAfterMove:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA082  f2 5b 1f 60 c8
	jr nz, .LFEA08A                                      ; FEA087  6e 01
	ret                                                  ; FEA089  0e
.LFEA08A:
	ld (EditScreen_ActionTimer:24), 0x85                             ; FEA08A  f2 58 1f 60 00 85
	ld (EditScreen_ActionIndex:24), 0x01                             ; FEA090  f2 59 1f 60 00 01
	ret                                                  ; FEA096  0e
; EditScreen_SoftKeyCol3: the SoftKeyCol3 action of DrumEdit, NoteEdit -- called only by SoftKeyCol3_DrumEdit, SoftKeyCol3_NoteEdit.
EditScreen_SoftKeyCol3:
	or	(UI_RequestBits:16), 0x08                            ; FEA097  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA09C  f2 58 1f 60 cf
	jr z, .LFEA0AC                                       ; FEA0A1  66 09
	cp	(EditScreen_ActionIndex:24), 0x02                          ; FEA0A3  c2 59 1f 60 3f 02
	jr z, .LFEA0AC                                       ; FEA0A9  66 01
	ret                                                  ; FEA0AB  0e
.LFEA0AC:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA0AC  f2 5b 1f 60 c8
	jr nz, .LFEA0B4                                      ; FEA0B1  6e 01
	ret                                                  ; FEA0B3  0e
.LFEA0B4:
	bit	0, (EditScreen_Mode:24)                             ; FEA0B4  f2 70 1f 60 c8
	jr z, .LFEA0C2                                       ; FEA0B9  66 07
	bit 0x07,W                                           ; FEA0BB  c8 33 07
	jr z, .LFEA0CB                                       ; FEA0BE  66 0b
	jr .LFEA0C7                                          ; FEA0C0  68 05
.LFEA0C2:
	bit 0x07,W                                           ; FEA0C2  c8 33 07
	jr nz, .LFEA0CB                                      ; FEA0C5  6e 04
.LFEA0C7:
	calr EditCursor_NoteUp                                      ; FEA0C7  1e 05 00
	ret                                                  ; FEA0CA  0e
.LFEA0CB:
	calr EditCursor_NoteDown                                      ; FEA0CB  1e 30 00
	ret                                                  ; FEA0CE  0e
; EditCursor_NoteUp: EditScreen_SoftKeyCol3's up arm: (0x601F44) + 1 below 0x7F; in DRUM EDIT DrumEdit_RowFollowNoteUp; then EditCursor_ApplyNoteToEvent,
;   EditScreen_DrawCursorNote, EditScreen_RedrawEditArea and (0x601F58) = 0x83, (0x601F59) = 2.
EditCursor_NoteUp:
	cp	(EditCursor_Note:24), 0x7f                          ; FEA0CF  c2 44 1f 60 3f 7f
	jr c, .LFEA0D8                                       ; FEA0D5  67 01
	ret                                                  ; FEA0D7  0e
.LFEA0D8:
	add	(EditCursor_Note:24), 0x01                          ; FEA0D8  c2 44 1f 60 38 01
	bit	0, (EditScreen_Mode:24)                             ; FEA0DE  f2 70 1f 60 c8
	jr z, .LFEA0E8                                       ; FEA0E3  66 03
	calr DrumEdit_RowFollowNoteUp                                      ; FEA0E5  1e d4 0d
.LFEA0E8:
	calr EditCursor_ApplyNoteToEvent                                          ; FEA0E8  1e ac f8
	calr EditScreen_DrawCursorNote                                          ; FEA0EB  1e 8d 69
	calr EditScreen_RedrawEditArea                                      ; FEA0EE  1e 3c 00
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEA0F1  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x02                             ; FEA0F7  f2 59 1f 60 00 02
	ret                                                  ; FEA0FD  0e
; EditCursor_NoteDown: the down arm: (0x601F44) - 1 above 1; in DRUM EDIT DrumEdit_RowFollowNoteDown; the same refresh.
EditCursor_NoteDown:
	cp	(EditCursor_Note:24), 0x01                          ; FEA0FE  c2 44 1f 60 3f 01
	jr nz, .LFEA107                                      ; FEA104  6e 01
	ret                                                  ; FEA106  0e
.LFEA107:
	sub	(EditCursor_Note:24), 0x01                  ; FEA107  c2 44 1f 60 3a 01
	bit	0, (EditScreen_Mode:24)                             ; FEA10D  f2 70 1f 60 c8
	jr z, .LFEA117                                       ; FEA112  66 03
	calr DrumEdit_RowFollowNoteDown                                      ; FEA114  1e 33 0e
.LFEA117:
	calr EditCursor_ApplyNoteToEvent                                          ; FEA117  1e 7d f8
	calr EditScreen_DrawCursorNote                                          ; FEA11A  1e 5e 69
	calr EditScreen_RedrawEditArea                                      ; FEA11D  1e 0d 00
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEA120  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x02                             ; FEA126  f2 59 1f 60 00 02
	ret                                                  ; FEA12C  0e
; EditScreen_RedrawEditArea: with (0x601F58) bit 7: erase layer 1, EditScreen_FillSelectedEventBar, LCD_DrawVRuleLeft_OrNothing; otherwise erase layer 0 and
;   redraw the events (EditScreen_DrawVisibleNotesExceptSelected) first.
EditScreen_RedrawEditArea:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA12D  f2 58 1f 60 cf
	jr z, .LFEA13E                                       ; FEA132  66 0a
	calr EditScreen_EraseEditArea_Layer1                                          ; FEA134  1e 22 57
	calr EditScreen_FillSelectedEventBar                                          ; FEA137  1e 63 60
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FEA13A  1e 1c 5d
	ret                                                  ; FEA13D  0e
.LFEA13E:
	calr EditScreen_EraseEditArea_Layer0                                          ; FEA13E  1e 91 56
	calr EditScreen_DrawVisibleNotesExceptSelected                                          ; FEA141  1e e9 5d
	calr EditScreen_EraseEditArea_Layer1                                          ; FEA144  1e 12 57
	calr EditScreen_FillSelectedEventBar                                          ; FEA147  1e 53 60
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FEA14A  1e 0c 5d
	ret                                                  ; FEA14D  0e
; EditScreen_SoftKeyCol4: the SoftKeyCol4 action of DrumEdit, NoteEdit -- called only by SoftKeyCol4_DrumEdit, SoftKeyCol4_NoteEdit.
EditScreen_SoftKeyCol4:
	or	(UI_RequestBits:16), 0x08                            ; FEA14E  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA153  f2 58 1f 60 cf
	jr z, .LFEA15B                                       ; FEA158  66 01
.LFEA15A:
	ret                                                  ; FEA15A  0e
.LFEA15B:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA15B  f2 5b 1f 60 c8
	jr nz, .LFEA176                                      ; FEA160  6e 14
	bit	0, (EditScreen_Mode:24)                             ; FEA162  f2 70 1f 60 c8
	jr z, .LFEA15A                                       ; FEA167  66 f1
	bit 0x07,W                                           ; FEA169  c8 33 07
	jr nz, .LFEA172                                      ; FEA16C  6e 04
	calr EditField_NewNoteVelocityUp                                      ; FEA16E  1e 3e 00
	ret                                                  ; FEA171  0e
.LFEA172:
	calr EditField_NewNoteVelocityDown                                      ; FEA172  1e 4d 00
	ret                                                  ; FEA175  0e
.LFEA176:
	bit 0x07,W                                           ; FEA176  c8 33 07
	jr nz, .LFEA17F                                      ; FEA179  6e 04
	calr EditField_EventVelocityUp                                      ; FEA17B  1e 05 00
	ret                                                  ; FEA17E  0e
.LFEA17F:
	calr EditField_EventVelocityDown                                      ; FEA17F  1e 17 00
	ret                                                  ; FEA182  0e
; EditField_EventVelocityUp: (0x601F45), the NOTE field, + 1 up to 0x7F; redraws (0xFF0B46, 0xFE9A07).  NOTE EDIT draws the fields MEAS POS NOTE VEL LEN INC (DisplayList_NoteEditTrackSong).
; EditField_EventVelocityUp: CORRECTED 2026-10-04: 0x601F45 is the selected note-on's VELOCITY, byte +3 (EditField_ApplyVelocityToEvent writes it
;   there; EditScreen_DrawEventVelocity draws it in the same cell as the new-note velocity), not the NOTE: the NOTE
;   column is EditCursor_Note.  EditScreen_SoftKeyCol4 steps it while an event is selected ((0x601F5B) bit 0).
EditField_EventVelocityUp:
	cp	(EditField_EventVelocity:24), 0x7f                          ; FEA183  c2 45 1f 60 3f 7f
	jr c, .LFEA18C                                       ; FEA189  67 01
	ret                                                  ; FEA18B  0e
.LFEA18C:
	add	(EditField_EventVelocity:24), 0x01                          ; FEA18C  c2 45 1f 60 38 01
	calr EditScreen_DrawEventVelocity                                          ; FEA192  1e b1 69
	calr EditField_ApplyVelocityToEvent                                          ; FEA195  1e 6f f8
	ret                                                  ; FEA198  0e
; EditField_EventVelocityDown: (0x601F45) - 1 down to 1; redraws.
; EditField_EventVelocityDown: CORRECTED 2026-10-04: 0x601F45 is the selected note-on's VELOCITY, byte +3 (EditField_ApplyVelocityToEvent writes it
;   there; EditScreen_DrawEventVelocity draws it in the same cell as the new-note velocity), not the NOTE: the NOTE
;   column is EditCursor_Note.  EditScreen_SoftKeyCol4 steps it while an event is selected ((0x601F5B) bit 0).
EditField_EventVelocityDown:
	cp	(EditField_EventVelocity:24), 0x01                          ; FEA199  c2 45 1f 60 3f 01
	jr nz, .LFEA1A2                                      ; FEA19F  6e 01
	ret                                                  ; FEA1A1  0e
.LFEA1A2:
	sub	(EditField_EventVelocity:24), 0x01                  ; FEA1A2  c2 45 1f 60 3a 01
	calr EditScreen_DrawEventVelocity                                          ; FEA1A8  1e 9b 69
	calr EditField_ApplyVelocityToEvent                                          ; FEA1AB  1e 59 f8
	ret                                                  ; FEA1AE  0e
; EditField_NewNoteVelocityUp: (0x601F46), the VEL field (1..127, 100 by default from 0xFE833F), + 1 up to 0x7F; redraws (0xFF0B3A).
; EditField_NewNoteVelocityUp: CORRECTED 2026-10-04: 0x601F46 is the velocity a NEW note gets (100 by default); EditScreen_SoftKeyCol4 steps it
;   in DRUM EDIT when no event is selected, and EditScreen_DrawNewNoteVelocity shows it in the VEL cell.
EditField_NewNoteVelocityUp:
	cp	(EditField_NewNoteVelocity:24), 0x7f                          ; FEA1AF  c2 46 1f 60 3f 7f
	jr c, .LFEA1B8                                       ; FEA1B5  67 01
	ret                                                  ; FEA1B7  0e
.LFEA1B8:
	add	(EditField_NewNoteVelocity:24), 0x01                          ; FEA1B8  c2 46 1f 60 38 01
	calr EditScreen_DrawNewNoteVelocity                                          ; FEA1BE  1e 79 69
	ret                                                  ; FEA1C1  0e
; EditField_NewNoteVelocityDown: (0x601F46) - 1 down to 1; redraws.
; EditField_NewNoteVelocityDown: CORRECTED 2026-10-04: 0x601F46 is the velocity a NEW note gets (100 by default); EditScreen_SoftKeyCol4 steps it
;   in DRUM EDIT when no event is selected, and EditScreen_DrawNewNoteVelocity shows it in the VEL cell.
EditField_NewNoteVelocityDown:
	cp	(EditField_NewNoteVelocity:24), 0x01                          ; FEA1C2  c2 46 1f 60 3f 01
	jr nz, .LFEA1CB                                      ; FEA1C8  6e 01
	ret                                                  ; FEA1CA  0e
.LFEA1CB:
	sub	(EditField_NewNoteVelocity:24), 0x01                  ; FEA1CB  c2 46 1f 60 3a 01
	calr EditScreen_DrawNewNoteVelocity                                          ; FEA1D1  1e 66 69
	ret                                                  ; FEA1D4  0e
; NoteEdit_SoftKeyCol5: the SoftKeyCol5 action of NoteEdit -- called only by SoftKeyCol5_NoteEdit.
NoteEdit_SoftKeyCol5:
	or	(UI_RequestBits:16), 0x08                            ; FEA1D5  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA1DA  f2 58 1f 60 cf
	jr z, .LFEA1EA                                       ; FEA1DF  66 09
	cp	(EditScreen_ActionIndex:24), 0x03                          ; FEA1E1  c2 59 1f 60 3f 03
	jr z, .LFEA1EA                                       ; FEA1E7  66 01
	ret                                                  ; FEA1E9  0e
.LFEA1EA:
	bit 0x07,W                                           ; FEA1EA  c8 33 07
	jr nz, .LFEA1F3                                      ; FEA1ED  6e 04
	calr EditField_LengthUp                                      ; FEA1EF  1e 05 00
	ret                                                  ; FEA1F2  0e
.LFEA1F3:
	calr EditField_LengthDown                                      ; FEA1F3  1e 46 00
	ret                                                  ; FEA1F6  0e
; EditField_LengthUp: the LEN field + 1 up to 0x2FFF: (0x601F47), or (0x601F49) when (0x601F5B) bit 0 is clear; redraws.
EditField_LengthUp:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA1F7  f2 5b 1f 60 c8
	jr nz, .LFEA200                                      ; FEA1FC  6e 02
	jr T,.LFEA227                                        ; FEA1FE  68 27
.LFEA200:
	cpw	(EditField_Length:24), 0x2fff                        ; FEA200  d2 47 1f 60 3f ff 2f
	jr c, .LFEA20A                                       ; FEA207  67 01
	ret                                                  ; FEA209  0e
.LFEA20A:
	addw	(EditField_Length:24), 0x0001                        ; FEA20A  d2 47 1f 60 38 01 00
	calr EditField_StoreLengthInNoteEvent                                          ; FEA211  1e ab f7
	calr EditScreen_DrawEventLength                                      ; FEA214  1e da 69
	calr EditScreen_RedrawEditArea                                      ; FEA217  1e 13 ff
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEA21A  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEA220  f2 59 1f 60 00 03
	ret                                                  ; FEA226  0e
.LFEA227:
	cpw	(EditField_NewNoteLength:24), 0x2fff                        ; FEA227  d2 49 1f 60 3f ff 2f
	jr c, .LFEA231                                       ; FEA22E  67 01
	ret                                                  ; FEA230  0e
.LFEA231:
	addw	(EditField_NewNoteLength:24), 0x0001                        ; FEA231  d2 49 1f 60 38 01 00
	calr EditScreen_DrawNewNoteLength                                          ; FEA238  1e d7 69
	ret                                                  ; FEA23B  0e
; EditField_LengthDown: the LEN field - 1 down to 1 (0 becomes 1); redraws.
EditField_LengthDown:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA23C  f2 5b 1f 60 c8
	jr nz, .LFEA245                                      ; FEA241  6e 02
	jr .LFEA27E                                          ; FEA243  68 39
.LFEA245:
	cpw	(EditField_Length:24), 0x0000                        ; FEA245  d2 47 1f 60 3f 00 00
	jr z, .LFEA258                                       ; FEA24C  66 0a
	cpw	(EditField_Length:24), 0x0001                        ; FEA24E  d2 47 1f 60 3f 01 00
	jr ugt, .LFEA261                                     ; FEA255  6b 0a
	ret                                                  ; FEA257  0e
.LFEA258:
	ldw (EditField_Length:24), 0x01                             ; FEA258  f2 47 1f 60 02 01 00
	jr .LFEA268                                          ; FEA25F  68 07
.LFEA261:
	subw	(EditField_Length:24), 0x0001                ; FEA261  d2 47 1f 60 3a 01 00
.LFEA268:
	calr EditField_StoreLengthInNoteEvent                                          ; FEA268  1e 54 f7
	calr EditScreen_DrawEventLength                                      ; FEA26B  1e 83 69
	calr EditScreen_RedrawEditArea                                      ; FEA26E  1e bc fe
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEA271  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEA277  f2 59 1f 60 00 03
	ret                                                  ; FEA27D  0e
.LFEA27E:
	cpw	(EditField_NewNoteLength:24), 0x0000                        ; FEA27E  d2 49 1f 60 3f 00 00
	jr z, .LFEA291                                       ; FEA285  66 0a
	cpw	(EditField_NewNoteLength:24), 0x0001                        ; FEA287  d2 49 1f 60 3f 01 00
	jr nz, .LFEA29A                                      ; FEA28E  6e 0a
	ret                                                  ; FEA290  0e
.LFEA291:
	ldw (EditField_NewNoteLength:24), 0x01                             ; FEA291  f2 49 1f 60 02 01 00
	jr .LFEA2A1                                          ; FEA298  68 07
.LFEA29A:
	subw	(EditField_NewNoteLength:24), 0x0001                ; FEA29A  d2 49 1f 60 3a 01 00
.LFEA2A1:
	calr EditScreen_DrawNewNoteLength                                          ; FEA2A1  1e 6e 69
	ret                                                  ; FEA2A4  0e
; EditField_StepInc: repaint bit 3; unless (0x601F58) bit 7: W bit 7 clear -> EditField_IncUp, set -> EditField_IncDown (the key's two halves).
EditField_StepInc:
	or	(UI_RequestBits:16), 0x08                            ; FEA2A5  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA2AA  f2 58 1f 60 cf
	jr z, .LFEA2B2                                       ; FEA2AF  66 01
	ret                                                  ; FEA2B1  0e
.LFEA2B2:
	bit 0x07,W                                           ; FEA2B2  c8 33 07
	jr nz, .LFEA2BB                                      ; FEA2B5  6e 04
	calr EditField_IncUp                                      ; FEA2B7  1e 05 00
	ret                                                  ; FEA2BA  0e
.LFEA2BB:
	calr EditField_IncDown                                      ; FEA2BB  1e 16 00
	ret                                                  ; FEA2BE  0e
; EditField_IncUp: (0x601F4D), the INC field (cursor step in ticks), + 1 up to 0x60; redraws (0xFF0D03).
EditField_IncUp:
	cpw	(EditField_Inc:24), 0x0060                        ; FEA2BF  d2 4d 1f 60 3f 60 00
	jr c, .LFEA2C9                                       ; FEA2C6  67 01
	ret                                                  ; FEA2C8  0e
.LFEA2C9:
	addw	(EditField_Inc:24), 0x0001                        ; FEA2C9  d2 4d 1f 60 38 01 00
	calr EditScreen_DrawInc                                          ; FEA2D0  1e 30 6a
	ret                                                  ; FEA2D3  0e
; EditField_IncDown: (0x601F4D) - 1 down to 1; at 0 it is reset to 0x30; redraws.
EditField_IncDown:
	cpw	(EditField_Inc:24), 0x0000                        ; FEA2D4  d2 4d 1f 60 3f 00 00
	jr z, .LFEA2E7                                       ; FEA2DB  66 0a
	cpw	(EditField_Inc:24), 0x0001                        ; FEA2DD  d2 4d 1f 60 3f 01 00
	jr ugt, .LFEA2F2                                     ; FEA2E4  6b 0c
	ret                                                  ; FEA2E6  0e
.LFEA2E7:
	ldw (EditField_Inc:24), 0x30                             ; FEA2E7  f2 4d 1f 60 02 30 00
	calr EditScreen_DrawInc                                          ; FEA2EE  1e 12 6a
	ret                                                  ; FEA2F1  0e
.LFEA2F2:
	subw	(EditField_Inc:24), 0x0001                ; FEA2F2  d2 4d 1f 60 3a 01 00
	calr EditScreen_DrawInc                                          ; FEA2F9  1e 07 6a
	ret                                                  ; FEA2FC  0e
; EditField_IncUp5: (0x601F4D) + 5, clamped to 0x60; redraws.
EditField_IncUp5:
	cpw	(EditField_Inc:24), 0x0060                        ; FEA2FD  d2 4d 1f 60 3f 60 00
	jr c, .LFEA307                                       ; FEA304  67 01
	ret                                                  ; FEA306  0e
.LFEA307:
	addw	(EditField_Inc:24), 0x0005                        ; FEA307  d2 4d 1f 60 38 05 00
	cpw	(EditField_Inc:24), 0x0060                        ; FEA30E  d2 4d 1f 60 3f 60 00
	jr c, .LFEA31E                                       ; FEA315  67 07
	ldw (EditField_Inc:24), 0x60                             ; FEA317  f2 4d 1f 60 02 60 00
.LFEA31E:
	calr EditScreen_DrawInc                                          ; FEA31E  1e e2 69
	ret                                                  ; FEA321  0e
; EditField_IncDown5: (0x601F4D) - 5, clamped; at 0 it is reset to 0x30; redraws.
EditField_IncDown5:
	cpw	(EditField_Inc:24), 0x0000                        ; FEA322  d2 4d 1f 60 3f 00 00
	jr z, .LFEA335                                       ; FEA329  66 0a
	cpw	(EditField_Inc:24), 0x0001                        ; FEA32B  d2 4d 1f 60 3f 01 00
	jr ugt, .LFEA340                                     ; FEA332  6b 0c
	ret                                                  ; FEA334  0e
.LFEA335:
	ldw (EditField_Inc:24), 0x30                             ; FEA335  f2 4d 1f 60 02 30 00
	calr EditScreen_DrawInc                                          ; FEA33C  1e c4 69
	ret                                                  ; FEA33F  0e
.LFEA340:
	ld wa, (EditField_Inc:24)                                ; FEA340  d2 4d 1f 60 20
	sub WA,0x0005                                        ; FEA345  d8 ca 05 00
	jr c, .LFEA363                                       ; FEA349  67 18
	cpw	(EditField_Inc:24), 0x0000                        ; FEA34B  d2 4d 1f 60 3f 00 00
	jr z, .LFEA363                                       ; FEA352  66 0f
	xor W,W                                              ; FEA354  c8 d0
	ld (EditField_Inc:24), wa                                ; FEA356  f2 4d 1f 60 50
	cp a, 0x00:i3                                          ; FEA35B  c9 d8
	jr z, .LFEA363                                       ; FEA35D  66 04
.LFEA35F:
	calr EditScreen_DrawInc                                          ; FEA35F  1e a1 69
	ret                                                  ; FEA362  0e
.LFEA363:
	ldw (EditField_Inc:24), 0x01                             ; FEA363  f2 4d 1f 60 02 01 00
	jr .LFEA35F                                          ; FEA36A  68 f3
; EditScreen_CursorRight: the 'CURSOR >' key: SoftKeyCol8_NoteEdit and SoftKeyCol7_DrumEdit call it (DRUM EDIT has one column fewer).
EditScreen_CursorRight:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA36C  f2 58 1f 60 cf
	jr z, .LFEA374                                       ; FEA371  66 01
	ret                                                  ; FEA373  0e
.LFEA374:
	or	(UI_RequestBits:16), 0x08                            ; FEA374  c1 75 20 3e 08
	calr BStore_CursorSlot_Save                                          ; FEA379  1e 72 e9
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA37C  d2 54 1f 60 20
	ld (EditCursor_OldTickInView:24), wa                                ; FEA381  f2 56 1f 60 50
	calr EditCursor_AdvanceToNextIncStep                                      ; FEA386  1e 80 03
	ld c, (EditMeasure_Beats:24)                                 ; FEA389  c2 75 1f 60 23
	mul C,0x60                                           ; FEA38E  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FEA391  d2 54 1f 60 f9
	jr c, .LFEA39A                                       ; FEA396  67 02
	jr .LFEA39D                                          ; FEA398  68 03
.LFEA39A:
	calr EditCursor_SplitViewTick                                      ; FEA39A  1e a6 03
.LFEA39D:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA39D  f2 5b 1f 60 c8
	jr nz, .LFEA3D1                                      ; FEA3A2  6e 2d
	calr EditPos_SeekFirstNoteAfterOldCursor                                      ; FEA3A4  1e a2 00
	call BStoreCursor_ReadByte                                        ; FEA3A7  1d 32 22 ff
	and A,0xf0                                           ; FEA3AB  c9 cc f0
	cp A,0x90                                            ; FEA3AE  c9 cf 90
	jr nz, .LFEA3D1                                      ; FEA3B1  6e 1e
	calr DrumEdit_IsOtherNote                                          ; FEA3B3  1e fd e6
	cp a, 0x00:i3                                          ; FEA3B6  c9 d8
	jr nz, .LFEA3D1                                      ; FEA3B8  6e 17
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA3BA  1e 6b 02
	sub XWA,XBC                                          ; FEA3BD  e9 a0
	xor XHL,XHL                                          ; FEA3BF  eb d3
	ld hl, (EditCursor_TickInMeasure:24)                                ; FEA3C1  d2 54 1f 60 23
	cp XWA,XHL                                           ; FEA3C6  eb f0
	jr ule, .LFEA400                                     ; FEA3C8  63 36
	bit	1, (EditScreen_CursorFlags:24)                             ; FEA3CA  f2 5b 1f 60 c9
	jr nz, .LFEA3E2                                      ; FEA3CF  6e 11
.LFEA3D1:
	calr EditPos_SeekNextShownNote                                      ; FEA3D1  1e 13 04
	bit	4, (EditScreen_CursorFlags:24)                             ; FEA3D4  f2 5b 1f 60 cc
	jr nz, .LFEA404                                      ; FEA3D9  6e 29
	bit	1, (EditScreen_CursorFlags:24)                             ; FEA3DB  f2 5b 1f 60 c9
	jr z, .LFEA3F0                                       ; FEA3E0  66 0e
.LFEA3E2:
	calr EditScreen_ExtendChainToCursorBeat                                      ; FEA3E2  1e 68 02
	bit	2, (EditScreen_CursorFlags:24)                             ; FEA3E5  f2 5b 1f 60 ca
	jr z, .LFEA404                                       ; FEA3EA  66 18
	calr EditScreen_FlagMemoryFull                                          ; FEA3EC  1e e5 e7
	ret                                                  ; FEA3EF  0e
.LFEA3F0:
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA3F0  1e 35 02
	xor XHL,XHL                                          ; FEA3F3  eb d3
	ld hl, (EditCursor_TickInMeasure:24)                                ; FEA3F5  d2 54 1f 60 23
	add XBC,XHL                                          ; FEA3FA  eb 81
	cp XWA,XBC                                           ; FEA3FC  e9 f0
	jr UGT,.LFEA404                                      ; FEA3FE  6b 04
.LFEA400:
	calr EditCursor_LandOnNote                                      ; FEA400  1e d9 00
	ret                                                  ; FEA403  0e
.LFEA404:
	calr EditCursor_LandOnGrid                                      ; FEA404  1e 05 01
	ret                                                  ; FEA407  0e
	cpw	(EditCursor_Measure:24), 0x03e7                        ; FEA408  d2 3f 1f 60 3f e7 03
	jr c, .LFEA412                                       ; FEA40F  67 01
	ret                                                  ; FEA411  0e
.LFEA412:
	ld XIX,EditScreen_BeatTable                                    ; FEA412  44 5f 1f 60 00
.LFEA417:
	ld A,(XIX)                                           ; FEA417  84 21
	cp a, 0x00:i3                                          ; FEA419  c9 d8
	jr nz, .LFEA445                                      ; FEA41B  6e 28
.LFEA41D:
	inc 1,XIX                                            ; FEA41D  ec 61
	ld XHL,EditScreen_BeatTable                                    ; FEA41F  43 5f 1f 60 00
	xor XBC,XBC                                          ; FEA424  e9 d1
	ld c, (0x601f76:24)                                 ; FEA426  c2 76 1f 60 23
	add XHL,XBC                                          ; FEA42B  e9 83
	cp XIX,XHL                                           ; FEA42D  eb f4
	jr c, .LFEA417                                       ; FEA42F  67 e6
	dec 1,C                                              ; FEA431  cb 69
	xor B,B                                              ; FEA433  ca d2
	ld wa, (EditScreen_FirstMeasure:24)                                ; FEA435  d2 5d 1f 60 20
	add WA,BC                                            ; FEA43A  d9 80
	ld (EditCursor_Measure:24), wa                                ; FEA43C  f2 3f 1f 60 50
	calr EditCursor_MeasureChangedByCursor                                      ; FEA441  1e 1c f9
	ret                                                  ; FEA444  0e
.LFEA445:
	ld C,A                                               ; FEA445  c9 8b
	jr .LFEA41D                                          ; FEA447  68 d4
; EditPos_SeekFirstNoteAfterOldCursor: from the measure's mark, EditPos_SeekNextShownNote until the position passes (0x601F56) -- the cursor before
;   the move -- or the chain ends (bit 1).
EditPos_SeekFirstNoteAfterOldCursor:
	calr BStore_CursorSlot_RestoreMark                                          ; FEA449  1e ac e7
	calr EditPos_LoadTickIfShownNote                                          ; FEA44C  1e 4c e6
	call BStoreCursor_ReadByte                                        ; FEA44F  1d 32 22 ff
	and A,0xf0                                           ; FEA453  c9 cc f0
	cp A,0x90                                            ; FEA456  c9 cf 90
	jr z, .LFEA45D                                       ; FEA459  66 02
	jr .LFEA464                                          ; FEA45B  68 07
.LFEA45D:
	calr DrumEdit_IsOtherNote                                          ; FEA45D  1e 53 e6
	cp a, 0x00:i3                                          ; FEA460  c9 d8
	jr z, .LFEA46E                                       ; FEA462  66 0a
.LFEA464:
	calr EditPos_SeekNextShownNote                                      ; FEA464  1e 80 03
	bit	1, (EditScreen_CursorFlags:24)                             ; FEA467  f2 5b 1f 60 c9
	jr nz, .LFEA47E                                      ; FEA46C  6e 10
.LFEA46E:
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA46E  1e b7 01
	sub XWA,XBC                                          ; FEA471  e9 a0
	xor XHL,XHL                                          ; FEA473  eb d3
	ld hl, (EditCursor_OldTickInView:24)                                ; FEA475  d2 56 1f 60 23
	cp XWA,XHL                                           ; FEA47A  eb f0
	jr ule, .LFEA464                                     ; FEA47C  63 e6
.LFEA47E:
	ret                                                  ; FEA47E  0e
; EditPos_SeekLastNoteBeforeOldCursor: the last shown note before (0x601F56): walks from the mark saving the cursor at each note; CursorFlags bit 3
;   is set when there is none.
EditPos_SeekLastNoteBeforeOldCursor:
	and	(EditScreen_CursorFlags:24), 0xf7                          ; FEA47F  c2 5b 1f 60 3c f7
	cpw	(EditCursor_OldTickInView:24), 0x0000                        ; FEA485  d2 56 1f 60 3f 00 00
	jr nz, .LFEA4B4                                      ; FEA48C  6e 26
	call BStoreCursor_ReadByte                                        ; FEA48E  1d 32 22 ff
	cp A,0x81                                            ; FEA492  c9 cf 81
	jr z, .LFEA4D5                                       ; FEA495  66 3e
	and A,0xf0                                           ; FEA497  c9 cc f0
	cp A,0x90                                            ; FEA49A  c9 cf 90
	jr nz, .LFEA4A8                                      ; FEA49D  6e 09
	calr DrumEdit_IsOtherNote                                          ; FEA49F  1e 11 e6
	cp a, 0x00:i3                                          ; FEA4A2  c9 d8
	jr z, .LFEA4AC                                       ; FEA4A4  66 06
	jr .LFEA4D5                                          ; FEA4A6  68 2d
.LFEA4A8:
	calr EditPos_SeekPrevShownNote                                      ; FEA4A8  1e 78 04
	ret                                                  ; FEA4AB  0e
.LFEA4AC:
	cp	(EditPos_Tick:24), 0x00                          ; FEA4AC  c2 07 1f 60 3f 00
	jr nz, .LFEA4D5                                      ; FEA4B2  6e 21
.LFEA4B4:
	calr BStore_CursorSlot_RestoreMark                                          ; FEA4B4  1e 41 e7
	calr EditPos_LoadTickIfShownNote                                          ; FEA4B7  1e e1 e5
.LFEA4BA:
	calr BStore_CursorSlot_Save                                          ; FEA4BA  1e 31 e8
	calr EditPos_SeekNextShownNote                                      ; FEA4BD  1e 27 03
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA4C0  1e 65 01
	sub XWA,XBC                                          ; FEA4C3  e9 a0
	xor XHL,XHL                                          ; FEA4C5  eb d3
	ld hl, (EditCursor_OldTickInView:24)                                ; FEA4C7  d2 56 1f 60 23
	cp XWA,XHL                                           ; FEA4CC  eb f0
	jr c, .LFEA4BA                                       ; FEA4CE  67 ea
	calr BStore_CursorSlot_Restore                                          ; FEA4D0  1e 42 e8
	jr .LFEA4DB                                          ; FEA4D3  68 06
.LFEA4D5:
	or	(EditScreen_CursorFlags:24), 0x08                          ; FEA4D5  c2 5b 1f 60 3e 08
.LFEA4DB:
	ret                                                  ; FEA4DB  0e
; EditCursor_LandOnNote: EditCursor_TickInMeasure = the note's position; past the view -> EditScreen_WrapAndShowCursorMeasure; otherwise
;   EditCursor_SplitViewTick, EditScreen_SelectEventAtCursor, the fields and cursor redrawn,
;   EditScreen_AuditionEvent.
EditCursor_LandOnNote:
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA4DC  1e 49 01
	sub XWA,XBC                                          ; FEA4DF  e9 a0
	ld (EditCursor_TickInMeasure:24), wa                                ; FEA4E1  f2 54 1f 60 50
	ld c, (EditMeasure_Beats:24)                                 ; FEA4E6  c2 75 1f 60 23
	mul C,0x60                                           ; FEA4EB  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FEA4EE  d2 54 1f 60 f9
	jr c, .LFEA4F9                                       ; FEA4F3  67 04
	calr EditScreen_WrapAndShowCursorMeasure                                          ; FEA4F5  1e 65 f0
	ret                                                  ; FEA4F8  0e
.LFEA4F9:
	calr EditCursor_SplitViewTick                                      ; FEA4F9  1e 47 02
	calr EditScreen_SelectEventAtCursor                                          ; FEA4FC  1e 12 ea
	calr EditScreen_EraseFieldRow                                          ; FEA4FF  1e 76 52
	calr EditScreen_DrawFields                                          ; FEA502  1e d1 53
	calr EditScreen_RedrawCursorLayer                                          ; FEA505  1e 82 58
	calr EditScreen_AuditionEvent                                      ; FEA508  1e 2a 00
	ret                                                  ; FEA50B  0e
; EditCursor_LandOnGrid: past the view -> EditScreen_WrapAndShowCursorMeasure; otherwise the selection cleared (CursorFlags bit 0), the block-store cursor
;   restored, the cursor layer redrawn, EditCursor_SplitViewTick, the fields redrawn.
EditCursor_LandOnGrid:
	ld c, (EditMeasure_Beats:24)                                 ; FEA50C  c2 75 1f 60 23
	mul C,0x60                                           ; FEA511  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FEA514  d2 54 1f 60 f9
	jr c, .LFEA51F                                       ; FEA519  67 04
	calr EditScreen_WrapAndShowCursorMeasure                                          ; FEA51B  1e 3f f0
	ret                                                  ; FEA51E  0e
.LFEA51F:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEA51F  c2 5b 1f 60 3c fe
	calr BStore_CursorSlot_Restore                                          ; FEA525  1e ed e7
	calr EditScreen_RedrawCursorLayer                                          ; FEA528  1e 5f 58
	calr EditCursor_SplitViewTick                                      ; FEA52B  1e 15 02
	calr EditScreen_EraseFieldRow                                          ; FEA52E  1e 47 52
	calr EditScreen_DrawFields                                          ; FEA531  1e a2 53
	ret                                                  ; FEA534  0e
; EditScreen_AuditionEvent: EditScreen_EndAudition, EditScreen_AuditionEventNote, EditScreen_ActionTimer2 = 0x82 (end it two ticks
;   later).  Called after the note or velocity of the selected event changes.
EditScreen_AuditionEvent:
	calr EditScreen_EndAudition                                      ; FEA535  1e 17 00
	calr EditScreen_AuditionEventNote                                      ; FEA538  1e 2b 00
	ld (EditScreen_ActionTimer2:24), 0x82                             ; FEA53B  f2 5a 1f 60 00 82
	ret                                                  ; FEA541  0e
; DrumEdit_AuditionRow: EditScreen_EndAudition, DrumEdit_AuditionRowNote, EditScreen_ActionTimer2 = 0x82.
DrumEdit_AuditionRow:
	calr EditScreen_EndAudition                                      ; FEA542  1e 0a 00
	calr DrumEdit_AuditionRowNote                                      ; FEA545  1e 68 00
	ld (EditScreen_ActionTimer2:24), 0x82                             ; FEA548  f2 5a 1f 60 00 82
	ret                                                  ; FEA54E  0e
; EditScreen_EndAudition: when (0x600808) >= 10: (0x34D4) |= 0x40, EditScreen_PutAuditionEnd.  EditScreen_ActionTimer2's action
;   (through EditScreen_EndAudition_Call).
EditScreen_EndAudition:
	ld XHL,0x00600800                                    ; FEA54F  43 00 08 60 00
	ld WA,(XHL+0x08)                                     ; FEA554  9b 08 20
	cp WA,0x000a                                         ; FEA557  d8 cf 0a 00
	jr c, .LFEA565                                       ; FEA55B  67 08
	or	(0x34d4:16), 0x40                            ; FEA55D  c1 d4 34 3e 40
	calr EditScreen_PutAuditionEnd                                      ; FEA562  1e 92 00
.LFEA565:
	ret                                                  ; FEA565  0e
; EditScreen_AuditionEventNote: when (0x600808) >= 0x14: (0x34D4) |= 0x40 and the timed event 0x90, 0x7E, EditCursor_Note,
;   EditField_EventVelocity, EditScreen_Part on TimedEvents_Ring (T_TimedEventRing_Put, five bytes).
EditScreen_AuditionEventNote:
	ld XHL,0x00600800                                    ; FEA566  43 00 08 60 00
	ld WA,(XHL+0x08)                                     ; FEA56B  9b 08 20
	cp WA,0x0014                                         ; FEA56E  d8 cf 14 00
	jr c, .LFEA5AF                                       ; FEA572  67 3b
	or	(0x34d4:16), 0x40                            ; FEA574  c1 d4 34 3e 40
	ld a, 0x90:opc                                          ; FEA579  21 90
	pushw wa                                             ; FEA57B  28
	call T_TimedEventRing_Put                                ; FEA57C  1d 64 1d f4
	inc 2,XSP                                            ; FEA580  ef 62
	ld a, 0x7e:opc                                          ; FEA582  21 7e
	pushw wa                                             ; FEA584  28
	call T_TimedEventRing_Put                                ; FEA585  1d 64 1d f4
	inc 2,XSP                                            ; FEA589  ef 62
	ld a, (EditCursor_Note:24)                                 ; FEA58B  c2 44 1f 60 21
	pushw wa                                             ; FEA590  28
	call T_TimedEventRing_Put                                ; FEA591  1d 64 1d f4
	inc 2,XSP                                            ; FEA595  ef 62
	ld a, (EditField_EventVelocity:24)                                 ; FEA597  c2 45 1f 60 21
	pushw wa                                             ; FEA59C  28
	call T_TimedEventRing_Put                                ; FEA59D  1d 64 1d f4
	inc 2,XSP                                            ; FEA5A1  ef 62
	ld a, (EditScreen_Part:24)                                 ; FEA5A3  c2 00 1f 60 21
	pushw wa                                             ; FEA5A8  28
	call T_TimedEventRing_Put                                ; FEA5A9  1d 64 1d f4
	inc 2,XSP                                            ; FEA5AD  ef 62
.LFEA5AF:
	ret                                                  ; FEA5AF  0e
; DrumEdit_AuditionRowNote: the same with velocity 0x50 -- a DRUM EDIT row change.
DrumEdit_AuditionRowNote:
	ld XHL,0x00600800                                    ; FEA5B0  43 00 08 60 00
	ld WA,(XHL+0x08)                                     ; FEA5B5  9b 08 20
	cp WA,0x0014                                         ; FEA5B8  d8 cf 14 00
	jr c, .LFEA5F6                                       ; FEA5BC  67 38
	or	(0x34d4:16), 0x40                            ; FEA5BE  c1 d4 34 3e 40
	ld a, 0x90:opc                                          ; FEA5C3  21 90
	pushw wa                                             ; FEA5C5  28
	call T_TimedEventRing_Put                                ; FEA5C6  1d 64 1d f4
	inc 2,XSP                                            ; FEA5CA  ef 62
	ld a, 0x7e:opc                                          ; FEA5CC  21 7e
	pushw wa                                             ; FEA5CE  28
	call T_TimedEventRing_Put                                ; FEA5CF  1d 64 1d f4
	inc 2,XSP                                            ; FEA5D3  ef 62
	ld a, (EditCursor_Note:24)                                 ; FEA5D5  c2 44 1f 60 21
	pushw wa                                             ; FEA5DA  28
	call T_TimedEventRing_Put                                ; FEA5DB  1d 64 1d f4
	inc 2,XSP                                            ; FEA5DF  ef 62
	ld a, 0x50:opc                                          ; FEA5E1  21 50
	pushw wa                                             ; FEA5E3  28
	call T_TimedEventRing_Put                                ; FEA5E4  1d 64 1d f4
	inc 2,XSP                                            ; FEA5E8  ef 62
	ld a, (EditScreen_Part:24)                                 ; FEA5EA  c2 00 1f 60 21
	pushw wa                                             ; FEA5EF  28
	call T_TimedEventRing_Put                                ; FEA5F0  1d 64 1d f4
	inc 2,XSP                                            ; FEA5F4  ef 62
.LFEA5F6:
	ret                                                  ; FEA5F6  0e
; EditScreen_PutAuditionEnd: the timed event 0x90, 0x7F, 0x28, 0, EditScreen_Part: what EditScreen_EndAudition sends before each new
;   audition and two ticks after one.
EditScreen_PutAuditionEnd:
	ld a, 0x90:opc                                          ; FEA5F7  21 90
	pushw wa                                             ; FEA5F9  28
	call T_TimedEventRing_Put                                ; FEA5FA  1d 64 1d f4
	inc 2,XSP                                            ; FEA5FE  ef 62
	ld a, 0x7f:opc                                          ; FEA600  21 7f
	pushw wa                                             ; FEA602  28
	call T_TimedEventRing_Put                                ; FEA603  1d 64 1d f4
	inc 2,XSP                                            ; FEA607  ef 62
	ld a, 0x28:opc                                          ; FEA609  21 28
	pushw wa                                             ; FEA60B  28
	call T_TimedEventRing_Put                                ; FEA60C  1d 64 1d f4
	inc 2,XSP                                            ; FEA610  ef 62
	ld a, 0x00:opc                                          ; FEA612  21 00
	pushw wa                                             ; FEA614  28
	call T_TimedEventRing_Put                                ; FEA615  1d 64 1d f4
	inc 2,XSP                                            ; FEA619  ef 62
	ld a, (EditScreen_Part:24)                                 ; FEA61B  c2 00 1f 60 21
	pushw wa                                             ; FEA620  28
	call T_TimedEventRing_Put                                ; FEA621  1d 64 1d f4
	inc 2,XSP                                            ; FEA625  ef 62
	ret                                                  ; FEA627  0e
; EditScreen_PositionAndMeasureStartTicks: XWA = (0x601F05) x 0x60 + (0x601F07), the walk position in ticks; XBC = (0x601F0F) x 0x60 + (0x601F11), the
;   measure's start -- the callers subtract them to get the tick within the measure.
EditScreen_PositionAndMeasureStartTicks:
	ld wa, (EditPos_Beat:24)                                ; FEA628  d2 05 1f 60 20
	mul WA,0x0060                                        ; FEA62D  d8 08 60 00
	xor XHL,XHL                                          ; FEA631  eb d3
	ld l, (EditPos_Tick:24)                                 ; FEA633  c2 07 1f 60 27
	add XWA,XHL                                          ; FEA638  eb 80
	ld bc, (EditMeasure_StartBeat:24)                                ; FEA63A  d2 0f 1f 60 21
	mul BC,0x0060                                        ; FEA63F  d9 08 60 00
	xor XHL,XHL                                          ; FEA643  eb d3
	ld l, (EditMeasure_StartTick:24)                                 ; FEA645  c2 11 1f 60 27
	add XBC,XHL                                          ; FEA64A  eb 81
	ret                                                  ; FEA64C  0e
; EditScreen_ExtendChainToCursorBeat: appends beat markers (EditScreen_AppendBeatMarker) until the chain holds the cursor's beat; CursorFlags bit 2
;   is set when an append fails; the block-store cursor is restored.
EditScreen_ExtendChainToCursorBeat:
	ld wa, (BStore_CursorBlock:16)                                 ; FEA64D  d1 5c 34 20
	ld bc, (BStore_CursorOffset:16)                                 ; FEA651  d1 5e 34 21
	pushw wa                                             ; FEA655  28
	pushw bc                                             ; FEA656  29
	res	2, (EditScreen_CursorFlags:24)                             ; FEA657  f2 5b 1f 60 b2
	calr EditScreen_CountBeatMarkersFromMeasureMark                                      ; FEA65C  1e 52 00
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA65F  d2 54 1f 60 20
	div A,0x60                                           ; FEA664  c9 0a 60
	xor W,W                                              ; FEA667  c8 d0
	add WA,0x0001                                        ; FEA669  d8 c8 01 00
	cp	wa, (EditScreen_BeatCounter:24)                            ; FEA66D  d2 6c 1f 60 f0
	jr nc, .LFEA676                                      ; FEA672  6f 02
	jr .LFEA6A6                                          ; FEA674  68 30
.LFEA676:
	add WA,0x0001                                        ; FEA676  d8 c8 01 00
	sub wa, (EditScreen_BeatCounter:24)                            ; FEA67A  d2 6c 1f 60 a0
	ld (EditScreen_BeatCounter:24), wa                                ; FEA67F  f2 6c 1f 60 50
	calr EditScreen_SeekPartSavedCursor                                          ; FEA684  1e 5c f0
.LFEA687:
	calr EditScreen_AppendBeatMarker                                          ; FEA687  1e ff e4
	cp	(BStore_ErrorCode:16), 0x00                            ; FEA68A  c1 4a 0d 3f 00
	jr nz, .LFEA6A1                                      ; FEA68F  6e 10
	decw 0x01, (EditScreen_BeatCounter:24)                          ; FEA691  d2 6c 1f 60 69
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FEA696  d2 6c 1f 60 3f 00 00
	jr nz, .LFEA687                                      ; FEA69D  6e e8
	jr .LFEA6A6                                          ; FEA69F  68 05
.LFEA6A1:
	set	2, (EditScreen_CursorFlags:24)                             ; FEA6A1  f2 5b 1f 60 ba
.LFEA6A6:
	popw bc                                              ; FEA6A6  49
	popw wa                                              ; FEA6A7  48
	ld (BStore_CursorBlock:16), wa                                  ; FEA6A8  f1 5c 34 50
	ld (BStore_CursorOffset:16), bc                                  ; FEA6AC  f1 5e 34 51
	ret                                                  ; FEA6B0  0e
; EditScreen_CountBeatMarkersFromMeasureMark: BStore_CursorSlot_RestoreMark (cursor onto the shown measure's mark),
;   then falls into EditScreen_CountBeatMarkersToEnd: EditScreen_BeatCounter = the 0x81 markers from that mark to the
;   chain end. EditScreen_ExtendChainToCursorBeat's first step. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_CountBeatMarkersFromMeasureMark:
	calr BStore_CursorSlot_RestoreMark                                          ; FEA6B1  1e 44 e5
; EditScreen_CountBeatMarkersToEnd: (0x601F6C) = the number of 0x81 beat markers from the cursor to the chain's end tag 0x82.
EditScreen_CountBeatMarkersToEnd:
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FEA6B4  f2 6c 1f 60 02 00 00
.LFEA6BB:
	call BStoreCursor_ReadByte                                        ; FEA6BB  1d 32 22 ff
	cp A,0x82                                            ; FEA6BF  c9 cf 82
	jr z, .LFEA6D6                                       ; FEA6C2  66 12
	cp A,0x81                                            ; FEA6C4  c9 cf 81
	jr z, .LFEA6CF                                       ; FEA6C7  66 06
.LFEA6C9:
	call BStoreCursor_SeekNextTag                                        ; FEA6C9  1d f6 21 ff
	jr .LFEA6BB                                          ; FEA6CD  68 ec
.LFEA6CF:
	incw 0x01, (EditScreen_BeatCounter:24)                          ; FEA6CF  d2 6c 1f 60 61
	jr .LFEA6C9                                          ; FEA6D4  68 f3
.LFEA6D6:
	ret                                                  ; FEA6D6  0e
; EditScreen_CountBeatsInMeasure: from the measure's mark, (0x601F6C) = the 0x81 markers counted until it passes EditMeasure_Beats or the
;   end tag.
EditScreen_CountBeatsInMeasure:
	calr BStore_CursorSlot_RestoreMark                                          ; FEA6D7  1e 1e e5
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FEA6DA  f2 6c 1f 60 02 00 00
.LFEA6E1:
	call BStoreCursor_ReadByte                                        ; FEA6E1  1d 32 22 ff
	cp A,0x82                                            ; FEA6E5  c9 cf 82
	jr z, .LFEA708                                       ; FEA6E8  66 1e
	cp A,0x81                                            ; FEA6EA  c9 cf 81
	jr z, .LFEA6F5                                       ; FEA6ED  66 06
.LFEA6EF:
	call BStoreCursor_SeekNextTag                                        ; FEA6EF  1d f6 21 ff
	jr .LFEA6E1                                          ; FEA6F3  68 ec
.LFEA6F5:
	incw 0x01, (EditScreen_BeatCounter:24)                          ; FEA6F5  d2 6c 1f 60 61
	xor WA,WA                                            ; FEA6FA  d8 d0
	ld a, (EditMeasure_Beats:24)                                 ; FEA6FC  c2 75 1f 60 21
	cp (EditScreen_BeatCounter:24), wa                             ; FEA701  d2 6c 1f 60 f8
	jr ule, .LFEA6EF                                     ; FEA706  63 e7
.LFEA708:
	ret                                                  ; FEA708  0e
; EditCursor_AdvanceToNextIncStep: EditCursor_TickInMeasure = the first multiple of EditField_Inc above it (adds EditField_Inc from 0 until it passes).
;   The first step of EditScreen_CursorRight.
EditCursor_AdvanceToNextIncStep:
	xor WA,WA                                            ; FEA709  d8 d0
.LFEA70B:
	cp	wa, (EditCursor_TickInMeasure:24)                            ; FEA70B  d2 54 1f 60 f0
	jr ugt, .LFEA719                                     ; FEA710  6b 07
	add wa, (EditField_Inc:24)                            ; FEA712  d2 4d 1f 60 80
	jr .LFEA70B                                          ; FEA717  68 f2
.LFEA719:
	ld (EditCursor_TickInMeasure:24), wa                                ; FEA719  f2 54 1f 60 50
	ret                                                  ; FEA71E  0e
; EditCursor_StepBackToIncGrid: EditCursor_TickInMeasure = the largest multiple of EditField_Inc below it (unchanged at 0).
EditCursor_StepBackToIncGrid:
	cpw	(EditCursor_TickInMeasure:24), 0x0000                        ; FEA71F  d2 54 1f 60 3f 00 00
	jr z, .LFEA742                                       ; FEA726  66 1a
	xor WA,WA                                            ; FEA728  d8 d0
.LFEA72A:
	cp	wa, (EditCursor_TickInMeasure:24)                            ; FEA72A  d2 54 1f 60 f0
	jr nc, .LFEA738                                      ; FEA72F  6f 07
	add wa, (EditField_Inc:24)                            ; FEA731  d2 4d 1f 60 80
	jr .LFEA72A                                          ; FEA736  68 f2
.LFEA738:
	sub wa, (EditField_Inc:24)                            ; FEA738  d2 4d 1f 60 a0
	ld (EditCursor_TickInMeasure:24), wa                                ; FEA73D  f2 54 1f 60 50
.LFEA742:
	ret                                                  ; FEA742  0e
; EditCursor_SplitViewTick: from EditCursor_TickInMeasure: EditCursor_Beat = the columns since the last measure start, EditCursor_Tick =
;   the tick mod 0x60, then EditCursor_SetMeasureFromView.
EditCursor_SplitViewTick:
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA743  d2 54 1f 60 20
	div A,0x60                                           ; FEA748  c9 0a 60
	xor E,E                                              ; FEA74B  cd d5
	xor W,W                                              ; FEA74D  c8 d0
	ld (EditScreen_BeatCounter:24), wa                                ; FEA74F  f2 6c 1f 60 50
	cp a, 0x00:i3                                          ; FEA754  c9 d8
	jr z, .LFEA785                                       ; FEA756  66 2d
	ld XIX,0x00601f60                                    ; FEA758  44 60 1f 60 00
	ld e, 0x01:opc                                          ; FEA75D  25 01
.LFEA75F:
	cp (XIX),0x00                                        ; FEA75F  84 3f 00
	jr nz, .LFEA766                                      ; FEA762  6e 02
	jr .LFEA768                                          ; FEA764  68 02
.LFEA766:
	xor E,E                                              ; FEA766  cd d5
.LFEA768:
	add XIX,0x00000001                                   ; FEA768  ec c8 01 00 00 00
	subw	(EditScreen_BeatCounter:24), 0x0001                ; FEA76E  d2 6c 1f 60 3a 01 00
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FEA775  d2 6c 1f 60 3f 00 00
	jr nz, .LFEA780                                      ; FEA77C  6e 02
	jr .LFEA785                                          ; FEA77E  68 05
.LFEA780:
	add E,0x01                                           ; FEA780  cd c8 01
	jr .LFEA75F                                          ; FEA783  68 da
.LFEA785:
	ld (EditCursor_Beat:24), e                                 ; FEA785  f2 41 1f 60 45
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA78A  d2 54 1f 60 20
	div A,0x60                                           ; FEA78F  c9 0a 60
	ld (EditCursor_Tick:24), w                                 ; FEA792  f2 43 1f 60 40
	calr EditCursor_SetMeasureFromView                                      ; FEA797  1e 01 00
	ret                                                  ; FEA79A  0e
; EditCursor_SetMeasureFromView: EditCursor_Measure = EditScreen_FirstMeasure + the measure starts (non-zero EditScreen_BeatTable entries)
;   among the columns up to the cursor's.
EditCursor_SetMeasureFromView:
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA79B  d2 54 1f 60 20
	div A,0x60                                           ; FEA7A0  c9 0a 60
	xor E,E                                              ; FEA7A3  cd d5
	xor W,W                                              ; FEA7A5  c8 d0
	ld (EditScreen_BeatCounter:24), wa                                ; FEA7A7  f2 6c 1f 60 50
	cp a, 0x00:i3                                          ; FEA7AC  c9 d8
	jr z, .LFEA7D8                                       ; FEA7AE  66 28
	ld XIX,0x00601f60                                    ; FEA7B0  44 60 1f 60 00
	xor E,E                                              ; FEA7B5  cd d5
.LFEA7B7:
	cp (XIX),0x00                                        ; FEA7B7  84 3f 00
	jr nz, .LFEA7D4                                      ; FEA7BA  6e 18
.LFEA7BC:
	add XIX,0x00000001                                   ; FEA7BC  ec c8 01 00 00 00
	subw	(EditScreen_BeatCounter:24), 0x0001                ; FEA7C2  d2 6c 1f 60 3a 01 00
	cpw	(EditScreen_BeatCounter:24), 0x0000                        ; FEA7C9  d2 6c 1f 60 3f 00 00
	jr nz, .LFEA7B7                                      ; FEA7D0  6e e5
	jr .LFEA7D8                                          ; FEA7D2  68 04
.LFEA7D4:
	inc 1,E                                              ; FEA7D4  cd 61
	jr .LFEA7BC                                          ; FEA7D6  68 e4
.LFEA7D8:
	ld wa, (EditScreen_FirstMeasure:24)                                ; FEA7D8  d2 5d 1f 60 20
	xor D,D                                              ; FEA7DD  cc d4
	add WA,DE                                            ; FEA7DF  da 80
	ld (EditCursor_Measure:24), wa                                ; FEA7E1  f2 3f 1f 60 50
	ret                                                  ; FEA7E6  0e
; EditPos_SeekNextShownNote: CursorFlags bits 1 and 4 cleared; steps to the next note-on that DrumEdit_IsOtherNote passes and loads its tick
;   (EditPos_LoadEventTick); EditPos_Beat + 1 at each 0x81; bit 1 set at the end tag (tick 0), bit 4 once the walk
;   has left the view (EditPos_Beat - EditMeasure_StartBeat >= EditMeasure_Beats).
EditPos_SeekNextShownNote:
	and	(EditScreen_CursorFlags:24), 0xed                          ; FEA7E7  c2 5b 1f 60 3c ed
	calr BStoreCursor_ReadByte                                          ; FEA7ED  1e 42 7a
	cp A,0x82                                            ; FEA7F0  c9 cf 82
	jr z, .LFEA81F                                       ; FEA7F3  66 2a
	cp A,0x81                                            ; FEA7F5  c9 cf 81
	jr z, .LFEA82C                                       ; FEA7F8  66 32
.LFEA7FA:
	calr BStoreCursor_SeekNextTag                                          ; FEA7FA  1e f9 79
	calr BStoreCursor_ReadByte                                          ; FEA7FD  1e 32 7a
	cp A,0x82                                            ; FEA800  c9 cf 82
	jr z, .LFEA81F                                       ; FEA803  66 1a
	cp A,0x81                                            ; FEA805  c9 cf 81
	jr z, .LFEA82C                                       ; FEA808  66 22
	and A,0xf0                                           ; FEA80A  c9 cc f0
	cp A,0x90                                            ; FEA80D  c9 cf 90
	jr z, .LFEA814                                       ; FEA810  66 02
	jr .LFEA7FA                                          ; FEA812  68 e6
.LFEA814:
	calr DrumEdit_IsOtherNote                                          ; FEA814  1e 9c e2
	cp a, 0x00:i3                                          ; FEA817  c9 d8
	jr nz, .LFEA7FA                                      ; FEA819  6e df
	calr EditPos_LoadEventTick                                      ; FEA81B  1e 31 00
	ret                                                  ; FEA81E  0e
.LFEA81F:
	or	(EditScreen_CursorFlags:24), 0x02                          ; FEA81F  c2 5b 1f 60 3e 02
	ld (EditPos_Tick:24), 0x00                             ; FEA825  f2 07 1f 60 00 00
	ret                                                  ; FEA82B  0e
.LFEA82C:
	addw	(EditPos_Beat:24), 0x0001                        ; FEA82C  d2 05 1f 60 38 01 00
	ld wa, (EditPos_Beat:24)                                ; FEA833  d2 05 1f 60 20
	sub wa, (EditMeasure_StartBeat:24)                            ; FEA838  d2 0f 1f 60 a0
	xor BC,BC                                            ; FEA83D  d9 d1
	ld c, (EditMeasure_Beats:24)                                 ; FEA83F  c2 75 1f 60 23
	cp WA,BC                                             ; FEA844  d9 f0
	jr c, .LFEA7FA                                       ; FEA846  67 b2
	or	(EditScreen_CursorFlags:24), 0x10                          ; FEA848  c2 5b 1f 60 3e 10
	ret                                                  ; FEA84E  0e
; EditPos_LoadEventTick: EditPos_Tick = byte +1 of the event at the block-store cursor (the cursor is restored).
EditPos_LoadEventTick:
	ld wa, (BStore_CursorBlock:16)                                 ; FEA84F  d1 5c 34 20
	ld bc, (BStore_CursorOffset:16)                                 ; FEA853  d1 5e 34 21
	pushw wa                                             ; FEA857  28
	pushw bc                                             ; FEA858  29
	calr BStoreCursor_Step                                          ; FEA859  1e a8 79
	calr BStoreCursor_ReadByte                                          ; FEA85C  1e d3 79
	ld (EditPos_Tick:24), a                                 ; FEA85F  f2 07 1f 60 41
	popw bc                                              ; FEA864  49
	popw wa                                              ; FEA865  48
	ld (BStore_CursorBlock:16), wa                                  ; FEA866  f1 5c 34 50
	ld (BStore_CursorOffset:16), bc                                  ; FEA86A  f1 5e 34 51
	ret                                                  ; FEA86E  0e
; EditScreen_CursorLeft: the 'CURSOR <' key: SoftKeyCol7_NoteEdit and SoftKeyCol6_DrumEdit call it.
EditScreen_CursorLeft:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA86F  f2 58 1f 60 cf
	jr z, .LFEA877                                       ; FEA874  66 01
	ret                                                  ; FEA876  0e
.LFEA877:
	or	(UI_RequestBits:16), 0x08                            ; FEA877  c1 75 20 3e 08
	calr BStore_CursorSlot_Save                                          ; FEA87C  1e 6f e4
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEA87F  d2 54 1f 60 20
	ld (EditCursor_OldTickInView:24), wa                                ; FEA884  f2 56 1f 60 50
	calr EditCursor_StepBackToIncGrid                                      ; FEA889  1e 93 fe
	calr EditCursor_SplitViewTick                                      ; FEA88C  1e b4 fe
	bit	0, (EditScreen_CursorFlags:24)                             ; FEA88F  f2 5b 1f 60 c8
	jr nz, .LFEA8E5                                      ; FEA894  6e 4f
	calr EditPos_SeekLastNoteBeforeOldCursor                                      ; FEA896  1e e6 fb
	bit	3, (EditScreen_CursorFlags:24)                             ; FEA899  f2 5b 1f 60 cb
	jrl nz, .LFEA90D                                     ; FEA89E  7e 6c 00
	ld wa, (EditMeasure_MarkBlock:24)                                ; FEA8A1  d2 12 1f 60 20
	cp	wa, (BStore_CursorBlock:16)                              ; FEA8A6  d1 5c 34 f0
	jr nz, .LFEA8C3                                      ; FEA8AA  6e 17
	ld wa, (EditMeasure_MarkOffset:24)                                ; FEA8AC  d2 14 1f 60 20
	cp	wa, (BStore_CursorOffset:16)                              ; FEA8B1  d1 5e 34 f0
	jr nz, .LFEA8C3                                      ; FEA8B5  6e 0c
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA8B7  1e 6e fd
	sub XWA,XBC                                          ; FEA8BA  e9 a0
	cp (EditCursor_OldTickInView:24), wa                             ; FEA8BC  d2 56 1f 60 f8
	jr ule, .LFEA909                                     ; FEA8C1  63 46
.LFEA8C3:
	calr BStoreCursor_ReadByte                                          ; FEA8C3  1e 6c 79
	and A,0xf0                                           ; FEA8C6  c9 cc f0
	cp A,0x90                                            ; FEA8C9  c9 cf 90
	jr nz, .LFEA8E5                                      ; FEA8CC  6e 17
	calr DrumEdit_IsOtherNote                                          ; FEA8CE  1e e2 e1
	cp a, 0x00:i3                                          ; FEA8D1  c9 d8
	jr nz, .LFEA8E5                                      ; FEA8D3  6e 10
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA8D5  1e 50 fd
	sub XWA,XBC                                          ; FEA8D8  e9 a0
	xor XHL,XHL                                          ; FEA8DA  eb d3
	ld hl, (EditCursor_TickInMeasure:24)                                ; FEA8DC  d2 54 1f 60 23
	cp XWA,XHL                                           ; FEA8E1  eb f0
	jr nc, .LFEA905                                      ; FEA8E3  6f 20
.LFEA8E5:
	calr EditPos_SeekPrevShownNote                                      ; FEA8E5  1e 3b 00
	bit	3, (EditScreen_CursorFlags:24)                             ; FEA8E8  f2 5b 1f 60 cb
	jr nz, .LFEA90D                                      ; FEA8ED  6e 1e
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA8EF  1e 36 fd
	cp XWA,XBC                                           ; FEA8F2  e9 f0
	jr c, .LFEA909                                       ; FEA8F4  67 13
	xor XHL,XHL                                          ; FEA8F6  eb d3
	ld hl, (EditCursor_TickInMeasure:24)                                ; FEA8F8  d2 54 1f 60 23
	add XBC,XHL                                          ; FEA8FD  eb 81
	cp XWA,XBC                                           ; FEA8FF  e9 f0
	jr nc, .LFEA905                                      ; FEA901  6f 02
	jr .LFEA909                                          ; FEA903  68 04
.LFEA905:
	calr EditCursor_LandOnNote                                      ; FEA905  1e d4 fb
	ret                                                  ; FEA908  0e
.LFEA909:
	calr EditCursor_LandOnGrid                                      ; FEA909  1e 00 fc
	ret                                                  ; FEA90C  0e
.LFEA90D:
	cpw	(EditCursor_Measure:24), 0x0001                        ; FEA90D  d2 3f 1f 60 3f 01 00
	jr z, .LFEA909                                       ; FEA914  66 f3
	cpw	(EditCursor_OldTickInView:24), 0x0000                        ; FEA916  d2 56 1f 60 3f 00 00
	jr nz, .LFEA909                                      ; FEA91D  6e ea
	calr EditScreen_ShowPreviousMeasure                                          ; FEA91F  1e 26 ed
	ret                                                  ; FEA922  0e
; EditPos_SeekPrevShownNote: steps back (BStoreCursor_SeekPrevTag) to the previous note-on DrumEdit_IsOtherNote passes, loading its tick;
;   EditPos_Beat - 1 at each 0x81; CursorFlags bit 3 when the measure's start is passed or a BStore error comes.
EditPos_SeekPrevShownNote:
	and	(EditScreen_CursorFlags:24), 0xf7                          ; FEA923  c2 5b 1f 60 3c f7
	calr BStoreCursor_ReadByte                                          ; FEA929  1e 06 79
	cp A,0x81                                            ; FEA92C  c9 cf 81
	jr z, .LFEA95F                                       ; FEA92F  66 2e
.LFEA931:
	calr BStoreCursor_SeekPrevTag                                          ; FEA931  1e b7 d9
	cp	(BStore_ErrorCode:16), 0x00                            ; FEA934  c1 4a 0d 3f 00
	jr nz, .LFEA978                                      ; FEA939  6e 3d
	calr BStoreCursor_ReadByte                                          ; FEA93B  1e f4 78
	cp A,0x81                                            ; FEA93E  c9 cf 81
	jr z, .LFEA95F                                       ; FEA941  66 1c
	and A,0xf0                                           ; FEA943  c9 cc f0
	cp A,0x90                                            ; FEA946  c9 cf 90
	jr z, .LFEA94D                                       ; FEA949  66 02
	jr .LFEA931                                          ; FEA94B  68 e4
.LFEA94D:
	calr DrumEdit_IsOtherNote                                          ; FEA94D  1e 63 e1
	cp a, 0x00:i3                                          ; FEA950  c9 d8
	jr nz, .LFEA931                                      ; FEA952  6e dd
	calr EditPos_LoadEventTick                                      ; FEA954  1e f8 fe
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA957  1e ce fc
	cp XWA,XBC                                           ; FEA95A  e9 f0
	jr c, .LFEA978                                       ; FEA95C  67 1a
	ret                                                  ; FEA95E  0e
.LFEA95F:
	cpw	(EditPos_Beat:24), 0x0000                        ; FEA95F  d2 05 1f 60 3f 00 00
	jr z, .LFEA978                                       ; FEA966  66 10
	subw	(EditPos_Beat:24), 0x0001                ; FEA968  d2 05 1f 60 3a 01 00
	calr EditScreen_PositionAndMeasureStartTicks                                      ; FEA96F  1e b6 fc
	cp XWA,XBC                                           ; FEA972  e9 f0
	jr c, .LFEA978                                       ; FEA974  67 02
	jr .LFEA931                                          ; FEA976  68 b9
.LFEA978:
	or	(EditScreen_CursorFlags:24), 0x08                          ; FEA978  c2 5b 1f 60 3e 08
	ret                                                  ; FEA97E  0e
; NoteEdit_LcdKeyRow1: the LcdKeyRow1 action of NoteEdit -- called only by LcdKeyRow1_NoteEdit.
NoteEdit_LcdKeyRow1:
	ld XIX,NoteEdit_HeldKeys                                    ; FEA97F  44 1c 1f 60 00
	ld A,(XIX)                                           ; FEA984  84 21
	bit 0x07,A                                           ; FEA986  c9 33 07
	jr nz, .LFEA992                                      ; FEA989  6e 07
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA98B  f2 58 1f 60 cf
	jr z, .LFEA993                                       ; FEA990  66 01
.LFEA992:
	ret                                                  ; FEA992  0e
.LFEA993:
	bit 0x07,W                                           ; FEA993  c8 33 07
	jr nz, .LFEA99F                                      ; FEA996  6e 07
	ldw (UI_Request:16), 0x8026                              ; FEA998  f1 70 20 02 26 80
	ret                                                  ; FEA99E  0e
.LFEA99F:
	ret                                                  ; FEA99F  0e
; NoteEdit_LcdKeyRow2: the LcdKeyRow2 action of NoteEdit -- called only by LcdKeyRow2_NoteEdit.
NoteEdit_LcdKeyRow2:
	or	(UI_RequestBits:16), 0x08                            ; FEA9A0  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA9A5  f2 58 1f 60 cf
	jr z, .LFEA9B5                                       ; FEA9AA  66 09
	cp	(EditScreen_ActionIndex:24), 0x04                          ; FEA9AC  c2 59 1f 60 3f 04
	jr z, .LFEA9B5                                       ; FEA9B2  66 01
	ret                                                  ; FEA9B4  0e
.LFEA9B5:
	bit 0x07,W                                           ; FEA9B5  c8 33 07
	jr nz, .LFEA9DF                                      ; FEA9B8  6e 25
	cp	(NoteEdit_RulerPosition:24), 0x09                          ; FEA9BA  c2 53 1f 60 3f 09
	jr c, .LFEA9C3                                       ; FEA9C0  67 01
	ret                                                  ; FEA9C2  0e
.LFEA9C3:
	add	(NoteEdit_RulerPosition:24), 0x01                          ; FEA9C3  c2 53 1f 60 38 01
	calr NoteEdit_DrawKeyboardRuler                                          ; FEA9C9  1e 70 e3
	ld (EditScreen_ActionTimer:24), 0x81                             ; FEA9CC  f2 58 1f 60 00 81
	ld (EditScreen_ActionIndex:24), 0x04                             ; FEA9D2  f2 59 1f 60 00 04
	calr EditScreen_EraseEditArea_Layer0                                          ; FEA9D8  1e f7 4d
	calr EditScreen_EraseEditArea_Layer1                                          ; FEA9DB  1e 7b 4e
	ret                                                  ; FEA9DE  0e
.LFEA9DF:
	ret                                                  ; FEA9DF  0e
; NoteEdit_LcdKeyRow3: the LcdKeyRow3 action of NoteEdit -- called only by LcdKeyRow3_NoteEdit.
NoteEdit_LcdKeyRow3:
	or	(UI_RequestBits:16), 0x08                            ; FEA9E0  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEA9E5  f2 58 1f 60 cf
	jr z, .LFEA9F5                                       ; FEA9EA  66 09
	cp	(EditScreen_ActionIndex:24), 0x04                          ; FEA9EC  c2 59 1f 60 3f 04
	jr z, .LFEA9F5                                       ; FEA9F2  66 01
	ret                                                  ; FEA9F4  0e
.LFEA9F5:
	bit 0x07,W                                           ; FEA9F5  c8 33 07
	jr nz, .LFEAA1F                                      ; FEA9F8  6e 25
	cp	(NoteEdit_RulerPosition:24), 0x00                          ; FEA9FA  c2 53 1f 60 3f 00
	jr nz, .LFEAA03                                      ; FEAA00  6e 01
	ret                                                  ; FEAA02  0e
.LFEAA03:
	sub	(NoteEdit_RulerPosition:24), 0x01                  ; FEAA03  c2 53 1f 60 3a 01
	calr NoteEdit_DrawKeyboardRuler                                          ; FEAA09  1e 30 e3
	ld (EditScreen_ActionTimer:24), 0x81                             ; FEAA0C  f2 58 1f 60 00 81
	ld (EditScreen_ActionIndex:24), 0x04                             ; FEAA12  f2 59 1f 60 00 04
	calr EditScreen_EraseEditArea_Layer0                                          ; FEAA18  1e b7 4d
	calr EditScreen_EraseEditArea_Layer1                                          ; FEAA1B  1e 3b 4e
	ret                                                  ; FEAA1E  0e
.LFEAA1F:
	ret                                                  ; FEAA1F  0e
; EditScreen_LcdKeyRow4: the LcdKeyRow4 action of DrumEdit, NoteEdit -- called only by LcdKeyRow4_DrumEdit, LcdKeyRow4_NoteEdit.
EditScreen_LcdKeyRow4:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAA20  f2 58 1f 60 cf
	jr z, .LFEAA28                                       ; FEAA25  66 01
	ret                                                  ; FEAA27  0e
.LFEAA28:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEAA28  f2 5b 1f 60 c8
	jr nz, .LFEAA30                                      ; FEAA2D  6e 01
	ret                                                  ; FEAA2F  0e
.LFEAA30:
	calr sub_FE9983                                          ; FEAA30  1e 50 ef
	calr BStoreCursor_ReadByte                                          ; FEAA33  1e fc 77
	cp A,0x82                                            ; FEAA36  c9 cf 82
	jr z, .LFEAA75                                       ; FEAA39  66 3a
	cp A,0x81                                            ; FEAA3B  c9 cf 81
	jr z, .LFEAA7D                                       ; FEAA3E  66 3d
	ld wa, (BStore_CursorBlock:16)                                 ; FEAA40  d1 5c 34 20
	ld bc, (BStore_CursorOffset:16)                                 ; FEAA44  d1 5e 34 21
	pushw wa                                             ; FEAA48  28
	pushw bc                                             ; FEAA49  29
	calr BStoreCursor_Step                                          ; FEAA4A  1e b7 77
	calr BStoreCursor_ReadByte                                          ; FEAA4D  1e e2 77
	ld (EditPos_Tick:24), a                                 ; FEAA50  f2 07 1f 60 41
	popw bc                                              ; FEAA55  49
	popw wa                                              ; FEAA56  48
	ld (BStore_CursorBlock:16), wa                                  ; FEAA57  f1 5c 34 50
	ld (BStore_CursorOffset:16), bc                                  ; FEAA5B  f1 5e 34 51
.LFEAA5F:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAA5F  c2 5b 1f 60 3c fe
	calr EditScreen_EraseFieldRow                                          ; FEAA65  1e 10 4d
	calr EditScreen_DrawFields                                          ; FEAA68  1e 6b 4e
	calr EditScreen_EraseEditArea_Layer0                                          ; FEAA6B  1e 64 4d
	calr EditScreen_DrawVisibleNotes                                          ; FEAA6E  1e 4e 54
	calr EditScreen_RedrawCursorLayer                                          ; FEAA71  1e 16 53
	ret                                                  ; FEAA74  0e
.LFEAA75:
	ld (EditPos_Tick:24), 0x00                             ; FEAA75  f2 07 1f 60 00 00
	jr .LFEAA5F                                          ; FEAA7B  68 e2
.LFEAA7D:
	addw	(EditPos_Beat:24), 0x0001                        ; FEAA7D  d2 05 1f 60 38 01 00
	jr .LFEAA5F                                          ; FEAA84  68 d9
; UI_GotoNoteEditPartSelect: UI_Request = 0x8024 -- go to screen 0x24, NOTE EDIT's part select (ScreenLeave_NoteEditPartSelect's
;   header: PanelScreen_VtableTable entry 0x44 = screen id 0x24).
UI_GotoNoteEditPartSelect:
	ldw (UI_Request:16), 0x8024                              ; FEAA86  f1 70 20 02 24 80
	ret                                                  ; FEAA8C  0e
; UI_GotoDrumEditPartSelect: UI_Request = 0x8027 -- go to screen 0x27, DRUM EDIT's part select.
UI_GotoDrumEditPartSelect:
	ldw (UI_Request:16), 0x8027                              ; FEAA8D  f1 70 20 02 27 80
	ret                                                  ; FEAA93  0e
; EditCursor_MeasureStepHeld: NoteEdit_Button17 / DrumEdit_Button17 -- slot 0x11, the held variant of SoftKeyCol1 (code 0x00 + 0x11, as slot
;   0x13 is of 0x02): EditCursor_MeasurePlus10 / _MeasureMinus10 by W bit 7, unless deferred action 0 is pending.
EditCursor_MeasureStepHeld:
	or	(UI_RequestBits:16), 0x08                            ; FEAA94  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAA99  f2 58 1f 60 cf
	jr z, .LFEAAA9                                       ; FEAA9E  66 09
	cp	(EditScreen_ActionIndex:24), 0x00                          ; FEAAA0  c2 59 1f 60 3f 00
	jr z, .LFEAAA9                                       ; FEAAA6  66 01
	ret                                                  ; FEAAA8  0e
.LFEAAA9:
	bit 0x07,W                                           ; FEAAA9  c8 33 07
	jr nz, .LFEAAB2                                      ; FEAAAC  6e 04
	calr EditCursor_MeasurePlus10                                      ; FEAAAE  1e 05 00
	ret                                                  ; FEAAB1  0e
.LFEAAB2:
	calr EditCursor_MeasureMinus10                                      ; FEAAB2  1e 2b 00
	ret                                                  ; FEAAB5  0e
; EditCursor_MeasurePlus10: EditCursor_Measure + 10, clamped to 999.
EditCursor_MeasurePlus10:
	ld wa, (EditCursor_Measure:24)                                ; FEAAB6  d2 3f 1f 60 20
	cp WA,0x03e7                                         ; FEAABB  d8 cf e7 03
	jr ugt, .LFEAADC                                     ; FEAABF  6b 1b
	addw	(EditCursor_Measure:24), 0x000a                        ; FEAAC1  d2 3f 1f 60 38 0a 00
	cpw	(EditCursor_Measure:24), 0x03e7                        ; FEAAC8  d2 3f 1f 60 3f e7 03
	jr ule, .LFEAAD8                                     ; FEAACF  63 07
	ldw (EditCursor_Measure:24), 0x03e7                           ; FEAAD1  f2 3f 1f 60 02 e7 03
.LFEAAD8:
	calr EditCursor_MeasureChanged                                      ; FEAAD8  1e 53 f2
; (sub_FEAADB removed 2026-10-04: no code names it and the line above falls through into it -- part of EditCursor_MeasurePlus10;
;  notes/prom_a_stray_label_removal.py)
	ret                                                  ; FEAADB  0e
.LFEAADC:
	calr Transport_ResetAndStartBC_Nop                                          ; FEAADC  1e 60 d5
	ret                                                  ; FEAADF  0e
; EditCursor_MeasureMinus10: EditCursor_Measure - 10, floored at 1.
EditCursor_MeasureMinus10:
	ld wa, (EditCursor_Measure:24)                                ; FEAAE0  d2 3f 1f 60 20
	cp wa, 0x01:i3                                         ; FEAAE5  d8 d9
	jr z, .LFEAB0A                                       ; FEAAE7  66 21
	ld wa, (EditCursor_Measure:24)                                ; FEAAE9  d2 3f 1f 60 20
	sub WA,0x000a                                        ; FEAAEE  d8 ca 0a 00
	jr c, .LFEAB01                                       ; FEAAF2  67 0d
	cp wa, 0x01:i3                                         ; FEAAF4  d8 d9
	jr c, .LFEAB01                                       ; FEAAF6  67 09
	ld (EditCursor_Measure:24), wa                                ; FEAAF8  f2 3f 1f 60 50
.LFEAAFD:
	calr EditCursor_MeasureChanged                                      ; FEAAFD  1e 2e f2
	ret                                                  ; FEAB00  0e
.LFEAB01:
	ldw (EditCursor_Measure:24), 0x01                             ; FEAB01  f2 3f 1f 60 02 01 00
	jr .LFEAAFD                                          ; FEAB08  68 f3
.LFEAB0A:
	calr Transport_ResetAndStartBC_Nop                                          ; FEAB0A  1e 32 d5
	ret                                                  ; FEAB0D  0e
; EditCursor_TickStepHeld: Button18 -- the held SoftKeyCol2: EditCursor_TickPlus5 / _TickMinus5, unless deferred action 1 is pending.
EditCursor_TickStepHeld:
	or	(UI_RequestBits:16), 0x08                            ; FEAB0E  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAB13  f2 58 1f 60 cf
	jr z, .LFEAB23                                       ; FEAB18  66 09
	cp	(EditScreen_ActionIndex:24), 0x01                          ; FEAB1A  c2 59 1f 60 3f 01
	jr z, .LFEAB23                                       ; FEAB20  66 01
	ret                                                  ; FEAB22  0e
.LFEAB23:
	bit 0x07,W                                           ; FEAB23  c8 33 07
	jr nz, .LFEAB2C                                      ; FEAB26  6e 04
	calr EditCursor_TickPlus5                                      ; FEAB28  1e aa f2
	ret                                                  ; FEAB2B  0e
.LFEAB2C:
	calr EditCursor_TickMinus5                                      ; FEAB2C  1e 66 f4
	ret                                                  ; FEAB2F  0e
; EditCursor_NoteStepHeld: NoteEdit_Button19 / DrumEdit_Button19 -- slot 0x13, the held variant of SoftKeyCol3: with (0x601F5B) bit 0
;   and the edit area not busy ((0x601F58) bit 7 with (0x601F59) not 2), EditCursor_NoteUp6 or _NoteDown6 by W
;   bit 7, the sense reversed in DRUM EDIT; UI_RequestBits |= 8.
EditCursor_NoteStepHeld:
	or	(UI_RequestBits:16), 0x08                            ; FEAB30  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAB35  f2 58 1f 60 cf
	jr z, .LFEAB45                                       ; FEAB3A  66 09
	cp	(EditScreen_ActionIndex:24), 0x02                          ; FEAB3C  c2 59 1f 60 3f 02
	jr z, .LFEAB45                                       ; FEAB42  66 01
	ret                                                  ; FEAB44  0e
.LFEAB45:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEAB45  f2 5b 1f 60 c8
	jr nz, .LFEAB4D                                      ; FEAB4A  6e 01
	ret                                                  ; FEAB4C  0e
.LFEAB4D:
	bit	0, (EditScreen_Mode:24)                             ; FEAB4D  f2 70 1f 60 c8
	jr z, .LFEAB5B                                       ; FEAB52  66 07
	bit 0x07,W                                           ; FEAB54  c8 33 07
	jr z, .LFEAB64                                       ; FEAB57  66 0b
	jr .LFEAB60                                          ; FEAB59  68 05
.LFEAB5B:
	bit 0x07,W                                           ; FEAB5B  c8 33 07
	jr nz, .LFEAB64                                      ; FEAB5E  6e 04
.LFEAB60:
	calr EditCursor_NoteUp6                                      ; FEAB60  1e 05 00
	ret                                                  ; FEAB63  0e
.LFEAB64:
	calr EditCursor_NoteDown6                                      ; FEAB64  1e 3e 00
	ret                                                  ; FEAB67  0e
; EditCursor_NoteUp6: (0x601F44) + 6, clamped to 0x7F, with EditCursor_NoteUp's tail.  Called by EditCursor_NoteStepHeld.
EditCursor_NoteUp6:
	cp	(EditCursor_Note:24), 0x7f                          ; FEAB68  c2 44 1f 60 3f 7f
	jr c, .LFEAB71                                       ; FEAB6E  67 01
	ret                                                  ; FEAB70  0e
.LFEAB71:
	add	(EditCursor_Note:24), 0x06                          ; FEAB71  c2 44 1f 60 38 06
	cp	(EditCursor_Note:24), 0x7f                          ; FEAB77  c2 44 1f 60 3f 7f
	jr ule, .LFEAB85                                     ; FEAB7D  63 06
	ld (EditCursor_Note:24), 0x7f                             ; FEAB7F  f2 44 1f 60 00 7f
.LFEAB85:
	bit	0, (EditScreen_Mode:24)                             ; FEAB85  f2 70 1f 60 c8
	jr z, .LFEAB8F                                       ; FEAB8A  66 03
	calr DrumEdit_RowFollowNoteUp                                      ; FEAB8C  1e 2d 03
.LFEAB8F:
	calr EditCursor_ApplyNoteToEvent                                          ; FEAB8F  1e 05 ee
	calr EditScreen_DrawCursorNote                                          ; FEAB92  1e e6 5e
	calr EditScreen_RedrawEditArea                                      ; FEAB95  1e 95 f5
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAB98  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x02                             ; FEAB9E  f2 59 1f 60 00 02
	ret                                                  ; FEABA4  0e
; EditCursor_NoteDown6: (0x601F44) - 6, floored at 1, with EditCursor_NoteDown's tail.  Called by EditCursor_NoteStepHeld.
EditCursor_NoteDown6:
	cp	(EditCursor_Note:24), 0x01                          ; FEABA5  c2 44 1f 60 3f 01
	jr nz, .LFEABAE                                      ; FEABAB  6e 01
	ret                                                  ; FEABAD  0e
.LFEABAE:
	ld a, (EditCursor_Note:24)                                 ; FEABAE  c2 44 1f 60 21
	sub A,0x06                                           ; FEABB3  c9 ca 06
	jr c, .LFEABE1                                       ; FEABB6  67 29
	cp a, 0x01:i3                                          ; FEABB8  c9 d9
	jr c, .LFEABE1                                       ; FEABBA  67 25
	ld (EditCursor_Note:24), a                                 ; FEABBC  f2 44 1f 60 41
.LFEABC1:
	bit	0, (EditScreen_Mode:24)                             ; FEABC1  f2 70 1f 60 c8
	jr z, .LFEABCB                                       ; FEABC6  66 03
	calr DrumEdit_RowFollowNoteDown                                      ; FEABC8  1e 7f 03
.LFEABCB:
	calr EditCursor_ApplyNoteToEvent                                          ; FEABCB  1e c9 ed
	calr EditScreen_DrawCursorNote                                          ; FEABCE  1e aa 5e
	calr EditScreen_RedrawEditArea                                      ; FEABD1  1e 59 f5
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEABD4  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x02                             ; FEABDA  f2 59 1f 60 00 02
	ret                                                  ; FEABE0  0e
.LFEABE1:
	ld (EditCursor_Note:24), 0x01                             ; FEABE1  f2 44 1f 60 00 01
	jr .LFEABC1                                          ; FEABE7  68 d8
; EditField_VelocityStepHeld: Button20 -- the held SoftKeyCol4: with an event selected EditField_EventVelocityUp5 / _Down5; otherwise, in
;   DRUM EDIT, EditField_NewNoteVelocityUp5 / _Down5.
EditField_VelocityStepHeld:
	or	(UI_RequestBits:16), 0x08                            ; FEABE9  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEABEE  f2 58 1f 60 cf
	jr z, .LFEABF6                                       ; FEABF3  66 01
.LFEABF5:
	ret                                                  ; FEABF5  0e
.LFEABF6:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEABF6  f2 5b 1f 60 c8
	jr nz, .LFEAC11                                      ; FEABFB  6e 14
	bit	0, (EditScreen_Mode:24)                             ; FEABFD  f2 70 1f 60 c8
	jr z, .LFEABF5                                       ; FEAC02  66 f1
	bit 0x07,W                                           ; FEAC04  c8 33 07
	jr nz, .LFEAC0D                                      ; FEAC07  6e 04
	calr EditField_NewNoteVelocityUp5                                      ; FEAC09  1e 12 00
	ret                                                  ; FEAC0C  0e
.LFEAC0D:
	calr EditField_NewNoteVelocityDown5                                      ; FEAC0D  1e 2f 00
	ret                                                  ; FEAC10  0e
.LFEAC11:
	bit 0x07,W                                           ; FEAC11  c8 33 07
	jr nz, .LFEAC1A                                      ; FEAC14  6e 04
	calr EditField_EventVelocityUp5                                      ; FEAC16  1e 4e 00
	ret                                                  ; FEAC19  0e
.LFEAC1A:
	calr EditField_EventVelocityDown5                                      ; FEAC1A  1e 6e 00
	ret                                                  ; FEAC1D  0e
; EditField_NewNoteVelocityUp5: (0x601F46) + 5, clamped to 0x7F; redraws.
; EditField_NewNoteVelocityUp5: CORRECTED 2026-10-04: 0x601F46 is the velocity a NEW note gets (100 by default); EditScreen_SoftKeyCol4 steps it
;   in DRUM EDIT when no event is selected, and EditScreen_DrawNewNoteVelocity shows it in the VEL cell.
EditField_NewNoteVelocityUp5:
	cp	(EditField_NewNoteVelocity:24), 0x7f                          ; FEAC1E  c2 46 1f 60 3f 7f
	jr c, .LFEAC27                                       ; FEAC24  67 01
	ret                                                  ; FEAC26  0e
.LFEAC27:
	add	(EditField_NewNoteVelocity:24), 0x05                          ; FEAC27  c2 46 1f 60 38 05
	cp	(EditField_NewNoteVelocity:24), 0x7f                          ; FEAC2D  c2 46 1f 60 3f 7f
	jr ule, .LFEAC3B                                     ; FEAC33  63 06
	ld (EditField_NewNoteVelocity:24), 0x7f                             ; FEAC35  f2 46 1f 60 00 7f
.LFEAC3B:
	calr EditScreen_DrawNewNoteVelocity                                          ; FEAC3B  1e fc 5e
	ret                                                  ; FEAC3E  0e
; EditField_NewNoteVelocityDown5: (0x601F46) - 5, clamped to 1; redraws.
; EditField_NewNoteVelocityDown5: CORRECTED 2026-10-04: 0x601F46 is the velocity a NEW note gets (100 by default); EditScreen_SoftKeyCol4 steps it
;   in DRUM EDIT when no event is selected, and EditScreen_DrawNewNoteVelocity shows it in the VEL cell.
EditField_NewNoteVelocityDown5:
	cp	(EditField_NewNoteVelocity:24), 0x01                          ; FEAC3F  c2 46 1f 60 3f 01
	jr nz, .LFEAC48                                      ; FEAC45  6e 01
	ret                                                  ; FEAC47  0e
.LFEAC48:
	ld a, (EditField_NewNoteVelocity:24)                                 ; FEAC48  c2 46 1f 60 21
	sub A,0x05                                           ; FEAC4D  c9 ca 05
	jr c, .LFEAC5F                                       ; FEAC50  67 0d
	cp a, 0x01:i3                                          ; FEAC52  c9 d9
	jr c, .LFEAC5F                                       ; FEAC54  67 09
	ld (EditField_NewNoteVelocity:24), a                                 ; FEAC56  f2 46 1f 60 41
.LFEAC5B:
	calr EditScreen_DrawNewNoteVelocity                                          ; FEAC5B  1e dc 5e
	ret                                                  ; FEAC5E  0e
.LFEAC5F:
	ld (EditField_NewNoteVelocity:24), 0x01                             ; FEAC5F  f2 46 1f 60 00 01
	jr .LFEAC5B                                          ; FEAC65  68 f4
; EditField_EventVelocityUp5: (0x601F45) + 5, clamped to 0x7F; redraws.
; EditField_EventVelocityUp5: CORRECTED 2026-10-04: 0x601F45 is the selected note-on's VELOCITY, byte +3 (EditField_ApplyVelocityToEvent writes it
;   there; EditScreen_DrawEventVelocity draws it in the same cell as the new-note velocity), not the NOTE: the NOTE
;   column is EditCursor_Note.  EditScreen_SoftKeyCol4 steps it while an event is selected ((0x601F5B) bit 0).
EditField_EventVelocityUp5:
	cp	(EditField_EventVelocity:24), 0x7f                          ; FEAC67  c2 45 1f 60 3f 7f
	jr c, .LFEAC70                                       ; FEAC6D  67 01
	ret                                                  ; FEAC6F  0e
.LFEAC70:
	add	(EditField_EventVelocity:24), 0x05                          ; FEAC70  c2 45 1f 60 38 05
	cp	(EditField_EventVelocity:24), 0x7f                          ; FEAC76  c2 45 1f 60 3f 7f
	jr ule, .LFEAC84                                     ; FEAC7C  63 06
	ld (EditField_EventVelocity:24), 0x7f                             ; FEAC7E  f2 45 1f 60 00 7f
.LFEAC84:
	calr EditScreen_DrawEventVelocity                                          ; FEAC84  1e bf 5e
	calr EditField_ApplyVelocityToEvent                                          ; FEAC87  1e 7d ed
	ret                                                  ; FEAC8A  0e
; EditField_EventVelocityDown5: (0x601F45) - 5, clamped to 1; redraws.
; EditField_EventVelocityDown5: CORRECTED 2026-10-04: 0x601F45 is the selected note-on's VELOCITY, byte +3 (EditField_ApplyVelocityToEvent writes it
;   there; EditScreen_DrawEventVelocity draws it in the same cell as the new-note velocity), not the NOTE: the NOTE
;   column is EditCursor_Note.  EditScreen_SoftKeyCol4 steps it while an event is selected ((0x601F5B) bit 0).
EditField_EventVelocityDown5:
	cp	(EditField_EventVelocity:24), 0x01                          ; FEAC8B  c2 45 1f 60 3f 01
	jr nz, .LFEAC94                                      ; FEAC91  6e 01
	ret                                                  ; FEAC93  0e
.LFEAC94:
	ld a, (EditField_EventVelocity:24)                                 ; FEAC94  c2 45 1f 60 21
	sub A,0x05                                           ; FEAC99  c9 ca 05
	jr c, .LFEACAE                                       ; FEAC9C  67 10
	cp a, 0x01:i3                                          ; FEAC9E  c9 d9
	jr c, .LFEACAE                                       ; FEACA0  67 0c
	ld (EditField_EventVelocity:24), a                                 ; FEACA2  f2 45 1f 60 41
.LFEACA7:
	calr EditScreen_DrawEventVelocity                                          ; FEACA7  1e 9c 5e
	calr EditField_ApplyVelocityToEvent                                          ; FEACAA  1e 5a ed
	ret                                                  ; FEACAD  0e
.LFEACAE:
	ld (EditField_EventVelocity:24), 0x01                             ; FEACAE  f2 45 1f 60 00 01
	jr .LFEACA7                                          ; FEACB4  68 f1
; EditField_StepLength12: repaint bit 3; unless (0x601F58) bit 7 with (0x601F59) not 3: W bit 7 clear -> EditField_LengthUp12, set -> _LengthDown12.
EditField_StepLength12:
	or	(UI_RequestBits:16), 0x08                            ; FEACB6  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEACBB  f2 58 1f 60 cf
	jr z, .LFEACCB                                       ; FEACC0  66 09
	cp	(EditScreen_ActionIndex:24), 0x03                          ; FEACC2  c2 59 1f 60 3f 03
	jr z, .LFEACCB                                       ; FEACC8  66 01
	ret                                                  ; FEACCA  0e
.LFEACCB:
	bit 0x07,W                                           ; FEACCB  c8 33 07
	jr nz, .LFEACD4                                      ; FEACCE  6e 04
	calr EditField_LengthUp12                                      ; FEACD0  1e 05 00
	ret                                                  ; FEACD3  0e
.LFEACD4:
	calr EditField_LengthDown12                                      ; FEACD4  1e 72 00
	ret                                                  ; FEACD7  0e
; EditField_LengthUp12: the LEN field + 12, clamped to 0x2FFF; redraws.
EditField_LengthUp12:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEACD8  f2 5b 1f 60 c8
	jr nz, .LFEACE1                                      ; FEACDD  6e 02
	jr .LFEAD18                                          ; FEACDF  68 37
.LFEACE1:
	cpw	(EditField_Length:24), 0x2fff                        ; FEACE1  d2 47 1f 60 3f ff 2f
	jr c, .LFEACEB                                       ; FEACE8  67 01
	ret                                                  ; FEACEA  0e
.LFEACEB:
	addw	(EditField_Length:24), 0x000c                        ; FEACEB  d2 47 1f 60 38 0c 00
	cpw	(EditField_Length:24), 0x2fff                        ; FEACF2  d2 47 1f 60 3f ff 2f
	jr ule, .LFEAD02                                     ; FEACF9  63 07
	ldw (EditField_Length:24), 0x2fff                           ; FEACFB  f2 47 1f 60 02 ff 2f
.LFEAD02:
	calr EditField_StoreLengthInNoteEvent                                          ; FEAD02  1e ba ec
	calr EditScreen_DrawEventLength                                      ; FEAD05  1e e9 5e
	calr EditScreen_RedrawEditArea                                      ; FEAD08  1e 22 f4
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAD0B  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEAD11  f2 59 1f 60 00 03
	ret                                                  ; FEAD17  0e
.LFEAD18:
	cpw	(EditField_NewNoteLength:24), 0x2fff                        ; FEAD18  d2 49 1f 60 3f ff 2f
	jr c, .LFEAD22                                       ; FEAD1F  67 01
	ret                                                  ; FEAD21  0e
.LFEAD22:
	addw	(EditField_NewNoteLength:24), 0x000c                        ; FEAD22  d2 49 1f 60 38 0c 00
	cpw	(EditField_NewNoteLength:24), 0x2fff                        ; FEAD29  d2 49 1f 60 3f ff 2f
	jr ule, .LFEAD39                                     ; FEAD30  63 07
	ldw (EditField_NewNoteLength:24), 0x2fff                           ; FEAD32  f2 49 1f 60 02 ff 2f
.LFEAD39:
	calr EditScreen_DrawNewNoteLength                                          ; FEAD39  1e d6 5e
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAD3C  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEAD42  f2 59 1f 60 00 03
	ret                                                  ; FEAD48  0e
; EditField_LengthDown12: the LEN field - 12, clamped to 1; redraws.
EditField_LengthDown12:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEAD49  f2 5b 1f 60 c8
	jr nz, .LFEAD52                                      ; FEAD4E  6e 02
	jr .LFEADA1                                          ; FEAD50  68 4f
.LFEAD52:
	cpw	(EditField_Length:24), 0x0000                        ; FEAD52  d2 47 1f 60 3f 00 00
	jr z, .LFEAD65                                       ; FEAD59  66 0a
	cpw	(EditField_Length:24), 0x0001                        ; FEAD5B  d2 47 1f 60 3f 01 00
	jr ugt, .LFEAD6E                                     ; FEAD62  6b 0a
	ret                                                  ; FEAD64  0e
.LFEAD65:
	ldw (EditField_Length:24), 0x01                             ; FEAD65  f2 47 1f 60 02 01 00
	jr .LFEAD82                                          ; FEAD6C  68 14
.LFEAD6E:
	ld wa, (EditField_Length:24)                                ; FEAD6E  d2 47 1f 60 20
	sub WA,0x000c                                        ; FEAD73  d8 ca 0c 00
	jr c, .LFEAD65                                       ; FEAD77  67 ec
	cp wa, 0x01:i3                                         ; FEAD79  d8 d9
	jr c, .LFEAD65                                       ; FEAD7B  67 e8
	ld (EditField_Length:24), wa                                ; FEAD7D  f2 47 1f 60 50
.LFEAD82:
	cpw	(EditField_Length:24), 0x0001                        ; FEAD82  d2 47 1f 60 3f 01 00
	jr c, .LFEAD65                                       ; FEAD89  67 da
	calr EditField_StoreLengthInNoteEvent                                          ; FEAD8B  1e 31 ec
	calr EditScreen_DrawEventLength                                      ; FEAD8E  1e 60 5e
	calr EditScreen_RedrawEditArea                                      ; FEAD91  1e 99 f3
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAD94  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEAD9A  f2 59 1f 60 00 03
	ret                                                  ; FEADA0  0e
.LFEADA1:
	cpw	(EditField_NewNoteLength:24), 0x0000                        ; FEADA1  d2 49 1f 60 3f 00 00
	jr z, .LFEADB4                                       ; FEADA8  66 0a
	cpw	(EditField_NewNoteLength:24), 0x0001                        ; FEADAA  d2 49 1f 60 3f 01 00
	jr nz, .LFEADBD                                      ; FEADB1  6e 0a
	ret                                                  ; FEADB3  0e
.LFEADB4:
	ldw (EditField_NewNoteLength:24), 0x01                             ; FEADB4  f2 49 1f 60 02 01 00
	jr .LFEADD1                                          ; FEADBB  68 14
.LFEADBD:
	ld wa, (EditField_NewNoteLength:24)                                ; FEADBD  d2 49 1f 60 20
	sub WA,0x000c                                        ; FEADC2  d8 ca 0c 00
	jr c, .LFEADB4                                       ; FEADC6  67 ec
	cp wa, 0x01:i3                                         ; FEADC8  d8 d9
	jr c, .LFEADB4                                       ; FEADCA  67 e8
	ld (EditField_NewNoteLength:24), wa                                ; FEADCC  f2 49 1f 60 50
.LFEADD1:
	calr EditScreen_DrawNewNoteLength                                          ; FEADD1  1e 3e 5e
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEADD4  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x03                             ; FEADDA  f2 59 1f 60 00 03
	ret                                                  ; FEADE0  0e
; EditField_StepInc5: as EditField_StepInc with EditField_IncUp5 / _IncDown5.
EditField_StepInc5:
	or	(UI_RequestBits:16), 0x08                            ; FEADE1  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEADE6  f2 58 1f 60 cf
	jr z, .LFEADEE                                       ; FEADEB  66 01
	ret                                                  ; FEADED  0e
.LFEADEE:
	bit 0x07,W                                           ; FEADEE  c8 33 07
	jr nz, .LFEADF7                                      ; FEADF1  6e 04
	calr EditField_IncUp5                                      ; FEADF3  1e 07 f5
	ret                                                  ; FEADF6  0e
.LFEADF7:
	calr EditField_IncDown5                                      ; FEADF7  1e 28 f5
	ret                                                  ; FEADFA  0e
; EditCursor_NextBeatStart: NoteEdit_Button24 / DrumEdit_Button23: selection cleared, EditCursor_AdvanceToNextIncStep with EditField_Inc
;   forced to 0x60 (restored after), then EditCursor_SplitViewTick and EditCursor_SeekPastTick and a redraw;
;   past the view, EditScreen_WrapAndShowCursorMeasure.
EditCursor_NextBeatStart:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEADFB  f2 58 1f 60 cf
	jr z, .LFEAE03                                       ; FEAE00  66 01
	ret                                                  ; FEAE02  0e
.LFEAE03:
	or	(UI_RequestBits:16), 0x08                            ; FEAE03  c1 75 20 3e 08
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAE08  c2 5b 1f 60 3c fe
	ld wa, (EditField_Inc:24)                                ; FEAE0E  d2 4d 1f 60 20
	pushw wa                                             ; FEAE13  28
	ldw (EditField_Inc:24), 0x60                             ; FEAE14  f2 4d 1f 60 02 60 00
	calr EditCursor_AdvanceToNextIncStep                                      ; FEAE1B  1e eb f8
	popw wa                                              ; FEAE1E  48
	ld (EditField_Inc:24), wa                                ; FEAE1F  f2 4d 1f 60 50
	ld c, (EditMeasure_Beats:24)                                 ; FEAE24  c2 75 1f 60 23
	mul C,0x60                                           ; FEAE29  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FEAE2C  d2 54 1f 60 f9
	jr nc, .LFEAE54                                      ; FEAE31  6f 21
	calr EditCursor_SplitViewTick                                      ; FEAE33  1e 0d f9
	calr BStore_CursorSlot_Save                                          ; FEAE36  1e b5 de
	calr EditCursor_SeekPastTick                                          ; FEAE39  1e 0f ea
	calr BStore_CursorSlot_Restore                                          ; FEAE3C  1e d6 de
	cp	(BStore_ErrorCode:16), 0x00                            ; FEAE3F  c1 4a 0d 3f 00
	jr nz, .LFEAE50                                      ; FEAE44  6e 0a
	calr EditScreen_EraseFieldRow                                          ; FEAE46  1e 2f 49
	calr EditScreen_DrawFields                                          ; FEAE49  1e 8a 4a
	calr EditScreen_RedrawCursorLayer                                          ; FEAE4C  1e 3b 4f
	ret                                                  ; FEAE4F  0e
.LFEAE50:
	calr EditScreen_FlagMemoryFull                                          ; FEAE50  1e 81 dd
	ret                                                  ; FEAE53  0e
.LFEAE54:
	calr EditScreen_WrapAndShowCursorMeasure                                          ; FEAE54  1e 06 e7
	ret                                                  ; FEAE57  0e
; EditCursor_PrevBeatStart: NoteEdit_Button23 / DrumEdit_Button22: the mirror with EditCursor_StepBackToIncGrid at a 0x60 grid; at view
;   tick 0, EditScreen_ShowPreviousMeasure.
EditCursor_PrevBeatStart:
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAE58  f2 58 1f 60 cf
	jr z, .LFEAE60                                       ; FEAE5D  66 01
	ret                                                  ; FEAE5F  0e
.LFEAE60:
	or	(UI_RequestBits:16), 0x08                            ; FEAE60  c1 75 20 3e 08
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAE65  c2 5b 1f 60 3c fe
	cpw	(EditCursor_TickInMeasure:24), 0x0000                        ; FEAE6B  d2 54 1f 60 3f 00 00
	jr nz, .LFEAE78                                      ; FEAE72  6e 04
	calr EditScreen_ShowPreviousMeasure                                          ; FEAE74  1e d1 e7
	ret                                                  ; FEAE77  0e
.LFEAE78:
	ld wa, (EditField_Inc:24)                                ; FEAE78  d2 4d 1f 60 20
	pushw wa                                             ; FEAE7D  28
	ldw (EditField_Inc:24), 0x60                             ; FEAE7E  f2 4d 1f 60 02 60 00
	calr EditCursor_StepBackToIncGrid                                      ; FEAE85  1e 97 f8
	popw wa                                              ; FEAE88  48
	ld (EditField_Inc:24), wa                                ; FEAE89  f2 4d 1f 60 50
	calr EditCursor_SplitViewTick                                      ; FEAE8E  1e b2 f8
	calr EditScreen_EraseFieldRow                                          ; FEAE91  1e e4 48
	calr EditScreen_DrawFields                                          ; FEAE94  1e 3f 4a
	calr EditScreen_RedrawCursorLayer                                          ; FEAE97  1e f0 4e
	ret                                                  ; FEAE9A  0e
; DrumEdit_LcdKeyRow3: the LcdKeyRow3 action of DrumEdit -- called only by LcdKeyRow3_DrumEdit.
DrumEdit_LcdKeyRow3:
	or	(UI_RequestBits:16), 0x08                            ; FEAE9B  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAEA0  f2 58 1f 60 cf
	jr z, .LFEAEB0                                       ; FEAEA5  66 09
	cp	(EditScreen_ActionIndex:24), 0x05                          ; FEAEA7  c2 59 1f 60 3f 05
	jr z, .LFEAEB0                                       ; FEAEAD  66 01
	ret                                                  ; FEAEAF  0e
.LFEAEB0:
	bit 0x07,W                                           ; FEAEB0  c8 33 07
	jrl nz, .LFEAF28                                     ; FEAEB3  7e 72 00
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAEB6  c2 5b 1f 60 3c fe
; DrumEdit_RowFollowNoteUp: after EditCursor_Note + 1 in DRUM EDIT (unless (0x601F1C) bit 7): EditScreen_CursorRow + 1 below 11, with
;   the left column and highlight redrawn; at row 11 the list scrolls instead, DrumEdit_TopRowNote + 1 below 0x74.
DrumEdit_RowFollowNoteUp:
	ld XIX,NoteEdit_HeldKeys                                    ; FEAEBC  44 1c 1f 60 00
	ld A,(XIX)                                           ; FEAEC1  84 21
	bit 0x07,A                                           ; FEAEC3  c9 33 07
	jr nz, .LFEAF27                                      ; FEAEC6  6e 5f
	cpw	(EditScreen_CursorRow:24), 0x000b                        ; FEAEC8  d2 73 1f 60 3f 0b 00
	jr nc, .LFEAEF2                                      ; FEAECF  6f 21
	incw 0x01, (EditScreen_CursorRow:24)                          ; FEAED1  d2 73 1f 60 61
	calr DrumEdit_CursorNoteFromRow                                      ; FEAED6  1e de 00
	calr EditScreen_EraseLeftColumn_Layer1                                          ; FEAED9  1e 91 49
	calr EditScreen_HighlightCursorRow                                      ; FEAEDC  1e 5e 01
	calr EditScreen_EraseEditArea_Layer1                                          ; FEAEDF  1e 77 49
	calr EditScreen_EraseFieldRow                                          ; FEAEE2  1e 93 48
	calr EditScreen_DrawFields                                          ; FEAEE5  1e ee 49
	calr EditScreen_RedrawCursorLayer                                          ; FEAEE8  1e 9f 4e
	calr DrumEdit_AuditionRow                                      ; FEAEEB  1e 54 f6
	calr NoteRouting_RebuildForSong_Call                                          ; FEAEEE  1e 4f d1
	ret                                                  ; FEAEF1  0e
.LFEAEF2:
	cpw	(DrumEdit_TopRowNote:24), 0x0074                        ; FEAEF2  d2 71 1f 60 3f 74 00
	jr nc, .LFEAF27                                      ; FEAEF9  6f 2c
	incw 0x01, (DrumEdit_TopRowNote:24)                          ; FEAEFB  d2 71 1f 60 61
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAF00  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x05                             ; FEAF06  f2 59 1f 60 00 05
	calr DrumEdit_CursorNoteFromRow                                      ; FEAF0C  1e a8 00
	calr DrumEdit_RedrawRowList                                      ; FEAF0F  1e 57 01
	calr EditScreen_EraseEditArea_Layer0                                          ; FEAF12  1e bd 48
	calr EditScreen_EraseEditArea_Layer1                                          ; FEAF15  1e 41 49
	calr EditScreen_EraseFieldRow                                          ; FEAF18  1e 5d 48
	calr EditScreen_DrawFields                                          ; FEAF1B  1e b8 49
	calr EditScreen_RedrawCursorLayer                                          ; FEAF1E  1e 69 4e
	calr DrumEdit_AuditionRow                                      ; FEAF21  1e 1e f6
	calr NoteRouting_RebuildForSong_Call                                          ; FEAF24  1e 19 d1
.LFEAF27:
	ret                                                  ; FEAF27  0e
.LFEAF28:
	ret                                                  ; FEAF28  0e
; DrumEdit_LcdKeyRow2: the LcdKeyRow2 action of DrumEdit -- called only by LcdKeyRow2_DrumEdit.
DrumEdit_LcdKeyRow2:
	or	(UI_RequestBits:16), 0x08                            ; FEAF29  c1 75 20 3e 08
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAF2E  f2 58 1f 60 cf
	jr z, .LFEAF3E                                       ; FEAF33  66 09
	cp	(EditScreen_ActionIndex:24), 0x05                          ; FEAF35  c2 59 1f 60 3f 05
	jr z, .LFEAF3E                                       ; FEAF3B  66 01
	ret                                                  ; FEAF3D  0e
.LFEAF3E:
	bit 0x07,W                                           ; FEAF3E  c8 33 07
	jrl nz, .LFEAFB6                                     ; FEAF41  7e 72 00
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAF44  c2 5b 1f 60 3c fe
; DrumEdit_RowFollowNoteDown: the mirror: EditScreen_CursorRow - 1 above 0, or DrumEdit_TopRowNote - 1 above 1.
DrumEdit_RowFollowNoteDown:
	ld XIX,NoteEdit_HeldKeys                                    ; FEAF4A  44 1c 1f 60 00
	ld A,(XIX)                                           ; FEAF4F  84 21
	bit 0x07,A                                           ; FEAF51  c9 33 07
	jr nz, .LFEAFB5                                      ; FEAF54  6e 5f
	cpw	(EditScreen_CursorRow:24), 0x0000                        ; FEAF56  d2 73 1f 60 3f 00 00
	jr z, .LFEAF80                                       ; FEAF5D  66 21
	decw 0x01, (EditScreen_CursorRow:24)                          ; FEAF5F  d2 73 1f 60 69
	calr DrumEdit_CursorNoteFromRow                                      ; FEAF64  1e 50 00
	calr EditScreen_EraseLeftColumn_Layer1                                          ; FEAF67  1e 03 49
	calr EditScreen_HighlightCursorRow                                      ; FEAF6A  1e d0 00
	calr EditScreen_EraseEditArea_Layer1                                          ; FEAF6D  1e e9 48
	calr EditScreen_EraseFieldRow                                          ; FEAF70  1e 05 48
	calr EditScreen_DrawFields                                          ; FEAF73  1e 60 49
	calr EditScreen_RedrawCursorLayer                                          ; FEAF76  1e 11 4e
	calr DrumEdit_AuditionRow                                      ; FEAF79  1e c6 f5
	calr NoteRouting_RebuildForSong_Call                                          ; FEAF7C  1e c1 d0
	ret                                                  ; FEAF7F  0e
.LFEAF80:
	cpw	(DrumEdit_TopRowNote:24), 0x0001                        ; FEAF80  d2 71 1f 60 3f 01 00
	jr z, .LFEAFB5                                       ; FEAF87  66 2c
	decw 0x01, (DrumEdit_TopRowNote:24)                          ; FEAF89  d2 71 1f 60 69
	ld (EditScreen_ActionTimer:24), 0x83                             ; FEAF8E  f2 58 1f 60 00 83
	ld (EditScreen_ActionIndex:24), 0x05                             ; FEAF94  f2 59 1f 60 00 05
	calr DrumEdit_CursorNoteFromRow                                      ; FEAF9A  1e 1a 00
	calr DrumEdit_RedrawRowList                                      ; FEAF9D  1e c9 00
	calr EditScreen_EraseEditArea_Layer0                                          ; FEAFA0  1e 2f 48
	calr EditScreen_EraseEditArea_Layer1                                          ; FEAFA3  1e b3 48
	calr EditScreen_EraseFieldRow                                          ; FEAFA6  1e cf 47
	calr EditScreen_DrawFields                                          ; FEAFA9  1e 2a 49
	calr EditScreen_RedrawCursorLayer                                          ; FEAFAC  1e db 4d
	calr DrumEdit_AuditionRow                                      ; FEAFAF  1e 90 f5
	calr NoteRouting_RebuildForSong_Call                                          ; FEAFB2  1e 8b d0
.LFEAFB5:
	ret                                                  ; FEAFB5  0e
.LFEAFB6:
	ret                                                  ; FEAFB6  0e
; DrumEdit_CursorNoteFromRow: DRUM EDIT: EditCursor_Note = DrumEdit_TopRowNote + EditScreen_CursorRow.
DrumEdit_CursorNoteFromRow:
	bit	0, (EditScreen_Mode:24)                             ; FEAFB7  f2 70 1f 60 c8
	jr z, .LFEAFCF                                       ; FEAFBC  66 11
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEAFBE  d2 71 1f 60 20
	ld de, (EditScreen_CursorRow:24)                                ; FEAFC3  d2 73 1f 60 22
	add WA,DE                                            ; FEAFC8  da 80
	ld (EditCursor_Note:24), a                                 ; FEAFCA  f2 44 1f 60 41
.LFEAFCF:
	ret                                                  ; FEAFCF  0e
; DrumEdit_LcdKeyRow1: the LcdKeyRow1 action of DrumEdit -- called only by LcdKeyRow1_DrumEdit.
DrumEdit_LcdKeyRow1:
	ld XIX,NoteEdit_HeldKeys                                    ; FEAFD0  44 1c 1f 60 00
	ld A,(XIX)                                           ; FEAFD5  84 21
	bit 0x07,A                                           ; FEAFD7  c9 33 07
	jr nz, .LFEAFE3                                      ; FEAFDA  6e 07
	bit	7, (EditScreen_ActionTimer:24)                             ; FEAFDC  f2 58 1f 60 cf
	jr z, .LFEAFE4                                       ; FEAFE1  66 01
.LFEAFE3:
	ret                                                  ; FEAFE3  0e
.LFEAFE4:
	bit 0x07,W                                           ; FEAFE4  c8 33 07
	jr nz, .LFEAFF0                                      ; FEAFE7  6e 07
	ldw (UI_Request:16), 0x8029                              ; FEAFE9  f1 70 20 02 29 80
	ret                                                  ; FEAFEF  0e
.LFEAFF0:
	ret                                                  ; FEAFF0  0e
; EditScreen_DeferredReselectAndRedraw5: EditScreen_DeferredActions[5] (queued by the DRUM EDIT scroll): the same four calls.
EditScreen_DeferredReselectAndRedraw5:   ; entry: named by 1 `.long` operand, first at 0xFE9325
	calr EditScreen_SelectEventAtCursor                                          ; FEAFF1  1e 1d df
	calr EditScreen_EraseEditArea_Layer0                                          ; FEAFF4  1e db 47
	calr EditScreen_DrawVisibleNotes                                          ; FEAFF7  1e c5 4e
	calr EditScreen_RedrawCursorLayer                                          ; FEAFFA  1e 8d 4d
	ret                                                  ; FEAFFD  0e
; DrumEdit_SoftKeyCol8: the SoftKeyCol8 action of DrumEdit -- called only by SoftKeyCol8_DrumEdit.
DrumEdit_SoftKeyCol8:
	and	(EditScreen_CursorFlags:24), 0xfe                          ; FEAFFE  c2 5b 1f 60 3c fe
	calr DrumEdit_CursorNoteFromRow                                      ; FEB004  1e b0 ff
	ld a, (EditCursor_Note:24)                                 ; FEB007  c2 44 1f 60 21
	ld (NoteEdit_InputNote:24), a                                 ; FEB00C  f2 34 1f 60 41
	ld a, (EditField_NewNoteVelocity:24)                                 ; FEB011  c2 46 1f 60 21
	ld (NoteEdit_InputVelocity:24), a                                 ; FEB016  f2 35 1f 60 41
	ld (EditField_EventVelocity:24), a                                 ; FEB01B  f2 45 1f 60 41
	calr DrumEdit_AuditionEnteredNote                                      ; FEB020  1e 10 00
	calr NoteEdit_InsertNoteAndSync                                          ; FEB023  1e 9a e1
	calr EditScreen_EraseEditArea_Layer1                                          ; FEB026  1e 30 48
	calr EditScreen_StepCursorAfterEntry                                          ; FEB029  1e 64 e2
	calr EditScreen_EraseEditArea_Layer0                                          ; FEB02C  1e a3 47
	calr EditScreen_DrawVisibleNotes                                          ; FEB02F  1e 8d 4e
	ret                                                  ; FEB032  0e
; DrumEdit_AuditionEnteredNote: EditScreen_AuditionEvent, EditScreen_ActionTimer2 = 0x82.  Called by DrumEdit_SoftKeyCol8 after it enters a
;   note.
DrumEdit_AuditionEnteredNote:
	calr EditScreen_AuditionEvent                                      ; FEB033  1e ff f4
	ld (EditScreen_ActionTimer2:24), 0x82                             ; FEB036  f2 5a 1f 60 00 82
	ret                                                  ; FEB03C  0e
; EditScreen_HighlightCursorRow: LCD_Svc_05_FillRect x 0..0x16, y = (0x601F73) * 10 + 0x2A .. +8: one 10-pixel row of the left column.  Called
;   between EditScreen_EraseLeftColumn_Layer1 and the DRUM EDIT row numbers by the three column redraws.
EditScreen_HighlightCursorRow:
	ldw (LCD_X0:16), 0x00                                ; FEB03D  f1 30 25 02 00 00
	ldw (LCD_X1:16), 0x16                                ; FEB043  f1 34 25 02 16 00
	ld wa, (EditScreen_CursorRow:24)                                ; FEB049  d2 73 1f 60 20
	mul A,0x0a                                           ; FEB04E  c9 08 0a
	add WA,0x002a                                        ; FEB051  d8 c8 2a 00
	ld (LCD_Y0:16), wa                                  ; FEB055  f1 32 25 50
	ld wa, (LCD_Y0:16)                                 ; FEB059  d1 32 25 20
	add WA,0x0008                                        ; FEB05D  d8 c8 08 00
	ld (LCD_Y1:16), wa                                  ; FEB061  f1 36 25 50
	ld a, 0x05:opc                                          ; FEB065  21 05
	swi 7                                                ; FEB067  ff
	ret                                                  ; FEB068  0e
; DrumEdit_RedrawRowList: DRUM EDIT: the left column erased (EditScreen_EraseRowLabelArea), DrumEdit_DrawRowNotes, DrumEdit_DrawRowNames.
DrumEdit_RedrawRowList:
	bit	0, (EditScreen_Mode:24)                             ; FEB069  f2 70 1f 60 c8
	jr z, .LFEB079                                       ; FEB06E  66 09
	calr EditScreen_EraseRowLabelArea                                          ; FEB070  1e 18 48
	calr DrumEdit_DrawRowNotes                                      ; FEB073  1e 04 00
	calr DrumEdit_DrawRowNames                                          ; FEB076  1e 07 02
.LFEB079:
	ret                                                  ; FEB079  0e
; DrumEdit_DrawRowNotes: layer 0, then DrumEdit_DrawRowNote0 .. DrumEdit_DrawRowNote11.  Called by DrumEdit_RedrawRowList only when EditScreen_Mode
;   bit 0 (DRUM EDIT) is set.
DrumEdit_DrawRowNotes:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEB07A  f1 40 25 00 00
	calr DrumEdit_DrawRowNote0                                      ; FEB07F  1e 22 00
	calr DrumEdit_DrawRowNote1                                            ; FEB082  1e 43 00
	calr DrumEdit_DrawRowNote2                                            ; FEB085  1e 68 00
	calr DrumEdit_DrawRowNote3                                            ; FEB088  1e 8d 00
	calr DrumEdit_DrawRowNote4                                            ; FEB08B  1e b2 00
	calr DrumEdit_DrawRowNote5                                            ; FEB08E  1e d7 00
	calr DrumEdit_DrawRowNote6                                            ; FEB091  1e fc 00
	calr DrumEdit_DrawRowNote7                                          ; FEB094  1e 21 01
	calr DrumEdit_DrawRowNote8                                          ; FEB097  1e 46 01
	calr DrumEdit_DrawRowNote9                                          ; FEB09A  1e 6b 01
	calr DrumEdit_DrawRowNote10                                          ; FEB09D  1e 90 01
	calr DrumEdit_DrawRowNote11                                          ; FEB0A0  1e b5 01
	ret                                                  ; FEB0A3  0e
; DrumEdit_DrawRowNote0 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 6
; instructions to its first `ret`:
;     site 0xFEB0B7  interpreter B  list 0xFEB0BC-0xFEB0C8
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote0: (0x601F71) + 0 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 0's note number.
DrumEdit_DrawRowNote0:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB0A4  d2 71 1f 60 20
	ld (0x26b0:16), wa                                  ; FEB0A9  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote0_DL                            ; FEB0AD  45 bc b0 fe 00
	ld XIX,DrumEdit_DrawRowNote1                                    ; FEB0B2  44 c8 b0 fe 00
	call T_DisplayListB_Run                              ; FEB0B7  1d f4 17 f4
	ret                                                  ; FEB0BB  0e

; DrumEdit_DrawRowNote0_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB0BC and land exactly on 0xFEB0C8.
DrumEdit_DrawRowNote0_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote0 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=43, digits=3
; DrumEdit_DrawRowNote1 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB0DF  interpreter B  list 0xFEB0E4-0xFEB0F0
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote1: (0x601F71) + 1 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 1's note number.
DrumEdit_DrawRowNote1:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB0C8  d2 71 1f 60 20
	add WA,0x0001                                        ; FEB0CD  d8 c8 01 00
	ld (0x26b0:16), wa                                  ; FEB0D1  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote1_DL                            ; FEB0D5  45 e4 b0 fe 00
	ld XIX,DrumEdit_DrawRowNote2                                    ; FEB0DA  44 f0 b0 fe 00
	call T_DisplayListB_Run                              ; FEB0DF  1d f4 17 f4
	ret                                                  ; FEB0E3  0e

; DrumEdit_DrawRowNote1_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB0E4 and land exactly on 0xFEB0F0.
DrumEdit_DrawRowNote1_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=53, digits=3
; DrumEdit_DrawRowNote2 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB107  interpreter B  list 0xFEB10C-0xFEB118
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote2: (0x601F71) + 2 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 2's note number.
DrumEdit_DrawRowNote2:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB0F0  d2 71 1f 60 20
	add WA,0x0002                                        ; FEB0F5  d8 c8 02 00
	ld (0x26b0:16), wa                                  ; FEB0F9  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote2_DL                            ; FEB0FD  45 0c b1 fe 00
	ld XIX,DrumEdit_DrawRowNote3                                    ; FEB102  44 18 b1 fe 00
	call T_DisplayListB_Run                              ; FEB107  1d f4 17 f4
	ret                                                  ; FEB10B  0e

; DrumEdit_DrawRowNote2_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB10C and land exactly on 0xFEB118.
DrumEdit_DrawRowNote2_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=63, digits=3
; DrumEdit_DrawRowNote3 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB12F  interpreter B  list 0xFEB134-0xFEB140
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote3: (0x601F71) + 3 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 3's note number.
DrumEdit_DrawRowNote3:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB118  d2 71 1f 60 20
	add WA,0x0003                                        ; FEB11D  d8 c8 03 00
	ld (0x26b0:16), wa                                  ; FEB121  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote3_DL                            ; FEB125  45 34 b1 fe 00
	ld XIX,DrumEdit_DrawRowNote4                                    ; FEB12A  44 40 b1 fe 00
	call T_DisplayListB_Run                              ; FEB12F  1d f4 17 f4
	ret                                                  ; FEB133  0e

; DrumEdit_DrawRowNote3_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB134 and land exactly on 0xFEB140.
DrumEdit_DrawRowNote3_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote3 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=73, digits=3
; DrumEdit_DrawRowNote4 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB157  interpreter B  list 0xFEB15C-0xFEB168
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote4: (0x601F71) + 4 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 4's note number.
DrumEdit_DrawRowNote4:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB140  d2 71 1f 60 20
	add WA,0x0004                                        ; FEB145  d8 c8 04 00
	ld (0x26b0:16), wa                                  ; FEB149  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote4_DL                            ; FEB14D  45 5c b1 fe 00
	ld XIX,DrumEdit_DrawRowNote5                                    ; FEB152  44 68 b1 fe 00
	call T_DisplayListB_Run                              ; FEB157  1d f4 17 f4
	ret                                                  ; FEB15B  0e

; DrumEdit_DrawRowNote4_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB15C and land exactly on 0xFEB168.
DrumEdit_DrawRowNote4_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote4 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=83, digits=3
; DrumEdit_DrawRowNote5 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB17F  interpreter B  list 0xFEB184-0xFEB190
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote5: (0x601F71) + 5 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 5's note number.
DrumEdit_DrawRowNote5:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB168  d2 71 1f 60 20
	add WA,0x0005                                        ; FEB16D  d8 c8 05 00
	ld (0x26b0:16), wa                                  ; FEB171  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote5_DL                            ; FEB175  45 84 b1 fe 00
	ld XIX,DrumEdit_DrawRowNote6                                    ; FEB17A  44 90 b1 fe 00
	call T_DisplayListB_Run                              ; FEB17F  1d f4 17 f4
	ret                                                  ; FEB183  0e

; DrumEdit_DrawRowNote5_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB184 and land exactly on 0xFEB190.
DrumEdit_DrawRowNote5_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote5 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=93, digits=3
; DrumEdit_DrawRowNote6 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB1A7  interpreter B  list 0xFEB1AC-0xFEB1B8
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote6: (0x601F71) + 6 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 6's note number.
DrumEdit_DrawRowNote6:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB190  d2 71 1f 60 20
	add WA,0x0006                                        ; FEB195  d8 c8 06 00
	ld (0x26b0:16), wa                                  ; FEB199  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote6_DL                            ; FEB19D  45 ac b1 fe 00
	ld XIX,DrumEdit_DrawRowNote7                                    ; FEB1A2  44 b8 b1 fe 00
	call T_DisplayListB_Run                              ; FEB1A7  1d f4 17 f4
	ret                                                  ; FEB1AB  0e

; DrumEdit_DrawRowNote6_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB1AC and land exactly on 0xFEB1B8.
DrumEdit_DrawRowNote6_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote6 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=103, digits=3
; DrumEdit_DrawRowNote7 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB1CF  interpreter B  list 0xFEB1D4-0xFEB1E0
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote7: (0x601F71) + 7 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 7's note number.
DrumEdit_DrawRowNote7:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB1B8  d2 71 1f 60 20
	add WA,0x0007                                        ; FEB1BD  d8 c8 07 00
	ld (0x26b0:16), wa                                  ; FEB1C1  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote7_DL                            ; FEB1C5  45 d4 b1 fe 00
	ld XIX,DrumEdit_DrawRowNote8                                    ; FEB1CA  44 e0 b1 fe 00
	call T_DisplayListB_Run                              ; FEB1CF  1d f4 17 f4
	ret                                                  ; FEB1D3  0e

; DrumEdit_DrawRowNote7_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB1D4 and land exactly on 0xFEB1E0.
DrumEdit_DrawRowNote7_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote7 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=113, digits=3
; DrumEdit_DrawRowNote8 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB1F7  interpreter B  list 0xFEB1FC-0xFEB208
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote8: (0x601F71) + 8 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 8's note number.
DrumEdit_DrawRowNote8:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB1E0  d2 71 1f 60 20
	add WA,0x0008                                        ; FEB1E5  d8 c8 08 00
	ld (0x26b0:16), wa                                  ; FEB1E9  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote8_DL                            ; FEB1ED  45 fc b1 fe 00
	ld XIX,DrumEdit_DrawRowNote9                                    ; FEB1F2  44 08 b2 fe 00
	call T_DisplayListB_Run                              ; FEB1F7  1d f4 17 f4
	ret                                                  ; FEB1FB  0e

; DrumEdit_DrawRowNote8_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB1FC and land exactly on 0xFEB208.
DrumEdit_DrawRowNote8_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=123, digits=3
; DrumEdit_DrawRowNote9 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB21F  interpreter B  list 0xFEB224-0xFEB230
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote9: (0x601F71) + 9 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 9's note number.
DrumEdit_DrawRowNote9:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB208  d2 71 1f 60 20
	add WA,0x0009                                        ; FEB20D  d8 c8 09 00
	ld (0x26b0:16), wa                                  ; FEB211  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote9_DL                            ; FEB215  45 24 b2 fe 00
	ld XIX,DrumEdit_DrawRowNote10                                    ; FEB21A  44 30 b2 fe 00
	call T_DisplayListB_Run                              ; FEB21F  1d f4 17 f4
	ret                                                  ; FEB223  0e

; DrumEdit_DrawRowNote9_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB224 and land exactly on 0xFEB230.
DrumEdit_DrawRowNote9_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote9 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=133, digits=3
; DrumEdit_DrawRowNote10 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB247  interpreter B  list 0xFEB24C-0xFEB258
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote10: (0x601F71) + 10 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 10's note number.
DrumEdit_DrawRowNote10:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB230  d2 71 1f 60 20
	add WA,0x000a                                        ; FEB235  d8 c8 0a 00
	ld (0x26b0:16), wa                                  ; FEB239  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote10_DL                            ; FEB23D  45 4c b2 fe 00
	ld XIX,DrumEdit_DrawRowNote11                                    ; FEB242  44 58 b2 fe 00
	call T_DisplayListB_Run                              ; FEB247  1d f4 17 f4
	ret                                                  ; FEB24B  0e

; DrumEdit_DrawRowNote10_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB24C and land exactly on 0xFEB258.
DrumEdit_DrawRowNote10_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote10 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=143, digits=3
; DrumEdit_DrawRowNote11 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFEB26F  interpreter B  list 0xFEB274-0xFEB280
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawRowNote11: (0x601F71) + 11 to the interpreter-B variable 0x26B0, then a one-record list (op 0A, a decimal readout,
;   handler 0xF31C14) -- row 11's note number.
DrumEdit_DrawRowNote11:
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEB258  d2 71 1f 60 20
	add WA,0x000b                                        ; FEB25D  d8 c8 0b 00
	ld (0x26b0:16), wa                                  ; FEB261  f1 b0 26 50
	ld XIY,DrumEdit_DrawRowNote11_DL                            ; FEB265  45 74 b2 fe 00
	ld XIX,DrumEdit_DrawRowNames                                    ; FEB26A  44 80 b2 fe 00
	call T_DisplayListB_Run                              ; FEB26F  1d f4 17 f4
	ret                                                  ; FEB273  0e

; DrumEdit_DrawRowNote11_DL -- 1 record(s), 12 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEB274 and land exactly on 0xFEB280.
DrumEdit_DrawRowNote11_DL:
; ; drawn (start operand) by DrumEdit_DrawRowNote11 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16_xy	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x8Packed, x=2, y=153, digits=3
; DrumEdit_DrawRowNames: DrumEdit_DrawRowName for rows 0..11.
DrumEdit_DrawRowNames:
	xor DE,DE                                            ; FEB280  da d2
.LFEB282:
	pushw de                                             ; FEB282  2a
	calr DrumEdit_DrawRowName                                      ; FEB283  1e 0a 00
	popw de                                              ; FEB286  4a
	inc 1,DE                                             ; FEB287  da 61
	cp DE,0x000c                                         ; FEB289  da cf 0c 00
	jr c, .LFEB282                                       ; FEB28D  67 f3
	ret                                                  ; FEB28F  0e
; DrumEdit_DrawRowName: (row DE) layer 0: note = DrumEdit_TopRowNote + row; T_DrumMap_MapNoteForPart with the part's kit (0x603422[EditScreen_Part])
;   and the note; RecordNameSource_Select; 10 characters (SWI 7 0x17) at x 0x1A, y = row x 10 + 0x2B.
DrumEdit_DrawRowName:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEB290  f1 40 25 00 00
	ld hl, (DrumEdit_TopRowNote:24)                                ; FEB295  d2 71 1f 60 23
	add HL,DE                                            ; FEB29A  da 83
	ld XIX,BStore_TrackToPart                                    ; FEB29C  44 22 34 60 00
	ld a, (EditScreen_Part:24)                                 ; FEB2A1  c2 00 1f 60 21
	ld	b, (xix+a)                                   ; FEB2A6  c3 03 f0 e0 22
	ld A,L                                               ; FEB2AB  cf 89
	pushw hl                                             ; FEB2AD  2b
	pushw de                                             ; FEB2AE  2a
	call T_DrumMap_MapNoteForPart                                        ; FEB2AF  1d 40 10 f4
	popw de                                              ; FEB2B3  4a
	popw hl                                              ; FEB2B4  4b
	ld L,A                                               ; FEB2B5  c9 8f
	ldw (LCD_X0:16), 0x1a                                ; FEB2B7  f1 30 25 02 1a 00
	mul E,0x0a                                           ; FEB2BD  cd 08 0a
	add DE,0x002b                                        ; FEB2C0  da c8 2b 00
	ld (LCD_Y0:16), de                                  ; FEB2C4  f1 32 25 52
	pushw hl                                             ; FEB2C8  2b
	calr RecordNameSource_Select                                      ; FEB2C9  1e 08 00
	popw hl                                              ; FEB2CC  4b
	ldw bc, 0x0a                                         ; FEB2CD  31 0a 00
	ld a, 0x17:opc                                          ; FEB2D0  21 17
	swi 7                                                ; FEB2D2  ff
	ret                                                  ; FEB2D3  0e
; ---------------------------------------------------------------------
; RecordNameSource_Select -- returns, in XIY, the name source for the record selected
;                            by (0x601F00) -- a drum-kit name block, a RAM buffer, or
;                            the name table itself -- according to the record's +0x01
;                            byte
;
; Evidence: 0xFEB2D4 `ld XIX,0x00603422` and 0xFEB2D9 `ld A,(0x601F00)`
;           pick the record; 0xFEB2E3 `ld XIY,0x00FEB330` with 0xFEB2EA
;           `sll WA,0x02` and 0xFEB2ED `ld XIX,(XIY+WA)` indexes
;           RecordPtrs_RAM76A2 at a stride of 4; 0xFEB2F2 `ld
;           A,(XIX+0x01)` reads the selector and 0xFEB2F5-0xFEB309
;           branch on 0x20, 0x28, 0x29 and 0x30. The four arms:
;           0xFEB30B-0xFEB318 returns DrumKitNameBlockPtrs[record+0x00],
;           0xFEB31E and 0xFEB324 return the RAM buffer 0x603FF6, and
;           0xFEB32A returns DrumKitNames. Those five arm addresses and
;           their targets are exactly what this listing's own drum-name
;           block header already states, under `WHAT A RECORD'S +0x01
;           BYTE SELECTS`; only the label was still sub_XXXXXX. One call
;           site, `calr` at 0xFEB2C9
; Unknown:  what (0x601F00) indexes and what the RAM buffer at 0x603FF6
;           holds. ⚠ EMITTER RISK: this label is inside
;           gen_prom_a_fe8000_module.py's declared range
;           0xFE8000-0xFEB330 and that emitter has NO name side-car, so
;           re-running it would revert this name; `--emitters` prints
;           the check
; Was `sub_FEB2D4`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
RecordNameSource_Select:
	ld XIX,BStore_TrackToPart                                    ; FEB2D4  44 22 34 60 00
	ld a, (EditScreen_Part:24)                                 ; FEB2D9  c2 00 1f 60 21
	ld	a, (xix+a)                                   ; FEB2DE  c3 03 f0 e0 21
	ld XIY,RecordPtrs_RAM76A2                            ; FEB2E3  45 30 b3 fe 00
	xor W,W                                              ; FEB2E8  c8 d0
	sll wa, 0x02                                         ; FEB2EA  d8 ee 02
	ld	xix, (xiy+a)                                 ; FEB2ED  e3 03 f4 e0 24
	ld A,(XIX+0x01)                                      ; FEB2F2  8c 01 21
	cp A,0x20                                            ; FEB2F5  c9 cf 20
	jr z, .LFEB30B                                       ; FEB2F8  66 11
	cp A,0x28                                            ; FEB2FA  c9 cf 28
	jr z, .LFEB31E                                       ; FEB2FD  66 1f
	cp A,0x29                                            ; FEB2FF  c9 cf 29
	jr z, .LFEB31E                                       ; FEB302  66 1a
	cp A,0x30                                            ; FEB304  c9 cf 30
	jr z, .LFEB324                                       ; FEB307  66 1b
	jr .LFEB32A                                          ; FEB309  68 1f
.LFEB30B:
	ld	a, (xix+0:8)                                 ; FEB30B  8c 00 21
	ld XIX,DrumKitNameBlockPtrs                          ; FEB30E  44 bc b3 fe 00
	xor W,W                                              ; FEB313  c8 d0
	sll wa, 0x02                                         ; FEB315  d8 ee 02
	ld	xiy, (xix+wa)                                ; FEB318  e3 07 f0 e0 25
	ret                                                  ; FEB31D  0e
.LFEB31E:
	ld XIY,0x00603ff6                                    ; FEB31E  45 f6 3f 60 00
	ret                                                  ; FEB323  0e
.LFEB324:
	ld XIY,0x00603ff6                                    ; FEB324  45 f6 3f 60 00
	ret                                                  ; FEB329  0e
.LFEB32A:
	ld XIY,DrumKitNames                                  ; FEB32A  45 c4 b5 fe 00
	ret                                                  ; FEB32F  0e
; ==============================================================================
; 0xFEB330-0xFEF746 -- the DRUM-KIT NAME TABLE and its two pointer tables
; ==============================================================================
;
; Converted 2026-08-25 by notes/gen_prom_a_drumnames.py, which refuses to emit
; anything it has not first checked against the ROM.  Verified by
; notes/prom_a_drumnames_checks.py.
;
; Three regions that tile the range exactly:
;   0xFEB330  RecordPtrs_RAM76A2          35 x LE32 -> RAM
;   0xFEB3BC  DrumKitNameBlockPtrs   130 x LE32 -> into the name table
;   0xFEB5C4  DrumKitNames           13 blocks x 129 names x 10 characters
;
; ---------------------------------------------------------------------
; RecordPtrs_RAM76A2 -- 35 pointers to 64-byte RAM records
;
; Read by: 0xFEB2E3 -- `ld XIY,0x00FEB330 / xor W,W / sll WA,2 /
;          ld XIX,(XIY+A)`, i.e. indexed by a byte in A at a stride of 4.
;          The record it yields is then read at +0x00 and +0x01.
; ENTRY COUNT 35 is from the EXTENT between this base and the next
;          reader-named base (0xFEB3BC), 140 bytes; ⚠ the reader carries NO
;          bound on A, so this count is weaker than the other two here and is
;          stated as such.
; Evidence that these are RAM records and not code: every value is below
;          0x8000, they step by 0x40 -- except once, 0x7862 -> 0x78E2, which is
;          0x80 -- and the last three repeat entry 0 rather than continuing.
; ★ THE SAME RECORD ARRAY APPEARS IN ANOTHER MODULE.  `PtrTable_FF4251`
;          (0xFF4251) holds sixteen pointers 0x76AF ... 0x7AAF: the same base
;          plus 13, the same 0x40 stride, AND THE SAME SINGLE 0x80 STEP in the
;          same place.  Two modules, written independently, agree on the layout
;          of a 64-byte record array at RAM 0x76A2.
; ★ WHAT A RECORD'S +0x01 BYTE SELECTS, read off the five arms at
;          0xFEB2F5-0xFEB309 (targets from prom_a/roundtrip.py --block, not
;          from arithmetic done by hand):
;            0x20        -> 0xFEB30B: XIY = DrumKitNameBlockPtrs[record+0x00],
;                           i.e. THIS record is a drum part and 0x20 is the
;                           type that reaches the name table;
;            0x28, 0x29  -> 0xFEB31E: XIY = RAM 0x00603FF6;
;            0x30        -> 0xFEB324: XIY = RAM 0x00603FF6 (a second, identical
;                           arm -- the compiler did not merge them);
;            anything else -> 0xFEB32A: XIY = 0xFEB5C4, name BLOCK 0, which is
;                           129 blank names.  So an unrecognised type displays
;                           blanks rather than garbage.
; Unknown:  what types 0x28, 0x29 and 0x30 are, and what lives at RAM
;          0x00603FF6.  And ⚠ WHAT THE RECORDS ARE.  This table was called
;          `PartRecordPtrs` until 2026-08-25; the word "Part" was inferred from
;          "35 records, one type of which reaches a drum-name table" and nothing
;          in either image justifies it, so the name is now the ADDRESS of the
;          record array it points into.  Two further reasons the old name was a
;          liability: prom_c 0xFAD850 documents a DIFFERENT structure -- 300-byte
;          records at RAM 0x001523 on CPU 2 -- under the heading "THE PART
;          RECORD", and the two are ~33 entries each, so a reader met two "part
;          records" of different sizes on different processors with nothing
;          saying whether they were the same object.  They are not known to be.
;          ⚠ prom_c still cross-references this table under its OLD name, at
;          prom_c/midi/midi_controllers.s:6906 (0xFAF87F); that file belongs to
;          another lane and was not edited.  ⚠ THE CITATION WAS
;          `prom_c/wsa1_prom_c.s:58817` and pointed nowhere after the
;          per-subject split moved the body out of that file -- cite the
;          ADDRESS, which does not move.
; ---------------------------------------------------------------------
RecordPtrs_RAM76A2:
	.long 0x000076a2                               ; FEB330  [ 0] RAM record 0
	.long 0x000076e2                               ; FEB334  [ 1] RAM record 1
	.long 0x00007722                               ; FEB338  [ 2] RAM record 2
	.long 0x00007762                               ; FEB33C  [ 3] RAM record 3
	.long 0x000077a2                               ; FEB340  [ 4] RAM record 4
	.long 0x000077e2                               ; FEB344  [ 5] RAM record 5
	.long 0x00007822                               ; FEB348  [ 6] RAM record 6
	.long 0x00007862                               ; FEB34C  [ 7] RAM record 7
	.long 0x000078e2                               ; FEB350  [ 8] RAM record 9
	.long 0x00007922                               ; FEB354  [ 9] RAM record 10
	.long 0x00007962                               ; FEB358  [10] RAM record 11
	.long 0x000079a2                               ; FEB35C  [11] RAM record 12
	.long 0x000079e2                               ; FEB360  [12] RAM record 13
	.long 0x00007a22                               ; FEB364  [13] RAM record 14
	.long 0x00007a62                               ; FEB368  [14] RAM record 15
	.long 0x00007aa2                               ; FEB36C  [15] RAM record 16
	.long 0x00007ae2                               ; FEB370  [16] RAM record 17
	.long 0x00007b22                               ; FEB374  [17] RAM record 18
	.long 0x00007b62                               ; FEB378  [18] RAM record 19
	.long 0x00007ba2                               ; FEB37C  [19] RAM record 20
	.long 0x00007be2                               ; FEB380  [20] RAM record 21
	.long 0x00007c22                               ; FEB384  [21] RAM record 22
	.long 0x00007c62                               ; FEB388  [22] RAM record 23
	.long 0x00007ca2                               ; FEB38C  [23] RAM record 24
	.long 0x00007ce2                               ; FEB390  [24] RAM record 25
	.long 0x00007d22                               ; FEB394  [25] RAM record 26
	.long 0x00007d62                               ; FEB398  [26] RAM record 27
	.long 0x00007da2                               ; FEB39C  [27] RAM record 28
	.long 0x00007de2                               ; FEB3A0  [28] RAM record 29
	.long 0x00007e22                               ; FEB3A4  [29] RAM record 30
	.long 0x00007e62                               ; FEB3A8  [30] RAM record 31
	.long 0x00007ea2                               ; FEB3AC  [31] RAM record 32
	.long 0x000076a2                               ; FEB3B0  [32] RAM record 0
	.long 0x000076a2                               ; FEB3B4  [33] RAM record 0
	.long 0x000076a2                               ; FEB3B8  [34] RAM record 0

; ---------------------------------------------------------------------
; DrumKitNameBlockPtrs -- 130 pointers, one per drum program
;
; Read by: 0xFEB30E -- `ld XIX,0x00FEB3BC / xor W,W / sll WA,2 /
;          ld XIY,(XIX+WA)`, indexed by the record's +0x00 byte.
; ENTRY COUNT 130 is from the EXTENT to the name table's own reader-named base
;          0xFEB5C4 (520 bytes); ⚠ again there is no bound in the reader, and
;          again that is weaker than a bound would be.
; ★ WHAT MAKES THE FRAMING CERTAIN ANYWAY: every one of the 130 values is
;          0xFEB5C4 + 1290*k for an integer k in 0..6 -- exactly on a name-block
;          boundary, never one byte off.  A misframed table would not do that.
; Distribution: 123 of the 130 name block 1; the seven exceptions are programs
;          24, 26 and 29 -> block 2, 40 -> block 3, 48 -> block 5,
;          112 -> block 4, 120 -> block 6.  Blocks 0 and 7-12 are never named
;          by this table.
; ---------------------------------------------------------------------
DrumKitNameBlockPtrs:
	.long DrumKitNames_Block1                      ; FEB3BC  [  0] name block 1
	.long DrumKitNames_Block1                      ; FEB3C0  [  1] name block 1
	.long DrumKitNames_Block1                      ; FEB3C4  [  2] name block 1
	.long DrumKitNames_Block1                      ; FEB3C8  [  3] name block 1
	.long DrumKitNames_Block1                      ; FEB3CC  [  4] name block 1
	.long DrumKitNames_Block1                      ; FEB3D0  [  5] name block 1
	.long DrumKitNames_Block1                      ; FEB3D4  [  6] name block 1
	.long DrumKitNames_Block1                      ; FEB3D8  [  7] name block 1
	.long DrumKitNames_Block1                      ; FEB3DC  [  8] name block 1
	.long DrumKitNames_Block1                      ; FEB3E0  [  9] name block 1
	.long DrumKitNames_Block1                      ; FEB3E4  [ 10] name block 1
	.long DrumKitNames_Block1                      ; FEB3E8  [ 11] name block 1
	.long DrumKitNames_Block1                      ; FEB3EC  [ 12] name block 1
	.long DrumKitNames_Block1                      ; FEB3F0  [ 13] name block 1
	.long DrumKitNames_Block1                      ; FEB3F4  [ 14] name block 1
	.long DrumKitNames_Block1                      ; FEB3F8  [ 15] name block 1
	.long DrumKitNames_Block1                      ; FEB3FC  [ 16] name block 1
	.long DrumKitNames_Block1                      ; FEB400  [ 17] name block 1
	.long DrumKitNames_Block1                      ; FEB404  [ 18] name block 1
	.long DrumKitNames_Block1                      ; FEB408  [ 19] name block 1
	.long DrumKitNames_Block1                      ; FEB40C  [ 20] name block 1
	.long DrumKitNames_Block1                      ; FEB410  [ 21] name block 1
	.long DrumKitNames_Block1                      ; FEB414  [ 22] name block 1
	.long DrumKitNames_Block1                      ; FEB418  [ 23] name block 1
	.long DrumKitNames_Block2                      ; FEB41C  [ 24] name block 2
	.long DrumKitNames_Block1                      ; FEB420  [ 25] name block 1
	.long DrumKitNames_Block2                      ; FEB424  [ 26] name block 2
	.long DrumKitNames_Block1                      ; FEB428  [ 27] name block 1
	.long DrumKitNames_Block1                      ; FEB42C  [ 28] name block 1
	.long DrumKitNames_Block2                      ; FEB430  [ 29] name block 2
	.long DrumKitNames_Block1                      ; FEB434  [ 30] name block 1
	.long DrumKitNames_Block1                      ; FEB438  [ 31] name block 1
	.long DrumKitNames_Block1                      ; FEB43C  [ 32] name block 1
	.long DrumKitNames_Block1                      ; FEB440  [ 33] name block 1
	.long DrumKitNames_Block1                      ; FEB444  [ 34] name block 1
	.long DrumKitNames_Block1                      ; FEB448  [ 35] name block 1
	.long DrumKitNames_Block1                      ; FEB44C  [ 36] name block 1
	.long DrumKitNames_Block1                      ; FEB450  [ 37] name block 1
	.long DrumKitNames_Block1                      ; FEB454  [ 38] name block 1
	.long DrumKitNames_Block1                      ; FEB458  [ 39] name block 1
	.long DrumKitNames_Block3                      ; FEB45C  [ 40] name block 3
	.long DrumKitNames_Block1                      ; FEB460  [ 41] name block 1
	.long DrumKitNames_Block1                      ; FEB464  [ 42] name block 1
	.long DrumKitNames_Block1                      ; FEB468  [ 43] name block 1
	.long DrumKitNames_Block1                      ; FEB46C  [ 44] name block 1
	.long DrumKitNames_Block1                      ; FEB470  [ 45] name block 1
	.long DrumKitNames_Block1                      ; FEB474  [ 46] name block 1
	.long DrumKitNames_Block1                      ; FEB478  [ 47] name block 1
	.long DrumKitNames_Block5                      ; FEB47C  [ 48] name block 5
	.long DrumKitNames_Block1                      ; FEB480  [ 49] name block 1
	.long DrumKitNames_Block1                      ; FEB484  [ 50] name block 1
	.long DrumKitNames_Block1                      ; FEB488  [ 51] name block 1
	.long DrumKitNames_Block1                      ; FEB48C  [ 52] name block 1
	.long DrumKitNames_Block1                      ; FEB490  [ 53] name block 1
	.long DrumKitNames_Block1                      ; FEB494  [ 54] name block 1
	.long DrumKitNames_Block1                      ; FEB498  [ 55] name block 1
	.long DrumKitNames_Block1                      ; FEB49C  [ 56] name block 1
	.long DrumKitNames_Block1                      ; FEB4A0  [ 57] name block 1
	.long DrumKitNames_Block1                      ; FEB4A4  [ 58] name block 1
	.long DrumKitNames_Block1                      ; FEB4A8  [ 59] name block 1
	.long DrumKitNames_Block1                      ; FEB4AC  [ 60] name block 1
	.long DrumKitNames_Block1                      ; FEB4B0  [ 61] name block 1
	.long DrumKitNames_Block1                      ; FEB4B4  [ 62] name block 1
	.long DrumKitNames_Block1                      ; FEB4B8  [ 63] name block 1
	.long DrumKitNames_Block1                      ; FEB4BC  [ 64] name block 1
	.long DrumKitNames_Block1                      ; FEB4C0  [ 65] name block 1
	.long DrumKitNames_Block1                      ; FEB4C4  [ 66] name block 1
	.long DrumKitNames_Block1                      ; FEB4C8  [ 67] name block 1
	.long DrumKitNames_Block1                      ; FEB4CC  [ 68] name block 1
	.long DrumKitNames_Block1                      ; FEB4D0  [ 69] name block 1
	.long DrumKitNames_Block1                      ; FEB4D4  [ 70] name block 1
	.long DrumKitNames_Block1                      ; FEB4D8  [ 71] name block 1
	.long DrumKitNames_Block1                      ; FEB4DC  [ 72] name block 1
	.long DrumKitNames_Block1                      ; FEB4E0  [ 73] name block 1
	.long DrumKitNames_Block1                      ; FEB4E4  [ 74] name block 1
	.long DrumKitNames_Block1                      ; FEB4E8  [ 75] name block 1
	.long DrumKitNames_Block1                      ; FEB4EC  [ 76] name block 1
	.long DrumKitNames_Block1                      ; FEB4F0  [ 77] name block 1
	.long DrumKitNames_Block1                      ; FEB4F4  [ 78] name block 1
	.long DrumKitNames_Block1                      ; FEB4F8  [ 79] name block 1
	.long DrumKitNames_Block1                      ; FEB4FC  [ 80] name block 1
	.long DrumKitNames_Block1                      ; FEB500  [ 81] name block 1
	.long DrumKitNames_Block1                      ; FEB504  [ 82] name block 1
	.long DrumKitNames_Block1                      ; FEB508  [ 83] name block 1
	.long DrumKitNames_Block1                      ; FEB50C  [ 84] name block 1
	.long DrumKitNames_Block1                      ; FEB510  [ 85] name block 1
	.long DrumKitNames_Block1                      ; FEB514  [ 86] name block 1
	.long DrumKitNames_Block1                      ; FEB518  [ 87] name block 1
	.long DrumKitNames_Block1                      ; FEB51C  [ 88] name block 1
	.long DrumKitNames_Block1                      ; FEB520  [ 89] name block 1
	.long DrumKitNames_Block1                      ; FEB524  [ 90] name block 1
	.long DrumKitNames_Block1                      ; FEB528  [ 91] name block 1
	.long DrumKitNames_Block1                      ; FEB52C  [ 92] name block 1
	.long DrumKitNames_Block1                      ; FEB530  [ 93] name block 1
	.long DrumKitNames_Block1                      ; FEB534  [ 94] name block 1
	.long DrumKitNames_Block1                      ; FEB538  [ 95] name block 1
	.long DrumKitNames_Block1                      ; FEB53C  [ 96] name block 1
	.long DrumKitNames_Block1                      ; FEB540  [ 97] name block 1
	.long DrumKitNames_Block1                      ; FEB544  [ 98] name block 1
	.long DrumKitNames_Block1                      ; FEB548  [ 99] name block 1
	.long DrumKitNames_Block1                      ; FEB54C  [100] name block 1
	.long DrumKitNames_Block1                      ; FEB550  [101] name block 1
	.long DrumKitNames_Block1                      ; FEB554  [102] name block 1
	.long DrumKitNames_Block1                      ; FEB558  [103] name block 1
	.long DrumKitNames_Block1                      ; FEB55C  [104] name block 1
	.long DrumKitNames_Block1                      ; FEB560  [105] name block 1
	.long DrumKitNames_Block1                      ; FEB564  [106] name block 1
	.long DrumKitNames_Block1                      ; FEB568  [107] name block 1
	.long DrumKitNames_Block1                      ; FEB56C  [108] name block 1
	.long DrumKitNames_Block1                      ; FEB570  [109] name block 1
	.long DrumKitNames_Block1                      ; FEB574  [110] name block 1
	.long DrumKitNames_Block1                      ; FEB578  [111] name block 1
	.long DrumKitNames_Block4                      ; FEB57C  [112] name block 4
	.long DrumKitNames_Block1                      ; FEB580  [113] name block 1
	.long DrumKitNames_Block1                      ; FEB584  [114] name block 1
	.long DrumKitNames_Block1                      ; FEB588  [115] name block 1
	.long DrumKitNames_Block1                      ; FEB58C  [116] name block 1
	.long DrumKitNames_Block1                      ; FEB590  [117] name block 1
	.long DrumKitNames_Block1                      ; FEB594  [118] name block 1
	.long DrumKitNames_Block1                      ; FEB598  [119] name block 1
	.long DrumKitNames_Block6                      ; FEB59C  [120] name block 6
	.long DrumKitNames_Block1                      ; FEB5A0  [121] name block 1
	.long DrumKitNames_Block1                      ; FEB5A4  [122] name block 1
	.long DrumKitNames_Block1                      ; FEB5A8  [123] name block 1
	.long DrumKitNames_Block1                      ; FEB5AC  [124] name block 1
	.long DrumKitNames_Block1                      ; FEB5B0  [125] name block 1
	.long DrumKitNames_Block1                      ; FEB5B4  [126] name block 1
	.long DrumKitNames_Block1                      ; FEB5B8  [127] name block 1
	.long DrumKitNames_Block1                      ; FEB5BC  [128] name block 1
	.long DrumKitNames_Block1                      ; FEB5C0  [129] name block 1

; ---------------------------------------------------------------------
; DrumKitNames -- 13 blocks x 129 names x 10 characters, 16,770 bytes
;
; Fixed-width, space-padded, NO terminator: name j of block k is the ten bytes
; at 0xFEB5C4 + (129*k + j)*10.
;
; ★ HOW THE FRAMING WAS ESTABLISHED, and it is not the string content:
;   1. the region is 16,770 bytes = 13 x 129 x 10 EXACTLY, with no remainder;
;   2. all 130 pointers of DrumKitNameBlockPtrs land on a multiple of 1290 from
;      the base -- so 1290 = 129 x 10 is the block stride the ROM itself uses;
;   3. within a block every name begins on a multiple of 10 and the words read
;      as words ("Bass Dr 1 ", "Crash Cym1") at that offset and at no other.
;   Point 2 is the load-bearing one: it comes from a different table.
;
; ★★ THE INDEX **IS** THE MIDI NOTE NUMBER -- the offset is ZERO, established
; 2026-08-25.  (This paragraph used to say that a name's INDEX is a MIDI note
; number with an OFFSET, and left open which note index 0 is.  That is settled.)
; Indices 35-81 are the General MIDI percussion map, in order, with no shift:
;
;   35 Bass Dr 2  (GM Acoustic Bass Drum)   36 Bass Dr 1  (GM Bass Drum 1)
;   37 Rim Shot   (GM Side Stick)           38 Snare Dr 1 (GM Acoustic Snare)
;   39 Hand Claps (GM Hand Clap)            40 High Snare (GM Electric Snare)
;   41 FloorTom L 42 Hi-HatCLOn 43 FloorTom H 44 Hi-Hat Ped 46 Hi-Hat O
;   49 Crash Cym1 51 Ride Cym 1 52 ChineseCym 53 Ride Bell  54 TamburnAcc
;   55 Splash Cym 56 Cowbell 2  57 Crash Cym2 58 Vibraslap  59 Ride Cym 2
;   60/61 Bongo   62/63/64 Conga 65/66 Timb   67/68 Agogo   69 Cabasa
;   70 Maracas On 71/72 SambaWh 73/74 Guiro   75 Claves     76/77 Wood Blk
;   78/79 Cuica   80 Triangle M 81 Triangle O (GM Open Triangle, the LAST GM key)
;
; ★ The test that makes this a decode rather than a resemblance is its NEGATIVE
; CONTROL, in notes/prom_a_drumnames_checks.py section 6b: 43 GM keywords match
; at their own index (43/43) and only 11/43 match at index+1 or index-1.  So
; what is being measured is the ALIGNMENT, not the presence of the words.
; Index 82 upward ("Shaker On", "SleighBell", "Wind Chime", "Orch.BasDr",
; "Rain Stick", ...) is a Technics extension ABOVE the GM range, which is what a
; GM-compatible kit looks like; indices 0-34 are Technics extras below it
; ("MetroClick", "Metro Bell", "Zap 1", "Voice Ah", "Scratch 1", "Rev Snare").
;
; ⚠ What this does NOT establish: that the byte the reader at 0xFEB2E3 receives
; is a MIDI note ON THE WIRE rather than a key number the panel already
; translated.  It establishes the ENCODING of the index, which is what a
; legend-to-index tie needs.
;
; ★ THE NAME READER pins the 10-byte width independently of the data.
; DrumEdit_DrawRowName (0xFEB290), called 12 times per redraw by DrumEdit_DrawRowNames's loop over
; DE = 0..11 (one row per visible key), sets HL = (0x601F71)+DE with L then
; replaced by what call 0xF41040 returns for it (the index into the block),
; (0x2530) = x 0x1A, (0x2532) = y 10*DE+0x2B, calls
; RecordNameSource_Select (0xFEB2D4) for XIY = the block, then BC = 10 and
; SWI7 service 0x17, LCD_Svc_17_DrawText8x8Packed (0xF90118), which draws BC
; characters from XIY + HL*BC.  So name j of a block is the ten bytes at
; block + 10*j, read by the reader itself, not inferred from the text.
;
; Block 0 is 129 BLANK names.  It is never named by the pointer table; it is
; what 0xFEB32A -- the FALL-THROUGH arm, for a record type that is none of
; 0x20/0x28/0x29/0x30 -- loads directly, so it is the "nothing to show" block.
; Blocks 7-12 are populated but are not named by DrumKitNameBlockPtrs either --
; some other reader must reach them, and it is NOT located: neither
; notes/prom_a_xref.py nor a raw scan for their addresses finds a site.
; ---------------------------------------------------------------------
DrumKitNames:

; ---- name block 0, 0xFEB5C4: 129 of 129 names are blank ----
	.ascii "          "                             ; FEB5C4  [  0][  0]
	.ascii "          "                             ; FEB5CE  [  0][  1]
	.ascii "          "                             ; FEB5D8  [  0][  2]
	.ascii "          "                             ; FEB5E2  [  0][  3]
	.ascii "          "                             ; FEB5EC  [  0][  4]
	.ascii "          "                             ; FEB5F6  [  0][  5]
	.ascii "          "                             ; FEB600  [  0][  6]
	.ascii "          "                             ; FEB60A  [  0][  7]
	.ascii "          "                             ; FEB614  [  0][  8]
	.ascii "          "                             ; FEB61E  [  0][  9]
	.ascii "          "                             ; FEB628  [  0][ 10]
	.ascii "          "                             ; FEB632  [  0][ 11]
	.ascii "          "                             ; FEB63C  [  0][ 12]
	.ascii "          "                             ; FEB646  [  0][ 13]
	.ascii "          "                             ; FEB650  [  0][ 14]
	.ascii "          "                             ; FEB65A  [  0][ 15]
	.ascii "          "                             ; FEB664  [  0][ 16]
	.ascii "          "                             ; FEB66E  [  0][ 17]
	.ascii "          "                             ; FEB678  [  0][ 18]
	.ascii "          "                             ; FEB682  [  0][ 19]
	.ascii "          "                             ; FEB68C  [  0][ 20]
	.ascii "          "                             ; FEB696  [  0][ 21]
	.ascii "          "                             ; FEB6A0  [  0][ 22]
	.ascii "          "                             ; FEB6AA  [  0][ 23]
	.ascii "          "                             ; FEB6B4  [  0][ 24]
	.ascii "          "                             ; FEB6BE  [  0][ 25]
	.ascii "          "                             ; FEB6C8  [  0][ 26]
	.ascii "          "                             ; FEB6D2  [  0][ 27]
	.ascii "          "                             ; FEB6DC  [  0][ 28]
	.ascii "          "                             ; FEB6E6  [  0][ 29]
	.ascii "          "                             ; FEB6F0  [  0][ 30]
	.ascii "          "                             ; FEB6FA  [  0][ 31]
	.ascii "          "                             ; FEB704  [  0][ 32]
	.ascii "          "                             ; FEB70E  [  0][ 33]
	.ascii "          "                             ; FEB718  [  0][ 34]
	.ascii "          "                             ; FEB722  [  0][ 35]
	.ascii "          "                             ; FEB72C  [  0][ 36]
	.ascii "          "                             ; FEB736  [  0][ 37]
	.ascii "          "                             ; FEB740  [  0][ 38]
	.ascii "          "                             ; FEB74A  [  0][ 39]
	.ascii "          "                             ; FEB754  [  0][ 40]
	.ascii "          "                             ; FEB75E  [  0][ 41]
	.ascii "          "                             ; FEB768  [  0][ 42]
	.ascii "          "                             ; FEB772  [  0][ 43]
	.ascii "          "                             ; FEB77C  [  0][ 44]
	.ascii "          "                             ; FEB786  [  0][ 45]
	.ascii "          "                             ; FEB790  [  0][ 46]
	.ascii "          "                             ; FEB79A  [  0][ 47]
	.ascii "          "                             ; FEB7A4  [  0][ 48]
	.ascii "          "                             ; FEB7AE  [  0][ 49]
	.ascii "          "                             ; FEB7B8  [  0][ 50]
	.ascii "          "                             ; FEB7C2  [  0][ 51]
	.ascii "          "                             ; FEB7CC  [  0][ 52]
	.ascii "          "                             ; FEB7D6  [  0][ 53]
	.ascii "          "                             ; FEB7E0  [  0][ 54]
	.ascii "          "                             ; FEB7EA  [  0][ 55]
	.ascii "          "                             ; FEB7F4  [  0][ 56]
	.ascii "          "                             ; FEB7FE  [  0][ 57]
	.ascii "          "                             ; FEB808  [  0][ 58]
	.ascii "          "                             ; FEB812  [  0][ 59]
	.ascii "          "                             ; FEB81C  [  0][ 60]
	.ascii "          "                             ; FEB826  [  0][ 61]
	.ascii "          "                             ; FEB830  [  0][ 62]
	.ascii "          "                             ; FEB83A  [  0][ 63]
	.ascii "          "                             ; FEB844  [  0][ 64]
	.ascii "          "                             ; FEB84E  [  0][ 65]
	.ascii "          "                             ; FEB858  [  0][ 66]
	.ascii "          "                             ; FEB862  [  0][ 67]
	.ascii "          "                             ; FEB86C  [  0][ 68]
	.ascii "          "                             ; FEB876  [  0][ 69]
	.ascii "          "                             ; FEB880  [  0][ 70]
	.ascii "          "                             ; FEB88A  [  0][ 71]
	.ascii "          "                             ; FEB894  [  0][ 72]
	.ascii "          "                             ; FEB89E  [  0][ 73]
	.ascii "          "                             ; FEB8A8  [  0][ 74]
	.ascii "          "                             ; FEB8B2  [  0][ 75]
	.ascii "          "                             ; FEB8BC  [  0][ 76]
	.ascii "          "                             ; FEB8C6  [  0][ 77]
	.ascii "          "                             ; FEB8D0  [  0][ 78]
	.ascii "          "                             ; FEB8DA  [  0][ 79]
	.ascii "          "                             ; FEB8E4  [  0][ 80]
	.ascii "          "                             ; FEB8EE  [  0][ 81]
	.ascii "          "                             ; FEB8F8  [  0][ 82]
	.ascii "          "                             ; FEB902  [  0][ 83]
	.ascii "          "                             ; FEB90C  [  0][ 84]
	.ascii "          "                             ; FEB916  [  0][ 85]
	.ascii "          "                             ; FEB920  [  0][ 86]
	.ascii "          "                             ; FEB92A  [  0][ 87]
	.ascii "          "                             ; FEB934  [  0][ 88]
	.ascii "          "                             ; FEB93E  [  0][ 89]
	.ascii "          "                             ; FEB948  [  0][ 90]
	.ascii "          "                             ; FEB952  [  0][ 91]
	.ascii "          "                             ; FEB95C  [  0][ 92]
	.ascii "          "                             ; FEB966  [  0][ 93]
	.ascii "          "                             ; FEB970  [  0][ 94]
	.ascii "          "                             ; FEB97A  [  0][ 95]
	.ascii "          "                             ; FEB984  [  0][ 96]
	.ascii "          "                             ; FEB98E  [  0][ 97]
	.ascii "          "                             ; FEB998  [  0][ 98]
	.ascii "          "                             ; FEB9A2  [  0][ 99]
	.ascii "          "                             ; FEB9AC  [  0][100]
	.ascii "          "                             ; FEB9B6  [  0][101]
	.ascii "          "                             ; FEB9C0  [  0][102]
	.ascii "          "                             ; FEB9CA  [  0][103]
	.ascii "          "                             ; FEB9D4  [  0][104]
	.ascii "          "                             ; FEB9DE  [  0][105]
	.ascii "          "                             ; FEB9E8  [  0][106]
	.ascii "          "                             ; FEB9F2  [  0][107]
	.ascii "          "                             ; FEB9FC  [  0][108]
	.ascii "          "                             ; FEBA06  [  0][109]
	.ascii "          "                             ; FEBA10  [  0][110]
	.ascii "          "                             ; FEBA1A  [  0][111]
	.ascii "          "                             ; FEBA24  [  0][112]
	.ascii "          "                             ; FEBA2E  [  0][113]
	.ascii "          "                             ; FEBA38  [  0][114]
	.ascii "          "                             ; FEBA42  [  0][115]
	.ascii "          "                             ; FEBA4C  [  0][116]
	.ascii "          "                             ; FEBA56  [  0][117]
	.ascii "          "                             ; FEBA60  [  0][118]
	.ascii "          "                             ; FEBA6A  [  0][119]
	.ascii "          "                             ; FEBA74  [  0][120]
	.ascii "          "                             ; FEBA7E  [  0][121]
	.ascii "          "                             ; FEBA88  [  0][122]
	.ascii "          "                             ; FEBA92  [  0][123]
	.ascii "          "                             ; FEBA9C  [  0][124]
	.ascii "          "                             ; FEBAA6  [  0][125]
	.ascii "          "                             ; FEBAB0  [  0][126]
	.ascii "          "                             ; FEBABA  [  0][127]
	.ascii "          "                             ; FEBAC4  [  0][128]

; DrumKitNames_Block1 -- name block 1: 129 ten-character names, 119 non-blank.
; Read by: DrumKitNameBlockPtrs[123 programs (every one not listed under another block)] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block1:
; ---- name block 1, 0xFEBACE: 10 of 129 names are blank ----
	.ascii "          "                             ; FEBACE  [  1][  0]
	.ascii "          "                             ; FEBAD8  [  1][  1]
	.ascii "          "                             ; FEBAE2  [  1][  2]
	.ascii "Zap 1     "                             ; FEBAEC  [  1][  3]
	.ascii "E.Unizon  "                             ; FEBAF6  [  1][  4]
	.ascii "E.Shot1   "                             ; FEBB00  [  1][  5]
	.ascii "E.Shot2   "                             ; FEBB0A  [  1][  6]
	.ascii "Zap 2     "                             ; FEBB14  [  1][  7]
	.ascii "Voice Uh  "                             ; FEBB1E  [  1][  8]
	.ascii "Voice Ah  "                             ; FEBB28  [  1][  9]
	.ascii "Voice Yeh "                             ; FEBB32  [  1][ 10]
	.ascii "AmbientHam"                             ; FEBB3C  [  1][ 11]
	.ascii "Brush Long"                             ; FEBB46  [  1][ 12]
	.ascii "Brush Tap "                             ; FEBB50  [  1][ 13]
	.ascii "Hi-Hat Acc"                             ; FEBB5A  [  1][ 14]
	.ascii "Hi-Hat Opn"                             ; FEBB64  [  1][ 15]
	.ascii "Hi-HatCLOf"                             ; FEBB6E  [  1][ 16]
	.ascii "Rev Cym   "                             ; FEBB78  [  1][ 17]
	.ascii "Extra Tom3"                             ; FEBB82  [  1][ 18]
	.ascii "Extra Tom2"                             ; FEBB8C  [  1][ 19]
	.ascii "Extra Tom1"                             ; FEBB96  [  1][ 20]
	.ascii "Rev Snare "                             ; FEBBA0  [  1][ 21]
	.ascii "Snare Dr 2"                             ; FEBBAA  [  1][ 22]
	.ascii "Snare Dr 3"                             ; FEBBB4  [  1][ 23]
	.ascii "          "                             ; FEBBBE  [  1][ 24]
	.ascii "          "                             ; FEBBC8  [  1][ 25]
	.ascii "          "                             ; FEBBD2  [  1][ 26]
	.ascii "          "                             ; FEBBDC  [  1][ 27]
	.ascii "Slap      "                             ; FEBBE6  [  1][ 28]
	.ascii "Scratch 1 "                             ; FEBBF0  [  1][ 29]
	.ascii "Scratch 2 "                             ; FEBBFA  [  1][ 30]
	.ascii "Rim Shot  "                             ; FEBC04  [  1][ 31]
	.ascii "Square Clk"                             ; FEBC0E  [  1][ 32]
	.ascii "MetroClick"                             ; FEBC18  [  1][ 33]
	.ascii "Metro Bell"                             ; FEBC22  [  1][ 34]
	.ascii "Bass Dr 2 "                             ; FEBC2C  [  1][ 35]
	.ascii "Bass Dr 1 "                             ; FEBC36  [  1][ 36]
	.ascii "Rim Shot  "                             ; FEBC40  [  1][ 37]
	.ascii "Snare Dr 1"                             ; FEBC4A  [  1][ 38]
	.ascii "Hand Claps"                             ; FEBC54  [  1][ 39]
	.ascii "High Snare"                             ; FEBC5E  [  1][ 40]
	.ascii "FloorTom L"                             ; FEBC68  [  1][ 41]
	.ascii "Hi-HatCLOn"                             ; FEBC72  [  1][ 42]
	.ascii "FloorTom H"                             ; FEBC7C  [  1][ 43]
	.ascii "Hi-Hat Ped"                             ; FEBC86  [  1][ 44]
	.ascii "Tom 3     "                             ; FEBC90  [  1][ 45]
	.ascii "Hi-Hat O  "                             ; FEBC9A  [  1][ 46]
	.ascii "Tom 2     "                             ; FEBCA4  [  1][ 47]
	.ascii "Tom 1     "                             ; FEBCAE  [  1][ 48]
	.ascii "Crash Cym1"                             ; FEBCB8  [  1][ 49]
	.ascii "Tom High  "                             ; FEBCC2  [  1][ 50]
	.ascii "Ride Cym 1"                             ; FEBCCC  [  1][ 51]
	.ascii "ChineseCym"                             ; FEBCD6  [  1][ 52]
	.ascii "Ride Bell "                             ; FEBCE0  [  1][ 53]
	.ascii "TamburnAcc"                             ; FEBCEA  [  1][ 54]
	.ascii "Splash Cym"                             ; FEBCF4  [  1][ 55]
	.ascii "Cowbell 2 "                             ; FEBCFE  [  1][ 56]
	.ascii "Crash Cym2"                             ; FEBD08  [  1][ 57]
	.ascii "Vibraslap "                             ; FEBD12  [  1][ 58]
	.ascii "Ride Cym 2"                             ; FEBD1C  [  1][ 59]
	.ascii "Bongo High"                             ; FEBD26  [  1][ 60]
	.ascii "Bongo Low "                             ; FEBD30  [  1][ 61]
	.ascii "CongaMutCr"                             ; FEBD3A  [  1][ 62]
	.ascii "Conga High"                             ; FEBD44  [  1][ 63]
	.ascii "Conga Low "                             ; FEBD4E  [  1][ 64]
	.ascii "TimbEdgeHi"                             ; FEBD58  [  1][ 65]
	.ascii "TimbOpnLow"                             ; FEBD62  [  1][ 66]
	.ascii "Agogo High"                             ; FEBD6C  [  1][ 67]
	.ascii "Agogo Low "                             ; FEBD76  [  1][ 68]
	.ascii "Cabasa    "                             ; FEBD80  [  1][ 69]
	.ascii "Maracas On"                             ; FEBD8A  [  1][ 70]
	.ascii "SambaWhSrt"                             ; FEBD94  [  1][ 71]
	.ascii "SambaWhLng"                             ; FEBD9E  [  1][ 72]
	.ascii "GuiroShort"                             ; FEBDA8  [  1][ 73]
	.ascii "Guiro Long"                             ; FEBDB2  [  1][ 74]
	.ascii "Claves    "                             ; FEBDBC  [  1][ 75]
	.ascii "Wood Blk H"                             ; FEBDC6  [  1][ 76]
	.ascii "Wood Blk L"                             ; FEBDD0  [  1][ 77]
	.ascii "Cuica High"                             ; FEBDDA  [  1][ 78]
	.ascii "Cuica Low "                             ; FEBDE4  [  1][ 79]
	.ascii "Triangle M"                             ; FEBDEE  [  1][ 80]
	.ascii "Triangle O"                             ; FEBDF8  [  1][ 81]
	.ascii "Shaker On "                             ; FEBE02  [  1][ 82]
	.ascii "SleighBell"                             ; FEBE0C  [  1][ 83]
	.ascii "Wind Chime"                             ; FEBE16  [  1][ 84]
	.ascii "Castanets "                             ; FEBE20  [  1][ 85]
	.ascii "Surdo Mute"                             ; FEBE2A  [  1][ 86]
	.ascii "Surdo Open"                             ; FEBE34  [  1][ 87]
	.ascii "Orch.BasDr"                             ; FEBE3E  [  1][ 88]
	.ascii "Orch.Snare"                             ; FEBE48  [  1][ 89]
	.ascii "Orch.Cym  "                             ; FEBE52  [  1][ 90]
	.ascii "NutshlTree"                             ; FEBE5C  [  1][ 91]
	.ascii "Rain Stick"                             ; FEBE66  [  1][ 92]
	.ascii "Shekele On"                             ; FEBE70  [  1][ 93]
	.ascii "BataDrSlap"                             ; FEBE7A  [  1][ 94]
	.ascii "BataDrOpen"                             ; FEBE84  [  1][ 95]
	.ascii "CaxixiOnBt"                             ; FEBE8E  [  1][ 96]
	.ascii "CaxixiOfBt"                             ; FEBE98  [  1][ 97]
	.ascii "DarbukaSlp"                             ; FEBEA2  [  1][ 98]
	.ascii "DarbukaOpn"                             ; FEBEAC  [  1][ 99]
	.ascii "Finger Cym"                             ; FEBEB6  [  1][100]
	.ascii "SambaDrOn "                             ; FEBEC0  [  1][101]
	.ascii "SambaDrOff"                             ; FEBECA  [  1][102]
	.ascii "SambaWhiHi"                             ; FEBED4  [  1][103]
	.ascii "SambaWhiLo"                             ; FEBEDE  [  1][104]
	.ascii "SmalCongaH"                             ; FEBEE8  [  1][105]
	.ascii "SmalCongaL"                             ; FEBEF2  [  1][106]
	.ascii "          "                             ; FEBEFC  [  1][107]
	.ascii "          "                             ; FEBF06  [  1][108]
	.ascii "Cowbell 1 "                             ; FEBF10  [  1][109]
	.ascii "Cowbell 3 "                             ; FEBF1A  [  1][110]
	.ascii "Cowbell 4 "                             ; FEBF24  [  1][111]
	.ascii "TimbOpenHi"                             ; FEBF2E  [  1][112]
	.ascii "Timb Paila"                             ; FEBF38  [  1][113]
	.ascii "Tamburn Bt"                             ; FEBF42  [  1][114]
	.ascii "Shaker Off"                             ; FEBF4C  [  1][115]
	.ascii "MaracasOff"                             ; FEBF56  [  1][116]
	.ascii "SurdoLHand"                             ; FEBF60  [  1][117]
	.ascii "ShekeleOff"                             ; FEBF6A  [  1][118]
	.ascii "Hand Claps"                             ; FEBF74  [  1][119]
	.ascii "CongaMutOn"                             ; FEBF7E  [  1][120]
	.ascii "CongaMutOf"                             ; FEBF88  [  1][121]
	.ascii "CongaOpnCr"                             ; FEBF92  [  1][122]
	.ascii "BongoMute3"                             ; FEBF9C  [  1][123]
	.ascii "BongoMute2"                             ; FEBFA6  [  1][124]
	.ascii "BongoMute1"                             ; FEBFB0  [  1][125]
	.ascii "OrchTmburn"                             ; FEBFBA  [  1][126]
	.ascii "WoodBlk H2"                             ; FEBFC4  [  1][127]
	.ascii "          "                             ; FEBFCE  [  1][128]

; DrumKitNames_Block2 -- name block 2: 129 ten-character names, 119 non-blank.
; Read by: DrumKitNameBlockPtrs[24, 26, 29] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block2:
; ---- name block 2, 0xFEBFD8: 10 of 129 names are blank ----
	.ascii "          "                             ; FEBFD8  [  2][  0]
	.ascii "          "                             ; FEBFE2  [  2][  1]
	.ascii "          "                             ; FEBFEC  [  2][  2]
	.ascii "Zap 1     "                             ; FEBFF6  [  2][  3]
	.ascii "E.Unizon  "                             ; FEC000  [  2][  4]
	.ascii "E.Shot1   "                             ; FEC00A  [  2][  5]
	.ascii "E.Shot2   "                             ; FEC014  [  2][  6]
	.ascii "Zap 2     "                             ; FEC01E  [  2][  7]
	.ascii "Voice Uh  "                             ; FEC028  [  2][  8]
	.ascii "Voice Ah  "                             ; FEC032  [  2][  9]
	.ascii "Voice Yeh "                             ; FEC03C  [  2][ 10]
	.ascii "AmbientHam"                             ; FEC046  [  2][ 11]
	.ascii "Brush Long"                             ; FEC050  [  2][ 12]
	.ascii "Brush Tap "                             ; FEC05A  [  2][ 13]
	.ascii "Hi-Hat Acc"                             ; FEC064  [  2][ 14]
	.ascii "Hi-Hat Opn"                             ; FEC06E  [  2][ 15]
	.ascii "Hi-HatCLOf"                             ; FEC078  [  2][ 16]
	.ascii "Rev Cym   "                             ; FEC082  [  2][ 17]
	.ascii "Extra Tom3"                             ; FEC08C  [  2][ 18]
	.ascii "Extra Tom2"                             ; FEC096  [  2][ 19]
	.ascii "Extra Tom1"                             ; FEC0A0  [  2][ 20]
	.ascii "Rev Snare "                             ; FEC0AA  [  2][ 21]
	.ascii "Snare Dr 2"                             ; FEC0B4  [  2][ 22]
	.ascii "Snare Dr 3"                             ; FEC0BE  [  2][ 23]
	.ascii "          "                             ; FEC0C8  [  2][ 24]
	.ascii "          "                             ; FEC0D2  [  2][ 25]
	.ascii "          "                             ; FEC0DC  [  2][ 26]
	.ascii "          "                             ; FEC0E6  [  2][ 27]
	.ascii "Slap      "                             ; FEC0F0  [  2][ 28]
	.ascii "Scratch H "                             ; FEC0FA  [  2][ 29]
	.ascii "Scratch L "                             ; FEC104  [  2][ 30]
	.ascii "Rim Shot  "                             ; FEC10E  [  2][ 31]
	.ascii "Square Clk"                             ; FEC118  [  2][ 32]
	.ascii "MetroClick"                             ; FEC122  [  2][ 33]
	.ascii "Metro Bell"                             ; FEC12C  [  2][ 34]
	.ascii "Bass Dr 2 "                             ; FEC136  [  2][ 35]
	.ascii "Bass Dr 1 "                             ; FEC140  [  2][ 36]
	.ascii "Rim Shot  "                             ; FEC14A  [  2][ 37]
	.ascii "Snare Dr 1"                             ; FEC154  [  2][ 38]
	.ascii "Rev Cym   "                             ; FEC15E  [  2][ 39]
	.ascii "High Snare"                             ; FEC168  [  2][ 40]
	.ascii "FloorTom L"                             ; FEC172  [  2][ 41]
	.ascii "Hi-HatCLOn"                             ; FEC17C  [  2][ 42]
	.ascii "FloorTom H"                             ; FEC186  [  2][ 43]
	.ascii "Hi-Hat Ped"                             ; FEC190  [  2][ 44]
	.ascii "Tom 3     "                             ; FEC19A  [  2][ 45]
	.ascii "Hi-Hat O  "                             ; FEC1A4  [  2][ 46]
	.ascii "Tom 2     "                             ; FEC1AE  [  2][ 47]
	.ascii "Tom 1     "                             ; FEC1B8  [  2][ 48]
	.ascii "Crash Cym1"                             ; FEC1C2  [  2][ 49]
	.ascii "Tom High  "                             ; FEC1CC  [  2][ 50]
	.ascii "Ride Cym 1"                             ; FEC1D6  [  2][ 51]
	.ascii "ChineseCym"                             ; FEC1E0  [  2][ 52]
	.ascii "Ride Bell "                             ; FEC1EA  [  2][ 53]
	.ascii "TamburnAcc"                             ; FEC1F4  [  2][ 54]
	.ascii "Splash Cym"                             ; FEC1FE  [  2][ 55]
	.ascii "Cowbell 2 "                             ; FEC208  [  2][ 56]
	.ascii "Crash Cym2"                             ; FEC212  [  2][ 57]
	.ascii "Vibraslap "                             ; FEC21C  [  2][ 58]
	.ascii "Ride Cym 2"                             ; FEC226  [  2][ 59]
	.ascii "Bongo High"                             ; FEC230  [  2][ 60]
	.ascii "Bongo Low "                             ; FEC23A  [  2][ 61]
	.ascii "CongaMutCr"                             ; FEC244  [  2][ 62]
	.ascii "Conga High"                             ; FEC24E  [  2][ 63]
	.ascii "Conga Low "                             ; FEC258  [  2][ 64]
	.ascii "TimbEdgeHi"                             ; FEC262  [  2][ 65]
	.ascii "TimbOpnLow"                             ; FEC26C  [  2][ 66]
	.ascii "Agogo High"                             ; FEC276  [  2][ 67]
	.ascii "Agogo Low "                             ; FEC280  [  2][ 68]
	.ascii "Cabasa    "                             ; FEC28A  [  2][ 69]
	.ascii "Maracas On"                             ; FEC294  [  2][ 70]
	.ascii "SambaWhSrt"                             ; FEC29E  [  2][ 71]
	.ascii "SambaWhLng"                             ; FEC2A8  [  2][ 72]
	.ascii "GuiroShort"                             ; FEC2B2  [  2][ 73]
	.ascii "Guiro Long"                             ; FEC2BC  [  2][ 74]
	.ascii "Claves    "                             ; FEC2C6  [  2][ 75]
	.ascii "Wood Blk H"                             ; FEC2D0  [  2][ 76]
	.ascii "Wood Blk L"                             ; FEC2DA  [  2][ 77]
	.ascii "Cuica High"                             ; FEC2E4  [  2][ 78]
	.ascii "Cuica Low "                             ; FEC2EE  [  2][ 79]
	.ascii "Triangle M"                             ; FEC2F8  [  2][ 80]
	.ascii "Triangle O"                             ; FEC302  [  2][ 81]
	.ascii "Shaker On "                             ; FEC30C  [  2][ 82]
	.ascii "SleighBell"                             ; FEC316  [  2][ 83]
	.ascii "Wind Chime"                             ; FEC320  [  2][ 84]
	.ascii "Castanets "                             ; FEC32A  [  2][ 85]
	.ascii "Surdo Mute"                             ; FEC334  [  2][ 86]
	.ascii "Surdo Open"                             ; FEC33E  [  2][ 87]
	.ascii "Orch.BasDr"                             ; FEC348  [  2][ 88]
	.ascii "Orch.Snare"                             ; FEC352  [  2][ 89]
	.ascii "Orch.Cym  "                             ; FEC35C  [  2][ 90]
	.ascii "NutshlTree"                             ; FEC366  [  2][ 91]
	.ascii "Rain Stick"                             ; FEC370  [  2][ 92]
	.ascii "Shekele On"                             ; FEC37A  [  2][ 93]
	.ascii "BataDrSlap"                             ; FEC384  [  2][ 94]
	.ascii "BataDrOpen"                             ; FEC38E  [  2][ 95]
	.ascii "CaxixiOnBt"                             ; FEC398  [  2][ 96]
	.ascii "CaxixiOfBt"                             ; FEC3A2  [  2][ 97]
	.ascii "DarbukaSlp"                             ; FEC3AC  [  2][ 98]
	.ascii "DarbukaOpn"                             ; FEC3B6  [  2][ 99]
	.ascii "Finger Cym"                             ; FEC3C0  [  2][100]
	.ascii "TamborinOn"                             ; FEC3CA  [  2][101]
	.ascii "TamborinOf"                             ; FEC3D4  [  2][102]
	.ascii "SambaWhiHi"                             ; FEC3DE  [  2][103]
	.ascii "SambaWhiLo"                             ; FEC3E8  [  2][104]
	.ascii "SmalCongaH"                             ; FEC3F2  [  2][105]
	.ascii "SmalCongaL"                             ; FEC3FC  [  2][106]
	.ascii "          "                             ; FEC406  [  2][107]
	.ascii "          "                             ; FEC410  [  2][108]
	.ascii "Cowbell 1 "                             ; FEC41A  [  2][109]
	.ascii "Cowbell 3 "                             ; FEC424  [  2][110]
	.ascii "Cowbell 4 "                             ; FEC42E  [  2][111]
	.ascii "TimbOpenHi"                             ; FEC438  [  2][112]
	.ascii "Timb Paila"                             ; FEC442  [  2][113]
	.ascii "Tamburn Bt"                             ; FEC44C  [  2][114]
	.ascii "Shaker Off"                             ; FEC456  [  2][115]
	.ascii "MaracasOff"                             ; FEC460  [  2][116]
	.ascii "SurdoLHand"                             ; FEC46A  [  2][117]
	.ascii "ShekeleOff"                             ; FEC474  [  2][118]
	.ascii "Hand Claps"                             ; FEC47E  [  2][119]
	.ascii "CongaMutOn"                             ; FEC488  [  2][120]
	.ascii "CongaMutOf"                             ; FEC492  [  2][121]
	.ascii "CongaOpnCr"                             ; FEC49C  [  2][122]
	.ascii "BongoMute3"                             ; FEC4A6  [  2][123]
	.ascii "BongoMute2"                             ; FEC4B0  [  2][124]
	.ascii "BongoMute1"                             ; FEC4BA  [  2][125]
	.ascii "OrchTmburn"                             ; FEC4C4  [  2][126]
	.ascii "WoodBlk H2"                             ; FEC4CE  [  2][127]
	.ascii "          "                             ; FEC4D8  [  2][128]

; DrumKitNames_Block3 -- name block 3: 129 ten-character names, 119 non-blank.
; Read by: DrumKitNameBlockPtrs[40] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block3:
; ---- name block 3, 0xFEC4E2: 10 of 129 names are blank ----
	.ascii "          "                             ; FEC4E2  [  3][  0]
	.ascii "          "                             ; FEC4EC  [  3][  1]
	.ascii "          "                             ; FEC4F6  [  3][  2]
	.ascii "Zap 1     "                             ; FEC500  [  3][  3]
	.ascii "E.Unizon  "                             ; FEC50A  [  3][  4]
	.ascii "E.Shot1   "                             ; FEC514  [  3][  5]
	.ascii "E.Shot2   "                             ; FEC51E  [  3][  6]
	.ascii "Zap 2     "                             ; FEC528  [  3][  7]
	.ascii "Voice Uh  "                             ; FEC532  [  3][  8]
	.ascii "Voice Ah  "                             ; FEC53C  [  3][  9]
	.ascii "Voice Yeh "                             ; FEC546  [  3][ 10]
	.ascii "AmbientHam"                             ; FEC550  [  3][ 11]
	.ascii "Brush Long"                             ; FEC55A  [  3][ 12]
	.ascii "Brush Tap "                             ; FEC564  [  3][ 13]
	.ascii "Hi-Hat Acc"                             ; FEC56E  [  3][ 14]
	.ascii "Hi-Hat Opn"                             ; FEC578  [  3][ 15]
	.ascii "Hi-HatCLOf"                             ; FEC582  [  3][ 16]
	.ascii "Rev Cym   "                             ; FEC58C  [  3][ 17]
	.ascii "Extra Tom3"                             ; FEC596  [  3][ 18]
	.ascii "Extra Tom2"                             ; FEC5A0  [  3][ 19]
	.ascii "Extra Tom1"                             ; FEC5AA  [  3][ 20]
	.ascii "Rev Snare "                             ; FEC5B4  [  3][ 21]
	.ascii "Snare Dr 2"                             ; FEC5BE  [  3][ 22]
	.ascii "Snare Dr 3"                             ; FEC5C8  [  3][ 23]
	.ascii "          "                             ; FEC5D2  [  3][ 24]
	.ascii "          "                             ; FEC5DC  [  3][ 25]
	.ascii "          "                             ; FEC5E6  [  3][ 26]
	.ascii "          "                             ; FEC5F0  [  3][ 27]
	.ascii "Slap      "                             ; FEC5FA  [  3][ 28]
	.ascii "Scratch H "                             ; FEC604  [  3][ 29]
	.ascii "Scratch L "                             ; FEC60E  [  3][ 30]
	.ascii "Rim Shot  "                             ; FEC618  [  3][ 31]
	.ascii "Square Clk"                             ; FEC622  [  3][ 32]
	.ascii "MetroClick"                             ; FEC62C  [  3][ 33]
	.ascii "Metro Bell"                             ; FEC636  [  3][ 34]
	.ascii "Bass Dr 2 "                             ; FEC640  [  3][ 35]
	.ascii "Bass Dr 1 "                             ; FEC64A  [  3][ 36]
	.ascii "Rim Shot  "                             ; FEC654  [  3][ 37]
	.ascii "Brush Tap "                             ; FEC65E  [  3][ 38]
	.ascii "Brush Hit "                             ; FEC668  [  3][ 39]
	.ascii "Brush Long"                             ; FEC672  [  3][ 40]
	.ascii "FloorTom L"                             ; FEC67C  [  3][ 41]
	.ascii "Hi-HatCLOn"                             ; FEC686  [  3][ 42]
	.ascii "FloorTom H"                             ; FEC690  [  3][ 43]
	.ascii "Hi-Hat Ped"                             ; FEC69A  [  3][ 44]
	.ascii "Tom 3     "                             ; FEC6A4  [  3][ 45]
	.ascii "Hi-Hat O  "                             ; FEC6AE  [  3][ 46]
	.ascii "Tom 2     "                             ; FEC6B8  [  3][ 47]
	.ascii "Tom 1     "                             ; FEC6C2  [  3][ 48]
	.ascii "Crash Cym1"                             ; FEC6CC  [  3][ 49]
	.ascii "Tom High  "                             ; FEC6D6  [  3][ 50]
	.ascii "Ride Cym 1"                             ; FEC6E0  [  3][ 51]
	.ascii "ChineseCym"                             ; FEC6EA  [  3][ 52]
	.ascii "Ride Bell "                             ; FEC6F4  [  3][ 53]
	.ascii "TamburnAcc"                             ; FEC6FE  [  3][ 54]
	.ascii "Splash Cym"                             ; FEC708  [  3][ 55]
	.ascii "Cowbell 2 "                             ; FEC712  [  3][ 56]
	.ascii "Crash Cym2"                             ; FEC71C  [  3][ 57]
	.ascii "Vibraslap "                             ; FEC726  [  3][ 58]
	.ascii "Ride Cym 2"                             ; FEC730  [  3][ 59]
	.ascii "Bongo High"                             ; FEC73A  [  3][ 60]
	.ascii "Bongo Low "                             ; FEC744  [  3][ 61]
	.ascii "CongaMutCr"                             ; FEC74E  [  3][ 62]
	.ascii "Conga High"                             ; FEC758  [  3][ 63]
	.ascii "Conga Low "                             ; FEC762  [  3][ 64]
	.ascii "TimbEdgeHi"                             ; FEC76C  [  3][ 65]
	.ascii "TimbOpnLow"                             ; FEC776  [  3][ 66]
	.ascii "Agogo High"                             ; FEC780  [  3][ 67]
	.ascii "Agogo Low "                             ; FEC78A  [  3][ 68]
	.ascii "Cabasa    "                             ; FEC794  [  3][ 69]
	.ascii "Maracas On"                             ; FEC79E  [  3][ 70]
	.ascii "SambaWhSrt"                             ; FEC7A8  [  3][ 71]
	.ascii "SambaWhLng"                             ; FEC7B2  [  3][ 72]
	.ascii "GuiroShort"                             ; FEC7BC  [  3][ 73]
	.ascii "Guiro Long"                             ; FEC7C6  [  3][ 74]
	.ascii "Claves    "                             ; FEC7D0  [  3][ 75]
	.ascii "Wood Blk H"                             ; FEC7DA  [  3][ 76]
	.ascii "Wood Blk L"                             ; FEC7E4  [  3][ 77]
	.ascii "Cuica High"                             ; FEC7EE  [  3][ 78]
	.ascii "Cuica Low "                             ; FEC7F8  [  3][ 79]
	.ascii "Triangle M"                             ; FEC802  [  3][ 80]
	.ascii "Triangle O"                             ; FEC80C  [  3][ 81]
	.ascii "Shaker On "                             ; FEC816  [  3][ 82]
	.ascii "SleighBell"                             ; FEC820  [  3][ 83]
	.ascii "Wind Chime"                             ; FEC82A  [  3][ 84]
	.ascii "Castanets "                             ; FEC834  [  3][ 85]
	.ascii "Surdo Mute"                             ; FEC83E  [  3][ 86]
	.ascii "Surdo Open"                             ; FEC848  [  3][ 87]
	.ascii "Orch.BasDr"                             ; FEC852  [  3][ 88]
	.ascii "Orch.Snare"                             ; FEC85C  [  3][ 89]
	.ascii "Orch.Cym  "                             ; FEC866  [  3][ 90]
	.ascii "NutshlTree"                             ; FEC870  [  3][ 91]
	.ascii "Rain Stick"                             ; FEC87A  [  3][ 92]
	.ascii "Shekele On"                             ; FEC884  [  3][ 93]
	.ascii "BataDrSlap"                             ; FEC88E  [  3][ 94]
	.ascii "BataDrOpen"                             ; FEC898  [  3][ 95]
	.ascii "CaxixiOnBt"                             ; FEC8A2  [  3][ 96]
	.ascii "CaxixiOfBt"                             ; FEC8AC  [  3][ 97]
	.ascii "DarbukaSlp"                             ; FEC8B6  [  3][ 98]
	.ascii "DarbukaOpn"                             ; FEC8C0  [  3][ 99]
	.ascii "Finger Cym"                             ; FEC8CA  [  3][100]
	.ascii "TamborinOn"                             ; FEC8D4  [  3][101]
	.ascii "TamborinOf"                             ; FEC8DE  [  3][102]
	.ascii "SambaWhiHi"                             ; FEC8E8  [  3][103]
	.ascii "SambaWhiLo"                             ; FEC8F2  [  3][104]
	.ascii "SmalCongaH"                             ; FEC8FC  [  3][105]
	.ascii "SmalCongaL"                             ; FEC906  [  3][106]
	.ascii "          "                             ; FEC910  [  3][107]
	.ascii "          "                             ; FEC91A  [  3][108]
	.ascii "Cowbell 1 "                             ; FEC924  [  3][109]
	.ascii "Cowbell 3 "                             ; FEC92E  [  3][110]
	.ascii "Cowbell 4 "                             ; FEC938  [  3][111]
	.ascii "TimbOpenHi"                             ; FEC942  [  3][112]
	.ascii "Timb Paila"                             ; FEC94C  [  3][113]
	.ascii "Tamburn Bt"                             ; FEC956  [  3][114]
	.ascii "Shaker Off"                             ; FEC960  [  3][115]
	.ascii "MaracasOff"                             ; FEC96A  [  3][116]
	.ascii "SurdoLHand"                             ; FEC974  [  3][117]
	.ascii "ShekeleOff"                             ; FEC97E  [  3][118]
	.ascii "Hand Claps"                             ; FEC988  [  3][119]
	.ascii "CongaMutOn"                             ; FEC992  [  3][120]
	.ascii "CongaMutOf"                             ; FEC99C  [  3][121]
	.ascii "CongaOpnCr"                             ; FEC9A6  [  3][122]
	.ascii "BongoMute3"                             ; FEC9B0  [  3][123]
	.ascii "BongoMute2"                             ; FEC9BA  [  3][124]
	.ascii "BongoMute1"                             ; FEC9C4  [  3][125]
	.ascii "OrchTmburn"                             ; FEC9CE  [  3][126]
	.ascii "WoodBlk H2"                             ; FEC9D8  [  3][127]
	.ascii "          "                             ; FEC9E2  [  3][128]

; DrumKitNames_Block4 -- name block 4: 129 ten-character names, 88 non-blank.
; Read by: DrumKitNameBlockPtrs[112] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block4:
; ---- name block 4, 0xFEC9EC: 41 of 129 names are blank ----
	.ascii "          "                             ; FEC9EC  [  4][  0]
	.ascii "          "                             ; FEC9F6  [  4][  1]
	.ascii "          "                             ; FECA00  [  4][  2]
	.ascii "          "                             ; FECA0A  [  4][  3]
	.ascii "          "                             ; FECA14  [  4][  4]
	.ascii "          "                             ; FECA1E  [  4][  5]
	.ascii "          "                             ; FECA28  [  4][  6]
	.ascii "          "                             ; FECA32  [  4][  7]
	.ascii "          "                             ; FECA3C  [  4][  8]
	.ascii "          "                             ; FECA46  [  4][  9]
	.ascii "          "                             ; FECA50  [  4][ 10]
	.ascii "          "                             ; FECA5A  [  4][ 11]
	.ascii "Timpani C "                             ; FECA64  [  4][ 12]
	.ascii "Timpani C#"                             ; FECA6E  [  4][ 13]
	.ascii "Timpani D "                             ; FECA78  [  4][ 14]
	.ascii "          "                             ; FECA82  [  4][ 15]
	.ascii "          "                             ; FECA8C  [  4][ 16]
	.ascii "          "                             ; FECA96  [  4][ 17]
	.ascii "          "                             ; FECAA0  [  4][ 18]
	.ascii "          "                             ; FECAAA  [  4][ 19]
	.ascii "Brush Long"                             ; FECAB4  [  4][ 20]
	.ascii "BrushShort"                             ; FECABE  [  4][ 21]
	.ascii "Hi-Hat Ped"                             ; FECAC8  [  4][ 22]
	.ascii "Hi-Hat HO "                             ; FECAD2  [  4][ 23]
	.ascii "Hi-HatClOn"                             ; FECADC  [  4][ 24]
	.ascii "Hi-HatClOf"                             ; FECAE6  [  4][ 25]
	.ascii "Hi-Hat Opn"                             ; FECAF0  [  4][ 26]
	.ascii "FloorTom  "                             ; FECAFA  [  4][ 27]
	.ascii "Tom 3     "                             ; FECB04  [  4][ 28]
	.ascii "Tom 2     "                             ; FECB0E  [  4][ 29]
	.ascii "Tom 1     "                             ; FECB18  [  4][ 30]
	.ascii "Tom High  "                             ; FECB22  [  4][ 31]
	.ascii "Ride Bell "                             ; FECB2C  [  4][ 32]
	.ascii "Ride Cym2 "                             ; FECB36  [  4][ 33]
	.ascii "OrchSnare3"                             ; FECB40  [  4][ 34]
	.ascii "OrchBasDr2"                             ; FECB4A  [  4][ 35]
	.ascii "OrchBasDr1"                             ; FECB54  [  4][ 36]
	.ascii "Rim Shot  "                             ; FECB5E  [  4][ 37]
	.ascii "OrchSnare1"                             ; FECB68  [  4][ 38]
	.ascii "Castanets "                             ; FECB72  [  4][ 39]
	.ascii "OrchSnare2"                             ; FECB7C  [  4][ 40]
	.ascii "Orch. Cym1"                             ; FECB86  [  4][ 41]
	.ascii "Triangle O"                             ; FECB90  [  4][ 42]
	.ascii "Orch. Cym2"                             ; FECB9A  [  4][ 43]
	.ascii "OrchTmburn"                             ; FECBA4  [  4][ 44]
	.ascii "CymSftMlet"                             ; FECBAE  [  4][ 45]
	.ascii "Rattle    "                             ; FECBB8  [  4][ 46]
	.ascii "Ride Cym1 "                             ; FECBC2  [  4][ 47]
	.ascii "WoodBlk L "                             ; FECBCC  [  4][ 48]
	.ascii "WoodBlk H "                             ; FECBD6  [  4][ 49]
	.ascii "WoodBlk H2"                             ; FECBE0  [  4][ 50]
	.ascii "Timpani D#"                             ; FECBEA  [  4][ 51]
	.ascii "Timpani E "                             ; FECBF4  [  4][ 52]
	.ascii "Timpani F "                             ; FECBFE  [  4][ 53]
	.ascii "Timpani F#"                             ; FECC08  [  4][ 54]
	.ascii "Timpani G "                             ; FECC12  [  4][ 55]
	.ascii "Timpani G#"                             ; FECC1C  [  4][ 56]
	.ascii "Timpani A "                             ; FECC26  [  4][ 57]
	.ascii "Timpani A#"                             ; FECC30  [  4][ 58]
	.ascii "Timpani B "                             ; FECC3A  [  4][ 59]
	.ascii "Timpani c "                             ; FECC44  [  4][ 60]
	.ascii "Timpani c#"                             ; FECC4E  [  4][ 61]
	.ascii "Timpani d "                             ; FECC58  [  4][ 62]
	.ascii "Timpani d#"                             ; FECC62  [  4][ 63]
	.ascii "Timpani e "                             ; FECC6C  [  4][ 64]
	.ascii "Timpani f "                             ; FECC76  [  4][ 65]
	.ascii "Timpani f#"                             ; FECC80  [  4][ 66]
	.ascii "Timpani g "                             ; FECC8A  [  4][ 67]
	.ascii "Timpani g#"                             ; FECC94  [  4][ 68]
	.ascii "Timpani a "                             ; FECC9E  [  4][ 69]
	.ascii "Timpani a#"                             ; FECCA8  [  4][ 70]
	.ascii "Timpani b "                             ; FECCB2  [  4][ 71]
	.ascii "T.Bells C "                             ; FECCBC  [  4][ 72]
	.ascii "T.Bells C#"                             ; FECCC6  [  4][ 73]
	.ascii "T.Bells D "                             ; FECCD0  [  4][ 74]
	.ascii "T.Bells D#"                             ; FECCDA  [  4][ 75]
	.ascii "T.Bells E "                             ; FECCE4  [  4][ 76]
	.ascii "T.Bells F "                             ; FECCEE  [  4][ 77]
	.ascii "T.Bells F#"                             ; FECCF8  [  4][ 78]
	.ascii "T.Bells G "                             ; FECD02  [  4][ 79]
	.ascii "T.Bells G#"                             ; FECD0C  [  4][ 80]
	.ascii "T.Bells A "                             ; FECD16  [  4][ 81]
	.ascii "T.Bells A#"                             ; FECD20  [  4][ 82]
	.ascii "T.Bells B "                             ; FECD2A  [  4][ 83]
	.ascii "T.Bells c "                             ; FECD34  [  4][ 84]
	.ascii "T.Bells c#"                             ; FECD3E  [  4][ 85]
	.ascii "T.Bells d "                             ; FECD48  [  4][ 86]
	.ascii "T.Bells d#"                             ; FECD52  [  4][ 87]
	.ascii "T.Bells e "                             ; FECD5C  [  4][ 88]
	.ascii "T.Bells f "                             ; FECD66  [  4][ 89]
	.ascii "T.Bells f#"                             ; FECD70  [  4][ 90]
	.ascii "T.Bells g "                             ; FECD7A  [  4][ 91]
	.ascii "T.Bells g#"                             ; FECD84  [  4][ 92]
	.ascii "T.Bells a "                             ; FECD8E  [  4][ 93]
	.ascii "T.Bells a#"                             ; FECD98  [  4][ 94]
	.ascii "T.Bells b "                             ; FECDA2  [  4][ 95]
	.ascii "Tam-Tam   "                             ; FECDAC  [  4][ 96]
	.ascii "TamburnAcc"                             ; FECDB6  [  4][ 97]
	.ascii "Tamburn Bt"                             ; FECDC0  [  4][ 98]
	.ascii "SleighBell"                             ; FECDCA  [  4][ 99]
	.ascii "Cowbell   "                             ; FECDD4  [  4][100]
	.ascii "Triangle M"                             ; FECDDE  [  4][101]
	.ascii "Triangle O"                             ; FECDE8  [  4][102]
	.ascii "WindChime "                             ; FECDF2  [  4][103]
	.ascii "Vibraslap "                             ; FECDFC  [  4][104]
	.ascii "          "                             ; FECE06  [  4][105]
	.ascii "          "                             ; FECE10  [  4][106]
	.ascii "          "                             ; FECE1A  [  4][107]
	.ascii "          "                             ; FECE24  [  4][108]
	.ascii "          "                             ; FECE2E  [  4][109]
	.ascii "          "                             ; FECE38  [  4][110]
	.ascii "          "                             ; FECE42  [  4][111]
	.ascii "          "                             ; FECE4C  [  4][112]
	.ascii "          "                             ; FECE56  [  4][113]
	.ascii "          "                             ; FECE60  [  4][114]
	.ascii "          "                             ; FECE6A  [  4][115]
	.ascii "          "                             ; FECE74  [  4][116]
	.ascii "          "                             ; FECE7E  [  4][117]
	.ascii "          "                             ; FECE88  [  4][118]
	.ascii "          "                             ; FECE92  [  4][119]
	.ascii "          "                             ; FECE9C  [  4][120]
	.ascii "          "                             ; FECEA6  [  4][121]
	.ascii "          "                             ; FECEB0  [  4][122]
	.ascii "          "                             ; FECEBA  [  4][123]
	.ascii "          "                             ; FECEC4  [  4][124]
	.ascii "          "                             ; FECECE  [  4][125]
	.ascii "          "                             ; FECED8  [  4][126]
	.ascii "          "                             ; FECEE2  [  4][127]
	.ascii "          "                             ; FECEEC  [  4][128]

; DrumKitNames_Block5 -- name block 5: 129 ten-character names, 62 non-blank.
; Read by: DrumKitNameBlockPtrs[48] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block5:
; ---- name block 5, 0xFECEF6: 67 of 129 names are blank ----
	.ascii "          "                             ; FECEF6  [  5][  0]
	.ascii "          "                             ; FECF00  [  5][  1]
	.ascii "          "                             ; FECF0A  [  5][  2]
	.ascii "          "                             ; FECF14  [  5][  3]
	.ascii "          "                             ; FECF1E  [  5][  4]
	.ascii "          "                             ; FECF28  [  5][  5]
	.ascii "          "                             ; FECF32  [  5][  6]
	.ascii "          "                             ; FECF3C  [  5][  7]
	.ascii "          "                             ; FECF46  [  5][  8]
	.ascii "          "                             ; FECF50  [  5][  9]
	.ascii "          "                             ; FECF5A  [  5][ 10]
	.ascii "          "                             ; FECF64  [  5][ 11]
	.ascii "          "                             ; FECF6E  [  5][ 12]
	.ascii "          "                             ; FECF78  [  5][ 13]
	.ascii "          "                             ; FECF82  [  5][ 14]
	.ascii "          "                             ; FECF8C  [  5][ 15]
	.ascii "          "                             ; FECF96  [  5][ 16]
	.ascii "          "                             ; FECFA0  [  5][ 17]
	.ascii "          "                             ; FECFAA  [  5][ 18]
	.ascii "          "                             ; FECFB4  [  5][ 19]
	.ascii "          "                             ; FECFBE  [  5][ 20]
	.ascii "          "                             ; FECFC8  [  5][ 21]
	.ascii "          "                             ; FECFD2  [  5][ 22]
	.ascii "          "                             ; FECFDC  [  5][ 23]
	.ascii "          "                             ; FECFE6  [  5][ 24]
	.ascii "          "                             ; FECFF0  [  5][ 25]
	.ascii "          "                             ; FECFFA  [  5][ 26]
	.ascii "Hi-HatClOn"                             ; FED004  [  5][ 27]
	.ascii "Hi-Hat Ped"                             ; FED00E  [  5][ 28]
	.ascii "Hi-Hat Opn"                             ; FED018  [  5][ 29]
	.ascii "Ride Cym1 "                             ; FED022  [  5][ 30]
	.ascii "Rim Shot  "                             ; FED02C  [  5][ 31]
	.ascii "Square Clk"                             ; FED036  [  5][ 32]
	.ascii "MetroClick"                             ; FED040  [  5][ 33]
	.ascii "Metro Bell"                             ; FED04A  [  5][ 34]
	.ascii "OrchBasDr2"                             ; FED054  [  5][ 35]
	.ascii "OrchBasDr1"                             ; FED05E  [  5][ 36]
	.ascii "Rim Shot  "                             ; FED068  [  5][ 37]
	.ascii "OrchSnare "                             ; FED072  [  5][ 38]
	.ascii "Castanets "                             ; FED07C  [  5][ 39]
	.ascii "OrchSnare "                             ; FED086  [  5][ 40]
	.ascii "Timpani F "                             ; FED090  [  5][ 41]
	.ascii "Timpani F#"                             ; FED09A  [  5][ 42]
	.ascii "Timpani G "                             ; FED0A4  [  5][ 43]
	.ascii "Timpani G#"                             ; FED0AE  [  5][ 44]
	.ascii "Timpani A "                             ; FED0B8  [  5][ 45]
	.ascii "Timpani A#"                             ; FED0C2  [  5][ 46]
	.ascii "Timpani B "                             ; FED0CC  [  5][ 47]
	.ascii "Timpani c "                             ; FED0D6  [  5][ 48]
	.ascii "Timpani c#"                             ; FED0E0  [  5][ 49]
	.ascii "Timpani d "                             ; FED0EA  [  5][ 50]
	.ascii "Timpani d#"                             ; FED0F4  [  5][ 51]
	.ascii "Timpani e "                             ; FED0FE  [  5][ 52]
	.ascii "Timpani f "                             ; FED108  [  5][ 53]
	.ascii "OrchTmburn"                             ; FED112  [  5][ 54]
	.ascii "Splash Cym"                             ; FED11C  [  5][ 55]
	.ascii "Cowbell   "                             ; FED126  [  5][ 56]
	.ascii "Orch Cym1 "                             ; FED130  [  5][ 57]
	.ascii "Vibraslap "                             ; FED13A  [  5][ 58]
	.ascii "Orch Cym2 "                             ; FED144  [  5][ 59]
	.ascii "Bongo High"                             ; FED14E  [  5][ 60]
	.ascii "Bongo Low "                             ; FED158  [  5][ 61]
	.ascii "CongaMutCr"                             ; FED162  [  5][ 62]
	.ascii "Conga High"                             ; FED16C  [  5][ 63]
	.ascii "Conga Low "                             ; FED176  [  5][ 64]
	.ascii "TimbEdgeHi"                             ; FED180  [  5][ 65]
	.ascii "TimbOpnLow"                             ; FED18A  [  5][ 66]
	.ascii "Agogo High"                             ; FED194  [  5][ 67]
	.ascii "Agogo Low "                             ; FED19E  [  5][ 68]
	.ascii "Cabasa    "                             ; FED1A8  [  5][ 69]
	.ascii "Maracas   "                             ; FED1B2  [  5][ 70]
	.ascii "SambaWhSrt"                             ; FED1BC  [  5][ 71]
	.ascii "SambaWhLng"                             ; FED1C6  [  5][ 72]
	.ascii "GuiroShort"                             ; FED1D0  [  5][ 73]
	.ascii "Guiro Long"                             ; FED1DA  [  5][ 74]
	.ascii "Claves    "                             ; FED1E4  [  5][ 75]
	.ascii "Wood Blk H"                             ; FED1EE  [  5][ 76]
	.ascii "Wood Blk L"                             ; FED1F8  [  5][ 77]
	.ascii "Cuica High"                             ; FED202  [  5][ 78]
	.ascii "Cuica Low "                             ; FED20C  [  5][ 79]
	.ascii "Triangle M"                             ; FED216  [  5][ 80]
	.ascii "Triangle O"                             ; FED220  [  5][ 81]
	.ascii "Shaker    "                             ; FED22A  [  5][ 82]
	.ascii "SleighBell"                             ; FED234  [  5][ 83]
	.ascii "Wind Chime"                             ; FED23E  [  5][ 84]
	.ascii "Castanets "                             ; FED248  [  5][ 85]
	.ascii "Surdo Mute"                             ; FED252  [  5][ 86]
	.ascii "Surdo Open"                             ; FED25C  [  5][ 87]
	.ascii "Applause  "                             ; FED266  [  5][ 88]
	.ascii "          "                             ; FED270  [  5][ 89]
	.ascii "          "                             ; FED27A  [  5][ 90]
	.ascii "          "                             ; FED284  [  5][ 91]
	.ascii "          "                             ; FED28E  [  5][ 92]
	.ascii "          "                             ; FED298  [  5][ 93]
	.ascii "          "                             ; FED2A2  [  5][ 94]
	.ascii "          "                             ; FED2AC  [  5][ 95]
	.ascii "          "                             ; FED2B6  [  5][ 96]
	.ascii "          "                             ; FED2C0  [  5][ 97]
	.ascii "          "                             ; FED2CA  [  5][ 98]
	.ascii "          "                             ; FED2D4  [  5][ 99]
	.ascii "          "                             ; FED2DE  [  5][100]
	.ascii "          "                             ; FED2E8  [  5][101]
	.ascii "          "                             ; FED2F2  [  5][102]
	.ascii "          "                             ; FED2FC  [  5][103]
	.ascii "          "                             ; FED306  [  5][104]
	.ascii "          "                             ; FED310  [  5][105]
	.ascii "          "                             ; FED31A  [  5][106]
	.ascii "          "                             ; FED324  [  5][107]
	.ascii "          "                             ; FED32E  [  5][108]
	.ascii "          "                             ; FED338  [  5][109]
	.ascii "          "                             ; FED342  [  5][110]
	.ascii "          "                             ; FED34C  [  5][111]
	.ascii "          "                             ; FED356  [  5][112]
	.ascii "          "                             ; FED360  [  5][113]
	.ascii "          "                             ; FED36A  [  5][114]
	.ascii "          "                             ; FED374  [  5][115]
	.ascii "          "                             ; FED37E  [  5][116]
	.ascii "          "                             ; FED388  [  5][117]
	.ascii "          "                             ; FED392  [  5][118]
	.ascii "          "                             ; FED39C  [  5][119]
	.ascii "          "                             ; FED3A6  [  5][120]
	.ascii "          "                             ; FED3B0  [  5][121]
	.ascii "          "                             ; FED3BA  [  5][122]
	.ascii "          "                             ; FED3C4  [  5][123]
	.ascii "          "                             ; FED3CE  [  5][124]
	.ascii "          "                             ; FED3D8  [  5][125]
	.ascii "          "                             ; FED3E2  [  5][126]
	.ascii "          "                             ; FED3EC  [  5][127]
	.ascii "          "                             ; FED3F6  [  5][128]

; DrumKitNames_Block6 -- name block 6: 129 ten-character names, 57 non-blank.
; Read by: DrumKitNameBlockPtrs[120] -> RecordNameSource_Select's type-0x20
;          arm (0xFEB30B) -> DrumEdit_DrawRowName, SWI7 svc 0x17 with BC=10, HL=note.
DrumKitNames_Block6:
; ---- name block 6, 0xFED400: 72 of 129 names are blank ----
	.ascii "          "                             ; FED400  [  6][  0]
	.ascii "          "                             ; FED40A  [  6][  1]
	.ascii "          "                             ; FED414  [  6][  2]
	.ascii "          "                             ; FED41E  [  6][  3]
	.ascii "          "                             ; FED428  [  6][  4]
	.ascii "          "                             ; FED432  [  6][  5]
	.ascii "          "                             ; FED43C  [  6][  6]
	.ascii "          "                             ; FED446  [  6][  7]
	.ascii "          "                             ; FED450  [  6][  8]
	.ascii "          "                             ; FED45A  [  6][  9]
	.ascii "          "                             ; FED464  [  6][ 10]
	.ascii "          "                             ; FED46E  [  6][ 11]
	.ascii "          "                             ; FED478  [  6][ 12]
	.ascii "          "                             ; FED482  [  6][ 13]
	.ascii "          "                             ; FED48C  [  6][ 14]
	.ascii "          "                             ; FED496  [  6][ 15]
	.ascii "          "                             ; FED4A0  [  6][ 16]
	.ascii "          "                             ; FED4AA  [  6][ 17]
	.ascii "          "                             ; FED4B4  [  6][ 18]
	.ascii "          "                             ; FED4BE  [  6][ 19]
	.ascii "          "                             ; FED4C8  [  6][ 20]
	.ascii "          "                             ; FED4D2  [  6][ 21]
	.ascii "          "                             ; FED4DC  [  6][ 22]
	.ascii "          "                             ; FED4E6  [  6][ 23]
	.ascii "          "                             ; FED4F0  [  6][ 24]
	.ascii "          "                             ; FED4FA  [  6][ 25]
	.ascii "          "                             ; FED504  [  6][ 26]
	.ascii "          "                             ; FED50E  [  6][ 27]
	.ascii "          "                             ; FED518  [  6][ 28]
	.ascii "          "                             ; FED522  [  6][ 29]
	.ascii "          "                             ; FED52C  [  6][ 30]
	.ascii "          "                             ; FED536  [  6][ 31]
	.ascii "          "                             ; FED540  [  6][ 32]
	.ascii "          "                             ; FED54A  [  6][ 33]
	.ascii "          "                             ; FED554  [  6][ 34]
	.ascii "          "                             ; FED55E  [  6][ 35]
	.ascii "Fret Noise"                             ; FED568  [  6][ 36]
	.ascii "PickNoise1"                             ; FED572  [  6][ 37]
	.ascii "PickNoise2"                             ; FED57C  [  6][ 38]
	.ascii "PickNoise3"                             ; FED586  [  6][ 39]
	.ascii "PickNoise4"                             ; FED590  [  6][ 40]
	.ascii "SaxBreathN"                             ; FED59A  [  6][ 41]
	.ascii "FltBreathN"                             ; FED5A4  [  6][ 42]
	.ascii "Slap Shot "                             ; FED5AE  [  6][ 43]
	.ascii "MetroClick"                             ; FED5B8  [  6][ 44]
	.ascii "Metro Bell"                             ; FED5C2  [  6][ 45]
	.ascii "Scratch 1 "                             ; FED5CC  [  6][ 46]
	.ascii "Scratch 2 "                             ; FED5D6  [  6][ 47]
	.ascii "Zap 1     "                             ; FED5E0  [  6][ 48]
	.ascii "E.Unizon  "                             ; FED5EA  [  6][ 49]
	.ascii "E.Shot1   "                             ; FED5F4  [  6][ 50]
	.ascii "E.Shot2   "                             ; FED5FE  [  6][ 51]
	.ascii "Zap 2     "                             ; FED608  [  6][ 52]
	.ascii "Square Clk"                             ; FED612  [  6][ 53]
	.ascii "Slap      "                             ; FED61C  [  6][ 54]
	.ascii "AmbientHam"                             ; FED626  [  6][ 55]
	.ascii "Orch.Hit H"                             ; FED630  [  6][ 56]
	.ascii "Orch.Hit L"                             ; FED63A  [  6][ 57]
	.ascii "MetalHit H"                             ; FED644  [  6][ 58]
	.ascii "MetalHit L"                             ; FED64E  [  6][ 59]
	.ascii "Crikets   "                             ; FED658  [  6][ 60]
	.ascii "NutshlTree"                             ; FED662  [  6][ 61]
	.ascii "Rain Stick"                             ; FED66C  [  6][ 62]
	.ascii "Temple Blk"                             ; FED676  [  6][ 63]
	.ascii "Small Bell"                             ; FED680  [  6][ 64]
	.ascii "FingerCymH"                             ; FED68A  [  6][ 65]
	.ascii "FingerCymL"                             ; FED694  [  6][ 66]
	.ascii "SleighBell"                             ; FED69E  [  6][ 67]
	.ascii "WindChime "                             ; FED6A8  [  6][ 68]
	.ascii "Tam-Tam   "                             ; FED6B2  [  6][ 69]
	.ascii "Voice Uh  "                             ; FED6BC  [  6][ 70]
	.ascii "Voice Ah  "                             ; FED6C6  [  6][ 71]
	.ascii "Voice Yeh "                             ; FED6D0  [  6][ 72]
	.ascii "Heart Beat"                             ; FED6DA  [  6][ 73]
	.ascii "Hand Claps"                             ; FED6E4  [  6][ 74]
	.ascii "Applause 1"                             ; FED6EE  [  6][ 75]
	.ascii "Applause 2"                             ; FED6F8  [  6][ 76]
	.ascii "Gun Shot  "                             ; FED702  [  6][ 77]
	.ascii "Explosion "                             ; FED70C  [  6][ 78]
	.ascii "Helicopter"                             ; FED716  [  6][ 79]
	.ascii "Train     "                             ; FED720  [  6][ 80]
	.ascii "SteamWhisl"                             ; FED72A  [  6][ 81]
	.ascii "Telephone "                             ; FED734  [  6][ 82]
	.ascii "Wave 1    "                             ; FED73E  [  6][ 83]
	.ascii "Wave 2    "                             ; FED748  [  6][ 84]
	.ascii "Wind      "                             ; FED752  [  6][ 85]
	.ascii "Bird 1    "                             ; FED75C  [  6][ 86]
	.ascii "Bird 2    "                             ; FED766  [  6][ 87]
	.ascii "Bullfrog  "                             ; FED770  [  6][ 88]
	.ascii "Little Dog"                             ; FED77A  [  6][ 89]
	.ascii "          "                             ; FED784  [  6][ 90]
	.ascii "          "                             ; FED78E  [  6][ 91]
	.ascii "          "                             ; FED798  [  6][ 92]
	.ascii "          "                             ; FED7A2  [  6][ 93]
	.ascii "          "                             ; FED7AC  [  6][ 94]
	.ascii "          "                             ; FED7B6  [  6][ 95]
	.ascii "          "                             ; FED7C0  [  6][ 96]
	.ascii "          "                             ; FED7CA  [  6][ 97]
	.ascii "          "                             ; FED7D4  [  6][ 98]
	.ascii "          "                             ; FED7DE  [  6][ 99]
	.ascii "          "                             ; FED7E8  [  6][100]
	.ascii "          "                             ; FED7F2  [  6][101]
	.ascii "          "                             ; FED7FC  [  6][102]
	.ascii "          "                             ; FED806  [  6][103]
	.ascii "          "                             ; FED810  [  6][104]
	.ascii "          "                             ; FED81A  [  6][105]
	.ascii "          "                             ; FED824  [  6][106]
	.ascii "          "                             ; FED82E  [  6][107]
	.ascii "          "                             ; FED838  [  6][108]
	.ascii "          "                             ; FED842  [  6][109]
	.ascii "          "                             ; FED84C  [  6][110]
	.ascii "          "                             ; FED856  [  6][111]
	.ascii "          "                             ; FED860  [  6][112]
	.ascii "          "                             ; FED86A  [  6][113]
	.ascii "          "                             ; FED874  [  6][114]
	.ascii "          "                             ; FED87E  [  6][115]
	.ascii "          "                             ; FED888  [  6][116]
	.ascii "          "                             ; FED892  [  6][117]
	.ascii "          "                             ; FED89C  [  6][118]
	.ascii "          "                             ; FED8A6  [  6][119]
	.ascii "          "                             ; FED8B0  [  6][120]
	.ascii "          "                             ; FED8BA  [  6][121]
	.ascii "          "                             ; FED8C4  [  6][122]
	.ascii "          "                             ; FED8CE  [  6][123]
	.ascii "          "                             ; FED8D8  [  6][124]
	.ascii "Click  1  "                             ; FED8E2  [  6][125]
	.ascii "Click  2  "                             ; FED8EC  [  6][126]
	.ascii "Click  3  "                             ; FED8F6  [  6][127]
	.ascii "          "                             ; FED900  [  6][128]

; DrumKitNames_Block7 -- name block 7: 129 ten-character names, 107 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFED90A as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block7:
; ---- name block 7, 0xFED90A: 22 of 129 names are blank ----
	.ascii "          "                             ; FED90A  [  7][  0]
	.ascii "          "                             ; FED914  [  7][  1]
	.ascii "          "                             ; FED91E  [  7][  2]
	.ascii "          "                             ; FED928  [  7][  3]
	.ascii "          "                             ; FED932  [  7][  4]
	.ascii "          "                             ; FED93C  [  7][  5]
	.ascii "          "                             ; FED946  [  7][  6]
	.ascii "          "                             ; FED950  [  7][  7]
	.ascii "          "                             ; FED95A  [  7][  8]
	.ascii "          "                             ; FED964  [  7][  9]
	.ascii "          "                             ; FED96E  [  7][ 10]
	.ascii "          "                             ; FED978  [  7][ 11]
	.ascii "          "                             ; FED982  [  7][ 12]
	.ascii "          "                             ; FED98C  [  7][ 13]
	.ascii "          "                             ; FED996  [  7][ 14]
	.ascii "          "                             ; FED9A0  [  7][ 15]
	.ascii "          "                             ; FED9AA  [  7][ 16]
	.ascii "Voice Ah  "                             ; FED9B4  [  7][ 17]
	.ascii "Voice Yeh "                             ; FED9BE  [  7][ 18]
	.ascii "SleighBell"                             ; FED9C8  [  7][ 19]
	.ascii "Castanets "                             ; FED9D2  [  7][ 20]
	.ascii "Orch Tamb "                             ; FED9DC  [  7][ 21]
	.ascii "Rev Cym   "                             ; FED9E6  [  7][ 22]
	.ascii "Rev Snare "                             ; FED9F0  [  7][ 23]
	.ascii "Splash Cym"                             ; FED9FA  [  7][ 24]
	.ascii "Crash 2   "                             ; FEDA04  [  7][ 25]
	.ascii "Ride 2    "                             ; FEDA0E  [  7][ 26]
	.ascii "          "                             ; FEDA18  [  7][ 27]
	.ascii "Ride Bell "                             ; FEDA22  [  7][ 28]
	.ascii "Wind Chime"                             ; FEDA2C  [  7][ 29]
	.ascii "China Cym "                             ; FEDA36  [  7][ 30]
	.ascii "Spc Snare "                             ; FEDA40  [  7][ 31]
	.ascii "Snare Dr2 "                             ; FEDA4A  [  7][ 32]
	.ascii "Extra Tom3"                             ; FEDA54  [  7][ 33]
	.ascii "Extra Tom2"                             ; FEDA5E  [  7][ 34]
	.ascii "Extra Tom1"                             ; FEDA68  [  7][ 35]
	.ascii "Bass Dr 1 "                             ; FEDA72  [  7][ 36]
	.ascii "Bass Dr 2 "                             ; FEDA7C  [  7][ 37]
	.ascii "Snare Dr 1"                             ; FEDA86  [  7][ 38]
	.ascii "Snare Dr 3"                             ; FEDA90  [  7][ 39]
	.ascii "High Snare"                             ; FEDA9A  [  7][ 40]
	.ascii "Tom 3     "                             ; FEDAA4  [  7][ 41]
	.ascii "Extra Tom3"                             ; FEDAAE  [  7][ 42]
	.ascii "Tom 2     "                             ; FEDAB8  [  7][ 43]
	.ascii "Extra Tom2"                             ; FEDAC2  [  7][ 44]
	.ascii "Tom 1     "                             ; FEDACC  [  7][ 45]
	.ascii "Extra Tom1"                             ; FEDAD6  [  7][ 46]
	.ascii "Rim Shot  "                             ; FEDAE0  [  7][ 47]
	.ascii "Hi-Hat Cl "                             ; FEDAEA  [  7][ 48]
	.ascii "Hi-Hat Cl "                             ; FEDAF4  [  7][ 49]
	.ascii "Hi-Hat O  "                             ; FEDAFE  [  7][ 50]
	.ascii "Crash 1   "                             ; FEDB08  [  7][ 51]
	.ascii "Ride 1    "                             ; FEDB12  [  7][ 52]
	.ascii "Conga Low "                             ; FEDB1C  [  7][ 53]
	.ascii "SmalCongaL"                             ; FEDB26  [  7][ 54]
	.ascii "Conga High"                             ; FEDB30  [  7][ 55]
	.ascii "SmalCongaH"                             ; FEDB3A  [  7][ 56]
	.ascii "CongaCrash"                             ; FEDB44  [  7][ 57]
	.ascii "Cabasa    "                             ; FEDB4E  [  7][ 58]
	.ascii "Cowbell 1 "                             ; FEDB58  [  7][ 59]
	.ascii "Cowbell 2 "                             ; FEDB62  [  7][ 60]
	.ascii "Cowbell 3 "                             ; FEDB6C  [  7][ 61]
	.ascii "Cowbell 4 "                             ; FEDB76  [  7][ 62]
	.ascii "Cowbell 5 "                             ; FEDB80  [  7][ 63]
	.ascii "Cowbell 6 "                             ; FEDB8A  [  7][ 64]
	.ascii "SambaWhi L"                             ; FEDB94  [  7][ 65]
	.ascii "SambaWhi H"                             ; FEDB9E  [  7][ 66]
	.ascii "Claves    "                             ; FEDBA8  [  7][ 67]
	.ascii "Slap      "                             ; FEDBB2  [  7][ 68]
	.ascii "Hand Claps"                             ; FEDBBC  [  7][ 69]
	.ascii "          "                             ; FEDBC6  [  7][ 70]
	.ascii "          "                             ; FEDBD0  [  7][ 71]
	.ascii "SambaDrOn "                             ; FEDBDA  [  7][ 72]
	.ascii "SambaDrOff"                             ; FEDBE4  [  7][ 73]
	.ascii "TamburnAcc"                             ; FEDBEE  [  7][ 74]
	.ascii "Tamburn Bt"                             ; FEDBF8  [  7][ 75]
	.ascii "Guiro Long"                             ; FEDC02  [  7][ 76]
	.ascii "GuiroShort"                             ; FEDC0C  [  7][ 77]
	.ascii "Cuica Low "                             ; FEDC16  [  7][ 78]
	.ascii "Cuica High"                             ; FEDC20  [  7][ 79]
	.ascii "CongaMutOn"                             ; FEDC2A  [  7][ 80]
	.ascii "CongaMutOf"                             ; FEDC34  [  7][ 81]
	.ascii "CongaMutCr"                             ; FEDC3E  [  7][ 82]
	.ascii "Brush Long"                             ; FEDC48  [  7][ 83]
	.ascii "Brush Shrt"                             ; FEDC52  [  7][ 84]
	.ascii "Orch.BasDr"                             ; FEDC5C  [  7][ 85]
	.ascii "Orch.Snare"                             ; FEDC66  [  7][ 86]
	.ascii "Orch.Cymbl"                             ; FEDC70  [  7][ 87]
	.ascii "Bongo Low "                             ; FEDC7A  [  7][ 88]
	.ascii "Bongo High"                             ; FEDC84  [  7][ 89]
	.ascii "BongoMute3"                             ; FEDC8E  [  7][ 90]
	.ascii "BongoMute2"                             ; FEDC98  [  7][ 91]
	.ascii "BongoMute1"                             ; FEDCA2  [  7][ 92]
	.ascii "Hi-Hat Acc"                             ; FEDCAC  [  7][ 93]
	.ascii "Hi-Hat Ped"                             ; FEDCB6  [  7][ 94]
	.ascii "FloorTom H"                             ; FEDCC0  [  7][ 95]
	.ascii "Shaker On "                             ; FEDCCA  [  7][ 96]
	.ascii "Shaker Off"                             ; FEDCD4  [  7][ 97]
	.ascii "Cabasa    "                             ; FEDCDE  [  7][ 98]
	.ascii "TimbOpenLo"                             ; FEDCE8  [  7][ 99]
	.ascii "TimbOpnRim"                             ; FEDCF2  [  7][100]
	.ascii "Agogo High"                             ; FEDCFC  [  7][101]
	.ascii "Agogo Low "                             ; FEDD06  [  7][102]
	.ascii "TimbOpenHi"                             ; FEDD10  [  7][103]
	.ascii "Timb Paila"                             ; FEDD1A  [  7][104]
	.ascii "Maracas On"                             ; FEDD24  [  7][105]
	.ascii "Maracas Of"                             ; FEDD2E  [  7][106]
	.ascii "Triangle O"                             ; FEDD38  [  7][107]
	.ascii "Triangle M"                             ; FEDD42  [  7][108]
	.ascii "Surdo Mute"                             ; FEDD4C  [  7][109]
	.ascii "Surdo Open"                             ; FEDD56  [  7][110]
	.ascii "Vibraslap "                             ; FEDD60  [  7][111]
	.ascii "SambaWhi S"                             ; FEDD6A  [  7][112]
	.ascii "SambaWhi L"                             ; FEDD74  [  7][113]
	.ascii "Hi-Hat HO "                             ; FEDD7E  [  7][114]
	.ascii "Wood Blk L"                             ; FEDD88  [  7][115]
	.ascii "Wood Blk M"                             ; FEDD92  [  7][116]
	.ascii "Wood Blk H"                             ; FEDD9C  [  7][117]
	.ascii "Scratch L "                             ; FEDDA6  [  7][118]
	.ascii "Scratch H "                             ; FEDDB0  [  7][119]
	.ascii "AmbientHam"                             ; FEDDBA  [  7][120]
	.ascii "FloorTom L"                             ; FEDDC4  [  7][121]
	.ascii "High Tom  "                             ; FEDDCE  [  7][122]
	.ascii "          "                             ; FEDDD8  [  7][123]
	.ascii "          "                             ; FEDDE2  [  7][124]
	.ascii "Metro 1   "                             ; FEDDEC  [  7][125]
	.ascii "Metro 2   "                             ; FEDDF6  [  7][126]
	.ascii "Metro 3   "                             ; FEDE00  [  7][127]
	.ascii "       128"                             ; FEDE0A  [  7][128]

; DrumKitNames_Block8 -- name block 8: 129 ten-character names, 109 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFEDE14 as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block8:
; ---- name block 8, 0xFEDE14: 20 of 129 names are blank ----
	.ascii "          "                             ; FEDE14  [  8][  0]
	.ascii "          "                             ; FEDE1E  [  8][  1]
	.ascii "          "                             ; FEDE28  [  8][  2]
	.ascii "          "                             ; FEDE32  [  8][  3]
	.ascii "          "                             ; FEDE3C  [  8][  4]
	.ascii "          "                             ; FEDE46  [  8][  5]
	.ascii "          "                             ; FEDE50  [  8][  6]
	.ascii "          "                             ; FEDE5A  [  8][  7]
	.ascii "          "                             ; FEDE64  [  8][  8]
	.ascii "          "                             ; FEDE6E  [  8][  9]
	.ascii "          "                             ; FEDE78  [  8][ 10]
	.ascii "          "                             ; FEDE82  [  8][ 11]
	.ascii "          "                             ; FEDE8C  [  8][ 12]
	.ascii "          "                             ; FEDE96  [  8][ 13]
	.ascii "          "                             ; FEDEA0  [  8][ 14]
	.ascii "          "                             ; FEDEAA  [  8][ 15]
	.ascii "          "                             ; FEDEB4  [  8][ 16]
	.ascii "Voice Ah  "                             ; FEDEBE  [  8][ 17]
	.ascii "Voice Yeh "                             ; FEDEC8  [  8][ 18]
	.ascii "SleighBell"                             ; FEDED2  [  8][ 19]
	.ascii "Castanets "                             ; FEDEDC  [  8][ 20]
	.ascii "Orch Tamb "                             ; FEDEE6  [  8][ 21]
	.ascii "Rev Cym   "                             ; FEDEF0  [  8][ 22]
	.ascii "Rev Snare "                             ; FEDEFA  [  8][ 23]
	.ascii "CymSftMlet"                             ; FEDF04  [  8][ 24]
	.ascii "Orch.Cym 2"                             ; FEDF0E  [  8][ 25]
	.ascii "Ride 2    "                             ; FEDF18  [  8][ 26]
	.ascii "          "                             ; FEDF22  [  8][ 27]
	.ascii "Ride Bell "                             ; FEDF2C  [  8][ 28]
	.ascii "Wind Chime"                             ; FEDF36  [  8][ 29]
	.ascii "Tam-Tam   "                             ; FEDF40  [  8][ 30]
	.ascii "Spc Snare "                             ; FEDF4A  [  8][ 31]
	.ascii "Orch.Snare"                             ; FEDF54  [  8][ 32]
	.ascii "Extra Tom3"                             ; FEDF5E  [  8][ 33]
	.ascii "Extra Tom2"                             ; FEDF68  [  8][ 34]
	.ascii "Extra Tom1"                             ; FEDF72  [  8][ 35]
	.ascii "Orch.B.Dr1"                             ; FEDF7C  [  8][ 36]
	.ascii "Orch.B.Dr2"                             ; FEDF86  [  8][ 37]
	.ascii "Orch.S.Dr1"                             ; FEDF90  [  8][ 38]
	.ascii "Snare Dr 2"                             ; FEDF9A  [  8][ 39]
	.ascii "Orch.S.Dr3"                             ; FEDFA4  [  8][ 40]
	.ascii "Tom 3     "                             ; FEDFAE  [  8][ 41]
	.ascii "Extra Tom3"                             ; FEDFB8  [  8][ 42]
	.ascii "Tom 2     "                             ; FEDFC2  [  8][ 43]
	.ascii "Extra Tom2"                             ; FEDFCC  [  8][ 44]
	.ascii "Tom 1     "                             ; FEDFD6  [  8][ 45]
	.ascii "Extra Tom1"                             ; FEDFE0  [  8][ 46]
	.ascii "Rim Shot  "                             ; FEDFEA  [  8][ 47]
	.ascii "Hi-Hat Cl "                             ; FEDFF4  [  8][ 48]
	.ascii "Hi-Hat Cl "                             ; FEDFFE  [  8][ 49]
	.ascii "Hi-Hat O  "                             ; FEE008  [  8][ 50]
	.ascii "Orch.Cym 1"                             ; FEE012  [  8][ 51]
	.ascii "Ride 1    "                             ; FEE01C  [  8][ 52]
	.ascii "TamburnAcc"                             ; FEE026  [  8][ 53]
	.ascii "Tamburn Bt"                             ; FEE030  [  8][ 54]
	.ascii "Castanets "                             ; FEE03A  [  8][ 55]
	.ascii "Triangle M"                             ; FEE044  [  8][ 56]
	.ascii "Triangle O"                             ; FEE04E  [  8][ 57]
	.ascii "Rattle    "                             ; FEE058  [  8][ 58]
	.ascii "Cowbell 1 "                             ; FEE062  [  8][ 59]
	.ascii "Timpani C "                             ; FEE06C  [  8][ 60]
	.ascii "Timpani C#"                             ; FEE076  [  8][ 61]
	.ascii "Timpani D "                             ; FEE080  [  8][ 62]
	.ascii "Timpani D#"                             ; FEE08A  [  8][ 63]
	.ascii "Timpani E "                             ; FEE094  [  8][ 64]
	.ascii "Timpani F "                             ; FEE09E  [  8][ 65]
	.ascii "Timpani F#"                             ; FEE0A8  [  8][ 66]
	.ascii "Timpani G "                             ; FEE0B2  [  8][ 67]
	.ascii "Timpani G#"                             ; FEE0BC  [  8][ 68]
	.ascii "Timpani A "                             ; FEE0C6  [  8][ 69]
	.ascii "Timpani A#"                             ; FEE0D0  [  8][ 70]
	.ascii "Timpani B "                             ; FEE0DA  [  8][ 71]
	.ascii "Timpani c "                             ; FEE0E4  [  8][ 72]
	.ascii "Timpani c#"                             ; FEE0EE  [  8][ 73]
	.ascii "Timpani d "                             ; FEE0F8  [  8][ 74]
	.ascii "Timpani d#"                             ; FEE102  [  8][ 75]
	.ascii "Timpani e "                             ; FEE10C  [  8][ 76]
	.ascii "Timpani f "                             ; FEE116  [  8][ 77]
	.ascii "Timpani f#"                             ; FEE120  [  8][ 78]
	.ascii "Timpani g "                             ; FEE12A  [  8][ 79]
	.ascii "Timpani g#"                             ; FEE134  [  8][ 80]
	.ascii "Timpani a "                             ; FEE13E  [  8][ 81]
	.ascii "Timpani a#"                             ; FEE148  [  8][ 82]
	.ascii "Timpani b "                             ; FEE152  [  8][ 83]
	.ascii "T.Bells C "                             ; FEE15C  [  8][ 84]
	.ascii "T.Bells C#"                             ; FEE166  [  8][ 85]
	.ascii "T.Bells D "                             ; FEE170  [  8][ 86]
	.ascii "T.Bells D#"                             ; FEE17A  [  8][ 87]
	.ascii "T.Bells E "                             ; FEE184  [  8][ 88]
	.ascii "T.Bells F "                             ; FEE18E  [  8][ 89]
	.ascii "T.Bells F#"                             ; FEE198  [  8][ 90]
	.ascii "T.Bells G "                             ; FEE1A2  [  8][ 91]
	.ascii "T.Bells G#"                             ; FEE1AC  [  8][ 92]
	.ascii "T.Bells A "                             ; FEE1B6  [  8][ 93]
	.ascii "T.Bells A#"                             ; FEE1C0  [  8][ 94]
	.ascii "T.Bells B "                             ; FEE1CA  [  8][ 95]
	.ascii "T.Bells c "                             ; FEE1D4  [  8][ 96]
	.ascii "T.Bells c#"                             ; FEE1DE  [  8][ 97]
	.ascii "T.Bells d "                             ; FEE1E8  [  8][ 98]
	.ascii "T.Bells d#"                             ; FEE1F2  [  8][ 99]
	.ascii "T.Bells e "                             ; FEE1FC  [  8][100]
	.ascii "T.Bells f "                             ; FEE206  [  8][101]
	.ascii "T.Bells f#"                             ; FEE210  [  8][102]
	.ascii "T.Bells g "                             ; FEE21A  [  8][103]
	.ascii "T.Bells g#"                             ; FEE224  [  8][104]
	.ascii "T.Bells a "                             ; FEE22E  [  8][105]
	.ascii "T.Bells a#"                             ; FEE238  [  8][106]
	.ascii "T.Bells b "                             ; FEE242  [  8][107]
	.ascii "Triangle M"                             ; FEE24C  [  8][108]
	.ascii "Surdo Mute"                             ; FEE256  [  8][109]
	.ascii "Surdo Open"                             ; FEE260  [  8][110]
	.ascii "Vibraslap "                             ; FEE26A  [  8][111]
	.ascii "SambaWhi S"                             ; FEE274  [  8][112]
	.ascii "SambaWhi L"                             ; FEE27E  [  8][113]
	.ascii "Hi-Hat HO "                             ; FEE288  [  8][114]
	.ascii "Wood Blk L"                             ; FEE292  [  8][115]
	.ascii "Wood Blk M"                             ; FEE29C  [  8][116]
	.ascii "Wood Blk H"                             ; FEE2A6  [  8][117]
	.ascii "Scratch L "                             ; FEE2B0  [  8][118]
	.ascii "Scratch H "                             ; FEE2BA  [  8][119]
	.ascii "AmbientHam"                             ; FEE2C4  [  8][120]
	.ascii "FloorTom L"                             ; FEE2CE  [  8][121]
	.ascii "High Tom  "                             ; FEE2D8  [  8][122]
	.ascii "          "                             ; FEE2E2  [  8][123]
	.ascii "          "                             ; FEE2EC  [  8][124]
	.ascii "Metro 1   "                             ; FEE2F6  [  8][125]
	.ascii "Metro 2   "                             ; FEE300  [  8][126]
	.ascii "Metro 3   "                             ; FEE30A  [  8][127]
	.ascii "       128"                             ; FEE314  [  8][128]

; DrumKitNames_Block9 -- name block 9: 129 ten-character names, 51 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFEE31E as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block9:
; ---- name block 9, 0xFEE31E: 78 of 129 names are blank ----
	.ascii "          "                             ; FEE31E  [  9][  0]
	.ascii "          "                             ; FEE328  [  9][  1]
	.ascii "          "                             ; FEE332  [  9][  2]
	.ascii "          "                             ; FEE33C  [  9][  3]
	.ascii "          "                             ; FEE346  [  9][  4]
	.ascii "          "                             ; FEE350  [  9][  5]
	.ascii "          "                             ; FEE35A  [  9][  6]
	.ascii "          "                             ; FEE364  [  9][  7]
	.ascii "          "                             ; FEE36E  [  9][  8]
	.ascii "          "                             ; FEE378  [  9][  9]
	.ascii "          "                             ; FEE382  [  9][ 10]
	.ascii "          "                             ; FEE38C  [  9][ 11]
	.ascii "          "                             ; FEE396  [  9][ 12]
	.ascii "          "                             ; FEE3A0  [  9][ 13]
	.ascii "          "                             ; FEE3AA  [  9][ 14]
	.ascii "Square Clk"                             ; FEE3B4  [  9][ 15]
	.ascii "MetroClick"                             ; FEE3BE  [  9][ 16]
	.ascii "Metro Bell"                             ; FEE3C8  [  9][ 17]
	.ascii "          "                             ; FEE3D2  [  9][ 18]
	.ascii "          "                             ; FEE3DC  [  9][ 19]
	.ascii "          "                             ; FEE3E6  [  9][ 20]
	.ascii "          "                             ; FEE3F0  [  9][ 21]
	.ascii "          "                             ; FEE3FA  [  9][ 22]
	.ascii "          "                             ; FEE404  [  9][ 23]
	.ascii "Fl Breath "                             ; FEE40E  [  9][ 24]
	.ascii "Slap      "                             ; FEE418  [  9][ 25]
	.ascii "Slap Shot "                             ; FEE422  [  9][ 26]
	.ascii "Wind Chime"                             ; FEE42C  [  9][ 27]
	.ascii "Orch.Hit L"                             ; FEE436  [  9][ 28]
	.ascii "Little Dog"                             ; FEE440  [  9][ 29]
	.ascii "          "                             ; FEE44A  [  9][ 30]
	.ascii "PickNoise3"                             ; FEE454  [  9][ 31]
	.ascii "PickNoise4"                             ; FEE45E  [  9][ 32]
	.ascii "Voice Ah  "                             ; FEE468  [  9][ 33]
	.ascii "Voice Yeh "                             ; FEE472  [  9][ 34]
	.ascii "Heart Beat"                             ; FEE47C  [  9][ 35]
	.ascii "Fret Noise"                             ; FEE486  [  9][ 36]
	.ascii "          "                             ; FEE490  [  9][ 37]
	.ascii "PickNoise2"                             ; FEE49A  [  9][ 38]
	.ascii "          "                             ; FEE4A4  [  9][ 39]
	.ascii "          "                             ; FEE4AE  [  9][ 40]
	.ascii "          "                             ; FEE4B8  [  9][ 41]
	.ascii "          "                             ; FEE4C2  [  9][ 42]
	.ascii "Scratch 2 "                             ; FEE4CC  [  9][ 43]
	.ascii "          "                             ; FEE4D6  [  9][ 44]
	.ascii "Hand Claps"                             ; FEE4E0  [  9][ 45]
	.ascii "          "                             ; FEE4EA  [  9][ 46]
	.ascii "PickNoise1"                             ; FEE4F4  [  9][ 47]
	.ascii "Applause 1"                             ; FEE4FE  [  9][ 48]
	.ascii "Applause 2"                             ; FEE508  [  9][ 49]
	.ascii "Whistle   "                             ; FEE512  [  9][ 50]
	.ascii "Scratch 1 "                             ; FEE51C  [  9][ 51]
	.ascii "Orch.Hit H"                             ; FEE526  [  9][ 52]
	.ascii "MetalHit L"                             ; FEE530  [  9][ 53]
	.ascii "MetalHit H"                             ; FEE53A  [  9][ 54]
	.ascii "Temple Blk"                             ; FEE544  [  9][ 55]
	.ascii "Small Bell"                             ; FEE54E  [  9][ 56]
	.ascii "SleighBell"                             ; FEE558  [  9][ 57]
	.ascii "          "                             ; FEE562  [  9][ 58]
	.ascii "Tam-Tam   "                             ; FEE56C  [  9][ 59]
	.ascii "Explosion "                             ; FEE576  [  9][ 60]
	.ascii "          "                             ; FEE580  [  9][ 61]
	.ascii "Helicopter"                             ; FEE58A  [  9][ 62]
	.ascii "          "                             ; FEE594  [  9][ 63]
	.ascii "          "                             ; FEE59E  [  9][ 64]
	.ascii "Telephone "                             ; FEE5A8  [  9][ 65]
	.ascii "Wave 1    "                             ; FEE5B2  [  9][ 66]
	.ascii "Wave 2    "                             ; FEE5BC  [  9][ 67]
	.ascii "          "                             ; FEE5C6  [  9][ 68]
	.ascii "          "                             ; FEE5D0  [  9][ 69]
	.ascii "          "                             ; FEE5DA  [  9][ 70]
	.ascii "          "                             ; FEE5E4  [  9][ 71]
	.ascii "          "                             ; FEE5EE  [  9][ 72]
	.ascii "          "                             ; FEE5F8  [  9][ 73]
	.ascii "          "                             ; FEE602  [  9][ 74]
	.ascii "          "                             ; FEE60C  [  9][ 75]
	.ascii "Bird 5    "                             ; FEE616  [  9][ 76]
	.ascii "Bird 4    "                             ; FEE620  [  9][ 77]
	.ascii "          "                             ; FEE62A  [  9][ 78]
	.ascii "          "                             ; FEE634  [  9][ 79]
	.ascii "          "                             ; FEE63E  [  9][ 80]
	.ascii "          "                             ; FEE648  [  9][ 81]
	.ascii "          "                             ; FEE652  [  9][ 82]
	.ascii "          "                             ; FEE65C  [  9][ 83]
	.ascii "          "                             ; FEE666  [  9][ 84]
	.ascii "Bird 6    "                             ; FEE670  [  9][ 85]
	.ascii "Bird 7    "                             ; FEE67A  [  9][ 86]
	.ascii "Bullfrog  "                             ; FEE684  [  9][ 87]
	.ascii "          "                             ; FEE68E  [  9][ 88]
	.ascii "          "                             ; FEE698  [  9][ 89]
	.ascii "          "                             ; FEE6A2  [  9][ 90]
	.ascii "          "                             ; FEE6AC  [  9][ 91]
	.ascii "          "                             ; FEE6B6  [  9][ 92]
	.ascii "          "                             ; FEE6C0  [  9][ 93]
	.ascii "          "                             ; FEE6CA  [  9][ 94]
	.ascii "Sax Breath"                             ; FEE6D4  [  9][ 95]
	.ascii "Wind      "                             ; FEE6DE  [  9][ 96]
	.ascii "          "                             ; FEE6E8  [  9][ 97]
	.ascii "          "                             ; FEE6F2  [  9][ 98]
	.ascii "          "                             ; FEE6FC  [  9][ 99]
	.ascii "Gun Shot  "                             ; FEE706  [  9][100]
	.ascii "SteamWhisl"                             ; FEE710  [  9][101]
	.ascii "Train     "                             ; FEE71A  [  9][102]
	.ascii "          "                             ; FEE724  [  9][103]
	.ascii "          "                             ; FEE72E  [  9][104]
	.ascii "Bird 2    "                             ; FEE738  [  9][105]
	.ascii "          "                             ; FEE742  [  9][106]
	.ascii "Bird 3    "                             ; FEE74C  [  9][107]
	.ascii "bird 1    "                             ; FEE756  [  9][108]
	.ascii "          "                             ; FEE760  [  9][109]
	.ascii "          "                             ; FEE76A  [  9][110]
	.ascii "          "                             ; FEE774  [  9][111]
	.ascii "          "                             ; FEE77E  [  9][112]
	.ascii "          "                             ; FEE788  [  9][113]
	.ascii "          "                             ; FEE792  [  9][114]
	.ascii "          "                             ; FEE79C  [  9][115]
	.ascii "          "                             ; FEE7A6  [  9][116]
	.ascii "          "                             ; FEE7B0  [  9][117]
	.ascii "          "                             ; FEE7BA  [  9][118]
	.ascii "          "                             ; FEE7C4  [  9][119]
	.ascii "          "                             ; FEE7CE  [  9][120]
	.ascii "          "                             ; FEE7D8  [  9][121]
	.ascii "          "                             ; FEE7E2  [  9][122]
	.ascii "          "                             ; FEE7EC  [  9][123]
	.ascii "          "                             ; FEE7F6  [  9][124]
	.ascii "Metro 1   "                             ; FEE800  [  9][125]
	.ascii "Metro 2   "                             ; FEE80A  [  9][126]
	.ascii "Metro 3   "                             ; FEE814  [  9][127]
	.ascii "          "                             ; FEE81E  [  9][128]

; DrumKitNames_Block10 -- name block 10: 129 ten-character names, 60 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFEE828 as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block10:
; ---- name block 10, 0xFEE828: 69 of 129 names are blank ----
	.ascii "          "                             ; FEE828  [ 10][  0]
	.ascii "          "                             ; FEE832  [ 10][  1]
	.ascii "          "                             ; FEE83C  [ 10][  2]
	.ascii "          "                             ; FEE846  [ 10][  3]
	.ascii "          "                             ; FEE850  [ 10][  4]
	.ascii "          "                             ; FEE85A  [ 10][  5]
	.ascii "          "                             ; FEE864  [ 10][  6]
	.ascii "          "                             ; FEE86E  [ 10][  7]
	.ascii "          "                             ; FEE878  [ 10][  8]
	.ascii "          "                             ; FEE882  [ 10][  9]
	.ascii "          "                             ; FEE88C  [ 10][ 10]
	.ascii "          "                             ; FEE896  [ 10][ 11]
	.ascii "          "                             ; FEE8A0  [ 10][ 12]
	.ascii "          "                             ; FEE8AA  [ 10][ 13]
	.ascii "          "                             ; FEE8B4  [ 10][ 14]
	.ascii "          "                             ; FEE8BE  [ 10][ 15]
	.ascii "          "                             ; FEE8C8  [ 10][ 16]
	.ascii "          "                             ; FEE8D2  [ 10][ 17]
	.ascii "          "                             ; FEE8DC  [ 10][ 18]
	.ascii "          "                             ; FEE8E6  [ 10][ 19]
	.ascii "          "                             ; FEE8F0  [ 10][ 20]
	.ascii "          "                             ; FEE8FA  [ 10][ 21]
	.ascii "          "                             ; FEE904  [ 10][ 22]
	.ascii "          "                             ; FEE90E  [ 10][ 23]
	.ascii "          "                             ; FEE918  [ 10][ 24]
	.ascii "          "                             ; FEE922  [ 10][ 25]
	.ascii "          "                             ; FEE92C  [ 10][ 26]
	.ascii "          "                             ; FEE936  [ 10][ 27]
	.ascii "Slap      "                             ; FEE940  [ 10][ 28]
	.ascii "Scratch 1 "                             ; FEE94A  [ 10][ 29]
	.ascii "Scratch 2 "                             ; FEE954  [ 10][ 30]
	.ascii "Rim Shot  "                             ; FEE95E  [ 10][ 31]
	.ascii "Square Clk"                             ; FEE968  [ 10][ 32]
	.ascii "MetroClick"                             ; FEE972  [ 10][ 33]
	.ascii "Metro Bell"                             ; FEE97C  [ 10][ 34]
	.ascii "Bass Dr 2 "                             ; FEE986  [ 10][ 35]
	.ascii "Bass Dr 1 "                             ; FEE990  [ 10][ 36]
	.ascii "Rim Shot  "                             ; FEE99A  [ 10][ 37]
	.ascii "Snare Dr 1"                             ; FEE9A4  [ 10][ 38]
	.ascii "Hand Claps"                             ; FEE9AE  [ 10][ 39]
	.ascii "Snare Dr 2"                             ; FEE9B8  [ 10][ 40]
	.ascii "FloorTom L"                             ; FEE9C2  [ 10][ 41]
	.ascii "Hi-Hat CL "                             ; FEE9CC  [ 10][ 42]
	.ascii "FloorTom H"                             ; FEE9D6  [ 10][ 43]
	.ascii "Hi-Hat Ped"                             ; FEE9E0  [ 10][ 44]
	.ascii "Tom Low   "                             ; FEE9EA  [ 10][ 45]
	.ascii "Hi-Hat O  "                             ; FEE9F4  [ 10][ 46]
	.ascii "Tom Mid   "                             ; FEE9FE  [ 10][ 47]
	.ascii "Tom High 1"                             ; FEEA08  [ 10][ 48]
	.ascii "Crash Cym1"                             ; FEEA12  [ 10][ 49]
	.ascii "Tom High 2"                             ; FEEA1C  [ 10][ 50]
	.ascii "Ride Cym 1"                             ; FEEA26  [ 10][ 51]
	.ascii "Rev Cymbal"                             ; FEEA30  [ 10][ 52]
	.ascii "Ride Bell "                             ; FEEA3A  [ 10][ 53]
	.ascii "Tambourine"                             ; FEEA44  [ 10][ 54]
	.ascii "Splash Cym"                             ; FEEA4E  [ 10][ 55]
	.ascii "Cowbell   "                             ; FEEA58  [ 10][ 56]
	.ascii "Crash Cym2"                             ; FEEA62  [ 10][ 57]
	.ascii "Vibraslap "                             ; FEEA6C  [ 10][ 58]
	.ascii "Ride Cym 2"                             ; FEEA76  [ 10][ 59]
	.ascii "Bongo High"                             ; FEEA80  [ 10][ 60]
	.ascii "Bongo Low "                             ; FEEA8A  [ 10][ 61]
	.ascii "CongaMutCr"                             ; FEEA94  [ 10][ 62]
	.ascii "Conga High"                             ; FEEA9E  [ 10][ 63]
	.ascii "Conga Low "                             ; FEEAA8  [ 10][ 64]
	.ascii "Timbales H"                             ; FEEAB2  [ 10][ 65]
	.ascii "Timbales L"                             ; FEEABC  [ 10][ 66]
	.ascii "Agogo High"                             ; FEEAC6  [ 10][ 67]
	.ascii "Agogo Low "                             ; FEEAD0  [ 10][ 68]
	.ascii "Cabasa    "                             ; FEEADA  [ 10][ 69]
	.ascii "Maracas   "                             ; FEEAE4  [ 10][ 70]
	.ascii "SambaWhi S"                             ; FEEAEE  [ 10][ 71]
	.ascii "SambaWhi L"                             ; FEEAF8  [ 10][ 72]
	.ascii "GuiroShort"                             ; FEEB02  [ 10][ 73]
	.ascii "Guiro Long"                             ; FEEB0C  [ 10][ 74]
	.ascii "Claves    "                             ; FEEB16  [ 10][ 75]
	.ascii "Wood Blk M"                             ; FEEB20  [ 10][ 76]
	.ascii "Wood Blk L"                             ; FEEB2A  [ 10][ 77]
	.ascii "Cuica High"                             ; FEEB34  [ 10][ 78]
	.ascii "Cuica Low "                             ; FEEB3E  [ 10][ 79]
	.ascii "Triangle M"                             ; FEEB48  [ 10][ 80]
	.ascii "Triangle O"                             ; FEEB52  [ 10][ 81]
	.ascii "Shaker    "                             ; FEEB5C  [ 10][ 82]
	.ascii "SleighBell"                             ; FEEB66  [ 10][ 83]
	.ascii "Wind Chime"                             ; FEEB70  [ 10][ 84]
	.ascii "Castanets "                             ; FEEB7A  [ 10][ 85]
	.ascii "Surdo Mute"                             ; FEEB84  [ 10][ 86]
	.ascii "Surdo Open"                             ; FEEB8E  [ 10][ 87]
	.ascii "          "                             ; FEEB98  [ 10][ 88]
	.ascii "          "                             ; FEEBA2  [ 10][ 89]
	.ascii "          "                             ; FEEBAC  [ 10][ 90]
	.ascii "          "                             ; FEEBB6  [ 10][ 91]
	.ascii "          "                             ; FEEBC0  [ 10][ 92]
	.ascii "          "                             ; FEEBCA  [ 10][ 93]
	.ascii "          "                             ; FEEBD4  [ 10][ 94]
	.ascii "          "                             ; FEEBDE  [ 10][ 95]
	.ascii "          "                             ; FEEBE8  [ 10][ 96]
	.ascii "          "                             ; FEEBF2  [ 10][ 97]
	.ascii "          "                             ; FEEBFC  [ 10][ 98]
	.ascii "          "                             ; FEEC06  [ 10][ 99]
	.ascii "          "                             ; FEEC10  [ 10][100]
	.ascii "          "                             ; FEEC1A  [ 10][101]
	.ascii "          "                             ; FEEC24  [ 10][102]
	.ascii "          "                             ; FEEC2E  [ 10][103]
	.ascii "          "                             ; FEEC38  [ 10][104]
	.ascii "          "                             ; FEEC42  [ 10][105]
	.ascii "          "                             ; FEEC4C  [ 10][106]
	.ascii "          "                             ; FEEC56  [ 10][107]
	.ascii "          "                             ; FEEC60  [ 10][108]
	.ascii "          "                             ; FEEC6A  [ 10][109]
	.ascii "          "                             ; FEEC74  [ 10][110]
	.ascii "          "                             ; FEEC7E  [ 10][111]
	.ascii "          "                             ; FEEC88  [ 10][112]
	.ascii "          "                             ; FEEC92  [ 10][113]
	.ascii "          "                             ; FEEC9C  [ 10][114]
	.ascii "          "                             ; FEECA6  [ 10][115]
	.ascii "          "                             ; FEECB0  [ 10][116]
	.ascii "          "                             ; FEECBA  [ 10][117]
	.ascii "          "                             ; FEECC4  [ 10][118]
	.ascii "          "                             ; FEECCE  [ 10][119]
	.ascii "          "                             ; FEECD8  [ 10][120]
	.ascii "          "                             ; FEECE2  [ 10][121]
	.ascii "          "                             ; FEECEC  [ 10][122]
	.ascii "          "                             ; FEECF6  [ 10][123]
	.ascii "          "                             ; FEED00  [ 10][124]
	.ascii "          "                             ; FEED0A  [ 10][125]
	.ascii "          "                             ; FEED14  [ 10][126]
	.ascii "          "                             ; FEED1E  [ 10][127]
	.ascii "          "                             ; FEED28  [ 10][128]

; DrumKitNames_Block11 -- name block 11: 129 ten-character names, 60 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFEED32 as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block11:
; ---- name block 11, 0xFEED32: 69 of 129 names are blank ----
	.ascii "          "                             ; FEED32  [ 11][  0]
	.ascii "          "                             ; FEED3C  [ 11][  1]
	.ascii "          "                             ; FEED46  [ 11][  2]
	.ascii "          "                             ; FEED50  [ 11][  3]
	.ascii "          "                             ; FEED5A  [ 11][  4]
	.ascii "          "                             ; FEED64  [ 11][  5]
	.ascii "          "                             ; FEED6E  [ 11][  6]
	.ascii "          "                             ; FEED78  [ 11][  7]
	.ascii "          "                             ; FEED82  [ 11][  8]
	.ascii "          "                             ; FEED8C  [ 11][  9]
	.ascii "          "                             ; FEED96  [ 11][ 10]
	.ascii "          "                             ; FEEDA0  [ 11][ 11]
	.ascii "          "                             ; FEEDAA  [ 11][ 12]
	.ascii "          "                             ; FEEDB4  [ 11][ 13]
	.ascii "          "                             ; FEEDBE  [ 11][ 14]
	.ascii "          "                             ; FEEDC8  [ 11][ 15]
	.ascii "          "                             ; FEEDD2  [ 11][ 16]
	.ascii "          "                             ; FEEDDC  [ 11][ 17]
	.ascii "          "                             ; FEEDE6  [ 11][ 18]
	.ascii "          "                             ; FEEDF0  [ 11][ 19]
	.ascii "          "                             ; FEEDFA  [ 11][ 20]
	.ascii "          "                             ; FEEE04  [ 11][ 21]
	.ascii "          "                             ; FEEE0E  [ 11][ 22]
	.ascii "          "                             ; FEEE18  [ 11][ 23]
	.ascii "          "                             ; FEEE22  [ 11][ 24]
	.ascii "          "                             ; FEEE2C  [ 11][ 25]
	.ascii "          "                             ; FEEE36  [ 11][ 26]
	.ascii "          "                             ; FEEE40  [ 11][ 27]
	.ascii "Slap      "                             ; FEEE4A  [ 11][ 28]
	.ascii "Scratch 1 "                             ; FEEE54  [ 11][ 29]
	.ascii "Scratch 2 "                             ; FEEE5E  [ 11][ 30]
	.ascii "Rim Shot  "                             ; FEEE68  [ 11][ 31]
	.ascii "Square Clk"                             ; FEEE72  [ 11][ 32]
	.ascii "MetroClick"                             ; FEEE7C  [ 11][ 33]
	.ascii "Metro Bell"                             ; FEEE86  [ 11][ 34]
	.ascii "Bass Dr 2 "                             ; FEEE90  [ 11][ 35]
	.ascii "Bass Dr 1 "                             ; FEEE9A  [ 11][ 36]
	.ascii "Rim Shot  "                             ; FEEEA4  [ 11][ 37]
	.ascii "Brush Tap "                             ; FEEEAE  [ 11][ 38]
	.ascii "Brush Hit "                             ; FEEEB8  [ 11][ 39]
	.ascii "Brush Long"                             ; FEEEC2  [ 11][ 40]
	.ascii "FloorTom L"                             ; FEEECC  [ 11][ 41]
	.ascii "Hi-Hat CL "                             ; FEEED6  [ 11][ 42]
	.ascii "FloorTom H"                             ; FEEEE0  [ 11][ 43]
	.ascii "Hi-Hat Ped"                             ; FEEEEA  [ 11][ 44]
	.ascii "Tom Low   "                             ; FEEEF4  [ 11][ 45]
	.ascii "Hi-Hat O  "                             ; FEEEFE  [ 11][ 46]
	.ascii "Tom Mid   "                             ; FEEF08  [ 11][ 47]
	.ascii "Tom High 1"                             ; FEEF12  [ 11][ 48]
	.ascii "Crash Cym1"                             ; FEEF1C  [ 11][ 49]
	.ascii "Tom High 2"                             ; FEEF26  [ 11][ 50]
	.ascii "Ride Cym 1"                             ; FEEF30  [ 11][ 51]
	.ascii "ChineseCym"                             ; FEEF3A  [ 11][ 52]
	.ascii "Ride Bell "                             ; FEEF44  [ 11][ 53]
	.ascii "Tambourine"                             ; FEEF4E  [ 11][ 54]
	.ascii "Splash Cym"                             ; FEEF58  [ 11][ 55]
	.ascii "Cowbell   "                             ; FEEF62  [ 11][ 56]
	.ascii "Crash Cym2"                             ; FEEF6C  [ 11][ 57]
	.ascii "Vibraslap "                             ; FEEF76  [ 11][ 58]
	.ascii "Ride Cym 2"                             ; FEEF80  [ 11][ 59]
	.ascii "Bongo High"                             ; FEEF8A  [ 11][ 60]
	.ascii "Bongo Low "                             ; FEEF94  [ 11][ 61]
	.ascii "CongaMutCr"                             ; FEEF9E  [ 11][ 62]
	.ascii "Conga High"                             ; FEEFA8  [ 11][ 63]
	.ascii "Conga Low "                             ; FEEFB2  [ 11][ 64]
	.ascii "Timbales H"                             ; FEEFBC  [ 11][ 65]
	.ascii "Timbales L"                             ; FEEFC6  [ 11][ 66]
	.ascii "Agogo High"                             ; FEEFD0  [ 11][ 67]
	.ascii "Agogo Low "                             ; FEEFDA  [ 11][ 68]
	.ascii "Cabasa    "                             ; FEEFE4  [ 11][ 69]
	.ascii "Maracas   "                             ; FEEFEE  [ 11][ 70]
	.ascii "SambaWhi S"                             ; FEEFF8  [ 11][ 71]
	.ascii "SambaWhi L"                             ; FEF002  [ 11][ 72]
	.ascii "GuiroShort"                             ; FEF00C  [ 11][ 73]
	.ascii "Guiro Long"                             ; FEF016  [ 11][ 74]
	.ascii "Claves    "                             ; FEF020  [ 11][ 75]
	.ascii "Wood Blk M"                             ; FEF02A  [ 11][ 76]
	.ascii "Wood Blk L"                             ; FEF034  [ 11][ 77]
	.ascii "Cuica High"                             ; FEF03E  [ 11][ 78]
	.ascii "Cuica Low "                             ; FEF048  [ 11][ 79]
	.ascii "Triangle M"                             ; FEF052  [ 11][ 80]
	.ascii "Triangle O"                             ; FEF05C  [ 11][ 81]
	.ascii "Shaker    "                             ; FEF066  [ 11][ 82]
	.ascii "SleighBell"                             ; FEF070  [ 11][ 83]
	.ascii "Wind Chime"                             ; FEF07A  [ 11][ 84]
	.ascii "Castanets "                             ; FEF084  [ 11][ 85]
	.ascii "Surdo Mute"                             ; FEF08E  [ 11][ 86]
	.ascii "Surdo Open"                             ; FEF098  [ 11][ 87]
	.ascii "          "                             ; FEF0A2  [ 11][ 88]
	.ascii "          "                             ; FEF0AC  [ 11][ 89]
	.ascii "          "                             ; FEF0B6  [ 11][ 90]
	.ascii "          "                             ; FEF0C0  [ 11][ 91]
	.ascii "          "                             ; FEF0CA  [ 11][ 92]
	.ascii "          "                             ; FEF0D4  [ 11][ 93]
	.ascii "          "                             ; FEF0DE  [ 11][ 94]
	.ascii "          "                             ; FEF0E8  [ 11][ 95]
	.ascii "          "                             ; FEF0F2  [ 11][ 96]
	.ascii "          "                             ; FEF0FC  [ 11][ 97]
	.ascii "          "                             ; FEF106  [ 11][ 98]
	.ascii "          "                             ; FEF110  [ 11][ 99]
	.ascii "          "                             ; FEF11A  [ 11][100]
	.ascii "          "                             ; FEF124  [ 11][101]
	.ascii "          "                             ; FEF12E  [ 11][102]
	.ascii "          "                             ; FEF138  [ 11][103]
	.ascii "          "                             ; FEF142  [ 11][104]
	.ascii "          "                             ; FEF14C  [ 11][105]
	.ascii "          "                             ; FEF156  [ 11][106]
	.ascii "          "                             ; FEF160  [ 11][107]
	.ascii "          "                             ; FEF16A  [ 11][108]
	.ascii "          "                             ; FEF174  [ 11][109]
	.ascii "          "                             ; FEF17E  [ 11][110]
	.ascii "          "                             ; FEF188  [ 11][111]
	.ascii "          "                             ; FEF192  [ 11][112]
	.ascii "          "                             ; FEF19C  [ 11][113]
	.ascii "          "                             ; FEF1A6  [ 11][114]
	.ascii "          "                             ; FEF1B0  [ 11][115]
	.ascii "          "                             ; FEF1BA  [ 11][116]
	.ascii "          "                             ; FEF1C4  [ 11][117]
	.ascii "          "                             ; FEF1CE  [ 11][118]
	.ascii "          "                             ; FEF1D8  [ 11][119]
	.ascii "          "                             ; FEF1E2  [ 11][120]
	.ascii "          "                             ; FEF1EC  [ 11][121]
	.ascii "          "                             ; FEF1F6  [ 11][122]
	.ascii "          "                             ; FEF200  [ 11][123]
	.ascii "          "                             ; FEF20A  [ 11][124]
	.ascii "          "                             ; FEF214  [ 11][125]
	.ascii "          "                             ; FEF21E  [ 11][126]
	.ascii "          "                             ; FEF228  [ 11][127]
	.ascii "          "                             ; FEF232  [ 11][128]

; DrumKitNames_Block12 -- name block 12: 129 ten-character names, 62 non-blank.
; No reader is known.  DrumKitNameBlockPtrs names only blocks 1-6, and
; RecordNameSource_Select's other arms return block 0 or RAM 0x603FF6.
; Forms searched (2026-09-25, lane proma): the block's 24-bit address
;   0xFEF23C as 3 LE bytes at every offset of prom_a, prom_b and prom_c
;   (0 hits); 16-bit block offsets 1290*k in instruction operands;
;   any multiply by 1290 or by 129 in prom_a (none; the only mul-by-10
;   sites are 0xF8BC47, 0xFDA1F1, 0xFEB04E and the reader's 0xFEB2BD).
DrumKitNames_Block12:
; ---- name block 12, 0xFEF23C: 67 of 129 names are blank ----
	.ascii "          "                             ; FEF23C  [ 12][  0]
	.ascii "          "                             ; FEF246  [ 12][  1]
	.ascii "          "                             ; FEF250  [ 12][  2]
	.ascii "          "                             ; FEF25A  [ 12][  3]
	.ascii "          "                             ; FEF264  [ 12][  4]
	.ascii "          "                             ; FEF26E  [ 12][  5]
	.ascii "          "                             ; FEF278  [ 12][  6]
	.ascii "          "                             ; FEF282  [ 12][  7]
	.ascii "          "                             ; FEF28C  [ 12][  8]
	.ascii "          "                             ; FEF296  [ 12][  9]
	.ascii "          "                             ; FEF2A0  [ 12][ 10]
	.ascii "          "                             ; FEF2AA  [ 12][ 11]
	.ascii "          "                             ; FEF2B4  [ 12][ 12]
	.ascii "          "                             ; FEF2BE  [ 12][ 13]
	.ascii "          "                             ; FEF2C8  [ 12][ 14]
	.ascii "          "                             ; FEF2D2  [ 12][ 15]
	.ascii "          "                             ; FEF2DC  [ 12][ 16]
	.ascii "          "                             ; FEF2E6  [ 12][ 17]
	.ascii "          "                             ; FEF2F0  [ 12][ 18]
	.ascii "          "                             ; FEF2FA  [ 12][ 19]
	.ascii "          "                             ; FEF304  [ 12][ 20]
	.ascii "          "                             ; FEF30E  [ 12][ 21]
	.ascii "          "                             ; FEF318  [ 12][ 22]
	.ascii "          "                             ; FEF322  [ 12][ 23]
	.ascii "          "                             ; FEF32C  [ 12][ 24]
	.ascii "          "                             ; FEF336  [ 12][ 25]
	.ascii "          "                             ; FEF340  [ 12][ 26]
	.ascii "Hi-Hat Cl "                             ; FEF34A  [ 12][ 27]
	.ascii "Hi-Hat Ped"                             ; FEF354  [ 12][ 28]
	.ascii "Hi-Hat O  "                             ; FEF35E  [ 12][ 29]
	.ascii "RideCymbal"                             ; FEF368  [ 12][ 30]
	.ascii "Rim Shot  "                             ; FEF372  [ 12][ 31]
	.ascii "Square Clk"                             ; FEF37C  [ 12][ 32]
	.ascii "MetroClick"                             ; FEF386  [ 12][ 33]
	.ascii "Metro Bell"                             ; FEF390  [ 12][ 34]
	.ascii "Orch.B.Dr2"                             ; FEF39A  [ 12][ 35]
	.ascii "Orch.B.Dr1"                             ; FEF3A4  [ 12][ 36]
	.ascii "Rim Shot  "                             ; FEF3AE  [ 12][ 37]
	.ascii "Orch.S.Dr "                             ; FEF3B8  [ 12][ 38]
	.ascii "Castanets "                             ; FEF3C2  [ 12][ 39]
	.ascii "Orch.S.Dr "                             ; FEF3CC  [ 12][ 40]
	.ascii "Timpani F "                             ; FEF3D6  [ 12][ 41]
	.ascii "Timpani F#"                             ; FEF3E0  [ 12][ 42]
	.ascii "Timpani G "                             ; FEF3EA  [ 12][ 43]
	.ascii "Timpani G#"                             ; FEF3F4  [ 12][ 44]
	.ascii "Timpani A "                             ; FEF3FE  [ 12][ 45]
	.ascii "Timpani A#"                             ; FEF408  [ 12][ 46]
	.ascii "Timpani B "                             ; FEF412  [ 12][ 47]
	.ascii "Timpani c "                             ; FEF41C  [ 12][ 48]
	.ascii "Timpani c#"                             ; FEF426  [ 12][ 49]
	.ascii "Timpani d "                             ; FEF430  [ 12][ 50]
	.ascii "Timpani d#"                             ; FEF43A  [ 12][ 51]
	.ascii "Timpani e "                             ; FEF444  [ 12][ 52]
	.ascii "Timpani f "                             ; FEF44E  [ 12][ 53]
	.ascii "Tambourin "                             ; FEF458  [ 12][ 54]
	.ascii "Splash Cym"                             ; FEF462  [ 12][ 55]
	.ascii "Cowbell   "                             ; FEF46C  [ 12][ 56]
	.ascii "Orch.Cym 2"                             ; FEF476  [ 12][ 57]
	.ascii "Vibraslap "                             ; FEF480  [ 12][ 58]
	.ascii "Orch.Cym 1"                             ; FEF48A  [ 12][ 59]
	.ascii "Bongo High"                             ; FEF494  [ 12][ 60]
	.ascii "Bongo Low "                             ; FEF49E  [ 12][ 61]
	.ascii "CongaMutCr"                             ; FEF4A8  [ 12][ 62]
	.ascii "Conga High"                             ; FEF4B2  [ 12][ 63]
	.ascii "Conga Low "                             ; FEF4BC  [ 12][ 64]
	.ascii "Timbales H"                             ; FEF4C6  [ 12][ 65]
	.ascii "Timbales L"                             ; FEF4D0  [ 12][ 66]
	.ascii "Agogo High"                             ; FEF4DA  [ 12][ 67]
	.ascii "Agogo Low "                             ; FEF4E4  [ 12][ 68]
	.ascii "Cabasa    "                             ; FEF4EE  [ 12][ 69]
	.ascii "Maracas   "                             ; FEF4F8  [ 12][ 70]
	.ascii "SambaWhi S"                             ; FEF502  [ 12][ 71]
	.ascii "SambaWhi L"                             ; FEF50C  [ 12][ 72]
	.ascii "GuiroShort"                             ; FEF516  [ 12][ 73]
	.ascii "Guiro Long"                             ; FEF520  [ 12][ 74]
	.ascii "Claves    "                             ; FEF52A  [ 12][ 75]
	.ascii "Wood Blk M"                             ; FEF534  [ 12][ 76]
	.ascii "Wood Blk L"                             ; FEF53E  [ 12][ 77]
	.ascii "Cuica High"                             ; FEF548  [ 12][ 78]
	.ascii "Cuica Low "                             ; FEF552  [ 12][ 79]
	.ascii "Triangle M"                             ; FEF55C  [ 12][ 80]
	.ascii "Triangle O"                             ; FEF566  [ 12][ 81]
	.ascii "Shaker    "                             ; FEF570  [ 12][ 82]
	.ascii "SleighBell"                             ; FEF57A  [ 12][ 83]
	.ascii "WindChime "                             ; FEF584  [ 12][ 84]
	.ascii "Castanets "                             ; FEF58E  [ 12][ 85]
	.ascii "Surdo Mute"                             ; FEF598  [ 12][ 86]
	.ascii "Surdo Open"                             ; FEF5A2  [ 12][ 87]
	.ascii "Applause  "                             ; FEF5AC  [ 12][ 88]
	.ascii "          "                             ; FEF5B6  [ 12][ 89]
	.ascii "          "                             ; FEF5C0  [ 12][ 90]
	.ascii "          "                             ; FEF5CA  [ 12][ 91]
	.ascii "          "                             ; FEF5D4  [ 12][ 92]
	.ascii "          "                             ; FEF5DE  [ 12][ 93]
	.ascii "          "                             ; FEF5E8  [ 12][ 94]
	.ascii "          "                             ; FEF5F2  [ 12][ 95]
	.ascii "          "                             ; FEF5FC  [ 12][ 96]
	.ascii "          "                             ; FEF606  [ 12][ 97]
	.ascii "          "                             ; FEF610  [ 12][ 98]
	.ascii "          "                             ; FEF61A  [ 12][ 99]
	.ascii "          "                             ; FEF624  [ 12][100]
	.ascii "          "                             ; FEF62E  [ 12][101]
	.ascii "          "                             ; FEF638  [ 12][102]
	.ascii "          "                             ; FEF642  [ 12][103]
	.ascii "          "                             ; FEF64C  [ 12][104]
	.ascii "          "                             ; FEF656  [ 12][105]
	.ascii "          "                             ; FEF660  [ 12][106]
	.ascii "          "                             ; FEF66A  [ 12][107]
	.ascii "          "                             ; FEF674  [ 12][108]
	.ascii "          "                             ; FEF67E  [ 12][109]
	.ascii "          "                             ; FEF688  [ 12][110]
	.ascii "          "                             ; FEF692  [ 12][111]
	.ascii "          "                             ; FEF69C  [ 12][112]
	.ascii "          "                             ; FEF6A6  [ 12][113]
	.ascii "          "                             ; FEF6B0  [ 12][114]
	.ascii "          "                             ; FEF6BA  [ 12][115]
	.ascii "          "                             ; FEF6C4  [ 12][116]
	.ascii "          "                             ; FEF6CE  [ 12][117]
	.ascii "          "                             ; FEF6D8  [ 12][118]
	.ascii "          "                             ; FEF6E2  [ 12][119]
	.ascii "          "                             ; FEF6EC  [ 12][120]
	.ascii "          "                             ; FEF6F6  [ 12][121]
	.ascii "          "                             ; FEF700  [ 12][122]
	.ascii "          "                             ; FEF70A  [ 12][123]
	.ascii "          "                             ; FEF714  [ 12][124]
	.ascii "          "                             ; FEF71E  [ 12][125]
	.ascii "          "                             ; FEF728  [ 12][126]
	.ascii "          "                             ; FEF732  [ 12][127]
	.ascii "          "                             ; FEF73C  [ 12][128]

; ==============================================================================
; 0xFEF746-0xFF3800 -- the SCREEN-DRAW module: 56 inline DISPLAY LISTS,
; 13 tables, and 3,956 bytes of the code that runs them
; ==============================================================================
;
; Converted 2026-08-25 by notes/gen_prom_a_screens.py.  11,044 substantive bytes
; and a 5,526-byte 0x0E pad; it closes the LAST large `.incbin` in the upper half
; of prom_a.
;
; ★ WHY THIS SPAN COULD BE FRAMED AT ALL.  Almost every routine here is the same
;   four instructions:
;
;       ld (0x2540),<layer>          ; which display layer
;       ld XIY,<list start>
;       ld XIX,<list end>
;       call 0xF417F0                ; DisplayList_Run  (or 0xF417F4, the
;       ret                          ;                   second interpreter)
;       <the display list itself, inline, immediately after the `ret`>
;
;   so code and data alternate every few bytes and a linear decode is worthless.
;   But the call site names BOTH ENDS of every list in immediates, and a display
;   list is self-checking: each record is `+0 opcode, +1 LENGTH OF THE WHOLE
;   RECORD` and the interpreter advances by that byte
;   (notes/FINDINGS-ui-display-list.md).  So the split is read off the ROM:
;
;     TEST 1  walking the length bytes from <start> must land EXACTLY on <end>.
;             It does for 56 of 56 spans.  (prom_b's 244 spans came in at 243.)
;     TEST 2  with those 56 spans and the 13 tables below removed, a linear
;             disassembly of everything that is left produces ZERO undecodable
;             bytes.  Guess one table boundary wrong and the decode
;             desynchronises and prints `db`, so this test can fail.
;
;   Both are re-run by `python3 notes/gen_prom_a_screens.py --check`, which
;   REFUSES to emit the region if either fails.
;
; ★ WHAT THE SCREENS ARE.  The text is in the lists, so this module is where a
;   large part of the machine's UI vocabulary lives: SEQUENCER / REALTIME /
;   EDIT, MASTER / REC0RD (sic, with a zero) / TRACK / ASSIGN, STEP, MEDLEY,
;   S0NG (also with a zero) / SELECT, AFTER T0UCH, NOTE EDIT, DRUM EDIT,
;   KIT:, and two help panels that read "Press up/down button under screen
;   corresponding track that want edit."  The five biggest lists --
;   0xFF0E2B, 0xFF0F11, 0xFF10E0, 0xFF1332 and 0xFF158A, 230 to 600 bytes each
;   -- are whole screens; the 51 small ones are single boxes and rules.
;
; ★ TWENTY-TWO `bit 0,(0x601F70)` tests sit in this module -- the byte pattern
;   F2 70 1F 60 C8, counted over the span -- and most of them pick a different
;   display list either way; ScreenDrawPtrs_FEF9FA / ScreenDrawPtrs_FEFA2A are
;   two whole pointer tables selected by the same bit.  It switches the machine
;   between two screen layouts: EditScreen_Mode bit 0, 0 = NOTE EDIT and 1 =
;   DRUM EDIT (FINDINGS-prom_a-screen-module.md section 8, 2026-10-03).
;
; ⚠ WHAT IS NOT ESTABLISHED.  Which screen each list belongs to; what
;   (0x601F00), (0x601F3A), (0x601F53) and (0x601F75) are; and what
;   Data_FF17E2 is.  Every routine is `sub_XXXXXX` except the three that the
;   kit-category legend pins.
;
; The five `sub (addr),imm` instructions at 0xFF0162, 0xFF016E, 0xFF017B,
;   0xFF0181 and 0xFF01F5, emitted as `.byte` until 2026-10-03, are native
;   `subw` now (scripts/converters/respell_raw_pseudos.py --bytes; see
;   notes/llvm-mc-tlcs900-spellings.md).
sub_FEF746:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF746  f1 40 25 00 00
	calr EditScreen_ClearCurrentLayer                                      ; FEF74B  1e 13 00
	ret                                                  ; FEF74E  0e
; EditScreen_ClearLayer1: LCD_CurrentLayer := 1, then EditScreen_ClearCurrentLayer runs EditScreen_ClearCurrentLayer_DL: one op-0E record = SWI7
;   LCD_Svc_0E_ClearColumns with IY 0, BC 0x28, HL 0xF0 -- the whole 40 x 240 layer (same record as prom_b
;   LCD_ClearCurrentLayer). Its only call site, 0xFEF8BB, falls into EditScreen_PaintLayer1; nothing known references
;   that entry. Basis: call site + body + display list. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_ClearLayer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEF74F  f1 40 25 00 01
	calr EditScreen_ClearCurrentLayer                                      ; FEF754  1e 0a 00
	ret                                                  ; FEF757  0e
; EditScreen_ClearLayer2: LCD_CurrentLayer := 2, then EditScreen_ClearCurrentLayer's single op-0E record (LCD_Svc_0E_ClearColumns, 40
;   columns x 240 rows): clears the whole layer 2. Its only call site, 0xFEF8C7, falls into EditScreen_PaintLayer2;
;   nothing known references that entry. Basis: call site + body + display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
EditScreen_ClearLayer2:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FEF758  f1 40 25 00 02
	calr EditScreen_ClearCurrentLayer                                      ; FEF75D  1e 01 00
	ret                                                  ; FEF760  0e
; EditScreen_ClearCurrentLayer -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFEF76B  interpreter A  list 0xFEF770-0xFEF778
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_ClearCurrentLayer: Runs EditScreen_ClearCurrentLayer_DL, one op-0E record (IY 0, BC 0x28, HL 0xF0: SWI7
;   LCD_Svc_0E_ClearColumns over 40 columns x 240 rows), so it clears LCD_CurrentLayer. EditScreen_ClearLayer1 /
;   _ClearLayer2 (and sub_FEF746, layer 0) set the layer first; the edit-screen module's own copy of prom_b
;   LCD_ClearCurrentLayer (same record, DL_F39551). Basis: callers + body + display list + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
EditScreen_ClearCurrentLayer:
	ld XIY,EditScreen_ClearCurrentLayer_DL                            ; FEF761  45 70 f7 fe 00
	ld XIX,EditScreen_EraseFieldRow                                    ; FEF766  44 78 f7 fe 00
	call T_DisplayList_Run                               ; FEF76B  1d f0 17 f4
	ret                                                  ; FEF76F  0e

; EditScreen_ClearCurrentLayer_DL -- 1 record(s), 8 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF770 and land exactly on 0xFEF778.
EditScreen_ClearCurrentLayer_DL:
; ; drawn (start operand) by EditScreen_ClearCurrentLayer -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_clear_area	x=0, y=0, w=320, h=240
; EditScreen_EraseFieldRow -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF787  interpreter A  list 0xFEF78C-0xFEF796
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseFieldRow: layer 0, EditScreen_EraseFieldRow_DL: EraseRect (8, 0xB2)-(0xE8, 0xC0), the value row at the bottom.
EditScreen_EraseFieldRow:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF778  f1 40 25 00 00
	ld XIY,EditScreen_EraseFieldRow_DL                                    ; FEF77D  45 8c f7 fe 00
	ld XIX,EditScreen_EraseMarkerStrip                                    ; FEF782  44 96 f7 fe 00
	call T_DisplayList_Run                               ; FEF787  1d f0 17 f4
	ret                                                  ; FEF78B  0e

; EditScreen_EraseFieldRow_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF78C and land exactly on 0xFEF796.
EditScreen_EraseFieldRow_DL:
; ; drawn (start operand) by EditScreen_EraseFieldRow -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=8, y0=178, x1=232, y1=192
; EditScreen_EraseMarkerStrip -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF7A5  interpreter A  list 0xFEF7AA-0xFEF7B4
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseMarkerStrip: layer 1, EditScreen_EraseMarkerStrip_DL: EraseRect (0, 0x21)-(0x108, 0x27), the strip the cursor tick marker (y 0x22) and
;   the data-end marker (y 0x21) are drawn in.
EditScreen_EraseMarkerStrip:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEF796  f1 40 25 00 01
	ld XIY,EditScreen_EraseMarkerStrip_DL                                    ; FEF79B  45 aa f7 fe 00
	ld XIX,EditScreen_EraseHeaderRow                                    ; FEF7A0  44 b4 f7 fe 00
	call T_DisplayList_Run                               ; FEF7A5  1d f0 17 f4
	ret                                                  ; FEF7A9  0e

; EditScreen_EraseMarkerStrip_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF7AA and land exactly on 0xFEF7B4.
EditScreen_EraseMarkerStrip_DL:
; ; drawn (start operand) by EditScreen_EraseMarkerStrip -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=0, y0=33, x1=264, y1=39
; EditScreen_EraseHeaderRow -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF7C3  interpreter A  list 0xFEF7C8-0xFEF7D2
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseHeaderRow: layer 0, EditScreen_EraseHeaderRow_DL: EraseRect (0, 0x14)-(0x108, 0x1F), the beat-number row (y 0x18).
EditScreen_EraseHeaderRow:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF7B4  f1 40 25 00 00
	ld XIY,EditScreen_EraseHeaderRow_DL                            ; FEF7B9  45 c8 f7 fe 00
	ld XIX,EditScreen_EraseEditArea_Layer0                                    ; FEF7BE  44 d2 f7 fe 00
	call T_DisplayList_Run                               ; FEF7C3  1d f0 17 f4
	ret                                                  ; FEF7C7  0e

; EditScreen_EraseHeaderRow_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF7C8 and land exactly on 0xFEF7D2.
EditScreen_EraseHeaderRow_DL:
; ; drawn (start operand) by EditScreen_EraseHeaderRow -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=0, y0=20, x1=264, y1=31
; EditScreen_EraseEditArea_Layer0: EditScreen_Mode bit 0 (DRUM EDIT) -> DrumEdit_EraseEditArea_Layer0, else NoteEdit_EraseEditArea_Layer0.  22 call sites.
EditScreen_EraseEditArea_Layer0:
	bit	0, (EditScreen_Mode:24)                             ; FEF7D2  f2 70 1f 60 c8
	jr z, .LFEF7DD                                       ; FEF7D7  66 04
	calr DrumEdit_EraseEditArea_Layer0                                            ; FEF7D9  1e 23 00
	ret                                                  ; FEF7DC  0e
.LFEF7DD:
	calr NoteEdit_EraseEditArea_Layer0                                      ; FEF7DD  1e 01 00
	ret                                                  ; FEF7E0  0e
; NoteEdit_EraseEditArea_Layer0: LCD_CurrentLayer = 0, then falls into NoteEdit_EraseEditArea.
NoteEdit_EraseEditArea_Layer0:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF7E1  f1 40 25 00 00
; NoteEdit_EraseEditArea -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFEF7F0  interpreter A  list 0xFEF7F5-0xFEF7FF
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; NoteEdit_EraseEditArea: runs NoteEdit_EraseEditArea_DL, one op-0x1B record: LCD_Svc_1B_EraseRect (0x10, 0x29)-(0x102, 0xAE).
NoteEdit_EraseEditArea:
	ld XIY,NoteEdit_EraseEditArea_DL                            ; FEF7E6  45 f5 f7 fe 00
	ld XIX,DrumEdit_EraseEditArea_Layer0                                    ; FEF7EB  44 ff f7 fe 00
	call T_DisplayList_Run                               ; FEF7F0  1d f0 17 f4
	ret                                                  ; FEF7F4  0e

; NoteEdit_EraseEditArea_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF7F5 and land exactly on 0xFEF7FF.
NoteEdit_EraseEditArea_DL:
; ; drawn (start operand) by NoteEdit_EraseEditArea -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=16, y0=41, x1=258, y1=174
; DrumEdit_EraseEditArea_Layer0: LCD_CurrentLayer = 0, then falls into DrumEdit_EraseEditArea.
DrumEdit_EraseEditArea_Layer0:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF7FF  f1 40 25 00 00
; DrumEdit_EraseEditArea -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 4
; instructions to its first `ret`:
;     site 0xFEF80E  interpreter A  list 0xFEF813-0xFEF81D
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_EraseEditArea: runs DrumEdit_EraseEditArea_DL: LCD_Svc_1B_EraseRect (0x58, 0x29)-(0x102, 0xAE): NOTE EDIT's area
;   from x = 0x58.
DrumEdit_EraseEditArea:
	ld XIY,DrumEdit_EraseEditArea_DL                                    ; FEF804  45 13 f8 fe 00
	ld XIX,EditScreen_EraseVelocityCell                                    ; FEF809  44 1d f8 fe 00
	call T_DisplayList_Run                               ; FEF80E  1d f0 17 f4
	ret                                                  ; FEF812  0e

; DrumEdit_EraseEditArea_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF813 and land exactly on 0xFEF81D.
DrumEdit_EraseEditArea_DL:
; ; drawn (start operand) by DrumEdit_EraseEditArea -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=88, y0=41, x1=258, y1=174
; EditScreen_EraseVelocityCell -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF82C  interpreter A  list 0xFEF831-0xFEF83B
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseVelocityCell: Layer 0, EditScreen_EraseVelocityCell_DL: EraseRect (0x78, 0xB2)-(0x80, 0xC0), the cell the
;   velocity value is then drawn into; the velocity twin of EditScreen_EraseLengthCell ((0xA0, 0xB2)-(0xC8, 0xC0)).
;   Called by EditScreen_DrawEventVelocity's shared tail (DrumEdit_EraseEditArea only names its address as a display-
;   list XIX operand). Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
EditScreen_EraseVelocityCell:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF81D  f1 40 25 00 00
	ld XIY,EditScreen_EraseVelocityCell_DL                                    ; FEF822  45 31 f8 fe 00
	ld XIX,EditScreen_EraseLengthCell                                    ; FEF827  44 3b f8 fe 00
	call T_DisplayList_Run                               ; FEF82C  1d f0 17 f4
	ret                                                  ; FEF830  0e

; EditScreen_EraseVelocityCell_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF831 and land exactly on 0xFEF83B.
EditScreen_EraseVelocityCell_DL:
; drawn (start operand) by EditScreen_EraseVelocityCell -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=120, y0=178, x1=128, y1=192
; EditScreen_EraseLengthCell -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF84A  interpreter A  list 0xFEF84F-0xFEF859
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseLengthCell: layer 0, EditScreen_EraseLengthCell_DL: EraseRect (0xA0, 0xB2)-(0xC8, 0xC0).  Called by EditScreen_DrawEventLength /
;   _DrawNewNoteLength.
EditScreen_EraseLengthCell:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF83B  f1 40 25 00 00
	ld XIY,EditScreen_EraseLengthCell_DL                                    ; FEF840  45 4f f8 fe 00
	ld XIX,EditScreen_EraseEditArea_Layer1                                    ; FEF845  44 59 f8 fe 00
	call T_DisplayList_Run                               ; FEF84A  1d f0 17 f4
	ret                                                  ; FEF84E  0e

; EditScreen_EraseLengthCell_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF84F and land exactly on 0xFEF859.
EditScreen_EraseLengthCell_DL:
; ; drawn (start operand) by EditScreen_EraseLengthCell -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=160, y0=178, x1=200, y1=192
; EditScreen_EraseEditArea_Layer1: LCD_CurrentLayer = 1, then by EditScreen_Mode bit 0 DrumEdit_ or NoteEdit_EraseEditArea.
EditScreen_EraseEditArea_Layer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEF859  f1 40 25 00 01
	bit	0, (EditScreen_Mode:24)                             ; FEF85E  f2 70 1f 60 c8
	jr z, .LFEF869                                       ; FEF863  66 04
	calr DrumEdit_EraseEditArea                                          ; FEF865  1e 9c ff
	ret                                                  ; FEF868  0e
.LFEF869:
	calr NoteEdit_EraseEditArea                                          ; FEF869  1e 7a ff
	ret                                                  ; FEF86C  0e
; EditScreen_EraseLeftColumn_Layer1 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 5
; instructions to its first `ret`:
;     site 0xFEF87C  interpreter A  list 0xFEF881-0xFEF88B
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_EraseLeftColumn_Layer1: layer 1, EditScreen_EraseLeftColumn_Layer1_DL: LCD_Svc_1B_EraseRect (0, 0x2A)-(0x16, 0xA3) -- the twelve rows' column.  Called by
;   NoteEdit_DrawKeyboardRuler and the column redraws.
EditScreen_EraseLeftColumn_Layer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEF86D  f1 40 25 00 01
	ld XIY,EditScreen_EraseLeftColumn_Layer1_DL                            ; FEF872  45 81 f8 fe 00
	ld XIX,EditScreen_EraseRowLabelArea                                    ; FEF877  44 8b f8 fe 00
	call T_DisplayList_Run                               ; FEF87C  1d f0 17 f4
	ret                                                  ; FEF880  0e

; EditScreen_EraseLeftColumn_Layer1_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF881 and land exactly on 0xFEF88B.
EditScreen_EraseLeftColumn_Layer1_DL:
; ; drawn (start operand) by EditScreen_EraseLeftColumn_Layer1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=0, y0=42, x1=22, y1=163
; EditScreen_EraseRowLabelArea: layer 0, EditScreen_EraseRowLabelArea_DL: EraseRect (0, 0x29)-(0x58, 0xA3), the left area DrumEdit_RedrawRowList redraws.
EditScreen_EraseRowLabelArea:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF88B  f1 40 25 00 00
	ld XIY,EditScreen_EraseRowLabelArea_DL                            ; FEF890  45 9f f8 fe 00
	ld XIX,sub_FEF8A9                                    ; FEF895  44 a9 f8 fe 00
; DisplayList_Run_Call -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 2
; instructions to its first `ret`:
;     site 0xFEF89A  interpreter A  list 0xFEF89F-0xFEF8A9
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
DisplayList_Run_Call:
	call T_DisplayList_Run                               ; FEF89A  1d f0 17 f4
	ret                                                  ; FEF89E  0e

; EditScreen_EraseRowLabelArea_DL -- 1 record(s), 10 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFEF89F and land exactly on 0xFEF8A9.
EditScreen_EraseRowLabelArea_DL:
; ; drawn (start operand) by EditScreen_EraseRowLabelArea -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=0, y0=41, x1=88, y1=163
sub_FEF8A9:   ; entry: named by 1 `ld` operand, first at 0xFEF895
	calr sub_FEF746                                          ; FEF8A9  1e 9a fe
; EditScreen_PaintLayer0: layer 0: EditScreen_DrawFields, EditScreen_DrawVisibleNotes, EditScreen_DrawHeaderAndGrid.  Called by
;   EditScreen_EnterNoteEdit.
EditScreen_PaintLayer0:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF8AC  f1 40 25 00 00
	calr EditScreen_DrawFields                                      ; FEF8B1  1e 22 00
	calr EditScreen_DrawVisibleNotes                                          ; FEF8B4  1e 08 06
	calr EditScreen_DrawHeaderAndGrid                                      ; FEF8B7  1e 6c 00
	ret                                                  ; FEF8BA  0e
	calr EditScreen_ClearLayer1                                          ; FEF8BB  1e 91 fe
; EditScreen_PaintLayer1: layer 1: EditScreen_RedrawCursorLayer.
EditScreen_PaintLayer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEF8BE  f1 40 25 00 01
	calr EditScreen_RedrawCursorLayer                                          ; FEF8C3  1e c4 04
	ret                                                  ; FEF8C6  0e
	calr EditScreen_ClearLayer2                                          ; FEF8C7  1e 8e fe
; EditScreen_PaintLayer2: layer 2: EditScreen_PaintStaticLayer, EditScreen_DrawRulersAndLegend.
EditScreen_PaintLayer2:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FEF8CA  f1 40 25 00 02
	calr EditScreen_PaintStaticLayer                                          ; FEF8CF  1e 4d 0a
	calr EditScreen_DrawRulersAndLegend                                          ; FEF8D2  1e de 0a
	ret                                                  ; FEF8D5  0e
; EditScreen_DrawFields: DrumEdit_DrawFields in DRUM EDIT, NoteEdit_DrawFields in NOTE EDIT.
EditScreen_DrawFields:
	bit	0, (EditScreen_Mode:24)                             ; FEF8D6  f2 70 1f 60 c8
	jr z, .LFEF8E1                                       ; FEF8DB  66 04
	calr DrumEdit_DrawFields                                      ; FEF8DD  1e 27 00
	ret                                                  ; FEF8E0  0e
.LFEF8E1:
	calr NoteEdit_DrawFields                                      ; FEF8E1  1e 01 00
	ret                                                  ; FEF8E4  0e
; NoteEdit_DrawFields: with an event selected: EditScreen_DrawCursorNote, _DrawEventVelocity, _DrawEventLength; otherwise
;   _DrawNewNoteLength; then EditScreen_DrawMeasure, _DrawBeat, _DrawTick, _DrawInc.
NoteEdit_DrawFields:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEF8E5  f2 5b 1f 60 c8
	jr z, .LFEF8F7                                       ; FEF8EA  66 0b
	calr EditScreen_DrawCursorNote                                          ; FEF8EC  1e 8c 11
	calr EditScreen_DrawEventVelocity                                          ; FEF8EF  1e 54 12
	calr EditScreen_DrawEventLength                                      ; FEF8F2  1e fc 12
	jr .LFEF8FA                                          ; FEF8F5  68 03
.LFEF8F7:
	calr EditScreen_DrawNewNoteLength                                          ; FEF8F7  1e 18 13
.LFEF8FA:
	calr EditScreen_DrawMeasure                                          ; FEF8FA  1e 8c 10
	calr EditScreen_DrawBeat                                          ; FEF8FD  1e 04 11
	calr EditScreen_DrawTick                                          ; FEF900  1e 4f 11
	calr EditScreen_DrawInc                                          ; FEF903  1e fd 13
	ret                                                  ; FEF906  0e
; DrumEdit_DrawFields: with an event selected: EditScreen_DrawCursorNote, _DrawEventVelocity; otherwise _DrawNewNoteVelocity; then
;   MEAS / beat / tick and INC.
DrumEdit_DrawFields:
	bit	0, (EditScreen_CursorFlags:24)                             ; FEF907  f2 5b 1f 60 c8
	jr z, .LFEF916                                       ; FEF90C  66 08
	calr EditScreen_DrawCursorNote                                          ; FEF90E  1e 6a 11
	calr EditScreen_DrawEventVelocity                                          ; FEF911  1e 32 12
	jr .LFEF919                                          ; FEF914  68 03
.LFEF916:
	calr EditScreen_DrawNewNoteVelocity                                          ; FEF916  1e 21 12
.LFEF919:
	calr EditScreen_DrawMeasure                                          ; FEF919  1e 6d 10
	calr EditScreen_DrawBeat                                          ; FEF91C  1e e5 10
	calr EditScreen_DrawTick                                          ; FEF91F  1e 30 11
	calr EditScreen_DrawInc                                          ; FEF922  1e de 13
	ret                                                  ; FEF925  0e
; EditScreen_DrawHeaderAndGrid: layer 0: EditScreen_DrawBeatNumbers, EditScreen_DrawMeasureNumbers, EditScreen_DrawGridLines,
;   EditScreen_DrawMeasureStartLines.
EditScreen_DrawHeaderAndGrid:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF926  f1 40 25 00 00
	calr EditScreen_DrawBeatNumbers                                      ; FEF92B  1e 0a 00
	calr EditScreen_DrawMeasureNumbers                                            ; FEF92E  1e 75 00
	calr EditScreen_DrawGridLines                                          ; FEF931  1e 0d 0f
	calr EditScreen_DrawMeasureStartLines                                          ; FEF934  1e 8e 0e
	ret                                                  ; FEF937  0e
; EditScreen_DrawBeatNumbers: layer 0, row y 0x18: at each beat column that is not a measure start (EditScreen_BeatTable entry 0) the
;   beat's number within its measure (Digits_FEF999, restarting at 1 after each start), x = 24 x column + 0x0D
;   (NOTE) or 0x55 (DRUM).
EditScreen_DrawBeatNumbers:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF938  f1 40 25 00 00
	ld XIX,EditScreen_BeatTable                                    ; FEF93D  44 5f 1f 60 00
	xor E,E                                              ; FEF942  cd d5
.LFEF944:
	ld A,(XIX)                                           ; FEF944  84 21
	cp a, 0x00:i3                                          ; FEF946  c9 d8
	jr nz, .LFEF94C                                      ; FEF948  6e 02
	jr .LFEF951                                          ; FEF94A  68 05
.LFEF94C:
	ldw hl, 0x01                                         ; FEF94C  33 01 00
	jr .LFEF984                                          ; FEF94F  68 33
.LFEF951:
	xor WA,WA                                            ; FEF951  d8 d0
	ld A,E                                               ; FEF953  cd 89
	mul A,0x18                                           ; FEF955  c9 08 18
	bit	0, (EditScreen_Mode:24)                             ; FEF958  f2 70 1f 60 c8
	jr z, .LFEF965                                       ; FEF95D  66 06
	add WA,0x0055                                        ; FEF95F  d8 c8 55 00
	jr .LFEF969                                          ; FEF963  68 04
.LFEF965:
	add WA,0x000d                                        ; FEF965  d8 c8 0d 00
.LFEF969:
	ld (LCD_X0:16), wa                                  ; FEF969  f1 30 25 50
	ldw (LCD_Y0:16), 0x18                                ; FEF96D  f1 32 25 02 18 00
	ld XIY,Digits_FEF999                                 ; FEF973  45 99 f9 fe 00
	ldw bc, 0x01                                         ; FEF978  31 01 00
	ld a, 0x17:opc                                          ; FEF97B  21 17
	pushw hl                                             ; FEF97D  2b
	pushw de                                             ; FEF97E  2a
	push XIX                                             ; FEF97F  3c
	swi 7                                                ; FEF980  ff
	pop XIX                                              ; FEF981  5c
	popw de                                              ; FEF982  4a
	popw hl                                              ; FEF983  4b
.LFEF984:
	add HL,0x0001                                        ; FEF984  db c8 01 00
	add E,0x01                                           ; FEF988  cd c8 01
	add XIX,0x00000001                                   ; FEF98B  ec c8 01 00 00 00
	cp	e, (EditMeasure_Beats:24)                             ; FEF991  c2 75 1f 60 f5
	jr ule, .LFEF944                                     ; FEF996  63 ac
	ret                                                  ; FEF998  0e
; ---------------------------------------------------------------------
; Digits_FEF999 -- 13 single characters, "0123456789" then three '*'
; Read by: 0xFEF973 `ld XIY,0x00FEF999`, then `ld BC,0x0001` and SWI7
;          service 0x17 at 0xFEF980 -- BC is the WIDTH, so the entry
;          stride is 1 and HL, incremented at 0xFEF984, is the index.
; ENTRY COUNT 13 is the extent: code resumes at 0xFEF9A6 and a linear
;          decode from there is clean to the next table.
; Unknown: what the three '*' entries stand for.
; ---------------------------------------------------------------------

Digits_FEF999:
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x2a, 0x2a, 0x2a  ; FEF999
; EditScreen_DrawMeasureNumbers: for E = 0..(0x601F75) and each non-zero beat count at 0x601F5F[E], draws
;   measure number BC (from (0x601F5D), +1 each) through ScreenDrawPtrs_FEF9FA[E] (NOTE EDIT) or _FEFA2A[E]
;   (DRUM EDIT, EditScreen_Mode bit 0).
EditScreen_DrawMeasureNumbers:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEF9A6  f1 40 25 00 00
	ld XIX,EditScreen_BeatTable                                    ; FEF9AB  44 5f 1f 60 00
	xor E,E                                              ; FEF9B0  cd d5
	ld bc, (EditScreen_FirstMeasure:24)                                ; FEF9B2  d2 5d 1f 60 21
.LFEF9B7:
	ld A,(XIX)                                           ; FEF9B7  84 21
	cp a, 0x00:i3                                          ; FEF9B9  c9 d8
	jr z, .LFEF9E9                                       ; FEF9BB  66 2c
	ld XIY,ScreenDrawPtrs_FEF9FA                         ; FEF9BD  45 fa f9 fe 00
	bit	0, (EditScreen_Mode:24)                             ; FEF9C2  f2 70 1f 60 c8
	jr z, .LFEF9CE                                       ; FEF9C7  66 05
	ld XIY,ScreenDrawPtrs_FEFA2A                         ; FEF9C9  45 2a fa fe 00
.LFEF9CE:
	xor XWA,XWA                                          ; FEF9CE  e8 d0
	ld A,E                                               ; FEF9D0  cd 89
	sll xwa, 0x02                                        ; FEF9D2  e8 ee 02
	add XIY,XWA                                          ; FEF9D5  e8 85
	ld XIY,(XIY)                                         ; FEF9D7  a5 25
	ld (0x26b0:16), bc                                  ; FEF9D9  f1 b0 26 51
	pushw bc                                             ; FEF9DD  29
	pushw de                                             ; FEF9DE  2a
	push XIX                                             ; FEF9DF  3c
	call (xiy)                                           ; FEF9E0  b5 e8
	pop XIX                                              ; FEF9E2  5c
	popw de                                              ; FEF9E3  4a
	popw bc                                              ; FEF9E4  49
	add BC,0x0001                                        ; FEF9E5  d9 c8 01 00
.LFEF9E9:
	add E,0x01                                           ; FEF9E9  cd c8 01
	add XIX,0x00000001                                   ; FEF9EC  ec c8 01 00 00 00
	cp	e, (EditMeasure_Beats:24)                             ; FEF9F2  c2 75 1f 60 f5
	jr ule, .LFEF9B7                                     ; FEF9F7  63 be
	ret                                                  ; FEF9F9  0e
; ---------------------------------------------------------------------
; ScreenDrawPtrs_FEF9FA -- 12 pointers to screen-drawing routines
; Read by: 0xFEF9BD `ld XIY,0x00FEF9FA`, then `XWA = E; XWA <<= 2;
;          XIY += XWA; XIY = (XIY); call T,XIY` at 0xFEF9D0-0xFEF9E0.
;          E is bounded against (0x601F75) at 0xFEF9F2.
; ENTRY COUNT 12 is the extent between this base and the sibling table
;          the other arm loads, 0xFEFA2A.  LAST-ENTRY TEST: entry 11 is
;          0x00FEFA4E, the same routine as entry 0, and 0xFEFA4E is where
;          code resumes after the sibling table -- so the array stops
;          exactly where the next object starts.
; Evidence: all 12 values are inside this module.
; ---------------------------------------------------------------------

ScreenDrawPtrs_FEF9FA:
	.long EditScreen_MeasureNumberAt0                                 ; FEF9FA  [  0]
	.long EditScreen_MeasureNumberAt1                                 ; FEF9FE  [  1]
	.long EditScreen_MeasureNumberAt2                                 ; FEFA02  [  2]
	.long EditScreen_MeasureNumberAt3                                 ; FEFA06  [  3]
	.long EditScreen_MeasureNumberAt5                                 ; FEFA0A  [  4]
	.long EditScreen_MeasureNumberAt6                                 ; FEFA0E  [  5]
	.long EditScreen_MeasureNumberAt7                                 ; FEFA12  [  6]
	.long EditScreen_MeasureNumberAt8                                 ; FEFA16  [  7]
	.long EditScreen_MeasureNumberAt9                                 ; FEFA1A  [  8]
	.long EditScreen_MeasureNumberAt10                                 ; FEFA1E  [  9]
	.long EditScreen_MeasureNumberAt11                                 ; FEFA22  [ 10]
	.long EditScreen_MeasureNumberAt0                                 ; FEFA26  [ 11]
; ---------------------------------------------------------------------
; ScreenDrawPtrs_FEFA2A -- 9 pointers, the other arm of the same read
; Called from: 0xFEF9C9 `ld XIY,0x00FEFA2A`, taken when bit 0 of
;          (0x601F70) is SET (tested at 0xFEF9C2).  The 0xFEF9FA table is
;          the clear arm.  So (0x601F70) bit 0 picks between two screen
;          layouts -- the same bit the whole module tests, 20 times.
; ENTRY COUNT 9 is the extent: 0xFEFA4E is an instruction boundary and
;          is itself entry 8 of this table and entry 0 of the other.
; ---------------------------------------------------------------------

ScreenDrawPtrs_FEFA2A:
	.long EditScreen_MeasureNumberAt4                                 ; FEFA2A  [  0]
	.long EditScreen_MeasureNumberAt5                                 ; FEFA2E  [  1]
	.long EditScreen_MeasureNumberAt6                                 ; FEFA32  [  2]
	.long EditScreen_MeasureNumberAt7                                 ; FEFA36  [  3]
	.long EditScreen_MeasureNumberAt8                                 ; FEFA3A  [  4]
	.long EditScreen_MeasureNumberAt9                                 ; FEFA3E  [  5]
	.long EditScreen_MeasureNumberAt10                                 ; FEFA42  [  6]
	.long EditScreen_MeasureNumberAt11                                 ; FEFA46  [  7]
	.long EditScreen_MeasureNumberAt0                                 ; FEFA4A  [  8]
; EditScreen_MeasureNumberAt0: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 0 of 12 in address order; NOTE EDIT slot 0, NOTE EDIT slot 11, DRUM EDIT slot 8 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt0:   ; entry: named by 3 `.long` operands, first at 0xFEF9FA
	cpw	(0x26b0:16), 0x03e7                          ; FEFA4E  d1 b0 26 3f e7 03
	jr ule, .LFEFA6B                                     ; FEFA54  63 15
	ldw (0x26b0:16), 0x00                                ; FEFA56  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt0_DL1                            ; FEFA5C  45 7a fa fe 00
	ld XIX,EditScreen_MeasureNumberAt0_DL2                            ; FEFA61  44 89 fa fe 00
	call T_DisplayListB_Run                              ; FEFA66  1d f4 17 f4
	ret                                                  ; FEFA6A  0e
.LFEFA6B:
	ld XIY,EditScreen_MeasureNumberAt0_DL2                            ; FEFA6B  45 89 fa fe 00
	ld XIX,EditScreen_MeasureNumberAt1                                    ; FEFA70  44 93 fa fe 00
	call T_DisplayListB_Run                              ; FEFA75  1d f4 17 f4
	ret                                                  ; FEFA79  0e

; EditScreen_MeasureNumberAt0_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFA7A and land exactly on 0xFEFA89.
EditScreen_MeasureNumberAt0_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt0 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=3, x=0, y=20

; EditScreen_MeasureNumberAt0_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFA89 and land exactly on 0xFEFA93.
EditScreen_MeasureNumberAt0_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt0 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=0, y=20, digits=3
; EditScreen_MeasureNumberAt1: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 1 of 12 in address order; NOTE EDIT slot 1 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt1:   ; entry: named by 2 `.long`/`ld` operands, first at 0xFEF9FE
	cpw	(0x26b0:16), 0x03e7                          ; FEFA93  d1 b0 26 3f e7 03
	jr ule, .LFEFAB0                                     ; FEFA99  63 15
	ldw (0x26b0:16), 0x00                                ; FEFA9B  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt1_DL1                            ; FEFAA1  45 bf fa fe 00
	ld XIX,EditScreen_MeasureNumberAt1_DL2                            ; FEFAA6  44 ce fa fe 00
	call T_DisplayListB_Run                              ; FEFAAB  1d f4 17 f4
	ret                                                  ; FEFAAF  0e
.LFEFAB0:
	ld XIY,EditScreen_MeasureNumberAt1_DL2                            ; FEFAB0  45 ce fa fe 00
	ld XIX,EditScreen_MeasureNumberAt2                                    ; FEFAB5  44 d8 fa fe 00
	call T_DisplayListB_Run                              ; FEFABA  1d f4 17 f4
	ret                                                  ; FEFABE  0e

; EditScreen_MeasureNumberAt1_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFABF and land exactly on 0xFEFACE.
EditScreen_MeasureNumberAt1_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=32, y=20

; EditScreen_MeasureNumberAt1_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFACE and land exactly on 0xFEFAD8.
EditScreen_MeasureNumberAt1_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt1 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=32, y=20, digits=2
; EditScreen_MeasureNumberAt2: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 2 of 12 in address order; NOTE EDIT slot 2 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt2:   ; entry: named by 2 `.long`/`ld` operands, first at 0xFEFA02
	cpw	(0x26b0:16), 0x03e7                          ; FEFAD8  d1 b0 26 3f e7 03
	jr ule, .LFEFAF5                                     ; FEFADE  63 15
	ldw (0x26b0:16), 0x00                                ; FEFAE0  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt2_DL1                            ; FEFAE6  45 04 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt2_DL2                            ; FEFAEB  44 13 fb fe 00
	call T_DisplayListB_Run                              ; FEFAF0  1d f4 17 f4
	ret                                                  ; FEFAF4  0e
.LFEFAF5:
	ld XIY,EditScreen_MeasureNumberAt2_DL2                            ; FEFAF5  45 13 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt3                                    ; FEFAFA  44 1d fb fe 00
	call T_DisplayListB_Run                              ; FEFAFF  1d f4 17 f4
	ret                                                  ; FEFB03  0e

; EditScreen_MeasureNumberAt2_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB04 and land exactly on 0xFEFB13.
EditScreen_MeasureNumberAt2_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=56, y=20

; EditScreen_MeasureNumberAt2_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB13 and land exactly on 0xFEFB1D.
EditScreen_MeasureNumberAt2_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt2 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=56, y=20, digits=2
; EditScreen_MeasureNumberAt3: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 3 of 12 in address order; NOTE EDIT slot 3 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt3:   ; entry: named by 2 `.long`/`ld` operands, first at 0xFEFA06
	cpw	(0x26b0:16), 0x03e7                          ; FEFB1D  d1 b0 26 3f e7 03
	jr ule, .LFEFB3A                                     ; FEFB23  63 15
	ldw (0x26b0:16), 0x00                                ; FEFB25  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt3_DL1                            ; FEFB2B  45 49 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt3_DL2                            ; FEFB30  44 58 fb fe 00
	call T_DisplayListB_Run                              ; FEFB35  1d f4 17 f4
	ret                                                  ; FEFB39  0e
.LFEFB3A:
	ld XIY,EditScreen_MeasureNumberAt3_DL2                            ; FEFB3A  45 58 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt4                                    ; FEFB3F  44 62 fb fe 00
	call T_DisplayListB_Run                              ; FEFB44  1d f4 17 f4
	ret                                                  ; FEFB48  0e

; EditScreen_MeasureNumberAt3_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB49 and land exactly on 0xFEFB58.
EditScreen_MeasureNumberAt3_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt3 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=80, y=20

; EditScreen_MeasureNumberAt3_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB58 and land exactly on 0xFEFB62.
EditScreen_MeasureNumberAt3_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt3 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=20, digits=2
; EditScreen_MeasureNumberAt4: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 4 of 12 in address order; DRUM EDIT slot 0 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt4:   ; entry: named by 2 `.long`/`ld` operands, first at 0xFEFA2A
	cpw	(0x26b0:16), 0x03e7                          ; FEFB62  d1 b0 26 3f e7 03
	jr ule, .LFEFB7F                                     ; FEFB68  63 15
	ldw (0x26b0:16), 0x00                                ; FEFB6A  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt4_DL1                            ; FEFB70  45 8e fb fe 00
	ld XIX,EditScreen_MeasureNumberAt4_DL2                            ; FEFB75  44 9d fb fe 00
	call T_DisplayListB_Run                              ; FEFB7A  1d f4 17 f4
	ret                                                  ; FEFB7E  0e
.LFEFB7F:
	ld XIY,EditScreen_MeasureNumberAt4_DL2                            ; FEFB7F  45 9d fb fe 00
	ld XIX,EditScreen_MeasureNumberAt5                                    ; FEFB84  44 a7 fb fe 00
	call T_DisplayListB_Run                              ; FEFB89  1d f4 17 f4
	ret                                                  ; FEFB8D  0e

; EditScreen_MeasureNumberAt4_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB8E and land exactly on 0xFEFB9D.
EditScreen_MeasureNumberAt4_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt4 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=3, x=72, y=20

; EditScreen_MeasureNumberAt4_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFB9D and land exactly on 0xFEFBA7.
EditScreen_MeasureNumberAt4_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt4 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=72, y=20, digits=3
; EditScreen_MeasureNumberAt5: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 5 of 12 in address order; NOTE EDIT slot 4, DRUM EDIT slot 1 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt5:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA0A
	cpw	(0x26b0:16), 0x03e7                          ; FEFBA7  d1 b0 26 3f e7 03
	jr ule, .LFEFBC4                                     ; FEFBAD  63 15
	ldw (0x26b0:16), 0x00                                ; FEFBAF  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt5_DL1                            ; FEFBB5  45 d3 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt5_DL2                            ; FEFBBA  44 e2 fb fe 00
	call T_DisplayListB_Run                              ; FEFBBF  1d f4 17 f4
	ret                                                  ; FEFBC3  0e
.LFEFBC4:
	ld XIY,EditScreen_MeasureNumberAt5_DL2                            ; FEFBC4  45 e2 fb fe 00
	ld XIX,EditScreen_MeasureNumberAt6                                    ; FEFBC9  44 ec fb fe 00
	call T_DisplayListB_Run                              ; FEFBCE  1d f4 17 f4
	ret                                                  ; FEFBD2  0e

; EditScreen_MeasureNumberAt5_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFBD3 and land exactly on 0xFEFBE2.
EditScreen_MeasureNumberAt5_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt5 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=104, y=20

; EditScreen_MeasureNumberAt5_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFBE2 and land exactly on 0xFEFBEC.
EditScreen_MeasureNumberAt5_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt5 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=104, y=20, digits=2
; EditScreen_MeasureNumberAt6: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 6 of 12 in address order; NOTE EDIT slot 5, DRUM EDIT slot 2 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt6:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA0E
	cpw	(0x26b0:16), 0x03e7                          ; FEFBEC  d1 b0 26 3f e7 03
	jr ule, .LFEFC09                                     ; FEFBF2  63 15
	ldw (0x26b0:16), 0x00                                ; FEFBF4  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt6_DL1                            ; FEFBFA  45 18 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt6_DL2                            ; FEFBFF  44 27 fc fe 00
	call T_DisplayListB_Run                              ; FEFC04  1d f4 17 f4
	ret                                                  ; FEFC08  0e
.LFEFC09:
	ld XIY,EditScreen_MeasureNumberAt6_DL2                            ; FEFC09  45 27 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt7                                    ; FEFC0E  44 31 fc fe 00
	call T_DisplayListB_Run                              ; FEFC13  1d f4 17 f4
	ret                                                  ; FEFC17  0e

; EditScreen_MeasureNumberAt6_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFC18 and land exactly on 0xFEFC27.
EditScreen_MeasureNumberAt6_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt6 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=128, y=20

; EditScreen_MeasureNumberAt6_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFC27 and land exactly on 0xFEFC31.
EditScreen_MeasureNumberAt6_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt6 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=128, y=20, digits=2
; EditScreen_MeasureNumberAt7: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 7 of 12 in address order; NOTE EDIT slot 6, DRUM EDIT slot 3 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt7:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA12
	cpw	(0x26b0:16), 0x03e7                          ; FEFC31  d1 b0 26 3f e7 03
	jr ule, .LFEFC4E                                     ; FEFC37  63 15
	ldw (0x26b0:16), 0x00                                ; FEFC39  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt7_DL1                            ; FEFC3F  45 5d fc fe 00
	ld XIX,EditScreen_MeasureNumberAt7_DL2                            ; FEFC44  44 6c fc fe 00
	call T_DisplayListB_Run                              ; FEFC49  1d f4 17 f4
	ret                                                  ; FEFC4D  0e
.LFEFC4E:
	ld XIY,EditScreen_MeasureNumberAt7_DL2                            ; FEFC4E  45 6c fc fe 00
	ld XIX,EditScreen_MeasureNumberAt8                                    ; FEFC53  44 76 fc fe 00
	call T_DisplayListB_Run                              ; FEFC58  1d f4 17 f4
	ret                                                  ; FEFC5C  0e

; EditScreen_MeasureNumberAt7_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFC5D and land exactly on 0xFEFC6C.
EditScreen_MeasureNumberAt7_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt7 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=152, y=20

; EditScreen_MeasureNumberAt7_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFC6C and land exactly on 0xFEFC76.
EditScreen_MeasureNumberAt7_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt7 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=152, y=20, digits=2
; EditScreen_MeasureNumberAt8: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 8 of 12 in address order; NOTE EDIT slot 7, DRUM EDIT slot 4 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt8:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA16
	cpw	(0x26b0:16), 0x03e7                          ; FEFC76  d1 b0 26 3f e7 03
	jr ule, .LFEFC93                                     ; FEFC7C  63 15
	ldw (0x26b0:16), 0x00                                ; FEFC7E  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt8_DL1                            ; FEFC84  45 a2 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt8_DL2                            ; FEFC89  44 b1 fc fe 00
	call T_DisplayListB_Run                              ; FEFC8E  1d f4 17 f4
	ret                                                  ; FEFC92  0e
.LFEFC93:
	ld XIY,EditScreen_MeasureNumberAt8_DL2                            ; FEFC93  45 b1 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt9                                    ; FEFC98  44 bb fc fe 00
	call T_DisplayListB_Run                              ; FEFC9D  1d f4 17 f4
	ret                                                  ; FEFCA1  0e

; EditScreen_MeasureNumberAt8_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFCA2 and land exactly on 0xFEFCB1.
EditScreen_MeasureNumberAt8_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=176, y=20

; EditScreen_MeasureNumberAt8_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFCB1 and land exactly on 0xFEFCBB.
EditScreen_MeasureNumberAt8_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt8 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=20, digits=2
; EditScreen_MeasureNumberAt9: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 9 of 12 in address order; NOTE EDIT slot 8, DRUM EDIT slot 5 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt9:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA1A
	cpw	(0x26b0:16), 0x03e7                          ; FEFCBB  d1 b0 26 3f e7 03
	jr ule, .LFEFCD8                                     ; FEFCC1  63 15
	ldw (0x26b0:16), 0x00                                ; FEFCC3  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt9_DL1                            ; FEFCC9  45 e7 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt9_DL2                            ; FEFCCE  44 f6 fc fe 00
	call T_DisplayListB_Run                              ; FEFCD3  1d f4 17 f4
	ret                                                  ; FEFCD7  0e
.LFEFCD8:
	ld XIY,EditScreen_MeasureNumberAt9_DL2                            ; FEFCD8  45 f6 fc fe 00
	ld XIX,EditScreen_MeasureNumberAt10                                    ; FEFCDD  44 00 fd fe 00
	call T_DisplayListB_Run                              ; FEFCE2  1d f4 17 f4
	ret                                                  ; FEFCE6  0e

; EditScreen_MeasureNumberAt9_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFCE7 and land exactly on 0xFEFCF6.
EditScreen_MeasureNumberAt9_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt9 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=200, y=20

; EditScreen_MeasureNumberAt9_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFCF6 and land exactly on 0xFEFD00.
EditScreen_MeasureNumberAt9_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt9 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=20, digits=2
; EditScreen_MeasureNumberAt10: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 10 of 12 in address order; NOTE EDIT slot 9, DRUM EDIT slot 6 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt10:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA1E
	cpw	(0x26b0:16), 0x03e7                          ; FEFD00  d1 b0 26 3f e7 03
	jr ule, .LFEFD1D                                     ; FEFD06  63 15
	ldw (0x26b0:16), 0x00                                ; FEFD08  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt10_DL1                            ; FEFD0E  45 2c fd fe 00
	ld XIX,EditScreen_MeasureNumberAt10_DL2                            ; FEFD13  44 3b fd fe 00
	call T_DisplayListB_Run                              ; FEFD18  1d f4 17 f4
	ret                                                  ; FEFD1C  0e
.LFEFD1D:
	ld XIY,EditScreen_MeasureNumberAt10_DL2                            ; FEFD1D  45 3b fd fe 00
	ld XIX,EditScreen_MeasureNumberAt11                                    ; FEFD22  44 45 fd fe 00
	call T_DisplayListB_Run                              ; FEFD27  1d f4 17 f4
	ret                                                  ; FEFD2B  0e

; EditScreen_MeasureNumberAt10_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFD2C and land exactly on 0xFEFD3B.
EditScreen_MeasureNumberAt10_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt10 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=224, y=20

; EditScreen_MeasureNumberAt10_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFD3B and land exactly on 0xFEFD45.
EditScreen_MeasureNumberAt10_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt10 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=224, y=20, digits=2
; EditScreen_MeasureNumberAt11: draws the measure number in (0x26B0) -- cleared if above 999 -- at one fixed place of the
;   edit screen; place 11 of 12 in address order; NOTE EDIT slot 10, DRUM EDIT slot 7 (notes/prom_a_edit_screen_measure_numbers.py).
EditScreen_MeasureNumberAt11:   ; entry: named by 3 `.long`/`ld` operands, first at 0xFEFA22
	cpw	(0x26b0:16), 0x03e7                          ; FEFD45  d1 b0 26 3f e7 03
	jr ule, .LFEFD62                                     ; FEFD4B  63 15
	ldw (0x26b0:16), 0x00                                ; FEFD4D  f1 b0 26 02 00 00
	ld XIY,EditScreen_MeasureNumberAt11_DL1                            ; FEFD53  45 71 fd fe 00
	ld XIX,EditScreen_MeasureNumberAt11_DL2                            ; FEFD58  44 80 fd fe 00
	call T_DisplayListB_Run                              ; FEFD5D  1d f4 17 f4
	ret                                                  ; FEFD61  0e
.LFEFD62:
	ld XIY,EditScreen_MeasureNumberAt11_DL2                            ; FEFD62  45 80 fd fe 00
	ld XIX,EditScreen_RedrawCursorLayer                                    ; FEFD67  44 8a fd fe 00
	call T_DisplayListB_Run                              ; FEFD6C  1d f4 17 f4
	ret                                                  ; FEFD70  0e

; EditScreen_MeasureNumberAt11_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFD71 and land exactly on 0xFEFD80.
EditScreen_MeasureNumberAt11_DL1:
; ; drawn (start operand) by EditScreen_MeasureNumberAt11 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=2, x=248, y=20

; EditScreen_MeasureNumberAt11_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFEFD80 and land exactly on 0xFEFD8A.
EditScreen_MeasureNumberAt11_DL2:
; ; drawn (start operand) by EditScreen_MeasureNumberAt11 -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=248, y=20, digits=2
; EditScreen_RedrawCursorLayer: while the cursor is inside the measure: layer 1 erased, EditScreen_DrawSelectedEventBar,
;   EditScreen_DrawCursorTickMarker, the left rule, EditScreen_DrawDataEndMarker.
EditScreen_RedrawCursorLayer:
	ld c, (EditMeasure_Beats:24)                                 ; FEFD8A  c2 75 1f 60 23
	mul C,0x60                                           ; FEFD8F  cb 08 60
	cp (EditCursor_TickInMeasure:24), bc                             ; FEFD92  d2 54 1f 60 f9
	jr nc, .LFEFDAB                                      ; FEFD97  6f 12
	calr EditScreen_EraseMarkerStrip                                          ; FEFD99  1e fa f9
	calr EditScreen_EraseEditArea_Layer1                                          ; FEFD9C  1e ba fa
	calr EditScreen_DrawSelectedEventBar                                          ; FEFD9F  1e 4b 03
	calr EditScreen_DrawCursorTickMarker                                      ; FEFDA2  1e 07 00
	calr LCD_DrawVRuleLeft_OrNothing                                            ; FEFDA5  1e b1 00
	calr EditScreen_DrawDataEndMarker                                            ; FEFDA8  1e 3a 00
.LFEFDAB:
	ret                                                  ; FEFDAB  0e
; EditScreen_DrawCursorTickMarker: layer 1: Glyph_FEFDE4 at x = EditCursor_TickInMeasure / 4 + 0x0D (NOTE) or 0x56 (DRUM), y = 0x22.
EditScreen_DrawCursorTickMarker:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEFDAC  f1 40 25 00 01
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEFDB1  d2 54 1f 60 20
	div A,0x04                                           ; FEFDB6  c9 0a 04
	xor W,W                                              ; FEFDB9  c8 d0
	bit	0, (EditScreen_Mode:24)                             ; FEFDBB  f2 70 1f 60 c8
	jr z, .LFEFDC8                                       ; FEFDC0  66 06
	add WA,0x0056                                        ; FEFDC2  d8 c8 56 00
	jr .LFEFDCC                                          ; FEFDC6  68 04
.LFEFDC8:
	add WA,0x000d                                        ; FEFDC8  d8 c8 0d 00
.LFEFDCC:
	ld (LCD_X0:16), wa                                  ; FEFDCC  f1 30 25 50
	ldw (LCD_Y0:16), 0x22                                ; FEFDD0  f1 32 25 02 22 00
	ld XIY,Glyph_FEFDE4                                  ; FEFDD6  45 e4 fd fe 00
	xor HL,HL                                            ; FEFDDB  db d3
	ldw bc, 0x01                                         ; FEFDDD  31 01 00
	ld a, 0x17:opc                                          ; FEFDE0  21 17
	swi 7                                                ; FEFDE2  ff
	ret                                                  ; FEFDE3  0e
; ---------------------------------------------------------------------
; Glyph_FEFDE4 -- ONE character, 0x12, drawn at (0x2530)=x, (0x2532)=0x22
; Read by: 0xFEFDD6, with HL = 0 and BC = 1, through SWI7 service 0x17.
; Unknown: which glyph 0x12 is.  It is below 0x20, so it is a custom
;          cell of the font rather than ASCII.
; ---------------------------------------------------------------------

Glyph_FEFDE4:
	.byte 0x12                                                                ; FEFDE4
; EditScreen_DrawDataEndMarker: EditScreen_CountBeatsInMeasure (cursor and position kept); when the part's chain ends inside the view, layer
;   1: Glyph_FEFE58 at x = 24 x the beats it holds + 0x0D / 0x56, y 0x21.
EditScreen_DrawDataEndMarker:
	ld wa, (BStore_CursorBlock:16)                                 ; FEFDE5  d1 5c 34 20
	ld bc, (BStore_CursorOffset:16)                                 ; FEFDE9  d1 5e 34 21
	ld ix, (EditPos_Beat:24)                                ; FEFDED  d2 05 1f 60 24
	ld h, (EditPos_Tick:24)                                 ; FEFDF2  c2 07 1f 60 26
	pushw wa                                             ; FEFDF7  28
	pushw bc                                             ; FEFDF8  29
	pushw ix                                             ; FEFDF9  2c
	pushw hl                                             ; FEFDFA  2b
	calr EditScreen_CountBeatsInMeasure                                          ; FEFDFB  1e d9 a8
	popw hl                                              ; FEFDFE  4b
	popw ix                                              ; FEFDFF  4c
	popw bc                                              ; FEFE00  49
	popw wa                                              ; FEFE01  48
	ld (BStore_CursorBlock:16), wa                                  ; FEFE02  f1 5c 34 50
	ld (BStore_CursorOffset:16), bc                                  ; FEFE06  f1 5e 34 51
	ld (EditPos_Beat:24), ix                                ; FEFE0A  f2 05 1f 60 54
	ld (EditPos_Tick:24), h                                 ; FEFE0F  f2 07 1f 60 46
	xor WA,WA                                            ; FEFE14  d8 d0
	ld a, (EditMeasure_Beats:24)                                 ; FEFE16  c2 75 1f 60 21
	cp (EditScreen_BeatCounter:24), wa                             ; FEFE1B  d2 6c 1f 60 f8
	jr ugt, .LFEFE57                                     ; FEFE20  6b 35
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEFE22  f1 40 25 00 01
	ld wa, (EditScreen_BeatCounter:24)                                ; FEFE27  d2 6c 1f 60 20
	mul A,0x18                                           ; FEFE2C  c9 08 18
	bit	0, (EditScreen_Mode:24)                             ; FEFE2F  f2 70 1f 60 c8
	jr z, .LFEFE3C                                       ; FEFE34  66 06
	add WA,0x0056                                        ; FEFE36  d8 c8 56 00
	jr .LFEFE40                                          ; FEFE3A  68 04
.LFEFE3C:
	add WA,0x000d                                        ; FEFE3C  d8 c8 0d 00
.LFEFE40:
	ld (LCD_X0:16), wa                                  ; FEFE40  f1 30 25 50
	ldw (LCD_Y0:16), 0x21                                ; FEFE44  f1 32 25 02 21 00
	ld XIY,Glyph_FEFE58                                  ; FEFE4A  45 58 fe fe 00
	xor HL,HL                                            ; FEFE4F  db d3
	ldw bc, 0x01                                         ; FEFE51  31 01 00
	ld a, 0x17:opc                                          ; FEFE54  21 17
	swi 7                                                ; FEFE56  ff
.LFEFE57:
	ret                                                  ; FEFE57  0e
; ---------------------------------------------------------------------
; Glyph_FEFE58 -- ONE character, 0xAF, the same shape as Glyph_FEFDE4
; Read by: 0xFEFE4A, HL = 0, BC = 1, SWI7 service 0x17, at y = 0x21.
; ---------------------------------------------------------------------

Glyph_FEFE58:
	.byte 0xaf                                                                ; FEFE58
; ---------------------------------------------------------------------
; LCD_DrawVRuleLeft_OrNothing -- in NOTE EDIT draws the left vertical rule; in DRUM EDIT nothing
;
; Evidence: 0xFEFE59 `bit 0,(EditScreen_Mode)`: SET (DRUM EDIT,
;           FINDINGS-prom_a-screen-module.md section 8) returns at
;           0xFEFE60; CLEAR (NOTE EDIT) jumps to 0xFEFE65 `calr
;           LCD_DrawVRuleLeft_Layer1`.  The `calr LCD_DrawVRuleRight_Layer1`
;           at 0xFEFE61 follows that `ret` and carries no label: nothing
;           reaches it (this header said 2026-10-03 that the bit chose
;           between the two calls).  Seven callers.
; Was `sub_FEFE59`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
LCD_DrawVRuleLeft_OrNothing:
	bit	0, (EditScreen_Mode:24)                             ; FEFE59  f2 70 1f 60 c8
	jr z, .LFEFE65                                       ; FEFE5E  66 05
	ret                                                  ; FEFE60  0e
	calr LCD_DrawVRuleRight_Layer1                                      ; FEFE61  1e 30 00
	ret                                                  ; FEFE64  0e
.LFEFE65:
	calr LCD_DrawVRuleLeft_Layer1                                      ; FEFE65  1e 01 00
	ret                                                  ; FEFE68  0e
; ---------------------------------------------------------------------
; LCD_DrawVRuleLeft_Layer1 -- a vertical rule on layer 1 whose column tracks (0x601F54)
;
; Called from: prom_a LCD_DrawVRuleLeft_OrNothing (`calr`) at 0xFEFE65
; Issues:  SWI7 service 0x02 at 0xFEFE92 -- LCD_Svc_02_DrawVLine, a solid vertical run of pixels
; Evidence: `ld (0x2540),0x01`; (0x2532)=0x0029 and (0x2536)=0x00A8 fix the ends;
;           X0 and X1 are BOTH set to (0x601F54)/4 + 0x10, so the rectangle is one
;           pixel wide, and service 0x02 draws a vertical run.  `Left` is relative to
;           LCD_DrawVRuleRight_Layer1 below, which adds 0x59 to the same quantity.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_DrawVRuleLeft_Layer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEFE69  f1 40 25 00 01
	ldw (LCD_Y0:16), 0x29                                ; FEFE6E  f1 32 25 02 29 00
	ldw (LCD_Y1:16), 0xa8                                ; FEFE74  f1 36 25 02 a8 00
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEFE7A  d2 54 1f 60 20
	div A,0x04                                           ; FEFE7F  c9 0a 04
	xor W,W                                              ; FEFE82  c8 d0
	add WA,0x0010                                        ; FEFE84  d8 c8 10 00
	ld (LCD_X0:16), wa                                  ; FEFE88  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FEFE8C  f1 34 25 50
	ld a, 0x02:opc                                          ; FEFE90  21 02
	swi 7                                                ; FEFE92  ff
	ret                                                  ; FEFE93  0e
; ---------------------------------------------------------------------
; LCD_DrawVRuleRight_Layer1 -- the companion vertical rule, 73 pixels to the right
;
; Called from: prom_a LCD_DrawVRuleLeft_OrNothing (`calr`) at 0xFEFE61
; ⚠ That call follows a `ret` (0xFEFE60) and carries no label, and it is the only reference:
;   as the code stands nothing reaches this routine (2026-10-03).
; Issues:  SWI7 service 0x02 at 0xFEFEBD -- LCD_Svc_02_DrawVLine, a solid vertical run of pixels
; Evidence: the same nine instructions as LCD_DrawVRuleLeft_Layer1 with three
;           immediates changed: Y0 0x2A, Y1 0xA1, and X = (0x601F54)/4 + 0x59.  0x59 -
;           0x10 = 0x49 = 73, which is what `Right` claims and all it claims.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_DrawVRuleRight_Layer1:
	ld (LCD_CurrentLayer:16), 0x01                                 ; FEFE94  f1 40 25 00 01
	ldw (LCD_Y0:16), 0x2a                                ; FEFE99  f1 32 25 02 2a 00
	ldw (LCD_Y1:16), 0xa1                                ; FEFE9F  f1 36 25 02 a1 00
	ld wa, (EditCursor_TickInMeasure:24)                                ; FEFEA5  d2 54 1f 60 20
	div A,0x04                                           ; FEFEAA  c9 0a 04
	xor W,W                                              ; FEFEAD  c8 d0
	add WA,0x0059                                        ; FEFEAF  d8 c8 59 00
	ld (LCD_X0:16), wa                                  ; FEFEB3  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FEFEB7  f1 34 25 50
	ld a, 0x02:opc                                          ; FEFEBB  21 02
	swi 7                                                ; FEFEBD  ff
	ret                                                  ; FEFEBE  0e
; EditScreen_DrawVisibleNotes: walks the measure from its mark, counting 0x81 beat markers up to EditMeasure_Beats, and draws every note-on
;   whose note is inside EditScreen_VisibleNoteRange (EditScreen_DrawEventBar).
EditScreen_DrawVisibleNotes:
	calr BStore_CursorSlot_Save                                          ; FEFEBF  1e 2c 8e
	calr BStore_CursorSlot_RestoreMark                                          ; FEFEC2  1e 33 8d
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FEFEC5  f2 6c 1f 60 02 00 00
.LFEFECC:
	calr BStoreCursor_ReadByte                                          ; FEFECC  1e 63 23
	cp A,0x82                                            ; FEFECF  c9 cf 82
	jr z, .LFEFF29                                       ; FEFED2  66 55
	cp A,0x81                                            ; FEFED4  c9 cf 81
	jr z, .LFEFF0B                                       ; FEFED7  66 32
	and A,0xf0                                           ; FEFED9  c9 cc f0
	cp A,0x90                                            ; FEFEDC  c9 cf 90
	jr z, .LFEFEE6                                       ; FEFEDF  66 05
.LFEFEE1:
	calr BStoreCursor_SeekNextTag                                          ; FEFEE1  1e 12 23
	jr .LFEFECC                                          ; FEFEE4  68 e6
.LFEFEE6:
	calr BStoreCursor_Step                                          ; FEFEE6  1e 1b 23
	calr BStoreCursor_ReadByte                                          ; FEFEE9  1e 46 23
	ld (EditPos_Tick:24), a                                 ; FEFEEC  f2 07 1f 60 41
	calr BStoreCursor_Step                                          ; FEFEF1  1e 10 23
	calr BStoreCursor_ReadByte                                          ; FEFEF4  1e 3b 23
	ld H,A                                               ; FEFEF7  c9 8e
	pushw hl                                             ; FEFEF9  2b
	calr EditScreen_VisibleNoteRange                                      ; FEFEFA  1e b7 00
	popw hl                                              ; FEFEFD  4b
	cp H,A                                               ; FEFEFE  c9 f6
	jr c, .LFEFEE1                                       ; FEFF00  67 df
	cp H,W                                               ; FEFF02  c8 f6
	jr ugt, .LFEFEE1                                     ; FEFF04  6b db
	calr EditScreen_DrawEventBar                                            ; FEFF06  1e ea 00
	jr .LFEFEE1                                          ; FEFF09  68 d6
.LFEFF0B:
	addw	(EditScreen_BeatCounter:24), 0x0001                        ; FEFF0B  d2 6c 1f 60 38 01 00
	addw	(EditPos_Beat:24), 0x0001                        ; FEFF12  d2 05 1f 60 38 01 00
	xor WA,WA                                            ; FEFF19  d8 d0
	ld a, (EditMeasure_Beats:24)                                 ; FEFF1B  c2 75 1f 60 21
	cp (EditScreen_BeatCounter:24), wa                             ; FEFF20  d2 6c 1f 60 f8
	jr nc, .LFEFF29                                      ; FEFF25  6f 02
	jr .LFEFEE1                                          ; FEFF27  68 b8
.LFEFF29:
	calr BStore_CursorSlot_Restore                                          ; FEFF29  1e e9 8d
	ret                                                  ; FEFF2C  0e
; EditScreen_DrawVisibleNotesExceptSelected: the same walk, skipping the note-on at the selected position (0x601F0B / 0x601F0D).
EditScreen_DrawVisibleNotesExceptSelected:
	calr BStore_CursorSlot_Save                                          ; FEFF2D  1e be 8d
	calr BStore_CursorSlot_RestoreMark                                          ; FEFF30  1e c5 8c
	ldw (EditScreen_BeatCounter:24), 0x00                             ; FEFF33  f2 6c 1f 60 02 00 00
.LFEFF3A:
	calr BStoreCursor_ReadByte                                          ; FEFF3A  1e f5 22
	cp A,0x82                                            ; FEFF3D  c9 cf 82
	jrl z, .LFEFFB0                                      ; FEFF40  76 6d 00
	cp A,0x81                                            ; FEFF43  c9 cf 81
	jr z, .LFEFF92                                       ; FEFF46  66 4a
	and A,0xf0                                           ; FEFF48  c9 cc f0
	cp A,0x90                                            ; FEFF4B  c9 cf 90
	jr z, .LFEFF55                                       ; FEFF4E  66 05
.LFEFF50:
	calr BStoreCursor_SeekNextTag                                          ; FEFF50  1e a3 22
	jr .LFEFF3A                                          ; FEFF53  68 e5
.LFEFF55:
	ld wa, (BStore_CursorBlock:16)                                 ; FEFF55  d1 5c 34 20
	cp	wa, (0x601f0b:24)                            ; FEFF59  d2 0b 1f 60 f0
	jr nz, .LFEFF6D                                      ; FEFF5E  6e 0d
	ld wa, (BStore_CursorOffset:16)                                 ; FEFF60  d1 5e 34 20
	cp	wa, (0x601f0d:24)                            ; FEFF64  d2 0d 1f 60 f0
	jr nz, .LFEFF6D                                      ; FEFF69  6e 02
	jr .LFEFF50                                          ; FEFF6B  68 e3
.LFEFF6D:
	calr BStoreCursor_Step                                          ; FEFF6D  1e 94 22
	calr BStoreCursor_ReadByte                                          ; FEFF70  1e bf 22
	ld (EditPos_Tick:24), a                                 ; FEFF73  f2 07 1f 60 41
	calr BStoreCursor_Step                                          ; FEFF78  1e 89 22
	calr BStoreCursor_ReadByte                                          ; FEFF7B  1e b4 22
	ld H,A                                               ; FEFF7E  c9 8e
	pushw hl                                             ; FEFF80  2b
	calr EditScreen_VisibleNoteRange                                      ; FEFF81  1e 30 00
	popw hl                                              ; FEFF84  4b
	cp H,A                                               ; FEFF85  c9 f6
	jr c, .LFEFF50                                       ; FEFF87  67 c7
	cp H,W                                               ; FEFF89  c8 f6
	jr ugt, .LFEFF50                                     ; FEFF8B  6b c3
	calr EditScreen_DrawEventBar                                            ; FEFF8D  1e 63 00
	jr .LFEFF50                                          ; FEFF90  68 be
.LFEFF92:
	addw	(EditScreen_BeatCounter:24), 0x0001                        ; FEFF92  d2 6c 1f 60 38 01 00
	addw	(EditPos_Beat:24), 0x0001                        ; FEFF99  d2 05 1f 60 38 01 00
	xor WA,WA                                            ; FEFFA0  d8 d0
	ld a, (EditMeasure_Beats:24)                                 ; FEFFA2  c2 75 1f 60 21
	cp (EditScreen_BeatCounter:24), wa                             ; FEFFA7  d2 6c 1f 60 f8
	jr nc, .LFEFFB0                                      ; FEFFAC  6f 02
	jr .LFEFF50                                          ; FEFFAE  68 a0
.LFEFFB0:
	calr BStore_CursorSlot_Restore                                          ; FEFFB0  1e 62 8d
	ret                                                  ; FEFFB3  0e
; EditScreen_VisibleNoteRange: A = the lowest, W = the highest note shown: DRUM EDIT DrumEdit_TopRowNote .. + 11; NOTE EDIT the word pair
;   WordTable_FEFFDD[NoteEdit_RulerPosition].
EditScreen_VisibleNoteRange:
	bit	0, (EditScreen_Mode:24)                             ; FEFFB4  f2 70 1f 60 c8
	jr z, .LFEFFC6                                       ; FEFFB9  66 0b
	ld wa, (DrumEdit_TopRowNote:24)                                ; FEFFBB  d2 71 1f 60 20
	ld W,A                                               ; FEFFC0  c9 88
	add W,0x0b                                           ; FEFFC2  c8 c8 0b
	ret                                                  ; FEFFC5  0e
.LFEFFC6:
	ld XIX,WordTable_FEFFDD                              ; FEFFC6  44 dd ff fe 00
	xor XWA,XWA                                          ; FEFFCB  e8 d0
	ld a, (NoteEdit_RulerPosition:24)                                 ; FEFFCD  c2 53 1f 60 21
	sll wa, 0x01                                         ; FEFFD2  d8 ee 01
	add XIX,XWA                                          ; FEFFD5  e8 84
	ld a, (xix+)                                      ; FEFFD7  c5 f0 21
	ld W,(XIX)                                           ; FEFFDA  84 20
	ret                                                  ; FEFFDC  0e
; ---------------------------------------------------------------------
; WordTable_FEFFDD -- 11 little-endian 16-bit words
; Read by: 0xFEFFC6 `ld XIX,0x00FEFFDD`, indexed by (0x601F53) with
;          `sll 1,WA` -- a stride of 2 -- then `ld A,(XIX+) / ld W,(XIX)`,
;          which returns the two bytes as a PAIR in WA rather than as one
;          number.  So `.byte` is the honest emission here, not `.short`.
; ENTRY COUNT 11 is the extent to 0xFEFFF3, where code resumes.
; Unknown: what the pairs are.  They are not monotonic.
; ---------------------------------------------------------------------

WordTable_FEFFDD:
	.byte 0x01, 0x17, 0x09, 0x23, 0x15, 0x2f, 0x21, 0x3b, 0x2d, 0x47, 0x39, 0x53, 0x45, 0x5f, 0x51, 0x6b  ; FEFFDD
	.byte 0x5d, 0x77, 0x69, 0x7f, 0x01, 0x01                                  ; FEFFED
; EditScreen_DrawEventBar: geometry from EditBar_LoadEventGeometry, layer 0, the mode's shape (DrumEdit_EventMarkRect DRUM / NoteEdit_EventBarRect NOTE), SWI 7 service 9.
EditScreen_DrawEventBar:
	calr EditBar_LoadEventGeometry                                          ; FEFFF3  1e 9e 02
	ld (LCD_CurrentLayer:16), 0x00                                 ; FEFFF6  f1 40 25 00 00
	bit	0, (EditScreen_Mode:24)                             ; FEFFFB  f2 70 1f 60 c8
	jr z, .LFF0007                                       ; FF0000  66 05
	calr DrumEdit_EventMarkRect                                            ; FF0002  1e 8d 00
	jr .LFF000A                                          ; FF0005  68 03
.LFF0007:
	calr NoteEdit_EventBarRect                                      ; FF0007  1e 04 00
.LFF000A:
	ld a, 0x09:opc                                          ; FF000A  21 09
	swi 7                                                ; FF000C  ff
	ret                                                  ; FF000D  0e
; NoteEdit_EventBarRect: LCD_X0 = (0x601F38) / 4 + 0x10, LCD_X1 = LCD_X0 + (0x601F3B) / 4, LCD_Y0 = CoordTable_FF0058[(0x601F3A)],
;   LCD_Y1 = LCD_Y0 + 3: a piano-roll bar as long as the note.
NoteEdit_EventBarRect:
	xor XWA,XWA                                          ; FF000E  e8 d0
	ld wa, (EditBar_Tick:24)                                ; FF0010  d2 38 1f 60 20
	div WA,0x0004                                        ; FF0015  d8 0a 04 00
	add WA,0x0010                                        ; FF0019  d8 c8 10 00
	ld (LCD_X0:16), wa                                  ; FF001D  f1 30 25 50
	xor XWA,XWA                                          ; FF0021  e8 d0
	ld wa, (EditBar_Length:24)                                ; FF0023  d2 3b 1f 60 20
	div WA,0x0004                                        ; FF0028  d8 0a 04 00
	add	wa, (LCD_X0:16)                              ; FF002C  d1 30 25 80
	ld (LCD_X1:16), wa                                  ; FF0030  f1 34 25 50
	ld XIX,CoordTable_FF0058                             ; FF0034  44 58 00 ff 00
	xor XWA,XWA                                          ; FF0039  e8 d0
	ld a, (EditBar_Row:24)                                 ; FF003B  c2 3a 1f 60 21
	sll wa, 0x01                                         ; FF0040  d8 ee 01
	add XIX,XWA                                          ; FF0043  e8 84
	ld WA,(XIX)                                          ; FF0045  94 20
	ld (LCD_Y0:16), wa                                  ; FF0047  f1 32 25 50
	ld wa, (LCD_Y0:16)                                 ; FF004B  d1 32 25 20
	add WA,0x0003                                        ; FF004F  d8 c8 03 00
	ld (LCD_Y1:16), wa                                  ; FF0053  f1 36 25 50
	ret                                                  ; FF0057  0e
; ---------------------------------------------------------------------
; CoordTable_FF0058 -- 29 little-endian 16-bit values, then two zeros
; Read by: 0xFF0034 `ld XIX,0x00FF0058`, indexed by (0x601F3A) at a
;          stride of 2, and the value goes straight to (0x2532) -- the
;          Y COORDINATE cell every SWI7 text call in this module writes.
; Evidence that they are coordinates: 0xA3, 0x9F, 0x9B, 0x93 ... 0x2B,
;          strictly descending, and the caller adds 3 to get (0x2536).
; ENTRY COUNT 29 is the extent to 0xFF0092, where code resumes; the last
;          two words are 0x0000 and read as a terminator, but nothing
;          tests for zero, so that is a description, not a claim.
; ---------------------------------------------------------------------

CoordTable_FF0058:
	.byte 0xa3, 0x00, 0x9f, 0x00, 0x9b, 0x00, 0x93, 0x00, 0x8f, 0x00, 0x8b, 0x00, 0x87, 0x00, 0x83, 0x00  ; FF0058
	.byte 0x7b, 0x00, 0x77, 0x00, 0x73, 0x00, 0x6f, 0x00, 0x6b, 0x00, 0x67, 0x00, 0x63, 0x00, 0x5b, 0x00  ; FF0068
	.byte 0x57, 0x00, 0x53, 0x00, 0x4f, 0x00, 0x4b, 0x00, 0x43, 0x00, 0x3f, 0x00, 0x3b, 0x00, 0x37, 0x00  ; FF0078
	.byte 0x33, 0x00, 0x2f, 0x00, 0x2b, 0x00, 0x00, 0x00, 0x00, 0x00          ; FF0088
; DrumEdit_EventMarkRect: LCD_X0 = (0x601F38) / 4 + 0x59, two pixels wide, LCD_Y0 = CoordTable_FF00D1[(0x601F3A)], three high: a drum
;   hit mark.
DrumEdit_EventMarkRect:
	xor XWA,XWA                                          ; FF0092  e8 d0
	ld wa, (EditBar_Tick:24)                                ; FF0094  d2 38 1f 60 20
	div WA,0x0004                                        ; FF0099  d8 0a 04 00
	add WA,0x0059                                        ; FF009D  d8 c8 59 00
	ld (LCD_X0:16), wa                                  ; FF00A1  f1 30 25 50
	add WA,0x0001                                        ; FF00A5  d8 c8 01 00
	ld (LCD_X1:16), wa                                  ; FF00A9  f1 34 25 50
	ld XIX,CoordTable_FF00D1                             ; FF00AD  44 d1 00 ff 00
	xor XWA,XWA                                          ; FF00B2  e8 d0
	ld a, (EditBar_Row:24)                                 ; FF00B4  c2 3a 1f 60 21
	sll wa, 0x01                                         ; FF00B9  d8 ee 01
	add XIX,XWA                                          ; FF00BC  e8 84
	ld WA,(XIX)                                          ; FF00BE  94 20
	ld (LCD_Y0:16), wa                                  ; FF00C0  f1 32 25 50
	ld wa, (LCD_Y0:16)                                 ; FF00C4  d1 32 25 20
	add WA,0x0002                                        ; FF00C8  d8 c8 02 00
	ld (LCD_Y1:16), wa                                  ; FF00CC  f1 36 25 50
	ret                                                  ; FF00D0  0e
; ---------------------------------------------------------------------
; CoordTable_FF00D1 -- 14 words of the same kind, step 10 rather than 4
; Read by: 0xFF00AD `ld XIX,0x00FF00D1`, same indexed read.
; ENTRY COUNT 14 is the extent to 0xFF00ED.  Values 0x9B, 0x91, 0x87 ...
;          0x2D, then two zeros.
; ---------------------------------------------------------------------

CoordTable_FF00D1:
	.byte 0x9b, 0x00, 0x91, 0x00, 0x87, 0x00, 0x7d, 0x00, 0x73, 0x00, 0x69, 0x00, 0x5f, 0x00, 0x55, 0x00  ; FF00D1
	.byte 0x4b, 0x00, 0x41, 0x00, 0x37, 0x00, 0x2d, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF00E1
; EditScreen_DrawSelectedEventBar: with an event selected and its note in EditScreen_VisibleNoteRange: its bar on layer 1 (DrumEdit_DrawSelectedMarkBrackets /
;   NoteEdit_DrawSelectedBarInset).
EditScreen_DrawSelectedEventBar:
	bit	0, (EditScreen_CursorFlags:24)                             ; FF00ED  f2 5b 1f 60 c8
	jr z, .LFF013E                                       ; FF00F2  66 4a
	calr BStore_CursorSlot_Save                                          ; FF00F4  1e f7 8b
	calr BStoreCursor_ReadByte                                          ; FF00F7  1e 38 21
	and A,0xf0                                           ; FF00FA  c9 cc f0
	cp A,0x90                                            ; FF00FD  c9 cf 90
	jr z, .LFF0104                                       ; FF0100  66 02
	jr .LFF013B                                          ; FF0102  68 37
.LFF0104:
	calr BStoreCursor_Step                                          ; FF0104  1e fd 20
	calr BStoreCursor_ReadByte                                          ; FF0107  1e 28 21
	ld (EditPos_Tick:24), a                                 ; FF010A  f2 07 1f 60 41
	calr BStoreCursor_Step                                          ; FF010F  1e f2 20
	calr BStoreCursor_ReadByte                                          ; FF0112  1e 1d 21
	ld H,A                                               ; FF0115  c9 8e
	pushw hl                                             ; FF0117  2b
	calr EditScreen_VisibleNoteRange                                          ; FF0118  1e 99 fe
	popw hl                                              ; FF011B  4b
	cp H,A                                               ; FF011C  c9 f6
	jr c, .LFF013B                                       ; FF011E  67 1b
	cp H,W                                               ; FF0120  c8 f6
	jr ugt, .LFF013B                                     ; FF0122  6b 17
	calr EditBar_LoadEventGeometry                                      ; FF0124  1e 6d 01
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF0127  f1 40 25 00 01
	bit	0, (EditScreen_Mode:24)                             ; FF012C  f2 70 1f 60 c8
	jr z, .LFF0138                                       ; FF0131  66 05
	calr DrumEdit_DrawSelectedMarkBrackets                                      ; FF0133  1e 42 00
	jr .LFF013B                                          ; FF0136  68 03
.LFF0138:
	calr NoteEdit_DrawSelectedBarInset                                      ; FF0138  1e 04 00
.LFF013B:
	calr BStore_CursorSlot_Restore                                          ; FF013B  1e d7 8b
.LFF013E:
	ret                                                  ; FF013E  0e
; NoteEdit_DrawSelectedBarInset: NoteEdit_EventBarRect shrunk by a pixel on each side (bars under 2 pixels: their left edge only), SWI 7 5
;   (FillRect).
NoteEdit_DrawSelectedBarInset:
	calr NoteEdit_EventBarRect                                          ; FF013F  1e cc fe
	ld wa, (LCD_X1:16)                                 ; FF0142  d1 34 25 20
	sub	wa, (LCD_X0:16)                              ; FF0146  d1 30 25 a0
	cp wa, 0x02:i3                                         ; FF014A  d8 da
	jr nc, .LFF015C                                      ; FF014C  6f 0e
	cp wa, 0x01:i3                                         ; FF014E  d8 d9
	jr z, .LFF0154                                       ; FF0150  66 02
	jr .LFF0177                                          ; FF0152  68 23
.LFF0154:
	addw	(LCD_X0:16), 0x0001                          ; FF0154  d1 30 25 38 01 00
	jr .LFF0168                                          ; FF015A  68 0c
.LFF015C:
	addw	(LCD_X0:16), 0x0001                          ; FF015C  d1 30 25 38 01 00
	subw	(LCD_X1:16), 0x0001                  ; FF0162  d1 34 25 3a 01 00
.LFF0168:
	addw	(LCD_Y0:16), 0x0001                          ; FF0168  d1 32 25 38 01 00
	subw	(LCD_Y1:16), 0x0001                  ; FF016E  d1 36 25 3a 01 00
	ld a, 0x05:opc                                          ; FF0174  21 05
	swi 7                                                ; FF0176  ff
.LFF0177:
	ret                                                  ; FF0177  0e
; DrumEdit_DrawSelectedMarkBrackets: two fills, just above and just below DrumEdit_EventMarkRect.
DrumEdit_DrawSelectedMarkBrackets:
	calr DrumEdit_EventMarkRect                                          ; FF0178  1e 17 ff
	subw	(LCD_Y0:16), 0x0002                  ; FF017B  d1 32 25 3a 02 00
	subw	(LCD_Y1:16), 0x0003                  ; FF0181  d1 36 25 3a 03 00
	ld a, 0x05:opc                                          ; FF0187  21 05
	swi 7                                                ; FF0189  ff
	calr DrumEdit_EventMarkRect                                          ; FF018A  1e 05 ff
	addw	(LCD_Y0:16), 0x0003                          ; FF018D  d1 32 25 38 03 00
	addw	(LCD_Y1:16), 0x0002                          ; FF0193  d1 36 25 38 02 00
	ld a, 0x05:opc                                          ; FF0199  21 05
	swi 7                                                ; FF019B  ff
	ret                                                  ; FF019C  0e
; EditScreen_FillSelectedEventBar: with an event selected and its note in view: layer 1, its bar or mark filled (LCD_FillRect_Grown2Rows in
;   DRUM EDIT, NoteEdit_EventBarRect + FillRect in NOTE EDIT).
EditScreen_FillSelectedEventBar:
	bit	0, (EditScreen_CursorFlags:24)                             ; FF019D  f2 5b 1f 60 c8
	jr z, .LFF01F1                                       ; FF01A2  66 4d
	calr BStore_CursorSlot_Save                                          ; FF01A4  1e 47 8b
	calr BStoreCursor_ReadByte                                          ; FF01A7  1e 88 20
	and A,0xf0                                           ; FF01AA  c9 cc f0
	cp A,0x90                                            ; FF01AD  c9 cf 90
	jr z, .LFF01B4                                       ; FF01B0  66 02
	jr .LFF01EE                                          ; FF01B2  68 3a
.LFF01B4:
	calr BStoreCursor_Step                                          ; FF01B4  1e 4d 20
	calr BStoreCursor_ReadByte                                          ; FF01B7  1e 78 20
	ld (EditPos_Tick:24), a                                 ; FF01BA  f2 07 1f 60 41
	calr BStoreCursor_Step                                          ; FF01BF  1e 42 20
	calr BStoreCursor_ReadByte                                          ; FF01C2  1e 6d 20
	ld H,A                                               ; FF01C5  c9 8e
	pushw hl                                             ; FF01C7  2b
	calr EditScreen_VisibleNoteRange                                          ; FF01C8  1e e9 fd
	popw hl                                              ; FF01CB  4b
	cp H,A                                               ; FF01CC  c9 f6
	jr c, .LFF01EE                                       ; FF01CE  67 1e
	cp H,W                                               ; FF01D0  c8 f6
	jr ugt, .LFF01EE                                     ; FF01D2  6b 1a
	calr EditBar_LoadEventGeometry                                      ; FF01D4  1e bd 00
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF01D7  f1 40 25 00 01
	bit	0, (EditScreen_Mode:24)                             ; FF01DC  f2 70 1f 60 c8
	jr z, .LFF01E8                                       ; FF01E1  66 05
	calr LCD_FillRect_Grown2Rows                                      ; FF01E3  1e 0c 00
	jr .LFF01EE                                          ; FF01E6  68 06
.LFF01E8:
	calr NoteEdit_EventBarRect                                          ; FF01E8  1e 23 fe
	ld a, 0x05:opc                                          ; FF01EB  21 05
	swi 7                                                ; FF01ED  ff
.LFF01EE:
	calr BStore_CursorSlot_Restore                                          ; FF01EE  1e 24 8b
.LFF01F1:
	ret                                                  ; FF01F1  0e
; ---------------------------------------------------------------------
; LCD_FillRect_Grown2Rows -- grow the pending rectangle by two rows each way and fill it
;
; Called from: prom_a EditScreen_FillSelectedEventBar (`calr`) at 0xFF01E3
;          prom_a EditScreen_DrawSelectionAtCursor (`calr`) at 0xFF0288
; Issues:  SWI7 service 0x05 at 0xFF0203 -- LCD_Svc_05_FillRect, fill the rectangle in (0x2530..0x2536)
; Evidence: `sub (0x2532),0x0002` and `add (0x2536),0x0002` move Y0 up and Y1 down by
;           two before service 0x05 fills (0x2530..0x2536).  This routine's own
;           instructions never touch X0 or X1, so all IT contributes is four rows of
;           height.  ⚠ Where the rectangle comes from is NOT established: the `calr`
;           at 0xFF01F2 resolves to DrumEdit_EventMarkRect, which this round did not trace.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_FillRect_Grown2Rows:
	calr DrumEdit_EventMarkRect                                          ; FF01F2  1e 9d fe
	subw	(LCD_Y0:16), 0x0002                  ; FF01F5  d1 32 25 3a 02 00
	addw	(LCD_Y1:16), 0x0002                          ; FF01FB  d1 36 25 38 02 00
	ld a, 0x05:opc                                          ; FF0201  21 05
	swi 7                                                ; FF0203  ff
	ret                                                  ; FF0204  0e
; EditScreen_RedrawAfterTickMove: EditCursor_Tick* moves: with a selection, the other notes redrawn and the selection drawn at the cursor
;   (EditScreen_DrawSelectionAtCursor while a deferred action is pending, else EditScreen_FillSelectedEventBar);
;   without, all notes and EditScreen_DrawSelectedEventBar.
EditScreen_RedrawAfterTickMove:
	bit	0, (EditScreen_CursorFlags:24)                             ; FF0205  f2 5b 1f 60 c8
	jr z, .LFF0233                                       ; FF020A  66 27
	bit	7, (EditScreen_ActionTimer:24)                             ; FF020C  f2 58 1f 60 cf
	jr z, .LFF0223                                       ; FF0211  66 10
	calr EditScreen_EraseEditArea_Layer0                                          ; FF0213  1e bc f5
	calr EditScreen_DrawVisibleNotesExceptSelected                                          ; FF0216  1e 14 fd
	calr EditScreen_EraseEditArea_Layer1                                          ; FF0219  1e 3d f6
	calr EditScreen_DrawSelectionAtCursor                                      ; FF021C  1e 24 00
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FF021F  1e 37 fc
	ret                                                  ; FF0222  0e
.LFF0223:
	calr EditScreen_EraseEditArea_Layer0                                          ; FF0223  1e ac f5
	calr EditScreen_DrawVisibleNotesExceptSelected                                          ; FF0226  1e 04 fd
	calr EditScreen_EraseEditArea_Layer1                                          ; FF0229  1e 2d f6
	calr EditScreen_FillSelectedEventBar                                      ; FF022C  1e 6e ff
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FF022F  1e 27 fc
	ret                                                  ; FF0232  0e
.LFF0233:
	calr EditScreen_EraseEditArea_Layer0                                          ; FF0233  1e 9c f5
	calr EditScreen_DrawVisibleNotes                                          ; FF0236  1e 86 fc
	calr EditScreen_EraseEditArea_Layer1                                          ; FF0239  1e 1d f6
	calr EditScreen_DrawSelectedEventBar                                      ; FF023C  1e ae fe
	calr LCD_DrawVRuleLeft_OrNothing                                          ; FF023F  1e 17 fc
	ret                                                  ; FF0242  0e
; EditScreen_DrawSelectionAtCursor: with an event selected: its bar drawn at the CURSOR -- EditCursor_Note's row, EditCursor_TickInMeasure,
;   EditField_Length long (2 in DRUM EDIT) -- on layer 1: the selection following the cursor.
EditScreen_DrawSelectionAtCursor:
	bit	0, (EditScreen_CursorFlags:24)                             ; FF0243  f2 5b 1f 60 c8
	jr z, .LFF0293                                       ; FF0248  66 49
	calr EditScreen_VisibleNoteRange                                          ; FF024A  1e 67 fd
	ld l, (EditCursor_Note:24)                                 ; FF024D  c2 44 1f 60 27
	calr EditBar_SetRowFromNote                                      ; FF0252  1e a0 00
	ld wa, (EditCursor_TickInMeasure:24)                                ; FF0255  d2 54 1f 60 20
	ld (EditBar_Tick:24), wa                                ; FF025A  f2 38 1f 60 50
	bit	0, (EditScreen_Mode:24)                             ; FF025F  f2 70 1f 60 c8
	jr z, .LFF026F                                       ; FF0264  66 09
	ldw (EditBar_Length:24), 0x02                             ; FF0266  f2 3b 1f 60 02 02 00
	jr .LFF0279                                          ; FF026D  68 0a
.LFF026F:
	ld wa, (EditField_Length:24)                                ; FF026F  d2 47 1f 60 20
	ld (EditBar_Length:24), wa                                ; FF0274  f2 3b 1f 60 50
.LFF0279:
	calr EditBar_ClipLengthToView                                      ; FF0279  1e 59 00
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF027C  f1 40 25 00 01
	bit	0, (EditScreen_Mode:24)                             ; FF0281  f2 70 1f 60 c8
	jr z, .LFF028D                                       ; FF0286  66 05
	calr LCD_FillRect_Grown2Rows                                      ; FF0288  1e 67 ff
	jr .LFF0293                                          ; FF028B  68 06
.LFF028D:
	calr NoteEdit_EventBarRect                                          ; FF028D  1e 7e fd
	ld a, 0x05:opc                                          ; FF0290  21 05
	swi 7                                                ; FF0292  ff
.LFF0293:
	ret                                                  ; FF0293  0e
; EditBar_LoadEventGeometry: for the note-on at the cursor: (0x601F38) = its tick in the view, (0x601F3A) = its row (EditBar_SetRowFromNote),
;   (0x601F3B) = its length (+5 & 0x7F) x 0x60 + (+4 & 0x7F), clipped (EditBar_ClipLengthToView).
EditBar_LoadEventGeometry:
	calr EditScreen_PositionAndMeasureStartTicks                                          ; FF0294  1e 91 a3
	sub XWA,XBC                                          ; FF0297  e9 a0
	ld (EditBar_Tick:24), wa                                ; FF0299  f2 38 1f 60 50
	calr BStoreCursor_ReadByte                                          ; FF029E  1e 91 1f
	ld L,A                                               ; FF02A1  c9 8f
	pushw hl                                             ; FF02A3  2b
	calr EditScreen_VisibleNoteRange                                          ; FF02A4  1e 0d fd
	popw hl                                              ; FF02A7  4b
	calr EditBar_SetRowFromNote                                      ; FF02A8  1e 4a 00
	calr BStoreCursor_Step                                          ; FF02AB  1e 56 1f
	calr BStoreCursor_Step                                          ; FF02AE  1e 53 1f
	calr BStoreCursor_ReadByte                                          ; FF02B1  1e 7e 1f
	xor BC,BC                                            ; FF02B4  d9 d1
	ld C,A                                               ; FF02B6  c9 8b
	pushw bc                                             ; FF02B8  29
	calr BStoreCursor_Step                                          ; FF02B9  1e 48 1f
	calr BStoreCursor_ReadByte                                          ; FF02BC  1e 73 1f
	popw bc                                              ; FF02BF  49
	and BC,0x007f                                        ; FF02C0  d9 cc 7f 00
	and A,0x7f                                           ; FF02C4  c9 cc 7f
	mul A,0x60                                           ; FF02C7  c9 08 60
	add WA,BC                                            ; FF02CA  d9 80
	ld (EditBar_Length:24), wa                                ; FF02CC  f2 3b 1f 60 50
	calr EditBar_ClipLengthToView                                      ; FF02D1  1e 01 00
	ret                                                  ; FF02D4  0e
; EditBar_ClipLengthToView: when (0x601F38) + the length passes EditMeasure_Beats x 0x60 - 1, (0x601F3B) = what is left to the view's end.
EditBar_ClipLengthToView:
	add wa, (EditBar_Tick:24)                            ; FF02D5  d2 38 1f 60 80
	ld c, (EditMeasure_Beats:24)                                 ; FF02DA  c2 75 1f 60 23
	mul C,0x60                                           ; FF02DF  cb 08 60
	dec 1,BC                                             ; FF02E2  d9 69
	cp WA,BC                                             ; FF02E4  d9 f0
	jr ule, .LFF02F4                                     ; FF02E6  63 0c
	ld WA,BC                                             ; FF02E8  d9 88
	sub wa, (EditBar_Tick:24)                            ; FF02EA  d2 38 1f 60 a0
	ld (EditBar_Length:24), wa                                ; FF02EF  f2 3b 1f 60 50
.LFF02F4:
	ret                                                  ; FF02F4  0e
; EditBar_SetRowFromNote: (note L, low A): DRUM EDIT row = 11 - (L - A), the list running top-down; NOTE EDIT row = L - A, + 4 at
;   NoteEdit_RulerPosition 0.
EditBar_SetRowFromNote:
	bit	0, (EditScreen_Mode:24)                             ; FF02F5  f2 70 1f 60 c8
	jr z, .LFF0309                                       ; FF02FA  66 0d
	sub L,A                                              ; FF02FC  c9 a7
	ld h, 0x0b:opc                                          ; FF02FE  26 0b
	sub H,L                                              ; FF0300  cf a6
	ld (EditBar_Row:24), h                                 ; FF0302  f2 3a 1f 60 46
	jr .LFF031E                                          ; FF0307  68 15
.LFF0309:
	sub L,A                                              ; FF0309  c9 a7
	ld (EditBar_Row:24), l                                 ; FF030B  f2 3a 1f 60 47
	cp	(NoteEdit_RulerPosition:24), 0x00                          ; FF0310  c2 53 1f 60 3f 00
	jr nz, .LFF031E                                      ; FF0316  6e 06
	add	(EditBar_Row:24), 0x04                          ; FF0318  c2 3a 1f 60 38 04
.LFF031E:
	ret                                                  ; FF031E  0e
; EditScreen_PaintStaticLayer: layer 2: Paint_DrumEdit or Paint_NoteEdit, then EditScreen_DrawTrackNumber, _DrawSongNumber,
;   _DrawRowGuides and _DrawGridLines.
EditScreen_PaintStaticLayer:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF031F  f1 40 25 00 02
	bit	0, (EditScreen_Mode:24)                             ; FF0324  f2 70 1f 60 c8
	jr z, .LFF0330                                       ; FF0329  66 05
	calr Paint_DrumEdit                                      ; FF032B  1e 21 00
	jr .LFF0333                                          ; FF032E  68 03
.LFF0330:
	calr Paint_NoteEdit                                      ; FF0330  1e 0d 00
.LFF0333:
	calr EditScreen_DrawTrackNumber                                      ; FF0333  1e 28 00
	calr EditScreen_DrawSongNumber                                            ; FF0336  1e 50 00
	calr EditScreen_DrawRowGuides                                          ; FF0339  1e cf 05
	calr EditScreen_DrawGridLines                                          ; FF033C  1e 02 05
	ret                                                  ; FF033F  0e
; Paint_NoteEdit -- paints the screen whose own text reads "NOTE EDIT", "TRACK", "SONG"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xFF034A  interpreter A  list 0xFF0F11  DisplayList_NoteEditTrackSong
;        text: "NOTE EDIT"; "TRACK"; "SONG"; "PLAY"; "GRAPH"; "ERS"
; Evidence: the list address is the `ld XIY,0x00FF0F11` IMMEDIATE at the
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
Paint_NoteEdit:
	ld XIY,DisplayList_NoteEditTrackSong                 ; FF0340  45 11 0f ff 00
	ld XIX,DisplayList_DrumEditTrackSong                 ; FF0345  44 e0 10 ff 00
	call T_DisplayList_Run                               ; FF034A  1d f0 17 f4
	ret                                                  ; FF034E  0e
; Paint_DrumEdit -- paints the screen whose own text reads "DRUM EDIT", "TRACK", "SONG"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xFF0359  interpreter A  list 0xFF10E0  DisplayList_DrumEditTrackSong
;        text: "DRUM EDIT"; "TRACK"; "SONG"; "PLAY"; "SOUND"; "ERS"
; Evidence: the list address is the `ld XIY,0x00FF10E0` IMMEDIATE at the
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
Paint_DrumEdit:
	ld XIY,DisplayList_DrumEditTrackSong                 ; FF034F  45 e0 10 ff 00
	ld XIX,DisplayList_NoteEditPartSelect                ; FF0354  44 32 13 ff 00
	call T_DisplayList_Run                               ; FF0359  1d f0 17 f4
	ret                                                  ; FF035D  0e
; EditScreen_DrawTrackNumber -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 9
; instructions to its first `ret`:
;     site 0xFF037A  interpreter B  list 0xFF037F-0xFF0389
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawTrackNumber: (0x26B0) = EditScreen_Part + 1 through EditScreen_DrawTrackNumber_DL -- the TRACK value of 'NOTE EDIT  TRACK  SONG'.
EditScreen_DrawTrackNumber:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF035E  f1 40 25 00 02
	xor WA,WA                                            ; FF0363  d8 d0
	ld a, (EditScreen_Part:24)                                 ; FF0365  c2 00 1f 60 21
	inc 1,A                                              ; FF036A  c9 61
	ld (0x26b0:16), wa                                  ; FF036C  f1 b0 26 50
	ld XIY,EditScreen_DrawTrackNumber_DL                            ; FF0370  45 7f 03 ff 00
	ld XIX,EditScreen_DrawSongNumber                                    ; FF0375  44 89 03 ff 00
	call T_DisplayListB_Run                              ; FF037A  1d f4 17 f4
	ret                                                  ; FF037E  0e

; EditScreen_DrawTrackNumber_DL -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF037F and land exactly on 0xFF0389.
EditScreen_DrawTrackNumber_DL:
; ; drawn (start operand) by EditScreen_DrawTrackNumber -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=152, y=3, digits=2
; EditScreen_DrawSongNumber -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 9
; instructions to its first `ret`:
;     site 0xFF03A4  interpreter B  list 0xFF03A9-0xFF03B3
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawSongNumber: (0x26B0) = BStore_CurrentBank + 1 through EditScreen_DrawSongNumber_DL -- the SONG value.
EditScreen_DrawSongNumber:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF0389  f1 40 25 00 02
	xor WA,WA                                            ; FF038E  d8 d0
	ld a, (BStore_CurrentBank:16)                                   ; FF0390  c1 0a 36 21
	inc 1,A                                              ; FF0394  c9 61
	ld (0x26b0:16), wa                                  ; FF0396  f1 b0 26 50
	ld XIY,EditScreen_DrawSongNumber_DL                            ; FF039A  45 a9 03 ff 00
	ld XIX,EditScreen_DrawRulersAndLegend                                    ; FF039F  44 b3 03 ff 00
	call T_DisplayListB_Run                              ; FF03A4  1d f4 17 f4
	ret                                                  ; FF03A8  0e

; EditScreen_DrawSongNumber_DL -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF03A9 and land exactly on 0xFF03B3.
EditScreen_DrawSongNumber_DL:
; ; drawn (start operand) by EditScreen_DrawSongNumber -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=288, y=3, digits=2
; EditScreen_DrawRulersAndLegend: layer 2: EditScreen_DrawMeasureStartLines, NoteEdit_DrawKeyboardRuler, Screen_DrawKitCategoryLegend.
EditScreen_DrawRulersAndLegend:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF03B3  f1 40 25 00 02
	calr EditScreen_DrawMeasureStartLines                                          ; FF03B8  1e 0a 04
	calr NoteEdit_DrawKeyboardRuler                                          ; FF03BB  1e 7e 89
	calr Screen_DrawKitCategoryLegend                    ; FF03BE  1e 01 00
	ret                                                  ; FF03C1  0e
; ---------------------------------------------------------------------
; Screen_DrawKitCategoryLegend -- draw the 6-character kit legend at x=0xD5
; Called from: 0xFF03BE (`calr`), the tail of the routine at 0xFF03B3.
; Inputs:  bit 0 of (0x601F70) -- if it is CLEAR the routine draws nothing.
; Outputs: six characters on the display, and SWI7 service 0x17 called with
;          (0x2530) = 0x00D5, (0x2532) = 0x0006, XIY = the base, HL = the
;          index, BC = 6.
; Evidence: the literal coordinate stores at 0xFF03D1 and 0xFF03D7, the two
;          `calr`s to KitCategoryLegend_Index and _SelectBase, and
;          `ld BC,0x0006 / ld A,0x17 / swi 7` at 0xFF03E2-0xFF03E7.
;          ★ BC is the entry WIDTH: it is the same register the whole module
;          uses for it, 1 for Digits_FEF999 and 6 here.
; Drawn on: DRUM EDIT only -- bit 0 of (0x601F70) is EditScreen_Mode's DRUM EDIT
;          bit (FINDINGS-prom_a-screen-module.md section 8), and a drum-kit
;          category legend has no place in NOTE EDIT.
; ---------------------------------------------------------------------
Screen_DrawKitCategoryLegend:
	bit	0, (EditScreen_Mode:24)                             ; FF03C2  f2 70 1f 60 c8
	jr z, .LFF03E8                                       ; FF03C7  66 1f
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF03C9  f1 40 25 00 02
	calr KitCategoryLegend_Index                         ; FF03CE  1e 6b 00
	ldw (LCD_X0:16), 0xd5                                ; FF03D1  f1 30 25 02 d5 00
	ldw (LCD_Y0:16), 0x06                                ; FF03D7  f1 32 25 02 06 00
	pushw hl                                             ; FF03DD  2b
	calr KitCategoryLegend_SelectBase                    ; FF03DE  1e 08 00
	popw hl                                              ; FF03E1  4b
	ldw bc, 0x06                                         ; FF03E2  31 06 00
	ld a, 0x17:opc                                          ; FF03E5  21 17
	swi 7                                                ; FF03E7  ff
.LFF03E8:
	ret                                                  ; FF03E8  0e
; ---------------------------------------------------------------------
; KitCategoryLegend_SelectBase -- XIY := the legend table for the selected part
; Called from: 0xFF03DE (`calr`), inside the routine that then issues SWI7
;          service 0x17 with BC = 6.
; Inputs:  (0x601F00), the selected part; the byte table at RAM 0x00603422;
;          RecordPtrs_RAM76A2 (0xFEB330) and the 64-byte records it points at.
; Outputs: XIY = one of five bases -- 0xFF0485 (type 0x20, the GM drum-kit
;          legends), 0xFF079D (0x28, "user1 "), 0xFF07AB (0x29, "user2 "),
;          0xFF07B9 (0x30, "ext   "), or 0xFF047F (six spaces) for anything
;          else.  A, WA, XIX, XIY clobbered.
; Evidence: `ld XIX,0x00603422 / ld A,(0x601F00) / ld A,(XIX+A) /
;          ld XIY,0x00FEB330 / sll 2,WA / ld XIX,(XIY+A) / ld A,(XIX+0x01)`
;          then the five-way compare.  ★ That is the SAME five-way switch on
;          the SAME +0x01 type byte that 0xFEB2E3 uses to pick a drum-NAME
;          block, so the legend table and the name table are indexed by one
;          object.
; Unknown:  what types 0x28/0x29/0x30 mean beyond their own legends.
; ---------------------------------------------------------------------
KitCategoryLegend_SelectBase:
	ld XIX,BStore_TrackToPart                                    ; FF03E9  44 22 34 60 00
	ld a, (EditScreen_Part:24)                                 ; FF03EE  c2 00 1f 60 21
	ld	a, (xix+a)                                   ; FF03F3  c3 03 f0 e0 21
	ld XIY,RecordPtrs_RAM76A2                            ; FF03F8  45 30 b3 fe 00
	xor W,W                                              ; FF03FD  c8 d0
	sll wa, 0x02                                         ; FF03FF  d8 ee 02
	ld	xix, (xiy+a)                                 ; FF0402  e3 03 f4 e0 24
; ---------------------------------------------------------------------
; KitCategoryLegend_SelectByKitCode -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: nothing in either image names this address.
;
;     0xFF041E loads 0xFF047F, where the ROM reads:
;        "      STANDR                                    "
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; KitCategoryLegend_SelectByKitCode: XIY = the legend table for the kit code (XIX+1): 0x20 KitCategoryLegends_ByProgram, 0x28 _User1, 0x29 _User2,
;   0x30 _Ext, otherwise KitCategoryLegends.  No call to it is decoded.
KitCategoryLegend_SelectByKitCode:
	ld A,(XIX+0x01)                                      ; FF0407  8c 01 21
	cp A,0x20                                            ; FF040A  c9 cf 20
	jr z, .LFF0424                                       ; FF040D  66 15
	cp A,0x28                                            ; FF040F  c9 cf 28
	jr z, .LFF042A                                       ; FF0412  66 16
	cp A,0x29                                            ; FF0414  c9 cf 29
	jr z, .LFF0430                                       ; FF0417  66 17
	cp A,0x30                                            ; FF0419  c9 cf 30
	jr z, .LFF0436                                       ; FF041C  66 18
	ld XIY,KitCategoryLegends                            ; FF041E  45 7f 04 ff 00
	ret                                                  ; FF0423  0e
.LFF0424:
	ld XIY,KitCategoryLegends_ByProgram                        ; FF0424  45 85 04 ff 00
	ret                                                  ; FF0429  0e
.LFF042A:
	ld XIY,KitCategoryLegend_User1                      ; FF042A  45 9d 07 ff 00
	ret                                                  ; FF042F  0e
.LFF0430:
	ld XIY,KitCategoryLegend_User2                      ; FF0430  45 ab 07 ff 00
	ret                                                  ; FF0435  0e
.LFF0436:
	ld XIY,KitCategoryLegend_Ext                      ; FF0436  45 b9 07 ff 00
	ret                                                  ; FF043B  0e
; ---------------------------------------------------------------------
; KitCategoryLegend_Index -- HL := the index into that legend table
; Called from: 0xFF03CE (`calr`), immediately before the coordinates are set.
; Inputs:  the same chain as KitCategoryLegend_SelectBase.
; Outputs: HL = the record's +0x00 byte when the type is 0x20, and 0 for types
;          0x28, 0x29, 0x30 and for anything else -- which is why those three
;          bases each need only their own single 6-character entry.
; Evidence: `ld A,(XIX+0x00) / xor HL,HL / ld L,A / ret` on the 0x20 arm,
;          `xor HL,HL / ret` on the others.
; Unknown:  nothing here.
; ---------------------------------------------------------------------
KitCategoryLegend_Index:
	ld XIX,BStore_TrackToPart                                    ; FF043C  44 22 34 60 00
	ld a, (EditScreen_Part:24)                                 ; FF0441  c2 00 1f 60 21
	ld	a, (xix+a)                                   ; FF0446  c3 03 f0 e0 21
	ld XIY,RecordPtrs_RAM76A2                            ; FF044B  45 30 b3 fe 00
	xor W,W                                              ; FF0450  c8 d0
	sll wa, 0x02                                         ; FF0452  d8 ee 02
	ld	xix, (xiy+a)                                 ; FF0455  e3 03 f4 e0 24
	ld A,(XIX+0x01)                                      ; FF045A  8c 01 21
	cp A,0x20                                            ; FF045D  c9 cf 20
	jr z, .LFF0474                                       ; FF0460  66 12
	cp A,0x28                                            ; FF0462  c9 cf 28
	jr z, .LFF047C                                       ; FF0465  66 15
	cp A,0x29                                            ; FF0467  c9 cf 29
	jr z, .LFF047C                                       ; FF046A  66 10
	cp A,0x30                                            ; FF046C  c9 cf 30
	jr z, .LFF047C                                       ; FF046F  66 0b
	xor HL,HL                                            ; FF0471  db d3
	ret                                                  ; FF0473  0e
.LFF0474:
	ld	a, (xix+0:8)                                 ; FF0474  8c 00 21
	xor HL,HL                                            ; FF0477  db d3
	ld L,A                                               ; FF0479  c9 8f
	ret                                                  ; FF047B  0e
.LFF047C:
	xor HL,HL                                            ; FF047C  db d3
	ret                                                  ; FF047E  0e
; ---------------------------------------------------------------------
; KitCategoryLegends -- the six-character legends the drum screens show
;
; ★ FOUR BASES, ONE TABLE, and the routine at 0xFF03E9 picks between them
;   by the TYPE BYTE of a RecordPtrs_RAM76A2 record:
;     type 0x20  -> 0xFF0485, indexed by the record's +0x00 byte
;     type 0x28  -> 0xFF079D  "user1 "
;     type 0x29  -> 0xFF07AB  "user2 "
;     type 0x30  -> 0xFF07B9  "ext   "
;     anything else -> 0xFF047F, six spaces
;   -- the same five-way switch on the same +0x01 type byte that
;   0xFEB2E3 uses to choose a drum-NAME block, so the two tables are
;   indexed by the same object.
;
; HOW IT IS DRAWN, and where the width comes from: 0xFF03D1 writes
;   (0x2530) = 0x00D5 and (0x2532) = 0x0006, calls 0xFF043C for the index
;   in HL and 0xFF03E9 for the base in XIY, then `ld BC,0x0006 / ld A,0x17
;   / swi 7`.  BC = 6 is the entry WIDTH.
;
; ★ THE INDEX IS THE DRUM PROGRAM NUMBER, ZERO-BASED, and the legends are the
;   General MIDI drum-kit map.  From base 0xFF0485, index 0 is STANDR, 8 ROOM,
;   16 POWER, 24 ELEC, 32 JAZZ, 40 BRUSH, 48 GMOrch -- which is GM's
;   Standard/Room/Power/Electronic/Jazz/Brush/Orchestra kits at MIDI programs
;   1, 9, 17, 25, 33, 41, 49 MINUS ONE.  Technics fills the gaps (9 LIGHT,
;   10 FUNK, 25 SOUL, 26 DANCE, 27 HOUSE, 29 SYNTH, 30 MODEL, 33 TRAD,
;   112 ORCH, 120 SE) and everything else is blank.
;   ★ The test is a KEYWORD test WITH A NEGATIVE CONTROL, in
;   `python3 notes/gen_prom_a_screens.py --check`: 7/7 of the GM kits land on
;   their own index and 0/7 land one either side.  A first draft used the
;   1-based numbers against base 0xFF047F and scored 0/7 and 7/7 at shift -1,
;   which is exactly what an off-by-one looks like when the control is there.
;   LAST-ENTRY TEST: the highest non-blank entry is 120, "SE    ", at 0xFF0755.
;
;   ⚠ RETRACTED 2026-08-25 (round-2 audit F2).  This header said: "130
;   entries x 6 = 780 bytes from 0xFF047F ends at 0xFF078B, and 130 is exactly
;   the entry count of DrumKitNameBlockPtrs (0xFEB3BC) -- two tables written
;   independently agreeing on the program count."  BOTH halves were wrong.
;   (a) OFF BY ONE ENTRY.  The arithmetic starts from 0xFF047F, the six-space
;   DEFAULT entry the switch hands back for an unrecognised type, which is one
;   entry BELOW index 0.  Index 0 is 0xFF0485, and from there 130 x 6 = 780
;   bytes end at 0xFF0791 -- which is what this lane's own generator has always
;   printed ("entry 130 would start at 0xFF0791"): the shipped comment and the
;   shipped check script disagreed by a whole entry.
;   (b) NOT TWO WITNESSES.  This table's own bytes show no 130 boundary at all:
;   entries 121 through 131 are ALL SPACES, and (0xFF079D - 0xFF0485)/6 = 132
;   whole entries fit before the next base with no remainder.  The 130 comes
;   only from DrumKitNameBlockPtrs, whose own header (see 0xFEB3BC) says its
;   count is EXTENT-derived with "no bound in the reader".  One extent quoted
;   twice is not two tables agreeing.
;   ★ WHAT SURVIVES: the base (0xFF0485), the 6-byte stride, the GM mapping
;   with its negative control, and the highest labelled entry (120).  The entry
;   COUNT is not established by this table -- 130 is a floor from the pointer
;   table and 132 is the ceiling this region admits.  Re-derived by
;   `python3 notes/prom_a_round3_checks.py` (section KitCategoryLegends).
;
; ⚠ The last 52 bytes, 0xFF0791-0xFF07C4, are NOT on that 6-byte grid.  The
;   run ENDS at 0xFF07C4: 0xFF07C5 is the first byte of EditScreen_DrawMeasureStartLines, so an
;   inclusive range written "-0xFF07C5" would end on an instruction.
;   Twelve blank bytes, then the three literal legends the type switch points
;   at -- 0xFF079D "user1 ", 0xFF07AB "user2 ", 0xFF07B9 "ext   " -- on a
;   14-byte stride, and each of the three is stored TWICE:
;   "user1  user1  ", "user2  user2  ", "ext   ext   " (the third pair is 12
;   bytes, not 14, because it runs into EditScreen_DrawMeasureStartLines).
;   ⚠ Unknown: why the duplicate.  It is NOT a second reader -- a 24-bit and
;   32-bit little-endian immediate scan of ALL FOUR ROM images finds the three
;   switch bases exactly once each -- as the OPERAND of the `ld XIY` at
;   0xFF042A, 0xFF0430 and 0xFF0436, one byte into each instruction -- and finds
;   the second copies 0xFF07A4, 0xFF07B2, 0xFF07BF ZERO times.
;   They are emitted in the same block because the region is contiguous and the
;   ROM gives no boundary; the bases are in the switch, above.
; ---------------------------------------------------------------------

KitCategoryLegends:
	.ascii "      "                                ; FF047F  default (any other type)
; ---------------------------------------------------------------------
; KitCategoryLegends_ByProgram -- 132 six-character legends, index = the drum
;          program (the record's +0x00 byte, KitCategoryLegend_Index).
; Read by: KitCategoryLegend_SelectBase's type-0x20 arm, `ld XIY,<this>` at
;          0xFF0424; drawn 6 characters wide (BC = 6, see the header above
;          KitCategoryLegends).  COUNT 132 by abutment: KitCategoryLegend_User1
;          follows; entries 121-131 are blank, 120 ("SE") is the last legend.
;          (notes/proma-2026-09-25/ascii_kit_legends.py)
; ---------------------------------------------------------------------
KitCategoryLegends_ByProgram:
	.ascii "STANDR"                                ; FF0485  [  0]
	.ascii "      "                                ; FF048B  [  1]
	.ascii "      "                                ; FF0491  [  2]
	.ascii "      "                                ; FF0497  [  3]
	.ascii "      "                                ; FF049D  [  4]
	.ascii "      "                                ; FF04A3  [  5]
	.ascii "      "                                ; FF04A9  [  6]
	.ascii "      "                                ; FF04AF  [  7]
	.ascii "ROOM  "                                ; FF04B5  [  8]
	.ascii "LIGHT "                                ; FF04BB  [  9]
	.ascii "FUNK  "                                ; FF04C1  [ 10]
	.ascii "      "                                ; FF04C7  [ 11]
	.ascii "      "                                ; FF04CD  [ 12]
	.ascii "      "                                ; FF04D3  [ 13]
	.ascii "      "                                ; FF04D9  [ 14]
	.ascii "      "                                ; FF04DF  [ 15]
	.ascii "POWER "                                ; FF04E5  [ 16]
	.ascii "      "                                ; FF04EB  [ 17]
	.ascii "      "                                ; FF04F1  [ 18]
	.ascii "      "                                ; FF04F7  [ 19]
	.ascii "      "                                ; FF04FD  [ 20]
	.ascii "      "                                ; FF0503  [ 21]
	.ascii "      "                                ; FF0509  [ 22]
	.ascii "      "                                ; FF050F  [ 23]
	.ascii "ELEC  "                                ; FF0515  [ 24]
	.ascii "SOUL  "                                ; FF051B  [ 25]
	.ascii "DANCE "                                ; FF0521  [ 26]
	.ascii "HOUSE "                                ; FF0527  [ 27]
	.ascii "      "                                ; FF052D  [ 28]
	.ascii "SYNTH "                                ; FF0533  [ 29]
	.ascii "MODEL "                                ; FF0539  [ 30]
	.ascii "      "                                ; FF053F  [ 31]
	.ascii "JAZZ  "                                ; FF0545  [ 32]
	.ascii "TRAD  "                                ; FF054B  [ 33]
	.ascii "      "                                ; FF0551  [ 34]
	.ascii "      "                                ; FF0557  [ 35]
	.ascii "      "                                ; FF055D  [ 36]
	.ascii "      "                                ; FF0563  [ 37]
	.ascii "      "                                ; FF0569  [ 38]
	.ascii "      "                                ; FF056F  [ 39]
	.ascii "BRUSH "                                ; FF0575  [ 40]
	.ascii "      "                                ; FF057B  [ 41]
	.ascii "      "                                ; FF0581  [ 42]
	.ascii "      "                                ; FF0587  [ 43]
	.ascii "      "                                ; FF058D  [ 44]
	.ascii "      "                                ; FF0593  [ 45]
	.ascii "      "                                ; FF0599  [ 46]
	.ascii "      "                                ; FF059F  [ 47]
	.ascii "GMOrch"                                ; FF05A5  [ 48]
	.ascii "      "                                ; FF05AB  [ 49]
	.ascii "      "                                ; FF05B1  [ 50]
	.ascii "      "                                ; FF05B7  [ 51]
	.ascii "      "                                ; FF05BD  [ 52]
	.ascii "      "                                ; FF05C3  [ 53]
	.ascii "      "                                ; FF05C9  [ 54]
	.ascii "      "                                ; FF05CF  [ 55]
	.ascii "      "                                ; FF05D5  [ 56]
	.ascii "      "                                ; FF05DB  [ 57]
	.ascii "      "                                ; FF05E1  [ 58]
	.ascii "      "                                ; FF05E7  [ 59]
	.ascii "      "                                ; FF05ED  [ 60]
	.ascii "      "                                ; FF05F3  [ 61]
	.ascii "      "                                ; FF05F9  [ 62]
	.ascii "      "                                ; FF05FF  [ 63]
	.ascii "      "                                ; FF0605  [ 64]
	.ascii "      "                                ; FF060B  [ 65]
	.ascii "      "                                ; FF0611  [ 66]
	.ascii "      "                                ; FF0617  [ 67]
	.ascii "      "                                ; FF061D  [ 68]
	.ascii "      "                                ; FF0623  [ 69]
	.ascii "      "                                ; FF0629  [ 70]
	.ascii "      "                                ; FF062F  [ 71]
	.ascii "      "                                ; FF0635  [ 72]
	.ascii "      "                                ; FF063B  [ 73]
	.ascii "      "                                ; FF0641  [ 74]
	.ascii "      "                                ; FF0647  [ 75]
	.ascii "      "                                ; FF064D  [ 76]
	.ascii "      "                                ; FF0653  [ 77]
	.ascii "      "                                ; FF0659  [ 78]
	.ascii "      "                                ; FF065F  [ 79]
	.ascii "      "                                ; FF0665  [ 80]
	.ascii "      "                                ; FF066B  [ 81]
	.ascii "      "                                ; FF0671  [ 82]
	.ascii "      "                                ; FF0677  [ 83]
	.ascii "      "                                ; FF067D  [ 84]
	.ascii "      "                                ; FF0683  [ 85]
	.ascii "      "                                ; FF0689  [ 86]
	.ascii "      "                                ; FF068F  [ 87]
	.ascii "      "                                ; FF0695  [ 88]
	.ascii "      "                                ; FF069B  [ 89]
	.ascii "      "                                ; FF06A1  [ 90]
	.ascii "      "                                ; FF06A7  [ 91]
	.ascii "      "                                ; FF06AD  [ 92]
	.ascii "      "                                ; FF06B3  [ 93]
	.ascii "      "                                ; FF06B9  [ 94]
	.ascii "      "                                ; FF06BF  [ 95]
	.ascii "      "                                ; FF06C5  [ 96]
	.ascii "      "                                ; FF06CB  [ 97]
	.ascii "      "                                ; FF06D1  [ 98]
	.ascii "      "                                ; FF06D7  [ 99]
	.ascii "      "                                ; FF06DD  [100]
	.ascii "      "                                ; FF06E3  [101]
	.ascii "      "                                ; FF06E9  [102]
	.ascii "      "                                ; FF06EF  [103]
	.ascii "      "                                ; FF06F5  [104]
	.ascii "      "                                ; FF06FB  [105]
	.ascii "      "                                ; FF0701  [106]
	.ascii "      "                                ; FF0707  [107]
	.ascii "      "                                ; FF070D  [108]
	.ascii "      "                                ; FF0713  [109]
	.ascii "      "                                ; FF0719  [110]
	.ascii "      "                                ; FF071F  [111]
	.ascii "ORCH  "                                ; FF0725  [112]
	.ascii "      "                                ; FF072B  [113]
	.ascii "      "                                ; FF0731  [114]
	.ascii "      "                                ; FF0737  [115]
	.ascii "      "                                ; FF073D  [116]
	.ascii "      "                                ; FF0743  [117]
	.ascii "      "                                ; FF0749  [118]
	.ascii "      "                                ; FF074F  [119]
	.ascii "SE    "                                ; FF0755  [120]
	.ascii "      "                                ; FF075B  [121]
	.ascii "      "                                ; FF0761  [122]
	.ascii "      "                                ; FF0767  [123]
	.ascii "      "                                ; FF076D  [124]
	.ascii "      "                                ; FF0773  [125]
	.ascii "      "                                ; FF0779  [126]
	.ascii "      "                                ; FF077F  [127]
	.ascii "      "                                ; FF0785  [128]
	.ascii "      "                                ; FF078B  [129]
	.ascii "      "                                ; FF0791  [130]
	.ascii "      "                                ; FF0797  [131]
; KitCategoryLegend_User1 -- the legend for record type 0x28: `ld XIY,<this>` at 0xFF042A;
;          KitCategoryLegend_Index returns 0 for this type, so the first six
;          characters are what is drawn.  14 bytes: the legend twice (see the
;          header above KitCategoryLegends).
KitCategoryLegend_User1:
	.ascii "user1  user1  "                        ; FF079D
; KitCategoryLegend_User2 -- the legend for record type 0x29: `ld XIY,<this>` at 0xFF0430;
;          KitCategoryLegend_Index returns 0 for this type, so the first six
;          characters are what is drawn.  14 bytes: the legend twice (see the
;          header above KitCategoryLegends).
KitCategoryLegend_User2:
	.ascii "user2  user2  "                        ; FF07AB
; KitCategoryLegend_Ext -- the legend for record type 0x30: `ld XIY,<this>` at 0xFF0436;
;          KitCategoryLegend_Index returns 0 for this type, so the first six
;          characters are what is drawn.  12 bytes: the legend twice (see the
;          header above KitCategoryLegends).
KitCategoryLegend_Ext:
	.ascii "ext   ext   "                        ; FF07B9
; EditScreen_DrawMeasureStartLines: layer 2: at each beat column whose EditScreen_BeatTable entry (from the second) is non-zero -- a measure
;   start -- a solid vertical line (SWI 7 2, LCD_Svc_02_DrawVLine): x = 0x10 + 24 n, y 0x29..0xA8 (NOTE EDIT) or
;   x = 0x59 + 24 n, y 0x2A..0xA1 (DRUM EDIT).
EditScreen_DrawMeasureStartLines:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF07C5  f1 40 25 00 02
	ld XIX,0x00601f60                                    ; FF07CA  44 60 1f 60 00
	ld e, 0x01:opc                                          ; FF07CF  25 01
.LFF07D1:
	ld A,(XIX)                                           ; FF07D1  84 21
	cp a, 0x00:i3                                          ; FF07D3  c9 d8
	jr z, .LFF0825                                       ; FF07D5  66 4e
	bit	0, (EditScreen_Mode:24)                             ; FF07D7  f2 70 1f 60 c8
	jr z, .LFF07FF                                       ; FF07DC  66 21
	ldw (LCD_Y0:16), 0x2a                                ; FF07DE  f1 32 25 02 2a 00
	ldw (LCD_Y1:16), 0xa1                                ; FF07E4  f1 36 25 02 a1 00
	xor WA,WA                                            ; FF07EA  d8 d0
	ld A,E                                               ; FF07EC  cd 89
	mul A,0x18                                           ; FF07EE  c9 08 18
	add WA,0x0059                                        ; FF07F1  d8 c8 59 00
	ld (LCD_X0:16), wa                                  ; FF07F5  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FF07F9  f1 34 25 50
	jr .LFF081E                                          ; FF07FD  68 1f
.LFF07FF:
	ldw (LCD_Y0:16), 0x29                                ; FF07FF  f1 32 25 02 29 00
	ldw (LCD_Y1:16), 0xa8                                ; FF0805  f1 36 25 02 a8 00
	xor WA,WA                                            ; FF080B  d8 d0
	ld A,E                                               ; FF080D  cd 89
	mul A,0x18                                           ; FF080F  c9 08 18
	add WA,0x0010                                        ; FF0812  d8 c8 10 00
	ld (LCD_X0:16), wa                                  ; FF0816  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FF081A  f1 34 25 50
.LFF081E:
	ld a, 0x02:opc                                          ; FF081E  21 02
	push XIX                                             ; FF0820  3c
	pushw de                                             ; FF0821  2a
	swi 7                                                ; FF0822  ff
	popw de                                              ; FF0823  4a
	pop XIX                                              ; FF0824  5c
.LFF0825:
	add E,0x01                                           ; FF0825  cd c8 01
	add XIX,0x00000001                                   ; FF0828  ec c8 01 00 00 00
	ld XHL,EditScreen_BeatTable                                    ; FF082E  43 5f 1f 60 00
	xor XBC,XBC                                          ; FF0833  e9 d1
	ld c, (0x601f76:24)                                 ; FF0835  c2 76 1f 60 23
	add XHL,XBC                                          ; FF083A  e9 83
	cp XIX,XHL                                           ; FF083C  eb f4
	jr c, .LFF07D1                                       ; FF083E  67 91
	ret                                                  ; FF0840  0e
; EditScreen_DrawGridLines: DrumEdit_DrawBeatLines in DRUM EDIT, EditMeasure_DrawBeatLines in NOTE EDIT.
EditScreen_DrawGridLines:
	bit	0, (EditScreen_Mode:24)                             ; FF0841  f2 70 1f 60 c8
	jr z, .LFF084C                                       ; FF0846  66 04
	calr DrumEdit_DrawBeatLines                                      ; FF0848  1e 5f 00
	ret                                                  ; FF084B  0e
.LFF084C:
	calr EditMeasure_DrawBeatLines                                      ; FF084C  1e 01 00
	ret                                                  ; FF084F  0e
; EditMeasure_DrawBeatLines: layer 2: for beats 1 .. EditMeasure_Beats-1, at x = 0x10 + 24 x beat from y 0x29 to 0xA8, SWI 7 0x1B
;   (EraseRect) then 0x12 (LCD_Svc_12_DrawVLineDashed).
EditMeasure_DrawBeatLines:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF0850  f1 40 25 00 02
	ld e, 0x01:opc                                          ; FF0855  25 01
.LFF0857:
	ldw (LCD_Y0:16), 0x29                                ; FF0857  f1 32 25 02 29 00
	ldw (LCD_Y1:16), 0xa8                                ; FF085D  f1 36 25 02 a8 00
	xor WA,WA                                            ; FF0863  d8 d0
	ld A,E                                               ; FF0865  cd 89
	mul A,0x18                                           ; FF0867  c9 08 18
	add WA,0x0010                                        ; FF086A  d8 c8 10 00
	ld (LCD_X0:16), wa                                  ; FF086E  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FF0872  f1 34 25 50
	pushw de                                             ; FF0876  2a
	ld a, 0x1b:opc                                          ; FF0877  21 1b
	swi 7                                                ; FF0879  ff
	popw de                                              ; FF087A  4a
	pushw de                                             ; FF087B  2a
	ldw (LCD_Y0:16), 0x29                                ; FF087C  f1 32 25 02 29 00
	ldw (LCD_Y1:16), 0xa8                                ; FF0882  f1 36 25 02 a8 00
	xor WA,WA                                            ; FF0888  d8 d0
	ld A,E                                               ; FF088A  cd 89
	mul A,0x18                                           ; FF088C  c9 08 18
	add WA,0x0010                                        ; FF088F  d8 c8 10 00
	ld (LCD_X0:16), wa                                  ; FF0893  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FF0897  f1 34 25 50
	ld a, 0x12:opc                                          ; FF089B  21 12
	swi 7                                                ; FF089D  ff
	popw de                                              ; FF089E  4a
	add E,0x01                                           ; FF089F  cd c8 01
	cp	e, (EditMeasure_Beats:24)                             ; FF08A2  c2 75 1f 60 f5
	jr c, .LFF0857                                       ; FF08A7  67 ae
	ret                                                  ; FF08A9  0e
; DrumEdit_DrawBeatLines: layer 2: for beats 1 .. EditMeasure_Beats-1 at x = 0x59 + 24 x beat: SWI 7 0x1B (EraseRect) over y 0x2A..0xA1,
;   then DrumEdit_DrawDottedVLine.
DrumEdit_DrawBeatLines:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF08AA  f1 40 25 00 02
	ld e, 0x01:opc                                          ; FF08AF  25 01
.LFF08B1:
	ldw (LCD_Y0:16), 0x2a                                ; FF08B1  f1 32 25 02 2a 00
	ldw (LCD_Y1:16), 0xa1                                ; FF08B7  f1 36 25 02 a1 00
	xor WA,WA                                            ; FF08BD  d8 d0
	ld A,E                                               ; FF08BF  cd 89
	mul A,0x18                                           ; FF08C1  c9 08 18
	add WA,0x0059                                        ; FF08C4  d8 c8 59 00
	ld (LCD_X0:16), wa                                  ; FF08C8  f1 30 25 50
	ld (LCD_X1:16), wa                                  ; FF08CC  f1 34 25 50
	pushw de                                             ; FF08D0  2a
	ld a, 0x1b:opc                                          ; FF08D1  21 1b
	swi 7                                                ; FF08D3  ff
	popw de                                              ; FF08D4  4a
	pushw de                                             ; FF08D5  2a
	calr DrumEdit_DrawDottedVLine                                      ; FF08D6  1e 0c 00
	popw de                                              ; FF08D9  4a
	add E,0x01                                           ; FF08DA  cd c8 01
	cp	e, (EditMeasure_Beats:24)                             ; FF08DD  c2 75 1f 60 f5
	jr c, .LFF08B1                                       ; FF08E2  67 cd
	ret                                                  ; FF08E4  0e
; DrumEdit_DrawDottedVLine: a point (SWI 7 0x0B, LCD_Svc_0B_PlotPoint) every second row from y 0x2B to 0xA0.
DrumEdit_DrawDottedVLine:
	ldw bc, 0x2b                                         ; FF08E5  31 2b 00
.LFF08E8:
	ld A,E                                               ; FF08E8  cd 89
	mul A,0x18                                           ; FF08EA  c9 08 18
	add WA,0x0059                                        ; FF08ED  d8 c8 59 00
	ld (LCD_X0:16), wa                                  ; FF08F1  f1 30 25 50
	ld (LCD_Y0:16), bc                                  ; FF08F5  f1 32 25 51
	pushw bc                                             ; FF08F9  29
	pushw de                                             ; FF08FA  2a
	ld a, 0x0b:opc                                          ; FF08FB  21 0b
	swi 7                                                ; FF08FD  ff
	popw de                                              ; FF08FE  4a
	popw bc                                              ; FF08FF  49
	add BC,0x0002                                        ; FF0900  d9 c8 02 00
	cp BC,0x00a1                                         ; FF0904  d9 cf a1 00
	jr c, .LFF08E8                                       ; FF0908  67 de
	ret                                                  ; FF090A  0e
; EditScreen_DrawRowGuides: layer 2: DrumEdit_DrawRowGuides or NoteEdit_DrawRowGuides.
EditScreen_DrawRowGuides:
	ld (LCD_CurrentLayer:16), 0x02                                 ; FF090B  f1 40 25 00 02
	bit	0, (EditScreen_Mode:24)                             ; FF0910  f2 70 1f 60 c8
	jr z, .LFF091B                                       ; FF0915  66 04
	calr DrumEdit_DrawRowGuides                                      ; FF0917  1e 3a 00
	ret                                                  ; FF091A  0e
.LFF091B:
	calr NoteEdit_DrawRowGuides                                      ; FF091B  1e 01 00
	ret                                                  ; FF091E  0e
; NoteEdit_DrawRowGuides: 16 dotted rows (NoteEdit_DrawDottedHLine), 8 pixels apart from y 0x29.
NoteEdit_DrawRowGuides:
	xor C,C                                              ; FF091F  cb d3
	ldw hl, 0x29                                         ; FF0921  33 29 00
.LFF0924:
	pushw hl                                             ; FF0924  2b
	pushw bc                                             ; FF0925  29
	calr NoteEdit_DrawDottedHLine                                      ; FF0926  1e 0e 00
	popw bc                                              ; FF0929  49
	popw hl                                              ; FF092A  4b
	add HL,0x0008                                        ; FF092B  db c8 08 00
	inc 1,C                                              ; FF092F  cb 61
	cp C,0x10                                            ; FF0931  cb cf 10
	jr c, .LFF0924                                       ; FF0934  67 ee
	ret                                                  ; FF0936  0e
; NoteEdit_DrawDottedHLine: a point (SWI 7 0x0B) every third pixel from x 0x10 to 0xFF on row HL.
NoteEdit_DrawDottedHLine:
	ldw de, 0x10                                         ; FF0937  32 10 00
.LFF093A:
	ld (LCD_X0:16), de                                  ; FF093A  f1 30 25 52
	ld (LCD_Y0:16), hl                                  ; FF093E  f1 32 25 53
	pushw de                                             ; FF0942  2a
	pushw hl                                             ; FF0943  2b
	ld a, 0x0b:opc                                          ; FF0944  21 0b
	swi 7                                                ; FF0946  ff
	popw hl                                              ; FF0947  4b
	popw de                                              ; FF0948  4a
	add DE,0x0003                                        ; FF0949  da c8 03 00
	cp DE,0x0100                                         ; FF094D  da cf 00 01
	jr c, .LFF093A                                       ; FF0951  67 e7
	ret                                                  ; FF0953  0e
; DrumEdit_DrawRowGuides: 12 dotted rows (DrumEdit_DrawDottedHLine), 10 pixels apart from y 0x29.
DrumEdit_DrawRowGuides:
	xor C,C                                              ; FF0954  cb d3
	ldw hl, 0x29                                         ; FF0956  33 29 00
.LFF0959:
	pushw hl                                             ; FF0959  2b
	pushw bc                                             ; FF095A  29
	calr DrumEdit_DrawDottedHLine                                      ; FF095B  1e 0e 00
	popw bc                                              ; FF095E  49
	popw hl                                              ; FF095F  4b
	add HL,0x000a                                        ; FF0960  db c8 0a 00
	inc 1,C                                              ; FF0964  cb 61
	cp C,0x0c                                            ; FF0966  cb cf 0c
	jr c, .LFF0959                                       ; FF0969  67 ee
	ret                                                  ; FF096B  0e
; DrumEdit_DrawDottedHLine: a point every third pixel from x 0x59 to 0x100 on row HL.
DrumEdit_DrawDottedHLine:
	ldw de, 0x59                                         ; FF096C  32 59 00
.LFF096F:
	ld (LCD_X0:16), de                                  ; FF096F  f1 30 25 52
	ld (LCD_Y0:16), hl                                  ; FF0973  f1 32 25 53
	pushw de                                             ; FF0977  2a
	pushw hl                                             ; FF0978  2b
	ld a, 0x0b:opc                                          ; FF0979  21 0b
	swi 7                                                ; FF097B  ff
	popw hl                                              ; FF097C  4b
	popw de                                              ; FF097D  4a
	add DE,0x0003                                        ; FF097E  da c8 03 00
	cp DE,0x0101                                         ; FF0982  da cf 01 01
	jr c, .LFF096F                                       ; FF0986  67 e7
	ret                                                  ; FF0988  0e
; EditScreen_DrawMeasure -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 8
; instructions to its first `ret`:
;     site 0xFF09A7  interpreter B  list 0xFF09D8-0xFF09E7
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawMeasure: layer 0; EditCursor_Measure below 1000 is drawn as a number (EditScreen_DrawMeasure_DL2), otherwise the string '***.'
;   (EditScreen_DrawMeasure_DL1, string table entry 0 at 0xFF09E7).
EditScreen_DrawMeasure:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0989  f1 40 25 00 00
	cpw	(EditCursor_Measure:24), 0x03e8                        ; FF098E  d2 3f 1f 60 3f e8 03
	jr c, .LFF09AC                                       ; FF0995  67 15
	ldw (0x26b0:16), 0x00                                ; FF0997  f1 b0 26 02 00 00
	ld XIY,EditScreen_DrawMeasure_DL1                            ; FF099D  45 d8 09 ff 00
	ld XIX,Str_EditMeasureOverflow                                    ; FF09A2  44 e7 09 ff 00
	call T_DisplayListB_Run                              ; FF09A7  1d f4 17 f4
	ret                                                  ; FF09AB  0e
.LFF09AC:
	ld wa, (EditCursor_Measure:24)                                ; FF09AC  d2 3f 1f 60 20
	ld (0x26b0:16), wa                                  ; FF09B1  f1 b0 26 50
	ld XIY,EditScreen_DrawMeasure_DL2                            ; FF09B5  45 eb 09 ff 00
	ld XIX,EditScreen_DrawMeasure_DL3                            ; FF09BA  44 f5 09 ff 00
	call T_DisplayListB_Run                              ; FF09BF  1d f4 17 f4
	ldw (0x26b0:16), 0x00                                ; FF09C3  f1 b0 26 02 00 00
	ld XIY,EditScreen_DrawMeasure_DL3                            ; FF09C9  45 f5 09 ff 00
	ld XIX,EditScreen_DrawBeat                                    ; FF09CE  44 04 0a ff 00
	call T_DisplayListB_Run                              ; FF09D3  1d f4 17 f4
	ret                                                  ; FF09D7  0e

; EditScreen_DrawMeasure_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF09D8 and land exactly on 0xFF09E7.
EditScreen_DrawMeasure_DL1:
; ; drawn (start operand) by EditScreen_DrawMeasure -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow, width=4, x=8, y=179
; The 4-character string EditScreen_DrawMeasure_DL1's op-02 record draws (string table, 4 bytes per entry, entry 0):
; EditScreen_DrawMeasure shows it instead of the measure number when EditCursor_Measure >= 1000.  It was decoded as
; `pushw de` x3 / `pushw iz`; it is also that list's end bound (XIX).  (2026-10-04)
Str_EditMeasureOverflow:
	.ascii "***."                                        ; FF09E7  2a 2a 2a 2e

; EditScreen_DrawMeasure_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF09EB and land exactly on 0xFF09F5.
EditScreen_DrawMeasure_DL2:
; ; drawn (start operand) by EditScreen_DrawMeasure -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=8, y=179, digits=3

; EditScreen_DrawMeasure_DL3 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF09F5 and land exactly on 0xFF0A04.
EditScreen_DrawMeasure_DL3:
; ; drawn (start operand) by EditScreen_DrawMeasure -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow+0x3, width=1, x=32, y=179
; EditScreen_DrawBeat -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 2 time(s) in the 13
; instructions to its first `ret`:
;     site 0xFF0A20  interpreter B  list 0xFF0A39-0xFF0A43
;     site 0xFF0A34  interpreter B  list 0xFF0A43-0xFF0A52
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawBeat: layer 0; EditCursor_Beat + 1 to 0x26B0, EditScreen_DrawBeat_DL1 (op 06, digits).
EditScreen_DrawBeat:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0A04  f1 40 25 00 00
	xor WA,WA                                            ; FF0A09  d8 d0
	ld wa, (EditCursor_Beat:24)                                ; FF0A0B  d2 41 1f 60 20
	inc 1,WA                                             ; FF0A10  d8 61
	ld (0x26b0:16), wa                                  ; FF0A12  f1 b0 26 50
	ld XIY,EditScreen_DrawBeat_DL1                            ; FF0A16  45 39 0a ff 00
	ld XIX,EditScreen_DrawBeat_DL2                            ; FF0A1B  44 43 0a ff 00
	call T_DisplayListB_Run                              ; FF0A20  1d f4 17 f4
	ldw (0x26b0:16), 0x00                                ; FF0A24  f1 b0 26 02 00 00
	ld XIY,EditScreen_DrawBeat_DL2                            ; FF0A2A  45 43 0a ff 00
	ld XIX,EditScreen_DrawTick                                    ; FF0A2F  44 52 0a ff 00
	call T_DisplayListB_Run                              ; FF0A34  1d f4 17 f4
	ret                                                  ; FF0A38  0e

; EditScreen_DrawBeat_DL1 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0A39 and land exactly on 0xFF0A43.
EditScreen_DrawBeat_DL1:
; ; drawn (start operand) by EditScreen_DrawBeat -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=40, y=179, digits=1

; EditScreen_DrawBeat_DL2 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0A43 and land exactly on 0xFF0A52.
EditScreen_DrawBeat_DL2:
; ; drawn (start operand) by EditScreen_DrawBeat -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_EditMeasureOverflow+0x3, width=1, x=48, y=179
; EditScreen_DrawTick -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 8
; instructions to its first `ret`:
;     site 0xFF0A6C  interpreter B  list 0xFF0A71-0xFF0A7B
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawTick: layer 0; EditCursor_Tick to 0x26B0, EditScreen_DrawTick_DL (op 06, digits).
EditScreen_DrawTick:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0A52  f1 40 25 00 00
	xor WA,WA                                            ; FF0A57  d8 d0
	ld a, (EditCursor_Tick:24)                                 ; FF0A59  c2 43 1f 60 21
	ld (0x26b0:16), wa                                  ; FF0A5E  f1 b0 26 50
	ld XIY,EditScreen_DrawTick_DL                            ; FF0A62  45 71 0a ff 00
	ld XIX,EditScreen_DrawCursorNote                                    ; FF0A67  44 7b 0a ff 00
	call T_DisplayListB_Run                              ; FF0A6C  1d f4 17 f4
	ret                                                  ; FF0A70  0e

; EditScreen_DrawTick_DL -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0A71 and land exactly on 0xFF0A7B.
EditScreen_DrawTick_DL:
; ; drawn (start operand) by EditScreen_DrawTick -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=56, y=179, digits=2
; EditScreen_DrawCursorNote: layer 0: DrumEdit_DrawCursorNoteNumber in DRUM EDIT, NoteEdit_DrawCursorNoteName in NOTE EDIT.
EditScreen_DrawCursorNote:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0A7B  f1 40 25 00 00
	bit	0, (EditScreen_Mode:24)                             ; FF0A80  f2 70 1f 60 c8
	jr z, .LFF0A8B                                       ; FF0A85  66 04
	calr DrumEdit_DrawCursorNoteNumber                                      ; FF0A87  1e 05 00
	ret                                                  ; FF0A8A  0e
.LFF0A8B:
	calr NoteEdit_DrawCursorNoteName                                            ; FF0A8B  1e 25 00
	ret                                                  ; FF0A8E  0e
; DrumEdit_DrawCursorNoteNumber -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 7
; instructions to its first `ret`:
;     site 0xFF0AA4  interpreter B  list 0xFF0AA9-0xFF0AB3
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawCursorNoteNumber: (0x26B0) = EditCursor_Note and DrumEdit_DrawCursorNoteNumber_DL run through T_DisplayListB_Run: the note as a number.
DrumEdit_DrawCursorNoteNumber:
	xor WA,WA                                            ; FF0A8F  d8 d0
	ld a, (EditCursor_Note:24)                                 ; FF0A91  c2 44 1f 60 21
	ld (0x26b0:16), wa                                  ; FF0A96  f1 b0 26 50
	ld XIY,DrumEdit_DrawCursorNoteNumber_DL                            ; FF0A9A  45 a9 0a ff 00
	ld XIX,NoteEdit_DrawCursorNoteName                                    ; FF0A9F  44 b3 0a ff 00
	call T_DisplayListB_Run                              ; FF0AA4  1d f4 17 f4
	ret                                                  ; FF0AA8  0e

; DrumEdit_DrawCursorNoteNumber_DL -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0AA9 and land exactly on 0xFF0AB3.
DrumEdit_DrawCursorNoteNumber_DL:
; ; drawn (start operand) by DrumEdit_DrawCursorNoteNumber -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=96, y=179, digits=2
; NoteEdit_DrawCursorNoteName -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 2 time(s) in the 17
; instructions to its first `ret`:
;     site 0xFF0AD0  interpreter B  list 0xFF0AEA-0xFF0AF9
;     site 0xFF0AE5  interpreter B  list 0xFF0AF9-0xFF0B08
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; NoteEdit_DrawCursorNoteName: EditCursor_Note split by `div A,0x0C`: the octave through NoteEdit_DrawCursorNoteName_DL1, the note through NoteNames.
NoteEdit_DrawCursorNoteName:
	xor WA,WA                                            ; FF0AB3  d8 d0
	ld a, (EditCursor_Note:24)                                 ; FF0AB5  c2 44 1f 60 21
	div A,0x0c                                           ; FF0ABA  c9 0a 0c
	pushw wa                                             ; FF0ABD  28
	ld A,W                                               ; FF0ABE  c8 89
	xor W,W                                              ; FF0AC0  c8 d0
	ld (0x26b0:16), wa                                  ; FF0AC2  f1 b0 26 50
	ld XIY,NoteEdit_DrawCursorNoteName_DL1                            ; FF0AC6  45 ea 0a ff 00
	ld XIX,NoteEdit_DrawCursorNoteName_DL2                            ; FF0ACB  44 f9 0a ff 00
	call T_DisplayListB_Run                              ; FF0AD0  1d f4 17 f4
	popw wa                                              ; FF0AD4  48
	xor W,W                                              ; FF0AD5  c8 d0
	ld (0x26b0:16), wa                                  ; FF0AD7  f1 b0 26 50
	ld XIY,NoteEdit_DrawCursorNoteName_DL2                            ; FF0ADB  45 f9 0a ff 00
	ld XIX,NoteNames                                     ; FF0AE0  44 08 0b ff 00
	call T_DisplayListB_Run                              ; FF0AE5  1d f4 17 f4
	ret                                                  ; FF0AE9  0e

; NoteEdit_DrawCursorNoteName_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0AEA and land exactly on 0xFF0AF9.
NoteEdit_DrawCursorNoteName_DL1:
; ; drawn (start operand) by NoteEdit_DrawCursorNoteName -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=NoteNames, width=2, x=88, y=179

; NoteEdit_DrawCursorNoteName_DL2 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0AF9 and land exactly on 0xFF0B08.
NoteEdit_DrawCursorNoteName_DL2:
; ; drawn (start operand) by NoteEdit_DrawCursorNoteName -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=OctaveNames, width=2, x=104, y=179
; ---------------------------------------------------------------------
; NoteNames -- 13 two-character chromatic note names
; " C" "D<88>" " D" "E<88>" " E" " F" "F<8C>" " G" "A<88>" " A"
; "B<88>" " B" " C"  -- 0x88 is the FLAT glyph and 0x8C the SHARP one,
; both below 0x20-and-above-0x7E, i.e. custom font cells.
; ENTRY COUNT 13, not 12: the twelfth entry is " B" and a THIRTEENTH
; repeats " C", which is what a note-plus-octave formatter needs when the
; index runs one past B.
; ⚠ Its reader is not located: nothing in either image spells 0xFF0B08 as
; an immediate, because the display list that ends at 0xFF0B08 supplies
; the address as its own end.  The framing is from the CONTENT and from
; the fact that OctaveNames follows it exactly.
; ---------------------------------------------------------------------

NoteNames:
	.byte 0x20, 0x43, 0x44, 0x88, 0x20, 0x44, 0x45, 0x88, 0x20, 0x45, 0x20, 0x46, 0x46, 0x8c, 0x20, 0x47  ; FF0B08
	.byte 0x41, 0x88, 0x20, 0x41, 0x42, 0x88, 0x20, 0x42, 0x20, 0x43          ; FF0B18
; ---------------------------------------------------------------------
; OctaveNames -- 12 two-character octave labels, "-2" "-1" "0 " ... "9 "
; ⚠ CORRECTED 2026-08-25 (round-2 audit F10): this said "-2 to 9 is twelve
; octaves, which is the range a 128-note MIDI keyboard spans when C-2 is note
; 0".  It does not.  With C-2 = note 0, note 127 is G8: MIDI reaches octave 8
; and never 9, so eleven of the twelve rows cover the whole note-number range
; and the twelfth, "9 ", is unreachable from one.  What the twelfth row is for
; is NOT established.  Code resumes at 0xFF0B3A.
; ---------------------------------------------------------------------

OctaveNames:
	.byte 0x2d, 0x32, 0x2d, 0x31, 0x30, 0x20, 0x31, 0x20, 0x32, 0x20, 0x33, 0x20, 0x34, 0x20, 0x35, 0x20  ; FF0B22
	.byte 0x36, 0x20, 0x37, 0x20, 0x38, 0x20, 0x39, 0x20                      ; FF0B32
; EditScreen_DrawNewNoteVelocity: (0x601F19) = (0x601F46), then the same tail -- the same cell.
EditScreen_DrawNewNoteVelocity:
	ld a, (EditField_NewNoteVelocity:24)                                 ; FF0B3A  c2 46 1f 60 21
	ld (0x601f19:24), a                                 ; FF0B3F  f2 19 1f 60 41
	jr .LFF0B50                                          ; FF0B44  68 0a
; EditScreen_DrawEventVelocity -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 2 time(s) in the 18
; instructions to its first `ret`:
;     site 0xFF0B72  interpreter B  list 0xFF0BD2-0xFF0BE1
;     site 0xFF0B8B  interpreter B  list 0xFF0BBE-0xFF0BC8
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; EditScreen_DrawEventVelocity: (0x601F19) = (0x601F45), then the shared tail .LFF0B50: layer 0, the cell erased (EditScreen_EraseVelocityCell), the value drawn
;   (below 100 with a leading blank, otherwise with Str_v).
EditScreen_DrawEventVelocity:
	ld a, (EditField_EventVelocity:24)                                 ; FF0B46  c2 45 1f 60 21
	ld (0x601f19:24), a                                 ; FF0B4B  f2 19 1f 60 41
.LFF0B50:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0B50  f1 40 25 00 00
	calr EditScreen_EraseVelocityCell                                          ; FF0B55  1e c5 ec
	ld a, (0x601f19:24)                                 ; FF0B58  c2 19 1f 60 21
	cp A,0x64                                            ; FF0B5D  c9 cf 64
	jr nc, .LFF0B90                                      ; FF0B60  6f 2e
	ldw (0x26b0:16), 0x00                                ; FF0B62  f1 b0 26 02 00 00
	ld XIY,EditScreen_DrawEventVelocity_DL1                            ; FF0B68  45 d2 0b ff 00
	ld XIX,EditScreen_DrawEventVelocity_DL3                            ; FF0B6D  44 e1 0b ff 00
	call T_DisplayListB_Run                              ; FF0B72  1d f4 17 f4
	xor WA,WA                                            ; FF0B76  d8 d0
	ld a, (0x601f19:24)                                 ; FF0B78  c2 19 1f 60 21
	ld (0x26b0:16), wa                                  ; FF0B7D  f1 b0 26 50
	ld XIY,EditScreen_DrawEventVelocity_DL2                            ; FF0B81  45 be 0b ff 00
	ld XIX,EditScreen_DrawEventVelocity_DL4                            ; FF0B86  44 c8 0b ff 00
	call T_DisplayListB_Run                              ; FF0B8B  1d f4 17 f4
	ret                                                  ; FF0B8F  0e
.LFF0B90:
	ldw (0x26b0:16), 0x00                                ; FF0B90  f1 b0 26 02 00 00
	ld XIY,EditScreen_DrawEventVelocity_DL3                            ; FF0B96  45 e1 0b ff 00
	ld XIX,Str_v                                                          ; FF0B9B  44 f0 0b ff 00
	call T_DisplayListB_Run                              ; FF0BA0  1d f4 17 f4
	xor WA,WA                                            ; FF0BA4  d8 d0
	ld a, (0x601f19:24)                                 ; FF0BA6  c2 19 1f 60 21
	ld (0x26b0:16), wa                                  ; FF0BAB  f1 b0 26 50
	ld XIY,EditScreen_DrawEventVelocity_DL4                            ; FF0BAF  45 c8 0b ff 00
	ld XIX,EditScreen_DrawEventVelocity_DL1                            ; FF0BB4  44 d2 0b ff 00
	call T_DisplayListB_Run                              ; FF0BB9  1d f4 17 f4
	ret                                                  ; FF0BBD  0e

; EditScreen_DrawEventVelocity_DL2 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0BBE and land exactly on 0xFF0BC8.
EditScreen_DrawEventVelocity_DL2:
; ; drawn (start operand) by EditScreen_DrawEventVelocity -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=136, y=179, digits=2

; EditScreen_DrawEventVelocity_DL4 -- 1 record(s), 10 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0BC8 and land exactly on 0xFF0BD2.
EditScreen_DrawEventVelocity_DL4:
; ; drawn (start operand) by EditScreen_DrawEventVelocity -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number16	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, x=128, y=179, digits=3

; EditScreen_DrawEventVelocity_DL1 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0BD2 and land exactly on 0xFF0BE1.
EditScreen_DrawEventVelocity_DL1:
; ; drawn (start operand) by EditScreen_DrawEventVelocity -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_v, width=1, x=128, y=179

; EditScreen_DrawEventVelocity_DL3 -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0BE1 and land exactly on 0xFF0BF0.
EditScreen_DrawEventVelocity_DL3:
; ; drawn (start operand) by EditScreen_DrawEventVelocity -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=Str_v, width=1, x=120, y=179
; Str_v -- a one-entry string table.  Both op-02 records above point at it (+7, entry width 1), and EditScreen_DrawEventVelocity
;          zeroes their index (0x26B0) before each run, so they draw "v" before the value's digits.  It is also
;          where EditScreen_DrawEventVelocity_DL3 ends (EditScreen_DrawEventVelocity's XIX).  Was decoded as `jrl z` with the routine below.
Str_v:	.ascii	"v"	; FF0BF0
; EditScreen_DrawEventLength: layer 0: the cell erased (EditScreen_EraseLengthCell); EditField_Length drawn, 4-digit layout below 10000, 5-digit above.
EditScreen_DrawEventLength:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0BF1  f1 40 25 00 00
	calr EditScreen_EraseLengthCell                                          ; FF0BF6  1e 42 ec
	ld wa, (EditField_Length:24)                                ; FF0BF9  d2 47 1f 60 20
	ld (0x26b0:16), wa                                  ; FF0BFE  f1 b0 26 50
	cpw	(0x26b0:16), 0x2710                          ; FF0C02  d1 b0 26 3f 10 27
	jr nc, .LFF0C0E                                      ; FF0C08  6f 04
	calr EditScreen_DrawLengthBelow10000                                      ; FF0C0A  1e 26 00
	ret                                                  ; FF0C0D  0e
.LFF0C0E:
	calr EditScreen_DrawLengthFrom10000                                      ; FF0C0E  1e 8a 00
	ret                                                  ; FF0C11  0e
; EditScreen_DrawNewNoteLength: the same for EditField_NewNoteLength.
EditScreen_DrawNewNoteLength:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0C12  f1 40 25 00 00
	calr EditScreen_EraseLengthCell                                          ; FF0C17  1e 21 ec
	ld wa, (EditField_NewNoteLength:24)                                ; FF0C1A  d2 49 1f 60 20
	ld (0x26b0:16), wa                                  ; FF0C1F  f1 b0 26 50
	cpw	(0x26b0:16), 0x2710                          ; FF0C23  d1 b0 26 3f 10 27
	jr nc, .LFF0C2F                                      ; FF0C29  6f 04
	calr EditScreen_DrawLengthBelow10000                                      ; FF0C2B  1e 05 00
	ret                                                  ; FF0C2E  0e
.LFF0C2F:
	calr EditScreen_DrawLengthFrom10000                                      ; FF0C2F  1e 69 00
	ret                                                  ; FF0C32  0e
; EditScreen_DrawLengthBelow10000: (0x26B0) as 1 + 3 digits (thousands at text cell 0x1C0C, the rest at 0x1C0D), or 3 digits below 1000.
EditScreen_DrawLengthBelow10000:
	cpw	(0x26b0:16), 0x03e7                          ; FF0C33  d1 b0 26 3f e7 03
	jr ule, .LFF0C81                                     ; FF0C39  63 46
	xor XWA,XWA                                          ; FF0C3B  e8 d0
	ld wa, (0x26b0:16)                                 ; FF0C3D  d1 b0 26 20
	div WA,0x03e8                                        ; FF0C41  d8 0a e8 03
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FF0C45  1d f0 1a f4
	ld XIY,Value_AsciiDigits+2                                    ; FF0C49  45 63 26 00 00
	ldw hl, 0x00                                         ; FF0C4E  33 00 00
	ldw bc, 0x01                                         ; FF0C51  31 01 00
	ldw ix, 0x1c0c                                       ; FF0C54  34 0c 1c
	ld a, 0x06:opc                                          ; FF0C57  21 06
	swi 7                                                ; FF0C59  ff
	ld wa, (0x26b0:16)                                 ; FF0C5A  d1 b0 26 20
	xor XWA,XWA                                          ; FF0C5E  e8 d0
	ld wa, (0x26b0:16)                                 ; FF0C60  d1 b0 26 20
	div WA,0x03e8                                        ; FF0C64  d8 0a e8 03
	ld WA,QWA                                            ; FF0C68  d7 e2 88
	call T_Value_ToAsciiDigits3                          ; FF0C6B  1d 00 1b f4
	ld XIY,Value_AsciiDigits                                    ; FF0C6F  45 61 26 00 00
	ldw hl, 0x00                                         ; FF0C74  33 00 00
	ldw bc, 0x03                                         ; FF0C77  31 03 00
	ldw ix, 0x1c0d                                       ; FF0C7A  34 0d 1c
	ld a, 0x06:opc                                          ; FF0C7D  21 06
	swi 7                                                ; FF0C7F  ff
	ret                                                  ; FF0C80  0e
.LFF0C81:
	ld wa, (0x26b0:16)                                 ; FF0C81  d1 b0 26 20
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FF0C85  1d f0 1a f4
	ld XIY,Value_AsciiDigits                                    ; FF0C89  45 61 26 00 00
	ldw hl, 0x00                                         ; FF0C8E  33 00 00
	ldw bc, 0x03                                         ; FF0C91  31 03 00
	ldw ix, 0x1c0d                                       ; FF0C94  34 0d 1c
	ld a, 0x06:opc                                          ; FF0C97  21 06
	swi 7                                                ; FF0C99  ff
	ret                                                  ; FF0C9A  0e
; EditScreen_DrawLengthFrom10000: (0x26B0) as 2 + 3 digits (cells 0x1C0C / 0x1C0E).
EditScreen_DrawLengthFrom10000:
	cpw	(0x26b0:16), 0x03e7                          ; FF0C9B  d1 b0 26 3f e7 03
	jr ule, .LFF0CE9                                     ; FF0CA1  63 46
	xor XWA,XWA                                          ; FF0CA3  e8 d0
	ld wa, (0x26b0:16)                                 ; FF0CA5  d1 b0 26 20
	div WA,0x03e8                                        ; FF0CA9  d8 0a e8 03
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FF0CAD  1d f0 1a f4
	ld XIY,Value_AsciiDigits+1                                    ; FF0CB1  45 62 26 00 00
	ldw hl, 0x00                                         ; FF0CB6  33 00 00
	ldw bc, 0x02                                         ; FF0CB9  31 02 00
	ldw ix, 0x1c0c                                       ; FF0CBC  34 0c 1c
	ld a, 0x06:opc                                          ; FF0CBF  21 06
	swi 7                                                ; FF0CC1  ff
	ld wa, (0x26b0:16)                                 ; FF0CC2  d1 b0 26 20
	xor XWA,XWA                                          ; FF0CC6  e8 d0
	ld wa, (0x26b0:16)                                 ; FF0CC8  d1 b0 26 20
	div WA,0x03e8                                        ; FF0CCC  d8 0a e8 03
	ld WA,QWA                                            ; FF0CD0  d7 e2 88
	call T_Value_ToAsciiDigits3                          ; FF0CD3  1d 00 1b f4
	ld XIY,Value_AsciiDigits                                    ; FF0CD7  45 61 26 00 00
	ldw hl, 0x00                                         ; FF0CDC  33 00 00
	ldw bc, 0x03                                         ; FF0CDF  31 03 00
	ldw ix, 0x1c0e                                       ; FF0CE2  34 0e 1c
	ld a, 0x06:opc                                          ; FF0CE5  21 06
	swi 7                                                ; FF0CE7  ff
	ret                                                  ; FF0CE8  0e
.LFF0CE9:
	ld wa, (0x26b0:16)                                 ; FF0CE9  d1 b0 26 20
	call T_Value_ToAsciiDigits3_RightJustified                                        ; FF0CED  1d f0 1a f4
	ld XIY,Value_AsciiDigits                                    ; FF0CF1  45 61 26 00 00
	ldw hl, 0x00                                         ; FF0CF6  33 00 00
	ldw bc, 0x03                                         ; FF0CF9  31 03 00
	ldw ix, 0x1c0e                                       ; FF0CFC  34 0e 1c
	ld a, 0x06:opc                                          ; FF0CFF  21 06
	swi 7                                                ; FF0D01  ff
	ret                                                  ; FF0D02  0e
; EditScreen_DrawInc: layer 0: DrumEdit_DrawIncLabel in DRUM EDIT, NoteEdit_DrawIncNumber in NOTE EDIT.
EditScreen_DrawInc:
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF0D03  f1 40 25 00 00
	bit	0, (EditScreen_Mode:24)                             ; FF0D08  f2 70 1f 60 c8
	jr z, .LFF0D13                                       ; FF0D0D  66 04
	calr DrumEdit_DrawIncLabel                                            ; FF0D0F  1e 2c 00
	ret                                                  ; FF0D12  0e
.LFF0D13:
	calr NoteEdit_DrawIncNumber                                      ; FF0D13  1e 01 00
	ret                                                  ; FF0D16  0e
; NoteEdit_DrawIncNumber -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 6
; instructions to its first `ret`:
;     site 0xFF0D2A  interpreter B  list 0xFF0D2F-0xFF0D3E
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; NoteEdit_DrawIncNumber: EditField_Inc through NoteEdit_DrawIncNumber_DL (a number).
NoteEdit_DrawIncNumber:
	ld wa, (EditField_Inc:24)                                ; FF0D17  d2 4d 1f 60 20
	ld (0x26b0:16), wa                                  ; FF0D1C  f1 b0 26 50
	ld XIY,NoteEdit_DrawIncNumber_DL                            ; FF0D20  45 2f 0d ff 00
	ld XIX,DrumEdit_DrawIncLabel                                    ; FF0D25  44 3e 0d ff 00
	call T_DisplayListB_Run                              ; FF0D2A  1d f4 17 f4
	ret                                                  ; FF0D2E  0e

; NoteEdit_DrawIncNumber_DL -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0D2F and land exactly on 0xFF0D3E.
NoteEdit_DrawIncNumber_DL:
; ; drawn (start operand) by NoteEdit_DrawIncNumber -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=TickLabels, width=2, x=216, y=179
; DrumEdit_DrawIncLabel -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 1 time(s) in the 6
; instructions to its first `ret`:
;     site 0xFF0D51  interpreter B  list 0xFF0D56-0xFF0D65
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; DrumEdit_DrawIncLabel: EditField_Inc through DrumEdit_DrawIncLabel_DL and TickLabels (a label).
DrumEdit_DrawIncLabel:
	ld wa, (EditField_Inc:24)                                ; FF0D3E  d2 4d 1f 60 20
	ld (0x26b0:16), wa                                  ; FF0D43  f1 b0 26 50
	ld XIY,DrumEdit_DrawIncLabel_DL                            ; FF0D47  45 56 0d ff 00
	ld XIX,TickLabels                                    ; FF0D4C  44 65 0d ff 00
	call T_DisplayListB_Run                              ; FF0D51  1d f4 17 f4
	ret                                                  ; FF0D55  0e

; DrumEdit_DrawIncLabel_DL -- 1 record(s), 15 bytes.  Run by interpreter B (0xF31AF0)
; The length bytes walk from 0xFF0D56 and land exactly on 0xFF0D65.
DrumEdit_DrawIncLabel_DL:
; ; drawn (start operand) by DrumEdit_DrawIncLabel -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x26b0, mask=0xff, shift=0, svc=LCDSVC_DrawText8x14, table=TickLabels, width=2, x=176, y=179
; ---------------------------------------------------------------------
; TickLabels -- 99 two-character cells; 0..96 are labelled, 97 and 98 are blank
;
; ★ Seven entries are NOT digits, and which seven is the decode: 8, 12,
;   16, 24, 32, 48 and 96 carry two bytes below 0x20 instead --
;     8 -> 18 1F   12 -> 18 20   16 -> 17 1F   24 -> 17 20
;    32 -> 16 1F   48 -> 16 20   96 -> 15 20
;   ⚠ CORRECTED 2026-08-25 (round-2 audit F3): this said "exactly the
;   divisors of 96", which is FALSE -- 1, 2, 3, 4 and 6 divide 96 too and all
;   five carry ordinary digits (" 1" " 2" " 3" " 4" " 6", read from ROM).  The
;   rule is "the divisors of 96 that are >= 8".  (A softer form, "the divisors
;   that matter musically", was in notes/FINDINGS-prom_a-screen-module.md and is
;   also gone: it cannot fail.)  96 ticks is one beat, so
;   the seven are NOTE-VALUE GLYPHS (96th, 48th, 32nd, 24th = 16th
;   triplet, 16th, 12th = 8th triplet, 8th) drawn as a note symbol
;   instead of a number.  The glyph pairs step 0x18, 0x17, 0x16, 0x15 as
;   the note gets longer, with the second byte 0x1F/0x20 alternating --
;   a two-cell symbol, stem and head.
; ENTRY COUNT 99 is the EXTENT: 0xFF0E2B, where the table stops, is the
;   start of a display list named by an immediate.
;   ⚠ LAST-ENTRY TEST (round-2 audit F3): entries 97 (0xFF0E27) and 98
;   (0xFF0E29) are `20 20`, BLANK.  The highest labelled value is 96, the
;   whole-beat glyph at 0xFF0E25.  So the extent is 99 cells and the labelled
;   range is 0..96; "labels for a tick count, 0 to 98" over-stated it by two.
;   Re-derived by `python3 notes/prom_a_round3_checks.py` (section TickLabels).
; ⚠ WHAT IS NOT ESTABLISHED: that a beat is 96 ticks HERE.  The divisor
;   set is the evidence for it, and nothing in this module states a
;   resolution.
; ---------------------------------------------------------------------

TickLabels:
	.byte 0x20, 0x30, 0x20, 0x31, 0x20, 0x32, 0x20, 0x33, 0x20, 0x34, 0x20, 0x35, 0x20, 0x36, 0x20, 0x37  ; FF0D65
	.byte 0x18, 0x1f, 0x20, 0x39, 0x31, 0x30, 0x31, 0x31, 0x18, 0x20, 0x31, 0x33, 0x31, 0x34, 0x31, 0x35  ; FF0D75
	.byte 0x17, 0x1f, 0x31, 0x37, 0x31, 0x38, 0x31, 0x39, 0x32, 0x30, 0x32, 0x31, 0x32, 0x32, 0x32, 0x33  ; FF0D85
	.byte 0x17, 0x20, 0x32, 0x35, 0x32, 0x36, 0x32, 0x37, 0x32, 0x38, 0x32, 0x39, 0x33, 0x30, 0x33, 0x31  ; FF0D95
	.byte 0x16, 0x1f, 0x33, 0x33, 0x33, 0x34, 0x33, 0x35, 0x33, 0x36, 0x33, 0x37, 0x33, 0x38, 0x33, 0x39  ; FF0DA5
	.byte 0x34, 0x30, 0x34, 0x31, 0x34, 0x32, 0x34, 0x33, 0x34, 0x34, 0x34, 0x35, 0x34, 0x36, 0x34, 0x37  ; FF0DB5
	.byte 0x16, 0x20, 0x34, 0x39, 0x35, 0x30, 0x35, 0x31, 0x35, 0x32, 0x35, 0x33, 0x35, 0x34, 0x35, 0x35  ; FF0DC5
	.byte 0x35, 0x36, 0x35, 0x37, 0x35, 0x38, 0x35, 0x39, 0x36, 0x30, 0x36, 0x31, 0x36, 0x32, 0x36, 0x33  ; FF0DD5
	.byte 0x36, 0x34, 0x36, 0x35, 0x36, 0x36, 0x36, 0x37, 0x36, 0x38, 0x36, 0x39, 0x37, 0x30, 0x37, 0x31  ; FF0DE5
	.byte 0x37, 0x32, 0x37, 0x33, 0x37, 0x34, 0x37, 0x35, 0x37, 0x36, 0x37, 0x37, 0x37, 0x38, 0x37, 0x39  ; FF0DF5
	.byte 0x38, 0x30, 0x38, 0x31, 0x38, 0x32, 0x38, 0x33, 0x38, 0x34, 0x38, 0x35, 0x38, 0x36, 0x38, 0x37  ; FF0E05
	.byte 0x38, 0x38, 0x38, 0x39, 0x39, 0x30, 0x39, 0x31, 0x39, 0x32, 0x39, 0x33, 0x39, 0x34, 0x39, 0x35  ; FF0E15
	.byte 0x15, 0x20, 0x20, 0x20, 0x20, 0x20                                  ; FF0E25

; DisplayList_SequencerRealtimeEdit -- 26 record(s), 230 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFF0E2B and land exactly on 0xFF0F11.
; DisplayList_SequencerRealtimeEdit -- the display list at 0xFF0E2B, renamed from its framed label
;                  `DisplayList_FF0E2B`.  Its own text records read:
;     "SEQUENCER"; "REALTIME"; "EDIT"; "MASTER"; "REC0RD"; "TRACK"; "ASSIGN"; "STEP"; "MEDLEY"; "S0NG"
; Evidence: the `.ascii` literals printed below this label, which the
;          display-list interpreter draws verbatim.  The name is the
;          CamelCase of the first of them and says what the list PUTS ON
;          THE SCREEN and nothing more -- the rule wave 7 round 4 used
;          for prom_b's 249 named lists.
; ---------------------------------------------------------------------
DisplayList_SequencerRealtimeEdit:
	dl_text16x16_packed	x=122, y=5, text="SEQUENCER"
	dl_text8x14	x=40, y=36, text="REALTIME"
	dl_text8x14	x=184, y=36, text="EDIT"
	dl_text8x8_packed	x=0, y=38, text="\020"
	dl_text8x8_packed	x=314, y=38, text="\021"
	dl_text8x14	x=40, y=76, text="MASTER"
	dl_text8x14	x=112, y=76, text="REC0RD"
	dl_text8x14	x=184, y=76, text="TRACK"
	dl_text8x14	x=232, y=76, text="ASSIGN"
	dl_text8x8_packed	x=0, y=77, text="\020"
	dl_text8x8_packed	x=314, y=77, text="\021"
	dl_text8x14	x=40, y=114, text="STEP"
	dl_text8x14	x=184, y=114, text="MEDLEY"
	dl_text8x8_packed	x=0, y=116, text="\020"
	dl_text8x8_packed	x=314, y=116, text="\021"
	dl_text8x14	x=40, y=146, text="S0NG"
	dl_text8x14	x=80, y=146, text="SELECT"
	dl_text8x14	x=184, y=146, text="AFTER"
	dl_text8x8_packed	x=0, y=155, text="\020"
	dl_text8x8_packed	x=314, y=155, text="\021"
	dl_text8x14	x=72, y=160, text="/NAME"
	dl_text8x14	x=184, y=160, text="T0UCH"
	dl_text8x14	x=232, y=160, text="SET"
	dl_hline	x0=105, y0=41, x1=108, y1=41
	dl_hline	x0=105, y0=120, x1=108, y1=120
	dl_vline	x0=108, y0=41, x1=108, y1=120

; DisplayList_NoteEditTrackSong -- 59 record(s), 463 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFF0F11 and land exactly on 0xFF10E0.
; DisplayList_NoteEditTrackSong -- the display list at 0xFF0F11, renamed from its framed label
;                  `DisplayList_FF0F11`.  Its own text records read:
;     "NOTE EDIT"; "TRACK"; "SONG"; "PLAY"; "GRAPH"; "ERS"; "MEAS"; "POS"; "NOTE"; "VEL"
; Evidence: the `.ascii` literals printed below this label, which the
;          display-list interpreter draws verbatim.  The name is the
;          CamelCase of the first of them and says what the list PUTS ON
;          THE SCREEN and nothing more -- the rule wave 7 round 4 used
;          for prom_b's 249 named lists.
; ---------------------------------------------------------------------
DisplayList_NoteEditTrackSong:
	dl_text8x16	x=8, y=2, text="NOTE EDIT"
	dl_text8x14	x=112, y=3, text="TRACK"
	dl_text8x14	x=256, y=3, text="SONG"
	dl_text8x16	x=312, y=36, text="\021"
	dl_text8x14	x=272, y=37, text="PLAY"
	dl_text8x16	x=288, y=72, text="\215"
	dl_text8x16	x=312, y=72, text="\021"
	dl_text8x14	x=272, y=94, text="GRAPH"
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x16	x=288, y=114, text="\216"
	dl_text8x16	x=312, y=151, text="\021"
	dl_text8x14	x=280, y=152, text="ERS"
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=48, y=199, text="POS"
	dl_text8x14	x=88, y=199, text="NOTE"
	dl_text8x14	x=128, y=199, text="VEL"
	dl_text8x14	x=168, y=199, text="LEN"
	dl_text8x14	x=208, y=199, text="INC"
	dl_text8x14	x=240, y=199, text="-"
	dl_text8x14	x=256, y=199, text="CURSOR"
	dl_text8x16	x=16, y=211, text="\215"
	dl_text8x16	x=56, y=211, text="\215"
	dl_text8x16	x=96, y=211, text="\215"
	dl_text8x16	x=136, y=211, text="\215"
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x16	x=216, y=211, text="\215"
	dl_text8x14	x=256, y=220, text="<"
	dl_text8x14	x=296, y=220, text=">"
	dl_text8x16	x=16, y=225, text="\216"
	dl_text8x16	x=56, y=225, text="\216"
	dl_text8x16	x=96, y=225, text="\216"
	dl_text8x16	x=136, y=225, text="\216"
	dl_text8x16	x=176, y=225, text="\216"
	dl_text8x16	x=216, y=225, text="\216"
	dl_box_shadow2	x0=3, y0=173, x1=241, y1=193
	dl_box_shadow2	x0=5, y0=212, x1=34, y1=236
	dl_box_shadow2	x0=45, y0=212, x1=74, y1=236
	dl_box_shadow2	x0=85, y0=212, x1=114, y1=236
	dl_box_shadow2	x0=125, y0=212, x1=154, y1=236
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_box_shadow2	x0=205, y0=212, x1=234, y1=236
	dl_box_shadow2	x0=245, y0=212, x1=274, y1=236
	dl_box_shadow2	x0=285, y0=212, x1=314, y1=236
	dl_box	x0=265, y0=31, x1=309, y1=51
	dl_box	x0=267, y0=33, x1=307, y1=49
	dl_box	x0=277, y0=70, x1=307, y1=86
	dl_box	x0=277, y0=111, x1=307, y1=127
	dl_box	x0=275, y0=147, x1=309, y1=166
	dl_box	x0=277, y0=149, x1=307, y1=164
	dl_hline	x0=0, y0=32, x1=256, y1=32
	dl_hline	x0=0, y0=39, x1=255, y1=39
	dl_hline	x0=16, y0=169, x1=255, y1=169
	dl_hline	x0=5, y0=224, x1=36, y1=224
	dl_hline	x0=45, y0=224, x1=76, y1=224
	dl_hline	x0=85, y0=224, x1=116, y1=224
	dl_hline	x0=125, y0=224, x1=156, y1=224
	dl_hline	x0=165, y0=224, x1=196, y1=224
	dl_hline	x0=205, y0=224, x1=236, y1=224
	dl_vline	x0=256, y0=39, x1=256, y1=169

; DisplayList_DrumEditTrackSong -- 71 record(s), 594 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFF10E0 and land exactly on 0xFF1332.
; DisplayList_DrumEditTrackSong -- the display list at 0xFF10E0, renamed from its framed label
;                  `DisplayList_FF10E0`.  Its own text records read:
;     "DRUM EDIT"; "TRACK"; "SONG"; "PLAY"; "SOUND"; "ERS"; "MEAS"; "POS"; "SND"; "VEL"
; Evidence: the `.ascii` literals printed below this label, which the
;          display-list interpreter draws verbatim.  The name is the
;          CamelCase of the first of them and says what the list PUTS ON
;          THE SCREEN and nothing more -- the rule wave 7 round 4 used
;          for prom_b's 249 named lists.
; ---------------------------------------------------------------------
DisplayList_DrumEditTrackSong:
	dl_text8x16	x=8, y=2, text="DRUM EDIT"
	dl_text8x14	x=112, y=3, text="TRACK"
	dl_text8x14	x=256, y=3, text="SONG"
	dl_text8x16	x=312, y=36, text="\021"
	dl_text8x14	x=272, y=37, text="PLAY"
	dl_text8x16	x=288, y=72, text="\215"
	dl_text8x16	x=312, y=72, text="\021"
	dl_text8x14	x=272, y=94, text="SOUND"
	dl_text8x16	x=312, y=113, text="\021"
	dl_text8x16	x=288, y=114, text="\216"
	dl_text8x16	x=312, y=151, text="\021"
	dl_text8x14	x=280, y=152, text="ERS"
	dl_text8x14	x=8, y=199, text="MEAS"
	dl_text8x14	x=48, y=199, text="POS"
	dl_text8x14	x=88, y=199, text="SND"
	dl_text8x14	x=128, y=199, text="VEL"
	dl_text8x14	x=168, y=199, text="INC"
	dl_text8x14	x=216, y=199, text="CURSOR"
	dl_text8x14	x=280, y=199, text="ENTER"
	dl_text8x14	x=200, y=199, text="-"
	dl_text8x8_packed	x=189, y=6, text="KIT:"
	dl_text8x16	x=16, y=211, text="\215"
	dl_text8x16	x=56, y=211, text="\215"
	dl_text8x16	x=96, y=211, text="\215"
	dl_text8x16	x=136, y=211, text="\215"
	dl_text8x16	x=176, y=211, text="\215"
	dl_text8x14	x=216, y=220, text="<"
	dl_text8x14	x=256, y=220, text=">"
	dl_text8x16	x=16, y=225, text="\216"
	dl_text8x16	x=56, y=225, text="\216"
	dl_text8x16	x=96, y=225, text="\216"
	dl_text8x16	x=136, y=225, text="\216"
	dl_text8x16	x=176, y=225, text="\216"
	dl_box_shadow2	x0=3, y0=173, x1=200, y1=193
	dl_box_shadow2	x0=5, y0=212, x1=34, y1=236
	dl_box_shadow2	x0=45, y0=212, x1=74, y1=236
	dl_box_shadow2	x0=85, y0=212, x1=114, y1=236
	dl_box_shadow2	x0=125, y0=212, x1=154, y1=236
	dl_box_shadow2	x0=165, y0=212, x1=194, y1=236
	dl_box_shadow2	x0=205, y0=212, x1=234, y1=236
	dl_box_shadow2	x0=245, y0=212, x1=274, y1=236
	dl_box_shadow2	x0=285, y0=212, x1=314, y1=236
	dl_box	x0=265, y0=31, x1=309, y1=51
	dl_box	x0=267, y0=33, x1=307, y1=49
	dl_box	x0=277, y0=70, x1=307, y1=86
	dl_box	x0=277, y0=111, x1=307, y1=127
	dl_box	x0=275, y0=147, x1=309, y1=166
	dl_box	x0=277, y0=149, x1=307, y1=164
	dl_hline	x0=0, y0=32, x1=257, y1=32
	dl_hline	x0=0, y0=39, x1=257, y1=39
	dl_hline	x0=0, y0=162, x1=257, y1=162
	dl_hline	x0=5, y0=224, x1=36, y1=224
	dl_hline	x0=45, y0=224, x1=76, y1=224
	dl_hline	x0=85, y0=224, x1=116, y1=224
	dl_hline	x0=125, y0=224, x1=156, y1=224
	dl_hline	x0=165, y0=224, x1=196, y1=224
	dl_vline	x0=0, y0=40, x1=0, y1=161
	dl_vline	x0=88, y0=40, x1=88, y1=161
	dl_vline	x0=257, y0=40, x1=257, y1=161
	dl_hline	x0=0, y0=41, x1=88, y1=41
	dl_hline	x0=0, y0=51, x1=88, y1=51
	dl_hline	x0=0, y0=61, x1=88, y1=61
	dl_hline	x0=0, y0=71, x1=88, y1=71
	dl_hline	x0=0, y0=81, x1=88, y1=81
	dl_hline	x0=0, y0=91, x1=88, y1=91
	dl_hline	x0=0, y0=101, x1=88, y1=101
	dl_hline	x0=0, y0=111, x1=88, y1=111
	dl_hline	x0=0, y0=121, x1=88, y1=121
	dl_hline	x0=0, y0=131, x1=88, y1=131
	dl_hline	x0=0, y0=141, x1=88, y1=141
	dl_hline	x0=0, y0=151, x1=88, y1=151

; DisplayList_NoteEditPartSelect -- 70 record(s), 600 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFF1332 and land exactly on 0xFF158A.
; DisplayList_NoteEditPartSelect -- the display list at 0xFF1332, renamed from its framed label
;                  `DisplayList_FF1332`.  Its own text records read:
;     "NOTE"; "EDIT"; "PART"; "SELECT"; "Press"; "the"; "up/down"; "button"; "under"; "the"
; Evidence: the `.ascii` literals printed below this label, which the
;          display-list interpreter draws verbatim.  The name is the
;          CamelCase of the first of them and says what the list PUTS ON
;          THE SCREEN and nothing more -- the rule wave 7 round 4 used
;          for prom_b's 249 named lists.
; ---------------------------------------------------------------------
DisplayList_NoteEditPartSelect:
	dl_text16x16_packed	x=80, y=6, text="NOTE"
	dl_text16x16_packed	x=135, y=6, text="EDIT"
	dl_text8x14	x=192, y=6, text=":"
	dl_text8x16	x=200, y=6, text="PART"
	dl_text8x16	x=240, y=6, text="SELECT"
	dl_text8x16	x=24, y=47, text="Press"
	dl_text8x16	x=72, y=47, text="the"
	dl_text8x16	x=104, y=47, text="up/down"
	dl_text8x16	x=168, y=47, text="button"
	dl_text8x16	x=224, y=47, text="under"
	dl_text8x16	x=24, y=68, text="the"
	dl_text8x16	x=56, y=68, text="screen"
	dl_text8x16	x=112, y=68, text="corresponding"
	dl_text8x16	x=224, y=68, text="to"
	dl_text8x16	x=248, y=68, text="the"
	dl_text8x16	x=24, y=89, text="track"
	dl_text8x16	x=72, y=89, text="that"
	dl_text8x16	x=112, y=89, text="you"
	dl_text8x16	x=144, y=89, text="want"
	dl_text8x16	x=184, y=89, text="to"
	dl_text8x16	x=208, y=89, text="edit."
	dl_text8x14	x=16, y=162, text="1"
	dl_text8x14	x=56, y=162, text="2"
	dl_text8x14	x=96, y=162, text="3"
	dl_text8x14	x=136, y=162, text="4"
	dl_text8x14	x=176, y=162, text="5"
	dl_text8x14	x=216, y=162, text="6"
	dl_text8x14	x=256, y=162, text="7"
	dl_text8x14	x=296, y=162, text="8"
	dl_text8x14	x=16, y=209, text="9"
	dl_text8x14	x=56, y=209, text="10"
	dl_text8x14	x=96, y=209, text="11"
	dl_text8x14	x=136, y=209, text="12"
	dl_text8x14	x=176, y=209, text="13"
	dl_text8x14	x=216, y=209, text="14"
	dl_text8x14	x=256, y=209, text="15"
	dl_text8x14	x=296, y=209, text="16"
	dl_box_shadow2	x0=16, y0=39, x1=287, y1=118
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233
	dl_hline	x0=5, y0=173, x1=36, y1=173
	dl_hline	x0=45, y0=173, x1=76, y1=173
	dl_hline	x0=85, y0=173, x1=116, y1=173
	dl_hline	x0=125, y0=173, x1=156, y1=173
	dl_hline	x0=165, y0=173, x1=196, y1=173
	dl_hline	x0=205, y0=173, x1=236, y1=173
	dl_hline	x0=245, y0=173, x1=276, y1=173
	dl_hline	x0=285, y0=173, x1=316, y1=173
	dl_hline	x0=5, y0=220, x1=36, y1=220
	dl_hline	x0=45, y0=220, x1=76, y1=220
	dl_hline	x0=85, y0=220, x1=116, y1=220
	dl_hline	x0=125, y0=220, x1=156, y1=220
	dl_hline	x0=165, y0=220, x1=196, y1=220
	dl_hline	x0=205, y0=220, x1=236, y1=220
	dl_hline	x0=245, y0=220, x1=276, y1=220
	dl_hline	x0=285, y0=220, x1=316, y1=220

; DisplayList_DrumEditPartSelect -- 70 record(s), 600 bytes.  Run by interpreter A (0xF31A09)
; The length bytes walk from 0xFF158A and land exactly on 0xFF17E2.
; DisplayList_DrumEditPartSelect -- the display list at 0xFF158A, renamed from its framed label
;                  `DisplayList_FF158A`.  Its own text records read:
;     "DRUM"; "EDIT"; "PART"; "SELECT"; "Press"; "the"; "up/down"; "button"; "under"; "the"
; Evidence: the `.ascii` literals printed below this label, which the
;          display-list interpreter draws verbatim.  The name is the
;          CamelCase of the first of them and says what the list PUTS ON
;          THE SCREEN and nothing more -- the rule wave 7 round 4 used
;          for prom_b's 249 named lists.
; ---------------------------------------------------------------------
DisplayList_DrumEditPartSelect:
	dl_text16x16_packed	x=80, y=6, text="DRUM"
	dl_text16x16_packed	x=135, y=6, text="EDIT"
	dl_text8x14	x=192, y=6, text=":"
	dl_text8x16	x=200, y=6, text="PART"
	dl_text8x16	x=240, y=6, text="SELECT"
	dl_text8x16	x=24, y=47, text="Press"
	dl_text8x16	x=72, y=47, text="the"
	dl_text8x16	x=104, y=47, text="up/down"
	dl_text8x16	x=168, y=47, text="button"
	dl_text8x16	x=224, y=47, text="under"
	dl_text8x16	x=24, y=68, text="the"
	dl_text8x16	x=56, y=68, text="screen"
	dl_text8x16	x=112, y=68, text="corresponding"
	dl_text8x16	x=224, y=68, text="to"
	dl_text8x16	x=248, y=68, text="the"
	dl_text8x16	x=24, y=89, text="track"
	dl_text8x16	x=72, y=89, text="that"
	dl_text8x16	x=112, y=89, text="you"
	dl_text8x16	x=144, y=89, text="want"
	dl_text8x16	x=184, y=89, text="to"
	dl_text8x16	x=208, y=89, text="edit."
	dl_text8x14	x=16, y=162, text="1"
	dl_text8x14	x=56, y=162, text="2"
	dl_text8x14	x=96, y=162, text="3"
	dl_text8x14	x=136, y=162, text="4"
	dl_text8x14	x=176, y=162, text="5"
	dl_text8x14	x=216, y=162, text="6"
	dl_text8x14	x=256, y=162, text="7"
	dl_text8x14	x=296, y=162, text="8"
	dl_text8x14	x=16, y=209, text="9"
	dl_text8x14	x=56, y=209, text="10"
	dl_text8x14	x=96, y=209, text="11"
	dl_text8x14	x=136, y=209, text="12"
	dl_text8x14	x=176, y=209, text="13"
	dl_text8x14	x=216, y=209, text="14"
	dl_text8x14	x=256, y=209, text="15"
	dl_text8x14	x=296, y=209, text="16"
	dl_box_shadow2	x0=16, y0=39, x1=287, y1=118
	dl_box_shadow2	x0=5, y0=160, x1=34, y1=186
	dl_box_shadow2	x0=45, y0=160, x1=74, y1=186
	dl_box_shadow2	x0=85, y0=160, x1=114, y1=186
	dl_box_shadow2	x0=125, y0=160, x1=154, y1=186
	dl_box_shadow2	x0=165, y0=160, x1=194, y1=186
	dl_box_shadow2	x0=205, y0=160, x1=234, y1=186
	dl_box_shadow2	x0=245, y0=160, x1=274, y1=186
	dl_box_shadow2	x0=285, y0=160, x1=314, y1=186
	dl_box_shadow2	x0=5, y0=207, x1=34, y1=233
	dl_box_shadow2	x0=45, y0=207, x1=74, y1=233
	dl_box_shadow2	x0=85, y0=207, x1=114, y1=233
	dl_box_shadow2	x0=125, y0=207, x1=154, y1=233
	dl_box_shadow2	x0=165, y0=207, x1=194, y1=233
	dl_box_shadow2	x0=205, y0=207, x1=234, y1=233
	dl_box_shadow2	x0=245, y0=207, x1=274, y1=233
	dl_box_shadow2	x0=285, y0=207, x1=314, y1=233
	dl_hline	x0=5, y0=173, x1=36, y1=173
	dl_hline	x0=45, y0=173, x1=76, y1=173
	dl_hline	x0=85, y0=173, x1=116, y1=173
	dl_hline	x0=125, y0=173, x1=156, y1=173
	dl_hline	x0=165, y0=173, x1=196, y1=173
	dl_hline	x0=205, y0=173, x1=236, y1=173
	dl_hline	x0=245, y0=173, x1=276, y1=173
	dl_hline	x0=285, y0=173, x1=316, y1=173
	dl_hline	x0=5, y0=220, x1=36, y1=220
	dl_hline	x0=45, y0=220, x1=76, y1=220
	dl_hline	x0=85, y0=220, x1=116, y1=220
	dl_hline	x0=125, y0=220, x1=156, y1=220
	dl_hline	x0=165, y0=220, x1=196, y1=220
	dl_hline	x0=205, y0=220, x1=236, y1=220
	dl_hline	x0=245, y0=220, x1=276, y1=220
	dl_hline	x0=285, y0=220, x1=316, y1=220
; ---------------------------------------------------------------------
; KeyboardRuler_Strip0..9 -- TEN 16x129 1-bpp BITMAPS, 0xFF17E2-0xFF21F5
; (2,580 bytes = 10 x 258).  Drawn, they are a vertical piano-keyboard ruler
; labelled C-2 .. C8, the same keyboard at ten scroll positions:
; prom_a/images/Bitmap_FF17E2.png .. Bitmap_FF20F4.png (sheet:
; CONTACT_KeyboardRuler.png).  The `.byte` rows are checked against those PNGs
; by `python3 scripts/build/wsa1_bitmaps.py check` (`make images-check`).
;
; READER -- and the geometry comes from it, not from the look of the data:
;   ScreenDispatch_FE8D6B (12 x u32, indexed by the byte at (0x601F53), called
;   from 0xFE8D48) selects one of ten 15-byte drawers at 0xFE8D9B + 15*i:
;       ld XIY,<record i> / ld XIX,<record i+1> / call 0xF417F0 / ret
;   Each record, KeyboardRuler_DrawStrip0_DL + 12*i, is ONE op-03 display-list record
;   `03 0C` + ptr32 + IX16 + BC16 + HL16, run by DLHandler_FarPtr (prom_b
;   0xF31ABE), which issues SWI7 service 3 = LCD_Svc_03_BlitColumns (0xF8EDB4):
;   BC columns of HL bytes, column-major, one byte = 8 horizontal pixels, MSB
;   leftmost.  All ten records carry IX=0x0668, BC=2, HL=129 -> 16 x 129 pixels,
;   258 bytes; their ptr32 fields are KeyboardRuler_Strip0..9 below.
; COUNT: 10 = the ten records (entries 9-11 of ScreenDispatch_FE8D6B all run
;   the tenth).  STRIDE: 258 = BC*HL, and also exactly the difference between
;   consecutive ptr32 fields.  So the strips tile 0xFF17E2-0xFF21F5 with no gap,
;   and the byte after the tenth is the first instruction of
;   BStoreCursor_SeekNextTag below.
;
; ⚠ CORRECTION (2026-09-25).  This range was `Data_FF17E2`, whose header
; called it 2,695 bytes of undecoded period-8 data that nothing in either image
; addresses, of no identified purpose.  Both halves of that were wrong: the ten
; op-03 records above name each strip, and the last 115 bytes of the old range,
; 0xFF21F6-0xFF2268 (+ the `ret` at 0xFF2269), are the four cursor routines
; below, called from ~70 sites in this module.  What the old header got right
; is kept: 0xFE83D2 `ld XIX,0x00FF17E2` is the END immediate of
; DisplayList_DrumEditPartSelect (0xFF158A), which ends where Strip0 begins.
; ---------------------------------------------------------------------

; KeyboardRuler_Strip0 -- scroll position 0 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip0_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[0] via 0xFE8D9B.  Image: Bitmap_FF17E2.png.
KeyboardRuler_Strip0:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF17E2
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF17F2
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1802
	.byte 0xff, 0xfc, 0xfc, 0x0e, 0x08, 0x08, 0x08, 0x0e, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1812
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1822
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1832
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x0e, 0x08, 0x08, 0x08, 0x0e  ; FF1842
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1852
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1862
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1872
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1882
	.byte 0x01, 0xff, 0x01, 0x01, 0x09, 0x09, 0xc9, 0x09, 0x09, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1892
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF18A2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF18B2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x1d, 0x05, 0xdd, 0x11  ; FF18C2
	.byte 0x1d, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF18D2
	.byte 0x01, 0xff  ; FF18E2

; KeyboardRuler_Strip1 -- scroll position 1 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip1_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[1] via 0xFE8DAA.  Image: Bitmap_FF18E4.png.
KeyboardRuler_Strip1:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF18E4
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF18F4
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1904
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1914
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1924
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1934
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x0e, 0x08, 0x08, 0x08, 0x0e  ; FF1944
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1954
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1964
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1974
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1984
	.byte 0x01, 0xff, 0x01, 0xdd, 0x15, 0x15, 0x15, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1994
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF19A4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF19B4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x09, 0x09, 0xc9, 0x09  ; FF19C4
	.byte 0x09, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF19D4
	.byte 0x01, 0xff  ; FF19E4

; KeyboardRuler_Strip2 -- scroll position 2 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip2_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[2] via 0xFE8DB9.  Image: Bitmap_FF19E6.png.
KeyboardRuler_Strip2:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF19E6
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF19F6
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1A06
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1A16
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1A26
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1A36
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1A46
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1A56
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1A66
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1A76
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1A86
	.byte 0x01, 0xff, 0x01, 0xc9, 0x09, 0x09, 0x09, 0xc9, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1A96
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1AA6
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1AB6
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x15, 0x15, 0x15, 0xdd  ; FF1AC6
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1AD6
	.byte 0x01, 0xff  ; FF1AE6

; KeyboardRuler_Strip3 -- scroll position 3 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip3_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[3] via 0xFE8DC8.  Image: Bitmap_FF1AE8.png.
KeyboardRuler_Strip3:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1AE8
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1AF8
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1B08
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1B18
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1B28
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1B38
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1B48
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1B58
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1B68
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1B78
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1B88
	.byte 0x01, 0xff, 0x01, 0xdd, 0x05, 0x1d, 0x11, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1B98
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1BA8
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1BB8
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xc9, 0x09, 0x09, 0x09, 0xc9  ; FF1BC8
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1BD8
	.byte 0x01, 0xff  ; FF1BE8

; KeyboardRuler_Strip4 -- scroll position 4 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip4_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[4] via 0xFE8DD7.  Image: Bitmap_FF1BEA.png.
KeyboardRuler_Strip4:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1BEA
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1BFA
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1C0A
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1C1A
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1C2A
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1C3A
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1C4A
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1C5A
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1C6A
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1C7A
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1C8A
	.byte 0x01, 0xff, 0x01, 0xdd, 0x05, 0x1d, 0x05, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1C9A
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1CAA
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1CBA
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x05, 0x1d, 0x11, 0xdd  ; FF1CCA
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1CDA
	.byte 0x01, 0xff  ; FF1CEA

; KeyboardRuler_Strip5 -- scroll position 5 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip5_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[5] via 0xFE8DE6.  Image: Bitmap_FF1CEC.png.
KeyboardRuler_Strip5:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1CEC
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1CFC
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1D0C
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1D1C
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1D2C
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1D3C
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1D4C
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1D5C
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1D6C
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1D7C
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1D8C
	.byte 0x01, 0xff, 0x01, 0xd5, 0x15, 0x1d, 0x05, 0xc5, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1D9C
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1DAC
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1DBC
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x05, 0x1d, 0x05, 0xdd  ; FF1DCC
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1DDC
	.byte 0x01, 0xff  ; FF1DEC

; KeyboardRuler_Strip6 -- scroll position 6 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip6_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[6] via 0xFE8DF5.  Image: Bitmap_FF1DEE.png.
KeyboardRuler_Strip6:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1DEE
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1DFE
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1E0E
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1E1E
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1E2E
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1E3E
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1E4E
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1E5E
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1E6E
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1E7E
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1E8E
	.byte 0x01, 0xff, 0x01, 0xdd, 0x11, 0x1d, 0x05, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1E9E
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1EAE
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1EBE
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xd5, 0x15, 0x1d, 0x05, 0xc5  ; FF1ECE
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1EDE
	.byte 0x01, 0xff  ; FF1EEE

; KeyboardRuler_Strip7 -- scroll position 7 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip7_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[7] via 0xFE8E04.  Image: Bitmap_FF1EF0.png.
KeyboardRuler_Strip7:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1EF0
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1F00
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1F10
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1F20
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1F30
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1F40
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF1F50
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF1F60
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1F70
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1F80
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1F90
	.byte 0x01, 0xff, 0x01, 0xdd, 0x11, 0x1d, 0x15, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1FA0
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1FB0
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1FC0
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x11, 0x1d, 0x05, 0xdd  ; FF1FD0
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF1FE0
	.byte 0x01, 0xff  ; FF1FF0

; KeyboardRuler_Strip8 -- scroll position 8 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip8_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[8] via 0xFE8E13.  Image: Bitmap_FF1FF2.png.
KeyboardRuler_Strip8:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF1FF2
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF2002
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2012
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2022
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2032
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2042
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF2052
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF2062
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2072
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2082
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2092
	.byte 0x01, 0xff, 0x01, 0xdd, 0x15, 0x15, 0x05, 0xc5, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF20A2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF20B2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF20C2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x11, 0x1d, 0x15, 0xdd  ; FF20D2
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF20E2
	.byte 0x01, 0xff  ; FF20F2

; KeyboardRuler_Strip9 -- scroll position 9 of 10: 16x129 pixels, 2 columns x 129 bytes.
; Read by: op-03 record KeyboardRuler_DrawStrip9_DL (ptr32 = this label, BC=2, HL=129),
; drawn by ScreenDispatch_FE8D6B[9..11] via 0xFE8E22.  Image: Bitmap_FF20F4.png.
KeyboardRuler_Strip9:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF20F4
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF2104
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2114
	.byte 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2124
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2134
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc  ; FF2144
	.byte 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfd, 0x01, 0x01, 0x01, 0x01, 0x00  ; FF2154
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfc, 0xfc, 0xff, 0xfc, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00  ; FF2164
	.byte 0xff, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2174
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2184
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF2194
	.byte 0x01, 0xff, 0x01, 0xdd, 0x15, 0x1d, 0x15, 0xdd, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF21A4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF21B4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF21C4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xdd, 0x15, 0x15, 0x05, 0xc5  ; FF21D4
	.byte 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; FF21E4
	.byte 0x01, 0xff  ; FF21F4

; ---------------------------------------------------------------------
; THE BLOCK-STORE CURSOR, prom_a's copy: 0xFF21F6-0xFF2269, four routines.
;
; The cursor is the pair ((0x345C) = 1-based BLOCK NUMBER, (0x345E) = BYTE
; OFFSET in that block, 5..0xFF) over the chained 256-byte heap whose base is
; the long at (0x3604) -- the heap prom_b's block store manages
; (wsa1/notes/FINDINGS-prom_b-block-store.md: +1..2 previous block, +3..4 next
; block, +5..0xFF payload).  The block address is computed the way prom_b's
; BStore_SeekBlock does it, (0x3604) + (n-1)*0x100, by the same three
; instructions in every routine here:
;     xor XHL,XHL / ld HL,(0x345C) / dec 1,XHL / sla 8,XHL
;     call BStore_GetHeapBase (XIY = (0x3604)) / add XHL,XIY
; Field offsets are read off these instructions: +3 (next block) at 0xFF221F;
; the offset restarts at 5 (0xFF2226) and the step past 0xFF follows the link
; (0xFF2208), which is the 251-byte payload window the prom_b note derives.
; The backward twin is BStoreCursor_SeekPrevTag (0xFE82EB), which follows +1.
;
; What is NOT claimed: what the tagged stream in the chain encodes.  The
; prom_b note records the tag values its module compares against
; (0x80-0x87) and says their meaning is not established; nothing here adds to
; that.  Note the forward step has NO end-of-chain check -- it follows +3 even
; when it is 0xFFFF; callers bound the walk themselves.
;
; Evidence that these are code, per the lane brief's standard: MAME unidasm and
; llvm-mc agree on every instruction (prom_a/roundtrip.py --block round-trips
; 0xFF21F6-0xFF226A: 22 unidasm + 20 llvm spellings, OK); every internal branch
; lands on an instruction boundary; the one external call target, 0xFE8334,
; is an independently labelled routine; each routine ends in `ret`; and all
; four entries are called from outside (12 + 43 + 54 + 4 call sites: SeekNextTag, Step,
; ReadByte, WriteByte; branch lines outside the block, counted 2026-10-02).
; ---------------------------------------------------------------------

; BStoreCursor_SeekNextTag -- advance the cursor to the next byte with bit 7 SET
; and return it in A.  Step, read, repeat while bit 7 is clear; so a call that
; starts ON a tag byte moves past it to the following one.
; In: (0x345C)/(0x345E).  Out: A = the tag byte; cursor left on it.
; Clobbers: WA, XHL, XIY (through its callees).
; Called from 12 sites in this module (0xFE8CE4, 0xFE9250, 0xFE962D, ... 0xFEFF50).
BStoreCursor_SeekNextTag:
	calr BStoreCursor_Step                               ; FF21F6  1e 0b 00
	calr BStoreCursor_ReadByte                           ; FF21F9  1e 36 00
	bit 0x07,A                                           ; FF21FC  c9 33 07
	jr z, BStoreCursor_SeekNextTag_Continue              ; FF21FF  66 01
	ret                                                  ; FF2201  0e
BStoreCursor_SeekNextTag_Continue:
	jr BStoreCursor_SeekNextTag                          ; FF2202  68 f2

; BStoreCursor_Step -- move the cursor ONE byte forward.
; If the offset (0x345E) is 0xFF -- the last payload byte of the block -- the
; block number becomes the block's +3 NEXT link and the offset restarts at 5;
; otherwise the offset is incremented.  No terminator check (see above).
; In/Out: (0x345C), (0x345E).  Clobbers: WA, XHL, XIY.
; Called from 30 sites in this module, and by BStoreCursor_SeekNextTag.
BStoreCursor_Step:
	ld wa, (BStore_CursorOffset:16)                                   ; FF2204  d1 5e 34 20
	cp WA,0x00ff                                         ; FF2208  d8 cf ff 00
	jr nz, BStoreCursor_Step_SameBlock                   ; FF220C  6e 1d
	xor XHL,XHL                                          ; FF220E  eb d3
	ld hl, (BStore_CursorBlock:16)                                   ; FF2210  d1 5c 34 23
	dec 1,XHL                                            ; FF2214  eb 69
	sla xhl, 0x08                                        ; FF2216  eb ec 08
	call BStore_GetHeapBase                              ; FF2219  1d 34 83 fe
	add XHL,XIY                                          ; FF221D  ed 83
	ld WA,(XHL+0x03)                                     ; FF221F  9b 03 20  ; +3 = NEXT block
	ld (BStore_CursorBlock:16), wa                                   ; FF2222  f1 5c 34 50
	ldw wa, 0x05                                         ; FF2226  30 05 00  ; first payload byte
	jr BStoreCursor_Step_Store                           ; FF2229  68 02
BStoreCursor_Step_SameBlock:
	inc 1,WA                                             ; FF222B  d8 61
BStoreCursor_Step_Store:
	ld (BStore_CursorOffset:16), wa                                   ; FF222D  f1 5e 34 50
	ret                                                  ; FF2231  0e

; BStoreCursor_ReadByte -- A = the byte under the cursor,
; ((0x3604) + ((0x345C)-1)*0x100)[(0x345E)].  The cursor does not move.
; Clobbers: XHL, XIY.  Called from 25 sites, and by BStoreCursor_SeekNextTag
; and BStoreCursor_SeekPrevTag.
BStoreCursor_ReadByte:
	xor XHL,XHL                                          ; FF2232  eb d3
	ld hl, (BStore_CursorBlock:16)                                   ; FF2234  d1 5c 34 23
	dec 1,XHL                                            ; FF2238  eb 69
	sla xhl, 0x08                                        ; FF223A  eb ec 08
	call BStore_GetHeapBase                              ; FF223D  1d 34 83 fe
	add XHL,XIY                                          ; FF2241  ed 83
	ld iy, (BStore_CursorOffset:16)                                   ; FF2243  d1 5e 34 25
	ld A,(XHL+IY)                                        ; FF2247  c3 07 ec f4 21
	ret                                                  ; FF224C  0e

; BStoreCursor_WriteByte -- store A at the byte under the cursor (the
; addressing of BStoreCursor_ReadByte, with WA saved across the heap-base
; call).  The cursor does not move.  Clobbers: XHL, XIY.
; Called from 4 sites, all in one routine near 0xFE99B4-0xFE9A28.
BStoreCursor_WriteByte:
	xor XHL,XHL                                          ; FF224D  eb d3
	ld hl, (BStore_CursorBlock:16)                                   ; FF224F  d1 5c 34 23
	dec 1,XHL                                            ; FF2253  eb 69
	sla xhl, 0x08                                        ; FF2255  eb ec 08
	pushw wa                                             ; FF2258  28
	call BStore_GetHeapBase                              ; FF2259  1d 34 83 fe
	add XHL,XIY                                          ; FF225D  ed 83
	popw wa                                              ; FF225F  48
	ld iy, (BStore_CursorOffset:16)                                   ; FF2260  d1 5e 34 25
	ld (XHL+IY),A                                        ; FF2264  f3 07 ec f4 41
	ret                                                  ; FF2269  0e

; 0xFF226A-0xFF37FF -- 5526 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 5526, 1, 0x0E
