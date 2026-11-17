/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m283b.c (2026-11-16-88-p6-r16)
   sha256 50efd1e278fa3afd62fb24cf9230373917a958333655c5050e23d53d8b723ae5 (tar-sha256); compiled at -Xr */
struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_96d4[];
void SndParam_ResetDefaultTable(void)
{
    ram_96d4[0] = SndParam_ClearRecordTemplate;
    ram_96d4[0].w[0] = 0xffff;
}
