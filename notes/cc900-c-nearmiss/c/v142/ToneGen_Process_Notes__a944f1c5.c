/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14a.c (2026-11-16-101-sub-r14)
   sha256 a944f1c52415e6e1c03fb4623e52d68614c4bd36f48256be4e7ae26f3d432bdd (name+funcs); compiled at -Xr */
extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
struct nmsg { unsigned char b[3]; };
extern unsigned int Keybed_Read_Event(unsigned char *ev);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);
void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)&*(struct nmsg *)0x4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)&*(struct nmsg *)0x4a42);
        }
    }
}
