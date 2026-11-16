/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
extern void PanelTlv_ValidatePanelMemories(void);
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_WritePanelMemoryHeaders(void);

void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_ValidateBlock0(p);
}

void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}
