/* Probe round 32r1, helper T, form a: demo/demo_seq_bridge.s (module 203).
   SongBank_ComputeTableOfs: build the 21-byte list row of song idx in ram_1afa (mark byte, optional "nn:" number,
   the 16-character name from the song slot's offset 256) and return the row. */

extern unsigned char SEQ_SONG_SLOTS[][0x800];
extern unsigned char __near ram_1afa[][21];
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern unsigned char *SongBank_ComputeTableOfs(unsigned int, unsigned int, unsigned char);

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
