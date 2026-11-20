# v7: FDC_HardwareSetup_Helper3 is v10's FDC_SendAuxCmd (2026-11-20, lane_p6): the staged FDC_CMD_SEND of v7
# (cc900-staged/fdc_routines_m270_xr_b.c) calls it by that name.  Evidence: the label's bytes equal v10's at
# FDC_SendAuxCmd, unique in the v7 ROM, and the next labels sit at the same offsets (+0x15 Epilogue, +0x18 the
# ReadResult routine); notes/cc900-phase6-2026-11-16/HANDOFF-2026-11-20.md.
# Apply: sed -i -f scripts/renaming/rename_v7_fdc_sendauxcmd.sed v7/maincpu/storage/fdc_routines.s
s/\bFDC_HardwareSetup_Helper3\b/FDC_SendAuxCmd/g
