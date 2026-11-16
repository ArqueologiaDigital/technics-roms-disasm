/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_7b.c (2026-11-16-79-sub-r7)
   sha256 0e81eb6ab024acd014e6d2eb800878760e411151e24f67720eb434542a72ee38 (name+funcs); compiled at -Xr */
extern void RingBuf_SetOffsetLo(unsigned char v);
extern void Voice_SetVelocity(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_SetPitch(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern void Voice_NoteOff(unsigned char a, unsigned char b, unsigned char c, unsigned int d);
extern unsigned char *Voice_Allocate(unsigned char a, unsigned char b);
extern void Voice_ParamInit(unsigned char *v);
void Voice_NoteOn(char *m)
{
    unsigned char ch;
    if (m[1] >= 26) return;
    ch = m[0] & 7;
    if ((m[3] & 0x7f) != 0) {
        RingBuf_SetOffsetLo(m[0] & 8);
        Voice_SetVelocity(m[1], m[2], m[3], ch);
        Voice_SetPitch(m[1], m[2], m[3], ch);
    } else {
        Voice_ParamInit(Voice_Allocate(m[1], m[2]));
        Voice_NoteOff(m[1], m[2], m[3], ch);
    }
}
