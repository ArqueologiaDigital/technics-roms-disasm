/* cc900-module: PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */
/* Phase 6, lane_p6 helper A, round 14, form a: module 277 (audio/tonegen_fileio_handlers.s).  Run 88 differed only
   in the base of the 80 panel memories: the ROM takes it with `lda XR,0x1ed400` (a large object's address), a
   constant pointer gives `ld`.  The images are now an extern array at that address. */
extern unsigned char ram_1ed400[];
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}

void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_ValidateBlock0(p);
}

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n < 80)
        PanelTlv_ValidateBlock0(ram_1ed400 + (unsigned long)n * 960);
}
