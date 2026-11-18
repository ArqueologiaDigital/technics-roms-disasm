/* Phase 6, lane_p6 helper K, round 3, module 268, form b: TrimAndFormatFilename with a second pointer local q for
   the trailing-blank loop (the ROM uses XWA there, XHL in the scan); ControlState_ProcessCommand switching on
   cmd[1] itself with the cases in the order 0x80 / 0x40, 0, 0x10 and the pointers set first. */
/* cc900-module: FileIO_BuildFileIndex FileIO_CopyString FileIO_FindPathSeparator */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern long ram_27416;
extern unsigned char ram_27414;
extern unsigned char ram_272d2;
extern char ram_272f2[];
extern int FileIO_FindPathSeparator(unsigned char *);
extern void FileIO_BuildFileIndex(unsigned char *);

int TrimAndFormatFilename(int len, unsigned char *s, unsigned char sep)
{
	unsigned char buf[128];
	int i;
	unsigned char *p;
	unsigned char c;
	unsigned char *q;

	s[len] = 0;
	for (i = 0; i < len; i++) {
		p = &s[i];
		c = *p;
		if (c < 0x20)
			*p = ' ';
		else if (c == sep) {
			*p = 0;
			break;
		}
	}
	while (--i >= 0) {
		q = &s[i];
		if (*q != ' ')
			break;
		*q = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		for (i = 0; buf[i] == ' '; i++)
			;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}

void ControlState_ProcessCommand(unsigned char *cmd)
{
	char *dir;
	unsigned char *path;

	ram_27416 = -1;
	ram_27414 = 0;
	if (cmd[0] != 2)
		return;
	dir = ram_272f2;
	path = &cmd[2];
	switch (cmd[1]) {
	case 0x80:
	case 0x40:
		break;
	case 0:
		ram_272d2 = 0;
		*dir = 0;
		break;
	case 0x10:
		*dir = 0;
		path = &cmd[FileIO_FindPathSeparator(path) + 3];
		break;
	default:
		return;
	}
	FileIO_BuildFileIndex(path);
}
