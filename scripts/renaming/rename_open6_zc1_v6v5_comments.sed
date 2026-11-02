# kn5000-zc1 (lane open6/kn5000-d naming, 2026-11-02), v6 / v5 only: three port comments quote VoiceSlot_* names
# of other trees.  v7's VoiceSlot_StatusRet_Helper3_Skip and VoiceSlot_StatusRet_Skip39 are now (rename_open6_zc1_v7.sed)
# DisplayStr_RedrawStatusAndTempoLine_Helper3_Skip and SqStep_ShowCursorEventPopup_Skip39; the routine called
# "VoiceSlot_StatusRet_Helper2" there is v6 / v5's SqStep_ShowTempoPopup (the TEMPO= line).
s/\bVoiceSlot_StatusRet_Helper3_Skip\b/DisplayStr_RedrawStatusAndTempoLine_Helper3_Skip/g
s/\bVoiceSlot_StatusRet_Skip39\b/SqStep_ShowCursorEventPopup_Skip39/g
s/\bVoiceSlot_StatusRet_Helper2\b/SqStep_ShowTempoPopup/g
