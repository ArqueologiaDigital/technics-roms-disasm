# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# guard_selftest.s -- what guard.py --selftest must find: each line marked PLANTED names an address the menu
# may not (run_menu_tests.sh guard counts them against guard.py's findings); the lines marked ALLOWED it must
# let pass.
.include "kn7cnv.inc"
.include "menu.inc"
.mnbase APP_BASE
    mov     (SVC+SV_RAWREAD), a0    # ALLOWED: a load of a service the menu uses
    mov     (SVC+SV_MSCOUNT), d0    # ALLOWED
    mov     (SVC+SV_WRITE), a0      # PLANTED: a write routine
    mov     (SVC+SV_RAWWRITE), a0   # PLANTED: the raw sector write
    mov     (SVC+SV_MKDIR), a0      # PLANTED: making a folder
    mov     (SVC+SV_SETPATH), a0    # PLANTED: changing the SD folder
    mov     d0, (SVC+SV_FG)         # PLANTED: a store into the service table
    mov     SVC, a0                 # PLANTED: the table's address taken
    mov     (LOADER_VARS), d0       # PLANTED: the loader's variables
    mov     0x44000000, a0          # PLANTED: IC23
    movbu   d0, (0x84000010)        # PLANTED: IC23, uncached
    mov     0x50200000, a1          # PLANTED: the user-memory pools
    .long   0x90180000              # PLANTED: the pools, uncached, as data
    .long   0x502B9E00              # PLANTED: the service table as data
    mov     MAILBOX, a0             # ALLOWED: the mailbox
