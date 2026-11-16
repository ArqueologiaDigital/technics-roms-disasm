/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283a.c (2026-11-16-107-p6-r21)
   sha256 7d977e1b84fde5b654e37b6a6c3d68f9fd9f03a4001a215e73154c642a6c15aa (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    q = &ram_96d4[0].w[0];
    *q = 0xffff;
}
