/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_sepout_msg.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_sepout_msg.c.
   cc900-options: -Xr
   cc900-name: SepOut_SendPartMsg=HDAE5000_SeparateOutput_SendPartMsg
   cc900-module: HDAE5000_SeparateOutput_SendPartMsg HDAE5000_SeparateOutput_Apply
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 1 = HDAE5000_SeparateOutput_MsgTemplateA
   cc900-data: HDAE5000_SeparateOutput_SendPartMsg 2 = HDAE5000_SeparateOutput_MsgTemplateB
*/
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

/* the array's address, to char * */

/* the array's address, to unsigned char * */

/* control: the first element's address */
