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
