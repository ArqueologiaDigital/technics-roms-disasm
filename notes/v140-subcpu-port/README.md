# Sub-CPU payload v1.40: the source tree and what changed in v1.41 (2026-10-24)

`v140/subcpu/` is a byte-exact source tree for `original_ROMs/kn5000_subprogram_v140.rom`
(196,608 B, SHA-1 `b7f471522ab3125e5eb42c7368d57a56084ce32a`). The same build, recompressed
with the factory stream's decisions, reproduces the firmware-update image
`original_ROMs/kn5000_subprogram_v140_compressed.rom` (93,124 B, SHA-1
`13098dd150c5a6083a5d15a63d5d785802d8e8ae`). `make gate` checks both, in the
`kn5000_subprogram_v140` and `kn5000_subprogram_v140_compressed` rows. Both files were already
tracked (the plain image was extracted from the update image, the only surviving copy), so this
work adds no image to git.

The tree is generated: `scripts/generators/create_v140_subcpu_source.py` copies `v141/subcpu/`
(itself `v142/subcpu/` plus `create_v141_subcpu_source.py`'s edits) and applies its `EDITS`
list. **That list is the whole v1.40 / v1.41 difference.** `make gate` runs its `--check`
right after the v141 one.

Spelling in the edits: an instruction that v1.41 also has at that spot keeps v1.41's text
byte for byte, which is v142's space after the mnemonic, so `diff v141/subcpu v140/subcpu`
shows only real changes. New or changed instructions use the tab style the policy asks for.
The exception is `DSP_SetVoiceCoefficients`: it is a rewrite (different registers, no stack
frame), written in tab style throughout, so a diff of that function shows every line.

## What changed between v1.40 and v1.41

The raw diff is 56,018 B in 2,508 runs (issue `kn5000-v41`). Apart from the version word,
every real change is inside one compiled-C function: the sub-CPU's handler for inter-CPU
messages from the main CPU (the loop from `DSP_Process_NextCmd` to `DSP_Process_Exit`, header
above `Audio_Process_DSP_MsgSizeCheck`), and the routine its sub-command 0x24 calls.

| # | where (v1.41 labels)                                        | v1.40                                                                                      | v1.41                                                                                                      | size in v1.40   |
|---|-------------------------------------------------------------|--------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|-----------------|
| 1 | version word at 0x00f000                                    | 140                                                                                        | 141                                                                                                        | same            |
| 2 | `DSP_Cmd2B_SetParam` (0x2b message, sub-command 0x24)       | looks up the patch record and the sub-tone reference itself, passes (lo, hi) to the callee | passes (part, i) straight from the payload                                                                 | +82 B           |
| 3 | `DSP_SetVoiceCoefficients` (the callee)                     | takes the reference; bit 5 set: `ToneDB_Find_ToneRecord(lo, hi)`; no stack frame           | takes (part, i), does the lookup; bit 5 set: `ToneDB_Find_SubToneRecord(patchrec, i, 0xff)`; 10-byte frame | -134 B          |
| 4 | the `jr` after `DSP_Cmd2B_ReadParam5D`                      | `jrl`: `DSP_Cmd2B_PostProcess` is out of 8-bit range once item 2 grew                      | `jr`                                                                                                       | +1 B            |
| 5 | `DSP_Cmd2B_VoiceParamWrite`                                 | channel nibble in QIZ, 14-bit parameter index in IZ                                        | the other way round                                                                                        | +1 B            |
| 6 | `DSP_Process_ReadNext` and `Audio_Process_DSP_MsgSizeCheck` | the type word from `DSP_RingBuf_Read` stays in IZ; the reader takes IZL                    | stored to the frame slot (XSP+12) and read back from it                                                    | -2 B, then same |

Items 2 and 3 are one change. Here is what sub-command 0x24 does. The main CPU sends a part
number (payload byte 0, at 0x4370) and a sub-tone index `i` (payload byte 1, at 0x4371). The
sub-CPU replies with the 10-byte ToneDB record that the part's patch record names in its
`i`-th sub-tone reference: the {lo, hi} pair at patch record + 0x27 + 2*i. The answer goes out
through `DSP_Cmd2B_PostProcess` as an echo of HL + 8 bytes. In both versions a reference
without bit 5 of `hi` set goes through the ROM tables (`idx = ((hi & 0x1f) << 7) + (lo &
0x7f)`, then `Root->+0x7c` and `Root->+0xb0`, unchanged). Two things changed:

* **Who does the lookup.** v1.40 does the part -> tone selector -> `ToneDB_Find_ToneRecord`
  -> reference steps inline in the message handler. v1.41 moves them into
  `DSP_SetVoiceCoefficients`, which then needs a frame to keep the part, `i` and the
  destination across the call. Moving the code costs v1.41 52 bytes overall: 134 more in the
  callee, 82 fewer in the caller.
* **How a reference with bit 5 set is resolved.** v1.40 hands the raw reference bytes (lo,
  hi, unmasked) to `ToneDB_Find_ToneRecord` as if they were a tone selector. v1.41 calls
  `ToneDB_Find_SubToneRecord` with the patch record, `i` and a part argument of 0xff. That
  routine reads the same {lo, hi} pair and goes on into `ToneDB_Resolve_NamedToneRecord`,
  whose bit-5 branch (`ToneDB_Resolve_NamedToneRecord_User`) computes an address in the RAM
  user-tone banks (the `VoiceBuf_Lookup_*` paths: `ToneDB_RamBankA` / `ToneDB_RamBankB` +
  0x4aa7 + 0x50*`i`). In other words, v1.41 serves this query for a user (RAM) sub-tone from
  the user-tone area, and v1.40 did not. `[INFERENCE]` That reads as a bug fix in v1.41 for
  querying user tones over the inter-CPU link. The main-CPU side that sends sub-command 0x24
  has not been traced, so what the user would have seen is not established. In v1.41
  `DSP_VoiceParam_Dispatch` still resolves bit-5 references through `ToneDB_Find_ToneRecord`,
  so v1.41 did not change this everywhere.

Items 5 and 6 change no behaviour. They are register-allocation differences, which is what a
recompile of the same function produces once item 2 changes its body. The arguments passed and
the values compared are the same.

Item 2 adds 82 bytes, and items 4, 5 and 6 add 1, 1 and -2. With item 3's -134, v1.40 code
from `DSP_SetCoeff_CopyDirect` to `DSP_Cmd2B_ReadParam5D` sits 0x86 below v1.41, and from
`DSP_Process_Exit` to the end 0x34 below it (-134 + 82 + 1 + 1 - 2 = -52). So does the zero-initialised RAM
that is linked after the image (`Payload_Bss_Start` is 0x03ee2a, not 0x03ee5e), and the image
carries 52 more bytes of 0xff tail fill. Both trees spell those RAM operands
`Payload_Bss_Start+offset`, so no edit is needed for them.

## How it was found and checked

    python3 scripts/analysis/subcpu_v141_v142_alignment.py \
        original_ROMs/kn5000_subprogram_v141.rom original_ROMs/kn5000_subprogram_v140.rom

The aligner (v1.41 as reference) found 2,857 gaps. 2,848 have the same length on both sides
(absolute operands that differ by the shift). Nine change length:

| v1.41 address | v1.41 bytes | v1.40 bytes | what it is                                                  |
|---------------|-------------|-------------|-------------------------------------------------------------|
| 0x031103      | 189         | 80          | item 3 (`DSP_SetVoiceCoefficients`)                         |
| 0x0311d0      | 12          | 8           | item 3                                                      |
| 0x0311e3      | 56          | 35          | item 3                                                      |
| 0x035cc1      | 5           | 73          | items 4 and 2 (the `jr` / `jrl`, then `DSP_Cmd2B_SetParam`) |
| 0x035cce      | 0           | 15          | item 2                                                      |
| 0x035cf4      | 27          | 29          | item 2                                                      |
| 0x035d17      | 11          | 10          | item 5 (the aligner splits it unevenly)                     |
| 0x03601a      | 18          | 16          | item 6                                                      |
| 0x03ef00      | 0           | 52          | the longer tail fill                                        |

The aligner missed one change because it has the same length. In
`Audio_Process_DSP_MsgSizeCheck`, `ld wa, (xsp + 12)` (3 bytes) is `ldto_berp a, 0xf8` in
v1.40 (A = IZL, also 3 bytes). It is the reader of item 6, and the first build attempt found
it as a 3-byte mismatch at 0x035a84. The byte-exact build is the proof that nothing else
differs.

Where each label moved, measured from the two ELFs:

    python3 scripts/analysis/subcpu_version_address_map.py \
        rebuilt_ROMs/kn5000_subprogram_v141.llvm.elf rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf

| shift (v1.40 - v1.41) | from (v1.41) | to (v1.41) | labels | first .. last label                                    |
|-----------------------|--------------|------------|--------|--------------------------------------------------------|
| 0                     | 0x000400     | 0x031103   | 3,180  | `PAYLOAD_ENTRY` .. `DSP_SetVoiceCoefficients`          |
| -0x6b .. -0x83        | 0x0311a5     | 0x031213   | 6      | the labels inside `DSP_SetVoiceCoefficients`           |
| -0x86                 | 0x031218     | 0x035ca8   | 552    | `DSP_SetCoeff_CopyDirect` .. `DSP_Cmd2B_ReadParam5D`   |
| -0x85                 | 0x035cc3     | 0x035cc3   | 1      | `DSP_Cmd2B_SetParam`                                   |
| -0x33                 | 0x035cde     | 0x035d07   | 4      | `DSP_Cmd2B_ReadParam11` .. `DSP_Cmd2B_VoiceParamWrite` |
| -0x32                 | 0x035d33     | 0x03601c   | 36     | `DSP_Cmd2B_PostProcess` .. `DSP_Process_ReadNext`      |
| -0x34                 | 0x03602d     | 0x0451b4   | 1,284  | `DSP_Process_Exit` .. `ToneGen_StagingBlock` (RAM)     |

Run with no arguments (v142 against v140), the same script gives the v1.42 -> v1.40 map that
the v140 banner states. v140's comments are v142's, so their addresses are v1.42 addresses.
`symbols/subcpu_v140_symbols_reference.txt` (5,063 names, `l2_symbol_reference.py --regen
--only subcpu_v140`) has the v1.40 address of every name.

## Names

No new labels were needed. v1.40's `DSP_SetVoiceCoefficients` has the same seven labels as
v1.41's, at the same points in the control flow. The roles match: the vestigial four-way
compare target, the index computation, the bit-5 lookup, the copy loop and the return. So the
v1.42 names are kept for cross-version diffing, and the comments say where v1.40 differs. The
name `DSP_SetVoiceCoefficients` is misleading in every version, because nothing in it touches a
DSP. v1.42's own header says so. Renaming it is a v142 change and outside this port.

## Reproduce

    python3 scripts/generators/create_v140_subcpu_source.py --check
    make rebuilt_ROMs/kn5000_subprogram_v140_compressed.rom   # builds v140, compresses, cmp
    make -j3 gate KN5000_V8_REF=<path to kn5000_v8_program.rom>
