/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-30-p6-r1)
   sha256 89c854e8d1cefff97d8e3bd7f8dd41e25e56a8bb83e3b643d1a5fe02db8a7c3a (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char SEQ_SONG_SLOTS[];
unsigned char *Demo_GetPresetBaseForPart(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 2048;
}
