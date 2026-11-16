/* lane_hd round 13, helper h_near2, form a: HDAE5000_PartList_Build alone (no calr), from hd_r9_b1b.c (the mask
   copied to a local, which gave the ROM's IZ and matched up to +342 in run 2026-11-16-60).  Options: -Xr.
   The one difference left: the first ApPostEvent's text argument, ROM `lda xwa,(PartListText); ld xbc,xwa;
   ld xwa,(xsp+2); ld xde,xbc` (evaluated first, parked), V4.23 `lda xde,(PartListText)` after obj.  Written through
   the offset-0 member, WRAP(x), the spelling that gave FdList_Clear (hd_r9_b2.c, run 64 MATCH) that shape. */
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

void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask)
{
    unsigned int m;

    m = mask;
    if (dir == 0xffff || song == 0xffff) {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
    } else {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_Text, 0x7f);
        if (m != 0xffff) {
            if (!(m & 0x001)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[0], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x002)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[14], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x004)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[28], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x008)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[42], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x010)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[56], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x020)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[70], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x040)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[84], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x080)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[98], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x100)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[112], HDAE5000_PartName_Blank, 14);
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
        }
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PartListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}
