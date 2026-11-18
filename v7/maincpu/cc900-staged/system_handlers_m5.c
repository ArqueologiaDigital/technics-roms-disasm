/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDC_ReadSectors */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern int __cdecl String_Compare(void *, void *, int);
extern void FDC_ReadSectors(long, int, void *);
extern char FILETYPE_SIG_PROGRAM_1[], FILETYPE_SIG_PROGRAM_2[], FILETYPE_SIG_TABLE_1[], FILETYPE_SIG_TABLE_2[];
extern char FILETYPE_SIG_CMPCUSTOM[], FILETYPE_SIG_HDAE_PRG[], FILETYPE_SIG_PROGRAM_PCK[], FILETYPE_SIG_TABLE_PCK[];
extern unsigned char Detect_Disk_Type(void);

unsigned char Detect_Disk_Type(void)
{
	unsigned char t;
	unsigned char *buf;

	t = 0xff;
	buf = Malloc(0x200);
	FDC_ReadSectors(0x21, 1, buf);
	if (String_Compare(buf, FILETYPE_SIG_PROGRAM_1, 0x26) == 0) t = 1;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_2, 0x26) == 0) t = 2;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_1, 0x26) == 0) t = 3;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_2, 0x26) == 0) t = 4;
	else if (String_Compare(buf, FILETYPE_SIG_CMPCUSTOM, 0x26) == 0) t = 5;
	else if (String_Compare(buf, FILETYPE_SIG_HDAE_PRG, 0x26) == 0) t = 6;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_PCK, 0x26) == 0) t = 7;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_PCK, 0x26) == 0) t = 8;
	Free(buf);
	return t;
}
