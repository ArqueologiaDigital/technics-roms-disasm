/* lane_sub probe round 1, form a: small leaf functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named. */

extern unsigned char ram_4134d;
extern unsigned char ram_4134b;
extern int ram_41349;
extern int ram_41347;
extern unsigned int ram_41343;
extern int __near ram_293e;
extern unsigned char Detune_Scale_Curve[];
extern unsigned char ram_41376[];
extern unsigned char ram_41342[];
extern unsigned int ram_4136a[];
extern long DSP_OscParamCurve[];
extern int ram_451f8;
extern int ram_451fa;

struct tvf { char pad[66]; int a; int b; };
struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };
struct st { int w[0x91]; };

void ScaleTune_Set_Global_Mode(unsigned char a) { ram_4134d = a; }
unsigned char ScaleTune_Get_Global_Mode(void) { return ram_4134d; }
void Voice_SetVelSwitchConfig(unsigned char a) { ram_4134b = a; }

unsigned int Unsigned_Max_Select(unsigned int a, unsigned int b)
{
    if (b > a) a = b;
    return a;
}

unsigned int ScaleTune_Is_Global_Enabled(void) { return ram_41343 & 0x200; }

unsigned char BitTest_Bit0_L(unsigned char a)
{
    if (a & 1) return 1;
    return 0;
}

void TVF_Set_Bypass(struct tvf *p) { p->a = 0x17f; p->b = 0x7f7f; }

void Pitch_Apply_Zone_Trim(struct zone *p) { p->out = p->base + ram_293e; }

void Voice_SetPitchBendRange(char a) { ram_41349 = (int)a << 8; }

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k) { return t[(k & 0x7f00) >> 8]; }

void Voice_SetMasterTune(char a) { ram_41347 = (char)((a - 0x40) * 2); }

void DSP_StateTable_Reset(struct st *p) { *p = *(struct st *)0x45ca; }

long DSP_ParamFetch_Op61Table(int x, unsigned long i) { return DSP_OscParamCurve[i]; }

unsigned int DSP_VelocityToVolume(unsigned int v) { return ((v * v) >> 2) + 0x3f; }

void DList_Unlink_SelfLink(struct dl *p)
{
    struct dl *n = p->next;
    struct dl *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

int TVF_Bias_Clamp_Amount(int a)
{
    a += 0x18;
    if (a > 0x78) a = 0x78;
    return a;
}

int Int_ClampSignedToRange(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

int ClampS16_WA_Short(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

int Voice_Pitch_ClampRange(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

unsigned int Detune_ScaleUnsigned(unsigned char a) { return Detune_Scale_Curve[a]; }

void Voice_CC_SetPan(unsigned char part, unsigned char v) { ram_41376[part * 0x11f] = v; }

unsigned char ScaleTune_Get_User_Offset(unsigned char n) { return ram_41342[n + 12]; }

void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { ram_41342[n + 12] = v - 0x80; }

void Voice_SetLFO_ActiveFlag(unsigned char part) { *(unsigned int *)((char *)ram_4136a + part * 0x11f) |= 0x2000; }

void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)((char *)ram_4136a + part * 0x11f) &= ~0x2000; }

int TVF_Clamp_Cutoff(int a)
{
    if (a > 0x78) a = 0x78;
    else if (a < 0) a = 0;
    return a;
}

int SignedClamp_Zero(int a)
{
    if (a > 0x7f) a = 0x7f;
    else if (a < 0) a = 0;
    return a;
}

void ScaleTune_Set_Global_Enabled(unsigned char a)
{
    if (a == 0) ram_41343 |= 0x200;
    else ram_41343 &= ~0x200;
}

void Voice_SetCCMaxFlag(unsigned char a)
{
    if (a == 0x7f) ram_41343 |= 2;
    else ram_41343 &= ~2;
}

struct vol { char pad[64]; int v; };
void Voice_WriteVolume_SetFlag(struct vol *p)
{
    ram_451f8 = p->v | 0x80;
    ram_451fa = p->v;
}

void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}
