/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_26r1m261c.c (2026-11-22-5-p6-r72)
   sha256 a33db74837c4988d7855dae09e90e7883867cdaa2e93839aa8509356756592ba (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11
   cc900-name: AccPatch_VADB_Helper6=AccPatch_VoiceAssignDataBlock_Helper6 */
extern volatile unsigned int __near ram_3952[5];
extern volatile unsigned int __near ram_395c[5];
extern volatile unsigned int __near ram_3966[5];
extern volatile unsigned int __near ram_3974[3];
extern void AccPatch_VADB_Helper11(void);
void AccPatch_VADB_Helper6(void)
{
    ram_3974[0] = ram_3952[0];
    ram_3974[1] = ram_395c[0];
    AccPatch_VADB_Helper11();
    ram_3952[0] = ram_3974[0];
    ram_3966[0] = ram_3974[2];
    ram_395c[0] = ram_3974[1];
}
