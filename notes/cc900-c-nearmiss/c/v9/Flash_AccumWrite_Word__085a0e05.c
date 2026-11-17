/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/system_handlers_m5.c (2026-11-16-68-p6-r12)
   sha256 085a0e05eabb47549084b1b16929336fe46ee96956e247d45dbd3c4f70d0ba7a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
typedef unsigned int *uip;
extern unsigned char __near ram_654;
extern unsigned char __near ram_62c[];
extern uip __near ram_656;
extern unsigned long __near ram_642;
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
void Flash_AccumWrite_Word(unsigned char a)
{
    ram_62c[ram_654] = a;
    if (ram_654++ == 1) {
        Flash_ProgramWord(1, ram_656++, *(unsigned int *)ram_62c);
        ram_654 = 0;
    }
    ram_642 += 1;
}
