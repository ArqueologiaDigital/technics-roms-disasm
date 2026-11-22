/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int ram_1e0010[];
extern unsigned int SoundRam_ComputeChecksum(void);
extern unsigned char ram_1e0000[];
extern void SoundRam_WriteChecksum(void);

unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned int n;

    n = 0x24b8;
    p = ram_1e0010;
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    return ~s;
}

void SoundRam_WriteChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned char *b;
    unsigned int n;

    n = 0x24b8;
    b = ram_1e0000;
    p = (unsigned int *)(b + 16);
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    *(unsigned int *)(b + 29352) = ~s;
}
