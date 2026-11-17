/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1b.c (2026-11-16-44-hd-r1)
   sha256 f0ffe5f8f88030190806f17337dda0ecbdcfedf242b4b2ef171faac50dbb205b (tar-sha256); compiled at -Xr */
typedef void (*VFN)();
struct ObjTab { VFN *fns; char pad[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOTF(t, i) ((t (*)())HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns[i])
#define RF_DeleteEvent 333
#define RF_ApPostEvent 73
void HDAE5000_RequestTitle15(unsigned char title)
{
    ROOTF(void, RF_DeleteEvent)(0xffffffffUL, 0x01c00015UL);
    ROOTF(void, RF_ApPostEvent)(0xffffffffUL, 0x01c00015UL, 0x01a00000UL + title);
}
