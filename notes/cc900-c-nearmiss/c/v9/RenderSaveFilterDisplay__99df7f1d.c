/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/composer_filters_m269.c (2026-11-19-73-p6-r53)
   sha256 99df7f1d11ea499bdf716069a4a86b4908a662718a114374e6341378f5f11257 (tar-sha256); compiled at -Xr
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
