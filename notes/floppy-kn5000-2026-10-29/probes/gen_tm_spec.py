#!/usr/bin/env python3
"""Build tm_sound_record.json: field map of the KN5000 SOUND MEMORY (.TM) 470-byte record and the user-kit tail.
Inputs: clamp_ranges.json (clamp_ranges.py), the .TM corpus (tm_load.py).  Checks tiling, measures value variety."""
import sys, os, json, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tm_load import files
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CL = json.load(open(os.environ.get('CLAMP_JSON', os.path.join(HERE, 'clamp_ranges.json'))))
OUT = sys.argv[1]

M = 'maincpu v10 '
S = 'subcpu v1.42 '
CLAMP = M + 'Param_SignExtendReturn_Helper3 0xFEEC48 (per-offset range args, via ParamSx_CaseMapA/B, SwitchA/B/C)'
KCLAMP = M + 'unlabelled kit clamp 0xFEEE10 after Param_SignExtendReturn_Skip5 (ParamSx_CaseMapD/E, SwitchD/E/F)'
TDB = 'table_data/tone_database_records.s header (RECORD LAYOUT FROM THE READERS)'
TDA = 'table_data/tone_database_aux.s PercInst/DrumKit headers'

def F(off, size, name, kind, ev, inf=False, todo=None, rep=None, bias=None, clamp=None):
    f = {'off': off, 'size': size, 'name': name, 'kind': kind, 'evidence': ev, 'inference': inf}
    if bias is not None: f['bias'] = bias
    if todo: f['todo'] = todo
    if rep: f['repeat'] = {'count': rep[0], 'stride': rep[1]}
    if clamp is not None: f['clamp'] = clamp
    return f

def cl(region, o):
    v = CL[region].get(str(o))
    if v is None or isinstance(v, str): return 'none'
    return {'min': v[0], 'max': v[1], 'value_mask': None if v[2] == 0xffff else v[2]}

# ---------------- 470-byte sound record ----------------
R = []
R.append(F(0x00, 16, 'name', 'ascii', M + 'SingleLoadSrc_ReadTmSoundName 0xF8A319 (16 B at 16 + 470*n); clamp 32..127 for offsets 0..15 (' + CLAMP + ')', clamp={'min': 32, 'max': 127, 'value_mask': None}))
R.append(F(0x10, 1, 'part_mode', 'bits', S + 'Voice_SetVelocity 0x02C8E4 switches on &0xC0 (0x00 melodic, 0x40 drawbar, 0x80 drum kit, 0xC0 silent); bit 4 via Voice_Calc_LevelPair_PatchAtk 0x025636; ' + TDB, clamp=cl('rec_head_common', 16)))
R.append(F(0x11, 1, 'partial_mask', 'bits', S + 'mask table 0x00FB4E {0x01,0x04,0x10,0x40} = partial 0..3 present; EFFSlotScan_AssignPath 0x032295; ' + TDB, clamp=cl('rec_head_common', 17)))
R.append(F(0x12, 1, 'b_0x12', 'hex', S + 'Partial_Build_Present_Word 0x032B1E tests bits 1:0', todo='reader known, meaning not; 0 in all 723 distinct corpus records', clamp=cl('rec_head_common', 18)))
R.append(F(0x13, 1, 'bend_type', 'dec', S + 'Voice_Pitch_Compute_Inactive 0x023698 (' + TDB + '); clamp 0..66', clamp=cl('rec_head_common', 19)))
for nm, k, kind, ev, todo in (('ctrl_part_switches', 0, 'bits', 'byte 0 of each 3-byte group is unclamped; 0x55 = four 2-bit fields 01, the partial-mask pattern; ' + S + 'Voice_PitchBend_BranchA 0x02A62E takes the address of group 0 (+0x14)', 'per-tone (1ST..4TH) switch reading of the 2-bit fields is an inference from the 0x55 pattern and the SeCtr2/SeCtr3 "1ST 2ND 3RD 4TH" captions'),
                              ('ctrl_b1', 1, 'bits', 'clamp 0..49 on bits 6:0 (value mask 0x7f, bit 7 kept): ' + CLAMP, 'no subcpu reader identified; bit 7 is a flag (0x81 in group 0 of every record)'),
                              ('ctrl_b2', 2, 'dec', 'clamp 0..127: ' + CLAMP, 'no subcpu reader identified; 0x40 in most records')):
    R.append(F(0x14 + k, 1, nm, kind, ev + '. Seven groups of 3 at +0x14..+0x28, shown by the clamp\'s period-3 ranges over offsets 20..40', inf=(k == 0), todo=todo, rep=(7, 3), clamp=cl('rec_head_common', 20 + k)))
