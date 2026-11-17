/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -Xr */
extern unsigned char ram_4134c;
unsigned int Voice_Apply_GateRouting(int part, unsigned int g);
void Voice_Build_GateCommand(unsigned char *v)
{
    unsigned int g;
    g = 0xff - (((unsigned int)(*(unsigned char **)((v) + (23)))[0] & 0x3f) << 2);
    if ((*(unsigned char **)((v) + (23)))[0] != 0) g |= 0x100;
    if ((*(unsigned char **)((v) + (35)))[18] != 0) {
        switch (ram_4134c) {
        case 0:
        case 5:
        case 6:
            (*(int *)((v) + (45))) = g | 0xfe00;
            break;
        default:
            (*(int *)((v) + (45))) = g | 0xf000;
            break;
        }
    } else (*(int *)((v) + (45))) = g | 0xf000;
    (*(int *)((v) + (45))) = Voice_Apply_GateRouting(v[4], (*(int *)((v) + (45))));
}
