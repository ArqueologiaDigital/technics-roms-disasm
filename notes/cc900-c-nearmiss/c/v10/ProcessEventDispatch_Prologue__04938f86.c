/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_23m299a.c (2026-11-18-1-p6-r33)
   sha256 04938f86d9758aa51ad4ad103ae99b1044b37bb4893eed994556ece22b8b9fcf (tar-sha256); compiled at -Xr */
extern unsigned char Rhythm_EventMapB[];
extern void SeqEvtBuf_SaveReadPos(void);
extern int SeqEvtBuf_ReadAlternate(void);
extern void SndPart_SetParam(int, int, int);
extern void SndParam_NotifyAndReturn(int, int, int, int);
extern void Song_SendPartDataBlocks(void);
void ProcessEventDispatch_Prologue(void)
{
    int a, b, c;
    int x, y;
    int w;
    y = 0;
    SeqEvtBuf_SaveReadPos();
    for (;;) {
        if ((a = SeqEvtBuf_ReadAlternate()) == -1) break;
        switch (a) {
        case 0xc1:
        case 0xc2:
            if ((b = SeqEvtBuf_ReadAlternate()) == -1) continue;
            if ((c = SeqEvtBuf_ReadAlternate()) == -1) continue;
            a = Rhythm_EventMapB[a & 0xf];
            if (c & 0x10) {
                c &= ~0x10;
                b |= 0x80;
            }
            SndPart_SetParam(a, 0, b);
            SndPart_SetParam(a, 0x20, c);
            SndPart_SetParam(a, 0x5e, 0);
            SndParam_NotifyAndReturn(a, 0, b, 3);
            SndParam_NotifyAndReturn(a, 0x20, c, 3);
            SndParam_NotifyAndReturn(a, 0x5e, 0, 3);
            break;
        case 0xd0:
            if ((x = SeqEvtBuf_ReadAlternate()) == -1) continue;
            if ((y = SeqEvtBuf_ReadAlternate()) == -1) continue;
            if (x != 3) continue;
            if (y != 0) continue;
            for (c = 0x17; c < 0x18; c++) {
                SndPart_SetParam(c, 1, 0);
                SndPart_SetParam(c, 0x1b0, 0x2000);
                SndPart_SetParam(c, 0x40, 0);
                SndPart_SetParam(c, 0x0b, 0x7f);
                SndParam_NotifyAndReturn(c, 1, 0, 3);
                SndParam_NotifyAndReturn(c, 0x1b0, 0x2000, 3);
                SndParam_NotifyAndReturn(c, 0x40, 0, 3);
                SndParam_NotifyAndReturn(c, 0x0b, 0x7f, 3);
            }
            break;
        case 0xd1:
        case 0xd2:
            if ((x = SeqEvtBuf_ReadAlternate()) == -1) continue;
            if ((y = SeqEvtBuf_ReadAlternate()) == -1) continue;
            a = Rhythm_EventMapB[a & 0xf];
            switch (x) {
            case 1:
                SndPart_SetParam(a, 1, y);
                SndParam_NotifyAndReturn(a, 1, y, 3);
                break;
            case 2:
                w = 0;
                if (y >= 0x40) w = y * 2 - 0x80;
                y = (y << 7) | w;
                SndPart_SetParam(a, 0x1b0, y);
                SndParam_NotifyAndReturn(a, 0x1b0, (unsigned int)y, 3);
                break;
            case 3:
                SndPart_SetParam(a, 0x40, y);
                SndParam_NotifyAndReturn(a, 0x40, y, 3);
                break;
            case 4:
                SndPart_SetParam(a, 0x0a, y);
                SndParam_NotifyAndReturn(a, 0x0a, y, 3);
                break;
            case 5:
                SndPart_SetParam(a, 0x0b, y);
                SndParam_NotifyAndReturn(a, 0x0b, y, 3);
                break;
            case 7:
                SndPart_SetParam(a, 0x5e, y);
                SndParam_NotifyAndReturn(a, 0x5e, y, 3);
                break;
            }
            break;
        default:
            break;
        }
    }
    Song_SendPartDataBlocks();
}
