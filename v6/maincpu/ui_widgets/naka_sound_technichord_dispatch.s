// Sound menu / TechniChord dispatch data
// Extracted from kn5000_v10_program.s
// Contains: Sound menu NAKA widgets (scrollbars, list boxes, page controls),
// NakaMenuItem entries (PartSetting, Mixer, MasterTuning, KeyScaling,
// ReverbEqPresets, Reverb, Equalizer, DspEffect, AcousticIllusion,
// LeftHold, TechniChord), SoundEdit widget, and associated string data.

; Tail of the NAKA record whose header (naka_header type 0x25) is at 0xE818E6,
; in the previous file; a 32-bit pointer to that record is at 0xE85474.
	.short 0xffff, 0x2
	.short 0xffff, 0x8
	.short 0xf5	; X-left coord of the button
	.short 0x6	; y-top coord of the button
	.short 0x13b, 0x17	; x-right coord of the button
	.short 0xf3, 0xc1	; y-botton coord
	.short 0xffff
	.long 0x3e664	; <-- the LSByte here affects the page number
	.short 0x1
	.short 0x2	; total number of pages
NakaWidget_SoundMenu_ScrollBar1:
	NAKA_REC_IvPageControl super=IDX_NakaContainer_SoundMenu_Root, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundMenu_ScrollBar2, prev=IDX_NakaWidget_SdmenuPage, flag=VF_Const | VF_InvisibleBox, x=0, y=0, w=32, h=32, page=1, window=0x20000 + IDX_NakaWidget_Sdmenu1
NakaWidget_SoundMenu_ScrollBar2:
	NAKA_REC_IvPageControl super=IDX_NakaContainer_SoundMenu_Root, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundMenu_ListBox, prev=IDX_NakaWidget_SoundMenu_ScrollBar1, flag=VF_Const | VF_InvisibleBox, x=36, y=0, w=32, h=32, page=2, window=0x20000 + IDX_NakaWidget_Sdmenu2
NakaWidget_SoundMenu_ListBox:
	NAKA_REC_IvExitMode super=IDX_NakaContainer_SoundMenu_Root, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundMenu_ValueEdit, prev=IDX_NakaWidget_SoundMenu_ScrollBar2, flag=VF_Const | VF_InvisibleBox, x=0, y=0, w=32, h=32, mode=NAKA_MODE_MD_NORMAL
NakaWidget_SoundMenu_ValueEdit:
	NAKA_REC_IvShowHide super=IDX_NakaContainer_SoundMenu_Root, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_NakaWidget_SoundMenu_ListBox, flag=VF_Const | VF_InvisibleBox, x=72, y=0, w=32, h=32, func=NAKA_APFUNC_TtSdmenu
NakaWidget_Sdmenu1:
	NAKA_REC_Window super=NAKA_INDEX_NONE, sub=IDX_NakaMenuItem_PartSetting, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=132, y=64, w=40, h=20, color=CL_Transparent, border=BD_None, modal=0x0, parent=0x3e666, child=0x3e66a




NakaMenuItem_PartSetting:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_Mixer, prev=NAKA_INDEX_NONE, flag=VF_Const, x=8, y=30, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left1, selected=0x3e66e, str=MenuStr_PartSetting, title=TITLE_SDPART, icon=idICON_i0


MenuStr_PartSetting:

; header: type=1D
;MenuItem     STRUCT
;header   db 6 dup (?)
;unk06		dw ?
;unk08		dw ?
;unk0a		dw ?
;unk0c		dw ?
;x		dw ?	; 0eh
;icon_y		dw ?	; 10h
;unk12		dw ?
;y		dw ?	; 14h
;bg_color	dw ?	; 16h
;unk18		dw ?
;unk1a		dw ?
;unk1c		dw ?
;unk1e		dw ?
;unk20		dw ?
;unk22		dw ?
;flags		dw ?	; 24h
;ptr26		dd ?
;text_string	dd ?	; 2ah
;unk2e		dw ?
;unk30		dw ?
;icon_id		dd ?	; 32h
;MenuItem     ENDSTRUCT


; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x50, 0x41, 0x52, 0x54, 0x20, 0x53, 0x45, 0x54
	.byte	0x54, 0x49, 0x4e, 0x47, 0x00, 0xff
NakaMenuItem_Mixer:
			;     and the text seems to disappear
			;    with mirror and offset on the x axis
	; X coord of menu item
	; <== affects Y coord of the menu item's icon
	; Y coord of menu item
	; bg color of menu item (00F7 means transparent)
	; <= affects positioning of label and icon
	; <== Select Icon (0 = no-icon, 1=worm, 2=... etc)
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_MasterTuning, prev=IDX_NakaMenuItem_PartSetting, flag=VF_Const, x=8, y=72, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left2, selected=0x3e670, str=MenuStr_Mixer, title=TITLE_SDMIXER, icon=idICON_i5


MenuStr_Mixer:	aligned_string "MIXER"


NakaMenuItem_MasterTuning:
	naka_header NAKA_TYPE_MENU_ITEM
	.byte 0x06, 0x00
	.byte 0xff, 0xff, 0x0a, 0x00, 0x08, 0x00, 0x08, 0x00
	.byte 0x08, 0x00, 0x9c, 0x00, 0x9c, 0x00, 0xb5, 0x00
	.byte 0xf7, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x8b, 0x00
	.byte	0x72, 0xe6, 0x03, 0x00, 0x08, 0x1a, 0xe8, 0x00
	.byte 0x04, 0x00, 0xa0, 0x01, 0x09, 0x00, 0x00, 0x00
	aligned_string "MASTER TUNING"
