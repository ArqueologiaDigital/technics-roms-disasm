/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m152a.c (2026-11-21-5-p6-r60)
   sha256 e8ba54658bc61a7bf4a80736b1579a3dd2be3748755cb1960eb3843e924d9cd0 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
#define TT_SEWRTMEM 0x3e
extern void SeWrtSnd_ClearName(void);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void FontGlyph_ByteData(unsigned char *s, unsigned char *d);
extern int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask);
extern void SeM_CWU_S3H14(int);
extern void SeMenu_SendEvent(int title, int refresh);
void SeWrtSnd_OnSideRow1(unsigned char a)
{
	unsigned char ch;
	unsigned char obj;
	unsigned char i;

	if (a == 0)
		SeWrtSnd_ClearName();
	else {
		SeMenu_LoadObjEntries(&obj);
		if (obj != 1) {
			for (i = 0; i < 16; i++) {
				SeMenu_GetNameBufferChar(i, &ch);
				FontGlyph_ByteData(&ch, &ch);
				SeMenu_RegisterElement_Extended(0, (unsigned char)(unsigned long)((unsigned char *)0 + i), &ch, 127);
			}
			SeM_CWU_S3H14(0);
			SeMenu_SendEvent(TT_SEWRTMEM, 0);
		}
	}
}
