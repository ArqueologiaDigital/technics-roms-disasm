#!/usr/bin/env python3
"""Which SOUND EDIT caption is each byte of the KN5000 sound record (the 470-byte .TM / SOUND RAM record)?

The answer comes from the sound-editor page handlers of the v10 main CPU (the evidence is in PAGES below, one row per
edited value): a column handler Se<Page>_OnColumn<n> edits one value of the page cache at RAM 0x660 + i (the cache
byte the page's bound field record, sdb_num / sdb_snum at RAM 0x66i, prints under its caption) and sends it with
SeMenu_StepParamFieldAndSend -> SeMenu_RegisterElement_Extended as an edit element {0x88, master, ELEMENT, 1, value,
mask} (semenu_routines.s).  The object flags (A) are the part 1..4 for a per-tone value and 0 for a common value:
  * per tone (flags = part): ELEMENT = the byte's offset in the tone's 81-byte partial block (record +0x66 + 0x51 p);
  * common (flags 0, the LFO pages): ELEMENT = the record offset (SeMenu_TransferPartValues: pitch LFO n at
    0x2B + 4 (n - 1), amplitude 0x3B + .., filter 0x4B + ..).
That the element of a per-tone value is its partial-block offset is read from the element sets themselves: PITCH ENV
7..22, FILTER ENV 61..76 and AMPLITUDE ENV 39..53 land on the three envelope structures the record's readers and its
clamp table (maincpu Param_SignExtendReturn_Helper3, ParamSx_* ranges) place there, and each element's edit range
(+8 max, +9 min of the edit record) equals that offset's clamp range.  [INFERENCE: the sub-CPU handler of element
messages was not traced; the agreement of 46 element numbers and ranges with the record layout is the evidence.]

usage:
  se_page_names.py --table                 print the page / caption / element table (Markdown, aligned)
  se_page_names.py --apply SPEC.json       rename the fields of notes/floppy-kn5000-2026-10-29/specs/tm_sound_record.json
                                           in place (the inputs of gen_tm_spec.py are not committed, so the spec is
                                           patched; gen_tm_spec.py imports apply() so a regeneration gives the same)
"""
import json
import sys

