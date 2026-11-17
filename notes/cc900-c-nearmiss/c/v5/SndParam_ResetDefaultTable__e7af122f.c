/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sndparam_routines_m0_xr.c (2026-11-16-122-p6-r24-staged)
   sha256 e7af122f14d663d1d5930122fb65cff574731f8fe9aea9180dc27133291a034a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_9614[];
unsigned int *SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_9614[0] = SndParam_ClearRecordTemplate;
    q = &ram_9614[0].w[0];
    *q = 0xffff;
    return q;
}