R.append(F(0x29, 1, 'octave_shift', 'dec', S + 'Voice_Pitch_Compute 0x023584 -> Pitch_Get_Patch_Octave_Shift (low nibble); clamp 6..10, 8 = no shift (' + CLAMP + ')', clamp=cl('rec_head_common', 41)))
R.append(F(0x2A, 1, 'program_lookup_nibbles', 'bits', S + 'Instrument_LookupProgram_HiNibble 0x02289D / _LoNibble 0x0228D9 index byte table 0x011ACF with each nibble', clamp=cl('rec_head_common', 42)))
lfo_ev = ('12 x 4-byte entries +0x2B..+0x5A (' + TDB + ': three runs of four; ' + S + 'ExtVoice_Build_SlotRegisters 0x024BE3 tests byte +2 bit 7 of entries 0-3). LFO reading: clamp ranges 0..127 / 0..127 / bit7 + 0..50 / bits7:6 + 0..30 (' + CLAMP + ') match the LFO page fields of ' + M +
          'SePitAmpFilLfo1_DrawField 0xF102FC (shared by TT_SEPITLFO1 / TT_SEAMPLFO1 / TT_SEFILLFO1): two 0..127 numbers, a 0..63 number + OFF/ON bit 7 (SePitAmpFilLfo1_DrawField_Records2), wave SIN/TRI/SQR/SAW in bits 7:6 + a 0..31 number (SeScreenData_0x287D); 3 pages x LFO1..LFO4 = 12')
R.append(F(0x2B, 1, 'lfo_b0', 'dec', lfo_ev, inf=True, todo='which UI caption (speed/delay/depth) is this byte not traced: the page params 0x661..0x664 arrive from the subcpu, not read from the record', rep=(12, 4), clamp=cl('rec_head_common', 43)))
R.append(F(0x2C, 1, 'lfo_b1', 'dec', lfo_ev, inf=True, todo='caption not traced', rep=(12, 4), clamp=cl('rec_head_common', 44)))
R.append(F(0x2D, 1, 'lfo_b2_onoff', 'bits', lfo_ev + '; bit 7 = ON/OFF, bits 6:0 = 0..50', inf=True, rep=(12, 4), clamp=cl('rec_head_common', 45)))
R.append(F(0x2E, 1, 'lfo_b3_wave', 'bits', lfo_ev + '; bits 7:6 = wave (SIN TRI SQR SAW, inference), bits 5:0 = 0..30', inf=True, rep=(12, 4), clamp=cl('rec_head_common', 46)))
R.append(F(0x5B, 1, 'b_0x5b', 'dec', 'clamp 0..127: ' + CLAMP, todo='no subcpu reader in ' + TDB, clamp=cl('rec_head_common', 91)))
R.append(F(0x5C, 1, 'level_offset', 'signed', S + 'Level_Build_Reg0C0 0x0253FE: level offset centred on 0x40 (' + TDB + '); clamp 0..127', bias=64, clamp=cl('rec_head_common', 92)))
R.append(F(0x5D, 1, 'algorithm_type', 'bits', S + 'AlgoType_StateWrite 0x033557 and Partial_Build_Present_Word 0x032B1E read the low nibble', clamp='none'))
R.append(F(0x5E, 4, 'partial_descriptor', 'hex', S + 'Voice_Build_Partial_Descriptor 0x02B717 (ROM tables 0x012038/0x012057/0x012095); +0x5E/+0x60 also DSP_ChanFreq_WritePacket1 0x033B8B, +0x5F & 0x3F AlgoType_AB_LoadIndex 0x033B70', todo='per-byte meaning not established; kept as one 4-byte field', clamp='none'))
R.append(F(0x62, 2, 'b_0x62', 'hex', 'no reader in ' + TDB + '; unclamped', todo='no reader found', clamp='none'))
R.append(F(0x64, 1, 'secondary_param_a', 'dec', S + 'Voice_SecondaryParam_Path2 0x033DAA', clamp='none'))
R.append(F(0x65, 1, 'secondary_param_b', 'dec', S + 'Voice_SecondaryParam_Path2_Epilogue 0x033DD3', clamp='none'))
# partial blocks
PB = 0x66
P = [  # (blk off, size, name, kind, evidence, inference, todo, bias)
 (0x00, 1, 'gate_ctl', 'dec', S + 'Voice_Build_GateCommand 0x025589 and Voice_ComputePitch 0x026396 read it; clamp 0..50', True, 'name from the readers only; meaning not established', None),
 (0x01, 1, 'b_0x01', 'dec', 'clamp 0..128; no subcpu reader (' + TDB + ')', False, 'no reader found', None),
 (0x02, 1, 'wave', 'dec', S + 'WaveSel_StageA1_FromPatchBlock 0x0325FC: wave byte of the wave-select pair; clamp 0..127', False, None, None),
 (0x03, 1, 'wave_family', 'hex', S + 'WaveSel_StageA1_FromPatchBlock 0x0325FC: family/sub-bank byte (0x00 / 0x80); DSP_WriteAlgoBuffer 0x03522E forces bits 5:4', False, None, None),
 (0x04, 1, 'coarse_tune', 'signed', 'clamp -24..+24 (two\'s complement); corpus values cluster on 0, +-12, +-24 (2457 / 145+101 / 49+42 of 2892 blocks) = semitones; no subcpu reader in ' + TDB, True, 'semitone reading from range and corpus only; no reader found', 0),
 (0x05, 1, 'partial_detune', 'dec', S + 'Pitch_Apply_Partial_Detune 0x023A05', False, None, None),
 (0x06, 1, 'b_0x06', 'hex', 'unclamped; no subcpu reader', False, 'no reader found', None),
 (0x07, 1, 'env2_start_level', 'signed', S + 'Voice_Level_ComputeTriplet 0x023AD0 (read as a sign flag in ' + TDB + '); clamp -50..50 and corpus values 0/+50/+30/-20 show a signed level; SePitEnv1 / SeFilEnv1 captions START PITCH / START', True, 'start-level reading is an inference; the header calls it a sign flag', 0),
 (0x08, 1, 'env2_porta_level', 'signed', S + 'Voice_PortaLevel_Compute 0x0248D5; clamp -50..50', False, None, 0)]
