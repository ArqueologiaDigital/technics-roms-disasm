/* Functions of factory_test/test_init.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDTest_PrintDiag */   /* scripts/analysis/cc900/module_calls.py v10 */

struct lsrec { long l; int w; char name[260]; };
extern char ListDir2_Entry_Str_A_HAMA_LSW[];
extern long _findfirst(char *, struct lsrec *);
extern int _findnext(long, long);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
extern int ListDir2_Entry(void);

int ListDir2_Entry(void)
{
	struct lsrec d;
	long h;

	h = _findfirst((char *)(long)ListDir2_Entry_Str_A_HAMA_LSW, &d);
	if (h == -1)
		return -1;
	FDTest_PrintDiag(d.name);
	while (_findnext(h, d.l) != -1)
		FDTest_PrintDiag(d.name);
	_findclose(h);
	return 0;
}
