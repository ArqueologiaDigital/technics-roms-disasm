/* Phase 6, lane_p6 helper C, round 22, module 299 (modules_v10.tsv) of v10 audio/note_voice_mapping.s, form a:
   ProcessEventDispatch_Prologue (new, poolnew_C, 702 B, -Xr style).  Replays the sequencer event buffer from its
   saved read position: each status word is read by SeqEvtBuf_ReadAlternate until -1, then Song_SendPartDataBlocks.
   0xc1 / 0xc2: two data words; the part (low nibble through Rhythm_EventMapB) gets controller 0 = the first word
   (bit 7 set when the second word's bit 4 is), 0x20 = the second, 0x5e = 0, each through SndPart_SetParam and
   SndParam_NotifyAndReturn (fourth argument 3, on the stack).  0xd0: data 3, 0 resets parts 0x17 with controllers
   1, 0x1b0 (0x2000), 0x40, 0x0b (0x7f).  0xd1 / 0xd2: a controller kind 1..7 (jump table SeqEvtBuf_SwitchOffsets;
   6 is ignored) and a value: 1, the pitch bend 0x1b0 (value * 128, plus 2 * value - 128 above 64), damper 0x40,
   pan 0x0a, expression 0x0b, delay send 0x5e.
   The status and the two data words live on the stack (+4 / +6 / +8), the kind and value of 0xd0..0xd2 in QIZ / IZ.
   Form b (p6_C_22m299b.c): without `register`, and the pitch-bend value cast where the ROM moves it through BC. */
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
    register int x;
    register int y;
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
                SndParam_NotifyAndReturn(a, 0x1b0, y, 3);
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
