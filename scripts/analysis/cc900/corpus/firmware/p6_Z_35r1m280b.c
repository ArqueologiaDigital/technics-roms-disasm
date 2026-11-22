/* Probe round 35r1, helper Z, form b: audio/audio_control_engine.s (module 280).  As form a, written as an
   if / else (the result declared before the count) and the companion test as a nested if. */
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
