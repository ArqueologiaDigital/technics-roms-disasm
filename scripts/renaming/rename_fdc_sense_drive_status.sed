# FDC_INTERRUPT_HANDLER is FDC command 11, SENSE DRIVE STATUS (uPD72068 command 0x04, ST3), as the table_data
# boot driver's twin FDC_CmdSenseDriveStatus already says; it is no interrupt handler (open item N-99d09c1a).
s/\bFDC_INTERRUPT_HANDLER_Code_Epilogue\b/FDC_CmdSenseDriveStatus_Done/g
s/\bFDC_INTERRUPT_HANDLER_Code_Skip2\b/FDC_CmdSenseDriveStatus_CheckWP/g
s/\bFDC_INTERRUPT_HANDLER_Code_Skip\b/FDC_CmdSenseDriveStatus_CheckReady/g
s/\bFDC_INTERRUPT_HANDLER\b/FDC_CmdSenseDriveStatus/g
