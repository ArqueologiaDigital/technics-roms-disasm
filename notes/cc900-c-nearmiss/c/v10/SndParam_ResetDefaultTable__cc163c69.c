/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283a.c (2026-11-16-100-p6-r19)
   sha256 cc163c69f7fc974d121e418b768ffd0651b39c90bbb6d1ba4e4deea36d2095c0 (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    ram_96d4[0] = SndParam_ClearRecordTemplate;
    *(unsigned int *)((unsigned long)&ram_96d4[0] + 0) = 0xffff;
}
