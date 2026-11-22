/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/

extern unsigned int SeqBuf_VoiceMap_ReadByte(void);
extern unsigned char SndParam_StoreDRAMInit(unsigned char id, unsigned int count, unsigned int limit, unsigned char *dst);

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
