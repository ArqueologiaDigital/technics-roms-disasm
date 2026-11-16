/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283a.c (2026-11-16-118-p6-r23)
   sha256 c3cd59d1f5affaf9f3a5d10c7a8c858173f6970cda4882faede02b8ca900cb50 (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
unsigned int *SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    q = &ram_96d4[0].w[0];
    *q = 0xffff;
    return q;
}
