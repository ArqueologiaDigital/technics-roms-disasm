/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21c.c (2026-11-18-29-sub-r21f)
   sha256 0f9f6b50e681ccdd0c79fa69a634212ad02f882d1981a6abb66195cad3ab5ac6 (tar-sha256); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
struct v71 { unsigned char b[71]; };
extern unsigned char ram_4308e[];
extern unsigned char __near ram_2942[];
extern void Voice_Allocate_Nodes(unsigned char *v);
void Voice_Allocate_1of4(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                         unsigned char key, unsigned char vel, unsigned char flag);
void Voice_NoteOn_Rhythm(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel)
{
    unsigned char k;
    unsigned char t;

    W(p, 0) = ((unsigned int)part << 8 | key) | 0x80;
    if (vel != 0) {
        k = 0;
        Voice_Allocate_1of4(p, part, 1, k, key, vel, 3);
        p[6] = 0x40;
        p[3] = 0;
        p[7] = 0;
    } else {
        k = 1;
        vel = 0x50;
        p[2] = 0;
        p[6] = 0;
        Voice_Allocate_1of4(p, part, 4, k, key, vel, 3);
        p[7] = 0;
    }
    p[4] = 0;
    p[8] = 0;
    p[5] = 0;
    p[9] = 0;
    Voice_Allocate_Nodes(p);
    if (p[(int)k + 10] < 0x40) {
        t = p[(int)k + 10];
        *(struct v71 *)&ram_4308e[(int)t * 71] = *(struct v71 *)&ram_2942[(int)k * 71];
        ram_4308e[(int)t * 71] = t;
    }
}
