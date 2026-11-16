# Sub-CPU payload v1.42 (and v1.41 / v1.40 through their generators): names for routines and RAM cells whose
# purpose lane_sub's cc900 C work pinned down (2026-11-16; notes/cc900-c-subcpu-2026-11-16/README.md, "Names").
# Apply to v142/subcpu/**/*.s, then regenerate v141 / v140 (scripts/generators/create_v14[01]_subcpu_source.py).
#
# Routines
#   VoiceCC_DataTable_0280FE: a single-register tone-generator writer, TG register 0x21 (latch voice + 0x840).
#   DSP_StateTable_Reset: copies 0x91 words FROM its argument TO the shadow at 0x45ca (ldirw XIY -> XIX).
s/\bVoiceCC_DataTable_0280FE_Next\b/ToneGen_WriteVoice_Reg21_Next/g
s/\bVoiceCC_DataTable_0280FE\b/ToneGen_WriteVoice_Reg21/g
s/\bDSP_StateTable_Reset\b/DSP_StateTable_Save/g
# Internal-RAM cells (.equ in kn5000_subprogram_v142.s), each spelled as the hand source spells it
s/(17550:16)/(DSP_ConfigBuffer:16)/g
s/\bld xix, 0x448E\b/ld xix, DSP_ConfigBuffer/g
s/\bld xix, 0x45CA\b/ld xix, DSP_ConfigBuffer_Shadow/g
s/(18736:16)/(EFF_SlotActiveFlags:16)/g
s/(18746:16)/(DSP_ChipActiveFlags:16)/g
s/(18750:16)/(DSP_AlgoChangedFlag:16)/g
s/(17852:16)/(DSP_SlotMuteState:16)/g
s/(15200:16)/(DSP2_RingBuffer:16)/g
s/(11021:16)/(MIDI_RingBuffer:16)/g
s/(10215:16)/(MIDI_BacklogCount:16)/g
s/(10214:16)/(RingBuf_OffsetLo:16)/g
# Zero-initialised RAM (named in the headers already: ToneDB_RelBase, ToneDB_RootPtr)
s/(Payload_Bss_Start+0x649a:24)/(ToneDB_RelBase:24)/g
s/(Payload_Bss_Start+0x649e:24)/(ToneDB_RootPtr:24)/g
# The rename-proposal note above the routine (core/06), now applied: its three lines become a record of it.  This
# block comes last: the two lines N joins skip the renames above, so it matches their old text.
/^; ⚠ RENAME PROPOSAL, NOT A PLACEHOLDER FILL: this address already carries the real name$/{
N
N
s/^; ⚠ RENAME PROPOSAL, NOT A PLACEHOLDER FILL: this address already carries the real name\n; VoiceCC_DataTable_0280FE\.  I have left that name alone; applying this one is a decision for\n; the maintainer\.  See the matching \[UNCERTAIN\] at the end\.$/; RENAME APPLIED.\n; ToneGen_WriteVoice_Reg21, the name this note proposed for VoiceCC_DataTable_0280FE, was applied on\n; 2026-11-16 (scripts\/renaming\/rename_subcpu_dsp_cells.sed, lane_sub)./
}
