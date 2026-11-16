/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine_m249.c (2026-11-16-111-p6-r22-staged)
   sha256 3cd4d0c435ee62c01c06a082b671e37a7cf21bf17288005dbdd27c717321c31c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_342a;
extern unsigned char __near ram_342b;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char *__near ACC_STYLE_RECORD;
void AccTone_IBDC_Helper(void)
{
    unsigned char a;
    unsigned char *p;
    a = Chord_TypeFamilyTable[ACC_CHORD_TYPE];
    ram_342b = a;
    p = ACC_STYLE_RECORD;
    a = p[a];
    ram_342a = a;
    if (a != 255)
        return;
    ram_342a = *p;
    ram_342b = 0;
}