NakaMenuItem_KeyScaling:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_ReverbEqPresets, prev=IDX_NakaMenuItem_MasterTuning, flag=VF_Const, x=8, y=198, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left5, selected=0x3e674, str=MenuStr_KeyScaling, title=TITLE_SDSCLTYP, icon=idICON_i130
MenuStr_KeyScaling:	aligned_string "KEY SCALING"
NakaMenuItem_ReverbEqPresets:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_Reverb, prev=IDX_NakaMenuItem_KeyScaling, flag=VF_Const, x=163, y=30, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right1, selected=0x3e676, str=MenuStr_ReverbEqPresets, title=TITLE_REVEQMENU, icon=idICON_i143


MenuStr_ReverbEqPresets:	aligned_string "REVERB & EQ PRESETS"
NakaMenuItem_Reverb:

	naka_header NAKA_TYPE_MENU_ITEM
	.byte 0x06, 0x00
	.byte 0xff, 0xff, 0x0d, 0x00, 0x0b, 0x00, 0x08, 0x00
	.byte 0xa3, 0x00, 0x48, 0x00, 0x37, 0x01, 0x61, 0x00
	.byte 0xf7, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x09, 0x00
	.byte	0x78, 0xe6, 0x03, 0x00, 0xd8, 0x1a, 0xe8, 0x00
	.byte 0x0a, 0x00, 0xa0, 0x01, 0x17, 0x00, 0x00, 0x00
	aligned_string "REVERB"
NakaMenuItem_Equalizer:

	naka_header NAKA_TYPE_MENU_ITEM
	.byte 0x06, 0x00, 0xff, 0xff
	.byte 0x0e, 0x00, 0x0c, 0x00, 0x08, 0x00, 0xa3, 0x00
	.byte 0x72, 0x00, 0x37, 0x01, 0x8b, 0x00, 0xf7, 0x00
	.byte 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00
	.byte 0xff, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x7a, 0xe6
	.byte	0x03, 0x00, 0x16, 0x1b, 0xe8, 0x00, 0x0c, 0x00
	.byte 0xa0, 0x01, 0x0d, 0x00, 0x00, 0x00
	aligned_string "EQUALIZER"
NakaMenuItem_DspEffect:

	naka_header NAKA_TYPE_MENU_ITEM
	.byte 0x06, 0x00, 0xff, 0xff
	.byte 0x0f, 0x00, 0x0d, 0x00, 0x08, 0x00, 0xa3, 0x00
	.byte 0x9c, 0x00, 0x37, 0x01, 0xb5, 0x00, 0xf7, 0x00
	.byte 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00
	.byte 0xff, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x7c, 0xe6
	.byte	0x03, 0x00, 0x56, 0x1b, 0xe8, 0x00, 0x0b, 0x00
	.byte 0xa0, 0x01, 0x0c, 0x00, 0x00, 0x00
	aligned_string "DSP EFFECT"
NakaMenuItem_AcousticIllusion:
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundEdit, prev=IDX_NakaMenuItem_DspEffect, flag=VF_Const, x=163, y=198, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right5, selected=0x3e67e, str=MenuStr_AcousticIllusion, title=TITLE_SDACCILL, icon=idICON_i144


MenuStr_AcousticIllusion:	aligned_string "ACOUSTIC ILLUSION"
NakaWidget_SoundEdit:

	.byte 0x20, 0x00, 0x61, 0x01, 0x06, 0x00
	.byte 0xff, 0xff
	.byte 0xff, 0xff
	.byte 0x0f, 0x00
	.byte 0x08, 0x00
	.byte 0x08, 0x00
	.byte 0x72, 0x00
	.byte 0x9c, 0x00
	.byte 0x8b, 0x00
	.byte 0xf7, 0x00
	.byte 0x00, 0x00
	.byte 0xff, 0xff
	.zero 4
	.byte 0xff, 0x00
	.byte 0x00, 0x00
	.byte 0x8a, 0x00
	.long 0x3e680
	.long MenuStr_SoundEdit
	.byte 0x03, 0x00, 0x80, 0x01, 0x0f, 0x00, 0x00, 0x00

MenuStr_SoundEdit:	aligned_string "SOUND EDIT"
NakaWidget_Sdmenu2:
	NAKA_REC_Window super=NAKA_INDEX_NONE, sub=IDX_NakaMenuItem_LeftHold, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=56, y=120, w=36, h=16, color=CL_Transparent, border=BD_None, modal=0x0, parent=0x3e682, child=0x3e686
NakaMenuItem_LeftHold:

	naka_header NAKA_TYPE_MENU_ITEM
	.byte 0x11, 0x00, 0xff, 0xff
	.byte 0x13, 0x00, 0xff, 0xff, 0x08, 0x00, 0x08, 0x00
	.byte 0x72, 0x00, 0x9c, 0x00, 0x8b, 0x00, 0xf7, 0x00
	.byte 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00
	.byte 0xff, 0x00, 0x00, 0x00, 0x8a, 0x00, 0x8a, 0xe6
	.byte	0x03, 0x00, 0x46, 0x1c, 0xe8, 0x00, 0x07, 0x00
	.byte 0xa0, 0x01, 0x16, 0x00, 0x00, 0x00
	aligned_string "LEFT HOLD"
NakaMenuItem_TechniChord:
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	; padding
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu2, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_NakaMenuItem_LeftHold, flag=VF_Const, x=163, y=114, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right3, selected=0x3e68c, str=NakaInst_TECHNI_CHORD, title=TITLE_SDTECD, icon=idICON_i22

