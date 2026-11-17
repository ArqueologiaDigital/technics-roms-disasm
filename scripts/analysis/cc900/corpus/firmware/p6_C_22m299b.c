/* Phase 6, lane_p6 helper C, round 22, module 299 (modules_v10.tsv) of v10 audio/note_voice_mapping.s, form b of
   ProcessEventDispatch_Prologue (form a, p6_C_22m299a.c, describes it): the kind and value locals without
   `register`, and the pitch-bend value passed to SndParam_NotifyAndReturn with an unsigned cast (the ROM moves it
   IZ -> BC -> DE there, where the other calls take IZ -> DE). */
/* cc900-data: ProcessEventDispatch_Prologue 1 = SeqEvtBuf_SwitchOffsets */

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
        a = SeqEvtBuf_ReadAlternate();
        if (a == -1) break;
        switch (a) {
        case 0xc1:
        case 0xc2:
            b = SeqEvtBuf_ReadAlternate();
            if (b == -1) continue;
            c = SeqEvtBuf_ReadAlternate();
            if (c == -1) continue;
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
            x = SeqEvtBuf_ReadAlternate();
            if (x == -1) continue;
            y = SeqEvtBuf_ReadAlternate();
            if (y == -1) continue;
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
            x = SeqEvtBuf_ReadAlternate();
            if (x == -1) continue;
            y = SeqEvtBuf_ReadAlternate();
            if (y == -1) continue;
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
