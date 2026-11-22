/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m203a.c (2026-11-22-17-p6-r84)
   sha256 57fb96c575cb8e34e04917f6fe18717fb52031529adf64c36d95e4d60252f475 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern unsigned char __near ram_1afa[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
unsigned char *SongBank_ComputeTableOfs(unsigned int idx, unsigned int c, unsigned char f)
{
    unsigned char *src;
    unsigned char *p;

    src = SEQ_SONG_SLOTS[idx] + 256;
    p = ram_1afa[idx];
    *p++ = c;
    if (f != 0) {
        if (idx == 9) {
            *p++ = '1';
            *p = '0';
        } else {
            *p++ = ' ';
            *p = idx + '1';
        }
        p++;
        *p++ = ':';
    }
    FileIO_CopyString_WriteNull(p, src, 16);
    p[16] = 0;
    return ram_1afa[idx];
}
