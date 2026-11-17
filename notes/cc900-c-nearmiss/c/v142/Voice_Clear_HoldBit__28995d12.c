/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned int __near ram_2936[];
void Voice_Reprioritise(unsigned char *p);
void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[(int)(unsigned char)(n >> 4)] &= ~((unsigned int)1 << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}
