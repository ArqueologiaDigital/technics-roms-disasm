/* Phase 6, lane_p6 helper G, round 14, module 5 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   Detect_Disk_Type (boot/system_handlers.s), new.  Reads sector 0x21 of the floppy into a 512-byte Malloc'd buffer
   and compares its first 0x26 bytes with the eight file-type signatures in turn (String_Compare, cdecl); the first
   that matches gives the type 1..8, none gives 0xff.  Frees the buffer and returns the type (in L).  Read from the
   hand assembly: the buffer in XIZ, the type a byte in the frame (xsp+4, set to 0xff first), every match jumping to
   the shared Free.  The signatures are passed as far pointers (two word pushes), the buffer as a long. */
/* cc900-module: FDC_ReadSectors */

extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern int __cdecl String_Compare(void *, void *, int);
extern void FDC_ReadSectors(long, int, void *);

extern char FILETYPE_SIG_PROGRAM_1[], FILETYPE_SIG_PROGRAM_2[], FILETYPE_SIG_TABLE_1[], FILETYPE_SIG_TABLE_2[];
extern char FILETYPE_SIG_CMPCUSTOM[], FILETYPE_SIG_HDAE_PRG[], FILETYPE_SIG_PROGRAM_PCK[], FILETYPE_SIG_TABLE_PCK[];

unsigned char Detect_Disk_Type(void)
{
	unsigned char t;
	unsigned char *buf;

	t = 0xff;
	buf = Malloc(0x200);
	FDC_ReadSectors(0x21, 1, buf);
	if (String_Compare(buf, FILETYPE_SIG_PROGRAM_1, 0x26) == 0) t = 1;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_2, 0x26) == 0) t = 2;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_1, 0x26) == 0) t = 3;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_2, 0x26) == 0) t = 4;
	else if (String_Compare(buf, FILETYPE_SIG_CMPCUSTOM, 0x26) == 0) t = 5;
	else if (String_Compare(buf, FILETYPE_SIG_HDAE_PRG, 0x26) == 0) t = 6;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_PCK, 0x26) == 0) t = 7;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_PCK, 0x26) == 0) t = 8;
	Free(buf);
	return t;
}
