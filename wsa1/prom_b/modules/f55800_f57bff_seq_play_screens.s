

; --------------------------------------------------------------------------
; ModeEnter_RealtimeRecord_Fwd
; Called from: T_ModeEnter_RealtimeRecord_Fwd (0xF40D98, x0)
; Touches: nothing with an absolute address
; Calls:   ModeEnter_RealtimeRecord
; Evidence: thunk slot T_ModeEnter_RealtimeRecord_Fwd holds `jp 0x00F55800`, and 0xF55800 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF5602C` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ModeEnter_RealtimeRecord_Fwd:		; <- T_ModeEnter_RealtimeRecord_Fwd
	calr	ModeEnter_RealtimeRecord	; F55800  calr 0xf5602c
	ret	; F55803  ret

; --------------------------------------------------------------------------
; ModeLeave_RealtimeRecord_Fwd
; Called from: T_ModeLeave_RealtimeRecord_Fwd (0xF40D9C, x0)
; Touches: nothing with an absolute address
; Calls:   ModeLeave_RealtimeRecord
; Evidence: thunk slot T_ModeLeave_RealtimeRecord_Fwd holds `jp 0x00F55804`, and 0xF55804 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF5603C` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ModeLeave_RealtimeRecord_Fwd:		; <- T_ModeLeave_RealtimeRecord_Fwd
	calr	ModeLeave_RealtimeRecord	; F55804  calr 0xf5603c
	ret	; F55807  ret

; --------------------------------------------------------------------------
; ModeEnter_SeqPlay_Fwd
; Called from: T_ModeEnter_SeqPlay_Fwd (0xF40D90, x0)
; Touches: nothing with an absolute address
; Calls:   ModeEnter_SeqPlay
; Evidence: thunk slot T_ModeEnter_SeqPlay_Fwd holds `jp 0x00F55808`, and 0xF55808 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56B5F` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ModeEnter_SeqPlay_Fwd:		; <- T_ModeEnter_SeqPlay_Fwd
	calr	ModeEnter_SeqPlay	; F55808  calr 0xf56b5f
	ret	; F5580B  ret

; --------------------------------------------------------------------------
; ModeLeave_SeqPlay_Fwd
; Called from: T_ModeLeave_SeqPlay_Fwd (0xF40D94, x0)
; Touches: nothing with an absolute address
; Calls:   ModeLeave_SeqPlay
; Evidence: thunk slot T_ModeLeave_SeqPlay_Fwd holds `jp 0x00F5580C`, and 0xF5580C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56B67` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ModeLeave_SeqPlay_Fwd:		; <- T_ModeLeave_SeqPlay_Fwd
	calr	ModeLeave_SeqPlay	; F5580C  calr 0xf56b67
	ret	; F5580F  ret

