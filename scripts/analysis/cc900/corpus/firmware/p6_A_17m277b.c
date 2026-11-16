/* cc900-module: PanelTlv_ValidateBlock0 */
/* Phase 6, lane_p6 helper A, round 17, form b: module 277 (audio/tonegen_fileio_handlers.s),
   PanelTlv_ValidatePanelMemory, the offset computed first into a long local, then added to the base address. */
extern unsigned char ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    unsigned long o;
    unsigned char *p;
    if (n < 80) {
        o = (unsigned long)n * 960;
        p = ram_1ed400;
        p += o;
        PanelTlv_ValidateBlock0(p);
    }
}
