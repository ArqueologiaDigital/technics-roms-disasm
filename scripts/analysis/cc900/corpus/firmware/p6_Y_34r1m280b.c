/* Probe round 34r1, helper Y, form b: audio/audio_control_engine.s (module 280).
   As form a (PanelVari_SetGroupSlot), with one spot changed: the record pointer is a plain auto (no `register`). */
/* cc900-module: PanelTlv_CompanionOfPart */

extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
extern void PanelVari_SetGroupSlot(unsigned char, unsigned char, unsigned char);

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
