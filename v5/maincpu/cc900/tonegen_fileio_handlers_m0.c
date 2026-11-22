/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char HELP_LANGUAGE;
extern unsigned char ram_340e6[], ram_340f2[], ram_340f6[], ram_340fa[];

void SndParamBank_LoadOptionBlock(void)
{
	Mem_Copy(&HELP_LANGUAGE, (void *)0x3d3400L, 2);
	Mem_Copy(ram_340e6, (void *)0x3d3410L, 12);
	Mem_Copy(ram_340f2, (void *)0x3d3420L, 4);
	Mem_Copy(ram_340f6, (void *)0x3d3430L, 4);
	Mem_Copy(ram_340fa, (void *)0x3d3440L, 6);
}

/* cc900-module: PanelTlv_ValidateRecord PanelTlv_WriteRecordHeader */
struct tlvrec { unsigned long off; unsigned char *rules; unsigned char tag; unsigned char len; };
extern struct tlvrec PanelTlv_Block1_Layout[];
extern void PanelTlv_WriteRecordHeader(unsigned char *base, struct tlvrec *l);
extern void PanelTlv_WriteBlock1Headers(unsigned char *base);

void PanelTlv_WriteBlock1Headers(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 30; i++)
		PanelTlv_WriteRecordHeader(base, &PanelTlv_Block1_Layout[i]);
}
