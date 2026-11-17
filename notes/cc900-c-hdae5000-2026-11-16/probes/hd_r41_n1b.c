/* lane_hd round 41, helper h_n1, file b: HDAE5000_SeparateOutput_SendPartMsg (SEPARATE OUTPUT module; the other
   functions of the module are matched, hdae5000/cc900-staged/hdae5000_sepout.c, and only declared here), with four
   variants.
   cc900-options: -Xr
   cc900-module: HDAE5000_SeparateOutput_SendPartMsg HDAE5000_SeparateOutput_Apply
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutMsg_v=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutMsg_s=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutMsg_u=HDAE5000_SeparateOutput_SendPartMsg
   cc900-name: SepOutMsg_e=HDAE5000_SeparateOutput_SendPartMsg
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 1 = HDAE5000_SeparateOutput_MsgTemplateA
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 2 = HDAE5000_SeparateOutput_MsgTemplateB
   Run 2026-11-17-10-hd-r39 (hd_r39_m4a.c): every instruction is the ROM's except the message address of the two
   sendCOMM calls: V4.23 took the array's address straight into XDE, the ROM takes it into XWA and copies it to XDE.
   That is the mark of a CONVERTED argument (as `(char *)&info3` of the song loaders, which gives the same pair for
   XBC).  So the two arrays are passed through a cast:
     main (SepOut_SendPartMsg): (char *)a
     SepOutMsg_v: (void *)a
     SepOutMsg_s: (char *)&a          (the address of the whole array, converted)
     SepOutMsg_u: (unsigned char *)&a (the same, to the element type)
     SepOutMsg_e: &a[0]               (a control: no conversion)
   Unsure: which of the conversions V4.23 counts as one for an array that decays to a pointer. */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void HDAE5000_SeparateOutput_Apply(void);

/* send the two 4-byte messages (templates b0 pp 9b xx / b0 pp 9d xx) for one part: bank 0 / 1 -> 0x01 / 0x20,
   mode 0..2 as it is */
void SepOut_SendPartMsg(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, (char *)a);
        CALLV(HAMA->sendCOMM)(0, 4, (char *)b);
    }
}

/* to void * */
void SepOutMsg_v(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, (void *)a);
        CALLV(HAMA->sendCOMM)(0, 4, (void *)b);
    }
}

/* the array's address, to char * */
void SepOutMsg_s(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, (char *)&a);
        CALLV(HAMA->sendCOMM)(0, 4, (char *)&b);
    }
}

/* the array's address, to unsigned char * */
void SepOutMsg_u(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, (unsigned char *)&a);
        CALLV(HAMA->sendCOMM)(0, 4, (unsigned char *)&b);
    }
}

/* control: the first element's address */
void SepOutMsg_e(unsigned char part, unsigned char bank, unsigned char mode)
{
    unsigned char a[4] = { 0xb0, 0, 0x9b, 0 };
    unsigned char b[4] = { 0xb0, 0, 0x9d, 0 };

    if (part < 16 && bank <= 1 && mode <= 2) {
        a[1] = part;
        b[1] = part;
        if (bank == 0)
            a[3] = 0x01;
        else
            a[3] = 0x20;
        if (mode == 0)
            b[3] = 0;
        else if (mode == 1)
            b[3] = 1;
        else
            b[3] = 2;
        CALLV(HAMA->sendCOMM)(0, 4, &a[0]);
        CALLV(HAMA->sendCOMM)(0, 4, &b[0]);
    }
}
