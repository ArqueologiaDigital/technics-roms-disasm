/* helper X, round 21r2: SingleLoadSrc_DrawSoundMemItemName (file_io/single_load.s, module 269), modelled on its
   promoted sibling SingleLoadSrc_DrawUserKitName (cc900/single_load_m269_d.c).  Form e: the USER KIT entry index
   passed as (unsigned char)(pos - 2C), widened by the unsigned int parameter (the ROM's sub a,e; extz wa). */
/* cc900-module: TrimAndPadSmfFilename */

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near SLOAD_SRC_SOUND_POS;
extern char __near SINGLE_LOAD_SRC_ROWS[];
extern char *SingleLoadSrc_ReadTmUserKitEntryName(unsigned int);
extern char *SingleLoadSrc_ReadTmSoundName(unsigned int);
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(unsigned char *, unsigned int);
extern long ApPostEvent(long, long, long);

void SingleLoadSrc_DrawSoundMemItemName(long obj, unsigned char n)
{
	char *p;
	unsigned char l;

	if (SINGLE_LOAD_ALL != 0)
		return;
	SINGLE_LOAD_SRC_ROWS[63] = 3;
	l = n + n;
	p = &SINGLE_LOAD_SRC_ROWS[64];
	if (SLOAD_SRC_SOUND_POS >= l)
		FileIO_CopyString(p, SingleLoadSrc_ReadTmUserKitEntryName((unsigned char)(SLOAD_SRC_SOUND_POS - l)));
	else
		FileIO_CopyString(p, SingleLoadSrc_ReadTmSoundName(SLOAD_SRC_SOUND_POS));
	TrimAndPadSmfFilename((unsigned char *)&SINGLE_LOAD_SRC_ROWS[64], 16);
	ApPostEvent(obj, EVT_PARA_DRAW, (long)&SINGLE_LOAD_SRC_ROWS[63]);
}