for s in range(4):
    a, b = 0x09 + 2 * s, 0x0A + 2 * s
    rd = 'Voice_Level_ComputeTriplet 0x023AD0' if s < 3 else 'Voice_Calc_LevelPair_EGB 0x026975'
    P.append((a, 1, 'env2_seg%d_a' % (s + 1), 'dec', S + rd + '; clamp 0..100 (segment pairs: ' + TDB + ' calls the odd bytes targets)', False, 'target vs rate of the (0..100, -50..50) pair not settled', None))
    P.append((b, 1, 'env2_seg%d_b' % (s + 1), 'signed', S + rd + '; clamp -50..50', False, 'target vs rate not settled', 0))
P += [
 (0x11, 1, 'env2_key_scale', 'signed', S + 'Voice_Level_ComputeTriplet 0x023AD0; clamp -50..50', False, None, 0),
 (0x12, 1, 'env2_b_0x12', 'signed', 'clamp -50..50; no subcpu reader', False, 'no reader found', 0),
 (0x13, 1, 'env2_velocity_base', 'dec', S + 'Voice_Level_ComputeTriplet 0x023AD0; clamp 0..127', False, None, None),
 (0x14, 2, 'env2_velocity_depth', 'signed', S + 'Voice_Level_ComputeTriplet 0x023AD0 (two depth bytes, each signed); clamp -50..50 each', False, 'two int8, not one int16', 0),
 (0x16, 1, 'env2_egb_0x16', 'signed', S + 'Voice_Calc_LevelPair_EGB 0x026975; clamp -50..50', False, None, 0),
 (0x17, 1, 'channel_detune', 'dec', S + 'Voice_ApplyPortamento 0x026637; clamp 0..127', False, None, None),
 (0x18, 1, 'fine_detune', 'signed', S + 'Voice_ComputePitch 0x026396 (signed detune); clamp -50..50', False, None, 0),
 (0x19, 1, 'pitch_curve', 'hex', S + 'Voice_ComputePitch 0x026396: curve selector, 0xE0 = the direct note table', False, None, None),
 (0x1A, 3, 'pitch_params', 'dec', S + 'Voice_ComputePitch 0x026396 reads +0x1A..+0x1C; clamp 0..127 each', False, 'three bytes, individual meaning not established', None),
 (0x1D, 1, 'b_0x1d', 'signed', 'clamp -50..50; no subcpu reader', False, 'no reader found', 0),
 (0x1E, 8, 'b_0x1e', 'dec', 'clamp 0..127 each; no subcpu reader for +0x1D..+0x26', False, 'no reader found', None),
 (0x26, 1, 'b_0x26', 'hex', 'unclamped; no subcpu reader', False, 'no reader found', None)]
for s in range(3):
    P.append((0x27 + 2 * s, 1, 'env1_seg%d_target' % (s + 1), 'dec', S + 'Voice_Calc_LevelPair_PatchAtk 0x025636 / _Full 0x025C87 / _Mono 0x025F7F (amplitude envelope); clamp 0..100', False, None, None))
    P.append((0x28 + 2 * s, 1, 'env1_seg%d_rate' % (s + 1), 'dec', S + 'Voice_Calc_LevelPair_PatchAtk 0x025636 (amplitude envelope); clamp 0..100', False, None, None))
