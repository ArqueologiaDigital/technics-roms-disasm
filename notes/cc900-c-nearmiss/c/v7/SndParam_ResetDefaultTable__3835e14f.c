/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sndparam_routines_m0_xr.c (2026-11-16-122-p6-r24-staged)
   sha256 3835e14feebd7448ded1f5d50f5828cd99618c6a65a83d16eb69a59571bc1e15 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_9638[];
unsigned int *SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_9638[0] = SndParam_ClearRecordTemplate;
    q = &ram_9638[0].w[0];
    *q = 0xffff;
    return q;
}
