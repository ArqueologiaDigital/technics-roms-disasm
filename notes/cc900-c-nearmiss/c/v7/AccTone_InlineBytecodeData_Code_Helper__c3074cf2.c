/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine_m249.c (2026-11-16-111-p6-r22-staged)
   sha256 c3074cf29abaefc4b784cf72dbebf119624c4e695f6233c0f2b0574210454926 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_338e;
extern unsigned char __near ram_338f;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char *__near ACC_STYLE_RECORD;
void AccTone_IBDC_Helper(void)
{
    unsigned char a;
    unsigned char *p;
    a = Chord_TypeFamilyTable[ACC_CHORD_TYPE];
    ram_338f = a;
    p = ACC_STYLE_RECORD;
    a = p[a];
    ram_338e = a;
    if (a != 255)
        return;
    ram_338e = *p;
    ram_338f = 0;
}
