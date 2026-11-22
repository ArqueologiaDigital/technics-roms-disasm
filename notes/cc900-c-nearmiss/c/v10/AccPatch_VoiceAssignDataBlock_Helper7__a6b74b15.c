/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_26r1m261a.c (2026-11-22-5-p6-r72)
   sha256 a6b74b154d6b83aa68943294781a1babb3a82ae37784b9b5cce087ff202bd46f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11
   cc900-name: AccPatch_VADB_Helper7=AccPatch_VoiceAssignDataBlock_Helper7 */
extern volatile unsigned int __near ram_3954;
extern volatile unsigned int __near ram_395e;
extern volatile unsigned int __near ram_3968;
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
void AccPatch_VADB_Helper7(void)
{
    ram_3974 = ram_3954;
    ram_3976 = ram_395e;
    AccPatch_VADB_Helper11();
    ram_3954 = ram_3974;
    ram_3968 = ram_3978;
    ram_395e = ram_3976;
}
