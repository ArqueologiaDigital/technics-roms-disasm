# ui/password_slot_routines.s's header (every main-CPU tree; the same text in each) listed the SMF DIRECT PLAY
# toggles as password values and their getters as password getters.  Owner, 2026-11-16.
/^;   0x8942: Password value 1$/c\
;   (0x8942 / 0x8944, listed here until 2026-11-16 as password values 1 / 2, are the SMF DIRECT PLAY page's\
;   toggles SmfPlayAsGm and SmfMidiOut_OnOff, at v10's addresses; see shared/ram_variables.s.)
/^;   0x8944: Password value 2$/d
/^;   SysData_F92C0E   - Get password value 1$/c\
;   (SysData_F92C0E / SysData_F92C13, listed here until 2026-11-16 as the getters of password values 1 / 2,\
;   are Smf_GetPlayAsGm and Smf_GetMidiOut in file_io/medley.s.)
/^;   SysData_F92C13   - Get password value 2$/d
