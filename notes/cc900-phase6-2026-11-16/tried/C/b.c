void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2] & 0x7f;
    ((struct l7 *)(d + 10))->v = t;
    t = s[3] & 0x7f;
    ((struct l7 *)(d + 11))->v = t;
    t = s[4] & 0x7f;
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = s[6] & 0x7f;
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}

void VoiceParam_CopyFields_TypeD(unsigned char *s, unsigned char *d)
{
    ((struct l2 *)(d + 2))->v = ((struct l2 *)(s + 2))->v;
    d[4] = s[3];
    ((struct l4 *)(d + 6))->v = ((struct l4 *)(s + 5))->v;
    ((struct l7 *)(d + 3))->v = s[17];
}

int Seq_CheckSongEnd(void)
{
    int r = SEQMAIN_WRITE_POS;
    if (r == SEQMAIN_READ_POS) r = 0;
    else r = -1;
    return r;
}

int TempoRingBuf_CheckEmpty(void)
{
    int r = ram_1e74f;
    if (r == ram_1e74b) r = 0;
    else r = -1;
    return r;
}

int SeqBuf_NoteEvent_CheckSongEnd(void)
{
    int r = ram_204db;
    if (r == ram_204d7) r = 0;
    else r = -1;
    return r;
}

int SeqBuf_DspSysEx_CheckSongEnd(void)
{
    int r = ram_1fc9f;
    if (r == ram_1fc9b) r = 0;
    else r = -1;
    return r;
}

int RhythmBuf_CheckEmpty(void)
{
    int r = ram_1ef59;
    if (r == ram_1ef55) r = 0;
    else r = -1;
    return r;
}

int SeqBuf_MidiOut_CheckEmpty(void)
{
    int r = ram_1f781;
    if (r == ram_1f77d) r = 0;
    else r = -1;
    return r;
}

unsigned int TempoRingBuf_BytecodeSnippet2(void) { return ram_1e751; }
unsigned int SeqBuf_NoteEvent_OrphanData(void) { return ram_204dd; }
unsigned int SeqBuf_DspSysEx_OrphanData(void) { return ram_1fca1; }
unsigned int RhythmBuf_BytecodeSnippet(void) { return ram_1ef5b; }

void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d = 0;
    unsigned char *p;
    do d++; while (d < 0x80);
    p = (unsigned char *)0x170000;
    p[r] = v;
}

unsigned char *Demo_GetPresetBaseForPartAlt(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 768;
}

int FileIO_SearchFile(char *a, char *b)
{
    char c;
    for (;;) {
        c = *a;
        if (*b != c) break;
        if (c == 0) return 0;
        a++;
        b++;
    }
    c = *a - *b;
    return c;
}

unsigned int FileIO_GetRecordFlags(unsigned int i)
{
    if (i < 20) return ((struct frec *)ram_25db8)[i].w[0];
    return 0;
}

void SqStep_SetPopupIdForDisplayMode(void)
{
    unsigned char *t = PortConfig_Handler_0_Tbl;
    STATUS_POPUP_ID = t[SQSTEP_DISPLAY_MODE & 3];
}

void Demo_WaitForDisplayBit(void)
{
    unsigned long n = 0xffffff;
    if (PLAY_TRANSPORT_STATE & 4) do {
        if (!--n) return;
    } while (PLAY_TRANSPORT_STATE & 4);
}

void OscScope_Handler_2_Helper(void)
{
    unsigned char *p = ram_1114 + (unsigned char)(ram_ec4 * 4);
    *p &= 0xdf;
    *p |= 0x40;
}

