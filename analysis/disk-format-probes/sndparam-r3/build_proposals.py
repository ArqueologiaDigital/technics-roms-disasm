#!/usr/bin/env python3
"""build_proposals.py -- round 3 of the sound-parameter descriptor naming (research output, read-only on the repo).

QUESTION IT ANSWERS
  For the 259 v10 descriptors that still carry positional aliases after gen_sndparam_desc_names_r2.py, which keys does
  the firmware itself identify, and what are they?  Each proposal carries file:line citations into the HEAD snapshot
  (snap/, `git archive` of the commit in snap/COMMIT).  Every citation is CHECKED here: the cited line must contain the
  token given next to it, or the script stops.  record / byte / mask / range are read from the ROM descriptors (never
  typed), through the same 972-pointer registry gen_sndparam_desc_names_r2.py walks.

RUN
  python3 build_proposals.py          # writes proposals.json, inferred.json, unresolved.json, observations.json,
                                      # proposals_weak_names.json next to this script and prints a summary
"""
import collections, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
SNAP = os.path.join(HERE, 'snap') + '/'
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
COMMIT = open(SNAP + 'COMMIT').read().strip()

# ---------------------------------------------------------------- descriptors from the ROM
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_v10_program.rom'), 'rb').read()
out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_v10_program.llvm.elf')],
                     capture_output=True, text=True, check=True).stdout
syms, byaddr = {}, collections.defaultdict(list)
for l in out.splitlines():
    f = l.split()
    if len(f) == 3:
        syms[f[2]] = int(f[0], 16)
        byaddr[int(f[0], 16)].append(f[2])
reg = syms['SndParam_RegisterLoop_Data'] - 0xE00000
DESC = {}
for i in range(972):
    p = int.from_bytes(rom[reg + 4 * i:reg + 4 * i + 4], 'little')
    b = rom[p - 0xE00000:p - 0xE00000 + 18]
    key = int.from_bytes(b[0:4], 'little')
    names = [n for n in byaddr[p] if not n.startswith('$') and not n.startswith('SndParamRun_')]
    DESC[key] = dict(addr=p, rec=b[4], off=b[5], mask=b[6], lo=b[7], hi=b[8], shift=b[9] & 15, xor=b[10],
                     aux=b[11], alias=names[0] if names else '?')
UNNAMED = set()
for l in open(os.path.join(HERE, 'sndparam_unnamed_v10.txt')):
    if l.startswith('0x'):
        UNNAMED.add(int(l.split()[0], 16))


def decode(key):
    if 0x8000 <= key <= 0x17FFF:
        return ((key - 0x8000) >> 10) & 0x3F, key & 0x3FF
    if 0x18000 <= key <= 0x27FFF:
        return ((key - 0x8000) >> 10) & 0x3F, (key & 0x3FF) + 0x400
    return None


# ---------------------------------------------------------------- citation checking
_cache = {}


def cite(f, line, token, text):
    if f not in _cache:
        _cache[f] = open(SNAP + f, 'rb').read().decode('latin-1').split('\n')
    L = _cache[f]
    if not (1 <= line <= len(L)) or token not in L[line - 1]:
        sys.exit('CITATION CHECK FAILED: %s:%d does not contain %r (line reads %r)'
                 % (f, line, token, L[line - 1] if 1 <= line <= len(L) else None))
    return '%s:%d -- %s' % (f, line, text)


NVM = 'v10/maincpu/audio/note_voice_mapping.s'
ACE = 'v10/maincpu/audio/audio_control_engine.s'
MDH = 'v10/maincpu/midi/midi_dispatch_handlers.s'
DPU = 'v10/maincpu/ui/drawbar_panel_ui.s'
UMH = 'v10/maincpu/ui/ui_mode_handlers.s'
BOR = 'v10/maincpu/ui/bitmap_out_routines.s'
EXT = 'v10/maincpu/extensions/extension_data.s'
ACL = 'v10/maincpu/midi/ac_listener_handlers.s'
DSC = 'v10/maincpu/audio/dsp_config_sysex.s'
SEP = 'v10/maincpu/sequencer/seq_event_playback.s'
GTV = 'v10/maincpu/display/graphics_text_vga.s'
CIC = 'v10/maincpu/midi/computer_interface_config.s'
FFH = 'v10/maincpu/storage/flash_floppy_handlers.s'
SPR = 'v10/maincpu/audio/sndparam_routines.s'
AEN = 'v10/maincpu/sequencer/accompaniment_engine.s'
FDP = 'v10/maincpu/demo/file_demo_proc.s'
NMR = 'v10/maincpu/ui_widgets/naka_midi_reverb.c'
NMS = 'v10/maincpu/ui_widgets/naka_msp_recording.c'
NTP = 'v10/maincpu/ui_widgets/naka_technichord_part.c'
NCM = 'v10/maincpu/ui_widgets/naka_ctrl_menu_body.c'
EVC = 'v10/maincpu/shared/event_codes.s'
V142 = 'v142/subcpu/kn5000_subprogram_v142.s'

LED_ROWS = cite(EXT, 2795, '.byte 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc8',
                'Protocol_values_for_LED_rows: LED-image byte n (ENCODER_STATE_BASE+n) is panel LED row 0xC0,0xC1,0xC2,'
                '0xC3,0xC4,0xC8,0x00,0x01,0x02,0x03,0x04,0x08,0x0A,0x0B,0x0C for n = 0..14 (row bit names: '
                'technics-docs/control-panel-protocol.md, CPR/CPL LED mapping tables)')
CTLMSG_GRID = [
    cite(NMR, 3342, 'ControlMessages_text_2', 'MIDI menu screen CONTROL MESSAGES; its grid box func is 0x01230014 = '
         'CtlMsgGridCheck (:3382)'),
    cite(DPU, 3234, 'CtlMsgGridCheck_Table:24', 'CtlMsgGridCheck edits CtlMsgGridCheck_Table[page*9 + row] (ROM 0xE80386): '
         'page 1 rows 2-8 = 228A 228D 228C 228E 228F 2290 2291, page 2 rows 2-7 = 2294 2295 2296 2298 228B 2299 (rows 0-1 '
         '0xFFFFFFFF); values drawn " ON  " / " OFF " (MidiSetup_TtlDispatch, :3318)'),
    cite(DPU, 3113, 'AcCtlMsgGrid_GetRowText:', 'the row captions are AcCtlMsgGrid_GetRowText_Str (page 1, ROM 0xE80292: '
         '" |-| PRG.CHANGE | BANK SELECT | PITCH BEND | VOLUME | EXPRESSION | PAN | SUSTAIN") and _Page1_Str (page 2, '
         '0xE8030E: " |-| EFFECT & REVERB| MODULATION | TUNING | BEND RANGE | AFTER TOUCH | RESET ALL CONT.")'),
]
COMSET_GRID = [
    cite(NMR, 3641, 'ComSetGridBox_fixedrow', 'MIDI menu screen COMMON SETTING (title :3612; grid func 0x0123000F = '
         'ComSetGridCheck, :3638); row captions 0-8: NOTE ONLY / PRG.CHANGE TO P.MEM / REALTIME SYSEX / INTRO,FILLIN '
         'ENDING / APC CONTROL / FADE IN/OUT / PROGRAM CHANGE MODE / DRUMS TYPE / SONG SELECT'),
    cite(DPU, 218, 'ComSetGridCheck_JumpTable_Table:24', 'ComSetGridCheck edits ComSetGridCheck_JumpTable_Table[row] '
         '(ROM 0xE80016 = 2203 2202 2282 2A001 2A000 229A 2201 2205 2280 for rows 0-8); ON/OFF rows drawn " ON  " / " OFF " '
         '(ComSetGridCheck_ParamDisplay, ComSetGrid_EventHandler :369)'),
]
FILTER_GRID = [
    cite(EXT, 829, 'PmExpFilter_CellKeys:', 'PmExpFilter_CellKeys = 2900 2901 2904 2902 2903 290A 290B 290C 290D '
         '(rows 2-10 of page 2/3) and PmExpFilter_AltKeys (:833) = 290E 2905 2907 2908 290F 2910 2909 2906 2911 (page 3/3)'),
    cite(UMH, 8529, 'ParamStr_Table_01:24', 'PmExpFilter_DrawCellBank1 writes caption ParamStr_Table_01[i] into row i+2 '
         'on page 2/3 (ParamStr_Table_01, extension_data.s:768: RHYTHM SELECTION, TEMPO, APC & MEMORY, SPLIT POINT, '
         'TRANSPOSE, FOOT CONT. SETTING, MIC LEVEL & REVERB, FADE IN/OUT SETTING, R1/R2 OCTAVE)'),
    cite(UMH, 8597, 'ParamStr_Table_02:24', 'PmExpFilter_DrawCellBank2 does the same on page 3/3 with ParamStr_Table_02 '
         '(extension_data.s:787: VOCALIST, MIDI, REVERB, DSP EFFECT, ACOUSTIC ILLUSION, EQUALIZER, PART4-16 SETTING, '
         'KEY SCALE, MSP BANK)'),
    cite(UMH, 8947, 'PmExpFilter_CellKeys:24', 'PmExpFilterGridCheck edits CellKeys[row-2] on page 2/3 and AltKeys[row-2] '
         '(:8957) on page 3/3 -- the same row index and page selector (0x340E2) as the captions; value 0 is drawn "ON", 1 '
         '"OFF" (PmExpFilterCheck_CellDecode :9084)'),
    cite(NCM, 2796, 'ExpandModeFilter_str', 'the grid is the PANEL MEMORY screen\'s EXPAND MODE FILTER'),
    cite(BOR, 1478, 'BitMapOut_SelectiveFieldRestore:', 'BitMapOut_SelectiveFieldRestore reads record 0x98 +7/+8/+9 and, '
         'for each set bit, keeps one group of the live panel over the recalled one; it is called at the end of '
         'PanelMemory_RecallKeepAccompaniment (:924), the EXPAND-mode recall'),
]

