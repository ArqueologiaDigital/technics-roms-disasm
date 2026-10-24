# scripts/tools

Fix-up tools for the WSA1 tree: each one changes files, and each one prints what it would change
before it is run with `--apply`. One entry per script: what question it answers, and the exact command.

## `fix_stale_doc_symbols.py`
**"Which stale label names in the notes have a current name, and on what evidence?"**
`scripts/analysis/doc_symbol_check.py` lists the backticked names a note uses that no linked image
defines; this tool resolves the renamed ones from the git rename history of the sources (or, for an
address-derived name, from the label now at that address in the image that defined it) and writes
the current name. Rename-mapping tables, names written as history ("was `X`") and fenced output are
left alone; a table with a changed row is re-padded.

    make all                                                    # the ELFs it reads
    python3 scripts/tools/fix_stale_doc_symbols.py --why        # dry run, with evidence
    python3 scripts/tools/fix_stale_doc_symbols.py --apply
    python3 scripts/analysis/doc_symbol_check.py $(git ls-files '*.md')

## `split_cpu1_images.py`
**"Where do CPU 1's firmware modules begin and end, and does a per-module split of prom_a / prom_b
change anything?"** Cuts each image where a 0x0E (`ret`) pad reaches a 0x100-aligned address (two
written-out exceptions: prom_b's routine directory, prom_a 0xFE0000), writes one verbatim file per
module under `prom_X/modules/`, and leaves `prom_X/wsa1_prom_X.s` as the root that `.include`s them.
Re-runnable: `--emit` always starts from the joined listing. Details and measurements:
`notes/cpu1-module-split-2026-10-24/README.md`.

    python3 scripts/tools/split_cpu1_images.py --plan        # modules, sizes, banners, first labels
    python3 scripts/tools/split_cpu1_images.py --table       # the same, as an aligned Markdown table
    python3 scripts/tools/split_cpu1_images.py --emit        # (re)write the split; 0 changes if current
    python3 scripts/tools/split_cpu1_images.py --verify REV  # joined tree == REV's listing, line for line
    python3 scripts/tools/split_cpu1_images.py --join        # undo
    make gate-wsa1

## `compare_census_json.py`
**"Did a change that only moves lines between files move anything in the dispatch census?"** Compares
two `census_keys.py ... --json` dumps with `file:line` strings ignored, or (`--map`) translated back
to the joined listing's line numbers, so it also checks that every reference still names the same line.

    python3 wsa1/scripts/tools/compare_census_json.py BEFORE.json AFTER.json [--map]

## `migrate_lane_readers.py`
**"Which repository-level lane tools still open prom_a / prom_b's root file as if it were the
image?"** Rewrites `NAME = os.path.join(<root>, "wsa1", "prom_X", "wsa1_prom_X.s")`-style
assignments under `notes/` to the materialised image, and turns any write through that name into a
refusal (the write would otherwise land in the cache file). `notes/migrate_listing_readers.py` does
the same job for the probes under `wsa1/`.

    python3 wsa1/scripts/tools/migrate_lane_readers.py [--apply]
