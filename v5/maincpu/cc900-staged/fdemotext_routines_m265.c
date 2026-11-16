/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_CalcTextExtent FDemo_LinkedListSearchInsert */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void DemoDesc_BuildCompactParams(unsigned char *);
extern void sendCOMM(int, int, unsigned char *);
extern void VoiceEvent_FlushAndReturn(int, int);
extern void FDemoText_SendExtVoiceParams(unsigned char part);

void FDemoText_SendExtVoiceParams(unsigned char part)
{
    unsigned char msg[6];
    unsigned char params[10];
    unsigned char *p;
    unsigned char k;

    p = params;
    DemoDesc_BuildCompactParams(p);
    msg[0] = 0xb0;
    msg[1] = part;
    msg[2] = 0x78;
    msg[3] = 0;
    sendCOMM(0, 4, msg);
    msg[0] = 0x88;
    msg[1] = part;
    msg[3] = 0;
    msg[5] = 0;
    for (k = 11; k <= 12; k++) {
        msg[2] = k;
        msg[4] = *p;
        sendCOMM(0, 6, msg);
        p++;
    }
    for (k = 4; k <= 8; k++) {
        msg[2] = k;
        msg[4] = *p;
        sendCOMM(0, 6, msg);
        p++;
    }
    VoiceEvent_FlushAndReturn(0xff, part);
}
