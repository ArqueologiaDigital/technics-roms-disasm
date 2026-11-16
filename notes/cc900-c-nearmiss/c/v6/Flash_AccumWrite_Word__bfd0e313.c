/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers.c (2026-11-16-55-p6-r10)
   sha256 bfd0e3133bebfcc5ff281e0beca2cca883c22f692506e95295fcea794dc731b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
typedef unsigned int *uip;
extern unsigned char __near ram_654;
extern unsigned char __near ram_62c[];
extern uip __near ram_656;
extern unsigned long __near ram_642;
void Flash_AccumWrite_Word(unsigned char a)
{
    ram_62c[ram_654] = a;
    if (ram_654++ == 1) {
        Flash_ProgramWord(1, ram_656++, *(unsigned int *)ram_62c);
        ram_654 = 0;
    }
    ram_642 += 1;
}