P += [
 (0x2D, 1, 'env1_level', 'dec', S + 'Voice_Calc_LevelPair_EGA 0x026769; clamp 0..100', False, None, None),
 (0x2E, 2, 'env1_key_scale', 'signed', S + 'Voice_Calc_LevelPair_PatchAtk 0x025636 (two key-scale bytes); clamp -50..50 each', False, 'two int8', 0),
 (0x30, 3, 'env1_velocity_ctl', 'dec', S + 'Voice_Calc_LevelPair_PatchAtk 0x025636 (velocity control triple); clamp 0..127 each', False, 'three bytes', None),
 (0x33, 2, 'env1_depth', 'signed', S + 'Voice_Calc_LevelPair_PatchAtk 0x025636 (depths); clamp -50..50 each', False, 'two int8', 0),
 (0x35, 1, 'env1_ega_0x35', 'signed', S + 'Voice_Calc_LevelPair_EGA 0x026769; clamp -50..50', False, None, 0),
 (0x36, 1, 'filter_type', 'bits', S + 'TVF_Build_Dispatch 0x024102: bits 2:0 = filter builder, bits 7:5 = key-follow curve', False, None, None),
 (0x37, 1, 'filter_key_follow_depth', 'dec', S + 'TVF_Calc_Cutoff 0x022C06; clamp 0..50', False, None, None),
 (0x38, 1, 'b_0x38', 'hex', 'unclamped; no subcpu reader', False, 'no reader found', None),
 (0x39, 1, 'level_scale_offset', 'dec', S + 'TVF_Calc_Cutoff 0x022C06; clamp 0..127', False, None, None),
 (0x3A, 1, 'level_scale_low', 'dec', S + 'TVF_Calc_Cutoff 0x022C06; clamp 0..127', False, None, None),
 (0x3B, 1, 'level_scale_high', 'dec', S + 'TVF_Calc_Cutoff 0x022C06; clamp 0..127', False, None, None),
 (0x3C, 1, 'level_scale_depth', 'signed', S + 'TVF_Calc_Cutoff 0x022C06; clamp -50..50', False, None, 0),
 (0x3D, 1, 'env3_start_level', 'signed', S + 'Voice_StereoLevel_Compute 0x024664 (shared bias in ' + TDB + '; twin of env2 +0x07); clamp -50..50, corpus 0/-30/-40/-20', True, 'start-level reading is an inference from the env2 twin', 0),
 (0x3E, 1, 'env3_porta_level', 'signed', S + 'Voice_PortaLevel_Compute 0x0248D5; clamp -50..50', False, None, 0)]
for s in range(4):
    rd = 'Voice_StereoLevel_Compute 0x024664' if s < 3 else 'Voice_Calc_LevelPair_EGC 0x026AAA'
    P.append((0x3F + 2 * s, 1, 'env3_seg%d_a' % (s + 1), 'dec', S + rd + '; clamp 0..100 (same 16-byte structure as env2, 0x36 later)', False, 'target vs rate not settled', None))
    P.append((0x40 + 2 * s, 1, 'env3_seg%d_b' % (s + 1), 'signed', S + rd + '; clamp -50..50', False, 'target vs rate not settled', 0))
P += [
 (0x47, 1, 'env3_key_scale', 'signed', S + 'Voice_StereoLevel_Compute 0x024664; clamp -50..50', False, None, 0),
 (0x48, 1, 'env3_b_0x48', 'signed', 'clamp -50..50; no subcpu reader', False, 'no reader found', 0),
 (0x49, 1, 'env3_velocity_base', 'dec', S + 'Voice_StereoLevel_Compute 0x024664; clamp 0..127', False, None, None),
 (0x4A, 2, 'env3_velocity_depth', 'signed', S + 'Voice_StereoLevel_Compute 0x024664; clamp -50..50 each', False, 'two int8', 0),
 (0x4C, 1, 'env3_egc_0x4c', 'signed', S + 'Voice_Calc_LevelPair_EGC 0x026AAA; clamp -50..50', False, None, 0),
 (0x4D, 1, 'filter_cutoff', 'dec', S + 'TVF_Build_Full 0x023D01 (cutoff seed); unclamped', False, None, None),
 (0x4E, 1, 'filter_slope_mode', 'hex', S + 'TVF_Build_Full 0x023D01 (slope/mode); unclamped', False, None, None),
 (0x4F, 2, 'filter_pair', 'hex', S + 'TVF_Build_Full 0x023D01 / Voice_PitchPack_Mode2 0x023DB5.._Mode5_Dual 0x02403D: resonance/depth pair, or a second cutoff in mode 5', False, 'two bytes', None)]
