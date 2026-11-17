/* lane_ws probe round 1: small leaf functions of the SX-WSA1R prom_a (CPU 1, wsa1/prom_a), to learn whether
   a cc900 we hold reproduces them and at which options.  Names are the tree's labels; ram_<hex> is a RAM cell the
   tree has not named.  The ROM reads every argument from the stack, so the functions are plain (cdecl). */

extern unsigned char __near ram_27df;
extern unsigned int __near ram_280c;
extern unsigned int __near ram_27f9;
extern unsigned char __tiny ram_c6;
extern unsigned char __near MIDI_Fg_Flags;
extern unsigned char __near MIDI_Fg_FirstData;
extern unsigned char __near ram_2330[];
extern unsigned char __near ram_2333;
extern unsigned char __near ram_76c2[];

void Var27DF_Set(unsigned char v) { ram_27df = v; }
void Var27DF_Get(unsigned char *p) { *p = ram_27df; }
void Var280C_SetW(unsigned int v) { ram_280c = v; }
void Var27F9_GetW(unsigned int *p) { *p = ram_27f9; }
void LCD_SetPanelDarkFlag(unsigned char v) { ram_c6 = v & 1; }

void MIDI_Fg_StashFirstData(unsigned char v)
{
    MIDI_Fg_Flags |= 0x40;
    MIDI_Fg_FirstData = v;
}

unsigned char BitMask_PopCountByte(unsigned char v)
{
    unsigned char n = 0;
    unsigned char i;
    for (i = 8; i != 0; i--) {
        if (v & 1) n++;
        v >>= 1;
    }
    return n;
}

void Rec2330_CopyData25(unsigned char *dst)
{
    unsigned int s = 6;
    unsigned char i;
    for (i = 0; i < 25; i++) {
        dst[i] = ram_2330[s];
        s++;
    }
}

void Rec2330_CopyData(unsigned char *dst)
{
    unsigned char n = ram_2333;
    unsigned char i = 0;
    unsigned int s;
    unsigned char c;
    if (n > 0) {
        s = 6;
        do {
            c = ram_2330[s];
            dst[i] = c;
            s++;
            i++;
        } while (i < n);
    }
}

void Part0SecondRecord_StoreBytes(unsigned int unused, unsigned int off, unsigned char n, unsigned char *src)
{
    unsigned char i;
    for (i = 0; i < n; i++)
        ram_76c2[off + i] = src[i];
}
