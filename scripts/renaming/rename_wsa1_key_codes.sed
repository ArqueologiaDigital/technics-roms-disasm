# wsa1: panel key codes 0x11-0x19 are the soft-key columns' and PAGE's second event (PanelEvent_ToFieldIndex
# folds 0x11-0x18 onto ops 0-7 with flag bit 7 and 0x19 onto op 0x10); see wsa1/include/wsa1_gui.inc.
s/\bKEY_Code11\b/KEY_SoftKeyCol1Alt/g
s/\bKEY_Code12\b/KEY_SoftKeyCol2Alt/g
s/\bKEY_Code13\b/KEY_SoftKeyCol3Alt/g
s/\bKEY_Code14\b/KEY_SoftKeyCol4Alt/g
s/\bKEY_Code15\b/KEY_SoftKeyCol5Alt/g
s/\bKEY_Code16\b/KEY_SoftKeyCol6Alt/g
s/\bKEY_Code17\b/KEY_SoftKeyCol7Alt/g
s/\bKEY_Code18\b/KEY_SoftKeyCol8Alt/g
s/\bKEY_Code19\b/KEY_PageAlt/g
