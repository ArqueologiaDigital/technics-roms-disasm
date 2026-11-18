/* Phase 6, lane_p6 helper K, round 1, module 268, form b of p6_K_1m268a.c: TrimAndFormatFilename with the scan
   reading s[i] through p only (no char local), the trailing strip as a for loop and the leading-blank skip as a
   while loop; ControlState_ProcessCommand with the switch value read into a local first (the ROM loads cmd[1]
   before the two pointers). */
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

	s[len] = 0;
	for (i = 0; i < len; i++) {
		p = &s[i];
		if (*p < 0x20)
			*p = ' ';
		else if (*p == sep) {
			*p = 0;
			break;
		}
	}
	for (i--; i >= 0; i--) {
		p = &s[i];
		if (*p != ' ')
			break;
		*p = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		i = 0;
		while (buf[i] == ' ')
			i++;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}

void ControlState_ProcessCommand(unsigned char *cmd)
{
	unsigned char c;
	unsigned char *path;
	char *dir;

	ram_27416 = -1;
	ram_27414 = 0;
	if (cmd[0] != 2)
		return;
	c = cmd[1];
	dir = ram_272f2;
	path = &cmd[2];
	switch (c) {
	case 0:
		ram_272d2 = 0;
		*dir = 0;
		break;
	case 0x10:
		*dir = 0;
		path = &cmd[FileIO_FindPathSeparator(path) + 3];
		break;
	case 0x40:
	case 0x80:
		break;
	default:
		return;
	}
	FileIO_BuildFileIndex(path);
}
