/* lane_sub probe round 9, helper C, form c: core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload v1.42.
   VoiceSubSlot_Init with the 11-byte row offset through an int local, and VoiceParam_SubSlot_Apply_Catalog64 (new;
   its two nibbles of `sel` live in byte registers QA / W in the ROM, and it ends with a tail jump to
   WaveSel_Cache_SetDescPtr, an absolute jp).

   cc900-module: BlockCopy_Words_BC_to_HL */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern void WaveSel_Cache_SetDescPtr();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    int o;
    o = (int)c * 11 + 426;
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c), ram_44fce + o,
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}

/* cc900-name: SubSlot_Apply_Catalog64=VoiceParam_SubSlot_Apply_Catalog64 */
void SubSlot_Apply_Catalog64(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char lo;
    unsigned char hi;
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 100));
    lo = sel;
    lo &= 15;
    hi = (sel & 0xf0) >> 4;
    (*(unsigned char **)&((unsigned char *)(unsigned long)((struct partrec *)(ram_41368 + part * 0x11f))->partial[lo])[4])
        [(int)hi * 2 + 3] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(*(unsigned char **)&((unsigned char *)(unsigned long)
        ((struct partrec *)(ram_41368 + part * 0x11f))->partial[lo])[4] + ((int)hi * 2 + 3)))[1] = tbl[idx].b;
    WaveSel_Cache_SetDescPtr(part, lo, hi);
}
