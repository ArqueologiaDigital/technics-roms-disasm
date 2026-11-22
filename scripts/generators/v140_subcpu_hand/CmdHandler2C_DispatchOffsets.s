CmdHandler2C_DispatchOffsets:
	.short CmdHandler2C_TableData - CmdHandler2C_TableData           	; sub-cmd 0x00
	.short CmdHandler2C_Global_MixParamA - CmdHandler2C_TableData    	; sub-cmd 0x01
	.short CmdHandler2C_Global_MixParamB - CmdHandler2C_TableData    	; sub-cmd 0x02
	.short CmdHandler2C_Global_MonoMode - CmdHandler2C_TableData     	; sub-cmd 0x03
	.short CmdHandler2C_Global_BendRange - CmdHandler2C_TableData    	; sub-cmd 0x04
	.short DSP_Process_ReadNext - CmdHandler2C_TableData             	; sub-cmd 0x05
	.short CmdHandler2C_Global_MixParamC - CmdHandler2C_TableData    	; sub-cmd 0x06
	.short CmdHandler2C_Global_SetValue45B8 - CmdHandler2C_TableData 	; sub-cmd 0x07
	.short CmdHandler2C_Global_SetEnable45BA - CmdHandler2C_TableData	; sub-cmd 0x08
	.short DSP_Process_ReadNext - CmdHandler2C_TableData             	; sub-cmd 0x20
	.short CmdHandler2C_Global_SetValue4504 - CmdHandler2C_TableData 	; sub-cmd 0x21
	.short CmdHandler2C_Global_SetValue453C - CmdHandler2C_TableData 	; sub-cmd 0x22
	.short CmdHandler2C_Global_SetAlgoType - CmdHandler2C_TableData  	; sub-cmd 0x23
	.short CmdHandler2C_Global_SetValue4574 - CmdHandler2C_TableData 	; sub-cmd 0x24
	.short CmdHandler2C_Global_SetValue45AC - CmdHandler2C_TableData 	; sub-cmd 0x25
