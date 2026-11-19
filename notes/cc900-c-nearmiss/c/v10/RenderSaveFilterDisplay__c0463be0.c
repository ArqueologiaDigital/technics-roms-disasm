/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m269a.c (2026-11-19-56-p6-r51)
   sha256 c0463be020c0ea54b2c7bbbee3840cdb39dda9416a3f7e5e112bdf0940295508 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: Rsf_Avail_Str_YES=RenderSaveFilter_Available_Str_YES
   cc900-name: Rsfd_Str_N1BANK=RenderSaveFilterDisplay_Str_N1BANK */
extern void FileIO_CopyString(char *, char *);
extern unsigned char FileIO_FormatName_Return(unsigned int);
extern unsigned char FileIO_GetRecordAttr_Check(void);
extern char Rsfd_Str_N1BANK[];
extern char Rsf_Avail_Str_YES[];
extern char RenderSaveFilter_Unavail_Str_NO[];
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
