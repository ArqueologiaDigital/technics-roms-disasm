/* Functions of file_io/wallpaper.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_CopyResourcePtrs */   /* scripts/analysis/cc900/module_calls.py v10 */

extern char *PtrTbl_VariationNames[];
extern char *SingleLoad_GetVariationName(unsigned int i);

char *SingleLoad_GetVariationName(unsigned int i)
{
  return *(char **)((unsigned long)PtrTbl_VariationNames + ((unsigned long)i << 2));
}

/* cc900-module: TrimAndPadSmfFilename */
extern char *SingleLoad_MemoryBankNames[];
extern void FileIO_CopyString(char *, char *);
extern void TrimAndPadSmfFilename(char *, unsigned int);
extern void SingleLoad_GetComposerBankName(char *dst, unsigned int idx, unsigned int mark);
extern char *SingleLoad_SoundMemBankNames[];
extern void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark);

void SingleLoad_GetComposerBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_MemoryBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}
void SingleLoad_GetSoundMemBankName(char *dst, unsigned int idx, unsigned int mark)
{
	*dst++ = mark;
	FileIO_CopyString(dst, SingleLoad_SoundMemBankNames[idx]);
	TrimAndPadSmfFilename(dst, 16);
}

extern unsigned char ram_1ed350[];
extern void FileIO_CopyString_WriteNull(char *, char *, int);
extern void SingleLoad_GetFileBankName(char *dst, unsigned int idx, unsigned char mark);
extern unsigned char ram_1e4aa7[];
extern void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned int mark);

void SingleLoad_GetFileBankName(char *dst, unsigned int idx, unsigned char mark)
{
	char *src;

	src = (char *)ram_1ed350;
	src += (unsigned long)idx << 4;
	src += 16;
	*dst++ = mark;
	FileIO_CopyString_WriteNull(dst, src, 16);
	dst[16] = 0;
	TrimAndPadSmfFilename(dst, 16);
}
void SingleLoad_GetUserKitEntryName(char *dst, unsigned int idx, unsigned int mark)
{
	char *src;

	src = (char *)ram_1e4aa7;
	src += idx * 80;
	*dst++ = mark;
	*dst++ = ' ';
	FileIO_CopyString_WriteNull(dst, src, 13);
	dst[13] = 0;
	TrimAndPadSmfFilename(dst, 15);
}
