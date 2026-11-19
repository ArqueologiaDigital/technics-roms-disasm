#!/usr/bin/env python3
"""gen_lane_23n.py: helper AN's Audio_Process_DSP forms with the short C name of Voice_AllVoices_PortamentoUpdate.

QUESTION: run 2026-11-19-16-sub-r23o-tg-dsp could not check Audio_Process_DSP (sub_AN_23a/b/c.c): its callee
Voice_AllVoices_PortamentoUpdate has 32 characters, cc900 keeps 31, so the listing's name resolves to nothing.  The
built files call it Voice_AllVoices_PortaUpdate with a `cc900-name:` comment; this writes
scripts/analysis/cc900/corpus/firmware/sub_lane_23n<form>.c from sub_AN_23<form>.c with that spelling, nothing else
changed.  Run from the repository root: python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23n.py
"""
import os

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
FW = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
LONG, SHORT = 'Voice_AllVoices_PortamentoUpdate', 'Voice_AllVoices_PortaUpdate'


def main():
    for form in 'abc':
        text = open(os.path.join(FW, 'sub_AN_23%s.c' % form), encoding='latin-1').read()
        text = text.replace(LONG, SHORT)
        head = ('/* lane_sub, round 23: sub_AN_23%s.c with Voice_AllVoices_PortamentoUpdate called by its short C name '
                '(notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23n.py).\n   cc900-options: -Xr */\n'
                '/* cc900-name: %s=%s */\n\n' % (form, SHORT, LONG))
        path = os.path.join(FW, 'sub_lane_23n%s.c' % form)
        with open(path, 'w', encoding='latin-1') as f:
            f.write(head + text)
        print(path)


if __name__ == '__main__':
    main()
