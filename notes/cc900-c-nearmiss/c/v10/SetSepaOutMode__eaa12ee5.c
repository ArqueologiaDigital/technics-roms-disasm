/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m159b.c (2026-11-21-21-p6-r66)
   sha256 eaa12ee57d68f7f77009e3662f84549f42fd9fd6b51a7448bd99204eee8b4de4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct cc4 { int w0, w1; };
#define SEND(m, p) ((unsigned char *)&(m))[1] = (p); sendCOMM(0, 4, (unsigned char *)&(m))
extern const struct cc4 SepaOut_Config_0;
extern const struct cc4 SepaOut_Msg_CC9B_Value32;
extern const struct cc4 SepaOut_Msg_CC9D_Value0;
extern const struct cc4 SepaOut_Msg_CC9D_Value1;
extern const struct cc4 SepaOut_Msg_CC9D_Value2;
extern void sendCOMM(int, int, unsigned char *);
void SetSepaOutMode(unsigned int mode)
{
	struct cc4 m0 = SepaOut_Config_0;
	struct cc4 m1 = SepaOut_Msg_CC9B_Value32;
	struct cc4 m2 = SepaOut_Msg_CC9D_Value0;
	struct cc4 m3 = SepaOut_Msg_CC9D_Value1;
	struct cc4 m4 = SepaOut_Msg_CC9D_Value2;

	switch (mode) {
	case 0:
		SEND(m0, 0x14);
		SEND(m2, 0x14);
		SEND(m0, 0x13);
		SEND(m2, 0x13);
		SEND(m0, 0x16);
		SEND(m2, 0x16);
		break;
	case 1:
		SEND(m1, 0x14);
		SEND(m2, 0x14);
		SEND(m0, 0x13);
		SEND(m2, 0x13);
		SEND(m0, 0x16);
		SEND(m2, 0x16);
		break;
	case 2:
		SEND(m1, 0x14);
		SEND(m2, 0x14);
		SEND(m1, 0x13);
		SEND(m2, 0x13);
		SEND(m1, 0x16);
		SEND(m2, 0x16);
		break;
	case 3:
		SEND(m1, 0x14);
		SEND(m4, 0x14);
		SEND(m1, 0x13);
		SEND(m3, 0x13);
		SEND(m1, 0x16);
		SEND(m3, 0x16);
		break;
	}
}
