/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-21-22-p6-r67)
   sha256 2ba66cb89bb685f16b1f40346b51ec97a51b68700efaac0e956c705ecf6b6c88 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near CURRENT_TITLE;
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near SEQ_SONG;
extern unsigned char __near ram_2708;
extern unsigned char __near ram_270a;
extern unsigned int __near SQEDT_MDEL_FROM;
extern unsigned int __near SQEDT_MDEL_LAST;
extern unsigned int __near SQEDT_MERS_FROM;
extern unsigned int __near SQEDT_MERS_LAST;
extern unsigned int __near SQEDT_MCP_FROM;
extern unsigned int __near SQEDT_MCP_LAST;
extern unsigned int __near SQEDT_MINS_FROM;
extern unsigned int __near SQEDT_MINS_LAST;
extern unsigned int __near ram_f1d9;
extern unsigned int __near ram_f1de;
extern unsigned int __near ram_f1e4;
extern unsigned int __near ram_f1ec;
extern void ApDeliveryEvent(long, long, long);
extern void SeqData_CopyBlockWithLookup(void);
extern void SeqPart_CountActiveVoices(unsigned int);
extern void SeqData_CopyBlock2K(unsigned int, unsigned char *);
void SeqEvent_MainHandler(void)
{
	switch (CURRENT_TITLE) {
	case 0x90:
		SeqData_CopyBlockWithLookup();
		SeqPart_CountActiveVoices(SEQ_SONG);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1eL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1fL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x20L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x21L);
		break;
	case 0x9f:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xaL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xbL);
		break;
	case 0x9e:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 5L);
		break;
	case 0x9d:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 4L);
		break;
	case 0xa3:
		SQEDT_MDEL_LAST = SQEDT_MDEL_FROM + ram_f1d9 - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		break;
	case 0xa1:
		SQEDT_MERS_LAST = SQEDT_MERS_FROM + ram_f1de - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 6L);
		break;
	case 0x9c:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 7L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 9L);
		break;
	case 0x9b:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xcL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xdL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xeL);
		break;
	case 0xa2:
		SQEDT_MCP_LAST = SQEDT_MCP_FROM + ram_f1ec - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xfL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x10L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x11L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x12L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x13L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x14L);
		break;
	case 0xa4:
		SQEDT_MINS_LAST = SQEDT_MINS_FROM + ram_f1e4 - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x15L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x16L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x17L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x18L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x19L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1aL);
		break;
	case 0x91:
	case 0xa8:
		SeqData_CopyBlock2K(ram_2708, (unsigned char *)0x2842L);
		SeqData_CopyBlock2K(ram_270a, (unsigned char *)0x2852L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1bL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1cL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1dL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1eL);
		break;
	default:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 3L);
		break;
	}
}
