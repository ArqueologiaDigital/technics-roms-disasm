/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned int ram_100002;
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct pkt *Voice_Query_AllChannels(void);
void Voice_NoteState_Clear(int n);

void Voice_AllVoices_PortamentoReset(void)
{
    unsigned char i;
    unsigned char *p;
    for (i = 0; i < 0x1a; i++) Voice_NoteState_Clear(i);
    p = (unsigned char *)Voice_Query_AllChannels() + 5;
    for (; *p < 0x40; p++) {
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x840;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa200;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
        ram_18 &= 0x7f;
        ram_100000 = *p + 0x800;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xa280;
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
    }
}