P = []   # firm proposals
I = []   # inferred
UNRES = []
OBS = []
WEAK = []


def add(lst, key, name, meaning, evidence, kind='global', conf='firm', extra=None):
    d = DESC[key]
    assert key in UNNAMED or lst is WEAK, hex(key)
    e = dict(key='0x%05X' % key, kind=kind, name=name, record='0x%02X' % d['rec'], byte=d['off'],
             mask='0x%02X' % d['mask'], range='%d..%d' % (d['lo'], d['hi']), alias=d['alias'],
             meaning=meaning, evidence=evidence, confidence=conf)
    if extra:
        e.update(extra)
    lst.append(e)


def add_part(lst, number, field, meaning, evidence, conf='firm', extra=None):
    keys = sorted(k for k in DESC if decode(k) and decode(k)[1] == number)
    assert keys and all(k in UNNAMED for k in keys), hex(number)
    parts = [decode(k)[0] for k in keys]
    recs = sorted({DESC[k]['rec'] for k in keys})
    offs = [DESC[k]['off'] for k in keys]
    shape = {(DESC[k]['mask'], DESC[k]['lo'], DESC[k]['hi']) for k in keys}
    assert len(shape) == 1, (hex(number), shape)
    mask, lo, hi = shape.pop()
    if recs == parts:
        assert len(set(offs)) == 1
        record, byte = 'part (= T)', offs[0]
    elif offs == parts and len(recs) == 1:
        record, byte = '0x%02X' % recs[0], 'part (= T)'
    else:
        assert len(set(offs)) == 1 and recs == [0x44 + t for t in parts], (hex(number), recs, offs)
        record, byte = '0x44 + T', offs[0]
    base = keys[0] - 0x400 * parts[0]
    e = dict(key='0x%05X + 0x400*T' % base, kind='part', number='0x%03X' % number, name=field,
             parts='0x%02X-0x%02X (%d)' % (parts[0], parts[-1], len(parts)), record=record, byte=byte,
             mask='0x%02X' % mask, range='%d..%d' % (lo, hi), aliases=[DESC[k]['alias'] for k in keys],
             meaning=meaning, evidence=evidence, confidence=conf)
    if extra:
        e.update(extra)
    lst.append(e)


# ================================================================ PART FIELDS
APPLY = cite(NVM, 18077, 'SndParam_ApplyEventField:', 'SndParam_ApplyEventField turns a posted (record, byte, value, mask) '
             'into its key, splits it with SndParam_KeyToLswPartNumber and calls SndPart_SetParam(part, number, value)')
add_part(P, 0x078, 'AllSoundOff', 'Per-part MIDI All Sound Off: writing it sends controller 120 with value 0 to the '
         'part (the written value is ignored).', [
    APPLY,
    cite(NVM, 18130, 'cp bc, 0x78', 'SndPart_SetParam dispatches Lsw number 0x78 to SndPart_SetAllSoundOff'),
    cite(NVM, 18341, 'SndPart_SetAllSoundOff:', 'SndPart_SetAllSoundOff = MIDI_SendControlChange(part, 0x78, DE = 0)'),
    cite(NVM, 19211, 'MIDI_SendControlChange:', 'MIDI_SendControlChange builds the [4, 0xB0, channel, controller, value] '
         'packet'),
    cite(NVM, 19662, 'MIDI_SendAllSoundOff:', 'the existing MIDI_SendAllSoundOff sends the same controller 0x78 / value 0 '
         'to parts 0..0x18 -- the parts this descriptor family covers'),
    cite('v10/maincpu/ui_widgets/widget_dispatch.s', 1088, 'SndParam_RO_Dispatch_Data:', 'the descriptors\' '
         'read_accessor is 0, which this table maps to SndParam_ReturnNotFound (sndparam_routines.s:820): the key '
         'cannot be read back, a trigger; record 0xAE has no RAM block and byte = part')])
add_part(P, 0x1B0, 'PitchBend', 'Per-part pitch bend (14-bit, centre 0x2000), sent to the tone generator as a MIDI '
         'pitch-bend message.', [
    APPLY,
    cite(NVM, 18138, 'cp bc, 0x1b0', 'SndPart_SetParam dispatches number 0x1B0 to SndPart_SetRPN (a misleading label)'),
    cite(NVM, 18299, 'SndPart_SetRPN:', 'which calls MIDI_SendPitchBend(part, value)'),
    cite(NVM, 19224, 'MIDI_SendPitchBend:', 'MIDI_SendPitchBend builds [4, 0xE0, channel, value & 0x7F, (value & 0x3FFF) '
         '>> 7]'),
    cite(NVM, 13546, 'ldw de, 0x2000', 'SeqPart_EmitNoteOn_Full_ResetPartControllers (:13515, "resets ... pitch bend '
         '(0x2000)") sends (part, 0x1B0, 0x2000) for parts 0x10..0x13'),
    cite(SPR, 856, 'cp e, 2:i3', 'SndParam_ReadRegWithLUT (read_accessor 2, SndParam_RO_Dispatch_Data widget_dispatch.s:'
         '1088): the 0x81B0 descriptors\' aux index 2 selects RAM 0x8EE8 and this branch rebuilds a 14-bit value capped '
         'at 0x3FFF'),
])
add_part(P, 0x1B2, 'ChannelPressure', 'Per-part channel pressure (aftertouch), sent to the tone generator as a MIDI '
         'channel-pressure message.', [
    APPLY,
    cite(NVM, 18132, 'cp bc, 0x1b2', 'SndPart_SetParam dispatches number 0x1B2 to SndPart_SetPitchBendSens (a misleading '
         'label)'),
    cite(NVM, 18335, 'SndPart_SetPitchBendSens:', 'which calls MIDI_SendChannelPressure(part, value)'),
    cite(NVM, 19242, 'MIDI_SendChannelPressure:', 'MIDI_SendChannelPressure builds [4, 0xD0, channel, 0, value]'),
    cite(ACE, 6673, 'ldw	bc, 0x1b2', 'UIState_RenderBitmapData notifies (part, 0x1B2, 0) when the part\'s AFTER TOUCH '
         'switch (record +12 bit 4 = Lsw 0x606) turns off'),
])
add_part(P, 0x403, 'MidiReceiveOn', 'The part receives MIDI on its channel: only parts with this flag set get incoming '
         'channel messages (stored inverted in part byte +13 bit 7).', [
    cite(MDH, 1056, 'MidiRx_BuildChannelPartLists:', 'MidiRx_BuildChannelPartLists, run with selector 0x80, lists per '
         'channel the parts whose +13 holds that channel and has bit 7 clear (the test at :1099), into RAM 0x94F4/0x9514'),
    cite(MDH, 155, 'MidiRx_ChannelMsgDispatch:', 'MidiRx_ChannelMsgDispatch delivers each incoming 8x..Ex message only to '
         'the parts listed in 0x94F4/0x9514'),
    cite(DPU, 15294, 'ldw	bc, 1027', 'PsMixer_CtlTypeProc8 puts (part, 0x403) = 1 together with (part, 0x402) = 1 '
         'when the channel is stepped up from OFF, and both = 0 when stepped below CH1 (:15315)'),
    cite(DPU, 4060, 'MidiSetup_EventHandler_Table:24', 'the MIDI PART SETTING grid\'s CHANNEL column does the same: if key+1 '
         '(0x402) reads 0 it puts key+1 = 1 and key+2 (0x403) = 1'),
    cite(AEN, 7796, 'AccAutoPlay_SplitDetect_NoSplit:', 'AccAutoPlay_SplitDetect compares an incoming channel with LEFT\'s '
         'and part 0x15\'s +13 only when bit 7 is clear'),
    cite(MDH, 1151, 'PanelEvt_CheckFlag7_Dispatch_A:', 'contrast: the TRANSMIT side tests +13 bit 6 (Lsw 0x402) of parts '
         '0-2 instead (PanelEvt_CheckFlag7_Dispatch_A/B/C), e.g. PanelEvt_Handler_0 then sends 0xC0 | channel (:1269) to '
         'SeqOut_WriteTimedBytes (:2077)'),
    '(d) descriptor mask 0x80, shift 7, xor 0xFF: value 1 <=> bit 7 clear; LocalControl 0x400 and MidiChannelOn 0x402 '
    'are stored inverted the same way'])
