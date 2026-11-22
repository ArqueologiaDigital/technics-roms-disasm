/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine_m261.c (2026-11-22-6-p6-r73)
   sha256 b4986c7a4300bf2af184d6406b4e8cbe966b39d86dc79adc760337d8f99866a5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11
   cc900-name: AccPatch_VADB_Helper6=AccPatch_VoiceAssignDataBlock_Helper6 */
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
extern volatile unsigned int __near ram_3952;
extern volatile unsigned int __near ram_395c;
extern volatile unsigned int __near ram_3966;
void AccPatch_VADB_Helper6(void)
{
    ram_3974 = ram_3952;
    ram_3976 = ram_395c;
    AccPatch_VADB_Helper11();
    ram_3952 = ram_3974;
    ram_3966 = ram_3978;
    ram_395c = ram_3976;
}
