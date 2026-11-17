/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m283a.c (2026-11-16-88-p6-r16)
   sha256 7555874f9f4353c9597576e92cbf7fd9fb6eeffaa5c4f99a7e0a3421b042df3b (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    struct SpRec12 *p;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    p = ram_96d4;
    p->w[0] = 0xffff;
}
