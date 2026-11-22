/* lane_p6 helper J, round 27r1, form a: module 277 (audio/tonegen_fileio_handlers.s), the family
   PanelTlv_ValidateBlock1 / PanelTlv_WriteBlock0Headers (families27_J, 2 x 46 B) and their twin
   PanelTlv_WriteBlock1Headers: for each 10-byte layout record of PanelTlv_Block0_Layout (46) / _Block1_Layout (30)
   call PanelTlv_ValidateRecord / PanelTlv_WriteRecordHeader (block base, record).  The base is spilled to the frame,
   the index homed in IZ.
   Form a: `for (i = 0; i < N; i++) F(base, &Layout[i]);` with a 10-byte layout struct.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ValidateRecord PanelTlv_WriteRecordHeader */   /* scripts/analysis/cc900/module_calls.py v10 */

struct tlvrec { unsigned long off; unsigned char *rules; unsigned char tag; unsigned char len; };

extern struct tlvrec PanelTlv_Block0_Layout[];
extern struct tlvrec PanelTlv_Block1_Layout[];
extern void PanelTlv_ValidateRecord(unsigned char *base, struct tlvrec *l);
extern void PanelTlv_WriteRecordHeader(unsigned char *base, struct tlvrec *l);

void PanelTlv_WriteBlock0Headers(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 46; i++)
		PanelTlv_WriteRecordHeader(base, &PanelTlv_Block0_Layout[i]);
}

void PanelTlv_ValidateBlock1(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 30; i++)
		PanelTlv_ValidateRecord(base, &PanelTlv_Block1_Layout[i]);
}

void PanelTlv_WriteBlock1Headers(unsigned char *base)
{
	unsigned int i;

	for (i = 0; i < 30; i++)
		PanelTlv_WriteRecordHeader(base, &PanelTlv_Block1_Layout[i]);
}
