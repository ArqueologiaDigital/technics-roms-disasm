#!/usr/bin/env python3
"""Lane open4/kn5000-b-display (2026-10-31, kn5000-nmg): name MainTitleControl's RAM cells and
correct the "transition" story, in every main-CPU tree (v10, v9, v7, v6, v5; v8 = v9).

1. shared/ram_variables.s: the PANEL_SW_HELD_* comments (ex TRANSITION_*, renamed by
   rename_open4_display.sed) say what the cells hold, and five new .equ name 0x274a6-0x274ae.
2. ui/ui_control_panel.s: the numeric operands (0x0274a6:24) ... (0x0274ae:24) are spelled with
   those names, and MainTitleCtrl_ChangeTitle's header is replaced.
The addresses are the same in all five trees (checked: the same instructions with the same
operands).  Evidence: notes/open4-kn5000-b/display/README.md, section kn5000-nmg.
Files are read and written as bytes.  Idempotent.

    python3 scripts/renaming/open4_display_title_ram.py
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ('v10', 'v9', 'v7', 'v6', 'v5')

RAM_OLD = re.compile(
    rb"; the ACTIVE title: EVT_CHANGE_TITLE, EVT_RETURN_TITLE and EVT_INTERRUPT_TITLE all set it \(`ldmm8\n"
    rb"; ACTIVE_TITLE_PREVIOUS, ACTIVE_TITLE / ld \(ACTIVE_TITLE\), l`\); MainTitleCtrl_ChangeTitle's header names the\n"
    rb"; transition variables\n"
    rb"(\t\.equ ACTIVE_TITLE,\t0x[0-9a-f]+\t[^\n]*\n\t\.equ ACTIVE_TITLE_PREVIOUS,\t0x[0-9a-f]+\t[^\n]*\n)"
    rb"\t\.equ PANEL_SW_HELD_UP,\t0x2749a\t[^\n]*\n"
    rb"\t\.equ PANEL_SW_HELD_DOWN,\t\t0x2749e\t[^\n]*\n"
    rb"\t\.equ PANEL_SW_HELD_BOTH,\t\t0x274a2\t[^\n]*\n")

RAM_NEW = (
    b"; the ACTIVE title: EVT_CHANGE_TITLE, EVT_RETURN_TITLE and EVT_INTERRUPT_TITLE all set it (`ldmm8\n"
    b"; ACTIVE_TITLE_PREVIOUS, ACTIVE_TITLE / ld (ACTIVE_TITLE), l`)\n"
    b"\\1"
    b"; held panel switches, kept by SwbtB3_OnPanelEvent from the 0xA9 switch records: group N = payload byte 1\n"
    b"; (0..16), bit N of a mask = CtrlPanel_SwitchRowBit[N].  Payload bit 1 is the group's UP switch (switch\n"
    b"; number N), bit 0 its DOWN switch (N | 0x80; ES_Left1..5 are 0x88..0x8C).  MainTitleControl clears all three\n"
    b"; on every mode or title change, so a held switch is forgotten across screens.  (Named TRANSITION_PROGRESS /\n"
    b"; _TIMER / _FLAGS until 2026-10-31: nothing in the firmware animates a title change.)\n"
    b"\t.equ PANEL_SW_HELD_UP,\t0x2749a\t; groups whose UP switch is held (set on press, cleared on release)\n"
    b"\t.equ PANEL_SW_HELD_DOWN,\t0x2749e\t; groups whose DOWN switch is held\n"
    b"\t.equ PANEL_SW_HELD_BOTH,\t0x274a2\t; PANEL_SW_HELD_UP & PANEL_SW_HELD_DOWN: 0x1100 -> CaptureLcd (version 0xff), 0xa1 -> TITLE_SOFTVER, 0x91 -> TITLE_PS, 0x89 -> EVT_SHOW to view 7\n"
    b"; MainTitleControl's delayed requests (MT_SetTitleFlag 0x01E000BA, MT_OtherPartLed 0x01E000AB): the handler\n"
    b"; stores the parameter and a count of 10; MT_MainLoopCount (0x01E000BB, once per main-loop pass) counts down\n"
    b"\t.equ TITLE_FLAGS_LATCHED,\t0x274a6\t; title-flags word, copied from TITLE_FLAGS_PENDING when the count ends; read by CtrlPanel_GetSelectionState\n"
    b"\t.equ TITLE_FLAGS_PENDING,\t0x274a8\t; the flags MT_SetTitleFlag last sent\n"
    b"\t.equ TITLE_FLAGS_DELAY,\t0x274aa\t; passes left before TITLE_FLAGS_PENDING is latched\n"
    b"\t.equ OTHER_PART_LED_PENDING,\t0x274ac\t; MT_OtherPartLed's request: non-zero = LED on (MainTitleCtrl_OnMainLoopCount sets bit 0 of a panel-state byte, 0x8f5c in v10)\n"
    b"\t.equ OTHER_PART_LED_DELAY,\t0x274ae\t; passes left before the request is applied (CtrlPanel_SetIndicatorBit 0x60)\n")

OPERANDS = [(rb"\(0x0?274a6:24\)", b"(TITLE_FLAGS_LATCHED:24)"),
            (rb"\(0x0?274a8:24\)", b"(TITLE_FLAGS_PENDING:24)"),
            (rb"\(0x0?274aa:24\)", b"(TITLE_FLAGS_DELAY:24)"),
            (rb"\(0x0?274ac:24\)", b"(OTHER_PART_LED_PENDING:24)"),
            (rb"\(0x0?274ae:24\)", b"(OTHER_PART_LED_DELAY:24)")]

HDR_OLD = re.compile(
    rb"; =+\n; MainTitleCtrl_ChangeTitle - Screen transition state handler\n(?:;[^\n]*\n)*?; =+\n"
    rb"(?=MainTitleCtrl_ChangeTitle:)")
HDR_NEW = (
    b"; MainTitleCtrl_ChangeTitle -- MainTitleControl's EVT_CHANGE_TITLE case (L = new title id).\n"
    b";   PREVIOUS_TITLE := CURRENT_TITLE (held in A), ACTIVE_TITLE_PREVIOUS := ACTIVE_TITLE, then CURRENT_TITLE\n"
    b";   and ACTIVE_TITLE := L.  EVT_INTERRUPT_TITLE and EVT_RETURN_TITLE (MainTitleCtrl_OnInterruptOrReturnTitle)\n"
    b";   change only ACTIVE_TITLE.  Both then request panel indicator 0x61 (CtrlPanel_SetIndicatorBit), clear the\n"
    b";   three held-switch masks PANEL_SW_HELD_* and call AudioMode_ResetVoiceState.  The change itself is\n"
    b";   immediate: no fade, slide or timed transition is started here or by any reader of these variables.\n")


def patch(path, fn):
    data = open(path, 'rb').read()
    new = fn(data)
    if new != data:
        open(path, 'wb').write(new)
        return True
    return False


def ram(data):
    if b"TITLE_FLAGS_LATCHED" in data:
        return data
    new, n = RAM_OLD.subn(RAM_NEW, data)
    if n != 1:
        sys.exit('ram_variables.s: block not found')
    return new


def panel(data):
    for pat, rep in OPERANDS:
        data = re.sub(pat, rep, data)
    if b"Screen transition state handler" in data:
        data, n = HDR_OLD.subn(HDR_NEW, data)
        if n != 1:
            sys.exit('ui_control_panel.s: header not found')
    return data


for t in TREES:
    for rel, fn in (('maincpu/shared/ram_variables.s', ram), ('maincpu/ui/ui_control_panel.s', panel)):
        p = os.path.join(ROOT, t, rel)
        print(('patched ' if patch(p, fn) else 'unchanged ') + os.path.relpath(p, ROOT))
