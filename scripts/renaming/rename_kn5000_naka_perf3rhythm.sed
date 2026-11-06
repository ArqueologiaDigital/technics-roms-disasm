# Lane open11/kn5000-naka (2026-11-06): the two "RHYTHM" captions of NakaWidget_Perf3RhythmSel
# (PsWideToggle, element 9 of Viewable slot 0xE3) were named the wrong way round.  The class's own
# propnames (naka_classes.h, read from the firmware's Class tables) put stron at +26 and stroff at
# +30; the record's +26 word is 0xE24066 (the second text) and its +30 word 0xE2405E (the first),
# exactly as its siblings, elements 7 and 8, point stroff at their first text and stron at their
# second.  So 0xE2405E is the StrOff caption and 0xE24066 the StrOn one.  A swap, through a
# placeholder; the C member names of the two texts in naka_widget_tables_1.c follow.
s/\bNakaWidget_Perf3RhythmSel_StrOn\b/NakaWidget_Perf3RhythmSel_StrSWAP_TMP/g
s/\bNakaWidget_Perf3RhythmSel_StrOff\b/NakaWidget_Perf3RhythmSel_StrOn/g
s/\bNakaWidget_Perf3RhythmSel_StrSWAP_TMP\b/NakaWidget_Perf3RhythmSel_StrOff/g
s/\btxt_RHYTHM_on\b/txt_RHYTHM_SWAP_TMP/g
s/\btxt_RHYTHM_off\b/txt_RHYTHM_on/g
s/\btxt_RHYTHM_SWAP_TMP\b/txt_RHYTHM_off/g
