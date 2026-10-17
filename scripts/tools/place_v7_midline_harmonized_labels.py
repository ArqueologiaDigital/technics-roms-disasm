#!/usr/bin/env python3
"""place_v7_midline_harmonized_labels.py -- v10 names the harmonizer could not place in v7 because the v7 address
falls inside a source line (an .incbin slice), placed with place_labels.Planner (2026-10-17).

QUESTION IT ANSWERS: which v7 addresses still lack v10's name only because no line starts there?
harmonize_version_labels.py --to v7 --report lists them as "insert-mid-line" (its byte check matched the addresses).
Names that are themselves placeholders in v10 (Not_sure_maybe_SOFT_VERSION_related_*, *_Data_2) are not copied;
SeqByteBlock_PathNormalize lands inside an instruction line and is left.

RUN (repository root, built tree): python3 scripts/tools/place_v7_midline_harmonized_labels.py [--apply]
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__))))
import place_labels as pl  # noqa: E402

WANT = {0xe0cd06: 'Scoop_EventLoop_36Entry_Branch2_Str_Fmt3d', 0xe347ba: 'EntGridCheck_Handle4E13_Str_Fmt3d',
        0xe347c4: 'EntGridCheck_SendAudioCommand_Str_Fmt3d', 0xe9d892: 'CheckMsg_AudioCommand_Str_MessageID_Fmt3d',
        0xeb7900: 'SupportClass_PartTrackIntTimeRecords', 0xeb7924: 'SupportClass_ZeroEndRecord',
        0xf69f1b: 'CmpStepTitle_OnPaint_Draw', 0xf69f28: 'CmpStepTitle_OnHide', 0xf69f35: 'CmpStepTitle_OnSwitchIn',
        0xf69f42: 'CmpStepTitle_Method3Nop'}

P = pl.Planner('v7')
for a, n in sorted(WANT.items()):
    print(hex(a), n, P.add(a, n))
if "--apply" in sys.argv:
    P.apply()