add_part(P, 0x404, 'MidiOctave', 'The part\'s OCTAVE setting on the MIDI PART SETTING screen: a 3-bit signed octave '
         'shift, -3..+3.', [
    cite(NMR, 3237, 'MdPartSetGridBox_fixedcol', 'MIDI menu screen PART SETTING (title :3205): columns " PART |CHANNEL|'
         'OCTAVE| LOCAL", rows RIGHT1..PART8 (:3235); grid func 0x01230016 = MidiPartGridCheck'),
    cite(DPU, 4060, 'MidiSetup_EventHandler_Table:24', 'MidiPartGridCheck edits MidiSetup_EventHandler_Table entry '
         '24*page + 3*(row-2) + (col-1); the table (ROM 0xE80520) holds per part T: 0x18001+0x400T (CHANNEL), '
         '0x18004+0x400T (OCTAVE), 0x18000+0x400T (LOCAL)'),
    cite(DPU, 4424, 'Transpose_ValueDisplay_Table:24', 'MidiPart_LookupColumnParam draws the OCTAVE cell as '
         'Transpose_ValueDisplay_Table[value]: 0..3 = "0".."3", 5..7 = "-3".."-1", 4 = "Error" (ROM 0xE80680-0xE806AA)'),
    cite(BOR, 1668, 'BitMapOut_RestoreVoiceChannels:', 'under the EXPAND filter row MIDI (0x2905) the recall keeps every '
         'part\'s +12 bits 0-2 together with its +13 (channel/local/on flags) and record 0x80'),
    '(d) mask 0x07 = 3 bits'])
add_part(P, 0x2C0, 'Perc4', 'DIGITAL DRAWBAR percussion 4\' switch of the part (RIGHT1/RIGHT2/LEFT drawbar record).', [
    cite(DPU, 15538, 'ldw bc, 0x2c0', 'IvDrawbar_LoadVals reads (part, 0x2C0) into the lower switch value (0x247C4)'),
    cite(DPU, 15581, 'NAKA_VIEW_DrawPerc4', 'IvDrawbar_DrawbarUpdate_Lower shows it on view DrawPerc4'),
    cite(DPU, 15681, 'ldw bc, 0x2c0', 'IvDrawbar_Release_Lower writes (part, 0x2C0) with MainLswPartPut'),
    cite(NTP, 5953, '.DrawPerc4 = {', 'DrawPerc4 is the DIGITAL DRAWBAR screen\'s toggle labelled " 4\'" (:5972), beside '
         'the PERCUSSIVE label (:6038)'),
    cite(EVC, 2067, 'NAKA_VIEW_DrawPerc4', 'view "DrawPerc4" = Viewable slot 0xEA entry 2 (firmware view name)')])
add_part(P, 0x2C1, 'Perc2_2_3', 'DIGITAL DRAWBAR percussion 2 2/3\' switch of the part.', [
    cite(DPU, 15534, 'ldw bc, 0x2c1', 'IvDrawbar_LoadVals reads (part, 0x2C1) into the upper switch value (0x247C2)'),
    cite(DPU, 15558, 'NAKA_VIEW_DrawPerc223', 'IvDrawbar_DrawbarUpdate sets view DrawPerc223 and draws White23/Black23'),
    cite(DPU, 15662, 'ldw bc, 0x2c1', 'IvDrawbar_Release_Upper writes (part, 0x2C1)'),
    cite(NTP, 5974, '.DrawPerc223 = {', 'DrawPerc223 is the toggle labelled "2  \'" (:5993) with the "2/3" label (:6008) '
         'drawn into it: 2 2/3\''),
    cite(EVC, 2068, 'NAKA_VIEW_DrawPerc223', 'view "DrawPerc223" = Viewable slot 0xEA entry 3')])

# ================================================================ GLOBALS
add(P, 0x0003, 'SndParam_Transpose', 'TRANSPOSE: 0..11 = -5..+6 semitones, 5 = none.', [
    cite(GTV, 5500, 'AcTranspose_Init:', 'AcTranspose (the TRANSPOSE box) sets its Lsw filter on key 3'),
    cite(GTV, 5518, 'AcTranspose_ShowHide:', 'reads key 3 with MainLswGet on show'),
    cite(GTV, 5548, 'AcTranspose_KeyNameTable:24', 'and draws AcTranspose_KeyNameTable[value] (blank at 5)'),
    cite(ACE, 5714, 'ExtData_ApplyTransposeEvent:', 'ExtData_ApplyTransposeEvent steps record 0x70 +2 within 0..11 and '
         'resets it to 5'),
    cite(BOR, 1587, 'BitMapOut_SelectRestore_CheckBit3:', 'EXPAND filter row TRANSPOSE (0x2903) keeps 0xFD04 = record '
         '0x70 +2')])
add(P, 0x0005, 'SndParam_Tempo_Bit8', 'Bit 8 of the 9-bit tempo (40..300 BPM); key 0x0004 (SndParam_Tempo) is bits 0-7.', [
    cite(ACE, 8293, 'and wa, 0x1ff', 'SeqTimer_UpdateTempoReg reads record 0x48 +8 as a word, keeps 9 bits and accepts '
         '0x28..0x12C (40..300), else resets to 120'),
    cite(ACE, 5359, 'ExtData_SetTempoIfChanged:', 'ExtData_SetTempoIfChanged stores +8 and +9 and posts field 9 with '
         'mask 1 right after field 8'),
    cite(BOR, 1543, 'BitMapOut_SelectRestore_CheckBit1:', 'EXPAND filter row TEMPO (0x2901) keeps 0x48 +8 and +9 together')])
add(P, 0x00C0, 'SndParam_GmOnOff', 'GM mode on/off (stored inverted in record 0x91 +3 bit 2).', [
    cite(UMH, 11845, 'GmOnOff_Return0xC0:', 'GmOnOffFunc (firmware name) answers EVT_GET_LSW_ADDRESS with 0xC0'),
    cite(SEP, 4565, 'ld xwa, 0xc0', 'GMYesFunc (the MIDI menu GM screen\'s YES) writes 0xC0 with MainLswPut'),
    cite(ACE, 982, 'ld	xwa, 192', 'PanelButton_MusicStyleArranger ignores the button while 0xC0 reads 1'),
    cite(DPU, 424, 'ComSetGrid_CheckC0Param:', 'COMMON SETTING draws PROGRAM CHANGE MODE / DRUMS TYPE as "  ----  " and '
         'refuses to edit them while 0xC0 reads 1'),
    cite(NVM, 23335, 'SoundParam_InitDefaultBanks:', 'SoundParam_InitDefaultBanks mode 1 sets 0xC0 = 1 with its own '
         '16-part channel map; modes 0 and 2 clear it')])
add(P, 0x0302, 'SndParam_PanelMemory_Mode', 'PANEL MEMORY MODE: 0 = NORMAL, 1 = EXPAND (EXPAND recall keeps the '
    'accompaniment and applies the EXPAND MODE FILTER).', [
    cite(UMH, 11077, 'PmemModeBoxProc:', 'PmemModeBoxProc, the PANEL MEMORY MODE box (screen title naka_ctrl_menu_body.c:2514)'),
    cite(UMH, 11108, 'ld xwa, 0x302', 'reads key 0x302 on show and redraws on EVT_LSW_DATA for 0x302 (:11121)'),
    cite(UMH, 11293, 'ld xwa, 0x302', 'switch 0x89 puts 0x302 = 0, switch 0x8B puts 0x302 = 1 (:11299)'),
    cite(NCM, 2605, '.editsw = 0x0089', 'switch 0x89 sits at y 77..93 beside label NORMAL (y 78..96, :2643); switch 0x8B '
         '(:2623) at y 161..177 beside EXPAND (y 162..180, :2658)'),
    cite(BOR, 634, 'ld xwa, 0x302', 'PanelMemory_Recall takes PanelMemory_RecallKeepAccompaniment when 0x302 = 1'),
    cite(BOR, 924, 'call nz, (BitMapOut_SelectiveFieldRestore:24)', 'whose end applies the EXPAND MODE FILTER')])
add(P, 0x0400, 'SndParam_MusicStyleArranger_OnOff', 'MUSIC STYLE ARRANGER on/off (drives the panel\'s MUSIC STYLE '
    'ARRANGER LED).', [
    cite(ACE, 3083, 'SndParam_SetResBit4_Via0400:', 'SndParam_SetResBit4_Via0400 copies 0x400 == 1 into LED-image byte 3 '
         'bit 4 = row 0xC3 bit 4 = MUSIC STYLE ARRANGER'),
    LED_ROWS,
    cite(UMH, 10857, 'ld xwa, 0x400', 'MsaModeScreenProc (MUSIC STYLE ARRANGER MODE screen) puts 0x400 = 1 if it reads 0 '
         'when entered from the arranger'),
    cite(UMH, 161, 'PanelTag48_MsaReapply:', 'PanelTag48_MsaReapply re-applies the arranger only when 0x400 is non-zero '
         'and 0x401 is 2 or 3')])
