/* FORM B of p6_I_2m236a.c: the operation pointers declared `int (__cdecl *read)()`.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 2, module 236 (sequencer/smf_event_processor.s), form a.  New.
   The stream library's character and line calls, all __cdecl (arguments on the stack), each checking the stream
   (NULL or mode 0: FILE_ERROR = 17; wrong direction bit of the mode at +4: FILE_ERROR = 13) and then calling the
   stream's operations table (pointer at +14: +4 read, +8 gets, +12 write) with (stream, buffer, count):
   - SeqStep_FileReadReturn(f): fgetc, one byte into a frame byte; -1 when nothing was read.
   - SeqStep_FileWriteSetup(c, f): fputc, c stored into a frame byte and written; returns the byte or -1.
   - SeqStep_ByteBlockF002(s, f): fputs, the length counted inline (`while (*p++ != 0) n++`, test copied to the
     entry); returns the write's result, -1 for 0 (ret nz).
   - SeqStep_ByteBlockEF56(buf, n, f): fgets through ops+8 with n - 1, terminates buf at the count; buf or NULL.
   The ROM pops fgetc's / fputc's call arguments with `add xsp,10` where fputs / fgets use lda: noted, not spelled.
   The operations are stack-argument (cdecl) functions: here their type is a __cdecl function typedef, the placement
   V4.23 accepts in declarations; form b writes `int (__cdecl *read)()` instead (unknown syntax, its own file). */

struct sfops { long f0; int (__cdecl *read)(); int (__cdecl *gets)(); int (__cdecl *write)(); };
struct sfile { long f0; unsigned char mode; unsigned char pad[9]; struct sfops *ops; };

extern int FILE_ERROR;
extern int __cdecl SeqStep_FileReadReturn(struct sfile *f);
extern int __cdecl SeqStep_FileWriteSetup(int c, struct sfile *f);
extern int __cdecl SeqStep_ByteBlockF002(char *s, struct sfile *f);
extern char *__cdecl SeqStep_ByteBlockEF56(char *buf, int n, struct sfile *f);

int __cdecl SeqStep_FileReadReturn(struct sfile *f)
{
    unsigned char ch;

    if (f == 0 || f->mode == 0) {
        FILE_ERROR = 17;
        return -1;
    }
    if (!(f->mode & 1)) {
        FILE_ERROR = 13;
        return -1;
    }
    if ((*f->ops->read)(f, &ch, 1) == 0)
        return -1;
    return ch;
}

int __cdecl SeqStep_FileWriteSetup(int c, struct sfile *f)
{
    unsigned char ch;

    if (f == 0 || f->mode == 0) {
        FILE_ERROR = 17;
        return -1;
    }
    if (!(f->mode & 2)) {
        FILE_ERROR = 13;
        return -1;
    }
    ch = c;
    if ((*f->ops->write)(f, &ch, 1) == 0)
        return -1;
    return ch;
}

int __cdecl SeqStep_ByteBlockF002(char *s, struct sfile *f)
{
    int n;
    char *p;

    if (f == 0 || f->mode == 0) {
        FILE_ERROR = 17;
        return -1;
    }
    if (!(f->mode & 2)) {
        FILE_ERROR = 13;
        return -1;
    }
    n = 0;
    p = s;
    while (*p++ != 0)
        n++;
    if ((n = (*f->ops->write)(f, s, n)) != 0)
        return n;
    return -1;
}

char *__cdecl SeqStep_ByteBlockEF56(char *buf, int n, struct sfile *f)
{
    int r;

    if (f == 0 || f->mode == 0) {
        FILE_ERROR = 17;
        return 0;
    }
    if (!(f->mode & 1)) {
        FILE_ERROR = 13;
        return 0;
    }
    r = (*f->ops->gets)(f, buf, n - 1);
    buf[r] = 0;
    if (r != 0)
        return buf;
    return 0;
}
