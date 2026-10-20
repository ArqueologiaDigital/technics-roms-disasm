# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# tramp.s -- the program menu's trampoline (README.md, "Starting a program"). It runs at T_CODE, in RAM
# no program uses at that moment, because what it does overwrites the menu: it puts the chosen program,
# already read into STAGE and checked there by the menu (header and CRC-32, as the loader checks), at
# APP_BASE, exactly as the loader would have, and hands the converter calls over to it.
#
# The menu copies this image to T_CODE (its bytes are in menu.s, from tramp_bin.inc), fills the data
# block at T_DATA (menu.inc TD_*), writes the instruction-cache sled at T_SLED, empties the data cache and
# runs the sled, and calls Launch with `calls`, from its own entry's frame. Launch:
#   1. copies TD_SIZE bytes from STAGE to APP_BASE, and zeroes the rest of the application area up to the
#      launch block, as the loader zeroes the whole area before it loads (CNV_END - 0x100 = LB_ADDR);
#   2. compares APP_BASE with STAGE byte for byte (the CRC-32 the menu checked on STAGE then holds here)
#      and checks the header as the loader does (magic, loader ABI, link address, size, entry);
#   3. writes the launch block (kn7cnv.inc LB_*): the program's folder;
#   4. empties the data cache (EVICT_LEN bytes of program flash read, a load per 16-byte line), so that
#      the new code is in RAM, and runs the sled twice, so that no line of the menu's code stays in the
#      instruction cache where the new program now is;
#   5. answers request 1 (call again, no repaint) and returns straight to the loader, with the stack
#      pointer and the registers the loader called the menu with (TD_RETSP; the menu's entry saved them
#      with `movm [d2,d3,a2,a3], (sp)` and made a 0x20-byte frame). From the next converter call on, the
#      loader calls the new program's entry (AH_ENTRY), as if it had loaded the program itself.
# If step 2 fails (it cannot, short of a fault: the copy is RAM to RAM), the launch block is zeroed and a
# header is written at APP_BASE whose entry is ErrApp, here: it answers request 5 with a short text for
# HOLD_MS (or HOLD_CALLS calls), then 0xFE; "Continue Next?" YES then makes the loader load the menu again.
#
# It calls no firmware routine and nothing of the loader; it reads only SVC+SV_MSCOUNT (through TD_MS)
# and writes only APP_BASE..LB_ADDR+LB_LEN, T_DATA and the mailbox. Calling convention as menu.s.

.include "kn7cnv.inc"
.include "menu.inc"
.mnbase T_CODE

Launch:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     T_DATA, a3
    mov     (TD_SIZE, a3), d2       # d2 = bytes
    mov     STAGE, a0               # 1. the copy: (size + 3) / 4 words
    mov     APP_BASE, a1
    mov     d2, d1
    add     3, d1
    lsr     2, d1
    cmp     0, d1
    beq     la_zero
la_copy:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     la_copy
la_zero:
    mov     APP_BASE, a1            # then zeros from APP_BASE + size: bytes to a word boundary ...
    add     d2, a1
la_zb:
    mov     a1, d0
    and     3, d0
    beq     la_zw0
    clr     d0
    movbu   d0, (a1)
    inc     a1
    bra     la_zb
la_zw0:
    mov     LB_ADDR, d1             # ... and words up to the launch block, and the block itself
    add     LB_LEN, d1
    clr     d0
la_zw:
    cmp     d1, a1
    bcc     la_cmp
    mov     d0, (a1)
    add     4, a1
    bra     la_zw
la_cmp:
    mov     STAGE, a0               # 2. what landed equals what was checked
    mov     APP_BASE, a1
    mov     d2, d3
    cmp     0, d3
    beq     la_bad_copy
la_cmp1:
    movbu   (a0), d0
    movbu   (a1), d1
    cmp     d1, d0
    bne     la_bad_copy
    inc     a0
    inc     a1
    add     -1, d3
    bne     la_cmp1
    mov     TR_HEADER, d3           # the header, as the loader checks it
    mov     0x40, d0
    cmp     d0, d2
    bcs     la_fail
    mov     (APP_BASE+AH_MAGIC), d0
    mov     0x41374E4B, d1          # "KN7A"
    cmp     d1, d0
    bne     la_fail
    mov     (APP_BASE+AH_ABI), d0
    cmp     LOADER_ABI, d0
    bne     la_fail
    mov     (APP_BASE+AH_BASE), d0
    mov     APP_BASE, d1
    cmp     d1, d0
    bne     la_fail
    mov     (APP_BASE+AH_SIZE), d0
    cmp     d2, d0
    bne     la_fail
    mov     (APP_BASE+AH_ENTRY), d0
    mov     APP_BASE+AH_NAME+0x20, d1
    cmp     d1, d0
    bcs     la_fail
    mov     APP_BASE, d1
    add     d2, d1
    cmp     d1, d0
    bcc     la_fail
    mov     T_DATA+TD_LB, a0        # 3. the launch block
    mov     LB_ADDR, a1
    mov     LB_LEN/4, d1
