/* Phase 6, lane_p6 helper S, round 2 of 2026-11-20, hand source audio/sound_editor_ui.s (m152), form b: first
   probes of the two SeWrtSnd handlers helper M left (its Column1..6 / 8 and SideRow2 matched at run r57,
   p6_M_14m152a.c).
   - SeWrtSnd_OnColumn7: WA = 0x8000, or 0 when the dial byte without bit 7 is 0, then the tail jump into
     SeWrtSnd_SetupNamingPage_Join4 (the ROM loads 0x8000 before the compare and overwrites it with 0).
   - SeWrtSnd_OnSideRow1: a == 0 clears the name (SeWrtSnd_ClearName, relative); else, unless the object is 1,
     for each of the 16 name characters (counter in QIZH): read it (SeMenu_GetNameBufferChar), map it through
     FontGlyph_ByteData in place, and register it as field i (the ROM widens i to a long and passes its low byte:
     the address-of-a-byte idiom of the sound-editor tables, `(unsigned char)(unsigned long)((unsigned char *)0 +
     i)`) with SeMenu_RegisterElement_Extended(0, field, &ch, 127) in its byte-parameter prototype (only C is
     loaded); then SeMenu_CopyWriteUpdate_Step3_Helper14(0) and the TT_SEWRTMEM title.
   Form b: Column7's argument as a conditional expression; SideRow1 takes &ch once into a pointer local (the
   ROM computes it into XBC and copies it to XWA) and passes it twice.
*/
/* cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
/* cc900-module: SeWrtSnd_ClearName SeWrtSnd_SetupNamingPage_Join4 */

#define TT_SEWRTMEM 0x3e
extern void SeWrtSnd_SetupNamingPage_Join4(unsigned int w);
extern void SeWrtSnd_ClearName(void);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void FontGlyph_ByteData(unsigned char *s, unsigned char *d);
extern int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask);
extern void SeM_CWU_S3H14(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeWrtSnd_OnColumn7(unsigned char a);
extern void SeWrtSnd_OnSideRow1(unsigned char a);

void SeWrtSnd_OnColumn7(unsigned char a)
{
	SeWrtSnd_SetupNamingPage_Join4((a & 0x7f) != 0 ? 0x8000 : 0);
}

void SeWrtSnd_OnSideRow1(unsigned char a)
{
	unsigned char ch;
	unsigned char obj;
	unsigned char i;
	unsigned char *p;

	if (a == 0)
		SeWrtSnd_ClearName();
	else {
		SeMenu_LoadObjEntries(&obj);
		if (obj != 1) {
			for (i = 0; i < 16; i++) {
				SeMenu_GetNameBufferChar(i, &ch);
				p = &ch;
				FontGlyph_ByteData(p, p);
				SeMenu_RegisterElement_Extended(0, (unsigned char)(unsigned long)((unsigned char *)0 + i), &ch, 127);
			}
			SeM_CWU_S3H14(0);
			SeMenu_SendEvent(TT_SEWRTMEM, 0);
		}
	}
}
