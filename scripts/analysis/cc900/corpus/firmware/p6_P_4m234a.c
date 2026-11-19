/* lane_p6 round 4 (2026-11-19), module 234 (sequencer/sequencer_engine.s, -O3 -Xr): SeqEvt_ProcessBlock from
   p6_J_5m234a.c (r37: +49, O3Xr) and its new twin Rhythm_ComputeNoteAllocation_Helper.  The ROM's result tests are
   a switch: compared in descending value order (132, 130, 129; 177, 176, 132, 130, 129), the bodies that clear the
   loop flag placed after the epilogue, the counting case inline.  Here as switches with fall-through:
   - SeqEvt_ProcessBlock: 130 clears the count and falls into 132 (stop), 129 counts;
   - Rhythm_ComputeNoteAllocation_Helper: 176 / 177 take the count from the byte at 0x230c and fall into 129 / 130
     / 132 (stop). */
/* cc900-module: Part_ReadSubBlock32 Part_ReadVoiceWord SeqEvent_ProcessRhythm4Ch SeqEvt_ProcessBlock_Helper */

struct cur4 { unsigned int blk; unsigned int ofs; };
extern struct cur4 SeqEvt_ProcessBlock_LocalInit;
extern struct cur4 SeqEvt_ProcessBlock_LocalInit_2;
extern unsigned char __near ram_230c;
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char SeqEvent_ProcessRhythm4Ch(struct cur4 *);
extern unsigned char SeqEvt_ProcessBlock_Helper(struct cur4 *);
extern int SeqEvt_ProcessBlock(unsigned char part);
extern int Rhythm_ComputeNoteAllocation_Helper(unsigned char part);

int SeqEvt_ProcessBlock(unsigned char part)
{
	int n;
	unsigned char go;
	struct cur4 c;
	unsigned char r;

	n = 0;
	go = 1;
	c = SeqEvt_ProcessBlock_LocalInit;
	r = Part_ReadSubBlock32(0, part);
	if (r != 16 && r != 13)
		return 0;
	c.blk = Part_ReadVoiceWord(0, part);
	c.ofs = 5;
	do {
		switch (SeqEvent_ProcessRhythm4Ch(&c)) {
		case 129:
			n++;
			break;
		case 130:
			n = 0;
		case 132:
			go = 0;
			break;
		}
	} while (go == 1);
	return n;
}

int Rhythm_ComputeNoteAllocation_Helper(unsigned char part)
{
	int n;
	unsigned char go;
	struct cur4 c;

	n = 0;
	go = 1;
	c = SeqEvt_ProcessBlock_LocalInit_2;
	if (Part_ReadSubBlock32(0, part) != 13)
		return 0;
	c.blk = Part_ReadVoiceWord(0, part);
	c.ofs = 5;
	do {
		switch (SeqEvt_ProcessBlock_Helper(&c)) {
		case 176:
		case 177:
			n = ram_230c;
		case 129:
		case 130:
		case 132:
			go = 0;
			break;
		}
	} while (go == 1);
	return n;
}
