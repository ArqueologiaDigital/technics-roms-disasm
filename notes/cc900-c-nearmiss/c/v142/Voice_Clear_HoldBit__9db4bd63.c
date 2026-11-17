/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18b.c (2026-11-17-7-sub-r18)
   sha256 9db4bd630ae5363516e81e0b25f0380c9790ffacf02065aae572215e2138f5b7 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned int __near ram_2936[];
void Voice_Reprioritise(unsigned char *p);
void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[(int)(n >> 4)] &= ~((unsigned int)1 << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}
