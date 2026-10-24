# KN7000 program 941: the hand names `Lib<Something>` that sit on the register-save
# `call` entry of a library routine the SP7001 (build 942) export table already names
# (tools/gen_program_s.py printed each one as "<export>  (...; its `call` entry LibX at ...)").
# Such an entry is <export>_entry everywhere else in the tree (memset_entry, memcpy_entry,
# strcpy_entry), so these follow.  The five alias rows at flash addresses 0x487Bxxxx
# (LibPrintf, LibMemSet, LibMemCopy, LibStrCopy, LibResourceLookup) are folded into
# the lib-address rows by scripts/renaming/fold_kn7000_lib_alias_rows.py first.
#
# Applied to kn7000/kn7000_manual.sym, kn7000/tools/gen_program_s.py, kn7000/annotations/*.ann
# and the kn7000 notes that quote the names.  NOT to kn7000/kn7000_ic18.sym or src/ic18: the
# IC18 boot ROM's LibTickSleep / LibIntcEnable / LibIntcDisable are that ROM's own, different
# routines (src/ic18/boot.s: LibTickSleep spins on its own TickCount and returns with retf, the
# two Intc routines index its own IrqSlots table; dly_tsk yields to the kernel, ena_int and
# dis_int go through the kernel's interrupt records).
s/\bLibSprintf\b/sprintf_entry/g
s/\bLibPrintf\b/sprintf_entry/g
s/\bLibStrncmp\b/strncmp_entry/g
s/\bLibParamGet\b/GetM3EmVal_entry/g
s/\bLibParamSet\b/PutM3Em_entry/g
s/\bLibIntcEnable\b/ena_int_entry/g
s/\bLibIntcDisable\b/dis_int_entry/g
s/\bLibTickSleep\b/dly_tsk_entry/g
s/\bLibMemSet\b/memset_entry/g
s/\bLibMemCopy\b/memcpy_entry/g
s/\bLibStrCopy\b/strcpy_entry/g
s/\bLibResourceLookup\b/GetM3Em_entry/g
