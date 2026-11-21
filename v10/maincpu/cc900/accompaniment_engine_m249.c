/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ACC_REQ_INTRO;
extern unsigned char __near PANEL_STYLE[];
extern void AddswbWr(int, int, int, int);
extern unsigned char __near ACC_REQ_FILLIN;
extern unsigned char __near ACC_REQ_ENDING;

/* cc900-name: AccTone_InlBcData_H3_Helper=AccTone_InlineBytecodeData_Code_Helper3_Helper */
void AccTone_InlBcData_H3_Helper(void)
{
    ACC_REQ_INTRO &= ~0x2;
    PANEL_STYLE[5] &= ~0x8;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper2=AccTone_InlineBytecodeData_Code_Helper3_Helper2 */
void AccTone_InlBcData_H3_Helper2(void)
{
    ACC_REQ_INTRO &= ~0x1;
    PANEL_STYLE[5] &= ~0x4;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper3=AccTone_InlineBytecodeData_Code_Helper3_Helper3 */
void AccTone_InlBcData_H3_Helper3(void)
{
    ACC_REQ_INTRO &= ~0x4;
    PANEL_STYLE[6] &= ~0x4;
    AddswbWr(72, 6, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper10=AccVoice_BarCounterBytecodeData_Helper10 */
void AccVoice_BarCntBcData_Helper10(void)
{
    ACC_REQ_FILLIN &= ~0x2;
    PANEL_STYLE[5] &= ~0x80;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper3=AccVoice_BarCounterBytecodeData_Helper3 */
void AccVoice_BarCntBcData_Helper3(void)
{
    ACC_REQ_FILLIN &= ~0x1;
    PANEL_STYLE[5] &= ~0x40;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper8=AccVoice_BarCounterBytecodeData_Helper8 */
void AccVoice_BarCntBcData_Helper8(void)
{
    ACC_REQ_ENDING &= ~0x1;
    PANEL_STYLE[5] &= ~0x10;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper9=AccVoice_BarCounterBytecodeData_Helper9 */
void AccVoice_BarCntBcData_Helper9(void)
{
    ACC_REQ_ENDING &= ~0x2;
    PANEL_STYLE[5] &= ~0x20;
    AddswbWr(72, 5, 0, 0);
}

extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_342a;
extern unsigned char __near ram_342b;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char *__near ACC_STYLE_RECORD;
extern void AccTone_IBDC_Helper(void);

/* cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
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

extern unsigned char __near ram_3422;
extern unsigned char __near ram_3423;
extern void Chord_LookupTypeFamily(void);

void Chord_LookupTypeFamily(void)
{
  ram_3422 = Chord_TypeFamilyTable[ram_3423];
}
