/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_338e;
extern unsigned char __near ram_338f;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char *__near ACC_STYLE_RECORD;
extern void AccTone_IBDC_Helper(void);

/* cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
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

extern unsigned char __near ram_3386;
extern unsigned char __near ram_3387;
extern void Chord_LookupTypeFamily(void);

void Chord_LookupTypeFamily(void)
{
  ram_3386 = Chord_TypeFamilyTable[ram_3387];
}
