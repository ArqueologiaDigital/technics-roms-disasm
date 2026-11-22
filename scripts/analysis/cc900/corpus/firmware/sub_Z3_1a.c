/* Probe round Z3-1 (lane_z3, feedback plan step Z3, the djnz pool), form a: sub-CPU v1.42 routines holding a djnz
   that read as compiled C.  DSP_WriteCount_Compute (core/11_ringbuf_and_midi_dispatch.s; the pool row is its loop
   label DSP_WriteCount_Loop): the DSP1 image's checksum, ~(sum of 0x4970 / 2 words from image + 16), with the
   halving left unfolded as in the ROM.  DSP_FillMemWords (core/02_audio_system_init.s): n words of v from p. */

extern unsigned char *ram_4531c;

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int n;
    unsigned int *p;
    unsigned int s;

    n = 0x4970;
    n >>= 1;
    p = (unsigned int *)(ram_4531c + 16);
    s = 0;
    for (; n != 0; n--)
        s += *p++;
    return ~s;
}

void DSP_FillMemWords(unsigned int *p, unsigned int v, unsigned int n)
{
    do
        *p++ = v;
    while (--n != 0);
}
