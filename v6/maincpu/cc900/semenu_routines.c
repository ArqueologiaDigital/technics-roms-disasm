/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near ram_65a;
extern unsigned char __near ram_693;
extern unsigned char __near ram_694;
extern unsigned char __near ram_695;
extern unsigned char __near ram_698;
extern unsigned char __near ram_6ad;
extern unsigned char __near ram_6af;
extern unsigned char __near ram_6b4;
extern unsigned char __near ram_6b5;
extern unsigned char __near ram_6b6;
extern unsigned char __near ram_6b8;
extern unsigned char __near ram_6b9;
extern unsigned char __near ram_6c4;
extern unsigned char __near ram_6c5;
extern unsigned char __near ram_e2f2;
extern unsigned char __near ram_e2f4;
extern unsigned char ram_205f2;
extern unsigned char __near SEMENU_PART_MODE;
extern unsigned char __near SEMENU_PART_MASK;
extern unsigned char __near GLOBAL_ERROR_CODE;

void SeCtr2_SetSelection(unsigned char v) { ram_695 = v; }
void SeMenu_ResetSubIndex(void) { ram_694 = 0; }
unsigned char SeMenu_ReturnZero(void) { return 0; }
void SeMenu_SetConfirmState(unsigned char v) { ram_6c4 = v; }
void SeMenu_SetCurrentStep(unsigned char v) { ram_693 = v; }
void SeMenu_SetDisplayState(unsigned char v) { ram_6c5 = v; }
void SeMenu_SetFilterCoeff(unsigned char v) { ram_6b9 = v; }
void SeMenu_SetFilterMode(unsigned char v) { ram_6b6 = v; }
void SeMenu_SetFilterParam1(unsigned char v) { ram_6b5 = v; }
void SeMenu_SetLastSwitch(unsigned char v) { ram_65a = v; }
void SeMenu_SetMode(unsigned char v) { SEMENU_PART_MODE = v; }
void SeMenu_SetPatchBank(unsigned char v) { ram_6b8 = v; }
void SeMenu_SetSelectedRow(unsigned char v) { ram_6af = v; }
void SeMenu_SetSoundBank(unsigned char v) { ram_6b4 = v; }
void SeMenu_SetWriteMemSlot(unsigned char v) { ram_6ad = v; }
void SeMenu_StoreEventId(unsigned char v) { ram_698 = v; }
void SeMenu_StorePartMask(unsigned char v) { SEMENU_PART_MASK = v; }
void SeMenu_OrPartConfig(unsigned char v) { ram_205f2 |= v; }
void SeMenu_ClearNotification(unsigned char v) { ram_e2f2 = v; ram_e2f4 |= 0x02; }
void SeMenu_TriggerNotification(unsigned char v) { GLOBAL_ERROR_CODE = v; ram_e2f2 = 238; ram_e2f4 |= 0x40; }

void SeMenu_StoreAbsoluteValue(char a, char *p) { if (a < 0) a = -a; *p = a; }
