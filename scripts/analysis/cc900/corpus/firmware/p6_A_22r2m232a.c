/* lane_p6 helper A, round 22r2, form a: module 232 (sequencer/sequencer_ui.s), TrAsGrid_LookupByteTable, the
   13-byte leaf at the head of pool roots23_A's TrAsGrid stretch (byte argument in A, zero-extended, indexes the
   near table SEQ_TRACK_ASSIGN; result in L).  The rest of that stretch is AcTrAsGridBoxProc's switch bodies.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_TRACK_ASSIGN[];

unsigned char TrAsGrid_LookupByteTable(unsigned char i)
{
	return SEQ_TRACK_ASSIGN[i];
}
