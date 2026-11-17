/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9b.c (2026-11-16-86-sub-r9)
   sha256 b3d05a841099d4cda9aa375131f53561d80ba0b7a5c605a73f349b2eac22e90c (name+funcs); compiled at -O1 -Xr */
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
void VoiceRow_FetchPair_WA_SP(int a);
void VoiceRow_FetchPair_DE_WA(int a, int c);
void VoiceSlot_UpdateNoteSource(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *s;
    unsigned char *r;
    unsigned char k;
    s = &ram_2126[(int)a * 5];
    r = &ram_1e4d[(int)s[2] * 27];
    k = s[3];
    if (r[k] == a) {
        if (s[0] != a) r[k] = s[0];
        else r[k] = 0xff;
    }
    r = &ram_1e4d[(int)c * 27];
    if (r[e] > 0xc0) {
        r[e] = a;
        VoiceRow_FetchPair_WA_SP(a);
    } else VoiceRow_FetchPair_DE_WA(a, r[e]);
    s[2] = c;
    s[3] = e;
}