add(P, 0x0401, 'SndParam_MusicStyleArranger_Mode', 'MUSIC STYLE ARRANGER MODE: 1 = RHYTHM, 2 = SOUND&RHYTHM, '
    '3 = PANEL MEMORY.', [
    cite(UMH, 11027, 'MsaMode_OK_Cmd89:', 'MsaModeScreenProc: switches 0x89 / 0x8A (:11033) / 0x8B (:11039) put '
         '0x401 = 1 / 2 / 3'),
    cite(NCM, 2410, '.editsw = 0x0089', 'switches 0x89/0x8A/0x8B (:2410/:2428/:2446) at y 84/126/168 sit beside labels '
         'RHYTHM (:2466, y 86), SOUND&RHYTHM (:2481, y 126) and PANEL MEMORY (y 170)'),
    cite(NCM, 2231, 'MusicStyleArrangerMode_text', 'screen title MUSIC STYLE ARRANGER MODE')])
add(P, 0x2200, 'SndParam_MidiRealtime_Clock', 'MIDI CLOCK source: 0 = INTERNAL, 1 = MIDI (external).', [
    cite(NMR, 3560, 'pman_adr = 0x00002200', 'REALTIME MESSAGES screen (title :3485): ClockBox edits key 0x2200, caption '
         '"CLOCK :" (:3568), texts " INTERNAL " for 0 (:3564) and "   MIDI   " for 1 (:3566)'),
    cite(ACL, 241, 'AcLswFuncEditBoxProc:', 'AcLswFuncEditBoxProc edits the widget\'s pman_adr key (MainLswPut :302) and '
         'draws off_str for 0, on_str for 1')])
add(P, 0x2281, 'SndParam_MidiRealtime_Commands', 'MIDI REALTIME COMMANDS on/off.', [
    cite(NMR, 3528, 'pman_adr = 0x00002281', 'REALTIME MESSAGES screen: RealtimeCommandBox edits key 0x2281, caption '
         '"REALTIME COMMANDS :" (:3536), " OFF " / " ON  "'),
    cite(ACL, 241, 'AcLswFuncEditBoxProc:', 'same widget class as CLOCK')])
add(P, 0x2201, 'SndParam_MidiCommon_ProgramChangeMode', 'MIDI PROGRAM CHANGE MODE: 0 = NORMAL, 1 = TECH, 3 = GM '
    '(2 = "Error!").', COMSET_GRID + [
    cite(DPU, 424, 'ComSetGrid_CheckC0Param:', 'rows 0x2201/0x2205 are drawn NORMAL/TECH/GM for 0/1/3, "Error!" otherwise, '
         'and "  ----  " in GM mode'),
    cite(CIC, 194, 'PcgMode_InvalidReturn:', 'MdPcgModeFunc (firmware name) answers EVT_GET_LSW_ADDRESS with 0x2201 and '
         'draws the same strings (no widget uses it in this build)'),
    cite(SPR, 2722, 'ld	xwa, 8705', 'SndParam_BatchUpdate_Data switches on 0x2201 over 0/1/3')])
add(P, 0x2205, 'SndParam_MidiCommon_DrumsType', 'MIDI DRUMS TYPE: 0 = NORMAL, 1 = TECH, 3 = GM.', COMSET_GRID + [
    cite(CIC, 259, 'DrumType_InvalidReturn:', 'MdDrumTypeFunc (firmware name) answers EVT_GET_LSW_ADDRESS with 0x2205, '
         'strings NORMAL/TECH/GM'),
    cite(NVM, 9622, 'ld xwa, 0x2205', 'the voice setup switches on 0x2205 over 0/1/3')])
add(P, 0x2202, 'SndParam_MidiCommon_PrgChangeToPmem', 'MIDI COMMON SETTING "PRG.CHANGE TO P.MEM" on/off.', COMSET_GRID)
add(P, 0x2203, 'SndParam_MidiCommon_NoteOnly', 'MIDI COMMON SETTING "NOTE ONLY" on/off.', COMSET_GRID + [
    cite(MDH, 7821, 'ld xwa, 0x2203', 'MidiSysEx_SendAllParams returns at once while 0x2203 is non-zero')])
add(P, 0x2280, 'SndParam_MidiCommon_SongSelect', 'MIDI COMMON SETTING "SONG SELECT" on/off (send Song Select).',
    COMSET_GRID + [
    cite(FDP, 8624, 'FileIO_MidiOutSendByte:', 'FileIO_MidiOutSendByte writes 0xF3 (Song Select, :8633) and the song '
         'number to MIDI OUT only when 0x2280 is non-zero')])
add(P, 0x2282, 'SndParam_MidiCommon_RealtimeSysex', 'MIDI COMMON SETTING "REALTIME SYSEX" on/off.', COMSET_GRID + [
    cite(AEN, 6901, 'bit 3, (0xfd56:16)', 'AccPedal_SendCtrl1 (and _2.._4, MidiPkt_ProcessEventQueue) send the panel-'
         'change packet through MidiPkt_DispatchViaTable_4DCE only when record 0x80 +6 bit 3 is set')])
add(P, 0x229A, 'SndParam_MidiCommon_FadeInOut', 'MIDI COMMON SETTING "FADE IN/OUT" on/off.', COMSET_GRID)
CTL = [
    (0x228A, 'ProgramChange', 'PRG.CHANGE', cite(MDH, 966, 'bit	4, (0xfd57:16)', 'MidiRx_ProgramChange is gated on +7 '
     'bit 4, as is the program-change sender PanelEvt_Handler_0 (:1257)')),
    (0x228B, 'AfterTouch', 'AFTER TOUCH', cite(MDH, 1006, 'bit	5, (0xfd57:16)', 'MidiRx_ChannelPressure is gated on +7 '
     'bit 5, as is the MidiTx_PartTargets_ChannelPressure sender (:1812)')),
    (0x228C, 'PitchBend', 'PITCH BEND', cite(MDH, 986, 'bit	6, (0xfd57:16)', 'MidiRx_PitchBend is gated on +7 bit 6, '
     'as is the MidiTx_PartTargets_PitchBend sender (:1741)')),
    (0x228D, 'BankSelect', 'BANK SELECT', cite(MDH, 2037, 'bit 7, (0xfd58:16)', 'MidiCC_ChannelDispatch_DualSend sends '
     'CC0/CC32 (bank select) only with +8 bit 7 set')),
    (0x228E, 'Volume', 'VOLUME', cite(MDH, 1288, 'bit	2, (0xfd58:16)', 'PanelEvt_Handler_3 (MidiTx_PartTargets_CC7_'
     'Volume) is gated on +8 bit 2')),
    (0x228F, 'Expression', 'EXPRESSION', cite(MDH, 1793, 'bit 3, (0xfd58:16)', 'MidiCC_ChannelDispatch_Ctrl3 '
     '(MidiTx_PartTargets_CC11_Expression) is gated on +8 bit 3')),
    (0x2290, 'Pan', 'PAN', cite(MDH, 1350, 'bit	4, (0xfd58:16)', 'PanelEvt_Handler_8 (MidiTx_PartTargets_CC10_Pan) is '
     'gated on +8 bit 4')),
    (0x2291, 'Sustain', 'SUSTAIN', cite(MDH, 1843, 'bit 0, (0xfd58:16)', 'MidiCC_ChannelDispatch_Ctrl0 '
     '(MidiTx_PartTargets_CC64_Sustain) is gated on +8 bit 0')),
    (0x2294, 'EffectReverb', 'EFFECT & REVERB', cite(MDH, 1574, 'bit	5, (0xfd58:16)', 'PanelEvt_D3ASlot1_SendCC91 and '
     'PanelEvt_Handler_5/_7 (CC93 / CC91 senders) are gated on +8 bit 5')),
    (0x2295, 'Modulation', 'MODULATION', cite(MDH, 1774, 'bit 1, (0xfd58:16)', 'MidiCC_ChannelDispatch_Ctrl1 '
     '(MidiTx_PartTargets_CC1_Modulation) is gated on +8 bit 1')),
    (0x2296, 'Tuning', 'TUNING', cite(MDH, 1370, 'bit	1, (0xfd57:16)', 'PanelEvt_Handler_9 (MidiTx_PartTargets_RpnCoarse'
     'Tune) and _10 (RpnFineTune, :1391) are gated on +7 bit 1')),
    (0x2298, 'BendRange', 'BEND RANGE', cite(MDH, 1414, 'bit	0, (0xfd57:16)', 'PanelEvt_Handler_11 (MidiTx_PartTargets_'
     'RpnBendRange) is gated on +7 bit 0')),
    (0x2299, 'ResetAllControllers', 'RESET ALL CONT.', cite(MDH, 1691, 'bit 0, (0xfd59:16)', 'MidiCC_ChannelDispatch_'
     'Ctrl40 (MidiTx_PartTargets_CC121_ResetAll; function 40 = CC121, :2169) is gated on +9 bit 0')),
]
for key, nm, cap, gate in CTL:
    add(P, key, 'SndParam_MidiCtlMsg_' + nm, 'MIDI CONTROL MESSAGES filter "%s" on/off: gates that message type in '
        'both directions.' % cap, CTLMSG_GRID + [gate])
