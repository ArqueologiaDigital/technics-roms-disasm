/* lane_p6 helper H, round 26r1, form a: module 261 (sequencer/accompaniment_engine.s), the family
   AccPatch_VoiceAssignDataBlock_Helper6 .. _Helper10 (5 x 44 B, f6b890 .. f6b940).
   Each copies part N's two words (0x3952 + 2N, 0x395c + 2N) to the work cells 0x3974 / 0x3976, runs
   AccPatch_VoiceAssignDataBlock_Helper11, and copies 0x3974 / 0x3976 back and the result 0x3978 to 0x3966 + 2N.
   Form a: direct assignments between volatile __near cells (load + store through WA, AccTuning_SaveState's idiom).
   Names longer than 31 characters get short C names (the cc900-name lines below).
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccPatch_VoiceAssignDataBlock_Helper11 */
/* cc900-name: AccPatch_VADB_Helper6=AccPatch_VoiceAssignDataBlock_Helper6 */
/* cc900-name: AccPatch_VADB_Helper7=AccPatch_VoiceAssignDataBlock_Helper7 */
/* cc900-name: AccPatch_VADB_Helper8=AccPatch_VoiceAssignDataBlock_Helper8 */
/* cc900-name: AccPatch_VADB_Helper9=AccPatch_VoiceAssignDataBlock_Helper9 */
/* cc900-name: AccPatch_VADB_Helper10=AccPatch_VoiceAssignDataBlock_Helper10 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */

extern volatile unsigned int __near ram_3952;
extern volatile unsigned int __near ram_3954;
extern volatile unsigned int __near ram_3956;
extern volatile unsigned int __near ram_3958;
extern volatile unsigned int __near ram_395a;
extern volatile unsigned int __near ram_395c;
extern volatile unsigned int __near ram_395e;
extern volatile unsigned int __near ram_3960;
extern volatile unsigned int __near ram_3962;
extern volatile unsigned int __near ram_3964;
extern volatile unsigned int __near ram_3966;
extern volatile unsigned int __near ram_3968;
extern volatile unsigned int __near ram_396a;
extern volatile unsigned int __near ram_396c;
extern volatile unsigned int __near ram_396e;
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);

void AccPatch_VADB_Helper6(void)
{
    ram_3974 = ram_3952;
    ram_3976 = ram_395c;
    AccPatch_VADB_Helper11();
    ram_3952 = ram_3974;
    ram_3966 = ram_3978;
    ram_395c = ram_3976;
}

void AccPatch_VADB_Helper7(void)
{
    ram_3974 = ram_3954;
    ram_3976 = ram_395e;
    AccPatch_VADB_Helper11();
    ram_3954 = ram_3974;
    ram_3968 = ram_3978;
    ram_395e = ram_3976;
}

void AccPatch_VADB_Helper8(void)
{
    ram_3974 = ram_3956;
    ram_3976 = ram_3960;
    AccPatch_VADB_Helper11();
    ram_3956 = ram_3974;
    ram_396a = ram_3978;
    ram_3960 = ram_3976;
}

void AccPatch_VADB_Helper9(void)
{
    ram_3974 = ram_3958;
    ram_3976 = ram_3962;
    AccPatch_VADB_Helper11();
    ram_3958 = ram_3974;
    ram_396c = ram_3978;
    ram_3962 = ram_3976;
}

void AccPatch_VADB_Helper10(void)
{
    ram_3974 = ram_395a;
    ram_3976 = ram_3964;
    AccPatch_VADB_Helper11();
    ram_395a = ram_3974;
    ram_396e = ram_3978;
    ram_3964 = ram_3976;
}
