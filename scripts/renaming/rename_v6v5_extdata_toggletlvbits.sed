# v6 / v5 still call two ExtData routines by older names; v7, v9 and v10 call them ExtData_ToggleTlvBits and
# ExtData_SetTlvField (same bytes and same layout: dec 2,xsp / ld (xsp),a / ld c|a,(EXTDATA_MASK) ...; the
# SetTlvField epilogue `inc 2,xsp / ret` sits at the same place).  The staged C of audio_control_engine_m0*.c and
# _m280.c could not be checked in v6 / v5 without the names (run 2026-11-16-92-p6-r18).
s/\bExtData_ToneParam_DispatchHandler_Helper2_Epilogue\b/ExtData_SetTlvField_Epilogue/g
s/\bExtData_ToneParam_DispatchHandler_Helper2\b/ExtData_SetTlvField/g
s/\bExtData_ToneParam_DispatchHandler_Helper\b/ExtData_ToggleTlvBits/g
