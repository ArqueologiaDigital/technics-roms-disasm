/* Phase 6, lane_p6 helper C, round 8, module 257 (modules_v10.tsv) of v10 sequencer/accompaniment_engine.s: the two
   parameter editors that call Tempo_DisplayParamCommon by calr, with that callee and its neighbours defined here. */

extern unsigned char __near ram_e3e2;
extern unsigned char __near ram_e3e4;
extern unsigned char __near ram_e3e6;
extern unsigned char __near ram_e3de;
extern unsigned char __near ram_e3dc;
extern unsigned char __near ram_e3e0;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned int __near ram_398a;
extern unsigned int __near ram_398c;
extern void UI_InterruptTitleByIndex(int);

void Tempo_DisplayParamCommon(unsigned char a, unsigned char c)
{
    ram_e3e2 |= 9;
    ram_e3e4 = a;
    ram_e3e6 = c;
}

void Tempo_DisplayParamSkipClear(unsigned char a)
{
    GLOBAL_ERROR_CODE = a;
    UI_InterruptTitleByIndex(0xee);
}

void Tempo_DisplayParamFormat(unsigned char a)
{
    ram_e3de = 0x80;
    ram_e3dc = a;
}

void TimeSig_ProcNop(void)
{
}

void Tempo_EditParam92(unsigned char dir)
{
    unsigned int v, w, m;
    Tempo_DisplayParamCommon(146, 18);
    v = ram_398a;
    if (dir == 0) {
        if (v >= 999) return;
        if (v >= 989) ram_398a = 999;
        else ram_398a = v + 10;
    } else {
        if (v <= 1) return;
        if (v <= 10) ram_398a = 1;
        else ram_398a = v - 10;
    }
    m = ram_398c;
    w = ram_398a;
    if (w > m) ram_398c = w;
    else if ((w += 7) < m) ram_398c = w;
    ram_e3e0 |= 0x10;
}

void Tempo_EditParam93(unsigned char dir)
{
    unsigned int v, b;
    Tempo_DisplayParamCommon(147, 19);
    v = ram_398c;
    if (dir == 0) {
        if (v >= 999) return;
        if (v >= 989) ram_398c = 999;
        else ram_398c = v + 10;
    } else {
        if (v <= 1) return;
        if (v <= 10) ram_398c = 1;
        else ram_398c = v - 10;
    }
    v = ram_398c;
    b = ram_398a;
    if (b > v) ram_398a = v;
    else if ((b += 7) < v) ram_398a = v - 7;
    ram_e3e0 |= 0x10;
}
