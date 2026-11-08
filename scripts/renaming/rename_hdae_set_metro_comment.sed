# wave 13 integration: the EVT_SET_METRO handler comment in the HD-AE5000 trees follows v5..v10
# (lane kn5000-naka3 renamed NoteEditSy_ModeScroll -> ApPlaySyori_OnSetMetro, notes/kn5000-naka3-2026-11-07/)
/^\.equ EVT_SET_METRO,/s/handler NoteEditSy_ModeScroll (misnamed) toggles/handler ApPlaySyori_OnSetMetro toggles/
