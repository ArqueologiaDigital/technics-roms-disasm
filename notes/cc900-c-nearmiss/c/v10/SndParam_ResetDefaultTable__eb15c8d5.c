/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sndparam_routines_m0_xr.c (2026-11-16-122-p6-r24-staged)
   sha256 eb15c8d5dbd8cc9bd06a22782d7c5c87004e2d821ab7332d60c7a35faf20fc68 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
