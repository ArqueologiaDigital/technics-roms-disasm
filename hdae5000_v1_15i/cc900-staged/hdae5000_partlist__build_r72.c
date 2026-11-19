/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-60-hd-r72-v1parts (hd_r72p_partlist__build.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r72p_partlist__build.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char HDAE5000_RAM_PartListText[];
extern char HDAE5000_PartNames_Text[];
extern char HDAE5000_PartNames_BlankText[];
extern char HDAE5000_PartName_Blank[];

/* an array read as an lvalue member at offset 0 (hd_r9_b2.c FdList_Clear: `lda xwa,(sym); ld xde,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

/* v1.15i: eight 14-character part names, so the list text is 8 * 14 + 1 = 0x71 bytes and there is no bit 0x100 */
void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask)
{
    unsigned int m;

    m = mask;
    if (dir == 0xffff || song == 0xffff) {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x71);
    } else {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_Text, 0x71);
        if (m != 0xffff) {
            if (!(m & 0x001)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[0], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x002)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[14], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x004)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[28], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x008)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[42], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x010)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[56], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x020)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[70], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x040)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[84], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x080)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[98], HDAE5000_PartName_Blank, 14);
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x71);
        }
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PartListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}
