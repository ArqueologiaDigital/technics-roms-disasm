/* Probe round 35r1, helper Z, form a: audio/audio_control_engine.s (module 277), the xr_screen.py shape at -O3 -Xr.
   PanelInput_ReadRxRecord(rec): pop a 3-byte record from the panel receive queue into rec (the header byte
   translated to its event index); 0 when all three bytes came, 0xff when the queue ran dry.  rec is a `register`
   parameter (XIZ), the popped word a `register` local (HL, never live across a call). */
/* cc900-module: PanelInput_EventIndexOfHeader */

extern unsigned int CPanel_RxEventQueue_Pop(void);
extern unsigned char PanelInput_EventIndexOfHeader(unsigned int);
extern unsigned char PanelInput_ReadRxRecord(unsigned char *);

unsigned char PanelInput_ReadRxRecord(register unsigned char *rec)
{
    unsigned char r;
    register unsigned int v;

    r = 0xff;
    if ((v = CPanel_RxEventQueue_Pop()) != 0xffff) {
        rec[0] = PanelInput_EventIndexOfHeader((unsigned char)v);
        if ((v = CPanel_RxEventQueue_Pop()) != 0xffff) {
            rec[1] = v;
            if ((v = CPanel_RxEventQueue_Pop()) != 0xffff) {
                rec[2] = v;
                r = 0;
            }
        }
    }
    return r;
}
