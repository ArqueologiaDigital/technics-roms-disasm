; =============================================================================
; KN5000 Sub-CPU Payload ROM v1.40 (192KB)
; =============================================================================
; GENERATED from v141/subcpu (itself generated from v142/subcpu) by
; scripts/generators/create_v140_subcpu_source.py, whose EDITS list is the whole
; v1.40 / v1.41 difference.  Edit v142, re-run create_v141_subcpu_source.py and then
; that script, rather than editing this tree by hand (both have --check).
; ⚠ ADDRESSES QUOTED IN COMMENTS ARE v1.42 ADDRESSES (the comments are v142's).
;   v1.40 address = v1.42 address        for 0x000400-0x01f924 (vectors, tables, RESET)
;                 = v1.42 address - 0x17 for 0x01f93b-0x03111a (to DSP_SetVoiceCoefficients' entry)
;                 = v1.42 address - 0x9d for 0x03122f-0x035cbf (DSP_SetCoeff_CopyDirect to
;                                           DSP_Cmd2B_ReadParam5D's entry)
;                 = v1.42 address - 0x4a for 0x035cf5-0x035d1e (DSP_Cmd2B_ReadParam11 to
;                                           DSP_Cmd2B_VoiceParamWrite's entry)
;                 = v1.42 address - 0x49 for 0x035d4a-0x036033 (DSP_Cmd2B_PostProcess to
;                                           DSP_Process_ReadNext's entry)
;                 = v1.42 address - 0x4b for 0x036044-0x03d2aa (DSP_Process_Exit onward)
;                 = v1.42 address - 0x4c for 0x03d2ac-0x03ee75 (FP_dcmp onward)
;   and DRAM in the zero-initialised window (Payload_Bss_Start+offset) is 0x4c lower.
;   The bodies the v1.40 edits rewrite (DSP_SetVoiceCoefficients, DSP_Cmd2B_SetParam,
;   DSP_Cmd2B_VoiceParamWrite, DSP_Process_ReadNext) have no single shift.
; Labels are what to trust: rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf and
; symbols/subcpu_v140_symbols_reference.txt give the v1.40 address of every name.
; =============================================================================

; --- Tone-generator (IC303) register window, A23 low (P6.7 = SFR 0x18 bit 7 cleared) ---
; ToneGen_RegAddrLatch: writing a register number latches it; reading returns the latched
; register's status word (ToneGen_Read_Register, the only read in the payload).
; ToneGen_RegDataPort: the data written to the latched register; never read.
; Evidence: ToneGen_Read_Register's header (139 latch writes, 137 data writes, one read) and
; subcpu_mem in mame_driver/src/mame/matsushita/kn5000.cpp (IC303 at 0x100000/0x110000).
	.equ	ToneGen_RegAddrLatch, 0x100000
	.equ	ToneGen_RegDataPort, 0x100002

; --- DRAM variables named by the headers that use them (2026-09-25; the stack tops and FP_Errno
; 2026-10-24).  Only these have names; the other RAM operands are spelled Payload_Bss_Start+offset
; until their meaning is pinned the same way.  scripts/converters/subcpu_bss_relative_refs.py
; writes each name below in place of the offset it stands for, wherever that offset is spelled. ---
; ToneGen_StagingBlock: "THE TONE GENERATOR STAGING BLOCK AT 0x0451CC" (the banner that decodes
;   its layout, above Voice_Build_OutputLevel in this file) -- the shadow record the TG writers
;   copy from.
; Part_Record_Base: part 0's 287-byte (0x11F) record; part p's is at +p*0x11F.  Its +0 word is
;   the part status/flags word ("(value & 3) == 0: the part is not loaded", bit 0 = RAM user tone).
; Part_PresentWord / Part_PatchRecord_Ptr: fields +2 and +6 of that record, the names the headers
;   use (Partial_GetBaseKey, VoiceParam_Update, ...), indexed `+ part*0x11F`.
; Voice_GlobalFlags: "the global flag word 0x041343" -- bit 1 disables the patch octave shift,
;   bits 9/10/11/12 are set and tested by the key-shift / tuning / CC setters that document them.
	.equ	ToneGen_StagingBlock, Payload_Bss_Start+0x6356
	.equ	Part_Record_Base, Payload_Bss_Start+0x24f2
	.equ	Part_PresentWord, Payload_Bss_Start+0x24f4
	.equ	Part_PatchRecord_Ptr, Payload_Bss_Start+0x24f8
	.equ	Voice_GlobalFlags, Payload_Bss_Start+0x24cd
; Task1_StackTop / Task2_StackTop / Task3_StackTop: the initial stack tops in the +4 field of the
;   three TaskSched_TaskDescriptorTable records (that table's header gives the DRAM partition).
;   Task 1's is also the boot stack PostReset_InitAudio loads before it calls Kernel_InitRam.
; TaskSched_StackTop: the scheduler's own stack, reloaded by Kernel_InitRam, Kernel_Dispatch
;   and Kernel_ExitTask; it sits between task 3's stack and task 2's.
	.equ	Task1_StackTop, Payload_Bss_Start+0x1824
	.equ	Task2_StackTop, Payload_Bss_Start+0x1daa
	.equ	Task3_StackTop, Payload_Bss_Start+0x1c26
	.equ	TaskSched_StackTop, Payload_Bss_Start+0x1ca8
; FP_Errno: the C library's errno word.  The double-precision routines in subcpu_fp_math.s store
;   ERRNO_EDOM there for a domain error (FP_log of x <= 0, FP_pow of 0 to a power <= 0) and
;   ERRNO_ERANGE for a range error (FP_tan of |x| >= 2^31, FP_pow over/underflow); FP_pow_ExpLog
;   saves it, clears it, calls FP_log and tests it for ERRNO_EDOM, then restores it.  The values
;   are the classic Unix EDOM / ERANGE numbers.
	.equ	FP_Errno, Payload_Bss_Start+0x1dac
	.equ	ERRNO_EDOM, 33
	.equ	ERRNO_ERANGE, 34
; Payload_Bss_Size: bytes of zero-initialised RAM that MemClear_DRAM_And_ExtRAM clears from
;   Payload_Bss_Start (the first even address after the program image) at reset.
	.equ	Payload_Bss_Size, 0x66f2

; --- Interrupt Vector Table & Handlers ---
	.include "subcpu_vectors.s"

; --- Data Tables, Constants & Configuration ---
	.include "subcpu_data_tables.s"

; >>> BEGIN CORE INCLUDES (generated by scripts/tools/split_v142_subcpu_core.py; do not edit by hand)
; The payload's core code, in link order, one file per subject (the cut points are the
; section banners the listing already had; the subject in each name is the one that
; dominates the file, see the tool's --census).  Moved verbatim on 2026-10-31.
	.include "core/01_reset_and_main_loop.s"
	.include "core/02_audio_system_init.s"
	.include "core/03_task_scheduler_kernel.s"
	.include "core/04_intercpu_link.s"
	.include "core/05_voice_params_and_tvf.s"
	.include "core/06_voice_envelopes_and_channels.s"
	.include "core/07_voice_ctrlchange.s"
	.include "core/08_voice_noteon_and_tonegen.s"
	.include "core/09_dsp_algo_select.s"
	.include "core/10_dsp_voice_params.s"
	.include "core/11_ringbuf_and_midi_dispatch.s"
	.include "core/12_dsp2_init.s"
	.include "core/13_audio_process_dsp_and_effects.s"
	.include "core/14_dsp_control_routines.s"
; <<< END CORE INCLUDES
; --- Floating-Point Math Library ---
	.include "subcpu_fp_math.s"