unsigned char FileIO_CheckRecordValid(unsigned char a)
{
    unsigned int m;
    int i;
    i = ram_25ea8;
    if (i < 0 || i >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (unsigned char)((*(unsigned int *)((unsigned char *)ram_25db8 + i * 12) & m) == m);
}

unsigned char FileIO_CheckRecordByFile(unsigned int i, unsigned char b)
{
    unsigned int m;
    if (i >= 20 || b >= 10) return 0;
    m = 1;
    m <<= b;
    return (unsigned char)((((struct frec *)ram_25db8)[i].w[0] & m) == m);
}

unsigned char FileIO_WriteRecordName_Done(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = (unsigned int)1 << a;
    return (unsigned char)((ram_272cc & m) == m);
}

unsigned char FileIO_FormatName_Return(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = (unsigned int)1 << a;
    return (unsigned char)((ram_272ce & m) == m);
}

void VoiceParam_CopyBitfields_TypeC(unsigned char *s, unsigned char *d)
{
    ((struct b10 *)(d + 2))->b0 = ((struct b10 *)(s + 2))->b0;
    ((struct b10 *)(d + 2))->b1 = ((struct b10 *)(s + 2))->b1;
    ((struct b10 *)(d + 3))->b1 = ((struct b10 *)(s + 3))->b1;
    ((struct b10 *)(d + 5))->b0 = ((struct b10 *)(s + 7))->b0;
    ((struct b10 *)(d + 5))->b1 = ((struct b10 *)(s + 7))->b1;
}

void DataBuf_CopyEQBlock7(unsigned char *s, unsigned char *d)
{
    ((struct eq2 *)(d + 2))->f54 = ((struct eq2 *)(s + 2))->f54;
    ((struct eq2 *)(d + 2))->b3 = ((struct eq2 *)(s + 2))->b3;
    ((struct eq2 *)(d + 2))->b2 = ((struct eq2 *)(s + 2))->b2;
    ((struct eq2 *)(d + 2))->l = ((struct eq2 *)(s + 2))->l;
    ((struct l7 *)(d + 3))->v = ((struct l7 *)(s + 3))->v;
    d[4] = s[4];
    ((struct l4 *)(d + 6))->v = ((struct l4 *)(s + 6))->v;
    if (ram_b7ea == 2) d[5] = s[5];
}

void DataBuf_CopyReverbBlock6(unsigned char *s, unsigned char *d)
{
    ((struct r8 *)(d + 2))->b1 = ((struct r8 *)(s + 2))->b1;
    ((struct r8 *)(d + 2))->b0 = ((struct r8 *)(s + 2))->b0;
    ((struct r8 *)(d + 3))->b1 = ((struct r8 *)(s + 3))->b1;
    ((struct r8 *)(d + 4))->b6 = ((struct r8 *)(s + 4))->b6;
    ((struct r8 *)(d + 4))->b5 = ((struct r8 *)(s + 4))->b5;
    ((struct r8 *)(d + 4))->b4 = ((struct r8 *)(s + 4))->b4;
    ((struct r8 *)(d + 4))->b3 = ((struct r8 *)(s + 4))->b3;
    ((struct r8 *)(d + 4))->b2 = ((struct r8 *)(s + 4))->b2;
    ((struct r8 *)(d + 4))->b1 = ((struct r8 *)(s + 4))->b1;
    ((struct r8 *)(d + 4))->b0 = ((struct r8 *)(s + 4))->b0;
    ((struct r8 *)(d + 5))->b1 = ((struct r8 *)(s + 5))->b1;
    ((struct r8 *)(d + 5))->b0 = ((struct r8 *)(s + 5))->b0;
}

void VoiceParam_CopyBitfields_TypeA(unsigned char *s, unsigned char *d)
{
    d[2] = s[2];
    ((struct l7 *)(d + 3))->v = ((struct a6 *)(s + 6))->lo;
    ((struct l7 *)(d + 5))->v = ((struct l7 *)(s + 3))->v;
    ((struct a4 *)(d + 6))->b7 = ((struct a4 *)(s + 4))->b7;
    ((struct a4 *)(d + 6))->b6 = ((struct a4 *)(s + 4))->b6;
    ((struct a4 *)(d + 6))->b3 = ((struct a4 *)(s + 4))->b3;
    ((struct a4 *)(d + 6))->lo = ((struct a4 *)(s + 4))->lo;
    if (((struct a4 *)(s + 4))->b5) ((struct l7 *)(d + 7))->v = 0x50;
    else ((struct l7 *)(d + 7))->v = 0;
    if (((struct l7 *)(s + 5))->h) ((struct l7 *)(d + 9))->v = 0x5a;
    else ((struct l7 *)(d + 9))->v = 0;
    ((struct a6 *)(d + 14))->b5 = ((struct a6 *)(s + 9))->b5;
    ((struct l7 *)(d + 16))->v = ((struct l7 *)(s + 8))->v;
    ((struct l7 *)(d + 16))->h = ((struct l7 *)(s + 8))->h;
    d[17] = s[11];
    ((struct a6 *)(d + 15))->b6 = ((struct a6 *)(s + 6))->b6;
    ((struct a6 *)(d + 15))->b5 = ((struct a6 *)(s + 6))->b5;
}
