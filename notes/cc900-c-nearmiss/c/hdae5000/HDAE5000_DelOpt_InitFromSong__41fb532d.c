/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small2.c (2026-11-17-13-hd-r42-ports)
   sha256 41fb532d04b1cddcad2b89adfb641aa4f14ab58d55121e6a1f2ac49d2d663760 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int flag);
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern unsigned char HDAE5000_DelOpt_TemplateBlank[];
void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all)
{
    unsigned int m;

    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, 0, HDAE5000_DelOpt_TemplateBlank, 2);
    HDAE5000_RAM_DeleteOptions.mask = 0;
}
