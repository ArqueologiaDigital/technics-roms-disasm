/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_CheckRegionSignature FileIO_ReadHeaderAt4 FileIO_ReadHeaderAtF */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_CheckRegionSignature(int r);
extern void FileIO_CloseHandle(void);
extern int FileIO_LoadRcmToFlash(void);
extern char FileIO_LoadRegion6_Simple_Str_rb[];
extern int FileIO_LoadRegion6_Simple(char *src);
extern void FileIO_ReadBlock(void *, long);
extern void PreMidiLoad(void);
extern void PostMidiLoad(int);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern char FileIO_LoadRegion7_Flash_Str_rb[];
extern int FileIO_LoadRegion7_Flash(char *src);

int FileIO_LoadRegion6_Simple(char *src)
{
	char hd[14];
	int r;

	FileIO_ReadHeader(hd, src, 6);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion6_Simple_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(6) != 0)
		r = FileIO_LoadRcmToFlash();
	else
		r = -102;
	FileIO_CloseHandle();
	return r;
}

int FileIO_LoadRegion7_Flash(char *src)
{
	char hd[14];
	unsigned char *buf;
	int r;

	FileIO_ReadHeader(hd, src, 7);
	if (FileIO_OpenWithMode(hd, FileIO_LoadRegion7_Flash_Str_rb) < 0)
		return FileIO_ReturnError();
	if (FileIO_CheckRegionSignature(7) != 0) {
		PreMidiLoad();
		if ((buf = (unsigned char *)Malloc(0x400)) != 0) {
			Memset(buf, 0x400, 0);
			FileIO_ReadBlock(buf, 0x400);
			FlashWrite(1, buf, 0x400, 0x3d3000);
			Free(buf);
			r = FileIO_ReturnError();
		} else
			r = -200;
		PostMidiLoad(r);
	} else
		r = -102;
	FileIO_CloseHandle();
	return r;
}