la_lb:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     la_lb
    clr     d0
    mov     d0, (TD_RESULT, a3)
    bra     la_caches
la_bad_copy:
    mov     TR_COPY, d3
la_fail:
    mov     d3, (TD_RESULT, a3)     # the launch block stays zero; ErrApp takes the calls
    clr     d0
    mov     d0, (TD_STATE, a3)
    mov     APP_BASE, a0
    mov     0x41374E4B, d0
    mov     d0, (AH_MAGIC, a0)
    mov     LOADER_ABI, d0
    mov     d0, (AH_ABI, a0)
    mov     0x40, d0
    mov     d0, (AH_SIZE, a0)
    mov     ErrApp, d0
    mov     d0, (AH_ENTRY, a0)
    clr     d0
    mov     d0, (AH_CRC, a0)
    mov     APP_BASE, d0
    mov     d0, (AH_BASE, a0)
la_caches:
    call    EvictD, 0, 0            # 4. the new code to RAM, the menu's out of the I-cache
    mov     T_SLED, a0
    calls   (a0)
    mov     T_SLED, a0
    calls   (a0)
    mov     MAILBOX, a0             # 5. request 1: call again at once, leave the screen alone
    mov     RQ_PARK, d0
    movbu   d0, (a0)
    clr     d0
    movbu   d0, (1, a0)
    movbu   d0, (2, a0)
    movbu   d0, (3, a0)
    movbu   d0, (4, a0)
la_return:
    mov     (T_DATA+TD_RETSP), a0   # back to the loader, from the menu's entry frame
    add     -0x30, a0
    mov     a0, sp
    ret     [d2,d3,a2,a3], 0x30

# EvictD: read EVICT_LEN bytes of program flash, one load per 16-byte line, through the cached view:
# every line of the data cache is replaced, and a dirty one written back to RAM first. Leaf.
EvictD:
    mov     EVICT_FROM, a0
    mov     EVICT_LEN/16, d1
ev_line:
    mov     (a0), d0
    add     16, a0
    add     -1, d1
    bne     ev_line
    rets

# ErrApp: the entry the failed launch leaves in the header at APP_BASE. Shows why, through request 5,
# for HOLD_MS (HOLD_CALLS calls without a millisecond counter), then ends the conversion: the firmware's
# message, EXIT, "Continue Next?" YES loads the menu again (the loader reads C:\KN7APP.BIN).
ErrApp:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     T_DATA, a3
    mov     (TD_MS, a3), a0
    cmp     0, a0
    beq     ea_calls
    mov     (a0), d0                # the time since the first call
    mov     (TD_STATE, a3), d1
    cmp     0, d1
    bne     ea_ms
    or      1, d0
    mov     d0, (TD_STATE, a3)
    bra     ea_show
ea_ms:
    sub     d1, d0
    mov     HOLD_MS, d1
    cmp     d1, d0
    bcc     ea_end
    bra     ea_show
ea_calls:
    mov     (TD_STATE, a3), d0
    inc     d0
    mov     d0, (TD_STATE, a3)
    mov     HOLD_CALLS, d1
    cmp     d1, d0
    bcc     ea_end
ea_show:
    mov     MAILBOX, a0             # request 5 and the text after it
    mov     RQ_TEXT, d0
    movbu   d0, (a0)
    mov     T_DATA+TD_MSG, a1
    mov     95, d1
ea_cpy:
    inc     a0
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     ea_ret
    inc     a1
    add     -1, d1
    bne     ea_cpy
    clr     d0
    movbu   d0, (1, a0)
    bra     ea_ret
ea_end:
    mov     MAILBOX, a0
    mov     RQ_END, d0
    movbu   d0, (a0)
ea_ret:
    ret     [d2,d3,a2,a3], 0x30

tramp_end:
