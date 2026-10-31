# AcLanguageTextProc's case labels were AcTrkSw_ShowHide*, borrowed from the track-switch code above it.
# EVT_DRAW: ask the view's function (+38) for its per-language table (EVT_GET_LANGUAGE_PTR) and draw entry
# [HELP_LANGUAGE]; EVT_GET_STR_PTR: return the class name string.  Found while settling open item N-94f26143.
s/\bAcTrkSw_ShowHide_CheckDirty_Str_AcLanguageText\b/AcLanguageTextProc_ClassName/g
s/\bAcTrkSw_ShowHide_CheckDirty\b/AcLanguageTextProc_OnGetStrPtr/g
s/\bAcTrkSw_ShowHide_Refresh\b/AcLanguageTextProc_Return/g
s/\bAcTrkSw_ShowHide\b/AcLanguageTextProc_OnDraw/g
