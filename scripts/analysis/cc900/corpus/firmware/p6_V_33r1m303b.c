/* Probe round 33r1, helper V, form b (the 7-byte header read as a do-while: the ROM has no entry test there): audio/note_voice_mapping.s (module 303), -Xr code.
   SndParam_StoreDRAMInit(id, count, limit, dst): scan the voice-map byte stream (SeqBuf_VoiceMap_ReadByte, 0xffff =
   no byte) for up to `limit` (at most 0xe00) records; a record is a lead byte and a 7-byte header whose last byte is
   the record id.  When the id matches, copy the next `count` bytes to dst and return 0; return 0xff when not found. */

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
