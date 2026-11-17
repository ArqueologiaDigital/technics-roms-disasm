/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270_xr.c (2026-11-16-103-p6-r20-staged)
   sha256 96730dd534867762b2d6ea5cd4fab1a5efed5fcb89efcf798ac0eb2e771a6d58 (tar-sha256); compiled at -O3 -Xr
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