# (page title, column / row, cache byte RAM 0x66i, caption, element, range, block)  block: 'P' partial, 'C' common
PAGES = [
    # PITCH ENV1 (TT_SEPITENV1): SePitEnv1_OnColumn1..7 -> SeMenu_ApplyPartEdit_AltStore_Join8..14; upper row = cache 0
    # (0x660) zero, lower row non-zero; captions SePitEnv1_Records + SeEnv1_DrawEnvelopeLayout_Records4, fields
    # SePitFilEnv1_*Field.
    ('PITCH ENV1', 'col 7 upper', 0x661, 'TOTAL DEPTH', 7, '-50..50', 'P'),
    ('PITCH ENV1', 'col 3 upper', 0x662, 'START PITCH', 8, '-50..50', 'P'),
    ('PITCH ENV1', 'col 1', 0x663, 'ATK', 9, '0..100', 'P'),
    ('PITCH ENV1', 'col 2', 0x664, 'PEAK', 10, '-50..50', 'P'),
    ('PITCH ENV1', 'col 3 lower', 0x665, 'DECAY1', 11, '0..100', 'P'),
    ('PITCH ENV1', 'col 4', 0x666, 'SUST1', 12, '-50..50', 'P'),
    ('PITCH ENV1', 'col 5 lower', 0x667, 'DECAY2', 13, '0..100', 'P'),
    ('PITCH ENV1', 'col 6', 0x668, 'SUST2', 14, '-50..50', 'P'),
    ('PITCH ENV1', 'col 7 lower', 0x669, 'RELEASE', 15, '0..100', 'P'),
    ('PITCH ENV1', 'col 5 upper', 0x66A, 'STOP PITCH', 16, '-50..50', 'P'),
    # PITCH ENV2 (TT_SEPITENV2): SePitEnv2_OnColumn2..8 -> Join15..20; SePitFilEnv2_StaticRecords, _Field*_Record.
    ('PITCH ENV2', 'col 7', 0x660, 'TOUCH ADR-TIME', 17, '-50..50', 'P'),
    ('PITCH ENV2', 'col 8', 0x661, 'TOUCH DEPTH', 18, '-50..50', 'P'),
    ('PITCH ENV2', 'col 5', 0x662, 'KEY FOLLOW CENTER (note)', 19, 'note', 'P'),
    ('PITCH ENV2', 'col 2', 0x663, 'KEY FOLLOW ATTACK', 20, '-50..50', 'P'),
    ('PITCH ENV2', 'col 3', 0x664, 'KEY FOLLOW DECAY', 21, '-50..50', 'P'),
    ('PITCH ENV2', 'col 4', 0x665, 'KEY FOLLOW RELEASE', 22, '-50..50', 'P'),
    # AMPLITUDE ENV1 (TT_SEAMPENV1), 4-part layout: SeAmpEnv1_OnColumn1..7 (display/scoop_editor_data.s), element
    # `ld a, 39..44:opc` / pushw 45; fields SeAmpEnv1_*Field (RAM 0x660..0x666).
    ('AMP ENV1', 'col 1', 0x660, 'ATK', 39, '0..100', 'P'),
    ('AMP ENV1', 'col 2', 0x661, 'PEAK', 40, '0..100', 'P'),
    ('AMP ENV1', 'col 3', 0x662, 'DECAY1', 41, '0..100', 'P'),
    ('AMP ENV1', 'col 4', 0x663, 'SUST1', 42, '0..100', 'P'),
    ('AMP ENV1', 'col 5', 0x664, 'DECAY2', 43, '0..100', 'P'),
    ('AMP ENV1', 'col 6', 0x665, 'SUST2', 44, '0..100', 'P'),
    ('AMP ENV1', 'col 7', 0x666, 'RELEASE', 45, '0..100', 'P'),
    # AMPLITUDE ENV2 (TT_SEAMPENV2): SeAmpEnv2_OnColumn1..8 (pushw 46..53 / ldw bc, 48..50); SeAmpEnv2_*Field.
    ('AMP ENV2', 'col 7', 0x660, 'TOUCH ATTACK', 46, '-50..50', 'P'),
    ('AMP ENV2', 'col 8', 0x661, 'TOUCH DECAY', 47, '-50..50', 'P'),
    ('AMP ENV2', 'col 5', 0x662, 'KEY FOLLOW RANGE middle note', 48, 'note', 'P'),
    ('AMP ENV2', 'col 4', 0x663, 'KEY FOLLOW RANGE low note', 49, 'note', 'P'),
    ('AMP ENV2', 'col 6', 0x664, 'KEY FOLLOW RANGE high note', 50, 'note', 'P'),
    ('AMP ENV2', 'col 1', 0x665, 'KEY FOLLOW ATK', 51, '-50..50', 'P'),
    ('AMP ENV2', 'col 2', 0x666, 'KEY FOLLOW DECAY', 52, '-50..50', 'P'),
    ('AMP ENV2', 'col 3', 0x667, 'KEY FOLLOW RELEASE', 53, '-50..50', 'P'),
    # FILTER ENV1 / ENV2: SeFilEnv1_OnColumn1..7 (elements 61..70) and SeFilEnv2_OnColumn2..8 (71..76) share the PITCH
    # handlers Join8..20; captions SeFilEnv1_Records (START POINT, STOP POINT, CUTOFF ADJUST) and SePitFilEnv2.
    ('FILTER ENV1', 'col 7 upper', 0x661, 'CUTOFF ADJUST', 61, '-50..50', 'P'),
    ('FILTER ENV1', 'col 3 upper', 0x662, 'START POINT', 62, '-50..50', 'P'),
    ('FILTER ENV1', 'col 1', 0x663, 'ATK', 63, '0..100', 'P'),
    ('FILTER ENV1', 'col 2', 0x664, 'PEAK', 64, '-50..50', 'P'),
    ('FILTER ENV1', 'col 3 lower', 0x665, 'DECAY1', 65, '0..100', 'P'),
    ('FILTER ENV1', 'col 4', 0x666, 'SUST1', 66, '-50..50', 'P'),
    ('FILTER ENV1', 'col 5 lower', 0x667, 'DECAY2', 67, '0..100', 'P'),
    ('FILTER ENV1', 'col 6', 0x668, 'SUST2', 68, '-50..50', 'P'),
    ('FILTER ENV1', 'col 7 lower', 0x669, 'RELEASE', 69, '0..100', 'P'),
    ('FILTER ENV1', 'col 5 upper', 0x66A, 'STOP POINT', 70, '-50..50', 'P'),
    ('FILTER ENV2', 'col 7', 0x660, 'TOUCH ADR-TIME', 71, '-50..50', 'P'),
    ('FILTER ENV2', 'col 8', 0x661, 'TOUCH DEPTH', 72, '-50..50', 'P'),
    ('FILTER ENV2', 'col 5', 0x662, 'KEY FOLLOW CENTER (note)', 73, 'note', 'P'),
    ('FILTER ENV2', 'col 2', 0x663, 'KEY FOLLOW ATTACK', 74, '-50..50', 'P'),
    ('FILTER ENV2', 'col 3', 0x664, 'KEY FOLLOW DECAY', 75, '-50..50', 'P'),
    ('FILTER ENV2', 'col 4', 0x665, 'KEY FOLLOW RELEASE', 76, '-50..50', 'P'),
    # The per-tone LFO switch bytes: SeMenu_GetLfoPartSwitchParamId (kind 0 AMP -> 0x26, 1 PITCH -> 0x06, 2 FILTER ->
    # 0x38), sent by SeMenu_CyclePartLfoState: bit 5 on, bits 7:6 = the LFO number - 1, bit 4 the +/- sign
    # (SeLfo1_Part1SignField); cache 0x665..0x668 = tones 1..4.
    ('* LFO1', 'side rows 2..5', 0x665, 'tone n LFO on / LFO number / sign', '6 / 38 / 56', 'bits', 'P'),
    # The LFO pages (common): SeAmpLfo1/SePitLfo1/SeFilLfo1_OnColumn3..8 -> SeMenu_ApplyPartEdit_AltStore_Join..Join6;
    # element = base + k (`inc k, a`); captions SeLfo1_Records, fields SeLfo1_WaveDelayFields .. _Records2.
    ('* LFO1', 'col 6', 0x661, 'DEPTH', 'base+0', '0..127', 'C'),
    ('* LFO1', 'col 5', 0x662, 'SPEED', 'base+1', '0..127', 'C'),
    ('* LFO1', 'col 7', 0x663, 'TOUCH (bits 5:0)', 'base+2', '0..50', 'C'),
    ('* LFO1', 'col 8', 0x663, 'KEYSYNC (bit 7)', 'base+2', 'OFF/ON', 'C'),
    ('* LFO1', 'col 3', 0x664, 'WAVE (bits 7:6)', 'base+3', 'SIN TRI SQR SAW', 'C'),
    ('* LFO1', 'col 4', 0x664, 'DELAY (bits 4:0)', 'base+3', '0..30', 'C'),
    # CONTROLLER (TT_SECTR2), common: UpdSeSel_DetailedUpdate_Helper5 requests the six FUNCTION bytes 0x18 + 3 k
    # (k = 0..5, cache 1..6, SeCtr2_FunctionNameFields shows 1, 2, 5, 6) and, for the selection s in RAM 0x695
    # (SeCtr2_SetSelection; side rows choose 1, 2 / 5, 6), the group base g = 0x17 / 0x1A / 0x23 / 0x26
    # (UpdSeSel_DetailedUpdate_SetDisplayState_Helper2) into cache 13, its +2 into cache 11 and +0 into cache 12.
    ('CONTROLLER', 'col 2 / 3', 0x661, 'FUNCTION (SeValText_CtrlDestinations)', 'g+1', '0..27', 'C'),
    ('CONTROLLER', 'col 4', 0x66B, 'DEPTH (SeCtr2_StepDepth)', 'g+2', '0..127', 'C'),
    ('CONTROLLER', 'cols 5..8', 0x66C, '1ST..4TH OFF / ON / INV (SeCtr2_StepPartField)', 'g+0', '2 bits per tone', 'C'),
    # CONTROLLER page 2 (TT_SECTR3): SeCtr3_OnColumn3 / 6 send record +0x10 with mask 1 << 4 / 1 << 5.
    ('CONTROLLER 2', 'col 3', 0x660, 'SUSTAIN PEDAL MODE (bit 4)', 16, '0..1', 'C'),
    ('CONTROLLER 2', 'col 6', 0x660, 'GLIDE (bit 5)', 16, '0..1', 'C'),
]

