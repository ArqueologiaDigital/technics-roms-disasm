// Sound menu / TechniChord dispatch data
// Extracted from kn5000_v10_program.s
// Contains: Sound menu NAKA widgets (scrollbars, list boxes, page controls),
// NakaMenuItem entries (PartSetting, Mixer, MasterTuning, KeyScaling,
// ReverbEqPresets, Reverb, Equalizer, DspEffect, AcousticIllusion,
// LeftHold, TechniChord), SoundEdit widget, and associated string data.

; element 1 of Viewable slot 0x2 (Sdmenu), an AcWindowPage; its first 6 bytes were the end of
; naka_sound_menu_drawbar.c until 2026-11-06 (scripts/converters/naka_move_edge_heads_to_asm.py)
; (the rect is the box of the page indicator; pagemax = 2, the number of pages)
NakaWidget_SdmenuPage:
	NAKA_REC_AcWindowPage super=IDX_NakaContainer_SoundMenu_Root, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundMenu_ScrollBar1, prev=NAKA_INDEX_NONE, flag=VF_Const, x=245, y=6, w=71, h=18, color=CL_PageBack, border=BD_3D_UP2, index=0xffff, page=0x3e664, pagemin=1, pagemax=2
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


MenuStr_PartSetting:	aligned_string "PART SETTING"

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
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_KeyScaling, prev=IDX_NakaMenuItem_Mixer, flag=VF_Const, x=8, y=156, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left4, selected=0x3e672, str=MenuStr_MasterTuning, title=TITLE_SDMTUNE, icon=idICON_i7
MenuStr_MasterTuning:	aligned_string "MASTER TUNING"
NakaMenuItem_KeyScaling:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_ReverbEqPresets, prev=IDX_NakaMenuItem_MasterTuning, flag=VF_Const, x=8, y=198, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left5, selected=0x3e674, str=MenuStr_KeyScaling, title=TITLE_SDSCLTYP, icon=idICON_i130
MenuStr_KeyScaling:	aligned_string "KEY SCALING"
NakaMenuItem_ReverbEqPresets:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_Reverb, prev=IDX_NakaMenuItem_KeyScaling, flag=VF_Const, x=163, y=30, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right1, selected=0x3e676, str=MenuStr_ReverbEqPresets, title=TITLE_REVEQMENU, icon=idICON_i143


MenuStr_ReverbEqPresets:	aligned_string "REVERB & EQ PRESETS"
NakaMenuItem_Reverb:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_Equalizer, prev=IDX_NakaMenuItem_ReverbEqPresets, flag=VF_Const, x=163, y=72, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right2, selected=0x3e678, str=MenuStr_Reverb, title=TITLE_SDREVSET, icon=idICON_i21
MenuStr_Reverb:	aligned_string "REVERB"
NakaMenuItem_Equalizer:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_DspEffect, prev=IDX_NakaMenuItem_Reverb, flag=VF_Const, x=163, y=114, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right3, selected=0x3e67a, str=MenuStr_Equalizer, title=TITLE_SDEQUALIZER, icon=idICON_i11
MenuStr_Equalizer:	aligned_string "EQUALIZER"
NakaMenuItem_DspEffect:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_AcousticIllusion, prev=IDX_NakaMenuItem_Equalizer, flag=VF_Const, x=163, y=156, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right4, selected=0x3e67c, str=MenuStr_DspEffect, title=TITLE_SDDSPEFF, icon=idICON_i10
MenuStr_DspEffect:	aligned_string "DSP EFFECT"
NakaMenuItem_AcousticIllusion:
	; padding
	; padding
	; padding
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=IDX_NakaWidget_SoundEdit, prev=IDX_NakaMenuItem_DspEffect, flag=VF_Const, x=163, y=198, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right5, selected=0x3e67e, str=MenuStr_AcousticIllusion, title=TITLE_SDACCILL, icon=idICON_i144


MenuStr_AcousticIllusion:	aligned_string "ACOUSTIC ILLUSION"
NakaWidget_SoundEdit:
	NAKA_REC_AcSndEMenu super=IDX_NakaWidget_Sdmenu1, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_NakaMenuItem_AcousticIllusion, flag=VF_Const, x=8, y=114, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left3, selected=0x3e680, str=MenuStr_SoundEdit, mode=NAKA_MODE_MD_SOUNDEDIT, icon=idICON_i13


MenuStr_SoundEdit:	aligned_string "SOUND EDIT"
NakaWidget_Sdmenu2:
	NAKA_REC_Window super=NAKA_INDEX_NONE, sub=IDX_NakaMenuItem_LeftHold, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=56, y=120, w=36, h=16, color=CL_Transparent, border=BD_None, modal=0x0, parent=0x3e682, child=0x3e686
NakaMenuItem_LeftHold:
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu2, sub=NAKA_INDEX_NONE, next=IDX_NakaMenuItem_TechniChord, prev=NAKA_INDEX_NONE, flag=VF_Const, x=8, y=114, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left3, selected=0x3e68a, str=MenuStr_LeftHold, title=TITLE_SDLFTHLD, icon=idICON_i20
MenuStr_LeftHold:	aligned_string "LEFT HOLD"
NakaMenuItem_TechniChord:
	; padding
	; padding
	NAKA_REC_AcTitleMenu super=IDX_NakaWidget_Sdmenu2, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_NakaMenuItem_LeftHold, flag=VF_Const, x=163, y=114, w=149, h=26, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Right3, selected=0x3e68c, str=NakaInst_TECHNI_CHORD, title=TITLE_SDTECD, icon=idICON_i22

