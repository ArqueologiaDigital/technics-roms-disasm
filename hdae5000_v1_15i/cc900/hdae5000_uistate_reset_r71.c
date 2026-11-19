/* Functions of hd-ae5000_v1_15i.s.  (hdae5000_uistate_reset_r71.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_uistate_reset_r71.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
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
extern struct LbnBlock ram_22aa10;                 /* the load-by-number block */
extern struct LbnBlock HDAE5000_Lbn_BlockTemplate;
extern struct TypeSel HDAE5000_TypeSel_TemplateBlank;

void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, struct TypeSel *tmpl, int flag);

void HDAE5000_UiState_Reset(void)
{
    unsigned int m;

    HDAE5000_RAM_DirPageBase = 0;
    HDAE5000_RAM_CurDir = 0;
    HDAE5000_RAM_CurSong = 0;
    ram_22aa10 = HDAE5000_Lbn_BlockTemplate;
    HDAE5000_RAM_SaveOptions = HDAE5000_TypeSel_TemplateBlank;
    HDAE5000_RAM_SaveOptions.mask = 0xff;
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, m, &HDAE5000_TypeSel_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, 0, &HDAE5000_TypeSel_TemplateBlank, 2);
    HDAE5000_Set_Menu_Visibility(1);
}
