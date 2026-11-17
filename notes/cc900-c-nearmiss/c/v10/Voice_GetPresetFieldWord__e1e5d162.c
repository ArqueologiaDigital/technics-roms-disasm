/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[];
unsigned int Voice_GetPresetFieldWord(unsigned char i)
{
    unsigned char *p;
    unsigned int *w;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    w = (unsigned int *)(p + 30);
    return *w;
}
