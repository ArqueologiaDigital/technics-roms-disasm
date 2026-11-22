/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m277.c (2026-11-22-24-p6-r91)
   sha256 5cebb92443eb5d76289d6fceca5c25c1a2e2dc7faed6c0723db10240fea48902 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int CPanel_RxEventQueue_Pop(void);
extern unsigned char PanelInput_EventIndexOfHeader(unsigned int);
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