# partial-block offset -> (new name, size, kind, caption evidence, old name)
_ENV = {
    0x06: ('pitch_lfo_switch', 'bits', 'PITCH LFO switch of the tone (bit 5 on, bits 7:6 LFO number - 1, bit 4 sign); '
           'subcpu Voice_Pitch_ApplyPortamento also keeps bits 2:0', 'porta_sel'),
    0x07: ('pitch_env_total_depth', 'signed', 'PITCH ENV1 TOTAL DEPTH', 'env2_start_level'),
    0x08: ('pitch_env_start', 'signed', 'PITCH ENV1 START PITCH', 'env2_porta_level'),
    0x09: ('pitch_env_attack', 'dec', 'PITCH ENV1 ATK', 'env2_seg1_a'),
    0x0A: ('pitch_env_peak', 'signed', 'PITCH ENV1 PEAK', 'env2_seg1_b'),
    0x0B: ('pitch_env_decay1', 'dec', 'PITCH ENV1 DECAY1', 'env2_seg2_a'),
    0x0C: ('pitch_env_sustain1', 'signed', 'PITCH ENV1 SUST1', 'env2_seg2_b'),
    0x0D: ('pitch_env_decay2', 'dec', 'PITCH ENV1 DECAY2', 'env2_seg3_a'),
    0x0E: ('pitch_env_sustain2', 'signed', 'PITCH ENV1 SUST2', 'env2_seg3_b'),
    0x0F: ('pitch_env_release', 'dec', 'PITCH ENV1 RELEASE', 'env2_seg4_a'),
    0x10: ('pitch_env_stop', 'signed', 'PITCH ENV1 STOP PITCH', 'env2_seg4_b'),
    0x11: ('pitch_env_touch_adr_time', 'signed', 'PITCH ENV2 TOUCH ADR-TIME', 'env2_key_scale'),
    0x12: ('pitch_env_touch_depth', 'signed', 'PITCH ENV2 TOUCH DEPTH; subcpu TVF_Build_Short / Voice_PitchPack_RouteB..D '
           'also read it through paramA', 'filter_b12'),
    0x13: ('pitch_env_key_follow_center', 'dec', 'PITCH ENV2 KEY FOLLOW CENTER (a note, SeValText_NoteNames)',
           'env2_velocity_base'),
    0x14: ('pitch_env_key_follow_attack', 'signed', 'PITCH ENV2 KEY FOLLOW ATTACK', 'env2_velocity_depth'),
    0x15: ('pitch_env_key_follow_decay', 'signed', 'PITCH ENV2 KEY FOLLOW DECAY', 'env2_velocity_depth'),
    0x16: ('pitch_env_key_follow_release', 'signed', 'PITCH ENV2 KEY FOLLOW RELEASE', 'env2_egb_0x16'),
    0x26: ('amp_lfo_switch', 'bits', 'AMPLITUDE LFO switch of the tone (bit 5 on, bits 7:6 LFO number - 1, bit 4 sign)',
           'unread_26'),
    0x27: ('amp_env_attack', 'dec', 'AMPLITUDE ENV1 ATK', 'env1_seg1_target'),
    0x28: ('amp_env_peak', 'dec', 'AMPLITUDE ENV1 PEAK', 'env1_seg1_rate'),
    0x29: ('amp_env_decay1', 'dec', 'AMPLITUDE ENV1 DECAY1', 'env1_seg2_target'),
    0x2A: ('amp_env_sustain1', 'dec', 'AMPLITUDE ENV1 SUST1', 'env1_seg2_rate'),
    0x2B: ('amp_env_decay2', 'dec', 'AMPLITUDE ENV1 DECAY2', 'env1_seg3_target'),
    0x2C: ('amp_env_sustain2', 'dec', 'AMPLITUDE ENV1 SUST2', 'env1_seg3_rate'),
    0x2D: ('amp_env_release', 'dec', 'AMPLITUDE ENV1 RELEASE', 'env1_level'),
    0x2E: ('amp_env_touch_attack', 'signed', 'AMPLITUDE ENV2 TOUCH ATTACK', 'env1_key_scale'),
    0x2F: ('amp_env_touch_decay', 'signed', 'AMPLITUDE ENV2 TOUCH DECAY', 'env1_key_scale'),
    0x30: ('amp_env_key_follow_range_mid', 'dec', 'AMPLITUDE ENV2 KEY FOLLOW RANGE middle note', 'env1_velocity_ctl'),
    0x31: ('amp_env_key_follow_range_low', 'dec', 'AMPLITUDE ENV2 KEY FOLLOW RANGE low note', 'env1_velocity_ctl'),
    0x32: ('amp_env_key_follow_range_high', 'dec', 'AMPLITUDE ENV2 KEY FOLLOW RANGE high note', 'env1_velocity_ctl'),
    0x33: ('amp_env_key_follow_attack', 'signed', 'AMPLITUDE ENV2 KEY FOLLOW ATK', 'env1_depth'),
    0x34: ('amp_env_key_follow_decay', 'signed', 'AMPLITUDE ENV2 KEY FOLLOW DECAY', 'env1_depth'),
    0x35: ('amp_env_key_follow_release', 'signed', 'AMPLITUDE ENV2 KEY FOLLOW RELEASE', 'env1_ega_0x35'),
    0x38: ('filter_lfo_switch', 'bits', 'FILTER LFO switch of the tone (bit 5 on, bits 7:6 LFO number - 1, bit 4 sign)',
           'unread_38'),
    0x3D: ('filter_env_cutoff_adjust', 'signed', 'FILTER ENV1 CUTOFF ADJUST', 'env3_start_level'),
    0x3E: ('filter_env_start_point', 'signed', 'FILTER ENV1 START POINT', 'env3_porta_level'),
    0x3F: ('filter_env_attack', 'dec', 'FILTER ENV1 ATK', 'env3_seg1_a'),
    0x40: ('filter_env_peak', 'signed', 'FILTER ENV1 PEAK', 'env3_seg1_b'),
    0x41: ('filter_env_decay1', 'dec', 'FILTER ENV1 DECAY1', 'env3_seg2_a'),
    0x42: ('filter_env_sustain1', 'signed', 'FILTER ENV1 SUST1', 'env3_seg2_b'),
    0x43: ('filter_env_decay2', 'dec', 'FILTER ENV1 DECAY2', 'env3_seg3_a'),
    0x44: ('filter_env_sustain2', 'signed', 'FILTER ENV1 SUST2', 'env3_seg3_b'),
    0x45: ('filter_env_release', 'dec', 'FILTER ENV1 RELEASE', 'env3_seg4_a'),
    0x46: ('filter_env_stop_point', 'signed', 'FILTER ENV1 STOP POINT', 'env3_seg4_b'),
    0x47: ('filter_env_touch_adr_time', 'signed', 'FILTER ENV2 TOUCH ADR-TIME', 'env3_key_scale'),
    0x48: ('filter_env_touch_depth', 'signed', 'FILTER ENV2 TOUCH DEPTH', 'unread_48'),
    0x49: ('filter_env_key_follow_center', 'dec', 'FILTER ENV2 KEY FOLLOW CENTER (a note)', 'env3_velocity_base'),
    0x4A: ('filter_env_key_follow_attack', 'signed', 'FILTER ENV2 KEY FOLLOW ATTACK', 'env3_velocity_depth'),
    0x4B: ('filter_env_key_follow_decay', 'signed', 'FILTER ENV2 KEY FOLLOW DECAY', 'env3_velocity_depth'),
    0x4C: ('filter_env_key_follow_release', 'signed', 'FILTER ENV2 KEY FOLLOW RELEASE', 'env3_egc_0x4c'),
}
# common LFO block: record offset -> (new name, caption evidence, old name)
_LFO = {
    0x2B: ('lfo_depth', 'LFO DEPTH (0..127)', 'lfo_b0'),
    0x2C: ('lfo_speed', 'LFO SPEED (0..127)', 'lfo_b1'),
    0x2D: ('lfo_touch_keysync', 'LFO TOUCH (bits 5:0, 0..50) and KEYSYNC (bit 7)', 'lfo_b2_onoff'),
    0x2E: ('lfo_wave_delay', 'LFO WAVE (bits 7:6: SIN TRI SQR SAW) and DELAY (bits 4:0, 0..30)', 'lfo_b3_wave'),
}
# controller groups: record offset of the group's first field -> (new name, caption evidence, old name)
_CTRL = {
    0x14: ('ctrl_tone_switches', 'CONTROLLER 1ST..4TH: four 2-bit fields, tone 1 in bits 1:0 .. tone 4 in bits 7:6, '
           '0 OFF, 1 ON, 3 INV (SeCtr2_StepPartField; SeValText_Off_On_Dash_Inv)', 'ctrl_part_switches'),
    0x15: ('ctrl_function', 'CONTROLLER FUNCTION: bits 6:0 index SeValText_CtrlDestinations ("PITCH BEND", "AMP ENV SUST", '
           '"FILTER CUTOFF", "PTCH LFO1 DEP", ...; the page shows & 0x3F); bit 7 a flag', 'ctrl_b1'),
    0x16: ('ctrl_depth', 'CONTROLLER DEPTH, 0..127 (SeCtr2_StepDepth)', 'ctrl_b2'),
}
CTRL_ORDER = ('7 groups of 3: group 0 (+0x14) is not on the CONTROLLER page (its FUNCTION is 0x81 = flag + PITCH BEND '
              'in every record; subcpu Voice_PitchBend_BranchA takes its address), groups 1..6 (+0x17 + 3 (k - 1)) are '
              'the page\'s FUNCTION selections 1..6 (UpdSeSel_DetailedUpdate_Helper5 / _SetDisplayState_Helper2; the page '
              'offers 1, 2 in its first row and 5, 6 in its second row; 3 and 4 no side row selects, their row label was not read: the rows carry icons, op-23 styles 0x60 and 0x39)')
