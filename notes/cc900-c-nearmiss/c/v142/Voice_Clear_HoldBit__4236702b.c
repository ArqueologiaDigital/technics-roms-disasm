/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
struct hw { unsigned int w; };
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern struct hw __near ram_2936[];
void Voice_Reprioritise(unsigned char *p);
void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[n >> 4].w &= ~(1U << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}
