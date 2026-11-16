/* cc900-module: PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */
/* Phase 6, lane_p6 helper A, round 14, form b: module 277 (audio/tonegen_fileio_handlers.s), the panel memories as an
   extern array of 960-byte images at 0x1ed400. */
struct pmem { unsigned char b[960]; };
extern struct pmem ram_1ed400[];
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    struct pmem *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p++)
        PanelTlv_WriteBlock0Headers(p->b);
}

void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    struct pmem *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p++)
        PanelTlv_ValidateBlock0(p->b);
}

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n < 80)
        PanelTlv_ValidateBlock0(ram_1ed400[n].b);
}