PB = 0x66
EV = ('SOUND EDIT page caption, notes/open6-kn5000-d/panel/probes/se_page_names.py (the element the page handler sends '
      'for it is this offset)')
LFO_ORDER = ('12 entries: PITCH LFO1-4 (+0x2B), AMPLITUDE LFO1-4 (+0x3B), FILTER LFO1-4 (+0x4B), entry k at +0x2B + 4 k '
             '(SeMenu_TransferPartValues)')


def apply(fields):
    """Rename the fields of a tm_sound_record field list in place; returns the list (two- and three-byte fields that
    the pages show as separate values are split into one field per byte)."""
    out = []
    for f in fields:
        o = f['off']
        if f.get('repeat', {}).get('stride') == 81 and PB <= o < PB + 81:
            p = o - PB
            hits = [q for q in range(p, p + f['size']) if q in _ENV]
            if hits:
                assert hits == list(range(p, p + f['size'])), f
                for q in hits:
                    nm, kind, cap, old = _ENV[q]
                    g = {k: v for k, v in f.items() if k not in ('todo', 'observed')}
                    g.update(off=PB + q, size=1, name='partial_' + nm, kind=kind, inference=False,
                             evidence=cap + ' (' + EV + '); was ' + old + ': ' + f['evidence'])
                    if kind == 'signed':
                        g['bias'] = 0
                    else:
                        g.pop('bias', None)
                    if f['size'] == 1 and 'observed' in f:
                        g['observed'] = f['observed']
                    out.append(g)
                continue
        if f.get('repeat', {}).get('stride') == 3 and o in _CTRL:
            nm, cap, old = _CTRL[o]
            g = {k: v for k, v in f.items() if k != 'todo'}
            g.update(name=nm, inference=False, evidence=cap + ' (' + EV + '); ' + CTRL_ORDER + '; was ' + old + ': ' +
                     f['evidence'])
            out.append(g)
            continue
        if o == 0x10 and f['name'] == 'part_mode':
            g = dict(f)
            g['evidence'] = (f['evidence'] + '; bit 4 = SUSTAIN PEDAL MODE and bit 5 = GLIDE (CONTROLLER page 2, '
                             'SeCtr3_OnColumn3 / 6 send element 16 with mask 0x10 / 0x20)')
            out.append(g)
            continue
        if f.get('repeat', {}).get('stride') == 4 and o in _LFO:
            nm, cap, old = _LFO[o]
            g = {k: v for k, v in f.items() if k != 'todo'}
            g.update(name=nm, inference=False, evidence=cap + ' (' + EV + '); ' + LFO_ORDER + '; was ' + old + ': ' +
                     f['evidence'])
            out.append(g)
            continue
        out.append(f)
    return out


