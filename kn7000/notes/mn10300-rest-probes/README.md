# mn10300-rest probes

Lane `mn10300-rest` of the open-items effort (2026-10-31). The notes are `../mn10300-rest/README.md`. Run every
probe from the repository root, with the reference images built (`baserom/` of kn7000, kn6000, kn6500, kn2400,
hdsx3); `python3 -I` keeps them from importing anything beside them. They read the committed sources, symbol
files and images and write nothing (rest_stats.py writes only into the scratch directory it is given).

| script                        | question it answers                                                                                                                                                                                    | run                                                                                          |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `rest_stats.py`               | For one gen_data_s.py profile, with the lane's rules off (main) and on (all, one with `--only R`, all but one with `--drop R`): typed bytes, reader rows, opaque pieces / bytes, offset-named fields with a reader, line churn, bytes typed in one run only | `python3 kn7000/notes/mn10300-rest-probes/rest_stats.py --profile 941 --scratch DIR`         |
| `kn6000_swno_states.py`       | What do the KN6000's switch states 0..3 select (payload bytes, ShortKeyHash key groups, names, sizes), does the ShortKeyHash -> sound -> ToneKeyHash round trip hold, who calls SoundSwNoGet and its inverse? | `python3 -I kn7000/notes/mn10300-rest-probes/kn6000_swno_states.py`                         |
| `kn7000_tone_hash_readers.py` | Which routines of program 941 look the 'Tone' hash up and read each payload byte; the payload's ranges, the switch-key groups and sizes, the round trip                                               | `python3 -I kn7000/notes/mn10300-rest-probes/kn7000_tone_hash_readers.py`                   |
| `tg_side_bits.py`             | Which TG does each zone side bit select: the six instructions of the chain TgVoiceSideSelect .. TgVoiceRegWrite, and every zone checked against the MAIN / SUB wave directories under both readings  | `python3 -I kn7000/notes/mn10300-rest-probes/tg_side_bits.py`                                |
| `kn2400_fx_streams.py`        | What are the KN2400's `7c aa aa 7d ...` bytes: the effect-DSP family's extent, blocks, record kinds and counts, and (with `--blocks`) one line per block with its types, units and names               | `python3 -I kn7000/notes/mn10300-rest-probes/kn2400_fx_streams.py [--blocks]`                |
| `kn2400_fx_pnums.py`          | For each KN2400 effect descriptor: its types, connection, the parameters pnum9 / 10 / 11 name, the depth-linked parameters                                                                          | `python3 -I kn7000/notes/mn10300-rest-probes/kn2400_fx_pnums.py`                             |
| `hdsx3_entry_vectors.py`      | The XAPR header's 31 words, and every KN6000 / KN6500 instruction that names 0x978000xx with its routine and its callers                                                                          | `python3 -I kn7000/notes/mn10300-rest-probes/hdsx3_entry_vectors.py`                         |
| `hdsx3_indirect_calls.py`     | How each of the plug-in's `calls (aN)` gets its register (host registry slot and entry, the tag table) and which routine it reaches on each host                                                    | `python3 -I kn7000/notes/mn10300-rest-probes/hdsx3_indirect_calls.py`                        |
| `hdsx3_opaque.py`             | The HD-SX3's opaque data pieces by group (widget variables, powers of ten, name-table sentinels, pointed, unread) with the reader evidence                                                          | `python3 -I kn7000/notes/mn10300-rest-probes/hdsx3_opaque.py`                                |
| `opaque_groups.py`            | Every tree's opaque pieces clustered by kind (generic rules in its docstring), bytes per group; `--by-table`, `--list GROUP`                                                                        | `python3 -I kn7000/notes/mn10300-rest-probes/opaque_groups.py --tree 941` (or `all`)         |
| `opaque_readers_941.py`       | For build 941: each reader the walk misses (widget variables, EUC-JP strings, 128 x 64 maps, chord voicings, panel descriptors ...), checked against the image; bytes explained and left per group | `python3 -I kn7000/notes/mn10300-rest-probes/opaque_readers_941.py [--widget] [--left N]`    |
| `kn6000_opaque.py`            | The same for the KN6000 and KN6500, per group with its reader rule                                                                                                                                 | `python3 -I kn7000/notes/mn10300-rest-probes/kn6000_opaque.py --model both [--left N]`       |
| `kn2400_opaque.py`            | The same for the KN2400 (and, with `--all-trees`, the powers-of-ten check in every image)                                                                                                         | `python3 -I kn7000/notes/mn10300-rest-probes/kn2400_opaque.py [--left N] [--all-trees]`      |

## What the signals are

- The opaque probes read the `# census: opaque -- unknown-dump` line and the `.incbin_range` after it in a
  tree's data sources: those are the pieces measured. A reader "found" is an instruction (routine label, CPU
  address, text) that reads the bytes through a path the linear walk does not follow; the probe checks the
  layout it implies against the image bytes (every record parses, every end marker is where the layout says).
- `tg_side_bits.py`: a zone's side is bits 2 / 3 of its byte +1 (halfword +0 bits 10 / 11); "in Main" means
  `Main_Ppp_Eeee` exists in `src/wave/main.s` for the zone's page and entry.
- `kn6000_swno_states.py` / `kn7000_tone_hash_readers.py`: the round trip takes every switch-key entry's
  {msb, lsb, program}, looks the sound up in the tone-key hash and checks that the payload's switch for that
  state is the switch-key entry's key.
- The finding probes (all but `rest_stats.py`) find routines and tables by the labels the sources had when
  they were written, the lane's base 43242446d; this lane's regeneration renames many of them (func_4863CDB5
  is FxPresetGet now ...). Run them in a checkout of that commit with the reference images copied
  (`git worktree add <dir> 43242446d`); the figures in the notes are from there. The image addresses they
  print do not change.
