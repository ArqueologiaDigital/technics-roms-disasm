/* Phase 6, lane_p6 helper J, round 1, module 268, form a: FileIO_OpenWithBuiltPath (demo/file_demo_proc.s).
   Open a file by name under the path prefix held at 0x272d2 / 0x272f2 (both loaded as immediates, `ld xbc,N`).
   The frame: a 140-byte path buffer at xsp+4, mode spilled above it. */
/* cc900-module: FileIO_BuildFilePath FileIO_CopyString */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern int FileIO_OpenWithMode(char *, char *);

int FileIO_OpenWithBuiltPath(char *name, char *mode)
{
	char path[140];

	FileIO_CopyString(path, (char *)0x272d2);
	FileIO_BuildFilePath(path, (char *)0x272f2);
	FileIO_BuildFilePath(path, name);
	return FileIO_OpenWithMode(path, mode);
}
