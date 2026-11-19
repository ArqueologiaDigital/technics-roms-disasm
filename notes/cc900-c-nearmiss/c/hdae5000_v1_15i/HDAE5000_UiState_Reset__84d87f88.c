/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_uistate_reset_r71.c (2026-11-19-61-hd-r73-staged)
   sha256 84d87f8878dfd56b5d2ec444fc6fd0303783e2cfaa38cf6dc8529ce93f60aecd (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct LbnBlock { unsigned int w[5]; };
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern void HDAE5000_Set_Menu_Visibility(int hide);
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct LbnBlock ram_22aa10;
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
