# N-ccdc980d (lane mn10300-names, 2026-11-02): the library's sound-command stream writer
# 0x4C003A60 is TgcBufWrite in the firmware's own tables (program 942's plug-in export table,
# IDNAME FN_TgcBufWrite; the KN6000 / KN6500 reflection tables).  Run on kn7000_manual.sym,
# kn7000/tools/gen_program_s.py and the notes, then regenerate (the generated files follow).
s/SndCmdStreamWrite/TgcBufWrite/g
