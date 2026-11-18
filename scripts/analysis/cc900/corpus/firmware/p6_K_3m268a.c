/* Phase 6, lane_p6 helper K, round 3, module 268 (demo/file_demo_proc.s), form a: one-spot refinements of round 1
   (run 2026-11-18-12-p6-r35).
   TrimAndFormatFilename (+49 at -O3 -Xr): everything up to the trailing-blank loop matched; that loop addresses
   s[i] through XWA in the ROM where round 1's shared pointer p gave XHL, so the loop now writes s[i] directly.
   ControlState_ProcessCommand (+23): V4.23 put the 0x10 case's body after the switch's end, the ROM puts it between
   the 0 case and the end.  Here the empty 0x80 / 0x40 cases come first and 0x10 last, with the command byte read
   into a local before the two pointers (the ROM's load order). */
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
		if (s[i] != ' ')
			break;
		s[i] = 0;
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
	unsigned char c;
	char *dir;
	unsigned char *path;

	ram_27416 = -1;
	ram_27414 = 0;
	if (cmd[0] != 2)
		return;
	c = cmd[1];
	dir = ram_272f2;
	path = &cmd[2];
	switch (c) {
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
