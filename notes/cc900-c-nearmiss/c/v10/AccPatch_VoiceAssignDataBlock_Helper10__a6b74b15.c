/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_26r1m261a.c (2026-11-22-5-p6-r72)
   sha256 a6b74b154d6b83aa68943294781a1babb3a82ae37784b9b5cce087ff202bd46f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper10=AccPatch_VoiceAssignDataBlock_Helper10
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
extern volatile unsigned int __near ram_395a;
extern volatile unsigned int __near ram_3964;
extern volatile unsigned int __near ram_396e;
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
void AccPatch_VADB_Helper10(void)
{
    ram_3974 = ram_395a;
    ram_3976 = ram_3964;
    AccPatch_VADB_Helper11();
    ram_395a = ram_3974;
    ram_396e = ram_3978;
    ram_3964 = ram_3976;
}
