/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned int Keybed_Read_Event(unsigned char *ev);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);

/* cc900-module: Keybed_Read_Event */
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
