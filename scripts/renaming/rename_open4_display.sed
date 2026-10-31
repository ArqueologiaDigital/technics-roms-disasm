# Lane open4/kn5000-b-display (2026-10-31): kn5000-5dc / kn5000-nmg / kn5000-ezo.
# Evidence per rule: notes/open4-kn5000-b/display/README.md.
#
# View-tree links (Viewable +4 super, +6 sub, +8 next, +10 prev; naka_classes.h naka_cls_Viewable_t):
s/\bView_GetParentOffset\b/GetSuperView/g
s/\bView_GetSuperViewInstance\b/GetSubView/g
s/\bView_GetNextSibling\b/GetNextView/g
s/\bView_ResolveInstanceAddr\b/GetPrevView/g
# ViewableProc's handlers of EVT_GET_SUPERVIEW / _SUBVIEW / _NEXTVIEW / _PREVVIEW:
s/\bViewable_GetParent\b/Viewable_OnGetSuperView/g
s/\bViewable_GetOwner\b/Viewable_OnGetSubView/g
s/\bViewable_GetChild\b/Viewable_OnGetNextView/g
s/\bViewable_GetClass\b/Viewable_OnGetPrevView/g
# VwBoxProc's handlers (VwBox +24 border, +26 index):
s/\bVwBox_HandleGetHeight\b/VwBox_OnGetBoxBorder/g
s/\bVwBox_HandleHitTest\b/VwBox_OnCheckIndex/g
s/\bVwBox_HandleGetWidth\b/VwBox_OnGetIndex/g
s/\bVwBox_HandleGetFocus\b/VwBox_OnDrawSelected/g
# PsGridBoxProc's handlers: EVT_DRAW, EVT_PAINT/REPAINT, EVT_PARA_DRAW, EVT_SELE_DRAW (and their blocks):
s/\bPsGridBox_Paint\b/PsGridBox_OnDraw/g
s/\bPsGridBox_ShowHide/PsGridBox_OnPaint/g
s/\bPsGridBox_Confirm/PsGridBox_OnParaDraw/g
s/\bPsGridBox_Select/PsGridBox_OnSeleDraw/g
# IvDrawbarProc's EVT_DRAW and EVT_PAINT/REPAINT handlers:
s/\bIvDrawbar_Paint\b/IvDrawbar_OnDraw/g
s/\bIvDrawbar_ShowHide\b/IvDrawbar_OnPaint/g
# MainTitleControl's handlers (MT_OtherPartLed 0xAB, MT_SetTitleFlag 0xBA, MT_MainLoopCount 0xBB):
s/\bMainTitleCtrl_HandleAB\b/MainTitleCtrl_OnOtherPartLed/g
s/\bMainTitleCtrl_HandleBA\b/MainTitleCtrl_OnSetTitleFlag/g
s/\bMainTitleCtrl_HandleBB\b/MainTitleCtrl_OnMainLoopCount/g
s/\bMainTitleCtrl_CheckSecondTimer\b/MainTitleCtrl_CountOtherPartLedDelay/g
s/\bMainTitleCtrl_ClearIndicatorBit\b/MainTitleCtrl_OtherPartLedOff/g
s/\bMainTitleCtrl_SetIndicator60\b/MainTitleCtrl_RequestOtherPartLed/g
s/\bMainTitleCtrl_SaveAndTransition\b/MainTitleCtrl_OnInterruptOrReturnTitle/g
s/\bMainTitleCtrl_SetIndicatorAndClear\b/MainTitleCtrl_FinishTitleChange/g
# The "transition" variables are the panel's held-switch masks (SwbtB3_OnPanelEvent, 0xA9 records):
s/\bTRANSITION_PROGRESS\b/PANEL_SW_HELD_UP/g
s/\bTRANSITION_TIMER\b/PANEL_SW_HELD_DOWN/g
s/\bTRANSITION_FLAGS\b/PANEL_SW_HELD_BOTH/g
# VGA: an unreferenced palette loader whose loop never ends; the three extended-sequencer tables:
s/\bVGA_CRTCTiming_ByteData\b/VGA_WritePalette256_Unterminated/g
s/\bVGA_WritePaletteEntry_Join\b/VGA_WritePalette256_Loop/g
s/\bVGA_ConfigExtSequencer_Alt\b/VGA_ConfigExtSequencer_AltB/g
