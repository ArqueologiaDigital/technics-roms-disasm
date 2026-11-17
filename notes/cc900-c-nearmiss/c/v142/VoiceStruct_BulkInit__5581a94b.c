/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18a.c (2026-11-17-7-sub-r18)
   sha256 5581a94b8744c554c7810133a024cbd218f46e7ca66812c682e8dd6f7e0a7d38 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
void VoiceStruct_BulkInit(unsigned char part)
{
    unsigned char k;
    unsigned char *s;
    s = *(unsigned char **)(ram_4136e + part * 0x11f);
    BlockCopy_Words_BC_to_HL(s, (unsigned int *)ram_44fce, 0x66);
    for (k = 0; k < 4; k++) {
        s = *(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[k];
        BlockCopy_Words_BC_to_HL(s, ((unsigned int *)&ram_44fce[(int)(unsigned int)((int)k * 0x51 + 0x66)]), 0x51);
    }
}
