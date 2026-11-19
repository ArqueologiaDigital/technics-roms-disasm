/* Functions of file_io/composer_filters.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern unsigned char FileIO_FormatName_Return(unsigned int);
extern unsigned char FileIO_GetRecordAttr_Check(void);
extern char Rsfd_Str_N1BANK[];
extern char Rsf_Avail_Str_YES[];
extern char RenderSaveFilter_Unavail_Str_NO[];
extern void RenderSaveFilterDisplay(char *p, unsigned char c);

/* cc900-name: Rsfd_Str_N1BANK=RenderSaveFilterDisplay_Str_N1BANK */
/* cc900-name: Rsf_Avail_Str_YES=RenderSaveFilter_Available_Str_YES */
void RenderSaveFilterDisplay(char *p, unsigned char c)
{
	*p++ = c;
	if (FileIO_FormatName_Return(c) != 0) {
		if (c == 1 && FileIO_GetRecordAttr_Check() != 0)
			FileIO_CopyString(p, Rsfd_Str_N1BANK);
		else
			FileIO_CopyString(p, Rsf_Avail_Str_YES);
	} else
		FileIO_CopyString(p, RenderSaveFilter_Unavail_Str_NO);
}
