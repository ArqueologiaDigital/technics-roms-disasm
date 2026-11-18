/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_ctrlchange_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 62c2f83dce024f097c31ff3a1aeb543ddd4720cb6f88b2776f1353994c531562 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char __near ram_2942[];
extern void Voice_Pitch_Compute(unsigned char *v);
void Voice_NoteOn_Type3(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                        unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *v;
    unsigned char *zone;
    unsigned char *a2;
    unsigned char *s;
    unsigned char *a1;
    if (*(unsigned int *)&ram_4136a[part * 0x11f] & mask) {
        a1 = *(unsigned char **)((unsigned long)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]) + 4);
        zone = *(unsigned char **)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        a2 = *(unsigned char **)((unsigned long)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]) + 8);
        s = (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e]);
        v = &ram_2942[(int)k * 71];
        (*(unsigned int *)((v) + (1))) = 8;
        if (vel & 0x80) (*(unsigned int *)((v) + (1))) |= 0x800;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel & 0x7f;
        (*(unsigned char **)((v) + (35))) = ram_41368 + part * 0x11f;
        (*(unsigned char **)((v) + (19))) = *(unsigned char **)&ram_4136e[part * 0x11f];
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
