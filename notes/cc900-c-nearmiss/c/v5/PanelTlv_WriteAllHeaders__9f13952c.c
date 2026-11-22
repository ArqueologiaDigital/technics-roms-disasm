/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/tonegen_fileio_handlers_m277_xs.c (2026-11-22-3-p6-r71)
   sha256 9f13952c12a6705d7c2f2496667759e420f2678d6fd70d748a39ba038ca8fe01 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -XS -Xr
   cc900-name: PanelTlv_WritePMemHeaders=PanelTlv_WritePanelMemoryHeaders */
extern void PanelTlv_WriteLivePanelHeaders(void);
extern void PanelTlv_WritePMemHeaders(void);
void PanelTlv_WriteAllHeaders(void)
{
  PanelTlv_WriteLivePanelHeaders();
  PanelTlv_WritePMemHeaders();
}
