/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_K_3m240a.c (2026-11-18-28-p6-r36)
   sha256 f6f86cefb7974bf954bc70be667e44c3b7ab5c525d3bbc607945fb4bd02b945e (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper K, round 3, module 240 (sequencer/smf_event_processor.s; the module's matched C is -Xr),
   form a: _findfirst(path, out), adecl.  Device type 5 (cell 0x3e3e4) goes to FindFirst_SndTable.  Otherwise:
   an 8-byte search record and a 0x104-byte path buffer (Malloc), FileIO_ParsePathComponents splits the path (the
   pattern pointer comes back through &pat), the directory is opened with mode "d", the path buffer is replaced by
   a copy of the pattern, and _findnext runs once (on failure _findclose); the record, or -1 on any failure, every
   allocation freed.  Frame: the directory handle and the record (plain) below the address-taken pattern pointer;
   the record's allocation is tested on the assigned value, the handle's after a reload (two spellings). */
/* cc900-module: FileIO_ParsePathComponents FindFirst_SndTable _findclose _findnext */   /* scripts/analysis/cc900/module_calls.py v10 */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct fsearch { FileP fp; char *pat; };
struct ffout;

extern unsigned char ram_3e3e4;
extern char FindFirst_OpenDir_Str_d[];
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern int __cdecl Strlen(char *);
extern char *__cdecl Strcpy(char *, char *);
extern FileP __cdecl FileOpen(char *, char *);
extern void *FindFirst_SndTable(void *unused, void *name);
extern int FileIO_ParsePathComponents(char *buf, char **pat);
extern int _findnext(struct fsearch *s, struct ffout *out);
extern int _findclose(struct fsearch *s);

void *_findfirst(char *path, struct ffout *out)
{
	FileP fp;
	struct fsearch *h;
	char *pat;
	char *buf;

	if (ram_3e3e4 == 5)
		return FindFirst_SndTable(path, out);
	if ((h = (struct fsearch *)Malloc(8)) == 0)
		return (void *)0xffffffffUL;
	if ((buf = (char *)Malloc(0x104)) == 0) {
		Free(h);
		return (void *)0xffffffffUL;
	}
	pat = path;
	if (FileIO_ParsePathComponents(buf, &pat) != 0) {
		Free(h);
		Free(buf);
		return (void *)0xffffffffUL;
	}
	fp = FileOpen(buf, FindFirst_OpenDir_Str_d);
	if (fp == 0) {
		Free(h);
		Free(buf);
		return (void *)0xffffffffUL;
	}
	Free(buf);
	if ((buf = (char *)Malloc(Strlen(pat) + 1)) == 0) {
		Free(h);
		return (void *)0xffffffffUL;
	}
	Strcpy(buf, pat);
	h->pat = buf;
	h->fp = fp;
	if (_findnext(h, out) != 0) {
		_findclose(h);
		return (void *)0xffffffffUL;
	}
	return h;
}
