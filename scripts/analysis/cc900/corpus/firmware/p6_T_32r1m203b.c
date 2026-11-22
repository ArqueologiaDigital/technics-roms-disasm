/* Probe round 32r1, helper T, form b: demo/demo_seq_bridge.s (module 203), as form a with the mark byte an
   unsigned char parameter and the number digits written with *p++ in both branches. */

extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern unsigned char __near ram_1afa[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern unsigned char *SongBank_ComputeTableOfs(unsigned int, unsigned char, unsigned char);

unsigned char *SongBank_ComputeTableOfs(unsigned int idx, unsigned char c, unsigned char f)
{
    unsigned char *src;
    unsigned char *p;

    src = &SEQ_SONG_SLOTS[idx][256];
    p = ram_1afa[idx];
    *p++ = c;
    if (f) {
        if (idx == 9) {
            *p++ = '1';
            *p++ = '0';
        } else {
            *p++ = ' ';
            *p++ = idx + '1';
        }
        *p++ = ':';
    }
    FileIO_CopyString_WriteNull(p, src, 16);
    p[16] = 0;
    return ram_1afa[idx];
}
