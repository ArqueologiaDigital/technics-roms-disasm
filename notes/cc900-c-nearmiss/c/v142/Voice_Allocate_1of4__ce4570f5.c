/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_ah_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 ce4570f55723a8610f88c4770f979bfd6504094ee3781d2c3004790b1375f635 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char __near ram_2942[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t);
extern unsigned char *WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);
extern void Voice_Slot_ComputePitch(unsigned char *v);
void Voice_Allocate_1of4(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                         unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned char *t;
    unsigned int w;
    unsigned char *v;
    z = 0;
    t = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                             + ((int)k * 37 + (int)z * 4)))[118];
    a2 = t;
    w = (*(unsigned int *)((t) + (12)));
    sub = ToneDB_Find_SubToneRecord(ToneDB_Find_ToneRecord((unsigned char)w, (unsigned char)(w >> 8)), a2[11], part);
    if ((a2[0] & 2) && (sub[13] & mask)) {
        zone = &sub[(int)k * 21 + 16];
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        (*(unsigned int *)((v) + (1))) = z << 6 | 0x12;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel;
        (*(unsigned char **)((v) + (35))) = ram_41368 + part * 0x11f;
        (*(unsigned char **)((v) + (19))) = sub;
        (*(unsigned char **)((v) + (23))) = zone;
        (*(unsigned char **)((v) + (27))) = a1;
        (*(unsigned char **)((v) + (31))) = a2;
        Voice_Slot_ComputePitch(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
}
