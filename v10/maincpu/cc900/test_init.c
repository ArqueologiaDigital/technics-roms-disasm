/* Functions of factory_test/test_init.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char XAPR_PRESENT_FLAG;

unsigned char Xapr_GetPresentFlag(void) { return XAPR_PRESENT_FLAG; }
