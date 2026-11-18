/* Phase 6, lane_p6 helper K, round 3, module 268, form c: ControlState_ProcessCommand only, round 1's case order
   (0, 0x10, 0x40 / 0x80) with the command byte in a local and the 0x10 case falling into the call instead of
   breaking (the ROM's 0x10 body runs straight into FileIO_BuildFileIndex; the 0 case jumps there). */
/* cc900-module: FileIO_BuildFileIndex FileIO_FindPathSeparator */   /* scripts/analysis/cc900/module_calls.py v10 */

extern long ram_27416;
extern unsigned char ram_27414;
extern unsigned char ram_272d2;
extern char ram_272f2[];
extern int FileIO_FindPathSeparator(unsigned char *);
extern void FileIO_BuildFileIndex(unsigned char *);

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
	case 0:
		ram_272d2 = 0;
		*dir = 0;
		goto build;
	case 0x10:
		*dir = 0;
		path = &cmd[FileIO_FindPathSeparator(path) + 3];
	case 0x40:
	case 0x80:
	build:
		FileIO_BuildFileIndex(path);
	}
}
