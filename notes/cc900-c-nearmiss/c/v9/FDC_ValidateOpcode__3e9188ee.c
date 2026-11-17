/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 3e9188eed62442c58d0c6969f393a850b7486e4c21c50feb61ec7d3778567f9a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near FDC_CMD_OPCODE;
unsigned char FDC_ValidateOpcode()
{
    unsigned char t;
    switch (FDC_CMD_OPCODE) {
    case 53:
    case 71:
    case 52:
    case 51:
    case 79:
        return 0;
    default:
        t = FDC_CMD_OPCODE & 31;
        if (t == 30 || t == 29 || t == 25 || (t != 16 && (t == 17 || (t <= 15 && t >= 2)))) return 0;
        return 1;
    }
}
