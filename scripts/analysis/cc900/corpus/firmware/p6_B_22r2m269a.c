/* lane_p6 helper B, round 22r2, form a: module 269 (file_io/single_load.s), the two blank single-load list procs
   from roots23_B's pooled stretches at f8fafd and f90935 (area 4 = none): on EVT_PAINT each of the four 21-byte
   rows gets its index and an empty name, padded by TrimAndPadSmfFilename and drawn with EVT_PARA_DRAW.
   The ROM's `ldto_berp a, 248` is a move from IZ's low byte (the row index), which V4.23 writes itself.
   Form a: the rows as an array of 21-byte records {index, name[20]}, unsigned int index.
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrimAndPadSmfFilename */

#define EVT_PAINT     0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL

struct slrow { unsigned char index; unsigned char name[20]; };

extern struct slrow __near SINGLE_LOAD_SRC_ROWS[];
extern struct slrow __near SINGLE_LOAD_DST_ROWS[];

extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);

long SingleLoadSrc_BlankListProc(long obj, long evt, long param);
long SingleLoadDst_BlankListProc(long obj, long evt, long param);

long SingleLoadSrc_BlankListProc(long obj, long evt, long param)
{
	unsigned int i;
	if (evt == EVT_PAINT) {
		for (i = 0; i < 4; i++) {
			SINGLE_LOAD_SRC_ROWS[i].index = (unsigned char)i;
			SINGLE_LOAD_SRC_ROWS[i].name[0] = 0;
			TrimAndPadSmfFilename(SINGLE_LOAD_SRC_ROWS[i].name, 16);
			ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[i]);
		}
	}
	return 0;
}

long SingleLoadDst_BlankListProc(long obj, long evt, long param)
{
	unsigned int i;
	if (evt == EVT_PAINT) {
		for (i = 0; i < 4; i++) {
			SINGLE_LOAD_DST_ROWS[i].index = (unsigned char)i;
			SINGLE_LOAD_DST_ROWS[i].name[0] = 0;
			TrimAndPadSmfFilename(SINGLE_LOAD_DST_ROWS[i].name, 16);
			ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_DST_ROWS[i]);
		}
	}
	return 0;
}
