/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m277b.c (2026-11-22-23-p6-r90)
   sha256 54b562f3d296f5cf078f1209cdac6b1e17e35a355675636647966b6c2ebee147 (tar-sha256); compiled at -Xr */
extern unsigned int CPanel_RxEventQueue_Pop(void);
extern unsigned char PanelInput_EventIndexOfHeader(unsigned int);
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
