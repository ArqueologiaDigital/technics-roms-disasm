s/\bNoteEditSy_ModeScroll\b/ApPlaySyori_OnSetMetro/g
s/handler ApPlaySyori_OnSetMetro (misnamed) toggles the metronome state\./handler ApPlaySyori_OnSetMetro toggles the metronome state (SEQ_METRO_FLAGS bit 0)./g
s/\bNoteEdit_ScrollToggle\b/ApPlaySyori_OnSetMetro_Refuse/g
s/\bNoteEdit_ScrollSetZero\b/ApPlaySyori_OnSetMetro_RefuseOff/g
s/\bNoteEdit_ScrollDispatchMode\b/ApPlaySyori_OnSetMetro_Redraw/g
s/\bNoteEdit_ScrollInactive\b/ApPlaySyori_OnSetMetro_Store/g
s/\bNoteEdit_ScrollActivate\b/ApPlaySyori_OnSetMetro_StoreOn/g
s/\bNoteEdit_ScrollCheck86\b/ApPlaySyori_OnSetMetro_Redraw86/g
s/\bNoteEdit_ScrollCheck87\b/ApPlaySyori_OnSetMetro_Redraw87/g
s/\bNoteEdit_ScrollCheck88\b/ApPlaySyori_OnSetMetro_Redraw88/g
