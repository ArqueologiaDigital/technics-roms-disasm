/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_8b.c (2026-11-16-82-sub-r8)
   sha256 d83228618a04eec7816bccc1d759faf828cc7db80cdfc2c451a244ea03ad84fa (name+funcs); compiled at -Xr */
extern unsigned char __near ram_4a42;
extern unsigned char __near ram_4a43;
extern unsigned char __near ram_4a44;
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned int Keybed_Read_Event(unsigned char *ev);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, void *buf);
void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (void *)&ram_4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (void *)&ram_4a42);
        }
    }
}
