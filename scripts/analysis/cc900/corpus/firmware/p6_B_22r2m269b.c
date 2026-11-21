/* lane_p6 helper B, round 22r2, form b: module 269 (file_io/single_load.s), SingleLoadSrc_BlankListProc and
   SingleLoadDst_BlankListProc as in form a, but the rows as a plain byte array indexed i * 21 and i * 21 + 1 (as
   the matched SingleLoadSrc_DrawSoundMemItemName spells its row).
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */

#define EVT_PAINT     0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL

extern unsigned char __near SINGLE_LOAD_SRC_ROWS[];
extern unsigned char __near SINGLE_LOAD_DST_ROWS[];

extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);

long SingleLoadSrc_BlankListProc(long obj, long evt, long param);
long SingleLoadDst_BlankListProc(long obj, long evt, long param);

long SingleLoadSrc_BlankListProc(long obj, long evt, long param)
{
	unsigned int i;
	if (evt == EVT_PAINT) {
		for (i = 0; i < 4; i++) {
			SINGLE_LOAD_SRC_ROWS[i * 21] = (unsigned char)i;
			SINGLE_LOAD_SRC_ROWS[1 + i * 21] = 0;
			TrimAndPadSmfFilename(&SINGLE_LOAD_SRC_ROWS[1 + i * 21], 16);
			ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[i * 21]);
		}
	}
	return 0;
}

long SingleLoadDst_BlankListProc(long obj, long evt, long param)
{
	unsigned int i;
	if (evt == EVT_PAINT) {
		for (i = 0; i < 4; i++) {
			SINGLE_LOAD_DST_ROWS[i * 21] = (unsigned char)i;
			SINGLE_LOAD_DST_ROWS[1 + i * 21] = 0;
			TrimAndPadSmfFilename(&SINGLE_LOAD_DST_ROWS[1 + i * 21], 16);
			ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_DST_ROWS[i * 21]);
		}
	}
	return 0;
}
