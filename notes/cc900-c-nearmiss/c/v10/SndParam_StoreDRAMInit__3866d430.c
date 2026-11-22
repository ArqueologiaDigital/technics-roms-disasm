/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_33r1m303b.c (2026-11-22-19-p6-r86)
   sha256 3866d430ab1ab69170e8fc0b71f840cee596ba6bdc1ed7e661a64019273f1ec1 (tar-sha256); compiled at -O3 -Xr */
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
            i = 0;
            do
                *p++ = SeqBuf_VoiceMap_ReadByte();
            while (++i < 7);
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