; --------------------------------------------------------------------------
; ScreenEnter_RealtimeRecordScreen_Fwd
; Called from: T_ScreenEnter_RealtimeRecordScreen_Fwd (0xF40DC0, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_RealtimeRecordScreen
; Evidence: thunk slot T_ScreenEnter_RealtimeRecordScreen_Fwd holds `jp 0x00F55810`, and 0xF55810 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56058` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_RealtimeRecordScreen_Fwd:		; <- T_ScreenEnter_RealtimeRecordScreen_Fwd
	calr	ScreenEnter_RealtimeRecordScreen	; F55810  calr 0xf56058
	ret	; F55813  ret

; --------------------------------------------------------------------------
; ScreenLeave_RealtimeRecordScreen_Fwd
; Called from: T_ScreenLeave_RealtimeRecordScreen_Fwd (0xF40DC4, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_RealtimeRecordScreen
; Evidence: thunk slot T_ScreenLeave_RealtimeRecordScreen_Fwd holds `jp 0x00F55814`, and 0xF55814 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56129` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_RealtimeRecordScreen_Fwd:		; <- T_ScreenLeave_RealtimeRecordScreen_Fwd
	calr	ScreenLeave_RealtimeRecordScreen	; F55814  calr 0xf56129
	ret	; F55817  ret

; --------------------------------------------------------------------------
; ScreenButton_RealtimeRecordScreen
; Called from: T_ScreenButton_RealtimeRecordScreen (0xF40DC8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_RealtimeRecordScreen holds `jp 0x00F55818`, and 0xF55818 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F558AE / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_RealtimeRecordScreen: the +8 BUTTON method of screen 0x06 -- ScreenButtons_RealtimeRecordScreen entry HL.
ScreenButton_RealtimeRecordScreen:		; <- T_ScreenButton_RealtimeRecordScreen
	ld	xix, ScreenButtons_RealtimeRecordScreen	; F55818  ld XIX,0x00f558ae
	call	T_PanelButton_CallTableEntry	; F5581D  call 0xf41b08
	ret	; F55821  ret

; --------------------------------------------------------------------------
; Fwd_F55822
; Called from: T_F40DCC (0xF40DCC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F56524
; Evidence: thunk slot T_F40DCC holds `jp 0x00F55822`, and 0xF55822 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56524` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F55822:		; <- T_F40DCC
	calr	Nop_Ret_F56524	; F55822  calr 0xf56524
	ret	; F55825  ret

; --------------------------------------------------------------------------
; ScreenEnter_MetronomeBalanceScreen_Fwd
; Called from: T_ScreenEnter_MetronomeBalanceScreen_Fwd (0xF40E00, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_MetronomeBalanceScreen
; Evidence: thunk slot T_ScreenEnter_MetronomeBalanceScreen_Fwd holds `jp 0x00F55826`, and 0xF55826 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF5658C` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_MetronomeBalanceScreen_Fwd:		; <- T_ScreenEnter_MetronomeBalanceScreen_Fwd
	calr	ScreenEnter_MetronomeBalanceScreen	; F55826  calr 0xf5658c
	ret	; F55829  ret

; --------------------------------------------------------------------------
; ScreenLeave_MetronomeBalanceScreen_Fwd
; Called from: T_ScreenLeave_MetronomeBalanceScreen_Fwd (0xF40E04, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F56649
; Evidence: thunk slot T_ScreenLeave_MetronomeBalanceScreen_Fwd holds `jp 0x00F5582A`, and 0xF5582A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56649` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_MetronomeBalanceScreen_Fwd:		; <- T_ScreenLeave_MetronomeBalanceScreen_Fwd
	calr	Nop_Ret_F56649	; F5582A  calr 0xf56649
	ret	; F5582D  ret

; --------------------------------------------------------------------------
; ScreenButton_MetronomeBalanceScreen
; Called from: T_ScreenButton_MetronomeBalanceScreen (0xF40E08, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_MetronomeBalanceScreen holds `jp 0x00F5582E`, and 0xF5582E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F5592E / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_MetronomeBalanceScreen: the +8 BUTTON method of screen 0x0C -- ScreenButtons_MetronomeBalanceScreen entry HL.
ScreenButton_MetronomeBalanceScreen:		; <- T_ScreenButton_MetronomeBalanceScreen
	ld	xix, ScreenButtons_MetronomeBalanceScreen	; F5582E  ld XIX,0x00f5592e
	call	T_PanelButton_CallTableEntry	; F55833  call 0xf41b08
	ret	; F55837  ret

; --------------------------------------------------------------------------
; Fwd_F55838
; Called from: T_F40E0C (0xF40E0C, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F56649
; Evidence: thunk slot T_F40E0C holds `jp 0x00F55838`, and 0xF55838 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56649` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F55838:		; <- T_F40E0C
	calr	Nop_Ret_F56649	; F55838  calr 0xf56649
	ret	; F5583B  ret

; --------------------------------------------------------------------------
; ScreenEnter_CycleRecordScreen_Fwd
; Called from: T_ScreenEnter_CycleRecordScreen_Fwd (0xF40DD0, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_CycleRecordScreen
; Evidence: thunk slot T_ScreenEnter_CycleRecordScreen_Fwd holds `jp 0x00F5583C`, and 0xF5583C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF5664A` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_CycleRecordScreen_Fwd:		; <- T_ScreenEnter_CycleRecordScreen_Fwd
	calr	ScreenEnter_CycleRecordScreen	; F5583C  calr 0xf5664a
	ret	; F5583F  ret

; --------------------------------------------------------------------------
; ScreenLeave_CycleRecordScreen_Fwd
; Called from: T_ScreenLeave_CycleRecordScreen_Fwd (0xF40DD4, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_CycleRecordScreen
; Evidence: thunk slot T_ScreenLeave_CycleRecordScreen_Fwd holds `jp 0x00F55840`, and 0xF55840 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF5670C` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_CycleRecordScreen_Fwd:		; <- T_ScreenLeave_CycleRecordScreen_Fwd
	calr	ScreenLeave_CycleRecordScreen	; F55840  calr 0xf5670c
	ret	; F55843  ret

; --------------------------------------------------------------------------
; ScreenButton_CycleRecordScreen
; Called from: T_ScreenButton_CycleRecordScreen (0xF40DD8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_CycleRecordScreen holds `jp 0x00F55844`, and 0xF55844 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F559AE / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_CycleRecordScreen: the +8 BUTTON method of screen 0x08 -- ScreenButtons_CycleRecordScreen entry HL.
ScreenButton_CycleRecordScreen:		; <- T_ScreenButton_CycleRecordScreen
	ld	xix, ScreenButtons_CycleRecordScreen	; F55844  ld XIX,0x00f559ae
	call	T_PanelButton_CallTableEntry	; F55849  call 0xf41b08
	ret	; F5584D  ret

; --------------------------------------------------------------------------
; sub_F5584E
; Called from: T_F40DDC (0xF40DDC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F568AA
; Evidence: thunk slot T_F40DDC holds `jp 0x00F5584E`, and 0xF5584E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F5584E:		; <- T_F40DDC
	calr	Nop_Ret_F568AA	; F5584E  calr 0xf568aa
	ret	; F55851  ret
	ret	; F55852  ret
	ret	; F55853  ret
	ret	; F55854  ret
	ret	; F55855  ret

; --------------------------------------------------------------------------
; ScreenEnter_SeqPlayScreen_Fwd
; Called from: T_ScreenEnter_SeqPlayScreen_Fwd (0xF40DA0, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_SeqPlayScreen
; Evidence: thunk slot T_ScreenEnter_SeqPlayScreen_Fwd holds `jp 0x00F55856`, and 0xF55856 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56B95` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_SeqPlayScreen_Fwd:		; <- T_ScreenEnter_SeqPlayScreen_Fwd
	calr	ScreenEnter_SeqPlayScreen	; F55856  calr 0xf56b95
	ret	; F55859  ret

; --------------------------------------------------------------------------
; ScreenLeave_SeqPlayScreen_Fwd
; Called from: T_ScreenLeave_SeqPlayScreen_Fwd (0xF40DA4, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_SeqPlayScreen
; Evidence: thunk slot T_ScreenLeave_SeqPlayScreen_Fwd holds `jp 0x00F5585A`, and 0xF5585A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56C35` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_SeqPlayScreen_Fwd:		; <- T_ScreenLeave_SeqPlayScreen_Fwd
	calr	ScreenLeave_SeqPlayScreen	; F5585A  calr 0xf56c35
	ret	; F5585D  ret

; --------------------------------------------------------------------------
; ScreenButton_SeqPlayScreen
; Called from: T_ScreenButton_SeqPlayScreen (0xF40DA8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_SeqPlayScreen holds `jp 0x00F5585E`, and 0xF5585E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F55A2E / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_SeqPlayScreen: the +8 BUTTON method of screen 0x12 -- ScreenButtons_SeqPlayScreen entry HL.
ScreenButton_SeqPlayScreen:		; <- T_ScreenButton_SeqPlayScreen
	ld	xix, ScreenButtons_SeqPlayScreen	; F5585E  ld XIX,0x00f55a2e
	call	T_PanelButton_CallTableEntry	; F55863  call 0xf41b08
	ret	; F55867  ret

; --------------------------------------------------------------------------
; Fwd_F55868
; Called from: T_F40DAC (0xF40DAC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F56DF0
; Evidence: thunk slot T_F40DAC holds `jp 0x00F55868`, and 0xF55868 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56DF0` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F55868:		; <- T_F40DAC
	calr	Nop_Ret_F56DF0	; F55868  calr 0xf56df0
	ret	; F5586B  ret

; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayScreen_Fwd
; Called from: T_ScreenEnter_CyclePlayScreen_Fwd (0xF40DB0, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_CyclePlayScreen
; Evidence: thunk slot T_ScreenEnter_CyclePlayScreen_Fwd holds `jp 0x00F5586C`, and 0xF5586C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56DF1` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_CyclePlayScreen_Fwd:		; <- T_ScreenEnter_CyclePlayScreen_Fwd
	calr	ScreenEnter_CyclePlayScreen	; F5586C  calr 0xf56df1
	ret	; F5586F  ret

; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayScreen_Fwd
; Called from: T_ScreenLeave_CyclePlayScreen_Fwd (0xF40DB4, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_CyclePlayScreen
; Evidence: thunk slot T_ScreenLeave_CyclePlayScreen_Fwd holds `jp 0x00F55870`, and 0xF55870 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56E99` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_CyclePlayScreen_Fwd:		; <- T_ScreenLeave_CyclePlayScreen_Fwd
	calr	ScreenLeave_CyclePlayScreen	; F55870  calr 0xf56e99
	ret	; F55873  ret

; --------------------------------------------------------------------------
; ScreenButton_CyclePlayScreen
; Called from: T_ScreenButton_CyclePlayScreen (0xF40DB8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_CyclePlayScreen holds `jp 0x00F55874`, and 0xF55874 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F55AAE / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_CyclePlayScreen: the +8 BUTTON method of screen 0x14 -- ScreenButtons_CyclePlayScreen entry HL.
ScreenButton_CyclePlayScreen:		; <- T_ScreenButton_CyclePlayScreen
	ld	xix, ScreenButtons_CyclePlayScreen	; F55874  ld XIX,0x00f55aae
	call	T_PanelButton_CallTableEntry	; F55879  call 0xf41b08
	ret	; F5587D  ret

; --------------------------------------------------------------------------
; Fwd_F5587E
; Called from: T_F40DBC (0xF40DBC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F56FD5
; Evidence: thunk slot T_F40DBC holds `jp 0x00F5587E`, and 0xF5587E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF56FD5` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F5587E:		; <- T_F40DBC
	calr	Nop_Ret_F56FD5	; F5587E  calr 0xf56fd5
	ret	; F55881  ret

; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayEditScreen_Fwd
; Called from: T_F40DE0 (0xF40DE0, x0), T_F40E14 (0xF40E14, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_CyclePlayEditScreen
; Evidence: thunk slot T_F40DE0 holds `jp 0x00F55882`, and 0xF55882 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57286` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenEnter_CyclePlayEditScreen_Fwd:		; <- T_F40DE0, T_F40E14
	calr	ScreenEnter_CyclePlayEditScreen	; F55882  calr 0xf57286
	ret	; F55885  ret

; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayEditScreen_Fwd
; Called from: T_ScreenLeave_CyclePlayEditScreen_Fwd (0xF40DE4, x0)
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_CyclePlayEditScreen
; Evidence: thunk slot T_ScreenLeave_CyclePlayEditScreen_Fwd holds `jp 0x00F55886`, and 0xF55886 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57311` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
ScreenLeave_CyclePlayEditScreen_Fwd:		; <- T_ScreenLeave_CyclePlayEditScreen_Fwd
	calr	ScreenLeave_CyclePlayEditScreen	; F55886  calr 0xf57311
	ret	; F55889  ret

; --------------------------------------------------------------------------
; ScreenButton_CyclePlayEditScreen
; Called from: T_ScreenButton_CyclePlayEditScreen (0xF40DE8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_CyclePlayEditScreen holds `jp 0x00F5588A`, and 0xF5588A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F55B2E / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_CyclePlayEditScreen: the +8 BUTTON method of screen 0x26 -- ScreenButtons_CyclePlayEditScreen entry HL.
ScreenButton_CyclePlayEditScreen:		; <- T_ScreenButton_CyclePlayEditScreen
	ld	xix, ScreenButtons_CyclePlayEditScreen	; F5588A  ld XIX,0x00f55b2e
	call	T_PanelButton_CallTableEntry	; F5588F  call 0xf41b08
	ret	; F55893  ret

; --------------------------------------------------------------------------
; Fwd_F55894
; Called from: T_F40DEC (0xF40DEC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F57381
; Evidence: thunk slot T_F40DEC holds `jp 0x00F55894`, and 0xF55894 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57381` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F55894:		; <- T_F40DEC
	calr	Nop_Ret_F57381	; F55894  calr 0xf57381
	ret	; F55897  ret

; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayEditScreen29_Fwd
; Called from: T_ScreenEnter_CyclePlayEditScreen29_Fwd (0xF40DF0, x0)
; Touches: nothing with an absolute address
; Calls:   Fwd_F57410
; Evidence: thunk slot T_ScreenEnter_CyclePlayEditScreen29_Fwd holds `jp 0x00F55898`, and 0xF55898 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57410` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayEditScreen29_Fwd: the +0 ENTER slot of screen 0x29 -- forwards to Fwd_F57410, the routine screen 0x26
;   (CyclePlayEditScreen) uses too.
ScreenEnter_CyclePlayEditScreen29_Fwd:		; <- T_ScreenEnter_CyclePlayEditScreen29_Fwd
	calr	Fwd_F57410	; F55898  calr 0xf57410
	ret	; F5589B  ret

; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayEditScreen29_Fwd
; Called from: T_ScreenLeave_CyclePlayEditScreen29_Fwd (0xF40DF4, x0)
; Touches: nothing with an absolute address
; Calls:   Fwd_F57414
; Evidence: thunk slot T_ScreenLeave_CyclePlayEditScreen29_Fwd holds `jp 0x00F5589C`, and 0xF5589C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57414` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayEditScreen29_Fwd: the +4 LEAVE slot of screen 0x29 -- forwards to Fwd_F57414, the routine screen 0x26
;   (CyclePlayEditScreen) uses too.
ScreenLeave_CyclePlayEditScreen29_Fwd:		; <- T_ScreenLeave_CyclePlayEditScreen29_Fwd
	calr	Fwd_F57414	; F5589C  calr 0xf57414
	ret	; F5589F  ret

; --------------------------------------------------------------------------
; ScreenButton_CyclePlayEditScreen29
; Called from: T_ScreenButton_CyclePlayEditScreen29 (0xF40DF8, x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelButton_CallTableEntry
; Evidence: thunk slot T_ScreenButton_CyclePlayEditScreen29 holds `jp 0x00F558A0`, and 0xF558A0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `ld XIX,0x00F55BAE / call 0xF41B08 / ret` -- call entry HL of that
;          32-entry routine table, bounds-checked by prom_a 0xF8BDC5.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ScreenButton_CyclePlayEditScreen29: the +8 BUTTON method of screen 0x29 -- ScreenButtons_CyclePlayEditScreen29 entry HL.
ScreenButton_CyclePlayEditScreen29:		; <- T_ScreenButton_CyclePlayEditScreen29
	ld	xix, ScreenButtons_CyclePlayEditScreen29	; F558A0  ld XIX,0x00f55bae
	call	T_PanelButton_CallTableEntry	; F558A5  call 0xf41b08
	ret	; F558A9  ret

; --------------------------------------------------------------------------
; Fwd_F558AA
; Called from: T_F40DFC (0xF40DFC, x0)
; Touches: nothing with an absolute address
; Calls:   Nop_Ret_F57432
; Evidence: thunk slot T_F40DFC holds `jp 0x00F558AA`, and 0xF558AA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Shape:   `calr`/`call 0xF57432` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F558AA:		; <- T_F40DFC
	calr	Nop_Ret_F57432	; F558AA  calr 0xf57432
	ret	; F558AD  ret

; --------------------------------------------------------------------------
; ScreenButtons_RealtimeRecordScreen -- 32 32-bit routine pointers, table 0 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF56142-0xF56524) and 22 of the 32 are
;                            distinct.
; Read by: the veneer at 0xF55818 -- `ld XIX,0x00F558AE / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_RealtimeRecordScreen: the 32-slot button table of RealtimeRecordScreen (view-B screen 0x06), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_RealtimeRecordScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_SeqPlayAndRealtimeRecord	; -> SoftKeyCol1_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_SeqPlayAndRealtimeRecord	; -> SoftKeyCol2_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_SeqPlayAndRealtimeRecord	; -> SoftKeyCol3_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_SeqPlayAndRealtimeRecord	; -> SoftKeyCol4_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_SeqPlayAndRealtimeRecord	; -> SoftKeyCol5_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_SeqPlayAndRealtimeRecord	; -> SoftKeyCol6_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_SeqPlayAndRealtimeRecord	; -> SoftKeyCol7_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_SeqPlayAndRealtimeRecord	; -> SoftKeyCol8_SeqPlayAndRealtimeRecord
	on_key	KEY_LcdRow1,		LcdKeyRow1_RealtimeRecordScreen	; -> LcdKeyRow1_RealtimeRecordScreen
	on_key	KEY_LcdRow2,		LcdKeyRow2_RealtimeRecordScreen	; -> LcdKeyRow2_RealtimeRecordScreen
	on_key	KEY_LcdRow3,		LcdKeyRow3_RealtimeRecordScreen	; -> LcdKeyRow3_RealtimeRecordScreen
	on_key	KEY_LcdRow4,		Nop_Ret_F56510	; -> Nop_Ret_F56510
	on_key	KEY_LcdRow5,		Nop_Ret_F56510	; -> Nop_Ret_F56510
	on_key	KEY_MinusPlus,		Nop_Ret_F56510	; -> Nop_Ret_F56510
	on_key	KEY_Code0E,		Nop_Ret_F56510	; -> Nop_Ret_F56510
	on_key	KEY_Exit,		ExitKey_RealtimeRecordScreen	; -> ExitKey_RealtimeRecordScreen
	on_key	KEY_Page,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Code11,		SoftKeyCol1Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol1Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code12,		SoftKeyCol2Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol2Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code13,		SoftKeyCol3Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol3Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code14,		SoftKeyCol4Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol4Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code15,		SoftKeyCol5Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol5Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code16,		SoftKeyCol6Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol6Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code17,		SoftKeyCol7Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol7Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code18,		SoftKeyCol8Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol8Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code19,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Code1A,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_NumberPad,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Code1C,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Code1D,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Compare,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	on_key	KEY_Code1F,		Nop_Ret_F56524	; -> Nop_Ret_F56524
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_MetronomeBalanceScreen -- 32 32-bit routine pointers, table 1 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF565BD-0xF56649) and 4 of the 32 are distinct.
; Read by: the veneer at 0xF5582E -- `ld XIX,0x00F5592E / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_MetronomeBalanceScreen: the 32-slot button table of MetronomeBalanceScreen (view-B screen 0x0C), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_MetronomeBalanceScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol2,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol3,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol4,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol5,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol6,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol7,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_SoftKeyCol8,	Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_LcdRow1,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_LcdRow2,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_LcdRow3,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_LcdRow4,		LcdKeyRow4_MetronomeBalanceScreen	; -> LcdKeyRow4_MetronomeBalanceScreen
	on_key	KEY_LcdRow5,		LcdKeyRow5_MetronomeBalanceScreen	; -> LcdKeyRow5_MetronomeBalanceScreen
	on_key	KEY_MinusPlus,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code0E,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Exit,		ExitKey_MetronomeBalanceScreen	; -> ExitKey_MetronomeBalanceScreen
	on_key	KEY_Page,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code11,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code12,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code13,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code14,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code15,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code16,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code17,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code18,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code19,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code1A,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_NumberPad,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code1C,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code1D,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Compare,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	on_key	KEY_Code1F,		Nop_Ret_F56649	; -> Nop_Ret_F56649
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_CycleRecordScreen -- 32 32-bit routine pointers, table 2 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF5672A-0xF568AA) and 10 of the 32 are
;                            distinct.
; Read by: the veneer at 0xF55844 -- `ld XIX,0x00F559AE / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_CycleRecordScreen: the 32-slot button table of CycleRecordScreen (view-B screen 0x08), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_CycleRecordScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol2,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol3,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol4,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol5,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol6,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol7,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_SoftKeyCol8,	Nop_Ret_F5672A	; -> Nop_Ret_F5672A
	on_key	KEY_LcdRow1,		LcdKeyRow1_CycleRecordScreen	; -> LcdKeyRow1_CycleRecordScreen
	on_key	KEY_LcdRow2,		LcdKeyRow2_CycleRecordScreen	; -> LcdKeyRow2_CycleRecordScreen
	on_key	KEY_LcdRow3,		LcdKeyRow3_CycleRecordScreen	; -> LcdKeyRow3_CycleRecordScreen
	on_key	KEY_LcdRow4,		LcdKeyRow4_CycleRecordScreen	; -> LcdKeyRow4_CycleRecordScreen
	on_key	KEY_LcdRow5,		LcdKeyRow5_CycleRecordScreen	; -> LcdKeyRow5_CycleRecordScreen
	on_key	KEY_MinusPlus,		Nop_Ret_F567C8	; -> Nop_Ret_F567C8
	on_key	KEY_Code0E,		Nop_Ret_F567C8	; -> Nop_Ret_F567C8
	on_key	KEY_Exit,		ExitKey_CycleRecordScreen	; -> ExitKey_CycleRecordScreen
	on_key	KEY_Page,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code11,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code12,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code13,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code14,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code15,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code16,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code17,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code18,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code19,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code1A,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_NumberPad,		NumberPadKey_CycleRecordScreen	; -> NumberPadKey_CycleRecordScreen
	on_key	KEY_Code1C,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code1D,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Compare,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	on_key	KEY_Code1F,		Nop_Ret_F568AA	; -> Nop_Ret_F568AA
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_SeqPlayScreen -- 32 32-bit routine pointers, table 3 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF56142-0xF56DF0) and 22 of the 32 are
;                            distinct.
; Read by: the veneer at 0xF5585E -- `ld XIX,0x00F55A2E / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_SeqPlayScreen: the 32-slot button table of SeqPlayScreen (view-B screen 0x12), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_SeqPlayScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_SeqPlayAndRealtimeRecord	; -> SoftKeyCol1_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_SeqPlayAndRealtimeRecord	; -> SoftKeyCol2_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_SeqPlayAndRealtimeRecord	; -> SoftKeyCol3_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_SeqPlayAndRealtimeRecord	; -> SoftKeyCol4_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_SeqPlayAndRealtimeRecord	; -> SoftKeyCol5_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_SeqPlayAndRealtimeRecord	; -> SoftKeyCol6_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_SeqPlayAndRealtimeRecord	; -> SoftKeyCol7_SeqPlayAndRealtimeRecord
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_SeqPlayAndRealtimeRecord	; -> SoftKeyCol8_SeqPlayAndRealtimeRecord
	on_key	KEY_LcdRow1,		LcdKeyRow1_SeqPlayScreen	; -> LcdKeyRow1_SeqPlayScreen
	on_key	KEY_LcdRow2,		LcdKeyRow2_SeqPlayScreen	; -> LcdKeyRow2_SeqPlayScreen
	on_key	KEY_LcdRow3,		LcdKeyRow3_SeqPlayScreen	; -> LcdKeyRow3_SeqPlayScreen
	on_key	KEY_LcdRow4,		Nop_Ret_F56DD8	; -> Nop_Ret_F56DD8
	on_key	KEY_LcdRow5,		Nop_Ret_F56DD8	; -> Nop_Ret_F56DD8
	on_key	KEY_MinusPlus,		Nop_Ret_F56DD8	; -> Nop_Ret_F56DD8
	on_key	KEY_Code0E,		Nop_Ret_F56DD8	; -> Nop_Ret_F56DD8
	on_key	KEY_Exit,		ExitKey_SeqPlayScreen	; -> ExitKey_SeqPlayScreen
	on_key	KEY_Page,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Code11,		SoftKeyCol1Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol1Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code12,		SoftKeyCol2Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol2Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code13,		SoftKeyCol3Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol3Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code14,		SoftKeyCol4Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol4Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code15,		SoftKeyCol5Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol5Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code16,		SoftKeyCol6Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol6Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code17,		SoftKeyCol7Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol7Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code18,		SoftKeyCol8Held_SeqPlayAndRealtimeRecord	; -> SoftKeyCol8Held_SeqPlayAndRealtimeRecord
	on_key	KEY_Code19,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Code1A,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_NumberPad,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Code1C,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Code1D,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Compare,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	on_key	KEY_Code1F,		Nop_Ret_F56DF0	; -> Nop_Ret_F56DF0
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayScreen -- 32 32-bit routine pointers, table 4 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF56EB7-0xF56FD5) and 9 of the 32 are distinct.
; Read by: the veneer at 0xF55874 -- `ld XIX,0x00F55AAE / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayScreen: the 32-slot button table of CyclePlayScreen (view-B screen 0x14), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_CyclePlayScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol2,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol3,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol4,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol5,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol6,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol7,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_SoftKeyCol8,	Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_LcdRow1,		Nop_Ret_F56EB7	; -> Nop_Ret_F56EB7
	on_key	KEY_LcdRow2,		LcdKeyRow2_CyclePlayScreen	; -> LcdKeyRow2_CyclePlayScreen
	on_key	KEY_LcdRow3,		LcdKeyRow3_CyclePlayScreen	; -> LcdKeyRow3_CyclePlayScreen
	on_key	KEY_LcdRow4,		LcdKeyRow4_CyclePlayScreen	; -> LcdKeyRow4_CyclePlayScreen
	on_key	KEY_LcdRow5,		LcdKeyRow5_CyclePlayScreen	; -> LcdKeyRow5_CyclePlayScreen
	on_key	KEY_MinusPlus,		Nop_Ret_F56EF3	; -> Nop_Ret_F56EF3
	on_key	KEY_Code0E,		Nop_Ret_F56EF3	; -> Nop_Ret_F56EF3
	on_key	KEY_Exit,		ExitKey_CyclePlayScreen	; -> ExitKey_CyclePlayScreen
	on_key	KEY_Page,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code11,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code12,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code13,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code14,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code15,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code16,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code17,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code18,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code19,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code1A,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_NumberPad,		NumberPadKey_CyclePlayScreen	; -> NumberPadKey_CyclePlayScreen
	on_key	KEY_Code1C,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code1D,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Compare,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	on_key	KEY_Code1F,		Nop_Ret_F56FD5	; -> Nop_Ret_F56FD5
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayEditScreen -- 32 32-bit routine pointers, table 5 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF57337-0xF57381) and 9 of the 32 are distinct.
; Read by: the veneer at 0xF5588A -- `ld XIX,0x00F55B2E / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayEditScreen: the 32-slot button table of CyclePlayEditScreen (view-B screen 0x26), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_CyclePlayEditScreen:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol2,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol3,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol4,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol5,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol6,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol7,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_SoftKeyCol8,	Nop_Ret_F57337	; -> Nop_Ret_F57337
	on_key	KEY_LcdRow1,		LcdKeyRow1_CyclePlayEditScreen	; -> LcdKeyRow1_CyclePlayEditScreen
	on_key	KEY_LcdRow2,		LcdKeyRow2_CyclePlayEditScreen	; -> LcdKeyRow2_CyclePlayEditScreen
	on_key	KEY_LcdRow3,		LcdKeyRow3_CyclePlayEditScreen	; -> LcdKeyRow3_CyclePlayEditScreen
	on_key	KEY_LcdRow4,		LcdKeyRow4_CyclePlayEditScreen	; -> LcdKeyRow4_CyclePlayEditScreen
	on_key	KEY_LcdRow5,		Nop_Ret_F5736A	; -> Nop_Ret_F5736A
	on_key	KEY_MinusPlus,		Nop_Ret_F5736A	; -> Nop_Ret_F5736A
	on_key	KEY_Code0E,		Nop_Ret_F5736A	; -> Nop_Ret_F5736A
	on_key	KEY_Exit,		ExitKey_CyclePlayEditScreen	; -> ExitKey_CyclePlayEditScreen
	on_key	KEY_Page,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code11,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code12,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code13,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code14,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code15,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code16,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code17,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code18,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code19,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code1A,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_NumberPad,		Fwd_F5737D	; -> Fwd_F5737D
	on_key	KEY_Code1C,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code1D,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Compare,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	on_key	KEY_Code1F,		Nop_Ret_F57381	; -> Nop_Ret_F57381
	keymap_end


; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayEditScreen29 -- 32 32-bit routine pointers, table 6 of the seven
;                            in this bank.  All 32 land inside this span
;                            (0xF57418-0xF57432) and 9 of the 32 are distinct.
; Read by: the veneer at 0xF558A0 -- `ld XIX,0x00F55BAE / call 0xF41B08 /
;          ret`.  T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is `cp
;          HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L / ld
;          XIX,(XIX+L) / call XIX` -- a bounds-checked call of entry HL of the
;          table in XIX.
; Evidence: the ENTRY COUNT IS THE INDEXER'S BOUND (32, from `and L,0x1F`),
;           and the NUMBER OF TABLES is settled by three counts that agree,
;           all re-measured on every emit: the veneer block holds exactly
;           seven `ld XIX,imm32` and their immediates are these seven bases;
;           the first seven 128-byte blocks from 0xF558AE are entirely ROM-
;           range words and the eighth is not; and 0xF55BAE + 0x80 = 0xF55C2E,
;           where the code resumes.  ★ Same shape, same evidence, as the 32
;           tables at 0xF7D000 already converted in this file.
; Unknown: WHICH selector each index is -- so this name is FRAMED, a kind plus
;          an address, not content.  The index space is bounded at 31 by the
;          same `cp HL,0x1F` that bounds Bit32MaskTable, which is a fact about
;          the BOUND and not a claim that the two enumerate the same things.
; --------------------------------------------------------------------------
; ScreenButtons_CyclePlayEditScreen29: the 32-slot button table of CyclePlayEditScreen29 (view-B screen 0x29), indexed by panel
;   button code through T_PanelButton_CallTableEntry (notes/prom_b_sequencer_screen_buttons.py).
ScreenButtons_CyclePlayEditScreen29:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol2,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol3,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol4,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol5,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol6,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol7,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_SoftKeyCol8,	Nop_Ret_F57418	; -> Nop_Ret_F57418
	on_key	KEY_LcdRow1,		LcdKeyRow1_CyclePlayEditScreen29	; -> LcdKeyRow1_CyclePlayEditScreen29
	on_key	KEY_LcdRow2,		LcdKeyRow2_CyclePlayEditScreen29	; -> LcdKeyRow2_CyclePlayEditScreen29
	on_key	KEY_LcdRow3,		LcdKeyRow3_CyclePlayEditScreen29	; -> LcdKeyRow3_CyclePlayEditScreen29
	on_key	KEY_LcdRow4,		LcdKeyRow4_CyclePlayEditScreen29	; -> LcdKeyRow4_CyclePlayEditScreen29
	on_key	KEY_LcdRow5,		Nop_Ret_F57429	; -> Nop_Ret_F57429
	on_key	KEY_MinusPlus,		Nop_Ret_F57429	; -> Nop_Ret_F57429
	on_key	KEY_Code0E,		Nop_Ret_F57429	; -> Nop_Ret_F57429
	on_key	KEY_Exit,		ExitKey_CyclePlayEditScreen29	; -> ExitKey_CyclePlayEditScreen29
	on_key	KEY_Page,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code11,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code12,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code13,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code14,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code15,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code16,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code17,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code18,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code19,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code1A,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_NumberPad,		Fwd_F5742E	; -> Fwd_F5742E
	on_key	KEY_Code1C,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code1D,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Compare,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	on_key	KEY_Code1F,		Nop_Ret_F57432	; -> Nop_Ret_F57432
	keymap_end


; --------------------------------------------------------------------------
; Nop_Ret_F55C2E
; Called from: in-module: 0xF55DEC 0xF55E45
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55C2E is an instruction boundary.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F55C2E:
	ret	; F55C2E  ret

; --------------------------------------------------------------------------
; LCD_BlankThenSetPanel3Layer_Layer0
; Called from: in-module: 0xF55C61 0xF55CB6 0xF55CE7 0xF55D12 0xF55E7D
;              0xF55ED8 0xF55F33
; Touches: (0x2540)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55C2F is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LCD_BlankThenSetPanel3Layer_Layer0: the same two services as LCD_BlankThenSetPanel3Layer_Copy2, then LCD_CurrentLayer = 0; called from
;   Draw_CyclePlayCurrentMeasureCycle / _CurrentMeasureEdit and Draw_CycleRecordCurrentMeasure.  Basis: body + SWI7 table.
LCD_BlankThenSetPanel3Layer_Layer0:
	ld	c, 0:opc	; F55C2F  ld C,0x00
	ld	a, 12:opc	; F55C31  ld A,0x0c
	swi	7	; F55C33  swi 7
	ld	a, 16:opc	; F55C34  ld A,0x10
	swi	7	; F55C36  swi 7
	ld	(LCD_CurrentLayer:16), 0	; F55C37  ld (0x2540),0x00
	ret	; F55C3C  ret

; --------------------------------------------------------------------------
; LCD_ShowAllLayers_Copy
; Called from: in-module: 0xF55CB2 0xF55CE3 0xF55D63 0xF55ED4 0xF55F2F
;              0xF55F9B
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55C3D is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LCD_ShowAllLayers_Copy: C = 7, `swi 7` service 0x0C: display layers 1, 2 and 3 steady on (prom_a's LCD_ShowAllLayers_StackFrame does the
;   same from a stack frame); called from Draw_CycleMasterS0ngMeasureTimeSig.  Basis: body + SWI7 table.
LCD_ShowAllLayers_Copy:
	ld	c, 7:opc	; F55C3D  ld C,0x07
	ld	a, 12:opc	; F55C3F  ld A,0x0c
	swi	7	; F55C41  swi 7
	ret	; F55C42  ret
	ret	; F55C43  ret

; --------------------------------------------------------------------------
; SeqScreen_DrawCountInMeasure
; Called from: in-module: 0xF55CAB 0xF55D5C 0xF55F6D
; Touches: (0x12F6) (0x2540) (0x2652) (0x3552) (0x3753)  |  0xF341B6 0xF34256
;          0xF3434C 0xF34361 0xF343B6 0xF343BC +9 more
; Calls:   T_DLB_Handler_StringTable LCD_BlankThenSetPanel3Layer_Layer0 T_DisplayList_Run SeqScreen_DrawTrackPartLabels
;          SeqScreen_QueueTrackRecPlayLabels SeqPlayScreen_StageValues T_DisplayListB_Run SeqScreen_DrawCountInMeasure T_PanelDial_QueueValueRedraw_Entry
;          LCD_ShowAllLayers_Copy RealtimeRecordScreen_StageValues
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55C44 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqScreen_DrawCountInMeasure: WA = the current measure (0x3552): 0x8002 -> entry 1, 0x8001 -> entry 0 of
;   DLTable_F3435B (' -2' / ' -1') drawn through the caller's string-table record XIY; any other value draws nothing.
;   0x8002/0x8001 are the count-in bars (bit 15 = count-in). Called by the SEQ PLAY, REALTIME RECORD and CYCLE RECORD
;   value painters. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
SeqScreen_DrawCountInMeasure:
	cp	wa, 32770	; F55C44  cp WA,0x8002
	jr	nz, SeqScreen_DrawCountInMeasure_Skip	; F55C48  jr NZ,0xf55c51
	ld	(DisplayListB_Stage:16), 1	; F55C4A  ld (0x12f6),0x01
	jr	SeqScreen_DrawCountInMeasure_Join	; F55C4F  jr T,0xf55c5c
SeqScreen_DrawCountInMeasure_Skip:
	cp	wa, 32769	; F55C51  cp WA,0x8001
	jr	nz, SeqScreen_DrawCountInMeasure_Return	; F55C55  jr NZ,0xf55c60
	ld	(DisplayListB_Stage:16), 0	; F55C57  ld (0x12f6),0x00
SeqScreen_DrawCountInMeasure_Join:
	call	T_DLB_Handler_StringTable	; F55C5C  call 0xf417f8
SeqScreen_DrawCountInMeasure_Return:
	ret	; F55C60  ret
Draw_SequencerPlayS0ngCycleMeasure:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55C61  calr 0xf55c2f
	ld	xiy, DL_SequencerPlayS0ngCycleMeasure	; F55C64  ld XIY,0x00f349c7
	ld	xix, Data_F34C6E	; F55C69  ld XIX,0x00f34c6e
	call	T_DisplayList_Run	; F55C6E  call 0xf417f0
	ld	xiy, DL_F341B6	; F55C72  ld XIY,0x00f341b6
	ld	xix, DL_F34256	; F55C77  ld XIX,0x00f34256
	call	T_DisplayList_Run	; F55C7C  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F55C80  ld (0x2540),0x02
	calr	SeqScreen_DrawTrackPartLabels	; F55C85  calr 0xf55d67
	calr	SeqScreen_QueueTrackRecPlayLabels	; F55C88  calr 0xf55d90
	ret	; F55C8B  ret
Draw_CycleMasterS0ngMeasureTimeSig:
	calr	SeqPlayScreen_StageValues	; F55C8C  calr 0xf57453
	ld	(LCD_CurrentLayer:16), 2	; F55C8F  ld (0x2540),0x02
	ld	xiy, DL_CycleMasterS0ngMeasureTimeSig	; F55C94  ld XIY,0x00f34970
	ld	xix, DLText_OffOn_F349BB	; F55C99  ld XIX,0x00f349bb
	call	T_DisplayListB_Run	; F55C9E  call 0xf417f4
	ld	wa, (13650:16)	; F55CA2  ld WA,(0x3552)
	ld	xiy, DL_F3434C	; F55CA6  ld XIY,0x00f3434c
	calr	SeqScreen_DrawCountInMeasure	; F55CAB  calr 0xf55c44
	call	T_PanelDial_QueueValueRedraw_Entry	; F55CAE  call 0xf415bc
	calr	LCD_ShowAllLayers_Copy	; F55CB2  calr 0xf55c3d
	ret	; F55CB5  ret
Draw_MetronomeBalance:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55CB6  calr 0xf55c2f
	ld	xiy, DL_MetronomeBalance	; F55CB9  ld XIY,0x00f35342
	ld	xix, MetronomeBalanceScreen_PaintValue_DL	; F55CBE  ld XIX,0x00f3539f
	call	T_DisplayList_Run	; F55CC3  call 0xf417f0
	ret	; F55CC7  ret
; MetronomeBalanceScreen_PaintValue: UI_DrawScratch+18 := (0x3753), the balance the screen edits, and MetronomeBalanceScreen_PaintValue_DL prints
;   it as a 3-digit decimal on layer 0; LCD_ShowAllLayers. Posted as a callback by ScreenEnter_MetronomeBalanceScreen
;   and after LCD rows 4/5 step the value. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
MetronomeBalanceScreen_PaintValue:
	ld	a, (14163:16)	; F55CC8  ld A,(0x3753)
	ld	(UI_DrawScratch+18:16), a	; F55CCC  ld (0x2652),A
	ld	(LCD_CurrentLayer:16), 0	; F55CD0  ld (0x2540),0x00
	ld	xiy, MetronomeBalanceScreen_PaintValue_DL	; F55CD5  ld XIY,0x00f3539f
	ld	xix, MetronomeBalanceScreen_PaintValue_DL + 0xC	; F55CDA  ld XIX,0x00f353ab
	call	T_DisplayListB_Run	; F55CDF  call 0xf417f4
	calr	LCD_ShowAllLayers_Copy	; F55CE3  calr 0xf55c3d
	ret	; F55CE6  ret
Draw_RealtimeRecordSongMeasureQuantiTimeSigMasterClear:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55CE7  calr 0xf55c2f
	ld	xiy, DL_RealtimeRecordSongMeasureQuantiTimeSigMasterClear	; F55CEA  ld XIY,0x00f34681
	ld	xix, DL_RealtimeRecordSongMeasureQuantiTimeSigMasterClear + 0x2E7	; F55CEF  ld XIX,0x00f34968
	call	T_DisplayList_Run	; F55CF4  call 0xf417f0
	ld	xiy, DL_F341B6	; F55CF8  ld XIY,0x00f341b6
	ld	xix, DL_F34256	; F55CFD  ld XIX,0x00f34256
	call	T_DisplayList_Run	; F55D02  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F55D06  ld (0x2540),0x02
	calr	SeqScreen_DrawTrackPartLabels	; F55D0B  calr 0xf55d67
	calr	SeqScreen_QueueTrackRecPlayLabels	; F55D0E  calr 0xf55d90
	ret	; F55D11  ret
Draw_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55D12  calr 0xf55c2f
	ld	xiy, DL_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle	; F55D15  ld XIY,0x00f343bc
	ld	xix, DL_RealtimeRecordSongMeasureQuantiTimeSigMasterClear	; F55D1A  ld XIX,0x00f34681
	call	T_DisplayList_Run	; F55D1F  call 0xf417f0
	ld	xiy, DL_F341B6	; F55D23  ld XIY,0x00f341b6
	ld	xix, DL_F34256	; F55D28  ld XIX,0x00f34256
	call	T_DisplayList_Run	; F55D2D  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F55D31  ld (0x2540),0x02
	calr	SeqScreen_DrawTrackPartLabels	; F55D36  calr 0xf55d67
	calr	SeqScreen_QueueTrackRecPlayLabels	; F55D39  calr 0xf55d90
	ret	; F55D3C  ret
; RealtimeRecordScreen_DrawValues: REALTIME RECORD screen values: RealtimeRecordScreen_StageValues, then on layer 2
;   interpreter B from RealtimeRecordScreen_DrawValues_DL to DLText_OffOn_F343B6 (the two OFF/ON readouts, MASTER, SONG, MEASURE, TIME SIG.),
;   the measure's special 0x8001/0x8002 text (SeqScreen_DrawCountInMeasure, DL_F3434C), PanelDial value redraw, show layers. Basis:
;   callers + body -- posted as a callback by the screen's ENTER and its LcdKeyRow1/2 handlers. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
RealtimeRecordScreen_DrawValues:
	calr	RealtimeRecordScreen_StageValues	; F55D3D  calr 0xf57498
	ld	(LCD_CurrentLayer:16), 2	; F55D40  ld (0x2540),0x02
	ld	xiy, RealtimeRecordScreen_DrawValues_DL	; F55D45  ld XIY,0x00f34361
	ld	xix, DLText_OffOn_F343B6	; F55D4A  ld XIX,0x00f343b6
	call	T_DisplayListB_Run	; F55D4F  call 0xf417f4
	ld	wa, (13650:16)	; F55D53  ld WA,(0x3552)
	ld	xiy, DL_F3434C	; F55D57  ld XIY,0x00f3434c
	calr	SeqScreen_DrawCountInMeasure	; F55D5C  calr 0xf55c44
	call	T_PanelDial_QueueValueRedraw_Entry	; F55D5F  call 0xf415bc
	calr	LCD_ShowAllLayers_Copy	; F55D63  calr 0xf55c3d
	ret	; F55D66  ret

; --------------------------------------------------------------------------
; SeqScreen_DrawTrackPartLabels
; Called from: in-module: 0xF55C85 0xF55D0B 0xF55D36
; Touches:   |  0x603422 0xF34D98 0xF34E88
; Calls:   T_DisplayListB_Run
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55D67 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqScreen_DrawTrackPartLabels: Copies the 16 track-to-part bytes (BStore_TrackToPart) to DisplayListB_Stage and runs
;   SeqScreen_DrawTrackPartLabels_DL, which reads each through DLText_P1ToP32 ('P 1'..'P32'). prom_b twin of prom_a
;   EditPartSelect_DrawPartLabels; called by the SEQUENCER PLAY and REALTIME RECORD (clear / cycle) painters. Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SeqScreen_DrawTrackPartLabels:
	ld	xiy, BStore_TrackToPart	; F55D67  ld XIY,0x00603422
	ld	xix, DisplayListB_Stage	; F55D6C  ld XIX,0x000012f6
	ld	c, 16:opc	; F55D71  ld C,0x10
SeqScreen_DrawTrackPartLabels_Join:
	ld	a, (xiy)	; F55D73  ld A,(XIY)
	ld	(xix), a	; F55D75  ld (XIX),A
	dec	1, c	; F55D77  dec 1,C
	jr	z, SeqScreen_DrawTrackPartLabels_Skip	; F55D79  jr Z,0xf55d81
	inc	1, iy	; F55D7B  inc 1,IY
	inc	1, ix	; F55D7D  inc 1,IX
	jr	SeqScreen_DrawTrackPartLabels_Join	; F55D7F  jr T,0xf55d73
SeqScreen_DrawTrackPartLabels_Skip:
	ld	xiy, SeqScreen_DrawTrackPartLabels_DL	; F55D81  ld XIY,0x00f34d98
	ld	xix, DLText_P1ToP32	; F55D86  ld XIX,0x00f34e88
	call	T_DisplayListB_Run	; F55D8B  call 0xf417f4
	ret	; F55D8F  ret

; --------------------------------------------------------------------------
; SeqScreen_QueueTrackRecPlayLabels
; Called from: T_SeqScreen_QueueTrackRecPlayLabels (0xF40E10, x6); in-module: 0xF55C88 0xF55D0E 0xF55D39
;              0xF56574
; Touches: (0x207C) (0x2540) (0x3000) (0x3740)  |  0xF34C6E 0xF34C7A
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal Nop_Ret_F55C2E SeqScreen_PaintActiveTrackHighlights
; Evidence: thunk slot T_SeqScreen_QueueTrackRecPlayLabels holds `jp 0x00F55D90`, and 0xF55D90 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqScreen_QueueTrackRecPlayLabels: On screen ids 0x06, 0x09 and 0x12 only: snapshots the playing mask (0x60341E)
;   into (0x3740) and posts SeqScreen_PaintTrackRecPlayLabels, which writes ' REC' (track in record mask 0x3000), 'PLAY' (in the snapshot) or
;   blanks for each of 16 tracks. Called by the sequencer painters and by the six track arm/disarm routines through
;   T_SeqScreen_QueueTrackRecPlayLabels. Basis: callers + body + text table. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
SeqScreen_QueueTrackRecPlayLabels:		; <- T_SeqScreen_QueueTrackRecPlayLabels
	ld	a, (UI_ScreenId:16)	; F55D90  ld A,(0x207c)
	cp	a, 6:i3	; F55D94  cp A,6
	jr	z, SeqScreen_QueueTrackRecPlayLabels_Skip	; F55D96  jr Z,0xf55da2
	cp	a, 9	; F55D98  cp A,0x09
	jr	z, SeqScreen_QueueTrackRecPlayLabels_Skip	; F55D9B  jr Z,0xf55da2
	cp	a, 18	; F55D9D  cp A,0x12
	jr	nz, SeqScreen_QueueTrackRecPlayLabels_Return	; F55DA0  jr NZ,0xf55dbd
SeqScreen_QueueTrackRecPlayLabels_Skip:
	ld	wa, (6304798:24)	; F55DA2  ld WA,(0x60341e)
	ld	(14144:16), wa	; F55DA7  ld (0x3740),WA
	ld	xwa, SeqScreen_PaintTrackRecPlayLabels	; F55DAB  ld XWA,0x00f55dbe
	push	xwa	; F55DB0  push XWA
	call	T_CallbackQueue_Post	; F55DB1  call 0xf42e84
	inc	4, xsp	; F55DB5  inc 4,XSP
	ld	a, 1:opc	; F55DB7  ld A,0x01
	call	T_Kernel_SemaSignal	; F55DB9  call 0xf42d88
SeqScreen_QueueTrackRecPlayLabels_Return:
	ret	; F55DBD  ret
; SeqScreen_PaintTrackRecPlayLabels: The callback SeqScreen_QueueTrackRecPlayLabels posts: for each of 16 tracks draws
;   ' REC' (bit in the record mask 0x3000), 'PLAY' (bit in the snapshot 0x3740) or four blanks from Data_F34C6E at
;   that track's position (+0x0C table) on layer 2 (swi 7), then SeqScreen_PaintActiveTrackHighlights with HL = snapshot | record mask. Basis:
;   caller + caller header + body + text table. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SeqScreen_PaintTrackRecPlayLabels:
	ldw	wa, 1	; F55DBE  ld WA,0x0001
	xor	bc, bc	; F55DC1  xor BC,BC
SeqScreen_PaintTrackRecPlayLabels_Loop:
	ld	hl, (12288:16)	; F55DC3  ld HL,(0x3000)
	ldfr_werp	hl, 0x3c	; F55DC7  ld RHL3,HL
	and	hl, wa	; F55DCA  and HL,WA
	ldto_werp	hl, 0x3c	; F55DCC  ld HL,RHL3
	jr	z, SeqScreen_PaintTrackRecPlayLabels_Skip2	; F55DCF  jr Z,0xf55dd5
	xor	hl, hl	; F55DD1  xor HL,HL
	jr	SeqScreen_PaintTrackRecPlayLabels_Join	; F55DD3  jr T,0xf55deb
SeqScreen_PaintTrackRecPlayLabels_Skip2:
	ld	hl, (14144:16)	; F55DD5  ld HL,(0x3740)
	ldfr_werp	hl, 0x3c	; F55DD9  ld RHL3,HL
	and	hl, wa	; F55DDC  and HL,WA
	ldto_werp	hl, 0x3c	; F55DDE  ld HL,RHL3
	jr	z, SeqScreen_PaintTrackRecPlayLabels_Skip3	; F55DE1  jr Z,0xf55de8
	ldw	hl, 1	; F55DE3  ld HL,0x0001
	jr	SeqScreen_PaintTrackRecPlayLabels_Join	; F55DE6  jr T,0xf55deb
SeqScreen_PaintTrackRecPlayLabels_Skip3:
	ldw	hl, 2	; F55DE8  ld HL,0x0002
SeqScreen_PaintTrackRecPlayLabels_Join:
	pushw	wa	; F55DEB  push WA
	calr	Nop_Ret_F55C2E	; F55DEC  calr 0xf55c2e
	ld	xiy, Data_F34C6E + 0xC	; F55DEF  ld XIY,0x00f34c7a
	add	iy, bc	; F55DF4  add IY,BC
	ld	ix, (xiy)	; F55DF6  ld IX,(XIY)
	ld	xiy, Data_F34C6E	; F55DF8  ld XIY,0x00f34c6e
	pushw	bc	; F55DFD  push BC
	ldw	bc, 4	; F55DFE  ld BC,0x0004
	ld	a, 6:opc	; F55E01  ld A,0x06
	ld	(LCD_CurrentLayer:16), 2	; F55E03  ld (0x2540),0x02
	swi	7	; F55E08  swi 7
	popw	bc	; F55E09  pop BC
	popw	wa	; F55E0A  pop WA
	add	bc, 2	; F55E0B  add BC,0x0002
	sla	wa, 1	; F55E0F  sla 0x01,WA
	jr	nc, SeqScreen_PaintTrackRecPlayLabels_Loop	; F55E12  jr NC,0xf55dc3
	ld	hl, (14144:16)	; F55E14  ld HL,(0x3740)
	or	hl, (0x3000:16)	; F55E18  or HL,(0x3000)
	calr	SeqScreen_PaintActiveTrackHighlights	; F55E1C  calr 0xf55e20
	ret	; F55E1F  ret

; --------------------------------------------------------------------------
; SeqScreen_PaintActiveTrackHighlights
; Called from: in-module: 0xF55E1C
; Touches: (0x12F6) (0x2540) (0x3552) (0x3627) (0x36CE) (0x3755) (0x3756)  |
;          0xF3437F 0xF3438E 0xF343A2 0xF343AC 0xF34C9A 0xF34CA2 +18 more
; Calls:   T_DisplayList_Run Nop_Ret_F55C2E T_DLB_Handler_Array8 T_DLB_Handler_Array6
;          LCD_BlankThenSetPanel3Layer_Layer0 CyclePlayEditScreen_StageValues T_DisplayListB_Run T_DLB_Handler_Array8_2 LCD_ShowAllLayers_Copy CyclePlayScreen_StageValues
;          CycleRecordScreen_StageValues SeqScreen_DrawCountInMeasure +1 more
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF55E20 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqScreen_PaintActiveTrackHighlights: On layer 1: clears the track-label band (op-0E record at Data_F34C6E+0x2C,
;   SWI7 0x0E LCD_Svc_0E_ClearColumns), then for each of 16 tracks set in HL fills its DLTable_F34D18 box (SWI7 0x05
;   LCD_Svc_05_FillRect) and clears its DLTable_F34CB8 cells otherwise. SeqScreen_PaintTrackRecPlayLabels' tail with
;   HL = PLAY snapshot | record mask. Basis: caller + body + SWI7 services. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqScreen_PaintActiveTrackHighlights:
	ld	(LCD_CurrentLayer:16), 1	; F55E20  ld (0x2540),0x01
	or	(0xc6:8), 0x01	; F55E25  or (0xc6),0x01
	ld	xiy, Data_F34C6E + 0x2C	; F55E29  ld XIY,0x00f34c9a
	ld	xix, Data_F34C6E + 0x34	; F55E2E  ld XIX,0x00f34ca2
	pushw	hl	; F55E33  push HL
	call	T_DisplayList_Run	; F55E34  call 0xf417f0
	popw	hl	; F55E38  pop HL
	cp	hl, 0:i3	; F55E39  cp HL,0
	jr	nz, SeqScreen_PaintActiveTrackHighlights_Skip	; F55E3B  jr NZ,0xf55e3f
	jr	SeqScreen_PaintActiveTrackHighlights_Join2	; F55E3D  jr T,0xf55e78
SeqScreen_PaintActiveTrackHighlights_Skip:
	ldw	wa, 1	; F55E3F  ld WA,0x0001
	xor	c, c	; F55E42  xor C,C
SeqScreen_PaintActiveTrackHighlights_Loop:
	pushw	wa	; F55E44  push WA
	calr	Nop_Ret_F55C2E	; F55E45  calr 0xf55c2e
	popw	wa	; F55E48  pop WA
	ld	(DisplayListB_Stage:16), c	; F55E49  ld (0x12f6),C
	pushw	wa	; F55E4D  push WA
	pushw	hl	; F55E4E  push HL
	pushw	bc	; F55E4F  push BC
	ldfr_werp	hl, 0x3c	; F55E50  ld RHL3,HL
	and	hl, wa	; F55E53  and HL,WA
	ldto_werp	hl, 0x3c	; F55E55  ld HL,RHL3
	jr	z, SeqScreen_PaintActiveTrackHighlights_Skip2	; F55E58  jr Z,0xf55e65
	ld	xiy, Data_F34C6E + 0x34	; F55E5A  ld XIY,0x00f34ca2
	call	T_DLB_Handler_Array8	; F55E5F  call 0xf4181c
	jr	SeqScreen_PaintActiveTrackHighlights_Join	; F55E63  jr T,0xf55e6e
SeqScreen_PaintActiveTrackHighlights_Skip2:
	ld	xiy, Data_F34C6E + 0x3F	; F55E65  ld XIY,0x00f34cad
	call	T_DLB_Handler_Array6	; F55E6A  call 0xf41824
SeqScreen_PaintActiveTrackHighlights_Join:
	popw	bc	; F55E6E  pop BC
	popw	hl	; F55E6F  pop HL
	popw	wa	; F55E70  pop WA
	inc	1, c	; F55E71  inc 1,C
	sla	wa, 1	; F55E73  sla 0x01,WA
	jr	nc, SeqScreen_PaintActiveTrackHighlights_Loop	; F55E76  jr NC,0xf55e44
SeqScreen_PaintActiveTrackHighlights_Join2:
	and	(0xc6:8), 0xfe	; F55E78  and (0xc6),0xfe
	ret	; F55E7C  ret
Draw_CyclePlayCurrentMeasureEdit:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55E7D  calr 0xf55c2f
	ld	xiy, DL_CyclePlayCurrentMeasureEdit	; F55E80  ld XIY,0x00f35208
	ld	xix, DL_F352F9	; F55E85  ld XIX,0x00f352f9
	call	T_DisplayList_Run	; F55E8A  call 0xf417f0
	ret	; F55E8E  ret
; CyclePlayEditScreen_DrawValues: CYCLE PLAY EDIT screen values: CyclePlayEditScreen_StageValues, then on layer 0
;   interpreter B over DL_F352F9 with DLText_OffOn_F3533C, the field highlights on layer 1 from (0x3756) and the
;   cursor (0x3627), LCD_ShowAllLayers_Copy. Posted as a callback by ScreenEnter_CyclePlayEditScreen; twin of
;   RealtimeRecordScreen_DrawValues. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
CyclePlayEditScreen_DrawValues:
	calr	CyclePlayEditScreen_StageValues	; F55E8F  calr 0xf5750c
	ld	(LCD_CurrentLayer:16), 0	; F55E92  ld (0x2540),0x00
	or	(0xc6:8), 0x01	; F55E97  or (0xc6),0x01
	ld	xiy, DL_F352F9	; F55E9B  ld XIY,0x00f352f9
	ld	xix, DLText_OffOn_F3533C	; F55EA0  ld XIX,0x00f3533c
	call	T_DisplayListB_Run	; F55EA5  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 1	; F55EA9  ld (0x2540),0x01
	ld	a, (14166:16)	; F55EAE  ld A,(0x3756)
	ld	(DisplayListB_Stage:16), a	; F55EB2  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x38	; F55EB6  ld XIY,0x00f3502a
	call	T_DLB_Handler_Array8_2	; F55EBB  call 0xf41820
	ld	a, (13863:16)	; F55EBF  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F55EC3  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x2D	; F55EC7  ld XIY,0x00f3501f
	call	T_DLB_Handler_Array8	; F55ECC  call 0xf4181c
	and	(0xc6:8), 0xfe	; F55ED0  and (0xc6),0xfe
	calr	LCD_ShowAllLayers_Copy	; F55ED4  calr 0xf55c3d
	ret	; F55ED7  ret
Draw_CyclePlayCurrentMeasureCycle:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55ED8  calr 0xf55c2f
	ld	xiy, DL_CyclePlayCurrentMeasureCycle	; F55EDB  ld XIY,0x00f34ee8
	ld	xix, DL_F34FF2	; F55EE0  ld XIX,0x00f34ff2
	call	T_DisplayList_Run	; F55EE5  call 0xf417f0
	ret	; F55EE9  ret
; CyclePlayScreen_DrawValues: Values painter of CYCLE PLAY (screen 0x14), posted by ScreenEnter_CyclePlayScreen after
;   the caption painter Draw_CyclePlayCurrentMeasureCycle: CyclePlayScreen_StageValues, the DL_F34FF2 readouts on
;   layer 0 (current measure, cycle start / end, ON/OFF), the two DL_F34FF2 array records on layer 1 staged with
;   (0x3756) and the field cursor (0x3627), then LCD_ShowAllLayers_Copy. Twins: CyclePlayEditScreen_DrawValues (CYCLE PLAY EDIT) and
;   CycleRecordScreen_DrawValues (CYCLE RECORD). Basis: caller + body + staging routine. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
CyclePlayScreen_DrawValues:
	calr	CyclePlayScreen_StageValues	; F55EEA  calr 0xf574de
	ld	(LCD_CurrentLayer:16), 0	; F55EED  ld (0x2540),0x00
	or	(0xc6:8), 0x01	; F55EF2  or (0xc6),0x01
	ld	xiy, DL_F34FF2	; F55EF6  ld XIY,0x00f34ff2
	ld	xix, Data_F35035	; F55EFB  ld XIX,0x00f35035
	call	T_DisplayListB_Run	; F55F00  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 1	; F55F04  ld (0x2540),0x01
	ld	a, (14166:16)	; F55F09  ld A,(0x3756)
	ld	(DisplayListB_Stage:16), a	; F55F0D  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x38	; F55F11  ld XIY,0x00f3502a
	call	T_DLB_Handler_Array8_2	; F55F16  call 0xf41820
	ld	a, (13863:16)	; F55F1A  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F55F1E  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x2D	; F55F22  ld XIY,0x00f3501f
	call	T_DLB_Handler_Array8	; F55F27  call 0xf4181c
	and	(0xc6:8), 0xfe	; F55F2B  and (0xc6),0xfe
	calr	LCD_ShowAllLayers_Copy	; F55F2F  calr 0xf55c3d
	ret	; F55F32  ret
Draw_CycleRecordCurrentMeasure:
	calr	LCD_BlankThenSetPanel3Layer_Layer0	; F55F33  calr 0xf55c2f
	ld	xiy, DL_CycleRecordCurrentMeasure	; F55F36  ld XIY,0x00f3505b
	ld	xix, CycleRecordScreen_DrawValues_DL	; F55F3B  ld XIX,0x00f351a7
	call	T_DisplayList_Run	; F55F40  call 0xf417f0
	ret	; F55F44  ret
; CycleRecordScreen_DrawValues: CYCLE RECORD screen values: CycleRecordScreen_StageValues, interpreter B from
;   CycleRecordScreen_DrawValues_DL to Data_F351F9 on layer 0, the measure's count-in text (SeqScreen_DrawCountInMeasure), the (0x3755) and
;   (0x36CE) arrays on layer 1, show layers. Posted as a callback by ScreenEnter_CycleRecordScreen.
;   RealtimeRecordScreen_DrawValues is its REALTIME RECORD twin. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
CycleRecordScreen_DrawValues:
	calr	CycleRecordScreen_StageValues	; F55F45  calr 0xf57537
	ld	(LCD_CurrentLayer:16), 0	; F55F48  ld (0x2540),0x00
	or	(0xc6:8), 0x01	; F55F4D  or (0xc6),0x01
	ld	xiy, CycleRecordScreen_DrawValues_DL	; F55F51  ld XIY,0x00f351a7
	ld	xix, Data_F351F9	; F55F56  ld XIX,0x00f351f9
	call	T_DisplayListB_Run	; F55F5B  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 0	; F55F5F  ld (0x2540),0x00
	ld	wa, (13650:16)	; F55F64  ld WA,(0x3552)
	ld	xiy, Data_F351F9	; F55F68  ld XIY,0x00f351f9
	calr	SeqScreen_DrawCountInMeasure	; F55F6D  calr 0xf55c44
	ld	(LCD_CurrentLayer:16), 1	; F55F70  ld (0x2540),0x01
	ld	a, (14165:16)	; F55F75  ld A,(0x3755)
	ld	(DisplayListB_Stage:16), a	; F55F79  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x38	; F55F7D  ld XIY,0x00f3502a
	call	T_DLB_Handler_Array8_2	; F55F82  call 0xf41820
	ld	a, (14030:16)	; F55F86  ld A,(0x36ce)
	ld	(DisplayListB_Stage:16), a	; F55F8A  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x2D	; F55F8E  ld XIY,0x00f3501f
	call	T_DLB_Handler_Array8	; F55F93  call 0xf4181c
	and	(0xc6:8), 0xfe	; F55F97  and (0xc6),0xfe
	calr	LCD_ShowAllLayers_Copy	; F55F9B  calr 0xf55c3d
	ret	; F55F9E  ret
sub_F55F9F:
	ld	(LCD_CurrentLayer:16), 0	; F55F9F  ld (0x2540),0x00
	ld	xiy, DL_F34FF2	; F55FA4  ld XIY,0x00f34ff2
	ld	xix, DL_F34FF2 + 0xF	; F55FA9  ld XIX,0x00f35001
	call	T_DisplayListB_Run	; F55FAE  call 0xf417f4
	ret	; F55FB2  ret
; CycleRecordScreen_BlinkStartAndEndMeasureReadouts: The callback CycleRecordScreen_BlinkStartAndEndMeasures posts: on
;   layer 0 hands Blink_Command both CYCLE RECORD measure readout records, CycleRecordScreen_DrawValues_DL + 0x28
;   (start, UI_DrawScratch+22) and + 0x32 (end, UI_DrawScratch+24). Two-field form of
;   CycleRecordScreen_BlinkStartMeasureReadout / _BlinkEndMeasureReadout. Basis: caller + body + twins. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
CycleRecordScreen_BlinkStartAndEndMeasureReadouts:
	ld	(LCD_CurrentLayer:16), 0	; F55FB3  ld (0x2540),0x00
	ld	xiy, CycleRecordScreen_DrawValues_DL + 0x28	; F55FB8  ld XIY,0x00f351cf
	push	xiy	; F55FBD  push XIY
	call	T_Blink_Command	; F55FBE  call 0xf42e20
	inc	4, xsp	; F55FC2  inc 4,XSP
	ld	xiy, CycleRecordScreen_DrawValues_DL + 0x32	; F55FC4  ld XIY,0x00f351d9
	push	xiy	; F55FC9  push XIY
	call	T_Blink_Command	; F55FCA  call 0xf42e20
	inc	4, xsp	; F55FCE  inc 4,XSP
	ret	; F55FD0  ret
; CyclePlayScreen_BlinkStartAndEndMeasureReadouts: The callback CyclePlayScreen_BlinkStartAndEndMeasures posts: on
;   layer 0 hands Blink_Command both CYCLE PLAY measure readout records, DL_F34FF2 + 0x19 (start, UI_DrawScratch+18)
;   and + 0x23 (end, UI_DrawScratch+20). Two-field form of CyclePlayScreen_BlinkStartMeasureReadout /
;   _BlinkEndMeasureReadout; CYCLE RECORD twin CycleRecordScreen_BlinkStartAndEndMeasureReadouts. Basis: caller + body
;   + twins. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
CyclePlayScreen_BlinkStartAndEndMeasureReadouts:
	ld	(LCD_CurrentLayer:16), 0	; F55FD1  ld (0x2540),0x00
	ld	xiy, DL_F34FF2 + 0x19	; F55FD6  ld XIY,0x00f3500b
	push	xiy	; F55FDB  push XIY
	call	T_Blink_Command	; F55FDC  call 0xf42e20
	inc	4, xsp	; F55FE0  inc 4,XSP
	ld	xiy, DL_F34FF2 + 0x23	; F55FE2  ld XIY,0x00f35015
	push	xiy	; F55FE7  push XIY
	call	T_Blink_Command	; F55FE8  call 0xf42e20
	inc	4, xsp	; F55FEC  inc 4,XSP
	ret	; F55FEE  ret
sub_F55FEF:
	ld	(LCD_CurrentLayer:16), 0	; F55FEF  ld (0x2540),0x00
	ld	xiy, DL_F352F9	; F55FF4  ld XIY,0x00f352f9
	ld	xix, DL_F352F9 + 0xF	; F55FF9  ld XIX,0x00f35308
	call	T_DisplayListB_Run	; F55FFE  call 0xf417f4
	ret	; F56002  ret
DisplayListB_Run_TimeSig:
	ld	(LCD_CurrentLayer:16), 2	; F56003  ld (0x2540),0x02
	ld	xiy, DL_TimeSig	; F56008  ld XIY,0x00f343a2
	ld	xix, DL_TimeSig + 0xA	; F5600D  ld XIX,0x00f343ac
	call	T_DisplayListB_Run	; F56012  call 0xf417f4
	ret	; F56016  ret
DisplayListB_Run_MasterSongMeasure:
	ld	(LCD_CurrentLayer:16), 2	; F56017  ld (0x2540),0x02
	ld	xiy, DL_MasterSongMeasure	; F5601C  ld XIY,0x00f3437f
	ld	xix, DL_MasterSongMeasure + 0xF	; F56021  ld XIX,0x00f3438e
	call	T_DisplayListB_Run	; F56026  call 0xf417f4
	ret	; F5602A  ret
	ret	; F5602B  ret

; --------------------------------------------------------------------------
; ModeEnter_RealtimeRecord
; Called from: in-module: 0xF55800
; Touches: nothing with an absolute address
; Calls:   T_RealtimeRecord_InitOnModeEnter Seq_RestorePlayingTrackMask T_RealtimeRecord_Arm T_SeqRecord_SaveCursorBaseline
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5602C is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModeEnter_RealtimeRecord: the +0 ENTER of panel mode 5 -- PanelScreen_VtableTable[5] (view A, indexed by PanelMode) is the
;   thunk triple T_ModeEnter_RealtimeRecord_Fwd, and PanelMode_ToScreenIdMap[5] = 0x06, RealtimeRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
ModeEnter_RealtimeRecord:
	call	T_RealtimeRecord_InitOnModeEnter	; F5602C  call 0xf40cf0
	calr	Seq_RestorePlayingTrackMask	; F56030  calr 0xf57433
	call	T_RealtimeRecord_Arm	; F56033  call 0xf40ce8
	call	T_SeqRecord_SaveCursorBaseline	; F56037  call 0xf40bd8
	ret	; F5603B  ret

; --------------------------------------------------------------------------
; ModeLeave_RealtimeRecord
; Called from: in-module: 0xF55804
; Touches: (0x34D1) (0x36C6) (0x36CA) (0x3758)
; Calls:   T_RealtimeRecord_Disarm Seq_SavePlayingTrackMask
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5603C is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModeLeave_RealtimeRecord: the +4 LEAVE of panel mode 5 (thunk T_ModeLeave_RealtimeRecord_Fwd).
ModeLeave_RealtimeRecord:
	and	(0x34d1:16), 0xef	; F5603C  and (0x34d1),0xef
	call	T_RealtimeRecord_Disarm	; F56041  call 0xf40cec
	xor	xwa, xwa	; F56045  xor XWA,XWA
	ld	(14026:16), xwa	; F56047  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F5604B  ld (0x36c6),XWA
	calr	Seq_SavePlayingTrackMask	; F5604F  calr 0xf57443
	and	(0x3758:16), 0xfe	; F56052  and (0x3758),0xfe
	ret	; F56057  ret

; --------------------------------------------------------------------------
; ScreenEnter_RealtimeRecordScreen
; Called from: in-module: 0xF55810
; Touches: (0x2070) (0x2071) (0x207A) (0x207B) (0x207C) (0x207D) (0x2095)
;          (0x2250) (0x34D1) (0x34D9) +5 more
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_F40CF8 T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart
;          T_Seq_SetTrackBeatsFromTransportB T_CycleRecord_SetUpRecordTrack T_SongMemory_UpdateFreePercent T_Queue2E00_AppendRegs T_NoteRouting_Rebuild
;          T_CallbackQueue_Post T_Kernel_SemaSignal T_Seq_LoadTimeSigAtCurrentMeasure
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56058 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_RealtimeRecordScreen: the +0 ENTER method of screen 0x06 (thunk T_ScreenEnter_RealtimeRecordScreen_Fwd).  Its painter names the screen.
ScreenEnter_RealtimeRecordScreen:
	ld	a, (UI_ScreenLatch:16)	; F56058  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F5605C  cp A,(0x207b)
	jr	nz, ScreenEnter_RealtimeRecordScreen_Skip	; F56060  jr NZ,0xf56073
	ld	a, (UI_ScreenId:16)	; F56062  ld A,(0x207c)
	cp	a, (UI_ScreenId_Previous:16)	; F56066  cp A,(0x207d)
	jr	nz, ScreenEnter_RealtimeRecordScreen_Skip3	; F5606A  jr NZ,0xf560a1
	bit	4, (UI_ScreenFlags:16)	; F5606C  bit 4,(0x2095)
	jrl	nz, ScreenEnter_RealtimeRecordScreen_Join	; F56070  jrl NZ,0xf56112
ScreenEnter_RealtimeRecordScreen_Skip:
	cp	(UI_ScreenLatch_Previous:16), 0x08	; F56073  cp (0x207b),0x08
	jr	z, ScreenEnter_RealtimeRecordScreen_Skip4	; F56078  jr Z,0xf560bb
	bit	2, (TransportB_State:8)	; F5607A  bit 2,(0x96)
	jr	nz, ScreenEnter_RealtimeRecordScreen_Skip3	; F5607D  jr NZ,0xf560a1
	call	T_CallbackQueue_ResetAndRestartTask2	; F5607F  call 0xf42e80
	call	T_F40CF8	; F56083  call 0xf40cf8
	bit	1, (0x360b:16)	; F56087  bit 1,(0x360b)
	jr	z, ScreenEnter_RealtimeRecordScreen_Skip2	; F5608B  jr Z,0xf5609d
	call	T_SeqCycle_CaptureEndCursors	; F5608D  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56091  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56095  call 0xf40ac4
	call	T_CycleRecord_SetUpRecordTrack	; F56099  call 0xf40bdc
ScreenEnter_RealtimeRecordScreen_Skip2:
	call	T_SongMemory_UpdateFreePercent	; F5609D  call 0xf40d00
ScreenEnter_RealtimeRecordScreen_Skip3:
	bit	4, (0x34d1:16)	; F560A1  bit 4,(0x34d1)
	jr	z, ScreenEnter_RealtimeRecordScreen_Skip4	; F560A5  jr Z,0xf560bb
	ld	(UI_Request:16), 1	; F560A7  ld (0x2070),0x01
	ld	(UI_Request_Hi:16), 2	; F560AC  ld (0x2071),0x02
	and	(0x34d1:16), 0xef	; F560B1  and (0x34d1),0xef
	and	(0x3614:16), 0xfe	; F560B6  and (0x3614),0xfe
ScreenEnter_RealtimeRecordScreen_Skip4:
	bit	0, (0x3758:16)	; F560BB  bit 0,(0x3758)
	jr	z, ScreenEnter_RealtimeRecordScreen_Skip5	; F560BF  jr Z,0xf560db
	ld	a, (14167:16)	; F560C1  ld A,(0x3757)
	ld	(UI_PartIndex:16), a	; F560C5  ld (0x2250),A
	and	(0x3758:16), 0xfe	; F560C9  and (0x3758),0xfe
	ld	w, 255:opc	; F560CE  ld W,0xff
	ldw	de, 4240	; F560D0  ld DE,0x1090
	call	T_Queue2E00_AppendRegs	; F560D3  call 0xf40f3c
	call	T_NoteRouting_Rebuild	; F560D7  call 0xf411bc
ScreenEnter_RealtimeRecordScreen_Skip5:
	bit	2, (MidiCfg_ModeBits:16)	; F560DB  bit 2,(0x7f32)
	jr	z, ScreenEnter_RealtimeRecordScreen_Skip6	; F560DF  jr Z,0xf560e6
	and	(0x34d9:16), 0xfe	; F560E1  and (0x34d9),0xfe
ScreenEnter_RealtimeRecordScreen_Skip6:
	bit	1, (0x360b:16)	; F560E6  bit 1,(0x360b)
	jr	nz, ScreenEnter_RealtimeRecordScreen_Skip7	; F560EA  jr NZ,0xf56100
	ld	xwa, Draw_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle	; F560EC  ld XWA,0x00f55d12
	push	xwa	; F560F1  push XWA
	call	T_CallbackQueue_Post	; F560F2  call 0xf42e84
	inc	4, xsp	; F560F6  inc 4,XSP
	ld	a, 1:opc	; F560F8  ld A,0x01
	call	T_Kernel_SemaSignal	; F560FA  call 0xf42d88
	jr	ScreenEnter_RealtimeRecordScreen_Join	; F560FE  jr T,0xf56112
ScreenEnter_RealtimeRecordScreen_Skip7:
	ld	xwa, Draw_RealtimeRecordSongMeasureQuantiTimeSigMasterClear	; F56100  ld XWA,0x00f55ce7
	push	xwa	; F56105  push XWA
	call	T_CallbackQueue_Post	; F56106  call 0xf42e84
	inc	4, xsp	; F5610A  inc 4,XSP
	ld	a, 1:opc	; F5610C  ld A,0x01
	call	T_Kernel_SemaSignal	; F5610E  call 0xf42d88
ScreenEnter_RealtimeRecordScreen_Join:
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56112  call 0xf42704
	ld	xwa, RealtimeRecordScreen_DrawValues	; F56116  ld XWA,0x00f55d3d
	push	xwa	; F5611B  push XWA
	call	T_CallbackQueue_Post	; F5611C  call 0xf42e84
	inc	4, xsp	; F56120  inc 4,XSP
	ld	a, 1:opc	; F56122  ld A,0x01
	call	T_Kernel_SemaSignal	; F56124  call 0xf42d88
	ret	; F56128  ret

; --------------------------------------------------------------------------
; ScreenLeave_RealtimeRecordScreen
; Called from: in-module: 0xF55814
; Touches: (0x2078) (0x207A) (0x207B) (0x20A9)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56129 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenLeave_RealtimeRecordScreen: the +4 LEAVE method of screen 0x06 (thunk T_ScreenLeave_RealtimeRecordScreen_Fwd).
ScreenLeave_RealtimeRecordScreen:
	ld	a, (UI_ScreenLatch:16)	; F56129  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F5612D  cp A,(0x207b)
	jr	nz, ScreenLeave_RealtimeRecordScreen_Skip	; F56131  jr NZ,0xf56135
	jr	ScreenLeave_RealtimeRecordScreen_Return	; F56133  jr T,0xf56141
ScreenLeave_RealtimeRecordScreen_Skip:
	cp	(PanelMode:16), 0x08	; F56135  cp (0x2078),0x08
	jr	z, ScreenLeave_RealtimeRecordScreen_Return	; F5613A  jr Z,0xf56141
	and	(0x20a9:16), 0xfe	; F5613C  and (0x20a9),0xfe
ScreenLeave_RealtimeRecordScreen_Return:
	ret	; F56141  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[0], 0xF55A2E[0]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [0] of the table at 0xF558AE reads 0x00F56142, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56142
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x00 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol1_SeqPlayAndRealtimeRecord: slot 0 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 0 for the column's upper switch, 8 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol1_SeqPlayAndRealtimeRecord:
	bit	7, w	; F56142  bit 0x07,W
	jr	nz, SoftKeyCol1_SeqPlayAndRealtimeRecord_Skip2	; F56145  jr NZ,0xf5614e
	ld	(13826:16), 0	; F56147  ld (0x3602),0x00
	jr	SoftKeyCol1_SeqPlayAndRealtimeRecord_Join	; F5614C  jr T,0xf56153
SoftKeyCol1_SeqPlayAndRealtimeRecord_Skip2:
	ld	(13826:16), 8	; F5614E  ld (0x3602),0x08
SoftKeyCol1_SeqPlayAndRealtimeRecord_Join:
	call	T_SeqTrackKey_Press	; F56153  call 0xf40cc4
	ret	; F56157  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[1], 0xF55A2E[1]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [1] of the table at 0xF558AE reads 0x00F56158, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56158
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x01 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol2_SeqPlayAndRealtimeRecord: slot 1 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 1 for the column's upper switch, 9 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol2_SeqPlayAndRealtimeRecord:
	bit	7, w	; F56158  bit 0x07,W
	jr	nz, SoftKeyCol2_SeqPlayAndRealtimeRecord_Skip3	; F5615B  jr NZ,0xf56164
	ld	(13826:16), 1	; F5615D  ld (0x3602),0x01
	jr	SoftKeyCol2_SeqPlayAndRealtimeRecord_Join2	; F56162  jr T,0xf56169
SoftKeyCol2_SeqPlayAndRealtimeRecord_Skip3:
	ld	(13826:16), 9	; F56164  ld (0x3602),0x09
SoftKeyCol2_SeqPlayAndRealtimeRecord_Join2:
	call	T_SeqTrackKey_Press	; F56169  call 0xf40cc4
	ret	; F5616D  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[2], 0xF55A2E[2]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [2] of the table at 0xF558AE reads 0x00F5616E, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5616E
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x02 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol3_SeqPlayAndRealtimeRecord: slot 2 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 2 for the column's upper switch, 10 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol3_SeqPlayAndRealtimeRecord:
	bit	7, w	; F5616E  bit 0x07,W
	jr	nz, SoftKeyCol3_SeqPlayAndRealtimeRecord_Skip4	; F56171  jr NZ,0xf5617a
	ld	(13826:16), 2	; F56173  ld (0x3602),0x02
	jr	SoftKeyCol3_SeqPlayAndRealtimeRecord_Join3	; F56178  jr T,0xf5617f
SoftKeyCol3_SeqPlayAndRealtimeRecord_Skip4:
	ld	(13826:16), 10	; F5617A  ld (0x3602),0x0a
SoftKeyCol3_SeqPlayAndRealtimeRecord_Join3:
	call	T_SeqTrackKey_Press	; F5617F  call 0xf40cc4
	ret	; F56183  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[3], 0xF55A2E[3]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [3] of the table at 0xF558AE reads 0x00F56184, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56184
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x03 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol4_SeqPlayAndRealtimeRecord: slot 3 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 3 for the column's upper switch, 11 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol4_SeqPlayAndRealtimeRecord:
	bit	7, w	; F56184  bit 0x07,W
	jr	nz, SoftKeyCol4_SeqPlayAndRealtimeRecord_Skip5	; F56187  jr NZ,0xf56190
	ld	(13826:16), 3	; F56189  ld (0x3602),0x03
	jr	SoftKeyCol4_SeqPlayAndRealtimeRecord_Join4	; F5618E  jr T,0xf56195
SoftKeyCol4_SeqPlayAndRealtimeRecord_Skip5:
	ld	(13826:16), 11	; F56190  ld (0x3602),0x0b
SoftKeyCol4_SeqPlayAndRealtimeRecord_Join4:
	call	T_SeqTrackKey_Press	; F56195  call 0xf40cc4
	ret	; F56199  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[4], 0xF55A2E[4]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [4] of the table at 0xF558AE reads 0x00F5619A, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5619A
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x04 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol5_SeqPlayAndRealtimeRecord: slot 4 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 4 for the column's upper switch, 12 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol5_SeqPlayAndRealtimeRecord:
	bit	7, w	; F5619A  bit 0x07,W
	jr	nz, SoftKeyCol5_SeqPlayAndRealtimeRecord_Skip6	; F5619D  jr NZ,0xf561a6
	ld	(13826:16), 4	; F5619F  ld (0x3602),0x04
	jr	SoftKeyCol5_SeqPlayAndRealtimeRecord_Join5	; F561A4  jr T,0xf561ab
SoftKeyCol5_SeqPlayAndRealtimeRecord_Skip6:
	ld	(13826:16), 12	; F561A6  ld (0x3602),0x0c
SoftKeyCol5_SeqPlayAndRealtimeRecord_Join5:
	call	T_SeqTrackKey_Press	; F561AB  call 0xf40cc4
	ret	; F561AF  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[5], 0xF55A2E[5]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [5] of the table at 0xF558AE reads 0x00F561B0, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF561B0
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x05 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol6_SeqPlayAndRealtimeRecord: slot 5 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 5 for the column's upper switch, 13 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol6_SeqPlayAndRealtimeRecord:
	bit	7, w	; F561B0  bit 0x07,W
	jr	nz, SoftKeyCol6_SeqPlayAndRealtimeRecord_Skip7	; F561B3  jr NZ,0xf561bc
	ld	(13826:16), 5	; F561B5  ld (0x3602),0x05
	jr	SoftKeyCol6_SeqPlayAndRealtimeRecord_Join6	; F561BA  jr T,0xf561c1
SoftKeyCol6_SeqPlayAndRealtimeRecord_Skip7:
	ld	(13826:16), 13	; F561BC  ld (0x3602),0x0d
SoftKeyCol6_SeqPlayAndRealtimeRecord_Join6:
	call	T_SeqTrackKey_Press	; F561C1  call 0xf40cc4
	ret	; F561C5  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[6], 0xF55A2E[6]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [6] of the table at 0xF558AE reads 0x00F561C6, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF561C6
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x06 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol7_SeqPlayAndRealtimeRecord: slot 6 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 6 for the column's upper switch, 14 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol7_SeqPlayAndRealtimeRecord:
	bit	7, w	; F561C6  bit 0x07,W
	jr	nz, SoftKeyCol7_SeqPlayAndRealtimeRecord_Skip8	; F561C9  jr NZ,0xf561d2
	ld	(13826:16), 6	; F561CB  ld (0x3602),0x06
	jr	SoftKeyCol7_SeqPlayAndRealtimeRecord_Join7	; F561D0  jr T,0xf561d7
SoftKeyCol7_SeqPlayAndRealtimeRecord_Skip8:
	ld	(13826:16), 14	; F561D2  ld (0x3602),0x0e
SoftKeyCol7_SeqPlayAndRealtimeRecord_Join7:
	call	T_SeqTrackKey_Press	; F561D7  call 0xf40cc4
	ret	; F561DB  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[7], 0xF55A2E[7]
; Touches: (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [7] of the table at 0xF558AE reads 0x00F561DC, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF561DC
;           is an instruction boundary of this transcription.
; Shape:   guarded by `bit 0x07,W`, it writes ONE index to (0x3602) -- 0x07 on
;          one arm and that value plus 8 on the other -- and calls T_SeqTrackKey_Press.
;          The +8 is the only difference between the two arms, so bit 7 of W
;          selects between two halves of one 16-value space.  What the halves
;          are is not established.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol8_SeqPlayAndRealtimeRecord: slot 7 of ScreenButtons_SeqPlayScreen and ScreenButtons_RealtimeRecordScreen:
;   (0x3602) = 7 for the column's upper switch, 15 for the lower (bit 7 of W), then T_SeqTrackKey_Press.
SoftKeyCol8_SeqPlayAndRealtimeRecord:
	bit	7, w	; F561DC  bit 0x07,W
	jr	nz, SoftKeyCol8_SeqPlayAndRealtimeRecord_Skip9	; F561DF  jr NZ,0xf561e8
	ld	(13826:16), 7	; F561E1  ld (0x3602),0x07
	jr	SoftKeyCol8_SeqPlayAndRealtimeRecord_Join8	; F561E6  jr T,0xf561ed
SoftKeyCol8_SeqPlayAndRealtimeRecord_Skip9:
	ld	(13826:16), 15	; F561E8  ld (0x3602),0x0f
SoftKeyCol8_SeqPlayAndRealtimeRecord_Join8:
	call	T_SeqTrackKey_Press	; F561ED  call 0xf40cc4
	ret	; F561F1  ret

; --------------------------------------------------------------------------
; SoftKeyCol1Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[17], 0xF55A2E[17]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [17] of the table at 0xF558AE reads 0x00F561F2, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF561F2 is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x00, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol1Held_SeqPlayAndRealtimeRecord: slot 0x11 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 0 / 8 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol1Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F561F2  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F561F3  ld XBC,(0x2088)
	and	xbc, 1	; F561F7  and XBC,0x00000001
	cp	xbc, 0	; F561FD  cp XBC,0x00000000
	jr	nz, SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Epilogue	; F56203  jr NZ,0xf5621a
	bit	7, w	; F56205  bit 0x07,W
	jr	nz, SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Skip10	; F56208  jr NZ,0xf56211
	ld	(13826:16), 0	; F5620A  ld (0x3602),0x00
	jr	SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Join9	; F5620F  jr T,0xf56216
SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Skip10:
	ld	(13826:16), 8	; F56211  ld (0x3602),0x08
SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Join9:
	call	T_SeqTrackKey_Press	; F56216  call 0xf40cc4
SoftKeyCol1Held_SeqPlayAndRealtimeRecord_Epilogue:
	pop	xbc	; F5621A  pop XBC
	ret	; F5621B  ret

; --------------------------------------------------------------------------
; SoftKeyCol2Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[18], 0xF55A2E[18]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [18] of the table at 0xF558AE reads 0x00F5621C, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5621C is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x01, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol2Held_SeqPlayAndRealtimeRecord: slot 0x12 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 1 / 9 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol2Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F5621C  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F5621D  ld XBC,(0x2088)
	and	xbc, 2	; F56221  and XBC,0x00000002
	cp	xbc, 0	; F56227  cp XBC,0x00000000
	jr	nz, SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Epilogue2	; F5622D  jr NZ,0xf56244
	bit	7, w	; F5622F  bit 0x07,W
	jr	nz, SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Skip11	; F56232  jr NZ,0xf5623b
	ld	(13826:16), 1	; F56234  ld (0x3602),0x01
	jr	SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Join10	; F56239  jr T,0xf56240
SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Skip11:
	ld	(13826:16), 9	; F5623B  ld (0x3602),0x09
SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Join10:
	call	T_SeqTrackKey_Press	; F56240  call 0xf40cc4
SoftKeyCol2Held_SeqPlayAndRealtimeRecord_Epilogue2:
	pop	xbc	; F56244  pop XBC
	ret	; F56245  ret

; --------------------------------------------------------------------------
; SoftKeyCol3Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[19], 0xF55A2E[19]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [19] of the table at 0xF558AE reads 0x00F56246, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56246 is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x02, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol3Held_SeqPlayAndRealtimeRecord: slot 0x13 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 2 / 10 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol3Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F56246  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F56247  ld XBC,(0x2088)
	and	xbc, 4	; F5624B  and XBC,0x00000004
	cp	xbc, 0	; F56251  cp XBC,0x00000000
	jr	nz, SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Epilogue3	; F56257  jr NZ,0xf5626e
	bit	7, w	; F56259  bit 0x07,W
	jr	nz, SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Skip12	; F5625C  jr NZ,0xf56265
	ld	(13826:16), 2	; F5625E  ld (0x3602),0x02
	jr	SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Join11	; F56263  jr T,0xf5626a
SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Skip12:
	ld	(13826:16), 10	; F56265  ld (0x3602),0x0a
SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Join11:
	call	T_SeqTrackKey_Press	; F5626A  call 0xf40cc4
SoftKeyCol3Held_SeqPlayAndRealtimeRecord_Epilogue3:
	pop	xbc	; F5626E  pop XBC
	ret	; F5626F  ret

; --------------------------------------------------------------------------
; SoftKeyCol4Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[20], 0xF55A2E[20]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [20] of the table at 0xF558AE reads 0x00F56270, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56270 is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x03, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol4Held_SeqPlayAndRealtimeRecord: slot 0x14 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 3 / 11 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol4Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F56270  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F56271  ld XBC,(0x2088)
	and	xbc, 8	; F56275  and XBC,0x00000008
	cp	xbc, 0	; F5627B  cp XBC,0x00000000
	jr	nz, SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Epilogue4	; F56281  jr NZ,0xf56298
	bit	7, w	; F56283  bit 0x07,W
	jr	nz, SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Skip13	; F56286  jr NZ,0xf5628f
	ld	(13826:16), 3	; F56288  ld (0x3602),0x03
	jr	SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Join12	; F5628D  jr T,0xf56294
SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Skip13:
	ld	(13826:16), 11	; F5628F  ld (0x3602),0x0b
SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Join12:
	call	T_SeqTrackKey_Press	; F56294  call 0xf40cc4
SoftKeyCol4Held_SeqPlayAndRealtimeRecord_Epilogue4:
	pop	xbc	; F56298  pop XBC
	ret	; F56299  ret

; --------------------------------------------------------------------------
; SoftKeyCol5Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[21], 0xF55A2E[21]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [21] of the table at 0xF558AE reads 0x00F5629A, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5629A is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x04, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol5Held_SeqPlayAndRealtimeRecord: slot 0x15 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 4 / 12 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol5Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F5629A  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F5629B  ld XBC,(0x2088)
	and	xbc, 16	; F5629F  and XBC,0x00000010
	cp	xbc, 0	; F562A5  cp XBC,0x00000000
	jr	nz, SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Epilogue5	; F562AB  jr NZ,0xf562c2
	bit	7, w	; F562AD  bit 0x07,W
	jr	nz, SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Skip14	; F562B0  jr NZ,0xf562b9
	ld	(13826:16), 4	; F562B2  ld (0x3602),0x04
	jr	SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Join13	; F562B7  jr T,0xf562be
SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Skip14:
	ld	(13826:16), 12	; F562B9  ld (0x3602),0x0c
SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Join13:
	call	T_SeqTrackKey_Press	; F562BE  call 0xf40cc4
SoftKeyCol5Held_SeqPlayAndRealtimeRecord_Epilogue5:
	pop	xbc	; F562C2  pop XBC
	ret	; F562C3  ret

; --------------------------------------------------------------------------
; SoftKeyCol6Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[22], 0xF55A2E[22]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [22] of the table at 0xF558AE reads 0x00F562C4, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF562C4 is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x05, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol6Held_SeqPlayAndRealtimeRecord: slot 0x16 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 5 / 13 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol6Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F562C4  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F562C5  ld XBC,(0x2088)
	and	xbc, 32	; F562C9  and XBC,0x00000020
	cp	xbc, 0	; F562CF  cp XBC,0x00000000
	jr	nz, SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Epilogue6	; F562D5  jr NZ,0xf562ec
	bit	7, w	; F562D7  bit 0x07,W
	jr	nz, SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Skip15	; F562DA  jr NZ,0xf562e3
	ld	(13826:16), 5	; F562DC  ld (0x3602),0x05
	jr	SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Join14	; F562E1  jr T,0xf562e8
SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Skip15:
	ld	(13826:16), 13	; F562E3  ld (0x3602),0x0d
SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Join14:
	call	T_SeqTrackKey_Press	; F562E8  call 0xf40cc4
SoftKeyCol6Held_SeqPlayAndRealtimeRecord_Epilogue6:
	pop	xbc	; F562EC  pop XBC
	ret	; F562ED  ret

; --------------------------------------------------------------------------
; SoftKeyCol7Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[23], 0xF55A2E[23]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [23] of the table at 0xF558AE reads 0x00F562EE, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF562EE is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x06, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol7Held_SeqPlayAndRealtimeRecord: slot 0x17 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 6 / 14 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol7Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F562EE  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F562EF  ld XBC,(0x2088)
	and	xbc, 64	; F562F3  and XBC,0x00000040
	cp	xbc, 0	; F562F9  cp XBC,0x00000000
	jr	nz, SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Epilogue7	; F562FF  jr NZ,0xf56316
	bit	7, w	; F56301  bit 0x07,W
	jr	nz, SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Skip16	; F56304  jr NZ,0xf5630d
	ld	(13826:16), 6	; F56306  ld (0x3602),0x06
	jr	SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Join15	; F5630B  jr T,0xf56312
SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Skip16:
	ld	(13826:16), 14	; F5630D  ld (0x3602),0x0e
SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Join15:
	call	T_SeqTrackKey_Press	; F56312  call 0xf40cc4
SoftKeyCol7Held_SeqPlayAndRealtimeRecord_Epilogue7:
	pop	xbc	; F56316  pop XBC
	ret	; F56317  ret

; --------------------------------------------------------------------------
; SoftKeyCol8Held_SeqPlayAndRealtimeRecord
; Called from: table 0xF558AE[24], 0xF55A2E[24]
; Touches: (0x2088) (0x3602)
; Calls:   T_SeqTrackKey_Press
; Evidence: entry [24] of the table at 0xF558AE reads 0x00F56318, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56318 is an instruction boundary of this transcription.
; Shape:   the same (0x3602) write and T_SeqTrackKey_Press call as its siblings, index
;          0x07, but reached only when one bit of the 32-bit word at (0x2088)
;          is CLEAR -- `ld XBC,(0x2088) / and XBC,<one bit> / cp XBC,0 / jr
;          NZ,<skip>`.  So (0x2088) is a 32-bit MASK OF SUPPRESSED indices.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; SoftKeyCol8Held_SeqPlayAndRealtimeRecord: slot 0x18 of the same two tables, the column's held form: unless
;   PanelButton_HeldMask bit 0, the same store of 7 / 15 to (0x3602) and T_SeqTrackKey_Press.
SoftKeyCol8Held_SeqPlayAndRealtimeRecord:
	push	xbc	; F56318  push XBC
	ld	xbc, (PanelButton_HeldMask:16)	; F56319  ld XBC,(0x2088)
	and	xbc, 128	; F5631D  and XBC,0x00000080
	cp	xbc, 0	; F56323  cp XBC,0x00000000
	jr	nz, SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Epilogue8	; F56329  jr NZ,0xf56340
	bit	7, w	; F5632B  bit 0x07,W
	jr	nz, SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Skip17	; F5632E  jr NZ,0xf56337
	ld	(13826:16), 7	; F56330  ld (0x3602),0x07
	jr	SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Join16	; F56335  jr T,0xf5633c
SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Skip17:
	ld	(13826:16), 15	; F56337  ld (0x3602),0x0f
SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Join16:
	call	T_SeqTrackKey_Press	; F5633C  call 0xf40cc4
SoftKeyCol8Held_SeqPlayAndRealtimeRecord_Epilogue8:
	pop	xbc	; F56340  pop XBC
	ret	; F56341  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_RealtimeRecordScreen
; Called from: table 0xF558AE[8]
; Touches: (0x2070) (0x3000) (0x34D9) (0x360B) (0x3622) (0x3624) (0x36D6)
;          (0x7F32)
; Calls:   T_RecordScreen_LcdKeyRow1 T_Seq_LoadTimeSigAtCurrentMeasure T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: entry [8] of the table at 0xF558AE reads 0x00F56342, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56342
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_RealtimeRecordScreen: ScreenButtons_RealtimeRecordScreen[8] -- the LcdKeyRow1 handler of RealtimeRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow1_RealtimeRecordScreen:
	bit	7, w	; F56342  bit 0x07,W
	jr	nz, LcdKeyRow1_RealtimeRecordScreen_Skip20	; F56345  jr NZ,0xf56380
	bit	0, (0x34d9:16)	; F56347  bit 0,(0x34d9)
	jr	nz, LcdKeyRow1_RealtimeRecordScreen_Skip18	; F5634B  jr NZ,0xf56356
	bit	2, (MidiCfg_ModeBits:16)	; F5634D  bit 2,(0x7f32)
	jr	z, LcdKeyRow1_RealtimeRecordScreen_Skip18	; F56351  jr Z,0xf56356
	jrl	LcdKeyRow1_RealtimeRecordScreen_Return2	; F56353  jrl T,0xf563dc
LcdKeyRow1_RealtimeRecordScreen_Skip18:
	call	T_RecordScreen_LcdKeyRow1	; F56356  call 0xf40cfc
	bit	0, (0x34d9:16)	; F5635A  bit 0,(0x34d9)
	jr	z, LcdKeyRow1_RealtimeRecordScreen_Skip19	; F5635E  jr Z,0xf56368
	ldw	(UI_Request:16), 16396	; F56360  ld (0x2070),0x400c
	jr	LcdKeyRow1_RealtimeRecordScreen_Return2	; F56366  jr T,0xf563dc
LcdKeyRow1_RealtimeRecordScreen_Skip19:
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56368  call 0xf42704
	ld	xwa, RealtimeRecordScreen_DrawValues	; F5636C  ld XWA,0x00f55d3d
	push	xwa	; F56371  push XWA
	call	T_CallbackQueue_Post	; F56372  call 0xf42e84
	inc	4, xsp	; F56376  inc 4,XSP
	ld	a, 1:opc	; F56378  ld A,0x01
	call	T_Kernel_SemaSignal	; F5637A  call 0xf42d88
	jr	LcdKeyRow1_RealtimeRecordScreen_Return2	; F5637E  jr T,0xf563dc
LcdKeyRow1_RealtimeRecordScreen_Skip20:
	bit	2, (TransportB_State:8)	; F56380  bit 2,(0x96)
	jr	nz, LcdKeyRow1_RealtimeRecordScreen_Return2	; F56383  jr NZ,0xf563dc
	bit	2, (0x34d9:16)	; F56385  bit 2,(0x34d9)
	jr	nz, LcdKeyRow1_RealtimeRecordScreen_Return2	; F56389  jr NZ,0xf563dc
	bit	1, (0x360b:16)	; F5638B  bit 1,(0x360b)
	jr	z, LcdKeyRow1_RealtimeRecordScreen_Join17	; F5638F  jr Z,0xf563d6
	cpw	(0x3000:16), 0x0000	; F56391  cp (0x3000),0x0000
	jr	z, LcdKeyRow1_RealtimeRecordScreen_Skip21	; F56397  jr Z,0xf563bc
	ld	a, (14038:16)	; F56399  ld A,(0x36d6)
	ld	(6304887:24), a	; F5639D  ld (0x603477),A
	ld	wa, (13858:16)	; F563A2  ld WA,(0x3622)
	ld	(6304888:24), wa	; F563A6  ld (0x603478),WA
	ld	wa, (13860:16)	; F563AB  ld WA,(0x3624)
	inc	1, wa	; F563AF  inc 1,WA
	sub	wa, (0x3622:16)	; F563B1  sub WA,(0x3622)
	ld	(6304890:24), wa	; F563B5  ld (0x60347a),WA
	jr	LcdKeyRow1_RealtimeRecordScreen_Join17	; F563BA  jr T,0xf563d6
LcdKeyRow1_RealtimeRecordScreen_Skip21:
	ld	wa, (13858:16)	; F563BC  ld WA,(0x3622)
	ld	(6304888:24), wa	; F563C0  ld (0x603478),WA
	ld	wa, (13860:16)	; F563C5  ld WA,(0x3624)
	inc	1, wa	; F563C9  inc 1,WA
	sub	wa, (0x3622:16)	; F563CB  sub WA,(0x3622)
	ld	(6304890:24), wa	; F563CF  ld (0x60347a),WA
	jr	LcdKeyRow1_RealtimeRecordScreen_Join17	; F563D4  jr T,0xf563d6
LcdKeyRow1_RealtimeRecordScreen_Join17:
	ldw	(UI_Request:16), 32798	; F563D6  ld (0x2070),0x801e
LcdKeyRow1_RealtimeRecordScreen_Return2:
	ret	; F563DC  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_RealtimeRecordScreen
; Called from: table 0xF558AE[9]
; Touches: (0x2070) (0x3008) (0x300C) (0x34D9) (0x360B) (0x36C6) (0x36CA)
;          (0x36CE)
; Calls:   T_RealtimeRecordScreen_LcdKeyRow2 T_CycleRecord_SetUpRecordTrack T_SeqRecord_RestoreCursorBaseline T_CycleRecord_FreeRecordChain T_SeqRecord_FreeTakeChain2 T_CallbackQueue_Post
;          T_Kernel_SemaSignal T_F40BE0 T_F40BFC
; Evidence: entry [9] of the table at 0xF558AE reads 0x00F563DD, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF563DD
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_RealtimeRecordScreen: ScreenButtons_RealtimeRecordScreen[9] -- the LcdKeyRow2 handler of RealtimeRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_RealtimeRecordScreen:
	bit	7, w	; F563DD  bit 0x07,W
	jr	nz, LcdKeyRow2_RealtimeRecordScreen_Skip23	; F563E0  jr NZ,0xf5645c
	bit	2, (TransportB_State:8)	; F563E2  bit 2,(0x96)
	jrl	nz, LcdKeyRow2_RealtimeRecordScreen_Return3	; F563E5  jrl NZ,0xf56473
	bit	2, (0x34d9:16)	; F563E8  bit 2,(0x34d9)
	jrl	nz, LcdKeyRow2_RealtimeRecordScreen_Return3	; F563EC  jrl NZ,0xf56473
	bit	1, (0x360b:16)	; F563EF  bit 1,(0x360b)
	jr	nz, LcdKeyRow2_RealtimeRecordScreen_Skip22	; F563F3  jr NZ,0xf5640e
	call	T_RealtimeRecordScreen_LcdKeyRow2	; F563F5  call 0xf40cc8
	set	1, (0x360b:16)	; F563F9  set 1,(0x360b)
	call	T_CycleRecord_SetUpRecordTrack	; F563FD  call 0xf40bdc
	ld	(14030:16), 1	; F56401  ld (0x36ce),0x01
	ldw	(UI_Request:16), 32776	; F56406  ld (0x2070),0x8008
	jr	LcdKeyRow2_RealtimeRecordScreen_Return3	; F5640C  jr T,0xf56473
LcdKeyRow2_RealtimeRecordScreen_Skip22:
	res	1, (0x360b:16)	; F5640E  res 1,(0x360b)
	xor	xwa, xwa	; F56412  xor XWA,XWA
	ld	(14026:16), xwa	; F56414  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F56418  ld (0x36c6),XWA
	call	T_SeqRecord_RestoreCursorBaseline	; F5641C  call 0xf40c04
	call	T_CycleRecord_FreeRecordChain	; F56420  call 0xf40bf4
	call	T_SeqRecord_FreeTakeChain2	; F56424  call 0xf40bf8
	xor	xwa, xwa	; F56428  xor XWA,XWA
	ld	(12296:16), xwa	; F5642A  ld (0x3008),XWA
	ld	(12300:16), xwa	; F5642E  ld (0x300c),XWA
	ld	xwa, Draw_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle	; F56432  ld XWA,0x00f55d12
	push	xwa	; F56437  push XWA
	call	T_CallbackQueue_Post	; F56438  call 0xf42e84
	inc	4, xsp	; F5643C  inc 4,XSP
	ld	a, 1:opc	; F5643E  ld A,0x01
	call	T_Kernel_SemaSignal	; F56440  call 0xf42d88
	ld	xwa, RealtimeRecordScreen_DrawValues	; F56444  ld XWA,0x00f55d3d
	push	xwa	; F56449  push XWA
	call	T_CallbackQueue_Post	; F5644A  call 0xf42e84
	inc	4, xsp	; F5644E  inc 4,XSP
	ld	a, 1:opc	; F56450  ld A,0x01
	call	T_Kernel_SemaSignal	; F56452  call 0xf42d88
	call	T_F40BE0	; F56456  call 0xf40be0
	jr	LcdKeyRow2_RealtimeRecordScreen_Return3	; F5645A  jr T,0xf56473
LcdKeyRow2_RealtimeRecordScreen_Skip23:
	bit	1, (0x360b:16)	; F5645C  bit 1,(0x360b)
	jr	nz, LcdKeyRow2_RealtimeRecordScreen_Skip24	; F56460  jr NZ,0xf56464
	jr	LcdKeyRow2_RealtimeRecordScreen_Return3	; F56462  jr T,0xf56473
LcdKeyRow2_RealtimeRecordScreen_Skip24:
	bit	2, (TransportB_State:8)	; F56464  bit 2,(0x96)
	jr	nz, LcdKeyRow2_RealtimeRecordScreen_Skip25	; F56467  jr NZ,0xf5646f
	bit	2, (0x34d9:16)	; F56469  bit 2,(0x34d9)
	jr	nz, LcdKeyRow2_RealtimeRecordScreen_Return3	; F5646D  jr NZ,0xf56473
LcdKeyRow2_RealtimeRecordScreen_Skip25:
	call	T_F40BFC	; F5646F  call 0xf40bfc
LcdKeyRow2_RealtimeRecordScreen_Return3:
	ret	; F56473  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_RealtimeRecordScreen
; Called from: table 0xF558AE[10]
; Touches: (0x2070) (0x2250) (0x3757) (0x3758)
; Calls:   RealtimeRecordScreen_LcdKeyRow3
; Evidence: entry [10] of the table at 0xF558AE reads 0x00F56474, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56474 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_RealtimeRecordScreen: ScreenButtons_RealtimeRecordScreen[10] -- the LcdKeyRow3 handler of RealtimeRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_RealtimeRecordScreen:
	bit	7, w	; F56474  bit 0x07,W
	jr	nz, LcdKeyRow3_RealtimeRecordScreen_Skip26	; F56477  jr NZ,0xf5647e
	calr	RealtimeRecordScreen_LcdKeyRow3	; F56479  calr 0xf56492
	jr	LcdKeyRow3_RealtimeRecordScreen_Return4	; F5647C  jr T,0xf56491
LcdKeyRow3_RealtimeRecordScreen_Skip26:
	ld	a, (UI_PartIndex:16)	; F5647E  ld A,(0x2250)
	ld	(14167:16), a	; F56482  ld (0x3757),A
	or	(0x3758:16), 0x01	; F56486  or (0x3758),0x01
	ldw	(UI_Request:16), 16567	; F5648B  ld (0x2070),0x40b7
LcdKeyRow3_RealtimeRecordScreen_Return4:
	ret	; F56491  ret

; --------------------------------------------------------------------------
; RealtimeRecordScreen_LcdKeyRow3
; Called from: in-module: 0xF56479
; Touches: (0x0DE3) (0x1309) (0x2646) (0x3458) (0x34D9) (0x3752)
; Calls:   SeqMasterTrack_SwitchOff T_CallbackQueue_Post T_Kernel_SemaSignal T_CycleRecord_CheckOn
;          T_CycleRecord_SetUpRecordTrack
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56492 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecordScreen_LcdKeyRow3: the LcdKeyRow3 action of RealtimeRecordScreen -- called only by LcdKeyRow3_RealtimeRecordScreen.
RealtimeRecordScreen_LcdKeyRow3:
	bit	2, (TransportB_State:8)	; F56492  bit 2,(0x96)
	jr	nz, RealtimeRecordScreen_LcdKeyRow3_Return	; F56495  jr NZ,0xf5650f
	bit	2, (0x34d9:16)	; F56497  bit 2,(0x34d9)
	jr	nz, RealtimeRecordScreen_LcdKeyRow3_Return	; F5649B  jr NZ,0xf5650f
	cp	(0x3752:16), 0x00	; F5649D  cp (0x3752),0x00
	jr	z, RealtimeRecordScreen_LcdKeyRow3_Skip	; F564A2  jr Z,0xf564c1
	calr	SeqMasterTrack_SwitchOff	; F564A4  calr 0xf56da8
	ld	a, (14162:16)	; F564A7  ld A,(0x3752)
	ld	(DisplayListB_Stage+19:16), a	; F564AB  ld (0x1309),A
	ld	xwa, DisplayListB_Run_MasterSongMeasure	; F564AF  ld XWA,0x00f56017
	push	xwa	; F564B4  push XWA
	call	T_CallbackQueue_Post	; F564B5  call 0xf42e84
	inc	4, xsp	; F564B9  inc 4,XSP
	ld	a, 1:opc	; F564BB  ld A,0x01
	call	T_Kernel_SemaSignal	; F564BD  call 0xf42d88
RealtimeRecordScreen_LcdKeyRow3_Skip:
	cp	(0x6034d7:24), 0x08	; F564C1  cp (0x6034d7),0x08
	jr	nc, RealtimeRecordScreen_LcdKeyRow3_Skip2	; F564C7  jr NC,0xf564d0
	inc	1, (6304983:24)	; F564C9  inc 1,(0x6034d7)
	jr	RealtimeRecordScreen_LcdKeyRow3_Join	; F564CE  jr T,0xf564d6
RealtimeRecordScreen_LcdKeyRow3_Skip2:
	ld	(6304983:24), 1	; F564D0  ld (0x6034d7),0x01
RealtimeRecordScreen_LcdKeyRow3_Join:
	ld	a, (6304983:24)	; F564D6  ld A,(0x6034d7)
	ld	(TransportA_BeatsPerBar:24), a	; F564DB  ld (0x605000),A
	ld	(0xc3:8), a	; F564E0  ld (0xc3),A
	ld	(13400:16), a	; F564E3  ld (0x3458),A
	pushw	wa	; F564E7  push WA
	call	T_CycleRecord_CheckOn	; F564E8  call 0xf40ccc
	cp	a, 0:i3	; F564EC  cp A,0
	jr	nz, RealtimeRecordScreen_LcdKeyRow3_Skip3	; F564EE  jr NZ,0xf564f4
	call	T_CycleRecord_SetUpRecordTrack	; F564F0  call 0xf40bdc
RealtimeRecordScreen_LcdKeyRow3_Skip3:
	popw	wa	; F564F4  pop WA
	ld	(3555:16), a	; F564F5  ld (0x0de3),A
	ld	(UI_DrawScratch+6:16), a	; F564F9  ld (0x2646),A
	ld	xwa, DisplayListB_Run_TimeSig	; F564FD  ld XWA,0x00f56003
	push	xwa	; F56502  push XWA
	call	T_CallbackQueue_Post	; F56503  call 0xf42e84
	inc	4, xsp	; F56507  inc 4,XSP
	ld	a, 1:opc	; F56509  ld A,0x01
	call	T_Kernel_SemaSignal	; F5650B  call 0xf42d88
RealtimeRecordScreen_LcdKeyRow3_Return:
	ret	; F5650F  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56510
; Called from: table 0xF558AE[11], 0xF558AE[12], 0xF558AE[13], 0xF558AE[14]
; Touches: nothing with an absolute address
; Evidence: entry [11] of the table at 0xF558AE reads 0x00F56510, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56510 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56510:
	ret	; F56510  ret

; --------------------------------------------------------------------------
; ExitKey_RealtimeRecordScreen
; Called from: table 0xF558AE[15]
; Touches: (0x2070)
; Evidence: entry [15] of the table at 0xF558AE reads 0x00F56511, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56511 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_RealtimeRecordScreen: ScreenButtons_RealtimeRecordScreen[15] -- the ExitKey handler of RealtimeRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_RealtimeRecordScreen:
	bit	7, w	; F56511  bit 0x07,W
	jr	nz, ExitKey_RealtimeRecordScreen_Return2	; F56514  jr NZ,0xf56523
	bit	2, (TransportB_State:8)	; F56516  bit 2,(0x96)
	jr	nz, ExitKey_RealtimeRecordScreen_Return2	; F56519  jr NZ,0xf56523
	ldw	(UI_Request:16), 515	; F5651B  ld (0x2070),0x0203
	jr	ExitKey_RealtimeRecordScreen_Return2	; F56521  jr T,0xf56523
ExitKey_RealtimeRecordScreen_Return2:
	ret	; F56523  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56524
; Called from: table 0xF558AE[16], 0xF558AE[25], 0xF558AE[26], 0xF558AE[27],
;              0xF558AE[28], 0xF558AE[29] +2 more; in-module: 0xF55822
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF558AE reads 0x00F56524, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56524 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56524:
	ret	; F56524  ret

; --------------------------------------------------------------------------
; Transport_StopWhileRecording
; Called from: T_Transport_StopWhileRecording (0xF40E18, x2)
; Touches: (0x34D3) (0x34D4) (0x3614)
; Calls:   T_RealtimeRecord_Disarm Transport_StopAllAndWaitC T_F42578 T_Seq_MainLoopService T_CycleRecord_CheckOn T_SeqRecord_SaveCursorBaseline T_NoteRouting_RebuildForSong
;          T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB SeqScreen_QueueTrackRecPlayLabels
; Evidence: thunk slot T_Transport_StopWhileRecording holds `jp 0x00F56525`, and 0xF56525 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transport_StopWhileRecording: The stop arm of the START/STOP keys while recording: T_RealtimeRecord_Disarm under (0x3614) bit 1,
;   Transport_StopAllAndWaitC, T_F42578, T_Seq_MainLoopService (Seq_MainLoopService's stop/teardown), then (0x34D3) bit 1 + T_SeqRecord_SaveCursorBaseline, and on
;   a cycle-record screen (CycleRecord_CheckOn A = 0) SeqCycle_CaptureEndCursors/LocateToStart; ends with SeqScreen_QueueTrackRecPlayLabels. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
Transport_StopWhileRecording:		; <- T_Transport_StopWhileRecording
	set	1, (0x3614:16)	; F56525  set 1,(0x3614)
	call	T_RealtimeRecord_Disarm	; F56529  call 0xf40cec
	res	1, (0x3614:16)	; F5652D  res 1,(0x3614)
	calr	Transport_StopAllAndWaitC	; F56531  calr 0xf56579
	call	T_F42578	; F56534  call 0xf42578
	call	T_Seq_MainLoopService	; F56538  call 0xf409c8
	call	T_CycleRecord_CheckOn	; F5653C  call 0xf40ccc
	cp	a, 0:i3	; F56540  cp A,0
	jr	z, Nop_Ret_F56524_Skip	; F56542  jr Z,0xf56557
	set	1, (0x34d3:16)	; F56544  set 1,(0x34d3)
	call	T_SeqRecord_SaveCursorBaseline	; F56548  call 0xf40bd8
	or	(0x34d4:16), 0x10	; F5654C  or (0x34d4),0x10
	call	T_NoteRouting_RebuildForSong	; F56551  call 0xf411b8
	jr	Nop_Ret_F56524_Join	; F56555  jr T,0xf56574
Nop_Ret_F56524_Skip:
	set	1, (0x34d3:16)	; F56557  set 1,(0x34d3)
	call	T_SeqRecord_SaveCursorBaseline	; F5655B  call 0xf40bd8
	or	(0x34d4:16), 0x10	; F5655F  or (0x34d4),0x10
	call	T_SeqCycle_CaptureEndCursors	; F56564  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56568  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F5656C  call 0xf40ac4
	call	T_NoteRouting_RebuildForSong	; F56570  call 0xf411b8
Nop_Ret_F56524_Join:
	call	SeqScreen_QueueTrackRecPlayLabels	; F56574  call 0xf55d90
	ret	; F56578  ret

; --------------------------------------------------------------------------
; Transport_StopAllAndWaitC
; Called from: in-module: 0xF56531 0xF57327
; Touches: nothing with an absolute address
; Calls:   T_Transport_StopAllRunning
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56579 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transport_StopAllAndWaitC: T_Transport_StopAllRunning, then up to 65,535 passes of a 3-NOP loop while TransportC_State bit 2 (running) stays
;   set; called from ScreenLeave_CyclePlayEditScreen.  Basis: body (named RAM).
Transport_StopAllAndWaitC:
	call	T_Transport_StopAllRunning	; F56579  call 0xf409ac
	ldw	wa, 65535	; F5657D  ld WA,0xffff
	bit	2, (TransportC_State:8)	; F56580  bit 2,(0x95)
	jr	z, Transport_StopAllAndWaitC_Return	; F56583  jr Z,0xf5658b
	nop	; F56585  nop
	nop	; F56586  nop
	nop	; F56587  nop
	djnz16	wa, -11	; F56588  djnz WA,0xf56580
Transport_StopAllAndWaitC_Return:
	ret	; F5658B  ret

; --------------------------------------------------------------------------
; ScreenEnter_MetronomeBalanceScreen
; Called from: in-module: 0xF55826
; Touches: (0x3753) (0x7F05)
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_CallbackQueue_Post
;          T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5658C is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_MetronomeBalanceScreen: the +0 ENTER method of screen 0x0C (thunk T_ScreenEnter_MetronomeBalanceScreen_Fwd).  Its painter names the screen.
ScreenEnter_MetronomeBalanceScreen:
	call	T_CallbackQueue_ResetAndRestartTask2	; F5658C  call 0xf42e80
	ld	a, (32517:16)	; F56590  ld A,(0x7f05)
	ld	(14163:16), a	; F56594  ld (0x3753),A
	ld	xwa, Draw_MetronomeBalance	; F56598  ld XWA,0x00f55cb6
	push	xwa	; F5659D  push XWA
	call	T_CallbackQueue_Post	; F5659E  call 0xf42e84
	inc	4, xsp	; F565A2  inc 4,XSP
	ld	a, 1:opc	; F565A4  ld A,0x01
	call	T_Kernel_SemaSignal	; F565A6  call 0xf42d88
	ld	xwa, MetronomeBalanceScreen_PaintValue	; F565AA  ld XWA,0x00f55cc8
	push	xwa	; F565AF  push XWA
	call	T_CallbackQueue_Post	; F565B0  call 0xf42e84
	inc	4, xsp	; F565B4  inc 4,XSP
	ld	a, 1:opc	; F565B6  ld A,0x01
	call	T_Kernel_SemaSignal	; F565B8  call 0xf42d88
	ret	; F565BC  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_MetronomeBalanceScreen
; Called from: table 0xF5592E[11]
; Touches: (0x2075)
; Calls:   MetronomeBalanceScreen_LcdKeyRow4 T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: entry [11] of the table at 0xF5592E reads 0x00F565BD, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF565BD is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_MetronomeBalanceScreen: ScreenButtons_MetronomeBalanceScreen[11] -- the LcdKeyRow4 handler of MetronomeBalanceScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow4_MetronomeBalanceScreen:
	bit	7, w	; F565BD  bit 0x07,W
	jr	nz, LcdKeyRow4_MetronomeBalanceScreen_Return	; F565C0  jr NZ,0xf565de
	or	(UI_RequestBits:16), 0x08	; F565C2  or (0x2075),0x08
	calr	MetronomeBalanceScreen_LcdKeyRow4	; F565C7  calr 0xf565df
	ld	xwa, MetronomeBalanceScreen_PaintValue	; F565CA  ld XWA,0x00f55cc8
	push	xwa	; F565CF  push XWA
	call	T_CallbackQueue_Post	; F565D0  call 0xf42e84
	inc	4, xsp	; F565D4  inc 4,XSP
	ld	a, 1:opc	; F565D6  ld A,0x01
	call	T_Kernel_SemaSignal	; F565D8  call 0xf42d88
	jr	LcdKeyRow4_MetronomeBalanceScreen_Return	; F565DC  jr T,0xf565de
LcdKeyRow4_MetronomeBalanceScreen_Return:
	ret	; F565DE  ret

; --------------------------------------------------------------------------
; MetronomeBalanceScreen_LcdKeyRow4
; Called from: in-module: 0xF565C7
; Touches: (0x3753) (0x7F05)
; Calls:   T_Queue2E00_AppendRegs
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF565DF is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MetronomeBalanceScreen_LcdKeyRow4: the LcdKeyRow4 action of MetronomeBalanceScreen -- called only by LcdKeyRow4_MetronomeBalanceScreen.
MetronomeBalanceScreen_LcdKeyRow4:
	ld	a, (32517:16)	; F565DF  ld A,(0x7f05)
	cp	a, 127	; F565E3  cp A,0x7f
	jr	nc, MetronomeBalanceScreen_LcdKeyRow4_Return	; F565E6  jr NC,0xf565fc
	inc	1, a	; F565E8  inc 1,A
	ld	(14163:16), a	; F565EA  ld (0x3753),A
	ld	(32517:16), a	; F565EE  ld (0x7f05),A
	ld	e, 152:opc	; F565F2  ld E,0x98
	ld	d, 3:opc	; F565F4  ld D,0x03
	ld	w, 127:opc	; F565F6  ld W,0x7f
	call	T_Queue2E00_AppendRegs	; F565F8  call 0xf40f3c
MetronomeBalanceScreen_LcdKeyRow4_Return:
	ret	; F565FC  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_MetronomeBalanceScreen
; Called from: table 0xF5592E[12]
; Touches: (0x2075)
; Calls:   MetronomeBalanceScreen_LcdKeyRow5 T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: entry [12] of the table at 0xF5592E reads 0x00F565FD, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF565FD is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_MetronomeBalanceScreen: ScreenButtons_MetronomeBalanceScreen[12] -- the LcdKeyRow5 handler of MetronomeBalanceScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow5_MetronomeBalanceScreen:
	bit	7, w	; F565FD  bit 0x07,W
	jr	nz, LcdKeyRow5_MetronomeBalanceScreen_Return2	; F56600  jr NZ,0xf5661e
	or	(UI_RequestBits:16), 0x08	; F56602  or (0x2075),0x08
	calr	MetronomeBalanceScreen_LcdKeyRow5	; F56607  calr 0xf5661f
	ld	xwa, MetronomeBalanceScreen_PaintValue	; F5660A  ld XWA,0x00f55cc8
	push	xwa	; F5660F  push XWA
	call	T_CallbackQueue_Post	; F56610  call 0xf42e84
	inc	4, xsp	; F56614  inc 4,XSP
	ld	a, 1:opc	; F56616  ld A,0x01
	call	T_Kernel_SemaSignal	; F56618  call 0xf42d88
	jr	LcdKeyRow5_MetronomeBalanceScreen_Return2	; F5661C  jr T,0xf5661e
LcdKeyRow5_MetronomeBalanceScreen_Return2:
	ret	; F5661E  ret

; --------------------------------------------------------------------------
; MetronomeBalanceScreen_LcdKeyRow5
; Called from: in-module: 0xF56607
; Touches: (0x3753) (0x7F05)
; Calls:   T_Queue2E00_AppendRegs
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5661F is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MetronomeBalanceScreen_LcdKeyRow5: the LcdKeyRow5 action of MetronomeBalanceScreen -- called only by LcdKeyRow5_MetronomeBalanceScreen.
MetronomeBalanceScreen_LcdKeyRow5:
	ld	a, (32517:16)	; F5661F  ld A,(0x7f05)
	cp	a, 0:i3	; F56623  cp A,0
	jr	ule, MetronomeBalanceScreen_LcdKeyRow5_Return	; F56625  jr ULE,0xf5663b
	dec	1, a	; F56627  dec 1,A
	ld	(14163:16), a	; F56629  ld (0x3753),A
	ld	(32517:16), a	; F5662D  ld (0x7f05),A
	ld	e, 152:opc	; F56631  ld E,0x98
	ld	d, 3:opc	; F56633  ld D,0x03
	ld	w, 127:opc	; F56635  ld W,0x7f
	call	T_Queue2E00_AppendRegs	; F56637  call 0xf40f3c
MetronomeBalanceScreen_LcdKeyRow5_Return:
	ret	; F5663B  ret

; --------------------------------------------------------------------------
; ExitKey_MetronomeBalanceScreen
; Called from: table 0xF5592E[15]
; Touches: (0x209A)
; Evidence: entry [15] of the table at 0xF5592E reads 0x00F5663C, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5663C is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_MetronomeBalanceScreen: ScreenButtons_MetronomeBalanceScreen[15] -- the ExitKey handler of MetronomeBalanceScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_MetronomeBalanceScreen:
	bit	7, w	; F5663C  bit 0x07,W
	jr	nz, ExitKey_MetronomeBalanceScreen_Return2	; F5663F  jr NZ,0xf56648
	ld	(UI_ScreenHoldPending:16), 1	; F56641  ld (0x209a),0x01
	jr	ExitKey_MetronomeBalanceScreen_Return2	; F56646  jr T,0xf56648
ExitKey_MetronomeBalanceScreen_Return2:
	ret	; F56648  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56649
; Called from: table 0xF5592E[0], 0xF5592E[1], 0xF5592E[2], 0xF5592E[3],
;              0xF5592E[4], 0xF5592E[5] +23 more; in-module: 0xF5582A 0xF55838
; Touches: nothing with an absolute address
; Evidence: entry [0] of the table at 0xF5592E reads 0x00F56649, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56649
;           is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56649:
	ret	; F56649  ret

; --------------------------------------------------------------------------
; ScreenEnter_CycleRecordScreen
; Called from: in-module: 0xF5583C
; Touches: (0x2070) (0x2071) (0x207A) (0x207B) (0x207C) (0x207D) (0x2095)
;          (0x34D1) (0x34D9) (0x3614) +3 more
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB
;          T_CycleRecord_SetUpRecordTrack T_CallbackQueue_Post T_Kernel_SemaSignal T_Blink_Stop
;          CycleRecordScreen_UpdateFieldBlink
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5664A is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_CycleRecordScreen: the +0 ENTER method of screen 0x08 (thunk T_ScreenEnter_CycleRecordScreen_Fwd).  Its painter names the screen.
ScreenEnter_CycleRecordScreen:
	ld	a, (UI_ScreenLatch:16)	; F5664A  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F5664E  cp A,(0x207b)
	jr	nz, ScreenEnter_CycleRecordScreen_Skip	; F56652  jr NZ,0xf56664
	ld	a, (UI_ScreenId:16)	; F56654  ld A,(0x207c)
	cp	a, (UI_ScreenId_Previous:16)	; F56658  cp A,(0x207d)
	jr	nz, ScreenEnter_CycleRecordScreen_Skip3	; F5665C  jr NZ,0xf5668f
	bit	4, (UI_ScreenFlags:16)	; F5665E  bit 4,(0x2095)
	jr	nz, ScreenEnter_CycleRecordScreen_Skip6	; F56662  jr NZ,0xf566c6
ScreenEnter_CycleRecordScreen_Skip:
	bit	2, (TransportB_State:8)	; F56664  bit 2,(0x96)
	jr	nz, ScreenEnter_CycleRecordScreen_Skip3	; F56667  jr NZ,0xf5668f
	call	T_CallbackQueue_ResetAndRestartTask2	; F56669  call 0xf42e80
	ld	wa, (13858:16)	; F5666D  ld WA,(0x3622)
	cp	wa, (0x3624:16)	; F56671  cp WA,(0x3624)
	jr	ule, ScreenEnter_CycleRecordScreen_Skip2	; F56675  jr ULE,0xf5667f
	ld	wa, (13858:16)	; F56677  ld WA,(0x3622)
	ld	(13860:16), wa	; F5667B  ld (0x3624),WA
ScreenEnter_CycleRecordScreen_Skip2:
	call	T_SeqCycle_CaptureEndCursors	; F5667F  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56683  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56687  call 0xf40ac4
	call	T_CycleRecord_SetUpRecordTrack	; F5668B  call 0xf40bdc
ScreenEnter_CycleRecordScreen_Skip3:
	bit	4, (0x34d1:16)	; F5668F  bit 4,(0x34d1)
	jr	z, ScreenEnter_CycleRecordScreen_Skip4	; F56693  jr Z,0xf566a9
	ld	(UI_Request:16), 1	; F56695  ld (0x2070),0x01
	ld	(UI_Request_Hi:16), 2	; F5669A  ld (0x2071),0x02
	and	(0x34d1:16), 0xef	; F5669F  and (0x34d1),0xef
	and	(0x3614:16), 0xfe	; F566A4  and (0x3614),0xfe
ScreenEnter_CycleRecordScreen_Skip4:
	bit	2, (MidiCfg_ModeBits:16)	; F566A9  bit 2,(0x7f32)
	jr	z, ScreenEnter_CycleRecordScreen_Skip5	; F566AD  jr Z,0xf566b4
	and	(0x34d9:16), 0xfe	; F566AF  and (0x34d9),0xfe
ScreenEnter_CycleRecordScreen_Skip5:
	ld	xwa, Draw_CycleRecordCurrentMeasure	; F566B4  ld XWA,0x00f55f33
	push	xwa	; F566B9  push XWA
	call	T_CallbackQueue_Post	; F566BA  call 0xf42e84
	inc	4, xsp	; F566BE  inc 4,XSP
	ld	a, 1:opc	; F566C0  ld A,0x01
	call	T_Kernel_SemaSignal	; F566C2  call 0xf42d88
ScreenEnter_CycleRecordScreen_Skip6:
	ld	xwa, CycleRecordScreen_DrawValues	; F566C6  ld XWA,0x00f55f45
	push	xwa	; F566CB  push XWA
	call	T_CallbackQueue_Post	; F566CC  call 0xf42e84
	inc	4, xsp	; F566D0  inc 4,XSP
	ld	a, 1:opc	; F566D2  ld A,0x01
	call	T_Kernel_SemaSignal	; F566D4  call 0xf42d88
	call	T_Blink_Stop	; F566D8  call 0xf42e24
	calr	CycleRecordScreen_UpdateFieldBlink	; F566DC  calr 0xf566e0
	ret	; F566DF  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_UpdateFieldBlink
; Called from: in-module: 0xF566DC
; Touches: (0x36CE)
; Calls:   T_Blink_SetEnable
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF566E0 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_UpdateFieldBlink: Blink_SetEnable(1) when the CYCLE RECORD cursor (0x36CE) is on field 1 or 2 (the
;   start / end measures the number pad edits), Blink_SetEnable(0) otherwise. The last step of
;   ScreenEnter_CycleRecordScreen; the CYCLE RECORD twin of CyclePlayScreen_UpdateFieldBlink. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
CycleRecordScreen_UpdateFieldBlink:
	cp	(0x36ce:16), 0x00	; F566E0  cp (0x36ce),0x00
	jr	z, CycleRecordScreen_UpdateFieldBlink_Join	; F566E5  jr Z,0xf56702
	cp	(0x36ce:16), 0x01	; F566E7  cp (0x36ce),0x01
	jr	z, CycleRecordScreen_UpdateFieldBlink_Skip	; F566EC  jr Z,0xf566f7
	cp	(0x36ce:16), 0x02	; F566EE  cp (0x36ce),0x02
	jr	z, CycleRecordScreen_UpdateFieldBlink_Skip	; F566F3  jr Z,0xf566f7
	jr	CycleRecordScreen_UpdateFieldBlink_Join	; F566F5  jr T,0xf56702
CycleRecordScreen_UpdateFieldBlink_Skip:
	pushw	1	; F566F7  push 0x0001
	call	T_Blink_SetEnable	; F566FA  call 0xf42e28
	inc	2, xsp	; F566FE  inc 2,XSP
	jr	CycleRecordScreen_UpdateFieldBlink_Return	; F56700  jr T,0xf5670b
CycleRecordScreen_UpdateFieldBlink_Join:
	pushw	0	; F56702  push 0x0000
	call	T_Blink_SetEnable	; F56705  call 0xf42e28
	inc	2, xsp	; F56709  inc 2,XSP
CycleRecordScreen_UpdateFieldBlink_Return:
	ret	; F5670B  ret

; --------------------------------------------------------------------------
; ScreenLeave_CycleRecordScreen
; Called from: in-module: 0xF55840
; Touches: (0x207A) (0x207B) (0x34BB) (0x3628)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5670C is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenLeave_CycleRecordScreen: the +4 LEAVE method of screen 0x08 (thunk T_ScreenLeave_CycleRecordScreen_Fwd).
ScreenLeave_CycleRecordScreen:
	ld	a, (UI_ScreenLatch:16)	; F5670C  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F56710  cp A,(0x207b)
	jr	nz, ScreenLeave_CycleRecordScreen_Skip	; F56714  jr NZ,0xf56718
	jr	ScreenLeave_CycleRecordScreen_Return	; F56716  jr T,0xf56729
ScreenLeave_CycleRecordScreen_Skip:
	and	(0x34bb:16), 0xfb	; F56718  and (0x34bb),0xfb
	cp	(0x3628:16), 0x00	; F5671D  cp (0x3628),0x00
	jr	z, ScreenLeave_CycleRecordScreen_Return	; F56722  jr Z,0xf56729
	ld	(13864:16), 0	; F56724  ld (0x3628),0x00
ScreenLeave_CycleRecordScreen_Return:
	ret	; F56729  ret

; --------------------------------------------------------------------------
; Nop_Ret_F5672A
; Called from: table 0xF559AE[0], 0xF559AE[1], 0xF559AE[2], 0xF559AE[3],
;              0xF559AE[4], 0xF559AE[5] +2 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the table at 0xF559AE reads 0x00F5672A, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5672A
;           is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F5672A:
	ret	; F5672A  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_CycleRecordScreen
; Called from: table 0xF559AE[8]
; Touches: (0x2095) (0x34D9) (0x7F32)
; Calls:   T_Blink_Stop T_RecordScreen_LcdKeyRow1 T_Seq_LoadTimeSigAtCurrentMeasure
; Evidence: entry [8] of the table at 0xF559AE reads 0x00F5672B, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5672B
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_CycleRecordScreen: ScreenButtons_CycleRecordScreen[8] -- the LcdKeyRow1 handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow1_CycleRecordScreen:
	bit	7, w	; F5672B  bit 0x07,W
	jr	nz, LcdKeyRow1_CycleRecordScreen_Return2	; F5672E  jr NZ,0xf56751
	bit	0, (0x34d9:16)	; F56730  bit 0,(0x34d9)
	jr	nz, LcdKeyRow1_CycleRecordScreen_Skip2	; F56734  jr NZ,0xf5673e
	bit	2, (MidiCfg_ModeBits:16)	; F56736  bit 2,(0x7f32)
	jr	z, LcdKeyRow1_CycleRecordScreen_Skip2	; F5673A  jr Z,0xf5673e
	jr	LcdKeyRow1_CycleRecordScreen_Return2	; F5673C  jr T,0xf56751
LcdKeyRow1_CycleRecordScreen_Skip2:
	call	T_Blink_Stop	; F5673E  call 0xf42e24
	call	T_RecordScreen_LcdKeyRow1	; F56742  call 0xf40cfc
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56746  call 0xf42704
	or	(UI_ScreenFlags:16), 0x10	; F5674A  or (0x2095),0x10
	jr	LcdKeyRow1_CycleRecordScreen_Return2	; F5674F  jr T,0xf56751
LcdKeyRow1_CycleRecordScreen_Return2:
	ret	; F56751  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_CycleRecordScreen
; Called from: table 0xF559AE[9]
; Touches: (0x34D9)
; Calls:   CycleRecordScreen_IncField CycleRecordScreen_SelectCycleField
; Evidence: entry [9] of the table at 0xF559AE reads 0x00F56752, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56752
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_CycleRecordScreen: ScreenButtons_CycleRecordScreen[9] -- the LcdKeyRow2 handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_CycleRecordScreen:
	bit	7, w	; F56752  bit 0x07,W
	jr	nz, LcdKeyRow2_CycleRecordScreen_Skip3	; F56755  jr NZ,0xf56767
	bit	2, (TransportB_State:8)	; F56757  bit 2,(0x96)
	jr	nz, LcdKeyRow2_CycleRecordScreen_Return3	; F5675A  jr NZ,0xf5676a
	bit	2, (0x34d9:16)	; F5675C  bit 2,(0x34d9)
	jr	nz, LcdKeyRow2_CycleRecordScreen_Return3	; F56760  jr NZ,0xf5676a
	calr	CycleRecordScreen_IncField	; F56762  calr 0xf56925
	jr	LcdKeyRow2_CycleRecordScreen_Return3	; F56765  jr T,0xf5676a
LcdKeyRow2_CycleRecordScreen_Skip3:
	calr	CycleRecordScreen_SelectCycleField	; F56767  calr 0xf568ab
LcdKeyRow2_CycleRecordScreen_Return3:
	ret	; F5676A  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_CycleRecordScreen
; Called from: table 0xF559AE[10]
; Touches: (0x34D9) (0x36CE)
; Calls:   CycleRecordScreen_DecField T_F40BE0 CycleRecordScreen_SelectStartMeasureField
; Evidence: entry [10] of the table at 0xF559AE reads 0x00F5676B, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5676B is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_CycleRecordScreen: ScreenButtons_CycleRecordScreen[10] -- the LcdKeyRow3 handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_CycleRecordScreen:
	bit	7, w	; F5676B  bit 0x07,W
	jr	nz, LcdKeyRow3_CycleRecordScreen_Skip5	; F5676E  jr NZ,0xf5678d
	bit	2, (TransportB_State:8)	; F56770  bit 2,(0x96)
	jr	nz, LcdKeyRow3_CycleRecordScreen_Return4	; F56773  jr NZ,0xf56790
	bit	2, (0x34d9:16)	; F56775  bit 2,(0x34d9)
	jr	nz, LcdKeyRow3_CycleRecordScreen_Return4	; F56779  jr NZ,0xf56790
	calr	CycleRecordScreen_DecField	; F5677B  calr 0xf56a5f
	cp	(0x36ce:16), 0x00	; F5677E  cp (0x36ce),0x00
	jr	z, LcdKeyRow3_CycleRecordScreen_Skip4	; F56783  jr Z,0xf56787
	jr	LcdKeyRow3_CycleRecordScreen_Return4	; F56785  jr T,0xf56790
LcdKeyRow3_CycleRecordScreen_Skip4:
	call	T_F40BE0	; F56787  call 0xf40be0
	jr	LcdKeyRow3_CycleRecordScreen_Return4	; F5678B  jr T,0xf56790
LcdKeyRow3_CycleRecordScreen_Skip5:
	calr	CycleRecordScreen_SelectStartMeasureField	; F5678D  calr 0xf568e9
LcdKeyRow3_CycleRecordScreen_Return4:
	ret	; F56790  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_CycleRecordScreen
; Called from: table 0xF559AE[11]
; Touches: nothing with an absolute address
; Calls:   CycleRecordScreen_SelectEndMeasureField
; Evidence: entry [11] of the table at 0xF559AE reads 0x00F56791, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56791 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_CycleRecordScreen: ScreenButtons_CycleRecordScreen[11] -- the LcdKeyRow4 handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow4_CycleRecordScreen:
	bit	7, w	; F56791  bit 0x07,W
	jr	nz, LcdKeyRow4_CycleRecordScreen_Skip6	; F56794  jr NZ,0xf56797
	ret	; F56796  ret
LcdKeyRow4_CycleRecordScreen_Skip6:
	calr	CycleRecordScreen_SelectEndMeasureField	; F56797  calr 0xf56907
	ret	; F5679A  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_CycleRecordScreen
; Called from: table 0xF559AE[12]
; Touches: (0x2070) (0x2095) (0x34D9) (0x3628)
; Calls:   T_Blink_Stop T_F40BFC
; Evidence: entry [12] of the table at 0xF559AE reads 0x00F5679B, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5679B is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_CycleRecordScreen: ScreenButtons_CycleRecordScreen[12] -- the LcdKeyRow5 handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow5_CycleRecordScreen:
	bit	7, w	; F5679B  bit 0x07,W
	jr	nz, LcdKeyRow5_CycleRecordScreen_Skip7	; F5679E  jr NZ,0xf567af
	cp	(0x3628:16), 0x00	; F567A0  cp (0x3628),0x00
	jr	nz, LcdKeyRow5_CycleRecordScreen_Return5	; F567A5  jr NZ,0xf567c7
	ldw	(UI_Request:16), 32774	; F567A7  ld (0x2070),0x8006
	jr	LcdKeyRow5_CycleRecordScreen_Return5	; F567AD  jr T,0xf567c7
LcdKeyRow5_CycleRecordScreen_Skip7:
	call	T_Blink_Stop	; F567AF  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F567B3  or (0x2095),0x10
	bit	2, (TransportB_State:8)	; F567B8  bit 2,(0x96)
	jr	nz, LcdKeyRow5_CycleRecordScreen_Skip8	; F567BB  jr NZ,0xf567c3
	bit	2, (0x34d9:16)	; F567BD  bit 2,(0x34d9)
	jr	nz, LcdKeyRow5_CycleRecordScreen_Return5	; F567C1  jr NZ,0xf567c7
LcdKeyRow5_CycleRecordScreen_Skip8:
	call	T_F40BFC	; F567C3  call 0xf40bfc
LcdKeyRow5_CycleRecordScreen_Return5:
	ret	; F567C7  ret

; --------------------------------------------------------------------------
; Nop_Ret_F567C8
; Called from: table 0xF559AE[13], 0xF559AE[14]
; Touches: nothing with an absolute address
; Evidence: entry [13] of the table at 0xF559AE reads 0x00F567C8, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF567C8 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F567C8:
	ret	; F567C8  ret

; --------------------------------------------------------------------------
; ExitKey_CycleRecordScreen
; Called from: table 0xF559AE[15]
; Touches: (0x2070) (0x3628)
; Evidence: entry [15] of the table at 0xF559AE reads 0x00F567C9, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF567C9 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_CycleRecordScreen: ScreenButtons_CycleRecordScreen[15] -- the ExitKey handler of CycleRecordScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_CycleRecordScreen:
	bit	7, w	; F567C9  bit 0x07,W
	jr	nz, ExitKey_CycleRecordScreen_Return6	; F567CC  jr NZ,0xf567dd
	cp	(0x3628:16), 0x00	; F567CE  cp (0x3628),0x00
	jr	nz, ExitKey_CycleRecordScreen_Return6	; F567D3  jr NZ,0xf567dd
	ldw	(UI_Request:16), 32774	; F567D5  ld (0x2070),0x8006
	jr	ExitKey_CycleRecordScreen_Return6	; F567DB  jr T,0xf567dd
ExitKey_CycleRecordScreen_Return6:
	ret	; F567DD  ret

; --------------------------------------------------------------------------
; NumberPadKey_CycleRecordScreen
; Called from: table 0xF559AE[27]
; Touches: (0x2267) (0x2826) (0x34D9) (0x3622) (0x3624) (0x36CE)
; Calls:   T_AsciiDigits3_ToValue T_Blink_Stop CycleRecordScreen_OnStartMeasureChanged CycleRecordScreen_BlinkStartMeasure
;          CycleRecordScreen_ApplyEndMeasure CycleRecordScreen_BlinkEndMeasure
; Evidence: entry [27] of the table at 0xF559AE reads 0x00F567DE, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF567DE is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; NumberPadKey_CycleRecordScreen: ScreenButtons_CycleRecordScreen[27] -- the NumberPadKey handler of CycleRecordScreen; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
NumberPadKey_CycleRecordScreen:
	bit	2, (TransportB_State:8)	; F567DE  bit 2,(0x96)
	jr	nz, NumberPadKey_CycleRecordScreen_Return7	; F567E1  jr NZ,0xf5684f
	bit	2, (0x34d9:16)	; F567E3  bit 2,(0x34d9)
	jr	nz, NumberPadKey_CycleRecordScreen_Return7	; F567E7  jr NZ,0xf5684f
	cp	(0x36ce:16), 0x01	; F567E9  cp (0x36ce),0x01
	jr	z, NumberPadKey_CycleRecordScreen_Skip9	; F567EE  jr Z,0xf567f9
	cp	(0x36ce:16), 0x02	; F567F0  cp (0x36ce),0x02
	jr	z, NumberPadKey_CycleRecordScreen_Skip11	; F567F5  jr Z,0xf56825
	jr	NumberPadKey_CycleRecordScreen_Return7	; F567F7  jr T,0xf5684f
NumberPadKey_CycleRecordScreen_Skip9:
	cp	(0x2267:16), 0x0f	; F567F9  cp (0x2267),0x0f
	jr	z, NumberPadKey_CycleRecordScreen_Skip10	; F567FE  jr Z,0xf56802
	jr	NumberPadKey_CycleRecordScreen_Join	; F56800  jr T,0xf56820
NumberPadKey_CycleRecordScreen_Skip10:
	ld	(10278:16), 3	; F56802  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F56807  call 0xf432f0
	cp	wa, 1:i3	; F5680B  cp WA,1
	jr	c, NumberPadKey_CycleRecordScreen_Join	; F5680D  jr C,0xf56820
	cp	wa, 999	; F5680F  cp WA,0x03e7
	jr	ugt, NumberPadKey_CycleRecordScreen_Join	; F56813  jr UGT,0xf56820
	ld	(13858:16), wa	; F56815  ld (0x3622),WA
	call	T_Blink_Stop	; F56819  call 0xf42e24
	calr	CycleRecordScreen_OnStartMeasureChanged	; F5681D  calr 0xf569af
NumberPadKey_CycleRecordScreen_Join:
	calr	CycleRecordScreen_BlinkStartMeasure	; F56820  calr 0xf56850
	jr	NumberPadKey_CycleRecordScreen_Return7	; F56823  jr T,0xf5684f
NumberPadKey_CycleRecordScreen_Skip11:
	cp	(0x2267:16), 0x0f	; F56825  cp (0x2267),0x0f
	jr	z, NumberPadKey_CycleRecordScreen_Skip12	; F5682A  jr Z,0xf5682e
	jr	NumberPadKey_CycleRecordScreen_Join2	; F5682C  jr T,0xf5684c
NumberPadKey_CycleRecordScreen_Skip12:
	ld	(10278:16), 3	; F5682E  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F56833  call 0xf432f0
	cp	wa, 1:i3	; F56837  cp WA,1
	jr	c, NumberPadKey_CycleRecordScreen_Join2	; F56839  jr C,0xf5684c
	cp	wa, 999	; F5683B  cp WA,0x03e7
	jr	ugt, NumberPadKey_CycleRecordScreen_Join2	; F5683F  jr UGT,0xf5684c
	ld	(13860:16), wa	; F56841  ld (0x3624),WA
	call	T_Blink_Stop	; F56845  call 0xf42e24
	calr	CycleRecordScreen_ApplyEndMeasure	; F56849  calr 0xf56b14
NumberPadKey_CycleRecordScreen_Join2:
	calr	CycleRecordScreen_BlinkEndMeasure	; F5684C  calr 0xf5687d
NumberPadKey_CycleRecordScreen_Return7:
	ret	; F5684F  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkStartMeasure
; Called from: in-module: 0xF56820
; Touches: (0x2540) (0x2656) (0x3622)  |  0xF351CF
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal T_Blink_Command
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56850 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkStartMeasure: UI_DrawScratch+22 := the CYCLE RECORD start measure (0x3622), then posts
;   CycleRecordScreen_BlinkStartMeasureReadout, which hands Blink_Command the CycleRecordScreen_DrawValues_DL + 0x28 record (the 3-digit readout of UI_DrawScratch+22) on
;   layer 0. Last step of NumberPadKey_CycleRecordScreen on field 1; its twin CycleRecordScreen_BlinkEndMeasure does the same for the end
;   measure (0x3624). Basis: caller + body + display-list record + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
CycleRecordScreen_BlinkStartMeasure:
	ld	wa, (13858:16)	; F56850  ld WA,(0x3622)
	ld	(UI_DrawScratch+22:16), wa	; F56854  ld (0x2656),WA
	ld	xwa, CycleRecordScreen_BlinkStartMeasureReadout	; F56858  ld XWA,0x00f5686b
	push	xwa	; F5685D  push XWA
	call	T_CallbackQueue_Post	; F5685E  call 0xf42e84
	inc	4, xsp	; F56862  inc 4,XSP
	ld	a, 1:opc	; F56864  ld A,0x01
	call	T_Kernel_SemaSignal	; F56866  call 0xf42d88
	ret	; F5686A  ret
; CycleRecordScreen_BlinkStartMeasureReadout: The callback CycleRecordScreen_BlinkStartMeasure posts: on layer 0 hands
;   Blink_Command the start-measure readout record CycleRecordScreen_DrawValues_DL + 0x28 (it shows
;   UI_DrawScratch+22). Basis: caller + caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
CycleRecordScreen_BlinkStartMeasureReadout:
	ld	(LCD_CurrentLayer:16), 0	; F5686B  ld (0x2540),0x00
	ld	xiy, CycleRecordScreen_DrawValues_DL + 0x28	; F56870  ld XIY,0x00f351cf
	push	xiy	; F56875  push XIY
	call	T_Blink_Command	; F56876  call 0xf42e20
	inc	4, xsp	; F5687A  inc 4,XSP
	ret	; F5687C  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkEndMeasure
; Called from: in-module: 0xF5684C
; Touches: (0x2540) (0x2658) (0x3624)  |  0xF351D9
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal T_Blink_Command
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5687D is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkEndMeasure: Stages CYCLE RECORD's END measure (0x3624) into UI_DrawScratch+24 and posts
;   CycleRecordScreen_BlinkEndMeasureReadout, which hands that field's decimal-readout record (CycleRecordScreen_DrawValues_DL + 0x32, source UI_DrawScratch+24) to
;   Blink_Command: the end field blinks with its value. The tail of NumberPadKey_CycleRecordScreen's END-field arm
;   (field cursor (0x36CE) = 2); CycleRecordScreen_BlinkStartMeasure is the START twin. Basis: caller + body + display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
CycleRecordScreen_BlinkEndMeasure:
	ld	wa, (13860:16)	; F5687D  ld WA,(0x3624)
	ld	(UI_DrawScratch+24:16), wa	; F56881  ld (0x2658),WA
	ld	xwa, CycleRecordScreen_BlinkEndMeasureReadout	; F56885  ld XWA,0x00f56898
	push	xwa	; F5688A  push XWA
	call	T_CallbackQueue_Post	; F5688B  call 0xf42e84
	inc	4, xsp	; F5688F  inc 4,XSP
	ld	a, 1:opc	; F56891  ld A,0x01
	call	T_Kernel_SemaSignal	; F56893  call 0xf42d88
	ret	; F56897  ret
; CycleRecordScreen_BlinkEndMeasureReadout: The callback CycleRecordScreen_BlinkEndMeasure posts: on layer 0 hands
;   Blink_Command the end-measure readout record CycleRecordScreen_DrawValues_DL + 0x32 (it shows UI_DrawScratch+24).
;   Twin of CycleRecordScreen_BlinkStartMeasureReadout. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
CycleRecordScreen_BlinkEndMeasureReadout:
	ld	(LCD_CurrentLayer:16), 0	; F56898  ld (0x2540),0x00
	ld	xiy, CycleRecordScreen_DrawValues_DL + 0x32	; F5689D  ld XIY,0x00f351d9
	push	xiy	; F568A2  push XIY
	call	T_Blink_Command	; F568A3  call 0xf42e20
	inc	4, xsp	; F568A7  inc 4,XSP
	ret	; F568A9  ret

; --------------------------------------------------------------------------
; Nop_Ret_F568AA
; Called from: table 0xF559AE[16], 0xF559AE[17], 0xF559AE[18], 0xF559AE[19],
;              0xF559AE[20], 0xF559AE[21] +9 more; in-module: 0xF5584E
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF559AE reads 0x00F568AA, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF568AA is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F568AA:
	ret	; F568AA  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_SelectCycleField
; Called from: in-module: 0xF56767
; Touches: (0x12F6) (0x2095) (0x2540) (0x3628) (0x36CE) (0x3755)  |  0xF3501F
;          0xF3502A
; Calls:   T_Blink_Stop T_DLB_Handler_Array8_2 T_DLB_Handler_Array8
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF568AB is an instruction boundary.
; Shape:   saves the current (0x36CE) to (0x3755) and writes 0x00 into it,
;          then calls T_Blink_Stop and sets bit 4 of (0x2095) -- and does none
;          of that unless (0x3628) is zero.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CycleRecordScreen_SelectCycleField: CYCLE RECORD LCD row 2 LEFT key: unless (0x3628) is set, field cursor (0x36CE)
;   := 0 (CYCLE), old one to (0x3755), stops the blink and repaints. Basis: body + the page's row text + rectangle 0
;   of Data_F35035+6. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_SelectCycleField:
	cp	(0x3628:16), 0x00	; F568AB  cp (0x3628),0x00
	jr	nz, CycleRecordScreen_SelectCycleField_Return	; F568B0  jr NZ,0xf568c8
	ld	a, (14030:16)	; F568B2  ld A,(0x36ce)
	ld	(14165:16), a	; F568B6  ld (0x3755),A
	ld	(14030:16), 0	; F568BA  ld (0x36ce),0x00
	call	T_Blink_Stop	; F568BF  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F568C3  or (0x2095),0x10
CycleRecordScreen_SelectCycleField_Return:
	ret	; F568C8  ret
	ld	(LCD_CurrentLayer:16), 1	; F568C9  ld (0x2540),0x01
	ld	xiy, DL_F34FF2 + 0x38	; F568CE  ld XIY,0x00f3502a
	call	T_DLB_Handler_Array8_2	; F568D3  call 0xf41820
	ld	a, (14030:16)	; F568D7  ld A,(0x36ce)
	ld	(DisplayListB_Stage:16), a	; F568DB  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x2D	; F568DF  ld XIY,0x00f3501f
	call	T_DLB_Handler_Array8	; F568E4  call 0xf4181c
	ret	; F568E8  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_SelectStartMeasureField
; Called from: in-module: 0xF5678D
; Touches: (0x2095) (0x3628) (0x36CE) (0x3755)
; Calls:   T_Blink_Stop
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF568E9 is an instruction boundary.
; Shape:   saves the current (0x36CE) to (0x3755) and writes 0x01 into it,
;          then calls T_Blink_Stop and sets bit 4 of (0x2095) -- and does none
;          of that unless (0x3628) is zero.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CycleRecordScreen_SelectStartMeasureField: CYCLE RECORD LCD row 3 LEFT key: unless (0x3628) is set, field cursor
;   (0x36CE) := 1 (CYCLE START MEASURE), old one to (0x3755), stops the blink and repaints. Basis: body + the page's
;   row text + rectangle 1 of Data_F35035+6. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_SelectStartMeasureField:
	cp	(0x3628:16), 0x00	; F568E9  cp (0x3628),0x00
	jr	nz, CycleRecordScreen_SelectStartMeasureField_Return	; F568EE  jr NZ,0xf56906
	ld	a, (14030:16)	; F568F0  ld A,(0x36ce)
	ld	(14165:16), a	; F568F4  ld (0x3755),A
	ld	(14030:16), 1	; F568F8  ld (0x36ce),0x01
	call	T_Blink_Stop	; F568FD  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F56901  or (0x2095),0x10
CycleRecordScreen_SelectStartMeasureField_Return:
	ret	; F56906  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_SelectEndMeasureField
; Called from: in-module: 0xF56797
; Touches: (0x2095) (0x3628) (0x36CE) (0x3755)
; Calls:   T_Blink_Stop
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56907 is an instruction boundary.
; Shape:   saves the current (0x36CE) to (0x3755) and writes 0x02 into it,
;          then calls T_Blink_Stop and sets bit 4 of (0x2095) -- and does none
;          of that unless (0x3628) is zero.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CycleRecordScreen_SelectEndMeasureField: CYCLE RECORD LCD row 4 LEFT key: unless (0x3628) is set, field cursor
;   (0x36CE) := 2 (CYCLE END MEASURE), old one to (0x3755), stops the blink and repaints. Basis: body + the page's row
;   text + rectangle 2 of Data_F35035+6. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_SelectEndMeasureField:
	cp	(0x3628:16), 0x00	; F56907  cp (0x3628),0x00
	jr	nz, CycleRecordScreen_SelectEndMeasureField_Return	; F5690C  jr NZ,0xf56924
	ld	a, (14030:16)	; F5690E  ld A,(0x36ce)
	ld	(14165:16), a	; F56912  ld (0x3755),A
	ld	(14030:16), 2	; F56916  ld (0x36ce),0x02
	call	T_Blink_Stop	; F5691B  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F5691F  or (0x2095),0x10
CycleRecordScreen_SelectEndMeasureField_Return:
	ret	; F56924  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_IncField
; Called from: in-module: 0xF56762
; Touches: (0x2075) (0x36CE)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56925 is an instruction boundary.
; Shape:   `ld XIX,0x00F5693F / ld A,(0x36CE) / sll 0x02,XWA / add XIX,XWA /
;          ld XIX,(XIX) / call T,XIX` -- entry (0x36CE) of that 5-entry table,
;          with NO bound on the index.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CycleRecordScreen_IncField: CYCLE RECORD LCD row 2 RIGHT key (up arrow): sets UI_RequestBits bit 3 and calls
;   CycleRecordScreen_FieldIncHandlers[field cursor (0x36CE)]. Basis: the table it reads + caller. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_IncField:
	or	(UI_RequestBits:16), 0x08	; F56925  or (0x2075),0x08
	xor	xwa, xwa	; F5692A  xor XWA,XWA
	ld	xix, CycleRecordScreen_FieldIncHandlers	; F5692C  ld XIX,0x00f5693f
	ld	a, (14030:16)	; F56931  ld A,(0x36ce)
	sll	xwa, 2	; F56935  sll 0x02,XWA
	add	xix, xwa	; F56938  add XIX,XWA
	ld	xix, (xix)	; F5693A  ld XIX,(XIX)
	call	(xix)	; F5693C  call T,XIX
	ret	; F5693E  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_FieldIncHandlers -- five 32-bit routine pointers, entered with
;                              `call (XIX)`.
; Read by: 0xF5692C: `xor XWA,XWA / ld XIX,0x00F5693F / ld A,(0x36CE) / sll
;          0x02,XWA / add XIX,XWA / ld XIX,(XIX) / call T,XIX` -- entry
;          (0x36CE) of this table, UNBOUNDED: nothing here range-checks the
;          byte.  ⚠ THE STATE BYTE IS NOT THE SAME FOR ALL FOUR TABLES:
;          0xF5693F and 0xF56A79 are indexed by (0x36CE), 0xF5706A and
;          0xF571A6 by (0x3627).  This file assumed one byte for all four and
;          --selftest refused it.
; Evidence: the entry count rests on two facts, both re-read on every emit:
;           entry [0] is 0xF56953, which is the byte immediately AFTER the
;           table, so the table frames itself; and the word at [5] is
;           0xC9360BF1, which is not a 0x00F00000-0x00FFFFFF pointer, while
;           [0]..[4] all are.  Same first-non-pointer rule the 0xF7D000 block
;           used.
; Unknown: what the byte at (0x36CE) enumerates.  Nothing decoded here says
;          what its values mean, so the name is FRAMED and no entry is given a
;          name.  ⚠ AND NOTHING BOUNDS IT: a value above 4 would index past
;          the table.  That is what the bytes say; whether the callers
;          guarantee the range is not established here.
; --------------------------------------------------------------------------
; CycleRecordScreen_FieldIncHandlers: CYCLE RECORD (screen 0x08), LCD row 2 RIGHT key (up arrow): steps the field
;   under the cursor (0x36CE) up -- 0 CYCLE := ON, 1 START MEASURE + 1, 2 END MEASURE + 1; [3], [4] repeat [0] (no
;   writer stores 3 or 4). Basis: table index (field cursor; its writers and the page's rows) + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_FieldIncHandlers:
	.long	CycleRecordScreen_SwitchCycleOn	; F5693F  [0] -> CycleRecordScreen_SwitchCycleOn
	.long	CycleRecordScreen_IncStartMeasure	; F56943  [1] -> CycleRecordScreen_IncStartMeasure
	.long	CycleRecordScreen_IncEndMeasure	; F56947  [2] -> CycleRecordScreen_IncEndMeasure
	.long	CycleRecordScreen_SwitchCycleOn	; F5694B  [3] -> CycleRecordScreen_SwitchCycleOn
	.long	CycleRecordScreen_SwitchCycleOn	; F5694F  [4] -> CycleRecordScreen_SwitchCycleOn


; --------------------------------------------------------------------------
; CycleRecordScreen_SwitchCycleOn
; Called from: table 0xF5693F[0], 0xF5693F[3], 0xF5693F[4]
; Touches: (0x360B)
; Calls:   sub_F5696D T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB
; Evidence: entry [0] of the table at 0xF5693F reads 0x00F56953, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56953
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_SwitchCycleOn: CycleRecordScreen_FieldIncHandlers[0] (field CYCLE): unless already on, sets the
;   CYCLE RECORD switch (0x360B) bit 1, repaints its OFF/ON, then SeqCycle_CaptureEndCursors / SeqCycle_LocateToStart
;   / Seq_SetTrackBeatsFromTransportB. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_SwitchCycleOn:
	bit	1, (0x360b:16)	; F56953  bit 1,(0x360b)
	jr	nz, CycleRecordScreen_SwitchCycleOn_Return	; F56957  jr NZ,0xf5696c
	set	1, (0x360b:16)	; F56959  set 1,(0x360b)
	calr	sub_F5696D	; F5695D  calr 0xf5696d
	call	T_SeqCycle_CaptureEndCursors	; F56960  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56964  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56968  call 0xf40ac4
CycleRecordScreen_SwitchCycleOn_Return:
	ret	; F5696C  ret

; --------------------------------------------------------------------------
; sub_F5696D
; Called from: in-module: 0xF5695D 0xF56AAD
; Touches: (0x2647) (0x360B)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5696D is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F5696D:
	ld	a, (13835:16)	; F5696D  ld A,(0x360b)
	and	a, 2	; F56971  and A,0x02
	srl	a, 1	; F56974  srl 0x01,A
	ld	(UI_DrawScratch+7:16), a	; F56977  ld (0x2647),A
	ld	xwa, sub_F55F9F	; F5697B  ld XWA,0x00f55f9f
	push	xwa	; F56980  push XWA
	call	T_CallbackQueue_Post	; F56981  call 0xf42e84
	inc	4, xsp	; F56985  inc 4,XSP
	ld	a, 1:opc	; F56987  ld A,0x01
	call	T_Kernel_SemaSignal	; F56989  call 0xf42d88
	ret	; F5698D  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_IncStartMeasure
; Called from: table 0xF5693F[1]
; Touches: (0x3622)
; Calls:   T_Blink_Stop CycleRecordScreen_BlinkStartAndEndMeasures CycleRecordScreen_OnStartMeasureChanged
; Evidence: entry [1] of the table at 0xF5693F reads 0x00F5698E, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5698E
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_IncStartMeasure: CycleRecordScreen_FieldIncHandlers[1] (field START MEASURE): while stopped,
;   (0x3622) + 1 up to 999, then blinks both readouts and CycleRecordScreen_OnStartMeasureChanged. Basis: table index
;   + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_IncStartMeasure:
	bit	2, (TransportB_State:8)	; F5698E  bit 2,(0x96)
	jr	nz, sub_F5696D_Return	; F56991  jr NZ,0xf569ae
	call	T_Blink_Stop	; F56993  call 0xf42e24
	cpw	(0x3622:16), 0x03e7	; F56997  cp (0x3622),0x03e7
	jr	c, sub_F5696D_Skip	; F5699D  jr C,0xf569a4
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F5699F  calr 0xf569fa
	jr	sub_F5696D_Return	; F569A2  jr T,0xf569ae
sub_F5696D_Skip:
	incw	1, (13858:16)	; F569A4  incw 1,(0x3622)
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F569A8  calr 0xf569fa
	calr	CycleRecordScreen_OnStartMeasureChanged	; F569AB  calr 0xf569af
sub_F5696D_Return:
	ret	; F569AE  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_OnStartMeasureChanged
; Called from: in-module: 0xF5681D 0xF569AB
; Touches: (0x34BB) (0x3622) (0x3624) (0x3628) (0x3629)
; Calls:   CycleRecordScreen_BlinkStartAndEndMeasures
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF569AF is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_OnStartMeasureChanged: After the CYCLE RECORD start measure (0x3622) changed: if it now exceeds
;   END (0x3624), END := START, the two fields re-blinked (CycleRecordScreen_BlinkStartAndEndMeasures) and Dispatch_3629 action 2 scheduled ((0x3628)
;   := 0x83, (0x3629) := 2); otherwise action 0 is scheduled, or only the countdown re-armed when action 2 is already
;   pending. Sets (0x34BB) bit 2 either way. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
CycleRecordScreen_OnStartMeasureChanged:
	ld	wa, (13858:16)	; F569AF  ld WA,(0x3622)
	cp	wa, (0x3624:16)	; F569B3  cp WA,(0x3624)
	jr	ule, CycleRecordScreen_OnStartMeasureChanged_Skip	; F569B7  jr ULE,0xf569d5
	ld	wa, (13858:16)	; F569B9  ld WA,(0x3622)
	ld	(13860:16), wa	; F569BD  ld (0x3624),WA
	or	(0x34bb:16), 0x04	; F569C1  or (0x34bb),0x04
	ld	(13864:16), 131	; F569C6  ld (0x3628),0x83
	ld	(13865:16), 2	; F569CB  ld (0x3629),0x02
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F569D0  calr 0xf569fa
	jr	CycleRecordScreen_OnStartMeasureChanged_Return	; F569D3  jr T,0xf569f9
CycleRecordScreen_OnStartMeasureChanged_Skip:
	or	(0x34bb:16), 0x04	; F569D5  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F569DA  cp (0x3628),0x00
	jr	z, CycleRecordScreen_OnStartMeasureChanged_Skip2	; F569DF  jr Z,0xf569ef
	cp	(0x3629:16), 0x02	; F569E1  cp (0x3629),0x02
	jr	nz, CycleRecordScreen_OnStartMeasureChanged_Skip2	; F569E6  jr NZ,0xf569ef
	ld	(13864:16), 131	; F569E8  ld (0x3628),0x83
	jr	CycleRecordScreen_OnStartMeasureChanged_Return	; F569ED  jr T,0xf569f9
CycleRecordScreen_OnStartMeasureChanged_Skip2:
	ld	(13864:16), 131	; F569EF  ld (0x3628),0x83
	ld	(13865:16), 0	; F569F4  ld (0x3629),0x00
CycleRecordScreen_OnStartMeasureChanged_Return:
	ret	; F569F9  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkStartAndEndMeasures
; Called from: in-module: 0xF5699F 0xF569A8 0xF569D0 0xF56A2E 0xF56A37
;              0xF56AC2 0xF56ACB 0xF56B04 +2 more
; Touches: (0x2656) (0x2658) (0x3622) (0x3624)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF569FA is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_BlinkStartAndEndMeasures: Stages the CYCLE RECORD start and end measures (0x3622)/(0x3624) into
;   UI_DrawScratch+22/+24 and posts CycleRecordScreen_BlinkStartAndEndMeasureReadouts, which hands both readout records (CycleRecordScreen_DrawValues_DL +
;   0x28 and + 0x32) to Blink_Command; then Kernel_SemaSignal. The two-field form of
;   CycleRecordScreen_BlinkStartMeasure / _BlinkEndMeasure, run when one bound moved the other
;   (CycleRecordScreen_OnStartMeasureChanged, CycleRecordScreen_ApplyEndMeasure, the step keys). Basis: callers + body
;   + twins. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
CycleRecordScreen_BlinkStartAndEndMeasures:
	ld	wa, (13858:16)	; F569FA  ld WA,(0x3622)
	ld	(UI_DrawScratch+22:16), wa	; F569FE  ld (0x2656),WA
	ld	wa, (13860:16)	; F56A02  ld WA,(0x3624)
	ld	(UI_DrawScratch+24:16), wa	; F56A06  ld (0x2658),WA
	ld	xwa, CycleRecordScreen_BlinkStartAndEndMeasureReadouts	; F56A0A  ld XWA,0x00f55fb3
	push	xwa	; F56A0F  push XWA
	call	T_CallbackQueue_Post	; F56A10  call 0xf42e84
	inc	4, xsp	; F56A14  inc 4,XSP
	ld	a, 1:opc	; F56A16  ld A,0x01
	call	T_Kernel_SemaSignal	; F56A18  call 0xf42d88
	ret	; F56A1C  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_IncEndMeasure
; Called from: table 0xF5693F[2]
; Touches: (0x34BB) (0x3624) (0x3628) (0x3629)
; Calls:   T_Blink_Stop CycleRecordScreen_BlinkStartAndEndMeasures
; Evidence: entry [2] of the table at 0xF5693F reads 0x00F56A1D, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56A1D
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_IncEndMeasure: CycleRecordScreen_FieldIncHandlers[2] (field END MEASURE): while stopped, (0x3624)
;   + 1 up to 999, blinks both readouts and sets (0x3628) := 0x83 / (0x3629) as CyclePlayScreen_QueueEndMeasureChange
;   does. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_IncEndMeasure:
	bit	2, (TransportB_State:8)	; F56A1D  bit 2,(0x96)
	jr	nz, CycleRecordScreen_IncEndMeasure_Return	; F56A20  jr NZ,0xf56a5e
	call	T_Blink_Stop	; F56A22  call 0xf42e24
	cpw	(0x3624:16), 0x03e7	; F56A26  cp (0x3624),0x03e7
	jr	c, CycleRecordScreen_IncEndMeasure_Skip	; F56A2C  jr C,0xf56a33
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56A2E  calr 0xf569fa
	jr	CycleRecordScreen_IncEndMeasure_Return	; F56A31  jr T,0xf56a5e
CycleRecordScreen_IncEndMeasure_Skip:
	incw	1, (13860:16)	; F56A33  incw 1,(0x3624)
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56A37  calr 0xf569fa
	or	(0x34bb:16), 0x04	; F56A3A  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F56A3F  cp (0x3628),0x00
	jr	z, CycleRecordScreen_IncEndMeasure_Skip2	; F56A44  jr Z,0xf56a54
	cp	(0x3629:16), 0x02	; F56A46  cp (0x3629),0x02
	jr	nz, CycleRecordScreen_IncEndMeasure_Skip2	; F56A4B  jr NZ,0xf56a54
	ld	(13864:16), 131	; F56A4D  ld (0x3628),0x83
	jr	CycleRecordScreen_IncEndMeasure_Return	; F56A52  jr T,0xf56a5e
CycleRecordScreen_IncEndMeasure_Skip2:
	ld	(13864:16), 131	; F56A54  ld (0x3628),0x83
	ld	(13865:16), 1	; F56A59  ld (0x3629),0x01
CycleRecordScreen_IncEndMeasure_Return:
	ret	; F56A5E  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_DecField
; Called from: in-module: 0xF5677B
; Touches: (0x2075) (0x36CE)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56A5F is an instruction boundary.
; Shape:   `ld XIX,0x00F56A79 / ld A,(0x36CE) / sll 0x02,XWA / add XIX,XWA /
;          ld XIX,(XIX) / call T,XIX` -- entry (0x36CE) of that 5-entry table,
;          with NO bound on the index.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CycleRecordScreen_DecField: CYCLE RECORD LCD row 3 RIGHT key (down arrow): sets UI_RequestBits bit 3 and calls
;   CycleRecordScreen_FieldDecHandlers[field cursor (0x36CE)]. Basis: the table it reads + caller. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_DecField:
	or	(UI_RequestBits:16), 0x08	; F56A5F  or (0x2075),0x08
	xor	xwa, xwa	; F56A64  xor XWA,XWA
	ld	xix, CycleRecordScreen_FieldDecHandlers	; F56A66  ld XIX,0x00f56a79
	ld	a, (14030:16)	; F56A6B  ld A,(0x36ce)
	sll	xwa, 2	; F56A6F  sll 0x02,XWA
	add	xix, xwa	; F56A72  add XIX,XWA
	ld	xix, (xix)	; F56A74  ld XIX,(XIX)
	call	(xix)	; F56A76  call T,XIX
	ret	; F56A78  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_FieldDecHandlers -- five 32-bit routine pointers, entered with
;                              `call (XIX)`.
; Read by: 0xF56A66: `xor XWA,XWA / ld XIX,0x00F56A79 / ld A,(0x36CE) / sll
;          0x02,XWA / add XIX,XWA / ld XIX,(XIX) / call T,XIX` -- entry
;          (0x36CE) of this table, UNBOUNDED: nothing here range-checks the
;          byte.  ⚠ THE STATE BYTE IS NOT THE SAME FOR ALL FOUR TABLES:
;          0xF5693F and 0xF56A79 are indexed by (0x36CE), 0xF5706A and
;          0xF571A6 by (0x3627).  This file assumed one byte for all four and
;          --selftest refused it.
; Evidence: the entry count rests on two facts, both re-read on every emit:
;           entry [0] is 0xF56A8D, which is the byte immediately AFTER the
;           table, so the table frames itself; and the word at [5] is
;           0xC9360BF1, which is not a 0x00F00000-0x00FFFFFF pointer, while
;           [0]..[4] all are.  Same first-non-pointer rule the 0xF7D000 block
;           used.
; Unknown: what the byte at (0x36CE) enumerates.  Nothing decoded here says
;          what its values mean, so the name is FRAMED and no entry is given a
;          name.  ⚠ AND NOTHING BOUNDS IT: a value above 4 would index past
;          the table.  That is what the bytes say; whether the callers
;          guarantee the range is not established here.
; --------------------------------------------------------------------------
; CycleRecordScreen_FieldDecHandlers: CYCLE RECORD (screen 0x08), LCD row 3 RIGHT key (down arrow): steps the field
;   under the cursor (0x36CE) down -- 0 CYCLE := OFF, 1 START MEASURE - 1, 2 END MEASURE - 1; [3], [4] repeat [0].
;   Basis: table index (field cursor) + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_FieldDecHandlers:
	.long	CycleRecordScreen_SwitchCycleOff	; F56A79  [0] -> CycleRecordScreen_SwitchCycleOff
	.long	CycleRecordScreen_DecStartMeasure	; F56A7D  [1] -> CycleRecordScreen_DecStartMeasure
	.long	CycleRecordScreen_DecEndMeasure	; F56A81  [2] -> CycleRecordScreen_DecEndMeasure
	.long	CycleRecordScreen_SwitchCycleOff	; F56A85  [3] -> CycleRecordScreen_SwitchCycleOff
	.long	CycleRecordScreen_SwitchCycleOff	; F56A89  [4] -> CycleRecordScreen_SwitchCycleOff


; --------------------------------------------------------------------------
; CycleRecordScreen_SwitchCycleOff
; Called from: table 0xF56A79[0], 0xF56A79[3], 0xF56A79[4]
; Touches: (0x360B) (0x36C6) (0x36CA)
; Calls:   T_SeqRecord_RestoreCursorBaseline T_CycleRecord_FreeRecordChain T_SeqRecord_FreeTakeChain2 sub_F5696D
; Evidence: entry [0] of the table at 0xF56A79 reads 0x00F56A8D, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56A8D
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_SwitchCycleOff: CycleRecordScreen_FieldDecHandlers[0] (field CYCLE): if on, clears the CYCLE
;   RECORD switch (0x360B) bit 1, zeroes (0x36CA)/(0x36C6), SeqRecord_RestoreCursorBaseline, frees the record and take
;   chains, repaints OFF/ON. Basis: table index + body; the same steps LcdKeyRow2_RealtimeRecordScreen takes to switch
;   CYCLE RECORD off. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_SwitchCycleOff:
	bit	1, (0x360b:16)	; F56A8D  bit 1,(0x360b)
	jr	z, CycleRecordScreen_SwitchCycleOff_Return	; F56A91  jr Z,0xf56ab0
	res	1, (0x360b:16)	; F56A93  res 1,(0x360b)
	xor	xwa, xwa	; F56A97  xor XWA,XWA
	ld	(14026:16), xwa	; F56A99  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F56A9D  ld (0x36c6),XWA
	call	T_SeqRecord_RestoreCursorBaseline	; F56AA1  call 0xf40c04
	call	T_CycleRecord_FreeRecordChain	; F56AA5  call 0xf40bf4
	call	T_SeqRecord_FreeTakeChain2	; F56AA9  call 0xf40bf8
	calr	sub_F5696D	; F56AAD  calr 0xf5696d
CycleRecordScreen_SwitchCycleOff_Return:
	ret	; F56AB0  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_DecStartMeasure
; Called from: table 0xF56A79[1]
; Touches: (0x34BB) (0x3622) (0x3628) (0x3629)
; Calls:   T_Blink_Stop CycleRecordScreen_BlinkStartAndEndMeasures
; Evidence: entry [1] of the table at 0xF56A79 reads 0x00F56AB1, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56AB1
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_DecStartMeasure: CycleRecordScreen_FieldDecHandlers[1] (field START MEASURE): while stopped,
;   (0x3622) - 1 down to 1, blinks both readouts and sets (0x3628) := 0x83 / (0x3629). Basis: table index + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_DecStartMeasure:
	bit	2, (TransportB_State:8)	; F56AB1  bit 2,(0x96)
	jr	nz, CycleRecordScreen_DecStartMeasure_Return	; F56AB4  jr NZ,0xf56af2
	call	T_Blink_Stop	; F56AB6  call 0xf42e24
	cpw	(0x3622:16), 0x0001	; F56ABA  cp (0x3622),0x0001
	jr	ugt, CycleRecordScreen_DecStartMeasure_Skip	; F56AC0  jr UGT,0xf56ac7
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56AC2  calr 0xf569fa
	jr	CycleRecordScreen_DecStartMeasure_Return	; F56AC5  jr T,0xf56af2
CycleRecordScreen_DecStartMeasure_Skip:
	decw	1, (13858:16)	; F56AC7  decw 1,(0x3622)
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56ACB  calr 0xf569fa
	or	(0x34bb:16), 0x04	; F56ACE  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F56AD3  cp (0x3628),0x00
	jr	z, CycleRecordScreen_DecStartMeasure_Skip2	; F56AD8  jr Z,0xf56ae8
	cp	(0x3629:16), 0x02	; F56ADA  cp (0x3629),0x02
	jr	nz, CycleRecordScreen_DecStartMeasure_Skip2	; F56ADF  jr NZ,0xf56ae8
	ld	(13864:16), 131	; F56AE1  ld (0x3628),0x83
	jr	CycleRecordScreen_DecStartMeasure_Return	; F56AE6  jr T,0xf56af2
CycleRecordScreen_DecStartMeasure_Skip2:
	ld	(13864:16), 131	; F56AE8  ld (0x3628),0x83
	ld	(13865:16), 0	; F56AED  ld (0x3629),0x00
CycleRecordScreen_DecStartMeasure_Return:
	ret	; F56AF2  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_DecEndMeasure
; Called from: table 0xF56A79[2]
; Touches: (0x3624)
; Calls:   T_Blink_Stop CycleRecordScreen_BlinkStartAndEndMeasures CycleRecordScreen_ApplyEndMeasure
; Evidence: entry [2] of the table at 0xF56A79 reads 0x00F56AF3, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56AF3
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_DecEndMeasure: CycleRecordScreen_FieldDecHandlers[2] (field END MEASURE): while stopped, (0x3624)
;   - 1 down to 1, blinks both readouts and CycleRecordScreen_ApplyEndMeasure. Basis: table index + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CycleRecordScreen_DecEndMeasure:
	bit	2, (TransportB_State:8)	; F56AF3  bit 2,(0x96)
	jr	nz, CycleRecordScreen_DecEndMeasure_Return	; F56AF6  jr NZ,0xf56b13
	call	T_Blink_Stop	; F56AF8  call 0xf42e24
	cpw	(0x3624:16), 0x0001	; F56AFC  cp (0x3624),0x0001
	jr	ugt, CycleRecordScreen_DecEndMeasure_Skip	; F56B02  jr UGT,0xf56b09
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56B04  calr 0xf569fa
	jr	CycleRecordScreen_DecEndMeasure_Return	; F56B07  jr T,0xf56b13
CycleRecordScreen_DecEndMeasure_Skip:
	decw	1, (13860:16)	; F56B09  decw 1,(0x3624)
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56B0D  calr 0xf569fa
	calr	CycleRecordScreen_ApplyEndMeasure	; F56B10  calr 0xf56b14
CycleRecordScreen_DecEndMeasure_Return:
	ret	; F56B13  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_ApplyEndMeasure
; Called from: in-module: 0xF56849 0xF56B10
; Touches: (0x34BB) (0x3622) (0x3624) (0x3628) (0x3629)
; Calls:   CycleRecordScreen_BlinkStartAndEndMeasures
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56B14 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecordScreen_ApplyEndMeasure: After the CYCLE RECORD end measure (0x3624) changes: if the start (0x3622) is
;   past it, start := end, (0x34BB) bit 2, the deferred action 2 (relocate start and end) armed and the fields
;   repainted (CycleRecordScreen_BlinkStartAndEndMeasures); otherwise (0x34BB) bit 2 and action 1 (capture the end cursors) armed 3 ticks ahead,
;   unless an action 2 is already pending. Callers: NumberPadKey_CycleRecordScreen (end typed) and the decrement key
;   CycleRecordScreen_DecEndMeasure. Basis: callers + body + Dispatch_3629. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
CycleRecordScreen_ApplyEndMeasure:
	ld	wa, (13858:16)	; F56B14  ld WA,(0x3622)
	cp	wa, (0x3624:16)	; F56B18  cp WA,(0x3624)
	jr	ule, CycleRecordScreen_ApplyEndMeasure_Skip	; F56B1C  jr ULE,0xf56b3a
	ld	wa, (13860:16)	; F56B1E  ld WA,(0x3624)
	ld	(13858:16), wa	; F56B22  ld (0x3622),WA
	or	(0x34bb:16), 0x04	; F56B26  or (0x34bb),0x04
	ld	(13864:16), 131	; F56B2B  ld (0x3628),0x83
	ld	(13865:16), 2	; F56B30  ld (0x3629),0x02
	calr	CycleRecordScreen_BlinkStartAndEndMeasures	; F56B35  calr 0xf569fa
	jr	CycleRecordScreen_ApplyEndMeasure_Return	; F56B38  jr T,0xf56b5e
CycleRecordScreen_ApplyEndMeasure_Skip:
	or	(0x34bb:16), 0x04	; F56B3A  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F56B3F  cp (0x3628),0x00
	jr	z, CycleRecordScreen_ApplyEndMeasure_Skip2	; F56B44  jr Z,0xf56b54
	cp	(0x3629:16), 0x02	; F56B46  cp (0x3629),0x02
	jr	nz, CycleRecordScreen_ApplyEndMeasure_Skip2	; F56B4B  jr NZ,0xf56b54
	ld	(13864:16), 131	; F56B4D  ld (0x3628),0x83
	jr	CycleRecordScreen_ApplyEndMeasure_Return	; F56B52  jr T,0xf56b5e
CycleRecordScreen_ApplyEndMeasure_Skip2:
	ld	(13864:16), 131	; F56B54  ld (0x3628),0x83
	ld	(13865:16), 1	; F56B59  ld (0x3629),0x01
CycleRecordScreen_ApplyEndMeasure_Return:
	ret	; F56B5E  ret

; --------------------------------------------------------------------------
; ModeEnter_SeqPlay
; Called from: in-module: 0xF55808
; Touches: nothing with an absolute address
; Calls:   Seq_RestorePlayingTrackMask T_SoundGroup_ReloadSelection
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56B5F is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModeEnter_SeqPlay: the +0 ENTER of panel mode 8 -- PanelScreen_VtableTable[8] is T_ModeEnter_SeqPlay_Fwd, and
;   PanelMode_ToScreenIdMap[8] = 0x12, SeqPlayScreen.
ModeEnter_SeqPlay:
	calr	Seq_RestorePlayingTrackMask	; F56B5F  calr 0xf57433
	call	T_SoundGroup_ReloadSelection	; F56B62  call 0xf415c8
	ret	; F56B66  ret

; --------------------------------------------------------------------------
; ModeLeave_SeqPlay
; Called from: in-module: 0xF5580C
; Touches: (0x2250) (0x36C6) (0x36CA) (0x3757) (0x3758)
; Calls:   Seq_SavePlayingTrackMask T_Queue2E00_AppendRegs T_NoteRouting_Rebuild
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56B67 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModeLeave_SeqPlay: the +4 LEAVE of panel mode 8 (thunk T_ModeLeave_SeqPlay_Fwd).
ModeLeave_SeqPlay:
	xor	xwa, xwa	; F56B67  xor XWA,XWA
	ld	(14026:16), xwa	; F56B69  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F56B6D  ld (0x36c6),XWA
	calr	Seq_SavePlayingTrackMask	; F56B71  calr 0xf57443
	bit	0, (0x3758:16)	; F56B74  bit 0,(0x3758)
	jr	z, ModeLeave_SeqPlay_Return	; F56B78  jr Z,0xf56b94
	ld	a, (14167:16)	; F56B7A  ld A,(0x3757)
	ld	(UI_PartIndex:16), a	; F56B7E  ld (0x2250),A
	and	(0x3758:16), 0xfe	; F56B82  and (0x3758),0xfe
	ld	w, 255:opc	; F56B87  ld W,0xff
	ldw	de, 4240	; F56B89  ld DE,0x1090
	call	T_Queue2E00_AppendRegs	; F56B8C  call 0xf40f3c
	call	T_NoteRouting_Rebuild	; F56B90  call 0xf411bc
ModeLeave_SeqPlay_Return:
	ret	; F56B94  ret

; --------------------------------------------------------------------------
; ScreenEnter_SeqPlayScreen
; Called from: in-module: 0xF55856
; Touches: (0x207A) (0x207B) (0x207C) (0x207D) (0x2095) (0x2250) (0x2666)
;          (0x266A) (0x360B) (0x3757) +1 more
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_SeqPlayScreen_EnsureMeasureNonZero T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart
;          T_Seq_SetTrackBeatsFromTransportB T_SongMemory_UpdateFreePercent T_Queue2E00_AppendRegs T_NoteRouting_Rebuild
;          T_CallbackQueue_Post T_Kernel_SemaSignal T_Seq_LoadTimeSigAtCurrentMeasure
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56B95 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_SeqPlayScreen: the +0 ENTER method of screen 0x12 (thunk T_ScreenEnter_SeqPlayScreen_Fwd).  Its painter names the screen.
ScreenEnter_SeqPlayScreen:
	ld	a, (UI_ScreenLatch:16)	; F56B95  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F56B99  cp A,(0x207b)
	jr	nz, ScreenEnter_SeqPlayScreen_Skip	; F56B9D  jr NZ,0xf56baf
	ld	a, (UI_ScreenId:16)	; F56B9F  ld A,(0x207c)
	cp	a, (UI_ScreenId_Previous:16)	; F56BA3  cp A,(0x207d)
	jr	nz, ScreenEnter_SeqPlayScreen_Skip3	; F56BA7  jr NZ,0xf56bec
	bit	4, (UI_ScreenFlags:16)	; F56BA9  bit 4,(0x2095)
	jr	nz, ScreenEnter_SeqPlayScreen_Skip5	; F56BAD  jr NZ,0xf56c1e
ScreenEnter_SeqPlayScreen_Skip:
	cp	(UI_ScreenLatch_Previous:16), 0x14	; F56BAF  cp (0x207b),0x14
	jr	z, ScreenEnter_SeqPlayScreen_Skip3	; F56BB4  jr Z,0xf56bec
	call	T_CallbackQueue_ResetAndRestartTask2	; F56BB6  call 0xf42e80
	call	T_SeqPlayScreen_EnsureMeasureNonZero	; F56BBA  call 0xf40d04
	bit	0, (0x360b:16)	; F56BBE  bit 0,(0x360b)
	jr	z, ScreenEnter_SeqPlayScreen_Join	; F56BC2  jr Z,0xf56bdc
	bit	2, (TransportB_State:8)	; F56BC4  bit 2,(0x96)
	jr	z, ScreenEnter_SeqPlayScreen_Skip2	; F56BC7  jr Z,0xf56bd0
	and	(0x360b:16), 0xfe	; F56BC9  and (0x360b),0xfe
	jr	ScreenEnter_SeqPlayScreen_Join	; F56BCE  jr T,0xf56bdc
ScreenEnter_SeqPlayScreen_Skip2:
	call	T_SeqCycle_CaptureEndCursors	; F56BD0  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56BD4  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56BD8  call 0xf40ac4
ScreenEnter_SeqPlayScreen_Join:
	call	T_SongMemory_UpdateFreePercent	; F56BDC  call 0xf40d00
	ldw	(9830:16), 65535	; F56BE0  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F56BE6  ld (0x266a),0xffff
ScreenEnter_SeqPlayScreen_Skip3:
	bit	0, (0x3758:16)	; F56BEC  bit 0,(0x3758)
	jr	z, ScreenEnter_SeqPlayScreen_Skip4	; F56BF0  jr Z,0xf56c0c
	ld	a, (14167:16)	; F56BF2  ld A,(0x3757)
	ld	(UI_PartIndex:16), a	; F56BF6  ld (0x2250),A
	and	(0x3758:16), 0xfe	; F56BFA  and (0x3758),0xfe
	ld	w, 255:opc	; F56BFF  ld W,0xff
	ldw	de, 4240	; F56C01  ld DE,0x1090
	call	T_Queue2E00_AppendRegs	; F56C04  call 0xf40f3c
	call	T_NoteRouting_Rebuild	; F56C08  call 0xf411bc
ScreenEnter_SeqPlayScreen_Skip4:
	ld	xwa, Draw_SequencerPlayS0ngCycleMeasure	; F56C0C  ld XWA,0x00f55c61
	push	xwa	; F56C11  push XWA
	call	T_CallbackQueue_Post	; F56C12  call 0xf42e84
	inc	4, xsp	; F56C16  inc 4,XSP
	ld	a, 1:opc	; F56C18  ld A,0x01
	call	T_Kernel_SemaSignal	; F56C1A  call 0xf42d88
ScreenEnter_SeqPlayScreen_Skip5:
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56C1E  call 0xf42704
	ld	xwa, Draw_CycleMasterS0ngMeasureTimeSig	; F56C22  ld XWA,0x00f55c8c
	push	xwa	; F56C27  push XWA
	call	T_CallbackQueue_Post	; F56C28  call 0xf42e84
	inc	4, xsp	; F56C2C  inc 4,XSP
	ld	a, 1:opc	; F56C2E  ld A,0x01
	call	T_Kernel_SemaSignal	; F56C30  call 0xf42d88
	ret	; F56C34  ret

; --------------------------------------------------------------------------
; ScreenLeave_SeqPlayScreen
; Called from: in-module: 0xF5585A
; Touches: (0x2078) (0x207A) (0x207B) (0x20A9)
; Calls:   T_F40D18
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56C35 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenLeave_SeqPlayScreen: the +4 LEAVE method of screen 0x12 (thunk T_ScreenLeave_SeqPlayScreen_Fwd).
ScreenLeave_SeqPlayScreen:
	ld	a, (UI_ScreenLatch:16)	; F56C35  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F56C39  cp A,(0x207b)
	jr	nz, ScreenLeave_SeqPlayScreen_Skip	; F56C3D  jr NZ,0xf56c41
	jr	ScreenLeave_SeqPlayScreen_Return	; F56C3F  jr T,0xf56c56
ScreenLeave_SeqPlayScreen_Skip:
	cp	(PanelMode:16), 0x01	; F56C41  cp (0x2078),0x01
	jr	z, ScreenLeave_SeqPlayScreen_Skip2	; F56C46  jr Z,0xf56c4d
	and	(0x20a9:16), 0xfe	; F56C48  and (0x20a9),0xfe
ScreenLeave_SeqPlayScreen_Skip2:
	bit	2, (TransportB_State:8)	; F56C4D  bit 2,(0x96)
	jr	nz, ScreenLeave_SeqPlayScreen_Return	; F56C50  jr NZ,0xf56c56
	call	T_F40D18	; F56C52  call 0xf40d18
ScreenLeave_SeqPlayScreen_Return:
	ret	; F56C56  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SeqPlayScreen
; Called from: table 0xF55A2E[8]
; Touches: (0x2070) (0x2075) (0x209B) (0x2647) (0x360B) (0x3627) (0x36C6)
;          (0x36CA) (0x3731)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal T_SeqPlayScreen_LcdKeyRow1 T_Seq_LoadTimeSigAtCurrentMeasure
; Evidence: entry [8] of the table at 0xF55A2E reads 0x00F56C57, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56C57
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SeqPlayScreen: ScreenButtons_SeqPlayScreen[8] -- the LcdKeyRow1 handler of SeqPlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow1_SeqPlayScreen:
	bit	7, w	; F56C57  bit 0x07,W
	jr	nz, LcdKeyRow1_SeqPlayScreen_Skip4	; F56C5A  jr NZ,0xf56cb0
	and	(UI_RequestBits:16), 0xf6	; F56C5C  and (0x2075),0xf6
	bit	0, (0x360b:16)	; F56C61  bit 0,(0x360b)
	jr	nz, LcdKeyRow1_SeqPlayScreen_Skip3	; F56C65  jr NZ,0xf56c7d
	bit	2, (TransportB_State:8)	; F56C67  bit 2,(0x96)
	jr	nz, LcdKeyRow1_SeqPlayScreen_Return2	; F56C6A  jr NZ,0xf56cd5
	set	0, (0x360b:16)	; F56C6C  set 0,(0x360b)
	ld	(13863:16), 1	; F56C70  ld (0x3627),0x01
	ldw	(UI_Request:16), 32788	; F56C75  ld (0x2070),0x8014
	jr	LcdKeyRow1_SeqPlayScreen_Return2	; F56C7B  jr T,0xf56cd5
LcdKeyRow1_SeqPlayScreen_Skip3:
	bit	2, (0x3731:16)	; F56C7D  bit 2,(0x3731)
	jr	nz, LcdKeyRow1_SeqPlayScreen_Return2	; F56C81  jr NZ,0xf56cd5
	res	0, (0x360b:16)	; F56C83  res 0,(0x360b)
	xor	xwa, xwa	; F56C87  xor XWA,XWA
	ld	(14026:16), xwa	; F56C89  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F56C8D  ld (0x36c6),XWA
	ld	a, (13835:16)	; F56C91  ld A,(0x360b)
	and	a, 1	; F56C95  and A,0x01
	ld	(UI_DrawScratch+7:16), a	; F56C98  ld (0x2647),A
	ld	xwa, Draw_CycleMasterS0ngMeasureTimeSig	; F56C9C  ld XWA,0x00f55c8c
	push	xwa	; F56CA1  push XWA
	call	T_CallbackQueue_Post	; F56CA2  call 0xf42e84
	inc	4, xsp	; F56CA6  inc 4,XSP
	ld	a, 1:opc	; F56CA8  ld A,0x01
	call	T_Kernel_SemaSignal	; F56CAA  call 0xf42d88
	jr	LcdKeyRow1_SeqPlayScreen_Return2	; F56CAE  jr T,0xf56cd5
LcdKeyRow1_SeqPlayScreen_Skip4:
	or	(UI_RequestBits:16), 0x09	; F56CB0  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 34953	; F56CB5  ld (0x209b),0x8889  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	call	T_SeqPlayScreen_LcdKeyRow1	; F56CBB  call 0xf40d0c
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56CBF  call 0xf42704
	ld	xwa, Draw_CycleMasterS0ngMeasureTimeSig	; F56CC3  ld XWA,0x00f55c8c
	push	xwa	; F56CC8  push XWA
	call	T_CallbackQueue_Post	; F56CC9  call 0xf42e84
	inc	4, xsp	; F56CCD  inc 4,XSP
	ld	a, 1:opc	; F56CCF  ld A,0x01
	call	T_Kernel_SemaSignal	; F56CD1  call 0xf42d88
LcdKeyRow1_SeqPlayScreen_Return2:
	ret	; F56CD5  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SeqPlayScreen
; Called from: table 0xF55A2E[9]
; Touches: (0x2070) (0x2075) (0x209B) (0x3008) (0x300C)
; Calls:   T_SeqPlayScreen_LcdKeyRow2 T_Seq_LoadTimeSigAtCurrentMeasure T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: entry [9] of the table at 0xF55A2E reads 0x00F56CD6, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56CD6
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SeqPlayScreen: ScreenButtons_SeqPlayScreen[9] -- the LcdKeyRow2 handler of SeqPlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_SeqPlayScreen:
	bit	7, w	; F56CD6  bit 0x07,W
	jr	nz, LcdKeyRow2_SeqPlayScreen_Skip5	; F56CD9  jr NZ,0xf56cf7
	and	(UI_RequestBits:16), 0xf6	; F56CDB  and (0x2075),0xf6
	bit	2, (TransportB_State:8)	; F56CE0  bit 2,(0x96)
	jr	nz, LcdKeyRow2_SeqPlayScreen_Return3	; F56CE3  jr NZ,0xf56d1c
	xor	xwa, xwa	; F56CE5  xor XWA,XWA
	ld	(12296:16), xwa	; F56CE7  ld (0x3008),XWA
	ld	(12300:16), xwa	; F56CEB  ld (0x300c),XWA
	ldw	(UI_Request:16), 517	; F56CEF  ld (0x2070),0x0205
	jr	LcdKeyRow2_SeqPlayScreen_Return3	; F56CF5  jr T,0xf56d1c
LcdKeyRow2_SeqPlayScreen_Skip5:
	or	(UI_RequestBits:16), 0x09	; F56CF7  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 34953	; F56CFC  ld (0x209b),0x8889  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	call	T_SeqPlayScreen_LcdKeyRow2	; F56D02  call 0xf40d10
	call	T_Seq_LoadTimeSigAtCurrentMeasure	; F56D06  call 0xf42704
	ld	xwa, Draw_CycleMasterS0ngMeasureTimeSig	; F56D0A  ld XWA,0x00f55c8c
	push	xwa	; F56D0F  push XWA
	call	T_CallbackQueue_Post	; F56D10  call 0xf42e84
	inc	4, xsp	; F56D14  inc 4,XSP
	ld	a, 1:opc	; F56D16  ld A,0x01
	call	T_Kernel_SemaSignal	; F56D18  call 0xf42d88
LcdKeyRow2_SeqPlayScreen_Return3:
	ret	; F56D1C  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SeqPlayScreen
; Called from: table 0xF55A2E[10]
; Touches: (0x2070) (0x2250) (0x360B) (0x3757) (0x3758)
; Calls:   SeqPlayScreen_LcdKeyRow3
; Evidence: entry [10] of the table at 0xF55A2E reads 0x00F56D1D, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56D1D is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SeqPlayScreen: ScreenButtons_SeqPlayScreen[10] -- the LcdKeyRow3 handler of SeqPlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_SeqPlayScreen:
	bit	7, w	; F56D1D  bit 0x07,W
	jr	nz, LcdKeyRow3_SeqPlayScreen_Skip7	; F56D20  jr NZ,0xf56d32
	bit	2, (TransportB_State:8)	; F56D22  bit 2,(0x96)
	jr	z, LcdKeyRow3_SeqPlayScreen_Skip6	; F56D25  jr Z,0xf56d2d
	bit	0, (0x360b:16)	; F56D27  bit 0,(0x360b)
	jr	nz, LcdKeyRow3_SeqPlayScreen_Return4	; F56D2B  jr NZ,0xf56d45
LcdKeyRow3_SeqPlayScreen_Skip6:
	calr	SeqPlayScreen_LcdKeyRow3	; F56D2D  calr 0xf56d46
	jr	LcdKeyRow3_SeqPlayScreen_Return4	; F56D30  jr T,0xf56d45
LcdKeyRow3_SeqPlayScreen_Skip7:
	ld	a, (UI_PartIndex:16)	; F56D32  ld A,(0x2250)
	ld	(14167:16), a	; F56D36  ld (0x3757),A
	or	(0x3758:16), 0x01	; F56D3A  or (0x3758),0x01
	ldw	(UI_Request:16), 16567	; F56D3F  ld (0x2070),0x40b7
LcdKeyRow3_SeqPlayScreen_Return4:
	ret	; F56D45  ret

; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow3
; Called from: in-module: 0xF56D2D
; Touches: (0x360B) (0x3752)
; Calls:   SeqMasterTrack_SwitchOn SeqMasterTrack_SwitchOff T_CallbackQueue_Post T_Kernel_SemaSignal
;          T_NoteRouting_RebuildForSong T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56D46 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow3: the LcdKeyRow3 action of SeqPlayScreen -- called only by LcdKeyRow3_SeqPlayScreen.
SeqPlayScreen_LcdKeyRow3:
	cp	(0x3752:16), 0x01	; F56D46  cp (0x3752),0x01
	jr	z, SeqPlayScreen_LcdKeyRow3_Skip	; F56D4B  jr Z,0xf56d52
	calr	SeqMasterTrack_SwitchOn	; F56D4D  calr 0xf56d7e
	jr	SeqPlayScreen_LcdKeyRow3_Join	; F56D50  jr T,0xf56d55
SeqPlayScreen_LcdKeyRow3_Skip:
	calr	SeqMasterTrack_SwitchOff	; F56D52  calr 0xf56da8
SeqPlayScreen_LcdKeyRow3_Join:
	ld	xwa, Draw_CycleMasterS0ngMeasureTimeSig	; F56D55  ld XWA,0x00f55c8c
	push	xwa	; F56D5A  push XWA
	call	T_CallbackQueue_Post	; F56D5B  call 0xf42e84
	inc	4, xsp	; F56D5F  inc 4,XSP
	ld	a, 1:opc	; F56D61  ld A,0x01
	call	T_Kernel_SemaSignal	; F56D63  call 0xf42d88
	call	T_NoteRouting_RebuildForSong	; F56D67  call 0xf411b8
	bit	0, (0x360b:16)	; F56D6B  bit 0,(0x360b)
	jr	z, SeqPlayScreen_LcdKeyRow3_Return	; F56D6F  jr Z,0xf56d7d
	call	T_SeqCycle_CaptureEndCursors	; F56D71  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56D75  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56D79  call 0xf40ac4
SeqPlayScreen_LcdKeyRow3_Return:
	ret	; F56D7D  ret

; --------------------------------------------------------------------------
; SeqMasterTrack_SwitchOn
; Called from: in-module: 0xF56D4D
; Touches: (0x360C) (0x3736) (0x3752)
; Calls:   T_SeqTrack_SwitchPlayOnWhileRunning T_SeqTrack_PlayOnWhileStopped
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56D7E is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqMasterTrack_SwitchOn: MASTER := ON: (0x3752) = 1, bit 16 of the saved track mask (0x360C) set, (0x3736) = 16 (the
;   master track), then T_SeqTrack_SwitchPlayOnWhileRunning while transport B runs or T_SeqTrack_PlayOnWhileStopped when stopped. The ON half of
;   SeqPlayScreen_LcdKeyRow3's toggle; SeqMasterTrack_SwitchOff is the OFF half. Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqMasterTrack_SwitchOn:
	ld	(14162:16), 1	; F56D7E  ld (0x3752),0x01
	ld	xwa, 65536	; F56D83  ld XWA,0x00010000
	or	(0x360c:16), xwa	; F56D88  or (0x360c),XWA
	bit	2, (TransportB_State:8)	; F56D8C  bit 2,(0x96)
	jr	z, SeqMasterTrack_SwitchOn_Skip	; F56D8F  jr Z,0xf56d9d
	ld	c, 16:opc	; F56D91  ld C,0x10
	ld	(14134:16), c	; F56D93  ld (0x3736),C
	call	T_SeqTrack_SwitchPlayOnWhileRunning	; F56D97  call 0xf40d68
	jr	SeqMasterTrack_SwitchOn_Return	; F56D9B  jr T,0xf56da7
SeqMasterTrack_SwitchOn_Skip:
	ld	c, 16:opc	; F56D9D  ld C,0x10
	ld	(14134:16), c	; F56D9F  ld (0x3736),C
	call	T_SeqTrack_PlayOnWhileStopped	; F56DA3  call 0xf40d60
SeqMasterTrack_SwitchOn_Return:
	ret	; F56DA7  ret

; --------------------------------------------------------------------------
; SeqMasterTrack_SwitchOff
; Called from: in-module: 0xF564A4 0xF56D52
; Touches: (0x360C) (0x3736) (0x3752)
; Calls:   T_SeqTrack_SwitchPlayOffWhileRunning T_SeqTrack_PlayOffWhileStopped
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56DA8 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqMasterTrack_SwitchOff: MASTER := OFF: (0x3752) = 0, bit 16 of (0x360C) cleared, (0x3736) = 16 (the 17th track),
;   then T_SeqTrack_PlayOffWhileStopped (SeqTrack_PlayOffWhileStopped: clear that track's bit, NoteRouting_RebuildForSong) or T_SeqTrack_SwitchPlayOffWhileRunning while transport B runs.
;   LCD row 3 of SEQ PLAY / REALTIME RECORD toggles; SeqMasterTrack_SwitchOn is the ON half. (0x3752) is the '(MASTER:' OFF/ON
;   readout. Basis: callers + body + caption. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
SeqMasterTrack_SwitchOff:
	ld	(14162:16), 0	; F56DA8  ld (0x3752),0x00
	ld	xwa, 65536	; F56DAD  ld XWA,0x00010000
	xor	xwa, 4294967295	; F56DB2  xor XWA,0xffffffff
	and	(0x360c:16), xwa	; F56DB8  and (0x360c),XWA
	bit	2, (TransportB_State:8)	; F56DBC  bit 2,(0x96)
	jr	z, SeqMasterTrack_SwitchOff_Skip	; F56DBF  jr Z,0xf56dcd
	ld	c, 16:opc	; F56DC1  ld C,0x10
	ld	(14134:16), c	; F56DC3  ld (0x3736),C
	call	T_SeqTrack_SwitchPlayOffWhileRunning	; F56DC7  call 0xf40d6c
	jr	SeqMasterTrack_SwitchOff_Return	; F56DCB  jr T,0xf56dd7
SeqMasterTrack_SwitchOff_Skip:
	ld	c, 16:opc	; F56DCD  ld C,0x10
	ld	(14134:16), c	; F56DCF  ld (0x3736),C
	call	T_SeqTrack_PlayOffWhileStopped	; F56DD3  call 0xf40d64
SeqMasterTrack_SwitchOff_Return:
	ret	; F56DD7  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56DD8
; Called from: table 0xF55A2E[11], 0xF55A2E[12], 0xF55A2E[13], 0xF55A2E[14]
; Touches: nothing with an absolute address
; Evidence: entry [11] of the table at 0xF55A2E reads 0x00F56DD8, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56DD8 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56DD8:
	ret	; F56DD8  ret

; --------------------------------------------------------------------------
; ExitKey_SeqPlayScreen
; Called from: table 0xF55A2E[15]
; Touches: (0x2070)
; Calls:   T_F40D18
; Evidence: entry [15] of the table at 0xF55A2E reads 0x00F56DD9, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56DD9 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SeqPlayScreen: ScreenButtons_SeqPlayScreen[15] -- the ExitKey handler of SeqPlayScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_SeqPlayScreen:
	bit	7, w	; F56DD9  bit 0x07,W
	jr	nz, ExitKey_SeqPlayScreen_Return2	; F56DDC  jr NZ,0xf56def
	bit	2, (TransportB_State:8)	; F56DDE  bit 2,(0x96)
	jr	nz, ExitKey_SeqPlayScreen_Return2	; F56DE1  jr NZ,0xf56def
	call	T_F40D18	; F56DE3  call 0xf40d18
	ldw	(UI_Request:16), 513	; F56DE7  ld (0x2070),0x0201
	jr	ExitKey_SeqPlayScreen_Return2	; F56DED  jr T,0xf56def
ExitKey_SeqPlayScreen_Return2:
	ret	; F56DEF  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56DF0
; Called from: table 0xF55A2E[16], 0xF55A2E[25], 0xF55A2E[26], 0xF55A2E[27],
;              0xF55A2E[28], 0xF55A2E[29] +2 more; in-module: 0xF55868
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF55A2E reads 0x00F56DF0, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56DF0 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56DF0:
	ret	; F56DF0  ret

; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayScreen
; Called from: in-module: 0xF5586C
; Touches: (0x207A) (0x207B) (0x207C) (0x207D) (0x2095) (0x361E) (0x3620)
;          (0x3627)
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB
;          T_CallbackQueue_Post T_Kernel_SemaSignal CyclePlayScreen_UpdateFieldBlink
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56DF1 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayScreen: the +0 ENTER method of screen 0x14 (thunk T_ScreenEnter_CyclePlayScreen_Fwd).  Its painter names the screen.
ScreenEnter_CyclePlayScreen:
	ld	a, (UI_ScreenLatch:16)	; F56DF1  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F56DF5  cp A,(0x207b)
	jr	nz, ScreenEnter_CyclePlayScreen_Skip	; F56DF9  jr NZ,0xf56e0b
	ld	a, (UI_ScreenId:16)	; F56DFB  ld A,(0x207c)
	cp	a, (UI_ScreenId_Previous:16)	; F56DFF  cp A,(0x207d)
	jr	nz, ScreenEnter_CyclePlayScreen_Skip4	; F56E03  jr NZ,0xf56e3e
	bit	4, (UI_ScreenFlags:16)	; F56E05  bit 4,(0x2095)
	jr	nz, ScreenEnter_CyclePlayScreen_Skip5	; F56E09  jr NZ,0xf56e50
ScreenEnter_CyclePlayScreen_Skip:
	bit	2, (TransportB_State:8)	; F56E0B  bit 2,(0x96)
	jr	nz, ScreenEnter_CyclePlayScreen_Skip4	; F56E0E  jr NZ,0xf56e3e
	call	T_CallbackQueue_ResetAndRestartTask2	; F56E10  call 0xf42e80
	cp	(0x3627:16), 0x03	; F56E14  cp (0x3627),0x03
	jr	nz, ScreenEnter_CyclePlayScreen_Skip2	; F56E19  jr NZ,0xf56e20
	ld	(13863:16), 1	; F56E1B  ld (0x3627),0x01
ScreenEnter_CyclePlayScreen_Skip2:
	ld	wa, (13854:16)	; F56E20  ld WA,(0x361e)
	cp	wa, (0x3620:16)	; F56E24  cp WA,(0x3620)
	jr	ule, ScreenEnter_CyclePlayScreen_Skip3	; F56E28  jr ULE,0xf56e32
	ld	wa, (13854:16)	; F56E2A  ld WA,(0x361e)
	ld	(13856:16), wa	; F56E2E  ld (0x3620),WA
ScreenEnter_CyclePlayScreen_Skip3:
	call	T_SeqCycle_CaptureEndCursors	; F56E32  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F56E36  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F56E3A  call 0xf40ac4
ScreenEnter_CyclePlayScreen_Skip4:
	ld	xwa, Draw_CyclePlayCurrentMeasureCycle	; F56E3E  ld XWA,0x00f55ed8
	push	xwa	; F56E43  push XWA
	call	T_CallbackQueue_Post	; F56E44  call 0xf42e84
	inc	4, xsp	; F56E48  inc 4,XSP
	ld	a, 1:opc	; F56E4A  ld A,0x01
	call	T_Kernel_SemaSignal	; F56E4C  call 0xf42d88
ScreenEnter_CyclePlayScreen_Skip5:
	ld	xwa, CyclePlayScreen_DrawValues	; F56E50  ld XWA,0x00f55eea
	push	xwa	; F56E55  push XWA
	call	T_CallbackQueue_Post	; F56E56  call 0xf42e84
	inc	4, xsp	; F56E5A  inc 4,XSP
	ld	a, 1:opc	; F56E5C  ld A,0x01
	call	T_Kernel_SemaSignal	; F56E5E  call 0xf42d88
	calr	CyclePlayScreen_UpdateFieldBlink	; F56E62  calr 0xf56e66
	ret	; F56E65  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_UpdateFieldBlink
; Called from: in-module: 0xF56E62 0xF5730D
; Touches: (0x3627)
; Calls:   T_Blink_SetEnable
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56E66 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_UpdateFieldBlink: Blink_SetEnable(1) when the CYCLE PLAY cursor (0x3627) is on field 1 or 2 (the two
;   measure fields the number pad edits), Blink_SetEnable(0) for 0, 3 or anything else. Basis: callers + body -- the
;   last step of the CYCLE PLAY and CYCLE PLAY EDIT screens' ENTER handlers. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
CyclePlayScreen_UpdateFieldBlink:
	cp	(0x3627:16), 0x00	; F56E66  cp (0x3627),0x00
	jr	z, CyclePlayScreen_UpdateFieldBlink_Join	; F56E6B  jr Z,0xf56e8f
	cp	(0x3627:16), 0x03	; F56E6D  cp (0x3627),0x03
	jr	z, CyclePlayScreen_UpdateFieldBlink_Join	; F56E72  jr Z,0xf56e8f
	cp	(0x3627:16), 0x01	; F56E74  cp (0x3627),0x01
	jr	z, CyclePlayScreen_UpdateFieldBlink_Skip	; F56E79  jr Z,0xf56e84
	cp	(0x3627:16), 0x02	; F56E7B  cp (0x3627),0x02
	jr	z, CyclePlayScreen_UpdateFieldBlink_Skip	; F56E80  jr Z,0xf56e84
	jr	CyclePlayScreen_UpdateFieldBlink_Join	; F56E82  jr T,0xf56e8f
CyclePlayScreen_UpdateFieldBlink_Skip:
	pushw	1	; F56E84  push 0x0001
	call	T_Blink_SetEnable	; F56E87  call 0xf42e28
	inc	2, xsp	; F56E8B  inc 2,XSP
	jr	CyclePlayScreen_UpdateFieldBlink_Return	; F56E8D  jr T,0xf56e98
CyclePlayScreen_UpdateFieldBlink_Join:
	pushw	0	; F56E8F  push 0x0000
	call	T_Blink_SetEnable	; F56E92  call 0xf42e28
	inc	2, xsp	; F56E96  inc 2,XSP
CyclePlayScreen_UpdateFieldBlink_Return:
	ret	; F56E98  ret

; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayScreen
; Called from: in-module: 0xF55870
; Touches: (0x207A) (0x207B) (0x34BB) (0x3628)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56E99 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayScreen: the +4 LEAVE method of screen 0x14 (thunk T_ScreenLeave_CyclePlayScreen_Fwd).
ScreenLeave_CyclePlayScreen:
	ld	a, (UI_ScreenLatch:16)	; F56E99  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F56E9D  cp A,(0x207b)
	jr	nz, ScreenLeave_CyclePlayScreen_Skip	; F56EA1  jr NZ,0xf56ea5
	jr	ScreenLeave_CyclePlayScreen_Return	; F56EA3  jr T,0xf56eb6
ScreenLeave_CyclePlayScreen_Skip:
	and	(0x34bb:16), 0xfb	; F56EA5  and (0x34bb),0xfb
	cp	(0x3628:16), 0x00	; F56EAA  cp (0x3628),0x00
	jr	z, ScreenLeave_CyclePlayScreen_Return	; F56EAF  jr Z,0xf56eb6
	ld	(13864:16), 0	; F56EB1  ld (0x3628),0x00
ScreenLeave_CyclePlayScreen_Return:
	ret	; F56EB6  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56EB7
; Called from: table 0xF55AAE[0], 0xF55AAE[1], 0xF55AAE[2], 0xF55AAE[3],
;              0xF55AAE[4], 0xF55AAE[5] +3 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the table at 0xF55AAE reads 0x00F56EB7, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56EB7
;           is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56EB7:
	ret	; F56EB7  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayScreen
; Called from: table 0xF55AAE[9]
; Touches: nothing with an absolute address
; Calls:   CyclePlayScreen_IncField CyclePlayScreen_LcdKeyRow2
; Evidence: entry [9] of the table at 0xF55AAE reads 0x00F56EB8, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF56EB8
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayScreen: ScreenButtons_CyclePlayScreen[9] -- the LcdKeyRow2 handler of CyclePlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_CyclePlayScreen:
	bit	7, w	; F56EB8  bit 0x07,W
	jr	nz, LcdKeyRow2_CyclePlayScreen_Skip2	; F56EBB  jr NZ,0xf56ec2
	calr	CyclePlayScreen_IncField	; F56EBD  calr 0xf57050
	jr	LcdKeyRow2_CyclePlayScreen_Return2	; F56EC0  jr T,0xf56ec5
LcdKeyRow2_CyclePlayScreen_Skip2:
	calr	CyclePlayScreen_LcdKeyRow2	; F56EC2  calr 0xf56fd6
LcdKeyRow2_CyclePlayScreen_Return2:
	ret	; F56EC5  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayScreen
; Called from: table 0xF55AAE[10]
; Touches: nothing with an absolute address
; Calls:   CyclePlayScreen_DecField CyclePlayScreen_LcdKeyRow3
; Evidence: entry [10] of the table at 0xF55AAE reads 0x00F56EC6, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56EC6 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayScreen: ScreenButtons_CyclePlayScreen[10] -- the LcdKeyRow3 handler of CyclePlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_CyclePlayScreen:
	bit	7, w	; F56EC6  bit 0x07,W
	jr	nz, LcdKeyRow3_CyclePlayScreen_Skip3	; F56EC9  jr NZ,0xf56ed0
	calr	CyclePlayScreen_DecField	; F56ECB  calr 0xf5718c
	jr	LcdKeyRow3_CyclePlayScreen_Return3	; F56ECE  jr T,0xf56ed3
LcdKeyRow3_CyclePlayScreen_Skip3:
	calr	CyclePlayScreen_LcdKeyRow3	; F56ED0  calr 0xf57014
LcdKeyRow3_CyclePlayScreen_Return3:
	ret	; F56ED3  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayScreen
; Called from: table 0xF55AAE[11]; in-module: 0xF57366
; Touches: nothing with an absolute address
; Calls:   CyclePlayScreen_LcdKeyRow4
; Evidence: entry [11] of the table at 0xF55AAE reads 0x00F56ED4, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56ED4 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayScreen: ScreenButtons_CyclePlayScreen[11] -- the LcdKeyRow4 handler of CyclePlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow4_CyclePlayScreen:
	bit	7, w	; F56ED4  bit 0x07,W
	jr	nz, LcdKeyRow4_CyclePlayScreen_Skip	; F56ED7  jr NZ,0xf56eda
	ret	; F56ED9  ret
LcdKeyRow4_CyclePlayScreen_Skip:
	calr	CyclePlayScreen_LcdKeyRow4	; F56EDA  calr 0xf57032
	ret	; F56EDD  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_CyclePlayScreen
; Called from: table 0xF55AAE[12]
; Touches: (0x2070) (0x3628)
; Evidence: entry [12] of the table at 0xF55AAE reads 0x00F56EDE, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56EDE is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_CyclePlayScreen: ScreenButtons_CyclePlayScreen[12] -- the LcdKeyRow5 handler of CyclePlayScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow5_CyclePlayScreen:
	bit	7, w	; F56EDE  bit 0x07,W
	jr	nz, LcdKeyRow5_CyclePlayScreen_Return	; F56EE1  jr NZ,0xf56ef2
	cp	(0x3628:16), 0x00	; F56EE3  cp (0x3628),0x00
	jr	nz, LcdKeyRow5_CyclePlayScreen_Return	; F56EE8  jr NZ,0xf56ef2
	ldw	(UI_Request:16), 32786	; F56EEA  ld (0x2070),0x8012
	jr	LcdKeyRow5_CyclePlayScreen_Return	; F56EF0  jr T,0xf56ef2
LcdKeyRow5_CyclePlayScreen_Return:
	ret	; F56EF2  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56EF3
; Called from: table 0xF55AAE[13], 0xF55AAE[14]
; Touches: nothing with an absolute address
; Evidence: entry [13] of the table at 0xF55AAE reads 0x00F56EF3, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56EF3 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56EF3:
	ret	; F56EF3  ret

; --------------------------------------------------------------------------
; ExitKey_CyclePlayScreen
; Called from: table 0xF55AAE[15]
; Touches: (0x2070) (0x3628)
; Evidence: entry [15] of the table at 0xF55AAE reads 0x00F56EF4, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56EF4 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_CyclePlayScreen: ScreenButtons_CyclePlayScreen[15] -- the ExitKey handler of CyclePlayScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_CyclePlayScreen:
	bit	7, w	; F56EF4  bit 0x07,W
	jr	nz, ExitKey_CyclePlayScreen_Return2	; F56EF7  jr NZ,0xf56f08
	cp	(0x3628:16), 0x00	; F56EF9  cp (0x3628),0x00
	jr	nz, ExitKey_CyclePlayScreen_Return2	; F56EFE  jr NZ,0xf56f08
	ldw	(UI_Request:16), 32786	; F56F00  ld (0x2070),0x8012
	jr	ExitKey_CyclePlayScreen_Return2	; F56F06  jr T,0xf56f08
ExitKey_CyclePlayScreen_Return2:
	ret	; F56F08  ret

; --------------------------------------------------------------------------
; NumberPadKey_CyclePlayScreen
; Called from: table 0xF55AAE[27]; in-module: 0xF5737D
; Touches: (0x2267) (0x2826) (0x34D9) (0x361E) (0x3620) (0x3627)
; Calls:   T_AsciiDigits3_ToValue T_Blink_Stop CyclePlayScreen_ApplyStartMeasure CyclePlayScreen_BlinkStartMeasure
;          CyclePlayScreen_QueueEndMeasureChange CyclePlayScreen_BlinkEndMeasure
; Evidence: entry [27] of the table at 0xF55AAE reads 0x00F56F09, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56F09 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; NumberPadKey_CyclePlayScreen: ScreenButtons_CyclePlayScreen[27] -- the NumberPadKey handler of CyclePlayScreen; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
NumberPadKey_CyclePlayScreen:
	bit	2, (TransportB_State:8)	; F56F09  bit 2,(0x96)
	jr	nz, NumberPadKey_CyclePlayScreen_Return	; F56F0C  jr NZ,0xf56f7a
	bit	2, (0x34d9:16)	; F56F0E  bit 2,(0x34d9)
	jr	nz, NumberPadKey_CyclePlayScreen_Return	; F56F12  jr NZ,0xf56f7a
	cp	(0x3627:16), 0x01	; F56F14  cp (0x3627),0x01
	jr	z, NumberPadKey_CyclePlayScreen_Skip	; F56F19  jr Z,0xf56f24
	cp	(0x3627:16), 0x02	; F56F1B  cp (0x3627),0x02
	jr	z, NumberPadKey_CyclePlayScreen_Skip3	; F56F20  jr Z,0xf56f50
	jr	NumberPadKey_CyclePlayScreen_Return	; F56F22  jr T,0xf56f7a
NumberPadKey_CyclePlayScreen_Skip:
	cp	(0x2267:16), 0x0f	; F56F24  cp (0x2267),0x0f
	jr	z, NumberPadKey_CyclePlayScreen_Skip2	; F56F29  jr Z,0xf56f2d
	jr	NumberPadKey_CyclePlayScreen_Join	; F56F2B  jr T,0xf56f4b
NumberPadKey_CyclePlayScreen_Skip2:
	ld	(10278:16), 3	; F56F2D  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F56F32  call 0xf432f0
	cp	wa, 1:i3	; F56F36  cp WA,1
	jr	c, NumberPadKey_CyclePlayScreen_Join	; F56F38  jr C,0xf56f4b
	cp	wa, 999	; F56F3A  cp WA,0x03e7
	jr	ugt, NumberPadKey_CyclePlayScreen_Join	; F56F3E  jr UGT,0xf56f4b
	ld	(13854:16), wa	; F56F40  ld (0x361e),WA
	call	T_Blink_Stop	; F56F44  call 0xf42e24
	calr	CyclePlayScreen_ApplyStartMeasure	; F56F48  calr 0xf570dc
NumberPadKey_CyclePlayScreen_Join:
	calr	CyclePlayScreen_BlinkStartMeasure	; F56F4B  calr 0xf56f7b
	jr	NumberPadKey_CyclePlayScreen_Return	; F56F4E  jr T,0xf56f7a
NumberPadKey_CyclePlayScreen_Skip3:
	cp	(0x2267:16), 0x0f	; F56F50  cp (0x2267),0x0f
	jr	z, NumberPadKey_CyclePlayScreen_Skip4	; F56F55  jr Z,0xf56f59
	jr	NumberPadKey_CyclePlayScreen_Join2	; F56F57  jr T,0xf56f77
NumberPadKey_CyclePlayScreen_Skip4:
	ld	(10278:16), 3	; F56F59  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F56F5E  call 0xf432f0
	cp	wa, 1:i3	; F56F62  cp WA,1
	jr	c, NumberPadKey_CyclePlayScreen_Join2	; F56F64  jr C,0xf56f77
	cp	wa, 999	; F56F66  cp WA,0x03e7
	jr	ugt, NumberPadKey_CyclePlayScreen_Join2	; F56F6A  jr UGT,0xf56f77
	ld	(13856:16), wa	; F56F6C  ld (0x3620),WA
	call	T_Blink_Stop	; F56F70  call 0xf42e24
	calr	CyclePlayScreen_QueueEndMeasureChange	; F56F74  calr 0xf5723b
NumberPadKey_CyclePlayScreen_Join2:
	calr	CyclePlayScreen_BlinkEndMeasure	; F56F77  calr 0xf56fa8
NumberPadKey_CyclePlayScreen_Return:
	ret	; F56F7A  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkStartMeasure
; Called from: in-module: 0xF56F4B
; Touches: (0x2540) (0x2652) (0x361E)  |  0xF3500B
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal T_Blink_Command
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56F7B is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkStartMeasure: Stages CYCLE PLAY's START measure (0x361E) into UI_DrawScratch+18 and posts
;   CyclePlayScreen_BlinkStartMeasureReadout, which hands that field's decimal-readout record (DL_F34FF2 + 0x19, source UI_DrawScratch+18) to
;   Blink_Command: the start field blinks with its value. The tail of NumberPadKey_CyclePlayScreen's START-field arm
;   (field cursor (0x3627) = 1); CyclePlayScreen_BlinkEndMeasure is the END twin. Basis: caller + body + display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
CyclePlayScreen_BlinkStartMeasure:
	ld	wa, (13854:16)	; F56F7B  ld WA,(0x361e)
	ld	(UI_DrawScratch+18:16), wa	; F56F7F  ld (0x2652),WA
	ld	xwa, CyclePlayScreen_BlinkStartMeasureReadout	; F56F83  ld XWA,0x00f56f96
	push	xwa	; F56F88  push XWA
	call	T_CallbackQueue_Post	; F56F89  call 0xf42e84
	inc	4, xsp	; F56F8D  inc 4,XSP
	ld	a, 1:opc	; F56F8F  ld A,0x01
	call	T_Kernel_SemaSignal	; F56F91  call 0xf42d88
	ret	; F56F95  ret
; CyclePlayScreen_BlinkStartMeasureReadout: The callback CyclePlayScreen_BlinkStartMeasure posts: on layer 0 hands
;   Blink_Command the START measure field's decimal-readout record DL_F34FF2 + 0x19 (source UI_DrawScratch+18, which
;   the poster has just loaded from (0x361E)). Twin of CyclePlayScreen_BlinkEndMeasureField (END) and of CYCLE
;   RECORD's CycleRecordScreen_BlinkStartMeasureReadout. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
CyclePlayScreen_BlinkStartMeasureReadout:
	ld	(LCD_CurrentLayer:16), 0	; F56F96  ld (0x2540),0x00
	ld	xiy, DL_F34FF2 + 0x19	; F56F9B  ld XIY,0x00f3500b
	push	xiy	; F56FA0  push XIY
	call	T_Blink_Command	; F56FA1  call 0xf42e20
	inc	4, xsp	; F56FA5  inc 4,XSP
	ret	; F56FA7  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkEndMeasure
; Called from: in-module: 0xF56F77
; Touches: (0x2540) (0x2654) (0x3620)  |  0xF35015
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal T_Blink_Command
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56FA8 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkEndMeasure: UI_DrawScratch+20 (0x2654) := the CYCLE PLAY end measure (0x3620), then posts
;   CyclePlayScreen_BlinkEndMeasureReadout, which hands Blink_Command the END field record DL_F34FF2+0x23 (command 6, SetState).
;   NumberPadKey_CyclePlayScreen calls it after every number entry on the END field ((0x3627) = 2). Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
CyclePlayScreen_BlinkEndMeasure:
	ld	wa, (13856:16)	; F56FA8  ld WA,(0x3620)
	ld	(UI_DrawScratch+20:16), wa	; F56FAC  ld (0x2654),WA
	ld	xwa, CyclePlayScreen_BlinkEndMeasureReadout	; F56FB0  ld XWA,0x00f56fc3
	push	xwa	; F56FB5  push XWA
	call	T_CallbackQueue_Post	; F56FB6  call 0xf42e84
	inc	4, xsp	; F56FBA  inc 4,XSP
	ld	a, 1:opc	; F56FBC  ld A,0x01
	call	T_Kernel_SemaSignal	; F56FBE  call 0xf42d88
	ret	; F56FC2  ret
; CyclePlayScreen_BlinkEndMeasureReadout: The callback CyclePlayScreen_BlinkEndMeasure posts: on layer 0 hands
;   Blink_Command the END measure field's decimal-readout record DL_F34FF2 + 0x23 (source UI_DrawScratch+20 =
;   (0x3620)). Twin of CyclePlayScreen_BlinkStartMeasureField and of CYCLE RECORD's CycleRecordScreen_BlinkEndMeasureReadout. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
CyclePlayScreen_BlinkEndMeasureReadout:
	ld	(LCD_CurrentLayer:16), 0	; F56FC3  ld (0x2540),0x00
	ld	xiy, DL_F34FF2 + 0x23	; F56FC8  ld XIY,0x00f35015
	push	xiy	; F56FCD  push XIY
	call	T_Blink_Command	; F56FCE  call 0xf42e20
	inc	4, xsp	; F56FD2  inc 4,XSP
	ret	; F56FD4  ret

; --------------------------------------------------------------------------
; Nop_Ret_F56FD5
; Called from: table 0xF55AAE[16], 0xF55AAE[17], 0xF55AAE[18], 0xF55AAE[19],
;              0xF55AAE[20], 0xF55AAE[21] +9 more; in-module: 0xF5587E
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF55AAE reads 0x00F56FD5, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF56FD5 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F56FD5:
	ret	; F56FD5  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow2
; Called from: in-module: 0xF56EC2
; Touches: (0x12F6) (0x2095) (0x2540) (0x3627) (0x3628) (0x3756)  |  0xF3501F
;          0xF3502A
; Calls:   T_Blink_Stop T_DLB_Handler_Array8_2 T_DLB_Handler_Array8
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF56FD6 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow2: the LcdKeyRow2 action of CyclePlayScreen -- called only by LcdKeyRow2_CyclePlayScreen.
CyclePlayScreen_LcdKeyRow2:
	cp	(0x3628:16), 0x00	; F56FD6  cp (0x3628),0x00
	jr	nz, CyclePlayScreen_LcdKeyRow2_Return	; F56FDB  jr NZ,0xf56ff3
	ld	a, (13863:16)	; F56FDD  ld A,(0x3627)
	ld	(14166:16), a	; F56FE1  ld (0x3756),A
	ld	(13863:16), 0	; F56FE5  ld (0x3627),0x00
	call	T_Blink_Stop	; F56FEA  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F56FEE  or (0x2095),0x10
CyclePlayScreen_LcdKeyRow2_Return:
	ret	; F56FF3  ret
	ld	(LCD_CurrentLayer:16), 1	; F56FF4  ld (0x2540),0x01
	ld	xiy, DL_F34FF2 + 0x38	; F56FF9  ld XIY,0x00f3502a
	call	T_DLB_Handler_Array8_2	; F56FFE  call 0xf41820
	ld	a, (13863:16)	; F57002  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F57006  ld (0x12f6),A
	ld	xiy, DL_F34FF2 + 0x2D	; F5700A  ld XIY,0x00f3501f
	call	T_DLB_Handler_Array8	; F5700F  call 0xf4181c
	ret	; F57013  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow3
; Called from: in-module: 0xF56ED0 0xF57362
; Touches: (0x2095) (0x3627) (0x3628) (0x3756)
; Calls:   T_Blink_Stop
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57014 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow3: the LcdKeyRow3 action of CyclePlayEditScreen, CyclePlayScreen -- called only by LcdKeyRow3_CyclePlayEditScreen, LcdKeyRow3_CyclePlayScreen.
CyclePlayScreen_LcdKeyRow3:
	cp	(0x3628:16), 0x00	; F57014  cp (0x3628),0x00
	jr	nz, CyclePlayScreen_LcdKeyRow3_Return	; F57019  jr NZ,0xf57031
	ld	a, (13863:16)	; F5701B  ld A,(0x3627)
	ld	(14166:16), a	; F5701F  ld (0x3756),A
	ld	(13863:16), 1	; F57023  ld (0x3627),0x01
	call	T_Blink_Stop	; F57028  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F5702C  or (0x2095),0x10
CyclePlayScreen_LcdKeyRow3_Return:
	ret	; F57031  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow4
; Called from: in-module: 0xF56EDA
; Touches: (0x2095) (0x3627) (0x3628) (0x3756)
; Calls:   T_Blink_Stop
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57032 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_LcdKeyRow4: the LcdKeyRow4 action of CyclePlayScreen -- called only by LcdKeyRow4_CyclePlayScreen.
CyclePlayScreen_LcdKeyRow4:
	cp	(0x3628:16), 0x00	; F57032  cp (0x3628),0x00
	jr	nz, CyclePlayScreen_LcdKeyRow4_Return	; F57037  jr NZ,0xf5704f
	ld	a, (13863:16)	; F57039  ld A,(0x3627)
	ld	(14166:16), a	; F5703D  ld (0x3756),A
	ld	(13863:16), 2	; F57041  ld (0x3627),0x02
	call	T_Blink_Stop	; F57046  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F5704A  or (0x2095),0x10
CyclePlayScreen_LcdKeyRow4_Return:
	ret	; F5704F  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_IncField
; Called from: in-module: 0xF56EBD 0xF5734F
; Touches: (0x2075) (0x3627)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57050 is an instruction boundary.
; Shape:   `ld XIX,0x00F5706A / ld A,(0x3627) / sll 0x02,XWA / add XIX,XWA /
;          ld XIX,(XIX) / call T,XIX` -- entry (0x3627) of that 5-entry table,
;          with NO bound on the index.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CyclePlayScreen_IncField: CYCLE PLAY / CYCLE PLAY EDIT LCD row 2 RIGHT key (up arrow): sets UI_RequestBits bit 3 and
;   calls CyclePlayScreen_FieldIncHandlers[field cursor (0x3627)]. Basis: the table it reads + callers. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_IncField:
	or	(UI_RequestBits:16), 0x08	; F57050  or (0x2075),0x08
	xor	xwa, xwa	; F57055  xor XWA,XWA
	ld	xix, CyclePlayScreen_FieldIncHandlers	; F57057  ld XIX,0x00f5706a
	ld	a, (13863:16)	; F5705C  ld A,(0x3627)
	sll	xwa, 2	; F57060  sll 0x02,XWA
	add	xix, xwa	; F57063  add XIX,XWA
	ld	xix, (xix)	; F57065  ld XIX,(XIX)
	call	(xix)	; F57067  call T,XIX
	ret	; F57069  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_FieldIncHandlers -- five 32-bit routine pointers, entered with
;                              `call (XIX)`.
; Read by: 0xF57057: `xor XWA,XWA / ld XIX,0x00F5706A / ld A,(0x3627) / sll
;          0x02,XWA / add XIX,XWA / ld XIX,(XIX) / call T,XIX` -- entry
;          (0x3627) of this table, UNBOUNDED: nothing here range-checks the
;          byte.  ⚠ THE STATE BYTE IS NOT THE SAME FOR ALL FOUR TABLES:
;          0xF5693F and 0xF56A79 are indexed by (0x36CE), 0xF5706A and
;          0xF571A6 by (0x3627).  This file assumed one byte for all four and
;          --selftest refused it.
; Evidence: the entry count rests on two facts, both re-read on every emit:
;           entry [0] is 0xF5707E, which is the byte immediately AFTER the
;           table, so the table frames itself; and the word at [5] is
;           0xC8360BF1, which is not a 0x00F00000-0x00FFFFFF pointer, while
;           [0]..[4] all are.  Same first-non-pointer rule the 0xF7D000 block
;           used.
; Unknown: what the byte at (0x3627) enumerates.  Nothing decoded here says
;          what its values mean, so the name is FRAMED and no entry is given a
;          name.  ⚠ AND NOTHING BOUNDS IT: a value above 4 would index past
;          the table.  That is what the bytes say; whether the callers
;          guarantee the range is not established here.
; --------------------------------------------------------------------------
; CyclePlayScreen_FieldIncHandlers: CYCLE PLAY (0x14) / CYCLE PLAY EDIT (0x26, 0x29), LCD row 2 RIGHT key (up arrow):
;   steps the field under the cursor (0x3627) up -- 0 CYCLE := ON, 1 START + 1, 2 END + 1, 3 SOLO := ON (EDIT page);
;   [4] repeats [0]. Basis: table index (field cursor; its writers and the pages' rows) + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_FieldIncHandlers:
	.long	CyclePlayScreen_SwitchCycleOn	; F5706A  [0] -> CyclePlayScreen_SwitchCycleOn
	.long	CyclePlayScreen_IncStartMeasure	; F5706E  [1] -> CyclePlayScreen_IncStartMeasure
	.long	CyclePlayScreen_IncEndMeasure	; F57072  [2] -> CyclePlayScreen_IncEndMeasure
	.long	CyclePlayEditScreen_SwitchSoloOn	; F57076  [3] -> CyclePlayEditScreen_SwitchSoloOn
	.long	CyclePlayScreen_SwitchCycleOn	; F5707A  [4] -> CyclePlayScreen_SwitchCycleOn


; --------------------------------------------------------------------------
; CyclePlayScreen_SwitchCycleOn
; Called from: table 0xF5706A[0], 0xF5706A[4]
; Touches: (0x360B)
; Calls:   sub_F5709D T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB
; Evidence: entry [0] of the table at 0xF5706A reads 0x00F5707E, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5707E
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_SwitchCycleOn: CyclePlayScreen_FieldIncHandlers[0] (field CYCLE): unless on or the transport runs,
;   sets the CYCLE PLAY switch (0x360B) bit 0, repaints OFF/ON, then SeqCycle_CaptureEndCursors /
;   SeqCycle_LocateToStart / Seq_SetTrackBeatsFromTransportB. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_SwitchCycleOn:
	bit	0, (0x360b:16)	; F5707E  bit 0,(0x360b)
	jr	nz, CyclePlayScreen_SwitchCycleOn_Return	; F57082  jr NZ,0xf5709c
	bit	2, (TransportB_State:8)	; F57084  bit 2,(0x96)
	jr	nz, CyclePlayScreen_SwitchCycleOn_Return	; F57087  jr NZ,0xf5709c
	set	0, (0x360b:16)	; F57089  set 0,(0x360b)
	calr	sub_F5709D	; F5708D  calr 0xf5709d
	call	T_SeqCycle_CaptureEndCursors	; F57090  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F57094  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F57098  call 0xf40ac4
CyclePlayScreen_SwitchCycleOn_Return:
	ret	; F5709C  ret

; --------------------------------------------------------------------------
; sub_F5709D
; Called from: in-module: 0xF5708D 0xF571D4
; Touches: (0x2647) (0x360B)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5709D is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F5709D:
	ld	a, (13835:16)	; F5709D  ld A,(0x360b)
	and	a, 1	; F570A1  and A,0x01
	ld	(UI_DrawScratch+7:16), a	; F570A4  ld (0x2647),A
	ld	xwa, sub_F55F9F	; F570A8  ld XWA,0x00f55f9f
	push	xwa	; F570AD  push XWA
	call	T_CallbackQueue_Post	; F570AE  call 0xf42e84
	inc	4, xsp	; F570B2  inc 4,XSP
	ld	a, 1:opc	; F570B4  ld A,0x01
	call	T_Kernel_SemaSignal	; F570B6  call 0xf42d88
	ret	; F570BA  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_IncStartMeasure
; Called from: table 0xF5706A[1]
; Touches: (0x361E)
; Calls:   T_Blink_Stop CyclePlayScreen_BlinkStartAndEndMeasures CyclePlayScreen_ApplyStartMeasure
; Evidence: entry [1] of the table at 0xF5706A reads 0x00F570BB, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF570BB
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_IncStartMeasure: CyclePlayScreen_FieldIncHandlers[1] (field START MEASURE): while stopped, (0x361E)
;   + 1 up to 999, blinks both readouts, CyclePlayScreen_ApplyStartMeasure. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_IncStartMeasure:
	bit	2, (TransportB_State:8)	; F570BB  bit 2,(0x96)
	jr	nz, sub_F5709D_Return	; F570BE  jr NZ,0xf570db
	call	T_Blink_Stop	; F570C0  call 0xf42e24
	cpw	(0x361e:16), 0x03e7	; F570C4  cp (0x361e),0x03e7
	jr	c, sub_F5709D_Skip	; F570CA  jr C,0xf570d1
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F570CC  calr 0xf57127
	jr	sub_F5709D_Return	; F570CF  jr T,0xf570db
sub_F5709D_Skip:
	incw	1, (13854:16)	; F570D1  incw 1,(0x361e)
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F570D5  calr 0xf57127
	calr	CyclePlayScreen_ApplyStartMeasure	; F570D8  calr 0xf570dc
sub_F5709D_Return:
	ret	; F570DB  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_ApplyStartMeasure
; Called from: in-module: 0xF56F48 0xF570D8
; Touches: (0x34BB) (0x361E) (0x3620) (0x3628) (0x3629)
; Calls:   CyclePlayScreen_BlinkStartAndEndMeasures
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF570DC is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_ApplyStartMeasure: After the CYCLE PLAY start measure (0x361E) changes: if it is past the end
;   (0x3620), end := start, (0x34BB) bit 2, the deferred action 2 (relocate start and end) armed and the fields
;   repainted (CyclePlayScreen_BlinkStartAndEndMeasures); otherwise (0x34BB) bit 2 and action 0 (relocate to the start) armed 3 ticks ahead, unless
;   an action 2 is already pending. Callers: NumberPadKey_CyclePlayScreen (start typed) and the increment key
;   CyclePlayScreen_IncStartMeasure. Basis: callers + body + Dispatch_3629. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
CyclePlayScreen_ApplyStartMeasure:
	ld	wa, (13854:16)	; F570DC  ld WA,(0x361e)
	cp	wa, (0x3620:16)	; F570E0  cp WA,(0x3620)
	jr	ule, CyclePlayScreen_ApplyStartMeasure_Skip	; F570E4  jr ULE,0xf57102
	ld	wa, (13854:16)	; F570E6  ld WA,(0x361e)
	ld	(13856:16), wa	; F570EA  ld (0x3620),WA
	or	(0x34bb:16), 0x04	; F570EE  or (0x34bb),0x04
	ld	(13864:16), 131	; F570F3  ld (0x3628),0x83
	ld	(13865:16), 2	; F570F8  ld (0x3629),0x02
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F570FD  calr 0xf57127
	jr	CyclePlayScreen_ApplyStartMeasure_Return	; F57100  jr T,0xf57126
CyclePlayScreen_ApplyStartMeasure_Skip:
	or	(0x34bb:16), 0x04	; F57102  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F57107  cp (0x3628),0x00
	jr	z, CyclePlayScreen_ApplyStartMeasure_Skip2	; F5710C  jr Z,0xf5711c
	cp	(0x3629:16), 0x02	; F5710E  cp (0x3629),0x02
	jr	nz, CyclePlayScreen_ApplyStartMeasure_Skip2	; F57113  jr NZ,0xf5711c
	ld	(13864:16), 131	; F57115  ld (0x3628),0x83
	jr	CyclePlayScreen_ApplyStartMeasure_Return	; F5711A  jr T,0xf57126
CyclePlayScreen_ApplyStartMeasure_Skip2:
	ld	(13864:16), 131	; F5711C  ld (0x3628),0x83
	ld	(13865:16), 0	; F57121  ld (0x3629),0x00
CyclePlayScreen_ApplyStartMeasure_Return:
	ret	; F57126  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkStartAndEndMeasures
; Called from: in-module: 0xF570CC 0xF570D5 0xF570FD 0xF5715B 0xF57164
;              0xF571E9 0xF571F2 0xF5722B +2 more
; Touches: (0x2652) (0x2654) (0x361E) (0x3620)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57127 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_BlinkStartAndEndMeasures: Stages the CYCLE PLAY start and end measures (0x361E)/(0x3620) into
;   UI_DrawScratch+18/+20 and posts CyclePlayScreen_BlinkStartAndEndMeasureReadouts, which hands both readout records (DL_F34FF2 + 0x19 and + 0x23) to
;   Blink_Command; then Kernel_SemaSignal. The two-field form of CyclePlayScreen_BlinkStartMeasure / _BlinkEndMeasure,
;   run when one bound moved the other (CyclePlayScreen_ApplyStartMeasure, CyclePlayScreen_QueueEndMeasureChange, the
;   step keys). Basis: callers + body + twins. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
CyclePlayScreen_BlinkStartAndEndMeasures:
	ld	wa, (13854:16)	; F57127  ld WA,(0x361e)
	ld	(UI_DrawScratch+18:16), wa	; F5712B  ld (0x2652),WA
	ld	wa, (13856:16)	; F5712F  ld WA,(0x3620)
	ld	(UI_DrawScratch+20:16), wa	; F57133  ld (0x2654),WA
	ld	xwa, CyclePlayScreen_BlinkStartAndEndMeasureReadouts	; F57137  ld XWA,0x00f55fd1
	push	xwa	; F5713C  push XWA
	call	T_CallbackQueue_Post	; F5713D  call 0xf42e84
	inc	4, xsp	; F57141  inc 4,XSP
	ld	a, 1:opc	; F57143  ld A,0x01
	call	T_Kernel_SemaSignal	; F57145  call 0xf42d88
	ret	; F57149  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_IncEndMeasure
; Called from: table 0xF5706A[2]
; Touches: (0x34BB) (0x3620) (0x3628) (0x3629)
; Calls:   T_Blink_Stop CyclePlayScreen_BlinkStartAndEndMeasures
; Evidence: entry [2] of the table at 0xF5706A reads 0x00F5714A, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5714A
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_IncEndMeasure: CyclePlayScreen_FieldIncHandlers[2] (field END MEASURE): while stopped, (0x3620) + 1
;   up to 999, blinks both readouts and sets (0x3628) := 0x83 / (0x3629) as CyclePlayScreen_QueueEndMeasureChange
;   does. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_IncEndMeasure:
	bit	2, (TransportB_State:8)	; F5714A  bit 2,(0x96)
	jr	nz, CyclePlayScreen_IncEndMeasure_Return	; F5714D  jr NZ,0xf5718b
	call	T_Blink_Stop	; F5714F  call 0xf42e24
	cpw	(0x3620:16), 0x03e7	; F57153  cp (0x3620),0x03e7
	jr	c, CyclePlayScreen_IncEndMeasure_Skip	; F57159  jr C,0xf57160
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F5715B  calr 0xf57127
	jr	CyclePlayScreen_IncEndMeasure_Return	; F5715E  jr T,0xf5718b
CyclePlayScreen_IncEndMeasure_Skip:
	incw	1, (13856:16)	; F57160  incw 1,(0x3620)
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F57164  calr 0xf57127
	or	(0x34bb:16), 0x04	; F57167  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F5716C  cp (0x3628),0x00
	jr	z, CyclePlayScreen_IncEndMeasure_Skip2	; F57171  jr Z,0xf57181
	cp	(0x3629:16), 0x02	; F57173  cp (0x3629),0x02
	jr	nz, CyclePlayScreen_IncEndMeasure_Skip2	; F57178  jr NZ,0xf57181
	ld	(13864:16), 131	; F5717A  ld (0x3628),0x83
	jr	CyclePlayScreen_IncEndMeasure_Return	; F5717F  jr T,0xf5718b
CyclePlayScreen_IncEndMeasure_Skip2:
	ld	(13864:16), 131	; F57181  ld (0x3628),0x83
	ld	(13865:16), 1	; F57186  ld (0x3629),0x01
CyclePlayScreen_IncEndMeasure_Return:
	ret	; F5718B  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_DecField
; Called from: in-module: 0xF56ECB 0xF5735D
; Touches: (0x2075) (0x3627)
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5718C is an instruction boundary.
; Shape:   `ld XIX,0x00F571A6 / ld A,(0x3627) / sll 0x02,XWA / add XIX,XWA /
;          ld XIX,(XIX) / call T,XIX` -- entry (0x3627) of that 5-entry table,
;          with NO bound on the index.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; CyclePlayScreen_DecField: CYCLE PLAY / CYCLE PLAY EDIT LCD row 3 RIGHT key (down arrow): sets UI_RequestBits bit 3
;   and calls CyclePlayScreen_FieldDecHandlers[field cursor (0x3627)]. Basis: the table it reads + callers.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_DecField:
	or	(UI_RequestBits:16), 0x08	; F5718C  or (0x2075),0x08
	xor	xwa, xwa	; F57191  xor XWA,XWA
	ld	xix, CyclePlayScreen_FieldDecHandlers	; F57193  ld XIX,0x00f571a6
	ld	a, (13863:16)	; F57198  ld A,(0x3627)
	sll	xwa, 2	; F5719C  sll 0x02,XWA
	add	xix, xwa	; F5719F  add XIX,XWA
	ld	xix, (xix)	; F571A1  ld XIX,(XIX)
	call	(xix)	; F571A3  call T,XIX
	ret	; F571A5  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_FieldDecHandlers -- five 32-bit routine pointers, entered with
;                              `call (XIX)`.
; Read by: 0xF57193: `xor XWA,XWA / ld XIX,0x00F571A6 / ld A,(0x3627) / sll
;          0x02,XWA / add XIX,XWA / ld XIX,(XIX) / call T,XIX` -- entry
;          (0x3627) of this table, UNBOUNDED: nothing here range-checks the
;          byte.  ⚠ THE STATE BYTE IS NOT THE SAME FOR ALL FOUR TABLES:
;          0xF5693F and 0xF56A79 are indexed by (0x36CE), 0xF5706A and
;          0xF571A6 by (0x3627).  This file assumed one byte for all four and
;          --selftest refused it.
; Evidence: the entry count rests on two facts, both re-read on every emit:
;           entry [0] is 0xF571BA, which is the byte immediately AFTER the
;           table, so the table frames itself; and the word at [5] is
;           0xC8360BF1, which is not a 0x00F00000-0x00FFFFFF pointer, while
;           [0]..[4] all are.  Same first-non-pointer rule the 0xF7D000 block
;           used.
; Unknown: what the byte at (0x3627) enumerates.  Nothing decoded here says
;          what its values mean, so the name is FRAMED and no entry is given a
;          name.  ⚠ AND NOTHING BOUNDS IT: a value above 4 would index past
;          the table.  That is what the bytes say; whether the callers
;          guarantee the range is not established here.
; --------------------------------------------------------------------------
; CyclePlayScreen_FieldDecHandlers: CYCLE PLAY (0x14) / CYCLE PLAY EDIT (0x26, 0x29), LCD row 3 RIGHT key (down
;   arrow): steps the field under (0x3627) down -- 0 CYCLE := OFF, 1 START - 1, 2 END - 1, 3 SOLO := OFF; [4] repeats
;   [0]. Basis: table index (field cursor) + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_FieldDecHandlers:
	.long	CyclePlayScreen_SwitchCycleOff	; F571A6  [0] -> CyclePlayScreen_SwitchCycleOff
	.long	CyclePlayScreen_DecStartMeasure	; F571AA  [1] -> CyclePlayScreen_DecStartMeasure
	.long	CyclePlayScreen_DecEndMeasure	; F571AE  [2] -> CyclePlayScreen_DecEndMeasure
	.long	CyclePlayEditScreen_SwitchSoloOff	; F571B2  [3] -> CyclePlayEditScreen_SwitchSoloOff
	.long	CyclePlayScreen_SwitchCycleOff	; F571B6  [4] -> CyclePlayScreen_SwitchCycleOff


; --------------------------------------------------------------------------
; CyclePlayScreen_SwitchCycleOff
; Called from: table 0xF571A6[0], 0xF571A6[4]
; Touches: (0x360B) (0x36C6) (0x36CA) (0x3731)
; Calls:   sub_F5709D
; Evidence: entry [0] of the table at 0xF571A6 reads 0x00F571BA, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF571BA
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_SwitchCycleOff: CyclePlayScreen_FieldDecHandlers[0] (field CYCLE): if on and (0x3731) bit 2 clear,
;   clears the CYCLE PLAY switch (0x360B) bit 0, zeroes (0x36CA)/(0x36C6), repaints OFF/ON -- the steps
;   LcdKeyRow1_SeqPlayScreen uses to switch it off. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_SwitchCycleOff:
	bit	0, (0x360b:16)	; F571BA  bit 0,(0x360b)
	jr	z, CyclePlayScreen_SwitchCycleOff_Return	; F571BE  jr Z,0xf571d7
	bit	2, (0x3731:16)	; F571C0  bit 2,(0x3731)
	jr	nz, CyclePlayScreen_SwitchCycleOff_Return	; F571C4  jr NZ,0xf571d7
	res	0, (0x360b:16)	; F571C6  res 0,(0x360b)
	xor	xwa, xwa	; F571CA  xor XWA,XWA
	ld	(14026:16), xwa	; F571CC  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F571D0  ld (0x36c6),XWA
	calr	sub_F5709D	; F571D4  calr 0xf5709d
CyclePlayScreen_SwitchCycleOff_Return:
	ret	; F571D7  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_DecStartMeasure
; Called from: table 0xF571A6[1]
; Touches: (0x34BB) (0x361E) (0x3628) (0x3629)
; Calls:   T_Blink_Stop CyclePlayScreen_BlinkStartAndEndMeasures
; Evidence: entry [1] of the table at 0xF571A6 reads 0x00F571D8, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF571D8
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_DecStartMeasure: CyclePlayScreen_FieldDecHandlers[1] (field START MEASURE): while stopped, (0x361E)
;   - 1 down to 1, blinks both readouts and sets (0x3628) := 0x83 / (0x3629). Basis: table index + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_DecStartMeasure:
	bit	2, (TransportB_State:8)	; F571D8  bit 2,(0x96)
	jr	nz, CyclePlayScreen_DecStartMeasure_Return	; F571DB  jr NZ,0xf57219
	call	T_Blink_Stop	; F571DD  call 0xf42e24
	cpw	(0x361e:16), 0x0001	; F571E1  cp (0x361e),0x0001
	jr	ugt, CyclePlayScreen_DecStartMeasure_Skip	; F571E7  jr UGT,0xf571ee
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F571E9  calr 0xf57127
	jr	CyclePlayScreen_DecStartMeasure_Return	; F571EC  jr T,0xf57219
CyclePlayScreen_DecStartMeasure_Skip:
	decw	1, (13854:16)	; F571EE  decw 1,(0x361e)
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F571F2  calr 0xf57127
	or	(0x34bb:16), 0x04	; F571F5  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F571FA  cp (0x3628),0x00
	jr	z, CyclePlayScreen_DecStartMeasure_Skip2	; F571FF  jr Z,0xf5720f
	cp	(0x3629:16), 0x02	; F57201  cp (0x3629),0x02
	jr	nz, CyclePlayScreen_DecStartMeasure_Skip2	; F57206  jr NZ,0xf5720f
	ld	(13864:16), 131	; F57208  ld (0x3628),0x83
	jr	CyclePlayScreen_DecStartMeasure_Return	; F5720D  jr T,0xf57219
CyclePlayScreen_DecStartMeasure_Skip2:
	ld	(13864:16), 131	; F5720F  ld (0x3628),0x83
	ld	(13865:16), 0	; F57214  ld (0x3629),0x00
CyclePlayScreen_DecStartMeasure_Return:
	ret	; F57219  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_DecEndMeasure
; Called from: table 0xF571A6[2]
; Touches: (0x3620)
; Calls:   T_Blink_Stop CyclePlayScreen_BlinkStartAndEndMeasures CyclePlayScreen_QueueEndMeasureChange
; Evidence: entry [2] of the table at 0xF571A6 reads 0x00F5721A, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5721A
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_DecEndMeasure: CyclePlayScreen_FieldDecHandlers[2] (field END MEASURE): while stopped, (0x3620) - 1
;   down to 1, blinks both readouts, CyclePlayScreen_QueueEndMeasureChange. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayScreen_DecEndMeasure:
	bit	2, (TransportB_State:8)	; F5721A  bit 2,(0x96)
	jr	nz, CyclePlayScreen_DecEndMeasure_Return	; F5721D  jr NZ,0xf5723a
	call	T_Blink_Stop	; F5721F  call 0xf42e24
	cpw	(0x3620:16), 0x0001	; F57223  cp (0x3620),0x0001
	jr	ugt, CyclePlayScreen_DecEndMeasure_Skip	; F57229  jr UGT,0xf57230
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F5722B  calr 0xf57127
	jr	CyclePlayScreen_DecEndMeasure_Return	; F5722E  jr T,0xf5723a
CyclePlayScreen_DecEndMeasure_Skip:
	decw	1, (13856:16)	; F57230  decw 1,(0x3620)
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F57234  calr 0xf57127
	calr	CyclePlayScreen_QueueEndMeasureChange	; F57237  calr 0xf5723b
CyclePlayScreen_DecEndMeasure_Return:
	ret	; F5723A  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_QueueEndMeasureChange
; Called from: in-module: 0xF56F74 0xF57237
; Touches: (0x34BB) (0x361E) (0x3620) (0x3628) (0x3629)
; Calls:   CyclePlayScreen_BlinkStartAndEndMeasures
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5723B is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayScreen_QueueEndMeasureChange: After the CYCLE PLAY end measure (0x3620) changed: if the start (0x361E) is
;   now later, start := end, (0x3629) := 2 and CyclePlayScreen_BlinkStartAndEndMeasures repaints; else (0x3629) := 1 unless 2 is already pending;
;   (0x3628) := 0x83 arms the deferred Dispatch_3629 step, and (0x34BB) |= 4. Run by NumberPadKey_CyclePlayScreen on
;   field 2 and by the end-measure step-down CyclePlayScreen_DecEndMeasure. Basis: callers + body + dispatcher. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
CyclePlayScreen_QueueEndMeasureChange:
	ld	wa, (13854:16)	; F5723B  ld WA,(0x361e)
	cp	wa, (0x3620:16)	; F5723F  cp WA,(0x3620)
	jr	ule, CyclePlayScreen_QueueEndMeasureChange_Skip	; F57243  jr ULE,0xf57261
	ld	wa, (13856:16)	; F57245  ld WA,(0x3620)
	ld	(13854:16), wa	; F57249  ld (0x361e),WA
	or	(0x34bb:16), 0x04	; F5724D  or (0x34bb),0x04
	ld	(13864:16), 131	; F57252  ld (0x3628),0x83
	ld	(13865:16), 2	; F57257  ld (0x3629),0x02
	calr	CyclePlayScreen_BlinkStartAndEndMeasures	; F5725C  calr 0xf57127
	jr	CyclePlayScreen_QueueEndMeasureChange_Return	; F5725F  jr T,0xf57285
CyclePlayScreen_QueueEndMeasureChange_Skip:
	or	(0x34bb:16), 0x04	; F57261  or (0x34bb),0x04
	cp	(0x3628:16), 0x00	; F57266  cp (0x3628),0x00
	jr	z, CyclePlayScreen_QueueEndMeasureChange_Skip2	; F5726B  jr Z,0xf5727b
	cp	(0x3629:16), 0x02	; F5726D  cp (0x3629),0x02
	jr	nz, CyclePlayScreen_QueueEndMeasureChange_Skip2	; F57272  jr NZ,0xf5727b
	ld	(13864:16), 131	; F57274  ld (0x3628),0x83
	jr	CyclePlayScreen_QueueEndMeasureChange_Return	; F57279  jr T,0xf57285
CyclePlayScreen_QueueEndMeasureChange_Skip2:
	ld	(13864:16), 131	; F5727B  ld (0x3628),0x83
	ld	(13865:16), 1	; F57280  ld (0x3629),0x01
CyclePlayScreen_QueueEndMeasureChange_Return:
	ret	; F57285  ret

; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayEditScreen
; Called from: in-module: 0xF55882 0xF57410
; Touches: (0x207A) (0x207B) (0x207C) (0x207D) (0x2095) (0x360C) (0x361E)
;          (0x3620) (0x3626) (0x3627)
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_NoteRouting_RebuildForSong T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart
;          T_Seq_SetTrackBeatsFromTransportB T_CallbackQueue_Post T_Kernel_SemaSignal CyclePlayScreen_UpdateFieldBlink
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57286 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_CyclePlayEditScreen: the +0 ENTER method of screen 0x26 (thunk T_F40DE0).  Its painter names the screen.
ScreenEnter_CyclePlayEditScreen:
	ld	a, (UI_ScreenLatch:16)	; F57286  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F5728A  cp A,(0x207b)
	jr	nz, ScreenEnter_CyclePlayEditScreen_Skip	; F5728E  jr NZ,0xf572a0
	ld	a, (UI_ScreenId:16)	; F57290  ld A,(0x207c)
	cp	a, (UI_ScreenId_Previous:16)	; F57294  cp A,(0x207d)
	jr	nz, ScreenEnter_CyclePlayEditScreen_Skip5	; F57298  jr NZ,0xf572e9
	bit	4, (UI_ScreenFlags:16)	; F5729A  bit 4,(0x2095)
	jr	nz, ScreenEnter_CyclePlayEditScreen_Skip6	; F5729E  jr NZ,0xf572fb
ScreenEnter_CyclePlayEditScreen_Skip:
	call	T_CallbackQueue_ResetAndRestartTask2	; F572A0  call 0xf42e80
	push	xwa	; F572A4  push XWA
	ld	xwa, (13836:16)	; F572A5  ld XWA,(0x360c)
	cp	(0x3626:16), 0x00	; F572A9  cp (0x3626),0x00
	jr	z, ScreenEnter_CyclePlayEditScreen_Skip2	; F572AE  jr Z,0xf572b5
	ld	xwa, (EditScreen_PartMask:24)	; F572B0  ld XWA,(0x601f01)
ScreenEnter_CyclePlayEditScreen_Skip2:
	ld	(6304798:24), xwa	; F572B5  ld (0x60341e),XWA
	call	T_NoteRouting_RebuildForSong	; F572BA  call 0xf411b8
	pop	xwa	; F572BE  pop XWA
	cp	(0x3627:16), 0x00	; F572BF  cp (0x3627),0x00
	jr	nz, ScreenEnter_CyclePlayEditScreen_Skip3	; F572C4  jr NZ,0xf572cb
	ld	(13863:16), 1	; F572C6  ld (0x3627),0x01
ScreenEnter_CyclePlayEditScreen_Skip3:
	ld	wa, (13854:16)	; F572CB  ld WA,(0x361e)
	cp	wa, (0x3620:16)	; F572CF  cp WA,(0x3620)
	jr	ule, ScreenEnter_CyclePlayEditScreen_Skip4	; F572D3  jr ULE,0xf572dd
	ld	wa, (13854:16)	; F572D5  ld WA,(0x361e)
	ld	(13856:16), wa	; F572D9  ld (0x3620),WA
ScreenEnter_CyclePlayEditScreen_Skip4:
	call	T_SeqCycle_CaptureEndCursors	; F572DD  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F572E1  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F572E5  call 0xf40ac4
ScreenEnter_CyclePlayEditScreen_Skip5:
	ld	xwa, Draw_CyclePlayCurrentMeasureEdit	; F572E9  ld XWA,0x00f55e7d
	push	xwa	; F572EE  push XWA
	call	T_CallbackQueue_Post	; F572EF  call 0xf42e84
	inc	4, xsp	; F572F3  inc 4,XSP
	ld	a, 1:opc	; F572F5  ld A,0x01
	call	T_Kernel_SemaSignal	; F572F7  call 0xf42d88
ScreenEnter_CyclePlayEditScreen_Skip6:
	ld	xwa, CyclePlayEditScreen_DrawValues	; F572FB  ld XWA,0x00f55e8f
	push	xwa	; F57300  push XWA
	call	T_CallbackQueue_Post	; F57301  call 0xf42e84
	inc	4, xsp	; F57305  inc 4,XSP
	ld	a, 1:opc	; F57307  ld A,0x01
	call	T_Kernel_SemaSignal	; F57309  call 0xf42d88
	calr	CyclePlayScreen_UpdateFieldBlink	; F5730D  calr 0xf56e66
	ret	; F57310  ret

; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayEditScreen
; Called from: in-module: 0xF55886 0xF57414
; Touches: (0x207A) (0x207B) (0x3628)
; Calls:   Transport_StopAllAndWaitC T_PartNotes_ReleaseAllTrackNotes T_F41F18 T_NoteRouting_RebuildForSong
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57311 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenLeave_CyclePlayEditScreen: the +4 LEAVE method of screen 0x26 (thunk T_ScreenLeave_CyclePlayEditScreen_Fwd).
ScreenLeave_CyclePlayEditScreen:
	ld	a, (UI_ScreenLatch:16)	; F57311  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F57315  cp A,(0x207b)
	jr	nz, ScreenLeave_CyclePlayEditScreen_Skip	; F57319  jr NZ,0xf5731d
	jr	ScreenLeave_CyclePlayEditScreen_Return	; F5731B  jr T,0xf57336
ScreenLeave_CyclePlayEditScreen_Skip:
	ld	(13864:16), 0	; F5731D  ld (0x3628),0x00
	bit	2, (TransportB_State:8)	; F57322  bit 2,(0x96)
	jr	z, ScreenLeave_CyclePlayEditScreen_Skip2	; F57325  jr Z,0xf57332
	calr	Transport_StopAllAndWaitC	; F57327  calr 0xf56579
	call	T_PartNotes_ReleaseAllTrackNotes	; F5732A  call 0xf413c8
	call	T_F41F18	; F5732E  call 0xf41f18
ScreenLeave_CyclePlayEditScreen_Skip2:
	call	T_NoteRouting_RebuildForSong	; F57332  call 0xf411b8
ScreenLeave_CyclePlayEditScreen_Return:
	ret	; F57336  ret

; --------------------------------------------------------------------------
; Nop_Ret_F57337
; Called from: table 0xF55B2E[0], 0xF55B2E[1], 0xF55B2E[2], 0xF55B2E[3],
;              0xF55B2E[4], 0xF55B2E[5] +2 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the table at 0xF55B2E reads 0x00F57337, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF57337
;           is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57337:
	ret	; F57337  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_CyclePlayEditScreen
; Called from: table 0xF55B2E[8]; in-module: 0xF57419
; Touches: (0x3628)
; Calls:   CyclePlayEdit_StopAndLeave
; Evidence: entry [8] of the table at 0xF55B2E reads 0x00F57338, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF57338
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_CyclePlayEditScreen: ScreenButtons_CyclePlayEditScreen[8] -- the LcdKeyRow1 handler of CyclePlayEditScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow1_CyclePlayEditScreen:
	bit	7, w	; F57338  bit 0x07,W
	jr	nz, LcdKeyRow1_CyclePlayEditScreen_Return	; F5733B  jr NZ,0xf57349
	cp	(0x3628:16), 0x00	; F5733D  cp (0x3628),0x00
	jr	nz, LcdKeyRow1_CyclePlayEditScreen_Return	; F57342  jr NZ,0xf57349
	calr	CyclePlayEdit_StopAndLeave	; F57344  calr 0xf57382
	jr	LcdKeyRow1_CyclePlayEditScreen_Return	; F57347  jr T,0xf57349
LcdKeyRow1_CyclePlayEditScreen_Return:
	ret	; F57349  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayEditScreen
; Called from: table 0xF55B2E[9]; in-module: 0xF5741D
; Touches: nothing with an absolute address
; Calls:   CyclePlayScreen_IncField CyclePlayEditScreen_LcdKeyRow2
; Evidence: entry [9] of the table at 0xF55B2E reads 0x00F5734A, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5734A
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayEditScreen: ScreenButtons_CyclePlayEditScreen[9] -- the LcdKeyRow2 handler of CyclePlayEditScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_CyclePlayEditScreen:
	bit	7, w	; F5734A  bit 0x07,W
	jr	nz, LcdKeyRow2_CyclePlayEditScreen_Skip	; F5734D  jr NZ,0xf57354
	calr	CyclePlayScreen_IncField	; F5734F  calr 0xf57050
	jr	LcdKeyRow2_CyclePlayEditScreen_Return	; F57352  jr T,0xf57357
LcdKeyRow2_CyclePlayEditScreen_Skip:
	calr	CyclePlayEditScreen_LcdKeyRow2	; F57354  calr 0xf5739c
LcdKeyRow2_CyclePlayEditScreen_Return:
	ret	; F57357  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayEditScreen
; Called from: table 0xF55B2E[10]; in-module: 0xF57421
; Touches: nothing with an absolute address
; Calls:   CyclePlayScreen_DecField CyclePlayScreen_LcdKeyRow3
; Evidence: entry [10] of the table at 0xF55B2E reads 0x00F57358, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57358 is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayEditScreen: ScreenButtons_CyclePlayEditScreen[10] -- the LcdKeyRow3 handler of CyclePlayEditScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_CyclePlayEditScreen:
	bit	7, w	; F57358  bit 0x07,W
	jr	nz, LcdKeyRow3_CyclePlayEditScreen_Skip	; F5735B  jr NZ,0xf57362
	calr	CyclePlayScreen_DecField	; F5735D  calr 0xf5718c
	jr	LcdKeyRow3_CyclePlayEditScreen_Return	; F57360  jr T,0xf57365
LcdKeyRow3_CyclePlayEditScreen_Skip:
	calr	CyclePlayScreen_LcdKeyRow3	; F57362  calr 0xf57014
LcdKeyRow3_CyclePlayEditScreen_Return:
	ret	; F57365  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayEditScreen
; Called from: table 0xF55B2E[11]; in-module: 0xF57425
; Touches: nothing with an absolute address
; Calls:   LcdKeyRow4_CyclePlayScreen
; Evidence: entry [11] of the table at 0xF55B2E reads 0x00F57366, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57366 is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF56ED4` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayEditScreen: ScreenButtons_CyclePlayEditScreen[11] -- the LcdKeyRow4 handler of CyclePlayEditScreen (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow4_CyclePlayEditScreen:
	calr	LcdKeyRow4_CyclePlayScreen	; F57366  calr 0xf56ed4
	ret	; F57369  ret

; --------------------------------------------------------------------------
; Nop_Ret_F5736A
; Called from: table 0xF55B2E[12], 0xF55B2E[13], 0xF55B2E[14]
; Touches: nothing with an absolute address
; Evidence: entry [12] of the table at 0xF55B2E reads 0x00F5736A, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5736A is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F5736A:
	ret	; F5736A  ret

; --------------------------------------------------------------------------
; ExitKey_CyclePlayEditScreen
; Called from: table 0xF55B2E[15]; in-module: 0xF5742A
; Touches: (0x3628)
; Calls:   CyclePlayEdit_StopAndLeave
; Evidence: entry [15] of the table at 0xF55B2E reads 0x00F5736B, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5736B is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_CyclePlayEditScreen: ScreenButtons_CyclePlayEditScreen[15] -- the ExitKey handler of CyclePlayEditScreen (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_CyclePlayEditScreen:
	bit	7, w	; F5736B  bit 0x07,W
	jr	nz, ExitKey_CyclePlayEditScreen_Return	; F5736E  jr NZ,0xf5737c
	cp	(0x3628:16), 0x00	; F57370  cp (0x3628),0x00
	jr	nz, ExitKey_CyclePlayEditScreen_Return	; F57375  jr NZ,0xf5737c
	calr	CyclePlayEdit_StopAndLeave	; F57377  calr 0xf57382
	jr	ExitKey_CyclePlayEditScreen_Return	; F5737A  jr T,0xf5737c
ExitKey_CyclePlayEditScreen_Return:
	ret	; F5737C  ret

; --------------------------------------------------------------------------
; Fwd_F5737D
; Called from: table 0xF55B2E[27]; in-module: 0xF5742E
; Touches: nothing with an absolute address
; Calls:   NumberPadKey_CyclePlayScreen
; Evidence: entry [27] of the table at 0xF55B2E reads 0x00F5737D, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5737D is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF56F09` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F5737D:
	calr	NumberPadKey_CyclePlayScreen	; F5737D  calr 0xf56f09
	ret	; F57380  ret

; --------------------------------------------------------------------------
; Nop_Ret_F57381
; Called from: table 0xF55B2E[16], 0xF55B2E[17], 0xF55B2E[18], 0xF55B2E[19],
;              0xF55B2E[20], 0xF55B2E[21] +9 more; in-module: 0xF55894
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF55B2E reads 0x00F57381, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57381 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57381:
	ret	; F57381  ret

; --------------------------------------------------------------------------
; CyclePlayEdit_StopAndLeave
; Called from: in-module: 0xF57344 0xF57377
; Touches: (0x2070) (0x207C)
; Calls:   T_Transport_StopAllRunning
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57382 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayEdit_StopAndLeave: T_Transport_StopAllRunning, then UI_Request = 0x8025 when UI_ScreenId is 0x26, else 0x8028 (high byte 0x80 = go to
;   screen); called from ExitKey_CyclePlayEditScreen and LcdKeyRow1_CyclePlayEditScreen.  Basis: callers + body.
CyclePlayEdit_StopAndLeave:
	call	T_Transport_StopAllRunning	; F57382  call 0xf409ac
	cp	(UI_ScreenId:16), 0x26	; F57386  cp (0x207c),0x26
	jr	z, CyclePlayEdit_StopAndLeave_Skip	; F5738B  jr Z,0xf57395
	ldw	(UI_Request:16), 32808	; F5738D  ld (0x2070),0x8028
	jr	CyclePlayEdit_StopAndLeave_Return	; F57393  jr T,0xf5739b
CyclePlayEdit_StopAndLeave_Skip:
	ldw	(UI_Request:16), 32805	; F57395  ld (0x2070),0x8025
CyclePlayEdit_StopAndLeave_Return:
	ret	; F5739B  ret

; --------------------------------------------------------------------------
; CyclePlayEditScreen_LcdKeyRow2
; Called from: in-module: 0xF57354
; Touches: (0x2095) (0x3627) (0x3628) (0x3756)
; Calls:   T_Blink_Stop
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF5739C is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayEditScreen_LcdKeyRow2: the LcdKeyRow2 action of CyclePlayEditScreen -- called only by LcdKeyRow2_CyclePlayEditScreen.
CyclePlayEditScreen_LcdKeyRow2:
	cp	(0x3628:16), 0x00	; F5739C  cp (0x3628),0x00
	jr	nz, CyclePlayEditScreen_LcdKeyRow2_Return	; F573A1  jr NZ,0xf573b9
	ld	a, (13863:16)	; F573A3  ld A,(0x3627)
	ld	(14166:16), a	; F573A7  ld (0x3756),A
	ld	(13863:16), 3	; F573AB  ld (0x3627),0x03
	call	T_Blink_Stop	; F573B0  call 0xf42e24
	or	(UI_ScreenFlags:16), 0x10	; F573B4  or (0x2095),0x10
CyclePlayEditScreen_LcdKeyRow2_Return:
	ret	; F573B9  ret

; --------------------------------------------------------------------------
; CyclePlayEditScreen_SwitchSoloOn
; Called from: table 0xF5706A[3]
; Touches: (0x3626)
; Calls:   T_NoteRouting_RebuildForSong sub_F573D8
; Evidence: entry [3] of the table at 0xF5706A reads 0x00F573BA, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF573BA
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayEditScreen_SwitchSoloOn: CyclePlayScreen_FieldIncHandlers[3] (CYCLE PLAY EDIT field SOLO): if off, (0x3626)
;   := 1, routes notes by EditScreen_PartMask ((0x60341E)), NoteRouting_RebuildForSong, repaints the SOLO OFF/ON
;   readout. Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayEditScreen_SwitchSoloOn:
	cp	(0x3626:16), 0x01	; F573BA  cp (0x3626),0x01
	jr	z, CyclePlayEditScreen_SwitchSoloOn_Return2	; F573BF  jr Z,0xf573d7
	ld	(13862:16), 1	; F573C1  ld (0x3626),0x01
	ld	xwa, (EditScreen_PartMask:24)	; F573C6  ld XWA,(0x601f01)
	ld	(6304798:24), xwa	; F573CB  ld (0x60341e),XWA
	call	T_NoteRouting_RebuildForSong	; F573D0  call 0xf411b8
	calr	sub_F573D8	; F573D4  calr 0xf573d8
CyclePlayEditScreen_SwitchSoloOn_Return2:
	ret	; F573D7  ret

; --------------------------------------------------------------------------
; sub_F573D8
; Called from: in-module: 0xF573D4 0xF5740C
; Touches: (0x1308) (0x3626)
; Calls:   T_CallbackQueue_Post T_Kernel_SemaSignal
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF573D8 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F573D8:
	ld	a, (13862:16)	; F573D8  ld A,(0x3626)
	ld	(DisplayListB_Stage+18:16), a	; F573DC  ld (0x1308),A
	ld	xwa, sub_F55FEF	; F573E0  ld XWA,0x00f55fef
	push	xwa	; F573E5  push XWA
	call	T_CallbackQueue_Post	; F573E6  call 0xf42e84
	inc	4, xsp	; F573EA  inc 4,XSP
	ld	a, 1:opc	; F573EC  ld A,0x01
	call	T_Kernel_SemaSignal	; F573EE  call 0xf42d88
	ret	; F573F2  ret

; --------------------------------------------------------------------------
; CyclePlayEditScreen_SwitchSoloOff
; Called from: table 0xF571A6[3]
; Touches: (0x360C) (0x3626)
; Calls:   T_NoteRouting_RebuildForSong sub_F573D8
; Evidence: entry [3] of the table at 0xF571A6 reads 0x00F573F3, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF573F3
;           is an instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CyclePlayEditScreen_SwitchSoloOff: CyclePlayScreen_FieldDecHandlers[3] (CYCLE PLAY EDIT field SOLO): if on, (0x3626)
;   := 0, routes notes by the saved track mask (0x360C), NoteRouting_RebuildForSong, repaints the SOLO OFF/ON readout.
;   Basis: table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
CyclePlayEditScreen_SwitchSoloOff:
	cp	(0x3626:16), 0x00	; F573F3  cp (0x3626),0x00
	jr	z, sub_F573D8_Return	; F573F8  jr Z,0xf5740f
	ld	(13862:16), 0	; F573FA  ld (0x3626),0x00
	ld	xwa, (13836:16)	; F573FF  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F57403  ld (0x60341e),XWA
	call	T_NoteRouting_RebuildForSong	; F57408  call 0xf411b8
	calr	sub_F573D8	; F5740C  calr 0xf573d8
sub_F573D8_Return:
	ret	; F5740F  ret

; --------------------------------------------------------------------------
; Fwd_F57410
; Called from: in-module: 0xF55898
; Touches: nothing with an absolute address
; Calls:   ScreenEnter_CyclePlayEditScreen
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57410 is an instruction boundary.
; Shape:   `calr`/`call 0xF57286` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F57410:
	calr	ScreenEnter_CyclePlayEditScreen	; F57410  calr 0xf57286
	ret	; F57413  ret

; --------------------------------------------------------------------------
; Fwd_F57414
; Called from: in-module: 0xF5589C
; Touches: nothing with an absolute address
; Calls:   ScreenLeave_CyclePlayEditScreen
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57414 is an instruction boundary.
; Shape:   `calr`/`call 0xF57311` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F57414:
	calr	ScreenLeave_CyclePlayEditScreen	; F57414  calr 0xf57311
	ret	; F57417  ret

; --------------------------------------------------------------------------
; Nop_Ret_F57418
; Called from: table 0xF55BAE[0], 0xF55BAE[1], 0xF55BAE[2], 0xF55BAE[3],
;              0xF55BAE[4], 0xF55BAE[5] +2 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the table at 0xF55BAE reads 0x00F57418, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF57418
;           is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57418:
	ret	; F57418  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_CyclePlayEditScreen29
; Called from: table 0xF55BAE[8]
; Touches: nothing with an absolute address
; Calls:   LcdKeyRow1_CyclePlayEditScreen
; Evidence: entry [8] of the table at 0xF55BAE reads 0x00F57419, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF57419
;           is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF57338` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; LcdKeyRow1_CyclePlayEditScreen29: ScreenButtons_CyclePlayEditScreen29[8] -- the LcdKeyRow1 handler of CyclePlayEditScreen29 (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow1_CyclePlayEditScreen29:
	calr	LcdKeyRow1_CyclePlayEditScreen	; F57419  calr 0xf57338
	ret	; F5741C  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayEditScreen29
; Called from: table 0xF55BAE[9]
; Touches: nothing with an absolute address
; Calls:   LcdKeyRow2_CyclePlayEditScreen
; Evidence: entry [9] of the table at 0xF55BAE reads 0x00F5741D, that table is
;           entered with `call XIX` after a bounds-checked index, and 0xF5741D
;           is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF5734A` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; LcdKeyRow2_CyclePlayEditScreen29: ScreenButtons_CyclePlayEditScreen29[9] -- the LcdKeyRow2 handler of CyclePlayEditScreen29 (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow2_CyclePlayEditScreen29:
	calr	LcdKeyRow2_CyclePlayEditScreen	; F5741D  calr 0xf5734a
	ret	; F57420  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayEditScreen29
; Called from: table 0xF55BAE[10]
; Touches: nothing with an absolute address
; Calls:   LcdKeyRow3_CyclePlayEditScreen
; Evidence: entry [10] of the table at 0xF55BAE reads 0x00F57421, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57421 is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF57358` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; LcdKeyRow3_CyclePlayEditScreen29: ScreenButtons_CyclePlayEditScreen29[10] -- the LcdKeyRow3 handler of CyclePlayEditScreen29 (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow3_CyclePlayEditScreen29:
	calr	LcdKeyRow3_CyclePlayEditScreen	; F57421  calr 0xf57358
	ret	; F57424  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayEditScreen29
; Called from: table 0xF55BAE[11]
; Touches: nothing with an absolute address
; Calls:   LcdKeyRow4_CyclePlayEditScreen
; Evidence: entry [11] of the table at 0xF55BAE reads 0x00F57425, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57425 is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF57366` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; LcdKeyRow4_CyclePlayEditScreen29: ScreenButtons_CyclePlayEditScreen29[11] -- the LcdKeyRow4 handler of CyclePlayEditScreen29 (notes/prom_b_sequencer_screen_buttons.py).
LcdKeyRow4_CyclePlayEditScreen29:
	calr	LcdKeyRow4_CyclePlayEditScreen	; F57425  calr 0xf57366
	ret	; F57428  ret

; --------------------------------------------------------------------------
; Nop_Ret_F57429
; Called from: table 0xF55BAE[12], 0xF55BAE[13], 0xF55BAE[14]
; Touches: nothing with an absolute address
; Evidence: entry [12] of the table at 0xF55BAE reads 0x00F57429, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57429 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57429:
	ret	; F57429  ret

; --------------------------------------------------------------------------
; ExitKey_CyclePlayEditScreen29
; Called from: table 0xF55BAE[15]
; Touches: nothing with an absolute address
; Calls:   ExitKey_CyclePlayEditScreen
; Evidence: entry [15] of the table at 0xF55BAE reads 0x00F5742A, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5742A is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF5736B` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
; ExitKey_CyclePlayEditScreen29: ScreenButtons_CyclePlayEditScreen29[15] -- the ExitKey handler of CyclePlayEditScreen29 (notes/prom_b_sequencer_screen_buttons.py).
ExitKey_CyclePlayEditScreen29:
	calr	ExitKey_CyclePlayEditScreen	; F5742A  calr 0xf5736b
	ret	; F5742D  ret

; --------------------------------------------------------------------------
; Fwd_F5742E
; Called from: table 0xF55BAE[27]
; Touches: nothing with an absolute address
; Calls:   Fwd_F5737D
; Evidence: entry [27] of the table at 0xF55BAE reads 0x00F5742E, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF5742E is an instruction boundary of this transcription.
; Shape:   `calr`/`call 0xF5737D` then `ret` -- a one-instruction forwarder,
;          the shape of a linker veneer.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Fwd_F5742E:
	calr	Fwd_F5737D	; F5742E  calr 0xf5737d
	ret	; F57431  ret

; --------------------------------------------------------------------------
; Nop_Ret_F57432
; Called from: table 0xF55BAE[16], 0xF55BAE[17], 0xF55BAE[18], 0xF55BAE[19],
;              0xF55BAE[20], 0xF55BAE[21] +9 more; in-module: 0xF558AA
; Touches: nothing with an absolute address
; Evidence: entry [16] of the table at 0xF55BAE reads 0x00F57432, that table
;           is entered with `call XIX` after a bounds-checked index, and
;           0xF57432 is an instruction boundary of this transcription.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57432:
	ret	; F57432  ret

; --------------------------------------------------------------------------
; Seq_RestorePlayingTrackMask
; Called from: in-module: 0xF56030 0xF56B5F
; Touches: (0x360C)
; Calls:   T_NoteRouting_RebuildForSong
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57433 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RestorePlayingTrackMask: Playing-track mask (0x60341E) := (0x360C), its saved copy, then
;   T_NoteRouting_RebuildForSong. The ENTER of panel modes SEQ PLAY and REALTIME RECORD; twin Seq_SavePlayingTrackMask
;   (Seq_SavePlayingTrackMask, batch f) copies it back on the mode LEAVEs. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
Seq_RestorePlayingTrackMask:
	push	xwa	; F57433  push XWA
	ld	xwa, (13836:16)	; F57434  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F57438  ld (0x60341e),XWA
	pop	xwa	; F5743D  pop XWA
	call	T_NoteRouting_RebuildForSong	; F5743E  call 0xf411b8
	ret	; F57442  ret

; --------------------------------------------------------------------------
; Seq_SavePlayingTrackMask
; Called from: in-module: 0xF5604F 0xF56B71
; Touches: (0x360C)
; Calls:   T_NoteRouting_RebuildForSong
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57443 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_SavePlayingTrackMask: (0x360C) := the playing-track mask (0x60341E), 32-bit, then NoteRouting_RebuildForSong.
;   Called by the LEAVE methods of panel modes 5 and 8; its twin Seq_RestorePlayingTrackMask copies (0x360C) back on their ENTER
;   methods. Basis: callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
Seq_SavePlayingTrackMask:
	push	xwa	; F57443  push XWA
	ld	xwa, (6304798:24)	; F57444  ld XWA,(0x60341e)
	ld	(13836:16), xwa	; F57449  ld (0x360c),XWA
	pop	xwa	; F5744D  pop XWA
	call	T_NoteRouting_RebuildForSong	; F5744E  call 0xf411b8
	ret	; F57452  ret

; ==========================================================================
; 0xF57453-0xF57572 -- FIVE SCREEN "STAGE VALUES" ROUTINES (converted 2026-09-25, lane promb)
;
; ⚠ CORRECTED 2026-09-25.  These 288 bytes used to be one `.byte` block,
; `Unclaimed_F57453`, whose header read: "Nothing in either image references
; any address inside them ... no 32-bit little-endian spelling of any address
; in 0xF57453-0xF57571 occurs anywhere in prom_a or prom_b" and "Unknown: who
; calls any of it."  The 32-bit census was right and the conclusion was not:
; FIVE PC-RELATIVE `calr` sites in this very module land on the five routine
; starts below -- 0xF55C8C (already spelled `calr Unclaimed_F57453`),
; 0xF55D3D, 0xF55E8F, 0xF55EEA and 0xF55F45.  A `calr` holds a 16-bit
; displacement, which no 32-bit search can see (notes/lanes/BRIEF-2026-09-01.md,
; "NO READER HAS NOW BEEN WRONG THREE TIMES, THE SAME WAY" -- this is a fourth).
;
; Framing evidence: MAME unidasm's linear sweep and llvm-mc agree on every
; instruction; each routine is `push ...` / loads and stores / `pop ...` /
; `ret`, each `ret` is followed immediately by the next routine's `push WA`
; (0x28), and every call target is an instruction start.  The last `ret`
; is 0xF57572 -- the byte the old listing counted as the first byte of the
; 0x0E padding.
;
; WHAT THEY DO, and how it is known.  Each caller is the "values" arm of one
; sequencer screen: it calls its routine here, then runs one interpreter-B
; display list with `call T_DisplayListB_Run`.  Each routine copies firmware
; state into RAM cells, and the cells it writes are EXACTLY the `+0x02` source
; variables of the records of the display list its caller runs next -- no
; more, no fewer (python3 notes/promb-2026-09-25/stage_values_probe.py):
;
;   routine                            caller   list its caller runs      cells
;   SeqPlayScreen_StageValues          F55C8C   DL_CycleMasterS0ngMeasureTimeSig   6/6
;   RealtimeRecordScreen_StageValues   F55D3D   RealtimeRecordScreen_DrawValues_DL .. 0xF343B6              7/7
;   CyclePlayScreen_StageValues        F55EEA   DL_F34FF2 .. Data_F35035           5/5
;   CyclePlayEditScreen_StageValues    F55E8F   DL_F352F9 .. DLText_OffOn_F3533C           5/5
;   CycleRecordScreen_StageValues      F55F45   CycleRecordScreen_DrawValues_DL .. Data_F351F9           6/6
;
; The screen names are those of the CAPTION list the same screen's other arm
; runs (DL_SequencerPlayS0ngCycleMeasure, DL_RealtimeRecordSongMeasure..., 
; DL_CyclePlayCurrentMeasureCycle, DL_CyclePlayCurrentMeasureEdit,
; DL_CycleRecordCurrentMeasure), which earlier rounds named from their own text.
; Which firmware variable each SOURCE cell is (0x3552, 0x0DE3, 0x360A, ...) is
; read off the caption whose field its display record fills, and is stated per
; routine as a reading of the screen, not as a name for the RAM cell.
; ==========================================================================

; --------------------------------------------------------------------------
; SeqPlayScreen_StageValues
; Called from: 0xF55C8C (`calr`), the values arm of the screen whose captions
;          are DL_SequencerPlayS0ngCycleMeasure; that arm then runs
;          DL_CycleMasterS0ngMeasureTimeSig with DisplayListB_Run.
; Writes:  (0x2644) <- word (0x3552)      read at the "MEASURE =" field
;          (0x2646) <- (0x0DE3)           read at the "TIME SIG.=" field
;          (0x2647) <- (0x360B) AND 1     the "CYCLE:" OFF/ON string index
;          (0x1309) <- (0x3752)           the "MASTER:" string index
;          (0x264B) <- (0x360A) + 1       the two-digit number after "S0NG"
;          (0x264C..0x2651) <- 6 bytes from 0x006034CA, printed as a 6-byte
;                    string right after that number (`ldir` of 3 words)
; Preserves: XIX, XIY, WA, BC.
; Evidence: the six destinations are exactly the six source variables of
;          DL_CycleMasterS0ngMeasureTimeSig's six records.
; --------------------------------------------------------------------------
SeqPlayScreen_StageValues:
	push	xix	; F57453  push XIX
	push	xiy	; F57454  push XIY
	pushw	wa	; F57455  push WA
	pushw	bc	; F57456  push BC
	ld	wa, (13650:16)	; F57457  ld WA,(0x3552)
	ld	(UI_DrawScratch+4:16), wa	; F5745B  ld (0x2644),WA
	ld	a, (3555:16)	; F5745F  ld A,(0x0de3)
	ld	(UI_DrawScratch+6:16), a	; F57463  ld (0x2646),A
	ld	a, (13835:16)	; F57467  ld A,(0x360b)
	and	a, 1	; F5746B  and A,0x01
	ld	(UI_DrawScratch+7:16), a	; F5746E  ld (0x2647),A
	ld	a, (14162:16)	; F57472  ld A,(0x3752)
	ld	(DisplayListB_Stage+19:16), a	; F57476  ld (0x1309),A
	ld	a, (BStore_CurrentBank:16)	; F5747A  ld A,(0x360a)
	inc	1, a	; F5747E  inc 1,A
	ld	(UI_DrawScratch+11:16), a	; F57480  ld (0x264b),A
	ldw	bc, 3	; F57484  ld BC,0x0003
	ld	xix, UI_DrawScratch+12	; F57487  ld XIX,0x0000264c
	ld	xiy, BStore_SongName	; F5748C  ld XIY,0x006034ca
	ldirw	; F57491  ldirw
	popw	bc	; F57493  pop BC
	popw	wa	; F57494  pop WA
	pop	xiy	; F57495  pop XIY
	pop	xix	; F57496  pop XIX
	ret	; F57497  ret

; --------------------------------------------------------------------------
; RealtimeRecordScreen_StageValues
; Called from: 0xF55D3D (`calr`), the values arm of the screen whose captions
;          are DL_RealtimeRecordSongMeasureQuantiTimeSigMasterCycle; that arm
;          then runs DisplayListB_Run from RealtimeRecordScreen_DrawValues_DL to 0xF343B6 (RealtimeRecordScreen_DrawValues_DL,
;          DL_MasterSongMeasure, DL_TimeSig).
; Writes:  (0x2644) <- word (0x3552)      (0x2646) <- (0x0DE3)
;          (0x2647) <- ((0x360B) AND 2) >> 1
;          (0x2648) <- (0x34D9) AND 1     (0x2649) <- word (0x0C08)
;          (0x1309) <- (0x3752)           (0x264B) <- (0x360A) + 1
; Preserves: WA.
; Evidence: the seven destinations are exactly the seven source variables of
;          the seven records from RealtimeRecordScreen_DrawValues_DL to 0xF343B6.
; --------------------------------------------------------------------------
RealtimeRecordScreen_StageValues:
	pushw	wa	; F57498  push WA
	ld	wa, (13650:16)	; F57499  ld WA,(0x3552)
	ld	(UI_DrawScratch+4:16), wa	; F5749D  ld (0x2644),WA
	ld	a, (3555:16)	; F574A1  ld A,(0x0de3)
	ld	(UI_DrawScratch+6:16), a	; F574A5  ld (0x2646),A
	ld	a, (13835:16)	; F574A9  ld A,(0x360b)
	and	a, 2	; F574AD  and A,0x02
	srl	a, 1	; F574B0  srl 0x01,A
	ld	(UI_DrawScratch+7:16), a	; F574B3  ld (0x2647),A
	ld	a, (13529:16)	; F574B7  ld A,(0x34d9)
	and	a, 1	; F574BB  and A,0x01
	ld	(UI_DrawScratch+8:16), a	; F574BE  ld (0x2648),A
	ld	wa, (3080:16)	; F574C2  ld WA,(0x0c08)
	ld	(UI_DrawScratch+9:16), wa	; F574C6  ld (0x2649),WA
	ld	a, (14162:16)	; F574CA  ld A,(0x3752)
	ld	(DisplayListB_Stage+19:16), a	; F574CE  ld (0x1309),A
	ld	a, (BStore_CurrentBank:16)	; F574D2  ld A,(0x360a)
	inc	1, a	; F574D6  inc 1,A
	ld	(UI_DrawScratch+11:16), a	; F574D8  ld (0x264b),A
	popw	wa	; F574DC  pop WA
	ret	; F574DD  ret

; --------------------------------------------------------------------------
; CyclePlayScreen_StageValues
; Called from: 0xF55EEA (`calr`), the values arm of the screen whose captions
;          are DL_CyclePlayCurrentMeasureCycle; that arm then runs
;          DisplayListB_Run from DL_F34FF2 to Data_F35035.
; Writes:  (0x12F6) <- (0x3627)           (0x2644) <- word (0x3552)
;          (0x2647) <- (0x360B) AND 1
;          (0x2652) <- word (0x361E)      (0x2654) <- word (0x3620)
; Preserves: WA.
; Evidence: the five destinations are exactly the five distinct source
;          variables of DL_F34FF2's six records (two read 0x12F6).
; --------------------------------------------------------------------------
CyclePlayScreen_StageValues:
	pushw	wa	; F574DE  push WA
	ld	a, (13863:16)	; F574DF  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F574E3  ld (0x12f6),A
	ld	wa, (13650:16)	; F574E7  ld WA,(0x3552)
	ld	(UI_DrawScratch+4:16), wa	; F574EB  ld (0x2644),WA
	ld	a, (13835:16)	; F574EF  ld A,(0x360b)
	and	a, 1	; F574F3  and A,0x01
	ld	(UI_DrawScratch+7:16), a	; F574F6  ld (0x2647),A
	ld	wa, (13854:16)	; F574FA  ld WA,(0x361e)
	ld	(UI_DrawScratch+18:16), wa	; F574FE  ld (0x2652),WA
	ld	wa, (13856:16)	; F57502  ld WA,(0x3620)
	ld	(UI_DrawScratch+20:16), wa	; F57506  ld (0x2654),WA
	popw	wa	; F5750A  pop WA
	ret	; F5750B  ret

; --------------------------------------------------------------------------
; CyclePlayEditScreen_StageValues
; Called from: 0xF55E8F (`calr`), the values arm of the screen whose captions
;          are DL_CyclePlayCurrentMeasureEdit; that arm then runs
;          DisplayListB_Run from DL_F352F9 to DLText_OffOn_F3533C.
; Writes:  (0x12F6) <- (0x3627)           (0x2644) <- word (0x3552)
;          (0x2652) <- word (0x361E)      (0x2654) <- word (0x3620)
;          (0x1308) <- (0x3626)
; Preserves: WA.
; Evidence: the five destinations are exactly the five distinct source
;          variables of DL_F352F9's six records (two read 0x12F6).
; --------------------------------------------------------------------------
CyclePlayEditScreen_StageValues:
	pushw	wa	; F5750C  push WA
	ld	a, (13863:16)	; F5750D  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F57511  ld (0x12f6),A
	ld	wa, (13650:16)	; F57515  ld WA,(0x3552)
	ld	(UI_DrawScratch+4:16), wa	; F57519  ld (0x2644),WA
	ld	wa, (13854:16)	; F5751D  ld WA,(0x361e)
	ld	(UI_DrawScratch+18:16), wa	; F57521  ld (0x2652),WA
	ld	wa, (13856:16)	; F57525  ld WA,(0x3620)
	ld	(UI_DrawScratch+20:16), wa	; F57529  ld (0x2654),WA
	ld	a, (13862:16)	; F5752D  ld A,(0x3626)
	ld	(DisplayListB_Stage+18:16), a	; F57531  ld (0x1308),A
	popw	wa	; F57535  pop WA
	ret	; F57536  ret

; --------------------------------------------------------------------------
; CycleRecordScreen_StageValues
; Called from: 0xF55F45 (`calr`), the values arm of the screen whose captions
;          are DL_CycleRecordCurrentMeasure; that arm then runs
;          DisplayListB_Run from CycleRecordScreen_DrawValues_DL to Data_F351F9.
; Writes:  (0x12F6) <- (0x3627)           (0x2644) <- word (0x3552)
;          (0x2647) <- ((0x360B) AND 2) >> 1
;          (0x2648) <- (0x34D9) AND 1
;          (0x2656) <- word (0x3622)      (0x2658) <- word (0x3624)
; Preserves: WA.
; Evidence: the six destinations are exactly the six distinct source
;          variables of CycleRecordScreen_DrawValues_DL's seven records (two read 0x12F6).
; --------------------------------------------------------------------------
CycleRecordScreen_StageValues:
	pushw	wa	; F57537  push WA
	ld	a, (13863:16)	; F57538  ld A,(0x3627)
	ld	(DisplayListB_Stage:16), a	; F5753C  ld (0x12f6),A
	ld	wa, (13650:16)	; F57540  ld WA,(0x3552)
	ld	(UI_DrawScratch+4:16), wa	; F57544  ld (0x2644),WA
	ld	a, (13835:16)	; F57548  ld A,(0x360b)
	and	a, 2	; F5754C  and A,0x02
	srl	a, 1	; F5754F  srl 0x01,A
	ld	(UI_DrawScratch+7:16), a	; F57552  ld (0x2647),A
	ld	a, (13529:16)	; F57556  ld A,(0x34d9)
	and	a, 1	; F5755A  and A,0x01
	ld	(UI_DrawScratch+8:16), a	; F5755D  ld (0x2648),A
	ld	wa, (13858:16)	; F57561  ld WA,(0x3622)
	ld	(UI_DrawScratch+22:16), wa	; F57565  ld (0x2656),WA
	ld	wa, (13860:16)	; F57569  ld WA,(0x3624)
	ld	(UI_DrawScratch+24:16), wa	; F5756D  ld (0x2658),WA
	popw	wa	; F57571  pop WA
	ret	; F57572  ret  (the first 0x0E the old listing counted as padding)

	.fill	1677, 1, 0x0E	; F57573-F57BFF  `ret` padding (asserted pure 0x0E)
