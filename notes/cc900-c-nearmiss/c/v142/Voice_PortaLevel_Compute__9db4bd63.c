/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18b.c (2026-11-17-7-sub-r18)
   sha256 9db4bd630ae5363516e81e0b25f0380c9790ffacf02065aae572215e2138f5b7 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451e2;
extern unsigned int ram_451ea;
unsigned int Detune_ScaleUnsigned(unsigned int a);
int Detune_ScaleSymmetric(int a);
int Int_ClampSignedToRange(int a, int hi, int lo);
int PitchBend_Scale(int a, int b, int c);
void Voice_PortaLevel_Compute(unsigned char *v)
{
    unsigned char *t;
    unsigned int b;
    unsigned int a;
    int c;
    unsigned char *u;
    u = P(v, 23);
    t = u;
    if (((char *)u)[7] < 0) {
        a = Detune_ScaleUnsigned(~(int)(char)t[7] + 1);
        b = Detune_ScaleSymmetric(~(int)(char)t[8] + 1);
    } else {
        a = Detune_ScaleUnsigned((char)t[7]);
        b = Detune_ScaleSymmetric((char)t[8]);
    }
    a += PitchBend_Scale((char)t[18], v[12], 6);
    a = Int_ClampSignedToRange(a, 0x7f, 0);
    c = 0x7f;
    c += PitchBend_Scale((char)t[72], v[12], 6);
    c = Int_ClampSignedToRange(c, 0x7f, 0);
    ram_451e2 = (a << 8) | (c & 0xff);
    ram_451ea = (b << 8) | (Detune_ScaleSymmetric((char)(t[62] + t[61])) & 0xff);
}
