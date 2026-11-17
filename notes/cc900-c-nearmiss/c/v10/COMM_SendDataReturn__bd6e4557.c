/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -Xr */
extern unsigned long __near ram_cfb4;
extern unsigned long __near ram_cfb8;
extern unsigned long __near ram_cfbc;
extern unsigned long __near ram_cfc0;
extern unsigned long __near ram_cfc4;
extern unsigned int __near ram_cfc8;
extern unsigned int __near ram_cfca;
extern unsigned int __near ram_cfcc;
extern unsigned int __near ram_cfce;
extern unsigned int __near ram_cfd0[];
extern unsigned int __near ram_d010[];
extern unsigned int __near ram_d050[];
void COMM_SendDataReturn(void)
{
  unsigned int i;
  ram_cfb4 = 0xffffffff; ram_cfb8 = 0xffffffff; ram_cfbc = 0xffffffff; ram_cfc0 = 0xffffffff; ram_cfc4 = 0xffffffff;
  ram_cfc8 = 0xffff; ram_cfca = 0xffff; ram_cfcc = 0xffff; ram_cfce = 0xffff;
  i = 0;
  if (i <= 24) do {
    ram_cfd0[i] = 0xffff;
    ram_d010[i] = 0xffff;
    ram_d050[i] = 0xffff;
    i++;
  } while (i <= 24);
}
