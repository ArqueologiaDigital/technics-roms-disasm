/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m233a.c (2026-11-22-15-p6-r82)
   sha256 6e76d8fd721c6bb21fcea78dce5838a50eddfedfb56ad01cb08507b0589d89d7 (tar-sha256); compiled at -O3 -Xr */
struct bo { unsigned int block; unsigned int offset; };
struct cnt { unsigned int whole; unsigned int rest; };
extern struct bo __near ram_24fc;
extern struct bo __near ram_2424;
extern unsigned char __near ram_23c2;
extern void SeqCh_LoadChannelConfig(unsigned int);
extern int SeqEvent_GetParamLength(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
void SeqCh_CountEventsAndCalcPos(struct cnt *r)
{
    struct bo t;
    unsigned int sum;
    int len;

    r->whole = 0;
    sum = 0;
    t = ram_24fc;
    ram_2424 = t;
    for (;;) {
        SeqCh_LoadChannelConfig(0x12);
        if (ram_23c2 == 0x82) break;
        len = SeqEvent_GetParamLength(ram_23c2);
        if (len < 0) {
            SeqData_SetErrorCode(7);
            continue;
        }
        sum += len;
        if (sum >= 0xfb) {
            sum -= 0xfb;
            r->whole++;
        }
    }
    r->rest = (unsigned char)(sum & 0xff);
}
