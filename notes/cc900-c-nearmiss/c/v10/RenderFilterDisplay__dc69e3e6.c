/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/composer_filters_m269.c (2026-11-16-87-p6-r15)
   sha256 dc69e3e64586ee4b0ec791f8ad23f32fc7cfffb5e11aa886f7002a3c0fff9776 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: rf_dash0=RenderFilterDisplay_Str_Dash_Dash_Dash_Dash
   cc900-name: rf_dash1=RenderFilter_Type1_Unavail_Str_Dash_Dash_Dash_Dash
   cc900-name: rf_dash2=RenderFilter_Type2_Restricted_Str_Dash_Dash_Dash_Dash
   cc900-name: rf_no1=RenderFilter_Type1_Restricted_Str_NO
   cc900-name: rf_no2=RenderFilter_Type2_Restricted_Str_NO
   cc900-name: rf_nog=RenderFilter_Generic_Restricted_Str_NO
   cc900-name: rf_yes1=RenderFilter_CheckType1_Str_YES
   cc900-name: rf_yes2=RenderFilter_CheckType2_Str_YES
   cc900-name: rf_yesg=RenderFilter_CheckGeneric_Str_YES */
extern char rf_dash0[], rf_yes1[], rf_no1[], rf_dash1[], rf_yesg[], rf_nog[], rf_yes2[], rf_no2[], rf_dash2[];
extern char GetCurrentFileType(void);
extern char FileIO_CheckRecordValid(int);
extern char FileIO_WriteRecordName_Done(int);
extern void FileIO_CopyString(char *, char *);
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
