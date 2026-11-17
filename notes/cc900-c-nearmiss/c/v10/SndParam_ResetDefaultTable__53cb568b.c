/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283b.c (2026-11-16-107-p6-r21)
   sha256 53cb568b54e7d0b445ed3ebdfaa2071a9d155552b182d093e04f113112383e92 (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    register struct SpRec12 *p;

    ram_96d4[0] = SndParam_ClearRecordTemplate;
    p = ram_96d4;
    p->w[0] = 0xffff;
}
