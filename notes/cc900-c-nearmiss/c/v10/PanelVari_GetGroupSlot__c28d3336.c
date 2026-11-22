/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m280b.c (2026-11-22-23-p6-r90)
   sha256 c28d3336f5ad8a9d1e444002da538739d814fed0b2a372a6bc416feb49e094d9 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
unsigned char PanelVari_GetGroupSlot(unsigned char part, unsigned char idx)
{
    unsigned char r;
    unsigned char n;
    register unsigned char *p;

    r = 0;
    if (part <= 31)
        n = ApplyProgramChangeAs_DoLookupRe();
    else if (part == 72)
        n = 15;
    else
        return 0;
    if ((p = PanelTlv_CompanionOfPart(part)) != (unsigned char *)-1L) {
        if (idx <= n)
            r = p[idx];
    }
    return r;
}
