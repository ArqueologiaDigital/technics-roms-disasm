/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m280b.c (2026-11-22-21-p6-r88)
   sha256 733cb071a09b85c8d70b920869be057edafe26446005fa8a43469196fa69563d (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
void PanelVari_SetGroupSlot(unsigned char part, unsigned char slot, unsigned char val)
{
    unsigned char n;
    unsigned char *p;

    if (part <= 0x1f) {
        n = ApplyProgramChangeAs_DoLookupRe();
look:
        p = PanelTlv_CompanionOfPart(part);
        if (p != (unsigned char *)0xffffffff && slot <= n)
            p[slot] = val;
    } else if (part == 0x48) {
        n = 0xf;
        goto look;
    }
}
