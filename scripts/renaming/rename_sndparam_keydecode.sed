# The key -> (part, Lsw number) decoder and two misnamed tables beside it (2026-10-17).
#  - SndParam_DecodeMidiAddr hashes a sound-parameter key, finds its descriptor and, for 0x8000..0x17FFF /
#    0x18000..0x27FFF, returns part = ((key - 0x8000) >> 10) & 0x3F and number = key & 0x3FF (+ 0x400): the Lsw
#    part-parameter address, not a MIDI address.  Its SndParam_DMA_* locals follow.
#  - SndParam_DMA_Zone2Check_Data (v10 only, 0xEE1160) was a second label on SndParam_BlockRamPtrs, the x4 table of
#    record payload pointers that bank_index indexes (sndparam_types.h), named after a local label that reads it.
#    Its references now use SndParam_BlockRamPtrs and its definition line was deleted (one name per address).
#  - MidiPart_ColWidthData (0xE7F070) is VocalistGridCheck_OnLswData's case table, indexed by key - 0x2D00
#    (20 u16 offsets from VocalistGridCheck_LswDrawMidiChannel); it holds no column widths.
s/\bSndParam_DMA_Zone2Check_Data\b/SndParam_BlockRamPtrs/g
s/\bSndParam_DecodeMidiAddr\b/SndParam_KeyToLswPartNumber/g
s/\bSndParam_DMA_/SndParam_KeyToLsw_/g
s/\bMidiPart_ColWidthData\b/VocalistGridCheck_LswCaseTable/g
#  - CmptCnctInvalidInputReturn is MdCmptCnct's EVT_GET_LSW_ADDRESS answer (`ld xhl, 0x2c00`: the computer-connect
#    mode key), not an invalid-input return.
s/\bCmptCnctInvalidInputReturn\b/MdCmptCnct_LswAddress/g
