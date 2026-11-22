/* lane_p6 helper H, round 26r1, form b: module 261 (sequencer/accompaniment_engine.s), the family
   AccPatch_VoiceAssignDataBlock_Helper6 .. _Helper10 (5 x 44 B, f6b890 .. f6b940).
   Form b: plain __near cells, each copy through an unsigned int local (AccCh1_SaveState's -Xr idiom).
   Names longer than 31 characters get short C names (the cc900-name lines below).
   cc900-options: -Xr
*/
/* cc900-module: AccPatch_VoiceAssignDataBlock_Helper11 */
/* cc900-name: AccPatch_VADB_Helper6=AccPatch_VoiceAssignDataBlock_Helper6 */
/* cc900-name: AccPatch_VADB_Helper7=AccPatch_VoiceAssignDataBlock_Helper7 */
/* cc900-name: AccPatch_VADB_Helper8=AccPatch_VoiceAssignDataBlock_Helper8 */
/* cc900-name: AccPatch_VADB_Helper9=AccPatch_VoiceAssignDataBlock_Helper9 */
/* cc900-name: AccPatch_VADB_Helper10=AccPatch_VoiceAssignDataBlock_Helper10 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */

extern unsigned int __near ram_3952;
extern unsigned int __near ram_3954;
extern unsigned int __near ram_3956;
extern unsigned int __near ram_3958;
extern unsigned int __near ram_395a;
extern unsigned int __near ram_395c;
extern unsigned int __near ram_395e;
extern unsigned int __near ram_3960;
extern unsigned int __near ram_3962;
extern unsigned int __near ram_3964;
extern unsigned int __near ram_3966;
extern unsigned int __near ram_3968;
extern unsigned int __near ram_396a;
extern unsigned int __near ram_396c;
extern unsigned int __near ram_396e;
extern unsigned int __near ram_3974;
extern unsigned int __near ram_3976;
extern unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);

void AccPatch_VADB_Helper6(void)
{
    unsigned int w;
    w = ram_3952;
    ram_3974 = w;
    w = ram_395c;
    ram_3976 = w;
    AccPatch_VADB_Helper11();
    w = ram_3974;
    ram_3952 = w;
    w = ram_3978;
    ram_3966 = w;
    w = ram_3976;
    ram_395c = w;
}

void AccPatch_VADB_Helper7(void)
{
    unsigned int w;
    w = ram_3954;
    ram_3974 = w;
    w = ram_395e;
    ram_3976 = w;
    AccPatch_VADB_Helper11();
    w = ram_3974;
    ram_3954 = w;
    w = ram_3978;
    ram_3968 = w;
    w = ram_3976;
    ram_395e = w;
}

void AccPatch_VADB_Helper8(void)
{
    unsigned int w;
    w = ram_3956;
    ram_3974 = w;
    w = ram_3960;
    ram_3976 = w;
    AccPatch_VADB_Helper11();
    w = ram_3974;
    ram_3956 = w;
    w = ram_3978;
    ram_396a = w;
    w = ram_3976;
    ram_3960 = w;
}

void AccPatch_VADB_Helper9(void)
{
    unsigned int w;
    w = ram_3958;
    ram_3974 = w;
    w = ram_3962;
    ram_3976 = w;
    AccPatch_VADB_Helper11();
    w = ram_3974;
    ram_3958 = w;
    w = ram_3978;
    ram_396c = w;
    w = ram_3976;
    ram_3962 = w;
}

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
