/* cc900-module: PanelTlv_ApplyFieldRule PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */
/* Phase 6, lane_p6 helper A, round 12, form a: module 277 of modules_v10.tsv (audio/tonegen_fileio_handlers.s), the
   panel-memory TLV validation loops.  The 80 panel memories are 960-byte images at RAM 0x1ed400. */
struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_ValidateBlock0(unsigned char *mem);

void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base += l->off + 2;
    r = l->rules;
    while (*r != 0xff)
        r += PanelTlv_ApplyFieldRule(base, r);
}

void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    i = 0;
    p = (unsigned char *)0x1ed400;
    do {
        PanelTlv_WriteBlock0Headers(p);
        i++;
        p += 960;
    } while (i < 80);
}

void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    i = 0;
    p = (unsigned char *)0x1ed400;
    do {
        PanelTlv_ValidateBlock0(p);
        i++;
        p += 960;
    } while (i < 80);
}

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n < 80)
        PanelTlv_ValidateBlock0((unsigned char *)0x1ed400 + (unsigned long)n * 960);
}
