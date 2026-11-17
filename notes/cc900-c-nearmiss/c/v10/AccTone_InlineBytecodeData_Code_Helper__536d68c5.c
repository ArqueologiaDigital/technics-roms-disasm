/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_16a.c (2026-11-16-100-p6-r19)
   sha256 536d68c5f63c70de9d18f69197f3e601618301b5706aa5a6952db8278237746d (tar-sha256); compiled at -O3 -XS -Xr
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
