/* lane_p6 helper H, round 26r1, form c: module 261 (sequencer/accompaniment_engine.s), the family
   AccPatch_VoiceAssignDataBlock_Helper6 .. _Helper10 (5 x 44 B, f6b890 .. f6b940).
   Form c: the cells as three volatile word arrays of five parts (0x3952, 0x395c, 0x3966) and the three work
   cells as one volatile array (0x3974), direct assignments.
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

void AccPatch_VADB_Helper7(void)
{
    ram_3974[0] = ram_3952[1];
    ram_3974[1] = ram_395c[1];
    AccPatch_VADB_Helper11();
    ram_3952[1] = ram_3974[0];
    ram_3966[1] = ram_3974[2];
    ram_395c[1] = ram_3974[1];
}

void AccPatch_VADB_Helper8(void)
{
    ram_3974[0] = ram_3952[2];
    ram_3974[1] = ram_395c[2];
    AccPatch_VADB_Helper11();
    ram_3952[2] = ram_3974[0];
    ram_3966[2] = ram_3974[2];
    ram_395c[2] = ram_3974[1];
}

void AccPatch_VADB_Helper9(void)
{
    ram_3974[0] = ram_3952[3];
    ram_3974[1] = ram_395c[3];
    AccPatch_VADB_Helper11();
    ram_3952[3] = ram_3974[0];
    ram_3966[3] = ram_3974[2];
    ram_395c[3] = ram_3974[1];
}

void AccPatch_VADB_Helper10(void)
{
    ram_3974[0] = ram_3952[4];
    ram_3974[1] = ram_395c[4];
    AccPatch_VADB_Helper11();
    ram_3952[4] = ram_3974[0];
    ram_3966[4] = ram_3974[2];
    ram_395c[4] = ram_3974[1];
}
