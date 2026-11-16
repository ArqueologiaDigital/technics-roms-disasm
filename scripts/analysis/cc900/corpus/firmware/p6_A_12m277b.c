/* cc900-module: PanelTlv_ApplyFieldRule PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */
/* Phase 6, lane_p6 helper A, round 12, form b: module 277 of modules_v10.tsv (audio/tonegen_fileio_handlers.s), the
   panel-memory TLV validation loops (for loops; an early return in PanelTlv_ValidatePanelMemory). */
struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base = base + (l->off + 2);
    for (r = l->rules; *r != 0xff; r += PanelTlv_ApplyFieldRule(base, r))
        ;
}

void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = (unsigned char *)0x1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}

void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = (unsigned char *)0x1ed400; i < 80; i++, p += 960)
        PanelTlv_ValidateBlock0(p);
}

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n >= 80)
        return;
    PanelTlv_ValidateBlock0((unsigned char *)0x1ed400 + (unsigned long)n * 960);
}
