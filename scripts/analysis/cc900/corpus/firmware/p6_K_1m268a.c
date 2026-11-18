/* Phase 6, lane_p6 helper K, round 1, module 268 (demo/file_demo_proc.s), form a.
   TrimAndFormatFilename(len, s, sep): terminates s at len, turns control characters into blanks and cuts at the
   first sep, strips trailing blanks, then strips leading blanks through a 128-byte copy; returns 0.  The scan keeps
   the character in C and its address in XHL (a local p / c); the leading-blank skip reuses &buf[i] as the copy's
   source (CSE at -O3 expected).
   FileIO_FindNextMatch(name, size): _findnext on the open search handle (24-bit cell 0x27416); at the end of the
   directory clears both outputs, closes the search and marks the handle -1; otherwise copies the name and returns
   the file size (-1 for a directory, attribute bit 4).  The 266-byte find block: attribute byte, size at +2, name
   at +6.
   ControlState_ProcessCommand(cmd): resets the search state; for a type-2 command switches on cmd[1] (0x80 / 0x40:
   path as given; 0x10: directory part cut off by FileIO_FindPathSeparator; 0: both cells cleared; else nothing)
   and builds the file index.  Cases written first-to-last as 0, 0x10, 0x40, 0x80 (V4.23 compares the last case
   first). */
/* cc900-module: FileIO_BuildFileIndex FileIO_CopyString FileIO_FindPathSeparator */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern void FileIO_CopyString(char *, char *);
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
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
		p = &s[i];
		if (*p != ' ')
			break;
		*p = 0;
	}
	if (*s == ' ') {
		FileIO_CopyString((char *)buf, (char *)s);
		for (i = 0; buf[i] == ' '; i++)
			;
		FileIO_CopyString((char *)s, (char *)&buf[i]);
	}
	return 0;
}

int FileIO_FindNextMatch(char *name, long *size)
{
	struct ffblk fb;

	if (_findnext(ram_27416, &fb) != 0) {
		*name = 0;
		*size = 0;
		_findclose(ram_27416);
		ram_27416 = -1;
		return -1;
	}
	FileIO_CopyString(name, fb.name);
	if (fb.attr & 0x10)
		*size = -1;
	else
		*size = fb.size;
	return 0;
}

void ControlState_ProcessCommand(unsigned char *cmd)
{
	unsigned char *path;
	char *dir;

	ram_27416 = -1;
	ram_27414 = 0;
	if (cmd[0] != 2)
		return;
	dir = ram_272f2;
	path = &cmd[2];
	switch (cmd[1]) {
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
