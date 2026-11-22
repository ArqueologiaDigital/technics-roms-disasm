/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_26r1m261b.c (2026-11-22-5-p6-r72)
   sha256 b5bab11353182eb12d4418894c7696fad6f5463c34fe9d3fbe741d9bf7dc4111 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr
   cc900-name: AccPatch_VADB_Helper10=AccPatch_VoiceAssignDataBlock_Helper10
   cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
extern unsigned int __near ram_395a;
extern unsigned int __near ram_3964;
extern unsigned int __near ram_396e;
extern unsigned int __near ram_3974;
extern unsigned int __near ram_3976;
extern unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
void AccPatch_VADB_Helper10(void)
{
    unsigned int w;
    w = ram_395a;
    ram_3974 = w;
    w = ram_3964;
    ram_3976 = w;
    AccPatch_VADB_Helper11();
    w = ram_3974;
    ram_395a = w;
    w = ram_3978;
    ram_396e = w;
    w = ram_3976;
    ram_3964 = w;
}