PEV = ' [partial block p at +0x66 + 0x51*p: ' + S + 'EFFSlotScan_AssignPath 0x032295 binds rec + 0x66 + 0x51*rank; ' + M + 'SoundRam_FillDefaultRecord 0xFEFD28 copies block 0 to +183/+264/+345]'
for (o, sz, nm, kind, ev, inf, todo, bias) in P:
    c = cl('rec_partial', o) if sz == 1 else cl('rec_partial', o)
    R.append(F(PB + o, sz, 'partial_' + nm, kind, ev + PEV, inf=inf, todo=todo, rep=(4, 81), bias=bias, clamp=c))
# velocity-split records
VEV = (' [4 x 11-byte velocity-split record at +0x1AA + 11*p, one per partial: ' + S + 'SlotParam_WriteType3 0x032517 (RamBank + 0x1D6*n + 0x1BA + 0x0B*p, bank base includes the 16-byte header), Audio_Cmd_DSPGlobal_Param_Store 0x0301E3; '
       'same layout as table_data ToneDB_MixerDefaultTable (CORRECTED 2026-09-25 header)]')
R.append(F(0x1AA, 3, 'vsel_thresholds', 'dec', S + 'Velocity_Select_Split_Zone 0x022824: three ascending velocity thresholds -> zone 0..3; clamp 0..127' + VEV, todo='only ~80% of corpus bytes in this 44-B tail fall in the clamp ranges (0xFF / 0x00 fills): ' + S + 'WaveSel_Cache_VelSplitPtr takes this RAM copy only when part flags bit 0 is set, else the ROM table, so the tail may be stale in many records; not verified', rep=(4, 11), clamp=cl('rec_vsel', 0)))
for z in range(4):
    R.append(F(0x1AD + 2 * z, 1, 'vsel_zone%d_wave' % z, 'dec', S + 'WaveSel_StageA2_FromVelZone 0x0328B5: zone wave byte; clamp 0..127' + VEV, rep=(4, 11), clamp=cl('rec_vsel', 3 + 2 * z)))
    R.append(F(0x1AE + 2 * z, 1, 'vsel_zone%d_family' % z, 'hex', S + 'WaveSel_StageA2_FromVelZone 0x0328B5: zone family/sub-bank byte; unclamped' + VEV, rep=(4, 11), clamp=cl('rec_vsel', 4 + 2 * z)))

# ---------------- user kit tail (file 0x4980, 10538 bytes) ----------------
K = []
K.append(F(0x000, 16, 'kit_name', 'ascii', M + 'SingleLoadSrc_ReadTmUserKitName 0xF8A394 (16 B at file 0x4980); ' + S + 'Audio_Cmd_PatchByte_Write_And_Echo 0x03021F echoes kit-record bytes to 0x1E0000 + 0x4980 + offset', clamp={'min': 32, 'max': 127, 'value_mask': None}))
K.append(F(0x010, 1, 'part_mode', 'hex', S + 'Voice_SetVelocity 0x02C8E4: 0x80 = drum kit (' + TDA + ')', clamp='none'))
K.append(F(0x011, 1, 'b_0x11', 'dec', M + 'HdaeRom_DataDispatch_Block3 0xFF03FB inserts this byte (shifts +0x11..0x72A6 up one) and stores 1 when converting a KN3000-format image; ROM kits hold 0..6 here, no reader (' + TDA + ')', todo='no reader found', clamp='none'))
for nm, k, kind in (('ctrl_part_switches', 0, 'bits'), ('ctrl_b1', 1, 'bits'), ('ctrl_b2', 2, 'dec')):
    K.append(F(0x012 + k, 1, nm, kind, 'kit twin of the sound record\'s +0x14 groups: same clamp ranges with period 3 over kit offsets 18..38 (' + KCLAMP + '); identical in all 26 ROM kits (' + TDA + ')', inf=True, todo='no reader found', rep=(7, 3), clamp=cl('kit_head', 18 + k) if str(18 + k) in CL['kit_head'] else 'none'))
K.append(F(0x027, 1, 'note_inst', 'dec', S + 'ToneDB_Find_SubToneRecord 0x032AE0 reads rec[0x27+2n] for MIDI note n; ToneDB_Resolve_NamedToneRecord 0x032A08 -> DrumKit_NoteMapA[slot&0x1F][wave] (' + TDA + ')', rep=(128, 2), clamp='none'))
K.append(F(0x028, 1, 'note_bank', 'bits', S + 'ToneDB_Find_SubToneRecord 0x032AE0 reads rec[0x28+2n]: bits 4:0 = NoteMapA row, bit 5 = user RAM entry; ' + M + 'HdaeRom_DataDispatch_Block3 0xFF03FB forces bits 5:4 = 10 on all 128', todo='bit 6 (0x60..0x6E seen) not explained', rep=(128, 2), clamp='none'))
EB = 0x127
EEV = (' [128 x 80-byte user drum instruments at kit +0x127 (file 0x4AA7) + 80*n, entry n = MIDI note n: ' + M + 'SingleLoad_LoadSoundMemEntry 0xF884D4 (80 B at 0x4AA7 + 80*i), SingleLoadSrc_ReadTmUserKitEntryName 0xF8A404; ' + S +
       'CustomTone_CopyToneRecord 0x02E30E copies a resolved PercInst into 0x4AA7 + 80*n; the first 58 B are the 58-byte PercInst layout (' + TDA + ')]')