FILT = [
    (0x2900, 'RhythmSelection', 'RHYTHM SELECTION', cite(BOR, 1478, 'BitMapOut_SelectiveFieldRestore:', '+7 bit 0 keeps '
     'record 0x48 +0/+1 (style), the variation bits (+7 & 0x30), +4 bit 4 and +5 bit 1')),
    (0x2901, 'Tempo', 'TEMPO', cite(BOR, 1543, 'BitMapOut_SelectRestore_CheckBit1:', '+7 bit 1 keeps 0x48 +8/+9 (tempo)')),
    (0x2902, 'SplitPoint', 'SPLIT POINT', cite(BOR, 1563, 'BitMapOut_SelectRestore_CheckBit2:', '+7 bit 2 keeps 0x70 +0 '
     'bits 0-1 (split preset 0x4180) and +1 (split note 0x4181)')),
    (0x2903, 'Transpose', 'TRANSPOSE', cite(BOR, 1587, 'BitMapOut_SelectRestore_CheckBit3:', '+7 bit 3 keeps 0x70 +2 '
     '(transpose 0x0003)')),
    (0x2904, 'ApcMemory', 'APC & MEMORY', cite(BOR, 1599, 'BitMapOut_SelectRestore_CheckBit4:', '+7 bit 4 keeps 0x48 +3 '
     'bits 0-3 (APC mode 0x28080, APC MEMORY 0x28081) and 0x90 +3 bits 0-1 (LEFT HOLD 0x28082, ON BASS 0x28083)')),
    (0x2905, 'Midi', 'MIDI', cite(BOR, 1668, 'BitMapOut_RestoreVoiceChannels:', '+7 bit 5 keeps every part\'s +12 bits 0-2 '
     'and +13 and record 0x80')),
    (0x2906, 'KeyScale', 'KEY SCALE', cite(BOR, 2183, 'BitMapOut_RestoreExtra_CheckBit6:', '+7 bit 6 keeps record 0x92 '
     '(scale tune)')),
    (0x2907, 'Reverb', 'REVERB', cite(BOR, 1649, 'BitMapOut_SelectRestore_CheckEffBit:', '+7 bit 7 keeps record 0x63 '
     '(DIGITAL REVERB slot)')),
    (0x2908, 'DspEffect', 'DSP EFFECT', cite(BOR, 1628, 'BitMapOut_SelectRestore_CheckVolBit:', '+8 bit 0 keeps record '
     '0x61 (DSP EFFECT slot)')),
    (0x2909, 'Part4To16', 'PART4-16 SETTING', cite(BOR, 2111, 'BitMapOut_RestoreChannels_CheckParts:', '+8 bit 1 keeps '
     'the part records from 0xFA04 (part 3) on, 13 parts')),
    (0x290A, 'FootCtrl', 'FOOT CONT. SETTING', cite(BOR, 2202, 'BitMapOut_RestoreExtra_CheckConfigBit:', '+8 bit 2 keeps '
     'record 0x99 (foot controllers)')),
    (0x290B, 'MicLevelReverb', 'MIC LEVEL & REVERB', cite(BOR, 2221, 'BitMapOut_RestoreExtra_CheckDataBit:', '+8 bit 3 '
     'keeps record 0x43 +0/+1 (mic) and record 0x66 (mic reverb slot)')),
    (0x290C, 'FadeInOut', 'FADE IN/OUT SETTING', cite(BOR, 2252, 'BitMapOut_RestoreExtra_CheckMiscBit:', '+8 bit 4 keeps '
     'record 0x70 +5/+6/+7 (fade settings 0x2A00/0x2A01/0x2A10-12)')),
    (0x290D, 'R1R2Octave', 'R1/R2 OCTAVE', cite(BOR, 2292, 'BitMapOut_RestoreExtra_CheckPanBit:', '+8 bit 5 keeps 0xFC6A '
     '= record 0x90 +4 (R1/R2 octave 0x40E0)')),
    (0x290E, 'Vocalist', 'VOCALIST', cite(BOR, 2304, 'BitMapOut_RestoreExtra_CheckCtrlBit:', '+8 bit 6 keeps record 0x47 '
     '(vocalist); PanelMemory_Recall_CheckActive (bitmap_out_routines.s:671) resends the vocalist SysEx when this bit is 0')),
    (0x290F, 'AcousticIllusion', 'ACOUSTIC ILLUSION', cite(BOR, 2323, 'BitMapOut_RestoreExtra_CheckLevelBit:', '+8 bit 7 '
     'keeps record 0x60 +1 bit 6 (0x4004) and record 0x65 (acoustic illusion slot)')),
    (0x2910, 'Equalizer', 'EQUALIZER', cite(BOR, 2353, 'BitMapOut_RestoreExtra_CheckExpBit:', '+9 bit 0 keeps record 0x60 '
     '+1 bit 5 (0x4006) and record 0x64 (equalizer slot)')),
    (0x2911, 'MspBank', 'MSP BANK', cite(BOR, 2278, 'BitMapOut_RestoreExtra_CheckFlagBits:', '+9 bit 1 keeps 0xFD12 = '
     'record 0x72 +6')),
]
for key, nm, cap, grp in FILT:
    add(P, key, 'SndParam_PmemFilter_' + nm, 'Panel memory EXPAND MODE FILTER row "%s": 0 (drawn ON) = recalled, '
        '1 (OFF) = the live setting is kept.' % cap, FILTER_GRID + [grp])
FADEGRID = [
    cite(NMR, 6886, 'FadeInOutGridBox_fixedrow', 'FADE IN/OUT SETTING screen (title :6857): rows " ", "Time", " ", "Time", '
         '"Auto reset", "Rhythm Auto stop", "SEQ Auto stop"; the FADE IN label (:6890, y 38-56) sits in row 0 and FADE OUT '
         '(:6905, y 90-108) in row 2 of the grid at y 30..210 (:6859)'),
    cite(ACL, 807, 'Data_FadeSetGridDispatch_Table:24', 'FadeSetGridCheck edits Data_FadeSetGridDispatch_Table[row] (ROM '
         '0xE7F972 = FFFFFFFF 2A00 FFFFFFFF 2A01 2A12 2A10 2A11); times drawn " %2d measure ", flags " ON  "/" OFF "'),
]
add(P, 0x2A00, 'SndParam_FadeIn_Time', 'FADE IN time in measures (1..16).', FADEGRID + [
    cite(DSC, 2257, 'ld xwa, 0x2a00', 'the fade engine scales 0x2A00 by the tempo (key 4) into the fade-in step '
         '(CompIface_ScaleAndNormalize; DSPCfg_ScaleFactor_Update :2319 redoes it on tempo change)')])
add(P, 0x2A01, 'SndParam_FadeOut_Time', 'FADE OUT time in measures (1..16).', FADEGRID + [
    cite(DSC, 2267, 'DSPCfg_CompParam_SubType6:', 'scales 0x2A01 by the tempo into the fade-out step')])
add(P, 0x2A10, 'SndParam_FadeOut_RhythmAutoStop', 'FADE OUT "Rhythm Auto stop" on/off.', FADEGRID + [
    cite(DSC, 2285, 'ld xwa, 0x2a10', 'copied into fade control byte 0xC1F0 bit 4')])
add(P, 0x2A11, 'SndParam_FadeOut_SeqAutoStop', 'FADE OUT "SEQ Auto stop" on/off.', FADEGRID + [
    cite(DSC, 2295, 'ld xwa, 0x2a11', 'copied into fade control byte 0xC1F0 bit 5')])
add(P, 0x2A12, 'SndParam_FadeOut_AutoReset', 'FADE OUT "Auto reset" on/off.', FADEGRID + [
    cite(DSC, 2305, 'ld xwa, 0x2a12', 'copied into fade control byte 0xC1F0 bit 6')])
add(P, 0x4005, 'SndParam_Fade_Level', 'Current FADE IN/OUT level (0..127), ramped by the fade engine and applied as '
    'the output gain\'s fade stage.', [
    cite(DSC, 1978, 'CompIface_RampUp_Clamp:', 'the fade-in ramp writes 0x4005 and, at 127, ends the fade and puts '
         '0x40C0 = 0 (:1989)'),
    cite(DSC, 2009, 'CompIface_RampDown_Clamp:', 'the fade-out ramp writes 0x4005 down to 0'),
    cite(NVM, 26278, 'SendPartDataBlock_Block3:', '0x4005 (SndParam_ApplySystemParam field 5) goes to the sub-CPU as COMM '
         'packet 6'),
    cite(V142, 44965, 'DSP_Set_FadeLevel:', 'sub-CPU global sub-command 6 = DSP_Set_FadeLevel: stores it and recomputes '
         'the DSP2 output gain (DSP_MixerCoeff_Compute)')])
