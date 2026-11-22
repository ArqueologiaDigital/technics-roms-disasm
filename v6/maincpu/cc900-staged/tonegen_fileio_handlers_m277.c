/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ValidateRecord PanelTlv_WriteRecordHeader */   /* scripts/analysis/cc900/module_calls.py v10 */

struct tlvrec { unsigned long off; unsigned char *rules; unsigned char tag; unsigned char len; };
extern struct tlvrec PanelTlv_Block1_Layout[];
extern void PanelTlv_ValidateRecord(unsigned char *base, struct tlvrec *l);
extern void PanelTlv_ValidateBlock1(unsigned char *base);
extern struct tlvrec PanelTlv_Block0_Layout[];
extern void PanelTlv_WriteRecordHeader(unsigned char *base, struct tlvrec *l);
extern void PanelTlv_WriteBlock0Headers(unsigned char *base);

void PanelTlv_ValidateBlock1(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 30; i++)
		PanelTlv_ValidateRecord(base, &PanelTlv_Block1_Layout[i]);
}

void PanelTlv_WriteBlock0Headers(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 46; i++)
		PanelTlv_WriteRecordHeader(base, &PanelTlv_Block0_Layout[i]);
}
