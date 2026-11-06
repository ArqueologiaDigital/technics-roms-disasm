# v6 / v5: the 64 work-RAM pointers after Naka_DrawbarReg_Table (one per chord type, read by
# MainChordPre_AppendChordSuffix) take v10's member name.  ported_c_rebase.py --ram-self names them
# <member before>_RamPtrs; v10 / v9 / v7 have called them ChordName_TypeRootTables since 57cfaeeae
# (naka_type_trackmixer_map.py).  Lane open12/v6v5-port3; a step of v6/maincpu/README.md's sequence.
s/\bNaka_DrawbarReg_Table_RamPtrs\b/ChordName_TypeRootTables/g
