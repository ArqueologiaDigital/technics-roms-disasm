/* lane_p6 helper J, round 27r1, form a: module 232 (sequencer/bmdredit_routines.s), the family
   BmDrEdit_SaveEditState / BmDrEdit_RestoreEditState (families27_J, 2 x 25 B): the editor cursor (0x275e word,
   0x2760 byte, SEQ_DATA_BLOCK, SEQ_DATA_OFFSET) copied to / from 0x2762, 0x2764, 0x2766, 0x2768 by memory-to-memory
   moves, the idiom of the built twin BmDrEdit_LoadAlternateState (non-volatile __near cells).
   cc900-options: -O3 -Xr
*/

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_275e;
extern unsigned char __near ram_2760;
extern unsigned int __near ram_2762;
extern unsigned char __near ram_2764;
extern unsigned int __near ram_2766;
extern unsigned int __near ram_2768;

void BmDrEdit_SaveEditState(void)
{
	ram_2762 = ram_275e;
	ram_2764 = ram_2760;
	ram_2766 = SEQ_DATA_BLOCK;
	ram_2768 = SEQ_DATA_OFFSET;
}

void BmDrEdit_RestoreEditState(void)
{
	ram_275e = ram_2762;
	ram_2760 = ram_2764;
	SEQ_DATA_BLOCK = ram_2766;
	SEQ_DATA_OFFSET = ram_2768;
}
