/* Helper R, round 1 of 2026-11-20: modules 264-269, form b (integer arithmetic for the grid row, a plain subscript
   for the name table, the result through a local). */

struct grid { unsigned char b[12]; };

extern struct grid *ram_3ea30;
extern char *PtrTbl_VariationNames[];
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenDefault(char *);

struct grid *Util_SignExtendAndDouble(int i)
{
  return (struct grid *)((long)i * 12 + (long)ram_3ea30);
}

char *SingleLoad_GetVariationName(unsigned int i)
{
  return PtrTbl_VariationNames[i];
}

int GetFirstRecordAndOpen(void)
{
  int n;
  if ((n = GetFirstPageBase()) >= 0)
    return FileIO_OpenDefault(GetRecordPtrForFile(n));
  return -0x68;
}
