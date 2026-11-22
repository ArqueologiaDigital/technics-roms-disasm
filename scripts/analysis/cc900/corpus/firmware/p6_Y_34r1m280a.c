/* Probe round 34r1, helper Y, form a: audio/audio_control_engine.s (module 280), unoptimised -Xr shape (all three
   char parameters stored to the frame, no register saves).
   PanelVari_SetGroupSlot(part, slot, val): the slot count is ApplyProgramChangeAs_DoLookupRe's for parts 0..0x1f
   and 15 for part 0x48 (other parts: nothing); write val to byte `slot` of the part's companion record when it
   has one (not -1) and slot is within the count.  The record pointer is a `register` local, which the
   unoptimised compiler keeps in the scratch XHL because it is not live across a call; the 0x48 branch re-enters
   the shared lookup with a goto, as the ROM's jump back. */
/* cc900-module: PanelTlv_CompanionOfPart */

extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern unsigned char *PanelTlv_CompanionOfPart(unsigned int);
extern void PanelVari_SetGroupSlot(unsigned char, unsigned char, unsigned char);

void PanelVari_SetGroupSlot(unsigned char part, unsigned char slot, unsigned char val)
{
    unsigned char n;
    register unsigned char *p;

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
