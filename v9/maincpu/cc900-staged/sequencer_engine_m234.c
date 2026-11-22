/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord_Off1 PartCtrl_TestBit7 Part_WriteSubBlock32 Part_WriteSubBlock48 SeqData_SetErrorCode */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
extern void PartCtrl_NavigateBackward(void);
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern void PartCtrl_NavigateBackwardAlt(void);

void PartCtrl_NavigateBackward(void)
{
	unsigned int b;

	if (SEQOP_SECONDARY_OFFSET != 5)
		SEQOP_SECONDARY_OFFSET--;
	else {
		b = PartCtrl_ReadWord_Off1(SEQOP_SECONDARY_BLOCK);
		if (PartCtrl_TestBit7(b) == 0) {
			SeqData_SetErrorCode(0x47);
			SEQ_ERROR_CODE = 2;
		} else if (b == 0 || b == 0xffff)
			SEQ_ERROR_CODE = 11;
		else {
			SEQOP_SECONDARY_BLOCK = b;
			SEQOP_SECONDARY_OFFSET = 255;
		}
	}
}

void PartCtrl_NavigateBackwardAlt(void)
{
	unsigned int b;

	if (SEQOP_PRIMARY_OFFSET != 5)
		SEQOP_PRIMARY_OFFSET--;
	else {
		b = PartCtrl_ReadWord_Off1(SEQOP_PRIMARY_BLOCK);
		if (PartCtrl_TestBit7(b) == 0) {
			SeqData_SetErrorCode(0x48);
			SEQ_ERROR_CODE = 2;
		} else if (b == 0 || b == 0xffff)
			SEQ_ERROR_CODE = 11;
		else {
			SEQOP_PRIMARY_BLOCK = b;
			SEQOP_PRIMARY_OFFSET = 255;
		}
	}
}
