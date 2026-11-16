/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern unsigned char ram_41335;
extern unsigned char ram_41333;
extern int ram_41331;
extern unsigned int ram_4132b;
extern unsigned char ram_4135e[];
extern int ram_451e0;
extern int ram_451e2;

struct vol { char pad[64]; int v; };

void Voice_WriteVolume_SetFlag(struct vol *p)
{
    ram_451e0 = p->v | 0x80;
    ram_451e2 = p->v;
}

void Voice_CC_SetPan(unsigned char part, unsigned char v) { ram_4135e[part * 0x11f] = v; }

void Voice_SetPitchBendRange(char a) { ram_41331 = (int)a << 8; }

void ScaleTune_Set_Global_Mode(unsigned char a) { ram_41335 = a; }
unsigned char ScaleTune_Get_Global_Mode(void) { return ram_41335; }
void Voice_SetVelSwitchConfig(unsigned char a) { ram_41333 = a; }

void Voice_SetCCMaxFlag(unsigned char a)
{
    if (a == 0x7f) ram_4132b |= 2;
    else ram_4132b &= ~2;
}

void ScaleTune_Set_Global_Enabled(unsigned char a)
{
    if (a == 0) ram_4132b |= 0x200;
    else ram_4132b &= ~0x200;
}

unsigned int ScaleTune_Is_Global_Enabled(void) { return ram_4132b & 0x200; }
