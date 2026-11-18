/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_2m236b.c (2026-11-18-28-p6-r36)
   sha256 c1c75f2226a17fc1f183ef1fb08063fd3a8b66e704089e9e5948e8d99f713a91 (tar-sha256); compiled at -Xr */
struct sfops { long f0; int (__cdecl *read)(); int (__cdecl *gets)(); int (__cdecl *write)(); };
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
