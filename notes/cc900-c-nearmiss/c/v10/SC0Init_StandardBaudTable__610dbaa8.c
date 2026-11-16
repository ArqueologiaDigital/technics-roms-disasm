/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_7b.c (2026-11-16-45-p6-r9)
   sha256 610dbaa80fee86b3fc7b51cb71c48d05736a0a61496faada5af95b573292fca3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_b7d4;
extern unsigned int __near ram_b7d6;
extern unsigned int __near ram_b7d8;
extern unsigned int __near ram_b7da;
extern unsigned char __near ram_b7dc;
extern unsigned char Get_Region_Code(void);
void SC0Init_StandardBaudTable(void)
{
    if (Get_Region_Code() == 4)
        goto alt;
    ram_b7d4 = 0x7a12;
    ram_b7d6 = 0x28b0;
    ram_b7d8 = 4166;
    ram_b7da = 1000;
    ram_b7dc = 8;
    goto done;
alt:
    ram_b7d4 = 0x5b8d;
    ram_b7d6 = 7812;
    ram_b7d8 = 3125;
    ram_b7da = 750;
    ram_b7dc = 6;
done:
    ;
}
