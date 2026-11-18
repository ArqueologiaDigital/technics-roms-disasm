/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20b.c (2026-11-18-18-sub-r21a)
   sha256 1a38294d9608c2cdcfb43a7ec910017dec23940711db7c62016a80b94617f566 (tar-sha256); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
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
    unsigned int w;
    unsigned char *v;

    z = 0;
    a2 = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)k * 37 + (int)z * 4)))[118];
    w = W(a2, 12);
    sub = ToneDB_Find_SubToneRecord(ToneDB_Find_ToneRecord((unsigned char)w, (unsigned char)(w >> 8)), a2[11], part);
    if ((a2[0] & 2) && (sub[13] & mask)) {
        zone = sub + ((int)k * 21 + 16);
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = z << 6 | 0x12;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 19) = sub;
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        Voice_Slot_ComputePitch(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
}
