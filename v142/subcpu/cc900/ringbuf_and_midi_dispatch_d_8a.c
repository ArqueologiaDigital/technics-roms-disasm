/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __near ram_2ae8[];
extern unsigned char __near ram_2aee[];
extern unsigned char __near ram_2af4[];
extern unsigned char __near ram_2af8[];
extern unsigned char __near ram_2afc[];
extern unsigned char __near ram_2b01[];
extern unsigned char __near ram_2b05[];
extern unsigned char __near ram_2b09[];
extern int RingBuf_ReadByte(struct ring4k *);
extern void RingBuf_SkipToEnd(struct ring4k *);
extern void MIDI_Backlog_Publish(unsigned int);
extern void Voice_ParamFinalize(unsigned char *);
extern void Voice_NoteOn(unsigned char *);
extern void Voice_Poly_NoteOn(unsigned char *);
extern void Voice_CtrlChange(unsigned char *);
extern void Voice_ProgChange(unsigned char *);
extern void Voice_ChanPressure(unsigned char *);
extern void Voice_PitchBend(unsigned char *);
extern void Voice_SystemMsg(unsigned char *);

/* cc900-module: RingBuf_ReadByte RingBuf_SkipToEnd */
void MIDI_Dispatch(void)
{
    struct ring4k *r;
    int c;

    r = &MIDI_RingBuffer;
    MIDI_Backlog_Publish(r->n);
    while ((c = RingBuf_ReadByte(r)) >= 0) {
        switch (c & 0xf0) {
        case 0x80:
            if (r->n >= 5) {
                if ((c & 8) == 0) {
                    ram_2ae8[0] = c;
                    ram_2ae8[1] = RingBuf_ReadByte(r);
                    ram_2ae8[2] = RingBuf_ReadByte(r);
                    ram_2ae8[3] = RingBuf_ReadByte(r);
                    ram_2ae8[4] = RingBuf_ReadByte(r);
                    ram_2ae8[5] = RingBuf_ReadByte(r);
                    Voice_ParamFinalize(ram_2ae8);
                } else {
                    ram_2aee[0] = c;
                    ram_2aee[1] = RingBuf_ReadByte(r);
                    ram_2aee[2] = RingBuf_ReadByte(r);
                    ram_2aee[3] = RingBuf_ReadByte(r);
                    ram_2aee[4] = RingBuf_ReadByte(r);
                    ram_2aee[5] = RingBuf_ReadByte(r);
                    Voice_ParamFinalize(ram_2aee);
                }
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0x90:
            if (r->n >= 3) {
                ram_2af4[0] = c;
                ram_2af4[1] = RingBuf_ReadByte(r);
                ram_2af4[2] = RingBuf_ReadByte(r);
                ram_2af4[3] = RingBuf_ReadByte(r);
                __A = ram_2af4[1];
                if (__A < 0xf0)
                    Voice_NoteOn(ram_2af4);
                else
                    Voice_Poly_NoteOn(ram_2af4);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xb0:
            if (r->n >= 3) {
                ram_2af8[0] = c;
                ram_2af8[1] = RingBuf_ReadByte(r);
                ram_2af8[2] = RingBuf_ReadByte(r);
                ram_2af8[3] = RingBuf_ReadByte(r);
                Voice_CtrlChange(ram_2af8);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xc0:
            if (r->n >= 4) {
                ram_2afc[0] = c;
                ram_2afc[1] = RingBuf_ReadByte(r);
                ram_2afc[2] = RingBuf_ReadByte(r);
                ram_2afc[3] = RingBuf_ReadByte(r);
                ram_2afc[4] = RingBuf_ReadByte(r);
                Voice_ProgChange(ram_2afc);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xd0:
            if (r->n >= 3) {
                ram_2b01[0] = c;
                ram_2b01[1] = RingBuf_ReadByte(r);
                ram_2b01[2] = RingBuf_ReadByte(r);
                ram_2b01[3] = RingBuf_ReadByte(r);
                Voice_ChanPressure(ram_2b01);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xe0:
            if (r->n >= 3) {
                ram_2b05[0] = c;
                ram_2b05[1] = RingBuf_ReadByte(r);
                ram_2b05[2] = RingBuf_ReadByte(r);
                ram_2b05[3] = RingBuf_ReadByte(r);
                Voice_PitchBend(ram_2b05);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        case 0xf0:
            if (r->n >= 3) {
                ram_2b09[0] = c;
                ram_2b09[1] = RingBuf_ReadByte(r);
                ram_2b09[2] = RingBuf_ReadByte(r);
                ram_2b09[3] = RingBuf_ReadByte(r);
                Voice_SystemMsg(ram_2b09);
                return;
            }
            RingBuf_SkipToEnd(r);
            continue;
        default:
            RingBuf_SkipToEnd(r);
            break;
        }
    }
}
