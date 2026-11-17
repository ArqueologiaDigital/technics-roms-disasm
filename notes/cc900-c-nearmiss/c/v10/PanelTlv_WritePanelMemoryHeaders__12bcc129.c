/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m277a.c (2026-11-16-100-p6-r19)
   sha256 12bcc129e9e72cd8970262c9d7e1d6e11013a638f1f855567e0455a8971fee71 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char ram_1ed400[];
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}
