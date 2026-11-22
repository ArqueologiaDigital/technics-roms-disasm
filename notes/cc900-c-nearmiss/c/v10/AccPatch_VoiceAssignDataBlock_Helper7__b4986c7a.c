/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/accompaniment_engine_m261.c (2026-11-22-6-p6-r73)
   sha256 b4986c7a4300bf2af184d6406b4e8cbe966b39d86dc79adc760337d8f99866a5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11
   cc900-name: AccPatch_VADB_Helper7=AccPatch_VoiceAssignDataBlock_Helper7 */
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
extern volatile unsigned int __near ram_3954;
extern volatile unsigned int __near ram_395e;
extern volatile unsigned int __near ram_3968;
void AccPatch_VADB_Helper7(void)
{
    ram_3974 = ram_3954;
    ram_3976 = ram_395e;
    AccPatch_VADB_Helper11();
    ram_3954 = ram_3974;
    ram_3968 = ram_3978;
    ram_395e = ram_3976;
}
