# N-edb08959 (lane open6/kn5000-d naming, 2026-11-02), v6 and v5 only: their port carried a neighbour's name onto
# the COMPOSER CHORD MAP getter (XIY = RHYTHM_PATTERN_BUF_A + 0xBA0 + 32 * (0x3852), v6/v5's 0x390A); v10 / v9 / v7
# call the same routine ComposerChordMap_GetRecord (rename_open6_style.sed).
s/\bDrumVoice_NotifyEE_Helper5\b/ComposerChordMap_GetRecord/g
