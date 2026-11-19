/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_lbn_page.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 f705ec41db45a5b36815ae721156987bcf7e5f7e96a7dcc1a5a102dbacdcfa60 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define OBJ_LBN_OPTION 0x7f0094L
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step)
{
    int m;
    int d;

    d = dir;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        return;
    case 1:
        d += step * 100;
        if (d >= 100)
            d = 100;
        else if (d <= 0)
            d = 0;
        break;
    case 2:
        d += step * 10;
        if (d >= 120)
            d = 120;
        else if (d <= 1)
            d = 0;
        break;
    case 3:
        d += step;
        if (d > 120)
            d = 120;
        else if (d <= 0)
            d = 1;
        break;
    case 4:
        song += step * 10;
        if (song >= 10)
            song = 10;
        else if (song <= 0)
            song = 0;
        break;
    case 5:
        song += step;
        if (song > 16)
            song = 16;
        else if (song <= 0)
            song = 1;
    }
    HDAE5000_RAM_LbnDir = d;
    HDAE5000_RAM_LbnSong = song;
    if (HDAE5000_RAM_LbnDigitPos == 5) {
        HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
        HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
        } else {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, -1, -1, 0xffff);
        }
    }
    HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
}
