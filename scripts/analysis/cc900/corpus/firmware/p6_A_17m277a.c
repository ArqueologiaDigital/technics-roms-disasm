/* cc900-module: PanelTlv_ValidateBlock0 */
/* Phase 6, lane_p6 helper A, round 17, form a: module 277 (audio/tonegen_fileio_handlers.s),
   PanelTlv_ValidatePanelMemory.  Run 100: passing `base + n * 960` straight to the call made V4.23 load the base
   with `ld` (a converted pointer); the ROM has `lda`, so the address goes through a pointer local. */
extern unsigned char ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    unsigned char *p;
    if (n < 80) {
        p = ram_1ed400 + (unsigned long)n * 960;
        PanelTlv_ValidateBlock0(p);
    }
}
