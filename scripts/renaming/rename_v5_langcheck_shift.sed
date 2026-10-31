# KN5000 v5: the Yoko ApFunction language-check procedures carried v6's labels one procedure late.
# Evidence: v5's ApFunction table (registry slot 0x127, Yoko_ApFunctionTable_127 at 0xE2025E) lists
# 0xF2A6B7, 0xF2A6C8, ... 0xF2A72E as entries 0-7, and its name table (slot 0x427, from
# DbgStr_PartSelLangCheck) names them PartSelLangCheck, AfterLangCheck, TrAsPreLangCheck,
# AtentionLangCheck, AreYouSureLangCheck, GmOnSureLangCheck, GmOffSureLangCheck, TrAsSureLangCheck.
# Entry 0 had no label (its skip was InitializeYoko_Skip), and each label stood on the next entry
# (the procedure "PartSelLangCheck" loaded AfterLangCheck_PtrTable).  Byte-neutral: every label
# and every reference moves together.  Applied to v5/maincpu/sequencer/sequencer_ui.s and
# v5/maincpu/port_dropped_labels.txt (two of its rows are placed now).
#   sed -i -f scripts/renaming/rename_v5_langcheck_shift.sed v5/maincpu/sequencer/sequencer_ui.s \
#       v5/maincpu/port_dropped_labels.txt
# entry 0: give it its label (the one `cp xbc, 0x1e0009f` whose skip is InitializeYoko_Skip)
/^\tcp\txbc, 0x1e0009f$/{N;s/^\tcp\txbc, 0x1e0009f\n\tjr\tnz, InitializeYoko_Skip$/QQLC_PartSelLangCheck:\n\tcp\txbc, EVT_GET_LANGUAGE_PTR\n\tjr\tnz, InitializeYoko_Skip/}
/^; port: v6's label GmOffSureLang_ReturnZero is not in v5 /d
/^; port: v6's label TrAsSureLangCheck is not in v5 /d
/^GmOffSureLang_ReturnZero\t/d
/^TrAsSureLangCheck\t/d
s/\bGmOffSureLangCheck\b/QQLC_TrAsSureLangCheck/g
s/\bGmOnSureLang_ReturnZero\b/QQLC_GmOffSureLang_ReturnZero/g
s/\bGmOnSureLangCheck\b/QQLC_GmOffSureLangCheck/g
s/\bAreYouSureLang_ReturnZero\b/QQLC_GmOnSureLang_ReturnZero/g
s/\bAreYouSureLangCheck\b/QQLC_GmOnSureLangCheck/g
s/\bAtentionLang_ReturnZero\b/QQLC_AreYouSureLang_ReturnZero/g
s/\bAtentionLangCheck\b/QQLC_AreYouSureLangCheck/g
s/\bTrAsPreLang_ReturnZero\b/QQLC_AtentionLang_ReturnZero/g
s/\bTrAsPreLangCheck\b/QQLC_AtentionLangCheck/g
s/\bAfterLang_ReturnZero\b/QQLC_TrAsPreLang_ReturnZero/g
s/\bAfterLangCheck\b/QQLC_TrAsPreLangCheck/g
s/\bPartSelLang_ReturnZero\b/QQLC_PartSelLang_ReturnZero_X/g
s/\bPartSelLangCheck\b/QQLC_AfterLangCheck/g
s/QQLC_PartSelLang_ReturnZero_X/QQLC_AfterLang_ReturnZero/g
s/\bInitializeYoko_Skip\b/QQLC_PartSelLang_ReturnZero/g
s/QQLC_//g