add(P, 0x40C0, 'SndParam_FadeIn_OnOff', 'FADE IN on/off (the panel FADE IN LED).', [
    cite(ACE, 3397, 'MidiChanged_ProcessGroup3_Data_Target9:', 'sets LED-image byte 0 bit 5 = row 0xC0 bit 5 = FADE IN '
         'when 0x40C0 reads 1'), LED_ROWS,
    cite(DSC, 1989, 'ld xwa, 0x40c0', 'the fade-in ramp clears 0x40C0 when the level reaches 127')])
add(P, 0x40C1, 'SndParam_FadeOut_OnOff', 'FADE OUT on/off (the panel FADE OUT LED).', [
    cite(ACE, 3411, 'CtrlPanel_SetResBit6_ViaLookup:', 'sets LED-image byte 0 bit 6 = row 0xC0 bit 6 = FADE OUT when '
         '0x40C1 reads 1'), LED_ROWS])
add(P, 0x40E0, 'SndParam_R1R2Octave', 'RIGHT1/RIGHT2 OCTAVE as a note offset: 64 = 0, 52/40 = -1/-2, 76/88 = +1/+2 '
    'octaves.', [
    cite(SEP, 4835, 'R12Octave_ReturnParamId:', 'R12OctaveFunc (firmware name) answers EVT_GET_LSW_ADDRESS with 0x40E0'),
    cite(NMR, 2035, '.func = 0x01230007', 'used by the "OCTAVE   :" edit box (:2039) of the RIGHT1/RIGHT2 OCTAVE screen '
         '(:2014)'),
    cite(ACE, 3426, 'CtrlPanel_MultiWayBitManip_ViaE0:', 'lights row 0x0B bit 1 (R1/R2 OCTAVE -) for 40/52, bit 2 (+) for '
         '76/88, neither for 64'), LED_ROWS])
add(P, 0x4100, 'SndParam_Conductor', 'CONDUCTOR part selection (which of RIGHT1/RIGHT2/LEFT play): 0..5 = R1, R2, '
    'R1+R2, all, R1+L, R2+L.', [
    cite(ACE, 2864, 'SndParam_TableLookup_Via4100:', 'puts AudioCtl_SmallTables[0x4100] into bits 4-6 of LED-image byte 10 '
         '= row 0x04 bits 4-6 = COND: LEFT / RIGHT 2 / RIGHT 1'),
    cite(EXT, 2806, 'AudioCtl_SmallTables:', 'the table is {4, 2, 6, 7, 5, 3}'), LED_ROWS])
add(P, 0x4140, 'SndParam_Mic_ReverbOnOff', 'MIC reverb on/off (enable of DSP slot 3, ROOM/KARAOKE/BATH ROOM/STAGE).', [
    cite(NVM, 18521, 'SndParam_ApplySystemParam_SendEqualizerOnOff_Skip9:', 'SndParam_ApplySystemParam queues 0x4140 in '
         'RAM 0xCFCE'),
    cite(NVM, 26348, 'SendPartDataBlock_ClearByte3:', 'which Song_SendPartDataBlocks sends as COMM packet 0x24'),
    cite(V142, 45060, 'DSP_Set_MicReverbOnOff:', 'sub-CPU global sub-command 0x24 links/unlinks EFF slot 3 into the chain'),
    cite(BOR, 2221, 'BitMapOut_RestoreExtra_CheckDataBit:', 'the EXPAND filter row captioned MIC LEVEL & REVERB (0x290B) '
         'keeps record 0x43 (this byte) with record 0x66 (slot 3)')])
add(P, 0x4180, 'SndParam_SplitPoint_Preset', 'SPLIT POINT preset: 0 = free (key-set), 1 = LEFT, 2 = CENTER, 3 = RIGHT.', [
    cite(ACE, 5698, 'SplitPoint_LedMaskByPreset:24', 'ExtData_Voice_MixedHandler maps (0xFD02 & 3) through '
         'SplitPoint_LedMaskByPreset = {0, 1, 2, 4} (extension_data.s:3415) into row 0xC4 bits 4-6 = SPLIT POINT '
         'LEFT/CENTER/RIGHT (via SndParam_MaskShiftMerge_8F58, audio_control_engine.s:3053)'),
    cite(SEP, 4636, 'ld xwa, 0x4180', 'SplitPointFunc sets 0x4180 = 0 when a key is played on the SPLIT POINT screen'),
    cite(BOR, 1563, 'BitMapOut_SelectRestore_CheckBit2:', 'EXPAND filter row SPLIT POINT keeps 0x70 +0 bits 0-1 with +1'),
    LED_ROWS])
add(P, 0x4181, 'SndParam_SplitPoint_Note', 'SPLIT POINT note number (21..108).', [
    cite(SEP, 4746, 'SplitPoint_ReturnParamId:', 'SplitPointFunc (firmware name) answers EVT_GET_LSW_ADDRESS with 0x4181'),
    cite(NMR, 7038, '.func = 0x01230036', 'it drives the AcLswBox of the SPLIT POINT screen (title :6996)')])
add(P, 0x4200, 'SndParam_TechniChord_OnOff', 'TECHNI-CHORD on/off (the panel TECHNI CHORD LED).', [
    cite(ACE, 3037, 'SndParam_SetResBit7_Via4200:', 'sets LED-image byte 10 bit 7 = row 0x04 bit 7 = TECHNI CHORD when '
         '0x4200 reads 1'), LED_ROWS,
    cite(DPU, 9781, 'Sdtecd_InitCase3:', 'the TECHNI-CHORD screen puts 0x4200 = 1 when entered')])
add(P, 0x4202, 'SndParam_TechniChord_Type', 'TECHNI-CHORD type: 0 CLOSE, 1 OPEN1, 2 OPEN2, 3 DUET2, 4 COUNTRY, '
    '5 THEATRE, 6 HYMN, 7 BLOCK, 8 BIG BAND BRASS, 9 BIG BAND REEDS, 10 OCTAVE, 11 HARD ROCK, 12 FANFARE, 13 DUET1.', [
    cite(DPU, 9856, 'Sdtecd1_TypeButtonView:24', 'IvSdtecd1Proc gives dial focus to Sdtecd1_TypeButtonView[0x4202] and '
         'steps 0x4202 with MainLswAdd; the table (ROM 0xE9D9CC) = views 0xD000A 0xD000B 0xD000C 0xD000E 0xD000F 0xD0010 '
         '0xD0011 0xD0015 0xD0012 0xD0013 0xD0014 0xD0016 0xD0017 0xD000D'),
    cite(NTP, 1634, 'element 10 of Viewable slot 0xD "TcClose"', 'Viewable slot 0xD elements 10..23 are TcClose, TcOpen1, '
         'TcOpen2, TcDuet1, TcDuet2, TcCountry, TcTheatre, TcHymn, TcBigBandBrass, TcBigBandReeds, TcOctave, TcBlock, '
         'TcHardRock, TcFanfare (to :1673)')])
SLOTS = cite(BOR, 2221, 'BitMapOut_RestoreExtra_CheckDataBit:', 'slot record groups kept by the EXPAND filter rows: '
             'MIC LEVEL & REVERB -> record 0x66, ACOUSTIC ILLUSION (:2323) -> record 0x65 with the 0x4004 bit, EQUALIZER '
             '(:2353) -> record 0x64 with the 0x4006 bit')
add(P, 0x4C00, 'SndParam_Equalizer_Algorithm', 'Algorithm byte of the EQUALIZER DSP slot (slot 4; 79 = GEQ).', [SLOTS,
    'analysis/disk-format-probes/README-lsw-leftover-records.md section 1 (prior work, same ROM): SlotToTag 61 63 65 66 64 '
    'and DSPCfg_SlotAcceptsAlgorithm give slot 4 = tag 0x64 = EQUALIZER, byte 0 = algorithm; EQPreset_Load writes tag '
    '0x64 then notifies 0x4006'])
add(P, 0x4D00, 'SndParam_AcousticIllusion_Algorithm', 'Algorithm byte of the ACOUSTIC ILLUSION DSP slot (slot 2: '
    'STANDARD/PERCUSSIVE/SYMPHONIC/DEEP SPACE).', [SLOTS, 'README-lsw-leftover-records.md section 1: slot 2 = tag 0x65, '
    'algorithms 57..60'])
add(P, 0x4E00, 'SndParam_MicReverb_Algorithm', 'Algorithm byte of the MIC reverb DSP slot (slot 3: ROOM/KARAOKE/BATH '
    'ROOM/STAGE).', [SLOTS, 'README-lsw-leftover-records.md section 1: slot 3 = tag 0x66, algorithms 88..91; the filter '
    'caption MIC LEVEL & REVERB is the title binding that note lacked'])
