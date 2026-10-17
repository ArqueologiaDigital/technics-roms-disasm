# naka_widget_names_charmap.c (v10/v9/v7): the icon-table name strings follow the IconName_ prefix (CLAUDE.md data
# labels; IconName_Empty already sits beside them).  IconIDProc_NameTable[k] points at icon k's name: "None",
# "Default", then "i0" .. "i173" for k = 2 .. 175 -- the firmware's own names, which these members held as i<n>_str
# (and I0_code for "i0").  Apply to that one file per tree; the names occur nowhere else.
s/\bI0_code\b/IconName_i0/g
s/\bi\([0-9][0-9]*\)_str\b/IconName_i\1/g
