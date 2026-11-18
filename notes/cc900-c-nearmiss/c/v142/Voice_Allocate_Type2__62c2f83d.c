/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 62c2f83dce024f097c31ff3a1aeb543ddd4720cb6f88b2776f1353994c531562 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
    unsigned char *r;
    r = *(unsigned char **)&ram_4136e[part * 0x11f];
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
        if (ram_41343 & 2) vel = Voice_Pitch_ClampRange(vel + 0x10, 0x7f, 0);
        v[12] = vel;
        (*(unsigned char **)((v) + (35))) = ram_41368 + part * 0x11f;
        (*(unsigned char **)((v) + (39))) = (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        (*(unsigned char **)((v) + (19))) = sub;
        (*(unsigned char **)((v) + (23))) = zone;
        (*(unsigned char **)((v) + (27))) = a1;
        (*(unsigned char **)((v) + (31))) = a2;
        Voice_Pitch_CopyBase(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}