add(P, 0x4001, 'SndParam_TotalExpression', 'TOTAL EXPRESSION level (0..127): the expression pedal when assigned to '
    'TOTAL EXPRESSION, forced to 127 otherwise; one stage of the master output gain.', [
    cite(EXT, 708, 'CtrlAssignStr_TotalExpression', 'foot-controller function code 0xB6 (182) is "TOTAL EXPRESSION" and '
         '0xB7 (183) "PART EXPRESSION" (FswAssign_FunctionCodes :672 / FswAssign_FunctionNames :675, entries 29/30)'),
    cite(ACE, 4150, 'cp (0xfd32:16), 182', 'Audio_ReinitToneGenAndOutput writes 0x7F to record 0xB0 +1 (key 0x4001) unless '
         'the expression pedal function (0x2880) is 182'),
    cite(ACE, 4193, 'Audio_CheckAndReinitReverb:', 'and puts 0x4001 = 127 when the pedal function is 183 (PART EXPRESSION), '
         'whose events PanelAction_ModWheel (:1236) reroutes to the per-part record 0xB3'),
    cite(MDH, 2316, '0xb0, 0x01, 0x7f', 'received CC11 for part 25 (0x19, the mixer\'s CTRL channel) is mapped to record 0xB0 +1 by the receive '
         'table MidiCC_PartTargets_CC11_Expression (:2309, entry 25 of 32)'),
    cite(V142, 44951, 'DSP_Set_MixParam_45B4:', 'sub-CPU global sub-command 2 (0x4001 is ApplySystemParam field 1 -> COMM 2) '
         'is the curve index BC of DSP_MixerCoeff_Compute, the DSP2 output gain')])
add(P, 0x28000, 'SndParam_Style_Number', 'Current rhythm style number (low byte; with Style_Bank it selects the style).', [
    cite(AEN, 11589, 'AccHelper_ComputeVoiceOffset:', 'AccHelper_ComputeVoiceOffset calls PartCtrl_WriteProgramChange for '
         'tag 0x48 with L = record 0x48 +0 and H = +1 & 7, the program/bank pair the part records use'),
    cite(ACE, 8087, 'PartCtrl_WriteProgramChange:', 'PartCtrl_WriteProgramChange stores L (program) at 0x90EA, H (bank) at '
         '0x90EB'),
    cite(ACE, 3314, 'MidiChanged_ProcessGroup2_Data_Target0:', 'resolves (0x28000, 0x28001) with SndParam_ResolveVoiceEntry '
         'and lights the style\'s rhythm-group LED (rows 0xC1/0xC2)'),
    cite(BOR, 1478, 'BitMapOut_SelectiveFieldRestore:', 'EXPAND filter row RHYTHM SELECTION keeps 0x48 +0/+1')])
add(P, 0x28001, 'SndParam_Style_Bank', 'Current rhythm style bank (0..7); same shape as the part records\' Bank field.', [
    cite(AEN, 24644, 'DrumKit_PostMidiEvents:', 'DrumKit_PostMidiEvents posts (0x48, +1, & 0x7F) and (0x48, +0) and calls '
         'PartCtrl_WriteProgramChange with H = +1, L = +0'),
    cite(AEN, 11589, 'AccHelper_ComputeVoiceOffset:', 'H = +1 & 7 is the bank of the style program change'),
    '(d) record 0x48 +1, mask 0x7F, range 0..7: identical to SndParam_PartTT_Bank (+1, 0x7F, 0..7)'])
add(P, 0x28002, 'SndParam_Style_Variation', 'VARIATION 1-4 of the current style (0..3).', [
    cite(ACE, 3003, 'SndParam_VoiceEntryLookup_ViaReg8000:', 'lights VARIATION LED 1 << 0x28002 in row 0xC3 bits 0-3 for '
         'ordinary styles'), LED_ROWS,
    cite(ACE, 1091, 'ld	(xde), 48', 'PanelButton_Variation posts the pressed variation with mask 0x30 (this field)')])
add(P, 0x28080, 'SndParam_Apc_Mode', 'AUTO PLAY CHORD mode: 0 = off, 1 = ONE FINGER, 2 = FINGERED, 3 = PIANIST.', [
    cite(FFH, 6782, 'AcApcMdBox_HandleTitleDisp:', 'AcApcMdBoxProc puts 0x28080 = its apcdata when selected and highlights '
         'when 0x28080 equals it (:6750)'),
    cite(NMS, 1684, '.apcdata = 0x01', 'AUTO PLAY CHORD screen (title :1663): apcdata 1/2/3 (:1684/:1709/:1734) are the '
         'boxes ONE FINGER (:1688), FINGERED (:1713), PIANIST (:1738)'),
    cite(ACE, 2985, 'SndParam_SetResBit5_Via028080:', 'lights row 0xC3 bit 5 = AUTO PLAY CHORD whenever 0x28080 != 0'),
    LED_ROWS])
add(P, 0x28081, 'SndParam_Apc_Memory', 'AUTO PLAY CHORD "MEMORY" on/off.', [
    cite(NMS, 1754, '.pman_ad = 0x00000000', 'toggle ApcMem (pman_ad 0) with texts " MEMORY : OFF" / " MEMORY : ON" '
         '(:1757/:1759), func ApcOnOffFunc'),
    cite(FFH, 6589, 'ld xwa, 0x28081', 'AcApcToggle_HandleOpen reads 0x28081 for pman_ad 0'),
    cite(FFH, 6676, 'ApcOnOffFunc:', 'ApcOnOffFunc puts 0x28081 on EVT_SET_PARAM')])
add(P, 0x28083, 'SndParam_Apc_OnBass', 'AUTO PLAY CHORD "ON BASS" on/off.', [
    cite(NMS, 1775, '.pman_ad = 0x00000001', 'toggle ApcOnBass (pman_ad 1) with texts "ON BASS : OFF" / "ON BASS : ON" '
         '(:1778), func ApcOnBasFunc'),
    cite(FFH, 6592, 'AcApcToggle_SetParam83:', 'AcApcToggle_HandleOpen reads 0x28083 for pman_ad 1'),
    cite(FFH, 6688, 'ApcOnBasFunc:', 'ApcOnBasFunc puts 0x28083 on EVT_SET_PARAM')])

# ================================================================ INFERRED
add(I, 0x4000, 'SndParam_MainVolume', 'Probably the MAIN VOLUME slider level: the other master-gain stage beside TOTAL '
    'EXPRESSION and the fade level.', [
    cite(V142, 44941, 'DSP_Set_MixParam_45B2:', 'sub-CPU global sub-command 1 (0x4000 = ApplySystemParam field 0 -> COMM 1) '
         'is index WA of DSP_MixerCoeff_Compute, multiplied with TOTAL EXPRESSION (0x4001) and the fade level (0x4005)'),
    cite(SPR, 849, 'SndParam_ReadRegWithLUT:', 'the 0x4000 descriptor\'s aux index 1 reads RAM 0x8EE6 (analog ID 27); '
         'the other sources are 0x8EE4 (TOTAL EXPRESSION 0x4001), 0x8EE8 (part pitch bend, 14-bit), 0x8EEA (part '
         'modulation), 0x8EF4 (part channel pressure)')],
    conf='inferred', extra=dict(would_confirm='Show that panel analog ID 27 (Encoder_ProcessExpression, RAM 0x8EE6) is '
    'the MAIN VOLUME slider, e.g. a panel capture or the service manual, or find a screen or test routine that labels '
    'RAM 0x8EE6 as volume.'))
add(I, 0x4A00, 'SndParam_DigitalReverbAlt_Algorithm', 'Algorithm byte of a second DSP namespace (0x4Axx, record 0x62 '
    'with no RAM block) that shares slot 1 (DIGITAL REVERB).', [
    'analysis/disk-format-probes/README-lsw-leftover-records.md section 1: DSPCfg_Data_ParamDispatch maps tag -> '
    '(namespace, slot) through 0xEE6384; "0x62 has no panel record and shares slot 1"',
    cite(NVM, 18356, 'SndParam_ApplySystemParam:', 'SndParam_ApplySystemParam handles namespaces 0x49, 0x4B-0x4E but not '
         '0x4A, so this key is never sent from there')],
    conf='inferred', extra=dict(would_confirm='A reader or writer of key 0x4A00 / record 0x62 (none found by key '
    'literal in v10) that says what the alternate slot-1 namespace is used for.'))

