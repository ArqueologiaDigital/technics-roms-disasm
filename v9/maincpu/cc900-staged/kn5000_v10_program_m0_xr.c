/* Functions of kn5000_v9_program.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near SEQ_RTMCFG;
extern void SeqAcc_InitPlaybackState(void);
extern void MidiIn_AcceptClockTransport(void);
void PlayStandBy(void);
void EditSwRefresh(void);
extern void PlayStandBy(void);
extern void EditSwRefresh(void);
struct cc4 { unsigned char b[4]; };
extern const struct cc4 SepaOut_Config_0;
extern const struct cc4 SepaOut_Msg_CC9B_Value32;
extern const struct cc4 SepaOut_Msg_CC9D_Value0;
extern const struct cc4 SepaOut_Msg_CC9D_Value1;
extern const struct cc4 SepaOut_Msg_CC9D_Value2;
extern void sendCOMM(int, int, unsigned char *);
void SetSepaOutMode(unsigned int mode);
extern void SetSepaOutMode(unsigned int mode);

void PlayStandBy(void)
{
	if (SEQ_RTMCFG & 4) SEQ_RTMCFG &= ~4;
	SEQ_RTMCFG &= ~8;
	SeqAcc_InitPlaybackState();
	MidiIn_AcceptClockTransport();
}
