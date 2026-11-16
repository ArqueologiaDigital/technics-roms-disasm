; =============================================================================
; KN5000 Sub-CPU Payload ROM (192KB)
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
; ToneDB_RelBase / ToneDB_RootPtr: the tone database's base address and its root (header) pointer, the two
;   longs every ToneDB_* lookup reads (headers of core/10_dsp_voice_params.s); DSP_System_Init stores
;   0x00050000 in both.
	.equ	ToneDB_RelBase, Payload_Bss_Start+0x649a
	.equ	ToneDB_RootPtr, Payload_Bss_Start+0x649e

; --- Internal-RAM cells named from the cc900 C of the routines that use them (2026-11-16, lane_sub;
; notes/cc900-c-subcpu-2026-11-16/README.md, "Names"; scripts/renaming/rename_subcpu_dsp_cells.sed). ---
; MIDI_BacklogCount: the MIDI ring's byte count as MIDI_Backlog_Publish stores it; RingBuf_CheckOffset_ClearFlags
;   compares it with 0x20 / 0x30 (0x40 / 0x50 when RingBuf_OffsetLo is 0) to drop layer slots.
; RingBuf_OffsetLo: the byte RingBuf_SetOffsetLo stores, which picks those thresholds.
; MIDI_RingBuffer / DSP2_RingBuffer: the MIDI ring (index mask 0xfff) and the DSP2 ring (mask 0x7ff): write
;   index, read index and count words, then the data.  DSP_System_Init / the DSP2 init clear the three words.
; DSP_ConfigBuffer: the DSP configuration record (four words, then five 56-byte effect-slot records);
;   DSP_GetConfigBuffer returns it, DSP_State_ApplyBuf pushes it.  DSP_ConfigBuffer_Shadow: the 145-word copy
;   DSP_StateTable_Save keeps of it.
; DSP_SlotMuteState: one word per effect slot, read and cleared by DSP_SlotMuteState_ReadAndClear.
; EFF_SlotActiveFlags: one word per effect slot; DSP_ChipActiveFlags: one word per DSP chip;
; DSP_AlgoChangedFlag: set by DSP_AlgoChange_CheckAndFlag.
	.equ	MIDI_BacklogCount, 0x27e7
	.equ	RingBuf_OffsetLo, 0x27e6
	.equ	MIDI_RingBuffer, 0x2b0d
	.equ	DSP2_RingBuffer, 0x3b60
	.equ	DSP_ConfigBuffer, 0x448e
	.equ	DSP_ConfigBuffer_Shadow, 0x45ca
	.equ	DSP_SlotMuteState, 0x45bc
	.equ	EFF_SlotActiveFlags, 0x4930
	.equ	DSP_ChipActiveFlags, 0x493a
	.equ	DSP_AlgoChangedFlag, 0x493e

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
