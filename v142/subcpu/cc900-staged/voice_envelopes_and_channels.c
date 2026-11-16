/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern unsigned char ram_4134d;
extern unsigned char ram_4134b;
extern int ram_41349;
extern unsigned int ram_41343;
extern unsigned char ram_41376[];
extern int ram_451f8;
extern int ram_451fa;

struct vol { char pad[64]; int v; };

void Voice_WriteVolume_SetFlag(struct vol *p)
{
    ram_451f8 = p->v | 0x80;
    ram_451fa = p->v;
}

void Voice_CC_SetPan(unsigned char part, unsigned char v) { ram_41376[part * 0x11f] = v; }

void Voice_SetPitchBendRange(char a) { ram_41349 = (int)a << 8; }

void ScaleTune_Set_Global_Mode(unsigned char a) { ram_4134d = a; }
unsigned char ScaleTune_Get_Global_Mode(void) { return ram_4134d; }
void Voice_SetVelSwitchConfig(unsigned char a) { ram_4134b = a; }

void Voice_SetCCMaxFlag(unsigned char a)
{
    if (a == 0x7f) ram_41343 |= 2;
    else ram_41343 &= ~2;
}

void ScaleTune_Set_Global_Enabled(unsigned char a)
{
    if (a == 0) ram_41343 |= 0x200;
    else ram_41343 &= ~0x200;
}

unsigned int ScaleTune_Is_Global_Enabled(void) { return ram_41343 & 0x200; }

extern unsigned char ram_4136a[];
extern int ram_41347;

void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4136a[part * 0x11f] &= ~0x2000; }

void Voice_SetLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4136a[part * 0x11f] |= 0x2000; }

void Voice_SetMasterTune(char a) { a -= 0x40; a += a; ram_41347 = a; }

extern unsigned int ram_4135c;
extern unsigned char ram_4135e;
extern unsigned char ram_4135f;
extern unsigned int ram_41360;
extern unsigned int ram_41362;
extern int ram_41364;
extern unsigned char ram_41372[];
extern unsigned char ram_41377[];
extern unsigned char ram_4137a[];
extern unsigned char ram_4137b[];
extern unsigned char ram_4137f[];
extern unsigned char ram_41380[];
extern unsigned char ram_4138d[];
extern unsigned char ram_4138e[];
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int Voice_RhythmMode_ScalePitch_Table[];
struct envseg { char pad[62]; unsigned int a; unsigned int b; };

int Audio_Clamp_To_Range(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

void VoiceCC_Stub_Ret1(void) { }

void VoiceCC_Stub_Ret2(void) { }

void Voice_CC_SetBendRange(unsigned char part, unsigned char v) { ram_4137b[part * 0x11f] = v; }

void Voice_CC_SetDspEffectSend(unsigned char part, unsigned char v) { ram_4137a[part * 0x11f] = v; }

void Voice_CC_SetGateRoutingMode(unsigned char part, unsigned char v) { ram_4138d[part * 0x11f] = v; }

void Voice_CC_SetGlidePedal(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41372[part * 0x11f] |= 4;
    else *(unsigned int *)&ram_41372[part * 0x11f] &= ~4;
}

void Voice_CC_SetKeyScaling(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_4136a[part * 0x11f] |= 0x100;
    else *(unsigned int *)&ram_4136a[part * 0x11f] &= ~0x100;
}

void Voice_CC_SetModWheelRange(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41372[part * 0x11f] |= 2;
    else *(unsigned int *)&ram_41372[part * 0x11f] &= ~2;
}

void Voice_CC_SetReverbSend(unsigned char part, unsigned char v) { ram_41377[part * 0x11f] = v; }

void Voice_CC_SetSostenutoFlag(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41372[part * 0x11f] |= 0x4000;
    else *(unsigned int *)&ram_41372[part * 0x11f] &= ~0x4000;
}

void Voice_CC_SetSustain(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41372[part * 0x11f] |= 1;
    else *(unsigned int *)&ram_41372[part * 0x11f] &= ~1;
}

void Voice_CC_SetSustainLength(unsigned char part, unsigned char v) { ram_41380[part * 0x11f] = v; }

void Voice_CC_SetTgPanMode(unsigned char part, unsigned char v) { ram_4138e[part * 0x11f] = v; }

void Voice_CC_SetVelSwitchConfig(unsigned char part, unsigned char v) { ram_4137f[part * 0x11f] = v; }

void Voice_SetKeyShiftEnable(unsigned char on)
{
    unsigned int t;
    if (on != 0) {
        if (ram_41343 & 0x1000) return;
        ram_41343 |= 0x800;
        ram_4135c = 0;
    } else {
        if (!(ram_41343 & 0x1000)) return;
        t = ram_41343 & ~(0x1000 | 0x4000 | 32768);
        t |= 0x2000;
        if (ram_4135c > 20) t |= 0x8000;
        else t |= 0x4000;
        ram_41343 = t;
        ram_4135c = 0;
    }
}

void Voice_SetRhythmMode(unsigned char a)
{
    if (a & 8) ram_4135e = 3;
    else ram_4135e = 1;
    ram_4135f = 1;
    ram_41360 = Voice_RhythmMode_ScalePitch_Table[(a & 0xf0) >> 4];
    if (a & 4) ram_41362 = 0x8000;
    else ram_41362 = 0xa000;
    ram_41364 = 200 - ((a & 3) << 3);
}

void Voice_Stage_EnvSegments(struct envseg *p)
{
    ram_451e6 = p->a;
    ram_451e8 = p->b;
}
