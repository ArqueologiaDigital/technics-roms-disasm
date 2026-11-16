/* lane_sub probe round 1, form b: other spellings of sub_1a.c's functions (sub-CPU payload v1.42). */

extern unsigned char ram_4134d;
extern int ram_41349;
extern int ram_41347;
extern unsigned int ram_41343;
extern int __near ram_293e;
extern unsigned char Detune_Scale_Curve[];
extern unsigned char ram_41376[];
extern char ram_41342[];
extern unsigned int ram_4136a[];
extern long DSP_OscParamCurve[];
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;

struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };
struct st { int w[0x91]; };
extern struct st __near ram_45ca;

char ScaleTune_Get_Global_Mode(void) { return ram_4134d; }

unsigned int Unsigned_Max_Select(unsigned int a, unsigned int b) { return b > a ? b : a; }

int ScaleTune_Is_Global_Enabled(void) { return ram_41343 & 0x200; }

char BitTest_Bit0_L(char a)
{
    if (a & 1) return 1;
    else return 0;
}

void Pitch_Apply_Zone_Trim(struct zone *p) { p->out = ram_293e + p->base; }

void Voice_SetPitchBendRange(char a) { ram_41349 = a * 256; }

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, unsigned int k) { return t[(int)(k & 0x7f00) >> 8]; }

void Voice_SetMasterTune(char a) { char t = a - 0x40; t += t; ram_41347 = t; }

void DSP_StateTable_Reset(struct st *p) { *p = ram_45ca; }

long DSP_ParamFetch_Op61Table(int x, long i) { return DSP_OscParamCurve[i]; }

unsigned int DSP_VelocityToVolume(unsigned int v) { unsigned int t = v * v; return (t >> 2) + 0x3f; }

void DList_Unlink_SelfLink(struct dl *p)
{
    p->prev->next = p->next;
    p->next->prev = p->prev;
    p->next = p->prev = p;
}

int TVF_Bias_Clamp_Amount(int a)
{
    a = a + 0x18;
    return a > 0x78 ? 0x78 : a;
}

int Int_ClampSignedToRange(int a, int hi, int lo)
{
    if (a > hi) return hi;
    if (a < lo) return lo;
    return a;
}

int Voice_Pitch_ClampRange(int a, int hi, int lo)
{
    if (a < lo) return lo;
    if (a > hi) return hi;
    return a;
}

int Detune_ScaleUnsigned(unsigned char a) { return Detune_Scale_Curve[a]; }

void Voice_CC_SetPan(unsigned char part, char v) { ram_41376[part * 0x11f] = v; }

char ScaleTune_Get_User_Offset(unsigned char n) { return ram_41342[n + 12]; }

void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { ram_41342[n + 12] = (char)(v - 128); }

int TVF_Clamp_Cutoff(int a)
{
    if (a > 0x78) return 0x78;
    if (a < 0) return 0;
    return a;
}

void ScaleTune_Set_Global_Enabled(char a)
{
    if (!a) ram_41343 |= 0x200;
    else ram_41343 &= 0xfdff;
}

struct vol { char pad[64]; unsigned int v; };
void Voice_WriteVolume_SetFlag(struct vol *p)
{
    ram_451f8 = p->v | 0x80;
    ram_451fa = p->v;
}

void BlockCopy_Words_BC_to_HL(char *s, char *d, int n)
{
    int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}
