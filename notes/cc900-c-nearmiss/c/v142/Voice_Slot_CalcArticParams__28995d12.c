/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d6[];
extern char ram_41472[];
extern char ram_41473[];
extern char ram_41474[];
extern char ram_41475[];
void Voice_SignedClamp(unsigned char *p, int d, int hi, int lo);
void Voice_Slot_CalcArticParams(unsigned char part)
{
    unsigned int i;
    char d1;
    char d2;
    unsigned char *s;
    unsigned int w;
    d1 = ram_41474[part * 0x11f];
    d2 = ram_41475[part * 0x11f];
    s = *(unsigned char **)&ram_413d6[part * 0x11f];
    for (i = 0; i < 4; i++, s += 81) {
        w = *(unsigned int *)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 2 + 0x102));
        s[2] = w;
        s[3] &= 0xf0;
        s[3] |= (w >> 8) & 0xf;
        if (i < 3) {
            Voice_SignedClamp(s + 39, d1, 0x64, 0);
            Voice_SignedClamp(s + 45, d2, 0x64, 0);
        } else {
            Voice_SignedClamp(s + 23, ram_41472[part * 0x11f], 0x7f, 0);
            Voice_SignedClamp(s + 41, ram_41473[part * 0x11f], 0x64, 0);
            Voice_SignedClamp(s + 43, ram_41473[part * 0x11f], 0x64, 0);
        }
    }
}
