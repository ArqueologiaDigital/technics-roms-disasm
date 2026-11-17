/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern unsigned long __near ram_1040;
extern unsigned char ram_41481[];
extern unsigned char ram_41485[];
extern unsigned char ram_41486[];
void Voice_Env_UpdateVelocityCounters(unsigned char a)
{
    unsigned long d;
    if ((d = ram_1040 - *(unsigned long *)&ram_41481[a * 287]) != 0) {
        if (d < 0x19) {
            switch (++*(ram_41485 + a * 287)) {
            case 0: ram_41486[a * 287] = 0; break;
            case 1: ram_41486[a * 287] = 0x10; break;
            default: ram_41486[a * 287] = 0x20; break;
            }
        } else {
            ram_41485[a * 287] = 0;
            ram_41486[a * 287] = 0;
        }
    }
    *(unsigned long *)&ram_41481[a * 287] = ram_1040;
}
