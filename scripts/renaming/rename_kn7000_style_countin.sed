# N-1af8fb95 (lane mn10300-names, 2026-11-02): 0x484335BF returns the COUNT-IN pattern record for
# the main variation's meter (COUNT INTRO param 0xD00A -> CountIntroRecordTable, else IC18's
# count-in table), not a variation name; 0x48433AB6 returns the "a count-in is bound" flag.
# Run on kn7000_manual.sym and kn7000/tools/gen_program_s.py; the generated files follow.
s/StyleVariationNameFlagGet/StyleCountInBoundGet/g
s/StyleVariationNameGet/StyleCountInRecordGet/g
