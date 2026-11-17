/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283b.c (2026-11-16-100-p6-r19)
   sha256 bb5d49ddbd4ab0b4fe2ff807261d08c6b49e6f23f0462ecf3f07c15844c1c009 (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    ram_96d4[0] = SndParam_ClearRecordTemplate;
    *(unsigned int *)(unsigned long)ram_96d4 = 0xffff;
}
