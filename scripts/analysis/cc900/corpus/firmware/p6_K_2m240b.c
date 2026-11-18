/* Phase 6, lane_p6 helper K, round 2, module 240, form b of p6_K_2m240a.c: _findnext with a plain while loop (the
   copied test is V4.23's own at -O3 -Xr) and the search record used as the parameter itself (form a copies it into
   a local, for the frame slot the ROM stores it in after the null test). */
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
	unsigned char ent[24];
	unsigned char raw[32];

	if (ram_3e3e4 == 5)
		return FileIO_ReadNextDirEntry(s, out);
	if (s == 0)
		return -1;
	fp = s->fp;
	while (FileRead((char *)raw, 32, 1, fp) == 1) {
		SeqStep_FileSectorComplete(ent, raw);
		if (ent[0] == 0xe5)
			continue;
		if (ent[0] == 0)
			break;
		if (ent[12] & 8)
			continue;
		if (FileIO_MatchWildcard((char *)ent, s->pat) != 1)
			continue;
		Mem_Copy(out->name, ent, 8);
		out->name[8] = '.';
		Mem_Copy(&out->name[9], &ent[8], 3);
		out->name[12] = 0;
		out->size = *(long *)&ent[19];
		out->attr = ent[12];
		return 0;
	}
	return -1;
}
