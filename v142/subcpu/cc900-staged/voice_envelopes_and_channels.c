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
