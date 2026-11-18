/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_2m236a.c (2026-11-18-28-p6-r36)
   sha256 2526d749c68479eb85f25c5addb21605cd1ef0a2abd5192742d872c8253709ff (tar-sha256); compiled at -Xr */
typedef int __cdecl sfopfn();
struct sfops { long f0; sfopfn *read; sfopfn *gets; sfopfn *write; };
struct sfile { long f0; unsigned char mode; unsigned char pad[9]; struct sfops *ops; };
extern int FILE_ERROR;
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
