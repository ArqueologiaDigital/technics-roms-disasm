/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDC_ReadDataRegister FDC_Read_Status FDC_ResultPhase_Read FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParam_SeekTrack FDC_SendParameterByte FDC_SendParams_Format FDC_SendParams_ReadWrite FDC_SendParams_Specify FDC_Send_Command FDC_Set_Status FDC_ValidateOpcode FDC_WaitParamByteReady FDC_WaitReady FDC_Wait_Ready_Timeout FDC_WriteAuxCmdByte FDC_WriteDataRegister */   /* scripts/analysis/cc900/module_calls.py v10 */

void FDC_Send_Command();
extern void FDC_Send_Command();
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_RESULT[];
extern void FDC_ResultPhase_Read(void);
extern void FDC_Wait_Ready_Timeout(void);
unsigned char FDC_ReadDataRegister();
void FDC_WriteAuxCmdByte();
extern unsigned char FDC_ReadDataRegister();
extern void FDC_WriteAuxCmdByte();
extern void FDC_SendAuxCmdReadResult();
void FDC_WriteDataRegister();
void FDC_SendParameterByte();
extern void FDC_WriteDataRegister();
extern void FDC_WaitParamByteReady();
extern void FDC_SendParameterByte();

void FDC_Send_Command(c)
unsigned char c;
{
    *(unsigned char *)0x110008 = c;
}

void FDC_SendAuxCmdReadResult(c)
unsigned char c;
{
    FDC_ResultPhase_Read();
    if (FDC_ERROR_CODE != 0) return;
    FDC_WriteAuxCmdByte(c);
    FDC_Wait_Ready_Timeout();
    FDC_RESULT[1] = FDC_ReadDataRegister();
}

void FDC_SendParameterByte(c)
unsigned char c;
{
    FDC_WaitParamByteReady();
    FDC_WriteDataRegister(c);
}
