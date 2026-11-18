/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_K_2m240a.c (2026-11-18-28-p6-r36)
   sha256 a02cf02c482c66dae625855923bd20e3545c9ebd3921394e0b529a74e5cae545 (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper K, round 2, module 240 (sequencer/smf_event_processor.s), form a: _findnext(s, out),
   adecl (XWA, XBC).  Device type 5 (cell 0x3e3e4) goes to FileIO_ReadNextDirEntry; otherwise 32-byte directory
   entries are read with FileRead and unpacked (SeqStep_FileSectorComplete) until one is neither deleted (0xe5) nor
   a volume label (attribute bit 3) and matches s's pattern; a 0 first byte ends the directory (-1).  The result:
   attribute +0, size +2, "NNNNNNNN.EEE" +6.  Frame: the file handle, the search record, then the raw entry below
   the unpacked one (address-taken arrays in reverse declaration order).  The loop's test is copied to the entry by
   hand (if + do/while) for -Xr. */
/* cc900-module: FileIO_MatchWildcard FileIO_ReadNextDirEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct fsearch { FileP fp; char *pat; };
struct ffout { unsigned char attr; char pad; long size; char name[13]; };

extern unsigned char ram_3e3e4;
extern int __cdecl FileRead(char *, int, int, FileP);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw);
extern int FileIO_MatchWildcard(char *name, char *pat);
extern int FileIO_ReadNextDirEntry(void *h, void *name);
extern int _findnext(struct fsearch *s, struct ffout *out);

int _findnext(struct fsearch *s, struct ffout *out)
{
	FileP fp;
	struct fsearch *sp;
	unsigned char ent[24];
	unsigned char raw[32];

	if (ram_3e3e4 == 5)
		return FileIO_ReadNextDirEntry(s, out);
	if (s == 0)
		return -1;
	sp = s;
	fp = s->fp;
	if (FileRead((char *)raw, 32, 1, fp) == 1) {
		do {
			SeqStep_FileSectorComplete(ent, raw);
			if (ent[0] == 0xe5)
				continue;
			if (ent[0] == 0)
				break;
			if (ent[12] & 8)
				continue;
			if (FileIO_MatchWildcard((char *)ent, sp->pat) != 1)
				continue;
			Mem_Copy(out->name, ent, 8);
			out->name[8] = '.';
			Mem_Copy(&out->name[9], &ent[8], 3);
			out->name[12] = 0;
			out->size = *(long *)&ent[19];
			out->attr = ent[12];
			return 0;
		} while (FileRead((char *)raw, 32, 1, fp) == 1);
	}
	return -1;
}
