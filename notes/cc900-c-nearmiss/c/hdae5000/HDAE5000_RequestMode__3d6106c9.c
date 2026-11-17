/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1a.c (2026-11-16-44-hd-r1)
   sha256 3d6106c93617b98bcac5898cac04887249bee17a21630bc45a65c43a896e7307 (tar-sha256); compiled at -Xr */
typedef void (*VFN)();
struct ObjTab { VFN *fns; char pad[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOTF(t, i) ((t (*)())HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns[i])
#define RF_DeleteEvent 333
#define RF_ApPostEvent 73
void HDAE5000_RequestMode(unsigned char mode)
{
    ROOTF(void, RF_DeleteEvent)(-1L, 0x01c00014L);
    ROOTF(void, RF_ApPostEvent)(-1L, 0x01c00014L, (long)mode + 0x01800000L);
}
