/* lane_p6 helper A, round 22r2, form b: module 269, alternatives to form a.
   DisplaySmfSequenceList: the list buffer as ten 32-byte row structs (index byte + 31-byte name).
   DocDiskNameFunc: a pointer variable for the buffer (the ROM keeps its base in XDE for the trim loop and the
   post), copy loop as `while`, trim loop as `for (;;)` with the ROM's test order.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState */

#define EVT_PAINT      0x1c0000bL
#define EVT_PARA_DRAW  0x1c0000fL

struct seqrow { unsigned char index; char name[31]; };

extern struct seqrow __near ram_850c[];
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
		ram_850c[i].index = i;
		FileIO_ReadHeader_ParseLoop(ram_850c[i].name, FileIO_GetWallpaperEntry(first + i), first + i + 1, 1, 12);
		ApPostEvent(obj, EVT_PARA_DRAW, (long)&ram_850c[i]);
	}
}

long DocDiskNameFunc(long obj, long evt, long par)
{
	unsigned char *s;
	unsigned char *d;
	int i;

	if (evt != EVT_PAINT)
		return 0;
	s = FileIO_SearchAndLoadFile();
	i = 0;
	while (d = ram_878c, *s != 0 && i < 30) {
		if (*s != ' ')
			d[i++] = *s;
		s++;
	}
	d[i] = 0;
	for (;;) {
		i--;
		if (d[i] != ' ')
			break;
		if (i <= 0)
			break;
		d[i] = 0;
	}
	ApPostEvent(par, EVT_PARA_DRAW, (long)d);
	return 0;
}
