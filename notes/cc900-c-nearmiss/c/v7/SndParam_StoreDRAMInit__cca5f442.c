/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m303_xs.c (2026-11-22-20-p6-r87)
   sha256 cca5f44202796b7aa3853e243a11c1cc13d22a1b53c15d55f47daa87f166c6a0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -XS -Xr */
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