K.append(F(EB + 0x00, 13, 'entry_name', 'ascii', 'PercInst +0x00 13-char name; kit clamp 32..127 for entry offsets 0..12' + EEV, rep=(128, 80), clamp={'min': 32, 'max': 127, 'value_mask': None}))
K.append(F(EB + 0x0D, 1, 'entry_layer_mask', 'bits', S + 'Voice_Allocate_Type2 0x02C12B: bit 0 = layer 0, bit 2 = layer 1, bit 5 = fixed level (Voice_WriteVolume_OrPan 0x026C16)' + EEV, rep=(128, 80), clamp=cl('kit_entry', 13)))
K.append(F(EB + 0x0E, 1, 'entry_b_0x0e', 'dec', 'clamp 0..127; no reader (' + TDA + ')' + EEV, todo='no reader found', rep=(128, 80), clamp=cl('kit_entry', 14)))
K.append(F(EB + 0x0F, 1, 'entry_b_0x0f', 'dec', 'clamp 0..127; no reader (' + TDA + ')' + EEV, todo='no reader found', rep=(128, 80), clamp=cl('kit_entry', 15)))
L = [
 (0x00, 1, 'b_0x00', 'dec', 'clamp 0..128; no reader', 'no reader found', None),
 (0x01, 1, 'wave', 'dec', S + 'WaveSel_StageA1_FromToneSlot 0x032682 wave byte; clamp 0..127', None, None),
 (0x02, 1, 'wave_family', 'hex', S + 'WaveSel_StageA1_FromToneSlot 0x032682 family byte (0x40..0x4F percussion)', None, None),
 (0x03, 1, 'coarse_tune', 'signed', S + 'Voice_Pitch_CopyBase 0x023809 (signed semitones); clamp -50..50', None, 0),
 (0x04, 1, 'fine_tune', 'signed', S + 'Voice_Pitch_CopyBase 0x023809 (signed fine step x2)', None, 0),
 (0x05, 1, 'channel_detune', 'dec', S + 'Voice_ApplyPortamento2 0x026684: +(value - 0x64), 0 = fixed -0x200; clamp 0..127', None, None),
 (0x06, 1, 'detune', 'signed', S + 'Voice_ComputePitch_Mono 0x026533 signed detune; clamp -50..50', None, 0),
 (0x07, 1, 'pitch_curve', 'hex', S + 'Voice_ComputePitch_Mono 0x026533 curve selector, 0xE0 = direct note table', None, None),
 (0x08, 1, 'amp_seg0_target', 'dec', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp 0..100', None, None),
 (0x09, 1, 'amp_seg1_target', 'dec', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp 0..100', None, None),
 (0x0A, 1, 'amp_seg1_rate', 'dec', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp 0..100', None, None),
 (0x0B, 1, 'amp_seg2_target', 'dec', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp 0..100', None, None),
 (0x0C, 1, 'amp_seg2_rate', 'dec', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp 0..100', None, None),
 (0x0D, 1, 'fixed_level', 'dec', S + 'Voice_WriteVolume_OrPan 0x026C16 (used when mask bit 5 set); clamp 0..100', None, None),
 (0x0E, 1, 'amp_seg0_key_scale', 'signed', S + 'Voice_Calc_LevelPair_FixedAtk 0x025A35; clamp -50..50', None, 0),
 (0x0F, 1, 'filter_type', 'bits', S + 'TVF_BuildEmit_Short_Dispatch 0x024300 bits 2:0; bits 7:5 key-follow curve (TVF_Calc_Cutoff_NoKeyFollow 0x022C99)', None, None),
 (0x10, 1, 'filter_key_follow_depth', 'dec', S + 'TVF_Calc_Cutoff_NoKeyFollow 0x022C99; clamp 0..50', None, None),
 (0x11, 1, 'filter_cutoff', 'dec', S + 'TVF_Build_Short 0x02413E', None, None),
 (0x12, 1, 'filter_slope', 'hex', S + 'TVF_Build_Short 0x02413E', None, None),
 (0x13, 2, 'filter_bias_depth', 'hex', S + 'TVF_Build_Short 0x02413E: bias, depth', 'two bytes', None)]
for lay in range(2):
    for (o, sz, nm, kind, ev, todo, bias) in L:
        eo = 0x10 + 0x15 * lay + o
        c = cl('kit_entry', eo) if str(eo) in CL['kit_entry'] else 'none'
        K.append(F(EB + eo, sz, 'entry_layer%d_%s' % (lay, nm), kind, ev + ' [layer L at entry +0x10 + 0x15*L: Voice_Allocate_Type2 0x02C12B; ' + S + 'DSP_SlotParam_Write_From_Cache_B 0x03025F writes 0x4AB7 + 80*edit + 21*L]' + EEV, todo=todo, rep=(128, 80), bias=bias, clamp=c))
for lay in range(2):
    base = EB + 0x3A + 11 * lay
    ev = (' [layer %d velocity-split record at entry +0x3A + 11*L: ' % lay + S + 'CustomTone_CopySubUnitRecord 0x02E390 copies it to 0x4AE1 + 80*n + 11*unit; Audio_Cmd_ToneEdit_Field_Write_And_Reply 0x030535; layout of ToneDB_PercMixerDefaultTable]' + EEV)
    K.append(F(base, 3, 'entry_vsel%d_thresholds' % lay, 'dec', S + 'Velocity_Select_Split_Zone 0x022824; clamp 0..127' + ev, rep=(128, 80), clamp=cl('kit_vsel', 0)))
    for z in range(4):
        K.append(F(base + 3 + 2 * z, 1, 'entry_vsel%d_zone%d_wave' % (lay, z), 'dec', S + 'WaveSel_StageA2_FromVelZone 0x0328B5' + ev, rep=(128, 80), clamp=cl('kit_vsel', 3 + 2 * z)))
        K.append(F(base + 4 + 2 * z, 1, 'entry_vsel%d_zone%d_family' % (lay, z), 'hex', S + 'WaveSel_StageA2_FromVelZone 0x0328B5' + ev, rep=(128, 80), clamp=cl('kit_vsel', 4 + 2 * z) if 4 + 2 * z < 10 else 'none'))
K.append(F(0x2927, 1, 'kit_edit_index', 'dec', S + 'DSP_SlotParam_Write_From_Cache_B 0x03025F and tone-edit opcodes 0x14-0x16 read the edit-entry index at ToneDB_RamBankA + 0x72A7 (= file 0x72A7); InterCPU_SendEditBufferToMain 0x02ED44', todo='corpus values run 1..252, so values >= 128 would index past the 128 entries; not checksummed', clamp='none'))
K.append(F(0x2928, 2, 'image_checksum', 'hex', M + 'SoundRam_WriteIdAndChecksum 0xFF03DC / SendPartDataBlock_SetWord5 0xFEF93B: LE16 = ~(sum of the 0x24B8 words from 0x1E0010), i.e. the 40 sound records only; SendPartDataBlock_ClearByte4 0xFEF950 checks it at boot (header + this word) before the E1 copy to subcpu 0x7800. Verified on 45/45 KN5000 files', clamp='none'))

# ---------------- tiling check ----------------
def expand(fields):
    out = []
    for f in fields:
        r = f.get('repeat', {'count': 1, 'stride': 0})
        for k in range(r['count']):
            out.append((f['off'] + k * r['stride'], f['size'], f['name'] + ('_%d' % k if r['count'] > 1 else ''), f))
    return sorted(out)
def check(fields, size):
    cov = [0] * size
    for o, s, n, f in expand(fields):
        for i in range(o, o + s): cov[i] += 1
    bad = [i for i, c in enumerate(cov) if c != 1]
    assert not bad, ('tiling', size, bad[:20], len(bad))
check(R, 470); check(K, 10538)

# ---------------- corpus statistics ----------------
TM = [(p, d) for p, d in files() if d[:16] == b'KN5000 SOUND RAM' and len(d) == 0x72AA]
recs = sorted({d[0x10 + 470 * n:0x10 + 470 * n + 470] for p, d in TM for n in range(40)})
kits = sorted({d[0x4980:0x72AA] for p, d in TM})
def val(b, f):
    v = int.from_bytes(b, 'little')
    return v
def stats(fields, blobs):
    for f in fields:
        r = f.get('repeat', {'count': 1, 'stride': 0})
        c = collections.Counter()
        inr = tot = 0
        for b in blobs:
            for k in range(r['count']):
                o = f['off'] + k * r['stride']; chunk = b[o:o + f['size']]
                if f['kind'] == 'ascii': c[chunk.decode('latin1')] += 1; continue
                for byte in (chunk if f['size'] <= 3 and f['kind'] != 'hex' or f['size'] == 1 else [None]):
                    pass
                c[chunk.hex()] += 1
                cl_ = f.get('clamp')
                if isinstance(cl_, dict):
                    for byte in chunk:
                        v = byte & (cl_['value_mask'] or 0xff)
                        if cl_['min'] < 0 and v >= 128 and not cl_['value_mask']: v -= 256
                        tot += 1; inr += cl_['min'] <= v <= cl_['max']
        top = c.most_common(4)
        o = {'samples': sum(c.values()), 'distinct': len(c), 'top': [[t, n] for t, n in top]}
        if f['kind'] != 'ascii' and f['size'] == 1:
            vals = [int(t, 16) for t in c]
            o['min'] = min(vals); o['max'] = max(vals)
        if tot: o['in_clamp_range'] = round(inr / tot, 4)
        f['observed'] = o
stats(R, recs); stats(K, kits)

doc = {
 'record_size': 470,
 'source_files': 'the 45 KN5000-format .TM files of floppy/kn5000/baserom/*.img (ca5000r/03FOLKS2.TM is a 29,696-byte KN3000 SOUND RAM image and is excluded); %d distinct sound records, %d distinct kit tails' % (len(recs), len(kits)),
 'fields': R,
 'kit': {'file_offset': 0x4980, 'size': 10538, 'fields': K},
 'notes': '',
}
doc['notes'] = (
 'FILE: "KN5000 SOUND RAM" (16 B, checked at boot by SendPartDataBlock_ClearByte4 0xFEF950) + 40 x 470-B sound records at 0x10 + 470*n (MEMORY A 1..20, B 1..20) + the user-kit tail at 0x4980 (not 0x4990: 16 + 40*470 = 0x4980; the kit NAME is its first 16 B). '
 'The tail is 295-B kit header + 128 x 80-B user drum instruments + 1-B edit index + 2-B checksum; the checksum covers only 0x10..0x497F. '
 'RECORD = the subcpu tone-record format (table_data/tone_database_records.s, 21 + 81*N with N = 5) at its full 426 B: head +0x00..+0x14, common block +0x15..+0x65, four partial blocks +0x66 + 81*p; DSP_Reinit_VoiceSlots 0x035323 copies the 40 ROM staging streams (tone table indices 338-377) into the RAM image as 426 B each = the factory defaults; then 44 B = four 11-B velocity-split records, the RAM copy of the ToneDB_MixerDefaultTable record a ROM tone would look up. '
 'The task note "factory defaults at v10 file offset 0x0A0150 (0x72A6 B)" does not hold: 0x0A0150 (0xEA0150) is only the 16-B header string; the 426-B SoundRam_DefaultRecord 0xEED59D ("    Initial     ") is what SoundRam_FillDefaultRecord 0xFEFD28 puts under converted KN1500/KN2000 records, and the 40 factory sounds come from table_data via the subcpu. '
 'The clamp tables (ParamSx_*) give a (min, max, value_mask) per offset; they are range ARGUMENTS of the call at 0xFEEE06 -> 0xFEEC3F, whose body as decoded (ld HL,WA; cpl BC; and HL,BC; retd 4) does not apply them, so they document the intended ranges rather than enforce them; "observed.in_clamp_range" tests them on the corpus. '
 'KINDS: signed = int8 two\'s complement unless "bias" is 64 (stored value - 64). bits = flags/packed fields named in evidence. REPEAT: a field with repeat {count, stride} stands for count copies at off + k*stride, named <name>_<k>. '
 'Field tiling of both blocks is checked by gen_tm_spec.py (every byte exactly once after repeat expansion). '
 'Old-format images: HdaeRom_DataHandler 0xFF024E dispatches on the 16-B id (SoundRam_Id_KN2000 / MKA / MKB / KN3000 / KN1500 / KN5000); KN3000 images lack the kit +0x11 byte (HdaeRom_DataDispatch_Block3 0xFF03FB inserts it), KN1500 records are 289 B (SoundRam_ConvertKn1500Record 0xFEF9B4), KN2000/MKA/MKB 144 B (SoundRam_ConvertKn2000Record 0xFEFD77). '
 'Producers: scratch scripts clamp_ranges.py (ROM tables + unidasm) and gen_tm_spec.py under ~/compartilhado/tmp/data-floppy-kn5000/agentA/scripts/ (not committed by this agent).')
os.makedirs(os.path.dirname(OUT), exist_ok=True)
json.dump(doc, open(OUT, 'w'), indent=1)
def count(fields):
    named = neutral = 0
    for o, s, n, f in expand(fields):
        if f['name'].split('_')[0] in ('b',) or '_b_0x' in f['name'] or f['name'].startswith('b_0x'): neutral += s
        else: named += s
    return named, neutral
print('record named/neutral bytes', count(R)); print('kit named/neutral bytes', count(K))
print(len(recs), len(kits))
