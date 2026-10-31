# open4/wsa1-b (2026-10-31): gap R -- SC1 states 0x04/0x0C/0x14 named after their
# KN5000 twins CPanel_SM_StartTX / _TXDelay1 / _TXDelay2; gap W -- the write side
# of 0x7B0004 is the uPD72070's data rate select register (notes/prom_a_fdc_checks.py
# section 8).
s/\bSC1_State04_TxByte1\b/SC1_State04_StartTx/g
s/\bSC1_State0C\b/SC1_State0C_TxGap1/g
s/\bSC1_State14\b/SC1_State14_TxGap2/g
s/\bDev7B_WriteControl_Shadowed\b/Dev7B_WriteDsr_Shadowed/g
s/\bDev7B_WriteControl\b/Dev7B_WriteDsr/g
s/\bFdc_WriteControlRegister_IfNoError\b/Fdc_WriteDsr_IfNoError/g
s/\bFdc_WriteControlRegister_AndReadResult\b/Fdc_WriteDsr_AndReadResult/g
s/\bFdc_WriteControlRegister\b/Fdc_WriteDsr/g
