/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v);

unsigned char FDemoText_ByteData_ProbeHelper(unsigned char v)
{
	unsigned char rec[6];
	unsigned char *t;
	unsigned char *p;

	t = FDemoText_LookupTableEntry(v);
	p = rec;
	p[3] = *t++;
	p[4] = *t;
	p[2] = v;
	SndParam_FetchOscTableEntry(p);
	return rec[1];
}
