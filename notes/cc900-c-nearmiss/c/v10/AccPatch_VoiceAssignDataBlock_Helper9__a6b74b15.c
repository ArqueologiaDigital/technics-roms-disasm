/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_26r1m261a.c (2026-11-22-5-p6-r72)
   sha256 a6b74b154d6b83aa68943294781a1babb3a82ae37784b9b5cce087ff202bd46f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11
   cc900-name: AccPatch_VADB_Helper9=AccPatch_VoiceAssignDataBlock_Helper9 */
extern volatile unsigned int __near ram_3958;
extern volatile unsigned int __near ram_3962;
extern volatile unsigned int __near ram_396c;
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
void AccPatch_VADB_Helper9(void)
{
    ram_3974 = ram_3958;
    ram_3976 = ram_3962;
    AccPatch_VADB_Helper11();
    ram_3958 = ram_3974;
    ram_396c = ram_3978;
    ram_3962 = ram_3976;
}
