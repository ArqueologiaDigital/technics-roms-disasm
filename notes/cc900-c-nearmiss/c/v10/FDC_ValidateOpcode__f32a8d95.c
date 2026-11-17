/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_10m270.c (2026-11-16-87-p6-r15)
   sha256 f32a8d95201755d7f7abe06028432dff4ce0eaed676e4bd869b52a53c2f4b125 (tar-sha256); compiled at -O3 -XS -Xr */
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
