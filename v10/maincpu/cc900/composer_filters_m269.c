/* Functions of file_io/composer_filters.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern char rf_dash0[], rf_yes1[], rf_no1[], rf_dash1[], rf_yesg[], rf_nog[], rf_yes2[], rf_no2[], rf_dash2[];
extern char GetCurrentFileType(void);
extern char FileIO_CheckRecordValid(int);
extern char FileIO_WriteRecordName_Done(int);
extern void FileIO_CopyString(char *, char *);
extern void RenderFilterDisplay(char *buf, unsigned char type);

/* cc900-name: rf_dash0=RenderFilterDisplay_Str_Dash_Dash_Dash_Dash */
/* cc900-name: rf_yes1=RenderFilter_CheckType1_Str_YES */
/* cc900-name: rf_no1=RenderFilter_Type1_Restricted_Str_NO */
/* cc900-name: rf_dash1=RenderFilter_Type1_Unavail_Str_Dash_Dash_Dash_Dash */
/* cc900-name: rf_yesg=RenderFilter_CheckGeneric_Str_YES */
/* cc900-name: rf_nog=RenderFilter_Generic_Restricted_Str_NO */
/* cc900-name: rf_yes2=RenderFilter_CheckType2_Str_YES */
/* cc900-name: rf_no2=RenderFilter_Type2_Restricted_Str_NO */
/* cc900-name: rf_dash2=RenderFilter_Type2_Restricted_Str_Dash_Dash_Dash_Dash */
void RenderFilterDisplay(char *buf, unsigned char type)
{
	*buf++ = type;
	if (type == 0 && GetCurrentFileType() != 0)
		FileIO_CopyString(buf, rf_dash0);
	else if (type == 1 && GetCurrentFileType() != 0) {
		if (FileIO_CheckRecordValid(0) != 0) {
			if (FileIO_WriteRecordName_Done(0) != 0) FileIO_CopyString(buf, rf_yes1);
			else FileIO_CopyString(buf, rf_no1);
		} else
			FileIO_CopyString(buf, rf_dash1);
	} else if (FileIO_CheckRecordValid(type) != 0) {
		if (FileIO_WriteRecordName_Done(type) != 0) FileIO_CopyString(buf, rf_yesg);
		else FileIO_CopyString(buf, rf_nog);
	} else if (type == 2 && FileIO_CheckRecordValid(8) != 0 && FileIO_CheckRecordValid(9) != 0) {
		if (FileIO_WriteRecordName_Done(type) != 0) FileIO_CopyString(buf, rf_yes2);
		else FileIO_CopyString(buf, rf_no2);
	} else
		FileIO_CopyString(buf, rf_dash2);
}

/* cc900-module: TrimAndPadSmfFilename */
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
