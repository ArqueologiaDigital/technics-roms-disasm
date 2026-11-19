/* lane_p6 helper N, round 7, form a: module 269, new functions.
   - SingleLoadSrc_DrawUserKitName (file_io/single_load.s): sibling of the built
     SingleLoadSrc_PanelMemDrawMemoryNumber (cc900/single_load_m269.c): row n of the single-load source list gets
     the tone-memory user kit's name (flag byte 21 = 1, 16 characters padded at 22) and a PARA_DRAW event.
   - RenderSaveFilterDisplay (file_io/composer_filters.s): writes the filter's mark, then "NO" when the format is
     unavailable, "1BANK" for filter 1 when the record attribute says so, else "YES" (one shared copy call).
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */
/* cc900-name: Rsfd_Str_N1BANK=RenderSaveFilterDisplay_Str_N1BANK */
/* cc900-name: Rsf_Avail_Str_YES=RenderSaveFilter_Available_Str_YES */

#define EVT_PARA_DRAW 0x1c0000fL
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char *SingleLoadSrc_ReadTmUserKitName(void);
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);

void SingleLoadSrc_DrawUserKitName(long obj, unsigned char n)
{
	char *p;

	if (SLOAD_SRC_SOUND_POS < (unsigned char)(n + n))
		return;
	SINGLE_LOAD_SRC_ROWS[21] = 1;
	p = &SINGLE_LOAD_SRC_ROWS[22];
	FileIO_CopyString(p, SingleLoadSrc_ReadTmUserKitName());
	TrimAndPadSmfFilename((unsigned char *)&SINGLE_LOAD_SRC_ROWS[22], 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[21]);
}

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
