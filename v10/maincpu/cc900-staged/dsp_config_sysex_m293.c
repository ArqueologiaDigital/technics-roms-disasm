/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DSPCfg_GetSlotCount DSPCfg_PackAddress */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_GetSlotCount(int fx);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern int DSPCfg_FindSlot63(int fx);

int DSPCfg_FindSlot63(int fx)
{
    int r;
    int n;
    int i;
    unsigned char *p;

    r = -1;
    n = DSPCfg_GetSlotCount(fx);
    p = DspFxRecListPtrTable[fx];
    for (i = 0; i < n; i++) {
        if (p[2] == 0x63)
            r = i;
        p = DSPCfg_PackAddress(p);
    }
    return r;
}
