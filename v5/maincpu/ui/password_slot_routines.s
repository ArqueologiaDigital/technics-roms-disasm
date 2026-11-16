; =============================================================================
; password_slot_routines.asm - Password Slot Management Routines
; =============================================================================
; These routines manage password slots for file protection.
; Each song/file can have a password stored in one of 10 slots.
;
; Memory locations:
;   (0x8942 / 0x8944, listed here until 2026-11-16 as password values 1 / 2, are the SMF DIRECT PLAY page's
;   toggles SmfPlayAsGm and SmfMidiOut_OnOff, at v10's addresses; see shared/ram_variables.s.)
;   0x8504: Slot limit 1
;   0x8506: Slot limit 2
;   0x8508: Slot limit 3
;   0x09480e: External password slot storage
;   0x0ab000 + slot*0x800 + 0x1c: Password data per slot
;
; Key routines:
;   (SysData_F92C0E / SysData_F92C13, listed here until 2026-11-16 as the getters of password values 1 / 2,
;   are Smf_GetPlayAsGm and Smf_GetMidiOut in file_io/medley.s.)
;   SysData_F92C21   - Navigate password slots (mode 1)
;   SysData_F92C70   - Navigate password slots (mode 2)
;   SysData_F92CAC   - Navigate password slots (mode 3)
;   SysData_F94193   - Store password to slot
;   SysData_F941C8   - Get password from slot
;   SysData_F941F9   - Find first empty slot
;   SysData_F9420F   - Store password to all slots
;   SysData_F94229   - Find empty and store to all
;   SysData_F94236   - Check if slot matches password
;   SysData_F94242   - Check if any slot has password
;   SysData_F9424A   - Set external password slot
;   SysData_F94250   - Get external password slot
;   SysData_F94256   - Check if external matches
;   SysData_F94262   - Check if external has value
; =============================================================================

; All password slot labels (SysData_F92C0E through SysData_F94262) are now
; positioned labels in medley.asm. The binclude regions that previously
; covered F92C0E-F92CE7, F94193-F94269, and F9426A-F95082 have been
; removed since medley.asm produces the same bytes.
