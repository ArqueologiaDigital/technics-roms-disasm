/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m277.c (2026-11-16-92-p6-r18)
   sha256 e99b4bacf59febb81db71da15247b5269061619da4b94a2080f83be8f542372f (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base += l->off + 2;
    r = l->rules;
    while (*r != 0xff)
        r += PanelTlv_ApplyFieldRule(base, r);
}
