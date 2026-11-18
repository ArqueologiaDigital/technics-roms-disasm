/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_2m236a.c (2026-11-18-28-p6-r36)
   sha256 2526d749c68479eb85f25c5addb21605cd1ef0a2abd5192742d872c8253709ff (tar-sha256); compiled at -Xr */
typedef int __cdecl sfopfn();
struct sfops { long f0; sfopfn *read; sfopfn *gets; sfopfn *write; };
struct sfile { long f0; unsigned char mode; unsigned char pad[9]; struct sfops *ops; };
extern int FILE_ERROR;
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
