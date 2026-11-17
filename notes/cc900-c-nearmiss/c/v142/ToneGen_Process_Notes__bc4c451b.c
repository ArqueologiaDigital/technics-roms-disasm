/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14b.c (2026-11-16-101-sub-r14)
   sha256 bc4c451bbb9fb863ec20e0cf12e808971bf6d9c87b958c7ad339bfeaa5661dac (name+funcs); compiled at -Xr */
extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned int Keybed_Read_Event(unsigned char *ev);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);
void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];
    unsigned char *m;

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1) {
                m = (unsigned char *)0x4a42;
                InterCPU_DMA_Send(2, 3, m);
            }
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1) {
                m = (unsigned char *)0x4a42;
                InterCPU_DMA_Send(2, 3, m);
            }
        }
    }
}
