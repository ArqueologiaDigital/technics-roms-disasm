/* hd_r54_misc_ui.c (helper h_misc, lane_hd round 54): one calr group, HDAE5000_UiState_Reset (hd-ae5000_v2_06i.s,
   0x2803c2, 122 B, survey `hand?`) and its calr target HDAE5000_TypeSel_Init (hdae5000_hd_driver.s, 0x2852e4, 92 B,
   survey `hand?`), in ROM order.  No earlier probe defined either (the probes only called TypeSel_Init).
   Both read as compiled C, not hand assembly: the `ldirw` is V4.23's struct copy (`ld xiy,src; ld xix,dst;
   ld bc,words; ldirw (xix+),(xiy+)`, as in RcmStream_InitialState's copy, run hd-r23a); TypeSel_Init ends in
   `retd 2` (callee pops its stacked 4th argument).
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_Init
   cc900-name: UiStateReset_b=HDAE5000_UiState_Reset
   cc900-name: TypeSelInit_b=HDAE5000_TypeSel_Init
   cc900-name: TypeSelInit_c=HDAE5000_TypeSel_Init

   UiState_Reset (ROM): three words = 0; the 10-byte LBN block 0x22aa58 = HDAE5000_Lbn_BlockTemplate and
   SaveOptions = TypeSel_TemplateBlank by `ld xiy,imm / ld xix,imm` (struct assignment of two externs);
   SaveOptions.mask = 0x1ff; m = Song_PartMask(CurDir, CurSong) kept in HL (no push: no register local),
   compared through `ld wa,hl; cp wa,0xffff`; TypeSel_Init(&SaveOptions converted -> loaded FIRST, m late,
   &TemplateBlank late, 2 pushed) or with 0 (constant last); tail `jp Set_Menu_Visibility` (V4.23 ends a void
   function in a jump when its last statement is a call and it has no frame: Frame_Handler, HardTest_Print).
     HDAE5000_UiState_Reset  m assigned in the condition
     UiStateReset_b          m assigned first, then tested
   TypeSel_Init (ROM): param homes src XDE->XIX, mask BC->HL, then the stacked byte `ld e,(xsp+4)`; struct copy
   *rec = *tmpl (XIY from XIX, XIX from XWA); rec->mask = mask; nine `bit k,hl; jr z; ld (xwa+2+k),e`.
     HDAE5000_TypeSel_Init   int flag (callers' prototype: `pushw 2`) narrowed by a char local v = flag
     TypeSelInit_b           an `unsigned char flag` parameter (byte load expected; the callers' push not tested here)
     TypeSelInit_c           explicit locals s = tmpl, m = mask, v = flag (the ROM's entry moves, in that order)
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

void HDAE5000_UiState_Reset(void)
{
    unsigned int m;

    HDAE5000_RAM_DirPageBase = 0;
    HDAE5000_RAM_CurDir = 0;
    HDAE5000_RAM_CurSong = 0;
    ram_22aa58 = HDAE5000_Lbn_BlockTemplate;
    HDAE5000_RAM_SaveOptions = HDAE5000_TypeSel_TemplateBlank;
    HDAE5000_RAM_SaveOptions.mask = 0x1ff;
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, m, &HDAE5000_TypeSel_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, 0, &HDAE5000_TypeSel_TemplateBlank, 2);
    HDAE5000_Set_Menu_Visibility(1);
}

void UiStateReset_b(void)
{
    unsigned int m;

    HDAE5000_RAM_DirPageBase = 0;
    HDAE5000_RAM_CurDir = 0;
    HDAE5000_RAM_CurSong = 0;
    ram_22aa58 = HDAE5000_Lbn_BlockTemplate;
    HDAE5000_RAM_SaveOptions = HDAE5000_TypeSel_TemplateBlank;
    HDAE5000_RAM_SaveOptions.mask = 0x1ff;
    m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong);
    if (m != 0xffff)
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, m, &HDAE5000_TypeSel_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init((void *)&HDAE5000_RAM_SaveOptions, 0, &HDAE5000_TypeSel_TemplateBlank, 2);
    HDAE5000_Set_Menu_Visibility(1);
}

void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, struct TypeSel *tmpl, int flag)
{
    unsigned char v = flag;

    *(struct TypeSel *)rec = *tmpl;
    ((struct TypeSel *)rec)->mask = mask;
    if (mask & 0x001)
        ((struct TypeSel *)rec)->flag[0] = v;
    if (mask & 0x002)
        ((struct TypeSel *)rec)->flag[1] = v;
    if (mask & 0x004)
        ((struct TypeSel *)rec)->flag[2] = v;
    if (mask & 0x008)
        ((struct TypeSel *)rec)->flag[3] = v;
    if (mask & 0x010)
        ((struct TypeSel *)rec)->flag[4] = v;
    if (mask & 0x020)
        ((struct TypeSel *)rec)->flag[5] = v;
    if (mask & 0x040)
        ((struct TypeSel *)rec)->flag[6] = v;
    if (mask & 0x080)
        ((struct TypeSel *)rec)->flag[7] = v;
    if (mask & 0x100)
        ((struct TypeSel *)rec)->flag[8] = v;
}

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

void TypeSelInit_c(struct TypeSel *rec, unsigned int mask, struct TypeSel *tmpl, int flag)
{
    struct TypeSel *s = tmpl;
    unsigned int m = mask;
    unsigned char v = flag;

    *rec = *s;
    rec->mask = m;
    if (m & 0x001)
        rec->flag[0] = v;
    if (m & 0x002)
        rec->flag[1] = v;
    if (m & 0x004)
        rec->flag[2] = v;
    if (m & 0x008)
        rec->flag[3] = v;
    if (m & 0x010)
        rec->flag[4] = v;
    if (m & 0x020)
        rec->flag[5] = v;
    if (m & 0x040)
        rec->flag[6] = v;
    if (m & 0x080)
        rec->flag[7] = v;
    if (m & 0x100)
        rec->flag[8] = v;
}
