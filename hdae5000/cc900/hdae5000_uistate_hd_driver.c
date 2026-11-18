/* Functions of hdae5000_hd_driver.s.  (hdae5000_uistate.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_uistate.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: TypeSelInit_b=HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_TypeSel_Init
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct LbnBlock { unsigned int w[5]; };

extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern void HDAE5000_Set_Menu_Visibility(int hide);

extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct LbnBlock ram_22aa58;                 /* the load-by-number block */
extern struct LbnBlock HDAE5000_Lbn_BlockTemplate;
extern struct TypeSel HDAE5000_TypeSel_TemplateBlank;

void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, struct TypeSel *tmpl, int flag);

void TypeSelInit_b(struct TypeSel *rec, unsigned int mask, struct TypeSel *tmpl, unsigned char flag)
{
    *rec = *tmpl;
    rec->mask = mask;
    if (mask & 0x001)
        rec->flag[0] = flag;
    if (mask & 0x002)
        rec->flag[1] = flag;
    if (mask & 0x004)
        rec->flag[2] = flag;
    if (mask & 0x008)
        rec->flag[3] = flag;
    if (mask & 0x010)
        rec->flag[4] = flag;
    if (mask & 0x020)
        rec->flag[5] = flag;
    if (mask & 0x040)
        rec->flag[6] = flag;
    if (mask & 0x080)
        rec->flag[7] = flag;
    if (mask & 0x100)
        rec->flag[8] = flag;
}