# ================================================================ UNRESOLVED (no firm or plausible meaning)
UNRES += [
    dict(keys='0x18205 + 0x400*T (Lsw 0x605), parts 0x00-0x19', where='part byte +22 bit 0',
         known='No reader of number 0x605 (also searched in decimal, 1541) and no access to byte +22; '
               'SndPart_SetParam ignores it. README-lsw-part-record-fields.md calls +22 the only declared bit no code touches.'),
    dict(keys='0x08221 / 0x08621 / 0x08A21 (Lsw 0x221)', where='drawbar records 0x44-0x46 +8 low nibble, range 0..1',
         known='Not in the drawbar screen\'s 15-entry control table (MainMemDrawControl) and no reader of byte +8; '
               'the screen\'s TREMOLO SLOW/FAST is the global 0x4003.'),
    dict(keys='0x00C1', where='record 0x91 +3 bit 0 (inverted)',
         known='Set to 1 only by SoundParam_InitDefaultBanks mode 2 (note_voice_mapping.s:23449), which clears GM '
               '(0xC0) and loads its own channel map. Mode 2 is used by Epilogue_Prologue/_2 (:22111) from a file-kind '
               'dispatch (SeqVoice_PopIzReturn_Prologue, :19934 area). Sent as F0 50 99 0/127. A tone-generator mode '
               'exclusive with GM, not named.'),
    dict(keys='0x00301', where='record 0x98 +1 bit 7 (beside the panel-memory number 0x300)',
         known='BitMapOut_ByteData_PresetCopy (bitmap_out_routines.s:374) does a full PanelMemory_Recall on a '
               'panel-memory number change when 0x301 = 0, else BitMapOut_CopyVoicePreset9 (parts 0-2 bytes +14/+15/+17 only).'),
    dict(keys='0x04080, 0x04081', where='record 0x98 +2 bits 7, 6',
         known='0x4080 is sent as F0 50 85 <v> (sub-CPU Voice_SystemMsg 0x85, labelled Voice_SetKeyShiftEnable there, a '
               'guessed name) and cleared at demo setup (file_demo_proc.s:933, mislabelled Timer7_DisableInterrupt). '
               'FswAsIniFunc clears it. No reader of 0x4081 found.'),
    dict(keys='record 0x99 flags 0x2882, 0x2887, 0x2889, 0x288B, 0x288D, 0x288F, 0x2891, 0x2893, 0x2895, 0x2897, '
              '0x2899, 0x289B, 0x289D; function bytes 0x2881 (+3), 0x2892/0x2894/0x2896/0x2898/0x289A/0x289C (+10..+15)',
         where='record 0x99',
         known='Each odd key is a 1-bit companion of the function byte at key-1. The FOOT CONTROLLERS grid and the '
               'PanelAction_FootSwitch*/FootController* handlers read only 0x2880/0x2886..0x2890. No reader of the flag '
               'bits or the unshown bytes except the whole-record copy under the FOOT CONT. SETTING filter row.'),
]

# ================================================================ OBSERVATIONS on already-named keys / labels
OBS += [
    dict(subject='0x4003, named SndParam_DigitalEffectOnOff in round 2',
         finding='It reaches the sub-CPU as COMM 0x23 (0xCFC8 -> SendPartDataBlock_Block7, note_voice_mapping.s:26332), '
                 'which is DSP_Set_RotarySpeed (v142 :45049). That routine applies the value only when slot 0\'s algorithm '
                 'is 15 ROCK ROTARY or 53 ROTARY SPEAKER. The DIGITAL DRAWBAR screen shows 0x4003 on its DrawTremolo view '
                 '(DrawbarNorm_Update, drawbar_panel_ui.s:17453), the TREMOLO SLOW/FAST control. It looks like the '
                 'rotary-speaker speed switch, not a digital-effect on/off.'),
    dict(subject='0x402, named _MidiChannelOn in round 2',
         finding='It is the TRANSMIT gate (+13 bit 6: PanelEvt_CheckFlag7_Dispatch_A/B/C, MidiCC_ChannelDispatch_DualSend, '
                 'PanelEvt_Handler_0). 0x403 is the RECEIVE gate. The KN5000 UI always sets the two together, so '
                 '"MidiChannelOn" is not wrong, but _MidiTransmitOn would mirror _MidiReceiveOn.'),
    dict(subject='misleading code labels met on the way',
         finding='SndPart_SetRPN sends pitch bend (0x1B0); SndPart_SetPitchBendSens sends channel pressure (0x1B2); '
                 'SndPart_SetCoarseTune / _SetFineTune / _SetPitchBendRange handle 0x603 GlidePedal / 0x602 KeyScaling / '
                 '0x600 SustainLength; SndPart_SetBankMSB / _BankLSB / _BankSelect handle 0x80 BendRange / 0x81 Tuning / '
                 '0x82 KeyShift. DSPCfg_Compressor* are the fade-setting handlers (0x2A00..0x2A12). CompIface_* is the fade '
                 'engine. Timer7_DisableInterrupt clears 0x4080. PanelAction_ModWheel handles the expression-pedal event '
                 '(0x2880 = 182/183).'),
    dict(subject='encoder RAM names in midi_encoder_constants.s',
         finding='The virtual-record read accessor (SndParam_ReadRegWithLUT) disagrees with several names. '
                 'MIDI_CC_MODWHEEL_VALUE 0x8EE4 is the value behind TOTAL EXPRESSION 0x4001. MIDI_CC_BREATH_VALUE 0x8EE8 '
                 'is decoded as 14-bit part pitch bend. 0x8EEA (FOOT) feeds part Modulation. MIDI_CC_VOLUME_VALUE 0x8EF4 '
                 'feeds part channel pressure, and Encoder_ProcessVolume clamps it by a threshold (the aftertouch '
                 'threshold?). The docs\' encoder-ID table probably needs re-checking.'),
]

# ================================================================ weak NakaInst_* names (not in the 259, offered separately)
add(WEAK, 0x2A000, 'SndParam_MidiCommon_ApcControl', 'MIDI COMMON SETTING "APC CONTROL" on/off (gates CC80 output).',
    COMSET_GRID + [cite(MDH, 1475, 'bit	5, (0xfd59:16)', 'PanelEvt_D6Slot3_SendCC80 is gated on record 0x80 +9 bit 5')])
add(WEAK, 0x2A001, 'SndParam_MidiCommon_IntroFillInEnding', 'MIDI COMMON SETTING "INTRO,FILLIN ENDING" on/off (gates '
    'CC82 output).', COMSET_GRID + [cite(MDH, 1497, 'bit	6, (0xfd59:16)', 'PanelEvt_D6Slot5_SendCC82 is gated on '
                                         'record 0x80 +9 bit 6')])
add(WEAK, 0x28103, 'SndParam_Style_SynchroBreak', 'SYNCHRO & BREAK state (panel LED).', [
    cite(ACE, 2969, 'SndParam_SetResBit0_Via028103:', 'lights LED-image byte 13 bit 0 = row 0x0B bit 0 = SYNCHRO & BREAK '
         'when 0x28103 reads 1'), LED_ROWS])
add(WEAK, 0x28100, 'SndParam_Style_FillIn', 'FILL IN state: 1 / 2 light FILL IN 1 / FILL IN 2.', [
    cite(ACE, 2752, 'SndParam_SetResBit0_Via028100:', 'row 0xC4 bit 0 (FILL IN 1) when 0x28100 = 1; bit 1 (FILL IN 2) when '
         '0x28100 = 2 (SndParam_SetResBit1_ViaRegs0100_0101, :2768)'), LED_ROWS])
add(WEAK, 0x28102, 'SndParam_Style_Ending', 'ENDING state: 1 / 2 light INTRO & ENDING 1 / 2.', [
    cite(ACE, 2788, 'SndParam_SetResBit2_ViaRegs0101_0102:', 'row 0xC4 bit 2 (INTRO & ENDING 1) when 0x28102 = 1 (or '
         '0x28101 = 2); bit 3 (INTRO & ENDING 2) when 0x28102 = 2 (or 0x28101 = 3, :2810)'), LED_ROWS])

for e in WEAK:
    e['current_name'] = e.pop('alias')


def dump(name, obj):
    with open(os.path.join(HERE, name), 'w') as f:
        json.dump(obj, f, indent=1)
        f.write('\n')


# ---------------------------------------------------------------- consistency checks and output
names = [e['name'] for e in P + I]
assert len(names) == len(set(names)), 'duplicate proposed name'
elfnames = set(syms)
for e in P + I + WEAK:
    if e['kind'] == 'part':
        for t in range(0x1A):
            assert 'SndParam_Part%02X_%s' % (t, e['name']) not in elfnames, e['name']
    else:
        assert e['name'] not in elfnames, e['name']
covered = set()
for e in P + I:
    if e['kind'] == 'part':
        covered |= {k for k in DESC if decode(k) and decode(k)[1] == int(e['number'], 16)}
    else:
        covered.add(int(e['key'], 16))
assert covered <= UNNAMED
nfirm = sum(len(e['aliases']) if e['kind'] == 'part' else 1 for e in P)
ninf = sum(len(e['aliases']) if e['kind'] == 'part' else 1 for e in I)
meta = dict(snapshot_commit=COMMIT, note='file:line citations are against the git archive of this commit (the working '
            'tree was being edited by other agents during the research); every citation was machine-checked to contain '
            'its quoted token by build_proposals.py')
dump('proposals.json', [meta] + P)
dump('inferred.json', [meta] + I)
dump('unresolved.json', [meta] + UNRES)
dump('observations.json', [meta] + OBS)
dump('proposals_weak_names.json', [meta] + WEAK)
print('snapshot %s' % COMMIT)
print('firm proposals: %d entries covering %d descriptors (%d part fields, %d globals)'
      % (len(P), nfirm, sum(e['kind'] == 'part' for e in P), sum(e['kind'] == 'global' for e in P)))
print('inferred: %d entries covering %d descriptors' % (len(I), ninf))
print('unnamed descriptors left with neither: %d of %d' % (len(UNNAMED) - len(covered), len(UNNAMED)))
print('weak-name upgrades offered: %d; observations: %d; unresolved groups: %d' % (len(WEAK), len(OBS), len(UNRES)))
