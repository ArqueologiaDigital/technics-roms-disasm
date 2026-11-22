/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m233a.c (2026-11-22-15-p6-r82)
   sha256 6e76d8fd721c6bb21fcea78dce5838a50eddfedfb56ad01cb08507b0589d89d7 (tar-sha256); compiled at -O3 -Xr */
struct bo { unsigned int block; unsigned int offset; };
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void SeqPart_ReadNextEventByte(struct bo *, unsigned char *);
int Part_ReadAndProcessVoiceData(unsigned char part, unsigned int max, struct bo *pos)
{
    unsigned int n;
    struct bo save;
    unsigned char ev[10];

    n = 0;
    if (Part_ReadVoiceBit7(0, part) == 0) return -1;
    pos->block = Part_ReadVoiceWord(0, part);
    pos->offset = 5;
    while (n < max) {
        save.block = pos->block;
        save.offset = pos->offset;
        SeqPart_ReadNextEventByte(pos, ev);
        if (ev[0] == 0x81)
            n++;
        else if (ev[0] == 0x82 || ev[0] == 0x84) {
            pos->block = save.block;
            pos->offset = save.offset;
            break;
        }
    }
    return n;
}
