/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccPatch_VoiceAssignDataBlock_Helper11 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned int __near ram_395a;
extern volatile unsigned int __near ram_3964;
extern volatile unsigned int __near ram_396e;
extern volatile unsigned int __near ram_3974;
extern volatile unsigned int __near ram_3976;
extern volatile unsigned int __near ram_3978;
extern void AccPatch_VADB_Helper11(void);
extern void AccPatch_VADB_Helper10(void);
extern volatile unsigned int __near ram_3952;
extern volatile unsigned int __near ram_395c;
extern volatile unsigned int __near ram_3966;
extern void AccPatch_VADB_Helper6(void);
extern volatile unsigned int __near ram_3954;
extern volatile unsigned int __near ram_395e;
extern volatile unsigned int __near ram_3968;
extern void AccPatch_VADB_Helper7(void);
extern volatile unsigned int __near ram_3956;
extern volatile unsigned int __near ram_3960;
extern volatile unsigned int __near ram_396a;
extern void AccPatch_VADB_Helper8(void);
extern volatile unsigned int __near ram_3958;
extern volatile unsigned int __near ram_3962;
extern volatile unsigned int __near ram_396c;
extern void AccPatch_VADB_Helper9(void);

/* cc900-name: AccPatch_VADB_Helper10=AccPatch_VoiceAssignDataBlock_Helper10 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
void AccPatch_VADB_Helper10(void)
{
    ram_3974 = ram_395a;
    ram_3976 = ram_3964;
    AccPatch_VADB_Helper11();
    ram_395a = ram_3974;
    ram_396e = ram_3978;
    ram_3964 = ram_3976;
}

/* cc900-name: AccPatch_VADB_Helper6=AccPatch_VoiceAssignDataBlock_Helper6 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
void AccPatch_VADB_Helper6(void)
{
    ram_3974 = ram_3952;
    ram_3976 = ram_395c;
    AccPatch_VADB_Helper11();
    ram_3952 = ram_3974;
    ram_3966 = ram_3978;
    ram_395c = ram_3976;
}

/* cc900-name: AccPatch_VADB_Helper7=AccPatch_VoiceAssignDataBlock_Helper7 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
void AccPatch_VADB_Helper7(void)
{
    ram_3974 = ram_3954;
    ram_3976 = ram_395e;
    AccPatch_VADB_Helper11();
    ram_3954 = ram_3974;
    ram_3968 = ram_3978;
    ram_395e = ram_3976;
}

/* cc900-name: AccPatch_VADB_Helper8=AccPatch_VoiceAssignDataBlock_Helper8 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
void AccPatch_VADB_Helper8(void)
{
    ram_3974 = ram_3956;
    ram_3976 = ram_3960;
    AccPatch_VADB_Helper11();
    ram_3956 = ram_3974;
    ram_396a = ram_3978;
    ram_3960 = ram_3976;
}

/* cc900-name: AccPatch_VADB_Helper9=AccPatch_VoiceAssignDataBlock_Helper9 */
/* cc900-name: AccPatch_VADB_Helper11=AccPatch_VoiceAssignDataBlock_Helper11 */
void AccPatch_VADB_Helper9(void)
{
    ram_3974 = ram_3958;
    ram_3976 = ram_3962;
    AccPatch_VADB_Helper11();
    ram_3958 = ram_3974;
    ram_396c = ram_3978;
    ram_3962 = ram_3976;
}
