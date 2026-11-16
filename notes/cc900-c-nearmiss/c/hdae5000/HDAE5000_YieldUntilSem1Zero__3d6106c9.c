/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1a.c (2026-11-16-44-hd-r1)
   sha256 3d6106c93617b98bcac5898cac04887249bee17a21630bc45a65c43a896e7307 (tar-sha256); compiled at -O3 -Xr */
typedef void (*VFN)();
struct ObjTab { VFN *fns; char pad[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define HAMAF(t, i) ((t (*)())HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns[i])
#define HF_rot_rdq 46
#define HF_ref_sem 52
void HDAE5000_YieldUntilSem1Zero(void)
{
    while (HAMAF(int, HF_ref_sem)(1) != 0)
        HAMAF(void, HF_rot_rdq)(3);
}
