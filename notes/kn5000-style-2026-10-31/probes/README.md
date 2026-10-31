# Probes of lane kn5000-style (2026-10-31)

Every script is read-only and takes the repository (or an extracted floppy directory) as an argument.

| script                  | question it answers                                                                                                                      | command                                                           |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| `style_bank_readers.py` | Which v10 instructions touch the Composer style image's header, section records and the area after the directory? (ABS / IMG / REC rows) | `python3 style_bank_readers.py [REPO] [--window N] [--off LO HI]` |
