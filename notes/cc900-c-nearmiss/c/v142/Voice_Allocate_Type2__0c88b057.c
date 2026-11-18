/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21b.c (2026-11-18-29-sub-r21f)
   sha256 0c88b057db4df86d1242b8b0aeb50e8e69981a7373919757e71b282266e1d268 (tar-sha256); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define SLOT(part, k) (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e])
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned int ram_41343;
extern unsigned char __near ram_2942[];
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t);
extern unsigned char *WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);
extern void Voice_Pitch_CopyBase(unsigned char *v);
int Voice_Pitch_ClampRange(int a, int hi, int lo);
void Voice_Allocate_Type2(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned char *v;

    sub = ToneDB_Find_SubToneRecord((unsigned char *)(unsigned long)*(unsigned char **)&ram_4136e[part * 0x11f], key, part);
    if (sub[13] & mask) {
        zone = &sub[(int)k * 21 + 16];
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = z << 6 | 0x10;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        if (ram_41343 & 2) vel = Voice_Pitch_ClampRange(vel + 0x10, 0x7f, 0);
        v[12] = vel;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 39) = SLOT(part, k);
        P(v, 19) = sub;
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        Voice_Pitch_CopyBase(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}
