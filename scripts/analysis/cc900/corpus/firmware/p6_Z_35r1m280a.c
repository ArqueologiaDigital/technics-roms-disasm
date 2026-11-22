/* Probe round 35r1, helper Z, form a: audio/audio_control_engine.s (module 280), the xr_screen.py shape at -O3 -Xr.
   PanelVari_GetGroupSlot(part, idx): the companion byte idx of a part (0 when none).  A part 0-31 takes its
   group count from ApplyProgramChangeAs_DoLookupRe, the style part (72) has 15, any other part gives 0 at once;
   idx above the count gives 0.  The ROM places the rhythm branch after the return and jumps back: written with
   goto.  The companion pointer is a `register` local (it stays in XHL). */
/* cc900-module: PanelTlv_CompanionOfPart */

extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
extern unsigned char PanelVari_GetGroupSlot(unsigned char, unsigned char);

unsigned char PanelVari_GetGroupSlot(unsigned char part, unsigned char idx)
{
    unsigned char r;
    unsigned char n;
    register unsigned char *p;

    r = 0;
    if (part > 31)
        goto rhythm;
    n = ApplyProgramChangeAs_DoLookupRe();
join:
    if ((p = PanelTlv_CompanionOfPart(part)) != (unsigned char *)-1L && idx <= n)
        r = p[idx];
    return r;
rhythm:
    if (part != 72)
        return 0;
    n = 15;
    goto join;
}
