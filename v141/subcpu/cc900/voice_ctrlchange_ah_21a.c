/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char ram_41352[];
extern unsigned char ram_41356[];
extern unsigned int ram_4132b;
extern unsigned char __near ram_2942[];
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t);
extern unsigned char *WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);
extern void Voice_Pitch_CopyBase(unsigned char *v);
extern void Voice_Pitch_Compute(unsigned char *v);
int Voice_Pitch_ClampRange(int a, int hi, int lo);
void Voice_Allocate_Type2(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag);
void Voice_NoteOn_Type3(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                        unsigned char key, unsigned char vel, unsigned char flag);

/* cc900-module: Voice_Allocate_Type2 Voice_NoteOn_Type3 Voice_Pitch_ClampRange */
void Voice_Allocate_Type2(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned char *v;
    unsigned char *r;
    r = *(unsigned char **)&ram_41356[part * 0x11f];
    sub = ToneDB_Find_SubToneRecord(r, key, part);
    if (sub[13] & mask) {
        zone = &sub[(int)k * 21 + 16];
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        (*(unsigned int *)((v) + (1))) = z << 6 | 0x10;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        if (ram_4132b & 2) vel = Voice_Pitch_ClampRange(vel + 0x10, 0x7f, 0);
        v[12] = vel;
        (*(unsigned char **)((v) + (35))) = ram_41350 + part * 0x11f;
        (*(unsigned char **)((v) + (39))) = (&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        (*(unsigned char **)((v) + (19))) = sub;
        (*(unsigned char **)((v) + (23))) = zone;
        (*(unsigned char **)((v) + (27))) = a1;
        (*(unsigned char **)((v) + (31))) = a2;
        Voice_Pitch_CopyBase(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}

void Voice_NoteOn_Type3(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                        unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *v;
    unsigned char *zone;
    unsigned char *a2;
    unsigned char *s;
    unsigned char *a1;
    if (*(unsigned int *)&ram_41352[part * 0x11f] & mask) {
        a1 = *(unsigned char **)((unsigned long)(&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]) + 4);
        zone = *(unsigned char **)(&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        a2 = *(unsigned char **)((unsigned long)(&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]) + 8);
        s = (&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        v = &ram_2942[(int)k * 71];
        (*(unsigned int *)((v) + (1))) = 8;
        if (vel & 0x80) (*(unsigned int *)((v) + (1))) |= 0x800;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel & 0x7f;
        (*(unsigned char **)((v) + (35))) = ram_41350 + part * 0x11f;
        (*(unsigned char **)((v) + (19))) = *(unsigned char **)&ram_41356[part * 0x11f];
        (*(unsigned char **)((v) + (23))) = zone;
        (*(unsigned char **)((v) + (27))) = a1;
        (*(unsigned char **)((v) + (31))) = a2;
        (*(unsigned char **)((v) + (39))) = s;
        Voice_Pitch_Compute(v);
        (*(unsigned int *)((v) + (47))) = 0;
        (*(unsigned int *)((v) + (49))) = 0xff;
        v[53] = 0;
        (*(unsigned int *)((v) + (54))) = 0;
        (*(unsigned int *)((v) + (58))) = 0;
        (*(unsigned int *)((v) + (56))) = 0;
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}
