/* Functions of shared/boot_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near REGION_CODE_VAR;

unsigned char Get_Region_Code(void) { return REGION_CODE_VAR; }