def table():
    rows = [('page', 'control', 'cache', 'caption', 'element', 'range', 'record byte')]
    for pg, col, c, cap, el, rg, blk in PAGES:
        if blk == 'P' and isinstance(el, int):
            where = 'partial +0x%02x (record +0x%02x + 0x51 p)' % (el, PB + el)
        elif blk == 'P':
            where = 'partial +0x06 / +0x26 / +0x38'
        elif isinstance(el, int):
            where = 'record +0x%02x' % el
        elif el.startswith('g+'):
            where = 'controller group g +%s (g = 0x17 + 3 (s - 1))' % el[2:]
        else:
            where = 'LFO entry +%s (record +0x2B / 0x3B / 0x4B + 4 (n-1))' % el.split('+')[1]
        rows.append((pg, col, '0x%03x' % c, cap, str(el), rg, where))
    w = [max(len(r[i]) for r in rows) for i in range(len(rows[0]))]
    fmt = lambda r: '| ' + ' | '.join(x.ljust(w[i]) for i, x in enumerate(r)) + ' |'
    print(fmt(rows[0]))
    print('|' + '|'.join('-' * (n + 2) for n in w) + '|')
    for r in rows[1:]:
        print(fmt(r))


if __name__ == '__main__':
    if '--table' in sys.argv:
        table()
    elif '--apply' in sys.argv:
        path = sys.argv[sys.argv.index('--apply') + 1]
        doc = json.load(open(path))
        doc['fields'] = apply(doc['fields'])
        json.dump(doc, open(path, 'w'), indent=1)
    else:
        print(__doc__)
