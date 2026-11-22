/* Probe round 35r1, helper Z, form b: audio/audio_control_engine.s (module 277).  As form a, with gotos to the
   common return and the popped word as an unnamed call result. */
/* cc900-module: PanelInput_EventIndexOfHeader */

extern unsigned int CPanel_RxEventQueue_Pop(void);
extern unsigned char PanelInput_EventIndexOfHeader(unsigned int);
extern unsigned char PanelInput_ReadRxRecord(unsigned char *);

unsigned char PanelInput_ReadRxRecord(register unsigned char *rec)
{
    unsigned char r;
    register unsigned int v;

    r = 0xff;
    if ((v = CPanel_RxEventQueue_Pop()) == 0xffff)
        goto done;
    rec[0] = PanelInput_EventIndexOfHeader((unsigned char)v);
    if ((v = CPanel_RxEventQueue_Pop()) == 0xffff)
        goto done;
    rec[1] = (unsigned char)v;
    if ((v = CPanel_RxEventQueue_Pop()) == 0xffff)
        goto done;
    rec[2] = (unsigned char)v;
    r = 0;
done:
    return r;
}
