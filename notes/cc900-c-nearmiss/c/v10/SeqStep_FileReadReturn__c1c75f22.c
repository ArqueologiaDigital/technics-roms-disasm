/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_2m236b.c (2026-11-18-28-p6-r36)
   sha256 c1c75f2226a17fc1f183ef1fb08063fd3a8b66e704089e9e5948e8d99f713a91 (tar-sha256); compiled at -Xr */
struct sfops { long f0; int (__cdecl *read)(); int (__cdecl *gets)(); int (__cdecl *write)(); };
struct sfile { long f0; unsigned char mode; unsigned char pad[9]; struct sfops *ops; };
extern int FILE_ERROR;
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
