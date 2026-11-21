/* lane_p6 helper A, round 22r2, form a: module 269, two roots of pool roots23_A:
   DisplaySmfSequenceList (file_io/smf_operations.s): fills the ten 32-byte rows of the list buffer at 0x850c
   (index byte + header name read by FileIO_ReadHeader_ParseLoop) and posts PARA_DRAW for each;
   DocDiskNameFunc (file_io/medley.s): on PAINT copies the disk name without spaces (at most 30 characters) into
   0x878c, trims trailing spaces and posts PARA_DRAW to the box in `par`.
   Form a: flat __near byte arrays, int loop counters.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState */

#define EVT_PAINT      0x1c0000bL
#define EVT_PARA_DRAW  0x1c0000fL

extern unsigned char __near ram_850c[];
extern unsigned char __near ram_878c[];

extern void InitializeOperationState(int);
extern char *FileIO_GetWallpaperEntry(int);
extern void FileIO_ReadHeader_ParseLoop(char *, char *, int, int, int);
extern long ApPostEvent(long, long, long);
extern unsigned char *FileIO_SearchAndLoadFile(void);

void DisplaySmfSequenceList(long obj, int first)
{
	int i;

	InitializeOperationState(0);
	for (i = 0; i < 10; i++) {
		ram_850c[i * 32] = i;
		FileIO_ReadHeader_ParseLoop((char *)&ram_850c[i * 32 + 1], FileIO_GetWallpaperEntry(first + i),
			first + i + 1, 1, 12);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)&ram_850c[i * 32]);
	}
}

long DocDiskNameFunc(long obj, long evt, long par)
{
	unsigned char *s;
	int i;

	if (evt == EVT_PAINT) {
		s = FileIO_SearchAndLoadFile();
		for (i = 0; *s != 0 && i < 30; s++)
			if (*s != ' ')
				ram_878c[i++] = *s;
		ram_878c[i] = 0;
		while (ram_878c[--i] == ' ' && i > 0)
			ram_878c[i] = 0;
		ApPostEvent(par, EVT_PARA_DRAW, (long)ram_878c);
	}
	return 0;
}
