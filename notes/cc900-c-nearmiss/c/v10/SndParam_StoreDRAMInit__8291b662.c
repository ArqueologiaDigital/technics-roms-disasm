/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_33r1m303a.c (2026-11-22-19-p6-r86)
   sha256 8291b662566b97922be49d1138ceb077357e35f1cb8469c735f0f8fe160663b6 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int SeqBuf_VoiceMap_ReadByte(void);
unsigned char SndParam_StoreDRAMInit(unsigned char id, unsigned int count, unsigned int limit, unsigned char *dst)
{
    long k;
    unsigned char r;
    unsigned char *p;
    unsigned char buf[288];
    register unsigned int i;

    r = 0xff;
    k = 0;
    while (k < limit) {
        if (SeqBuf_VoiceMap_ReadByte() != 0xffff) {
            p = buf;
            p++;
            for (i = 0; i < 7; i++)
                *p++ = SeqBuf_VoiceMap_ReadByte();
            if (buf[7] == id) {
                buf[0] = 0;
                for (i = 0; i < count; i++)
                    *dst++ = SeqBuf_VoiceMap_ReadByte();
                r = 0;
                break;
            }
        }
        k++;
        if (k >= 0xe00)
            break;
    }
    return r;
}
