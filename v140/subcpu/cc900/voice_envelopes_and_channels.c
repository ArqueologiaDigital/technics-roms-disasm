/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41301;
extern unsigned char ram_412ff;
extern int ram_412fd;
extern unsigned int ram_412f7;
extern unsigned char ram_4132a[];
extern int ram_451ac;
extern int ram_451ae;
struct vol { char pad[64]; int v; };

unsigned char ScaleTune_Get_Global_Mode(void) { return ram_41301; }

unsigned int ScaleTune_Is_Global_Enabled(void) { return ram_412f7 & 0x200; }

void ScaleTune_Set_Global_Enabled(unsigned char a)
{
    if (a == 0) ram_412f7 |= 0x200;
    else ram_412f7 &= ~0x200;
}

void ScaleTune_Set_Global_Mode(unsigned char a) { ram_41301 = a; }

void Voice_CC_SetPan(unsigned char part, unsigned char v) { ram_4132a[part * 0x11f] = v; }

void Voice_SetCCMaxFlag(unsigned char a)
{
    if (a == 0x7f) ram_412f7 |= 2;
    else ram_412f7 &= ~2;
}

void Voice_SetPitchBendRange(char a) { ram_412fd = (int)a << 8; }

void Voice_SetVelSwitchConfig(unsigned char a) { ram_412ff = a; }

void Voice_WriteVolume_SetFlag(struct vol *p)
{
    ram_451ac = p->v | 0x80;
    ram_451ae = p->v;
}

extern unsigned char ram_4131e[];
extern int ram_412fb;

void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4131e[part * 0x11f] &= ~0x2000; }

void Voice_SetLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4131e[part * 0x11f] |= 0x2000; }

void Voice_SetMasterTune(char a) { a -= 0x40; a += a; ram_412fb = a; }

extern unsigned int ram_41310;
extern unsigned char ram_41312;
extern unsigned char ram_41313;
extern unsigned int ram_41314;
extern unsigned int ram_41316;
extern int ram_41318;
extern unsigned char ram_41326[];
extern unsigned char ram_4132b[];
extern unsigned char ram_4132e[];
extern unsigned char ram_4132f[];
extern unsigned char ram_41333[];
extern unsigned char ram_41334[];
extern unsigned char ram_41341[];
extern unsigned char ram_41342[];
extern unsigned int ram_4519a;
extern unsigned int ram_4519c;
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

void Voice_CC_SetBendRange(unsigned char part, unsigned char v) { ram_4132f[part * 0x11f] = v; }

void Voice_CC_SetDspEffectSend(unsigned char part, unsigned char v) { ram_4132e[part * 0x11f] = v; }

void Voice_CC_SetGateRoutingMode(unsigned char part, unsigned char v) { ram_41341[part * 0x11f] = v; }

void Voice_CC_SetGlidePedal(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41326[part * 0x11f] |= 4;
    else *(unsigned int *)&ram_41326[part * 0x11f] &= ~4;
}

void Voice_CC_SetKeyScaling(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_4131e[part * 0x11f] |= 0x100;
    else *(unsigned int *)&ram_4131e[part * 0x11f] &= ~0x100;
}

void Voice_CC_SetModWheelRange(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41326[part * 0x11f] |= 2;
    else *(unsigned int *)&ram_41326[part * 0x11f] &= ~2;
}

void Voice_CC_SetReverbSend(unsigned char part, unsigned char v) { ram_4132b[part * 0x11f] = v; }

void Voice_CC_SetSostenutoFlag(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41326[part * 0x11f] |= 0x4000;
    else *(unsigned int *)&ram_41326[part * 0x11f] &= ~0x4000;
}

void Voice_CC_SetSustain(unsigned char part, unsigned char v)
{
    if (v != 0) *(unsigned int *)&ram_41326[part * 0x11f] |= 1;
    else *(unsigned int *)&ram_41326[part * 0x11f] &= ~1;
}

void Voice_CC_SetSustainLength(unsigned char part, unsigned char v) { ram_41334[part * 0x11f] = v; }

void Voice_CC_SetTgPanMode(unsigned char part, unsigned char v) { ram_41342[part * 0x11f] = v; }

void Voice_CC_SetVelSwitchConfig(unsigned char part, unsigned char v) { ram_41333[part * 0x11f] = v; }

void Voice_SetKeyShiftEnable(unsigned char on)
{
    unsigned int t;
    if (on != 0) {
        if (ram_412f7 & 0x1000) return;
        ram_412f7 |= 0x800;
        ram_41310 = 0;
    } else {
        if (!(ram_412f7 & 0x1000)) return;
        t = ram_412f7 & ~(0x1000 | 0x4000 | 32768);
        t |= 0x2000;
        if (ram_41310 > 20) t |= 0x8000;
        else t |= 0x4000;
        ram_412f7 = t;
        ram_41310 = 0;
    }
}

void Voice_SetRhythmMode(unsigned char a)
{
    if (a & 8) ram_41312 = 3;
    else ram_41312 = 1;
    ram_41313 = 1;
    ram_41314 = Voice_RhythmMode_ScalePitch_Table[(a & 0xf0) >> 4];
    if (a & 4) ram_41316 = 0x8000;
    else ram_41316 = 0xa000;
    ram_41318 = 200 - ((a & 3) << 3);
}

void Voice_Stage_EnvSegments(struct envseg *p)
{
    ram_4519a = p->a;
    ram_4519c = p->b;
}

extern unsigned char ram_41330[];

void Voice_CC_SetTuning(unsigned char part, unsigned char v)
{
    int t;
    t = v;
    t -= 0x80;
    t += t;
    *(int *)&ram_41330[part * 0x11f] = t;
}

extern int ram_4130e;
extern unsigned char ram_41332[];
extern char Voice_KeyShiftRamp_Steps[];

void Pitch_Bend_Ramp_Tick(void)
{
    int t;
    if (ram_412f7 & 0x800) {
        ram_41310++;
        t = Voice_KeyShiftRamp_Steps[0];
        t += t;
        ram_4130e = t;
        ram_412f7 &= ~0x800;
        ram_412f7 |= 0x1400;
    } else if (ram_412f7 & 0x1000) {
        ram_41310++;
        ram_412f7 &= ~0x400;
    } else if (ram_412f7 & 0x2000) {
        if (ram_412f7 & 0x4000) {
            ram_41310 += 2;
            t = Voice_KeyShiftRamp_Steps[ram_41310];
            t += t;
            ram_4130e = t;
            ram_412f7 |= 0x400;
        } else if (ram_412f7 & 32768) {
            ram_41310++;
            t = Voice_KeyShiftRamp_Steps[ram_41310];
            t += t;
            ram_4130e = t;
            ram_412f7 |= 0x400;
        } else {
            ram_4130e = 0;
            ram_412f7 |= 0x400;
        }
        if (ram_4130e != 0) return;
        ram_412f7 &= 0x1fff;
        ram_41310 = 0;
        ram_412f7 |= 0x400;
    } else {
        ram_412f7 &= ~0x400;
    }
}

void Voice_CC_SetKeyShift(unsigned char part, unsigned char v)
{
    unsigned char t;
    t = v;
    t -= 0x40;
    ram_41332[part * 0x11f] = t;
}

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;


