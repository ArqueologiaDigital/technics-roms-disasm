# The C side of rename_subcpu_dsp_cells.sed: the staged sub-CPU C (v142/subcpu/cc900-staged/*.c) names the cells
# and routines that script names (cells below 0x10000 only: a .equ the C can resolve is a number; the ToneDB_* cells
# are Payload_Bss_Start+offset and stay ram_<hex> in the C).
s/\bram_27e7\b/MIDI_BacklogCount/g
s/\bram_27e6\b/RingBuf_OffsetLo/g
s/\bram_2b0d\b/MIDI_RingBuffer/g
s/\bram_3b60\b/DSP2_RingBuffer/g
s/\bram_448e\b/DSP_ConfigBuffer/g
s/\bram_45ca\b/DSP_ConfigBuffer_Shadow/g
s/\bram_45bc\b/DSP_SlotMuteState/g
s/\bram_4930\b/EFF_SlotActiveFlags/g
s/\bram_493a\b/DSP_ChipActiveFlags/g
s/\bram_493e\b/DSP_AlgoChangedFlag/g
s/\bDSP_StateTable_Reset\b/DSP_StateTable_Save/g
s/\bVoiceCC_DataTable_0280FE\b/ToneGen_WriteVoice_Reg21/g
