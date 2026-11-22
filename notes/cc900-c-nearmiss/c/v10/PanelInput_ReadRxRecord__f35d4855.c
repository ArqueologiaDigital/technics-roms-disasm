/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m277a.c (2026-11-22-23-p6-r90)
   sha256 f35d4855ea1bbc5047f4e6b0f9854f891fa50e103fe5cc2e1e6de336031138ac (tar-sha256); compiled at -Xr */
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
