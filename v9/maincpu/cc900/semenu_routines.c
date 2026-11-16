/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_65a, ram_693, ram_694, ram_695, ram_698, ram_6ad, ram_6af, ram_6b4, ram_6b5;
extern unsigned char ram_6b6, ram_6b7, ram_6b8, ram_6b9, ram_6c4, ram_6c5, ram_e3dc, ram_e3de, ram_205f2;
extern unsigned char SEMENU_PART_MODE, SEMENU_PART_MASK, GLOBAL_ERROR_CODE;

void SeCtr2_SetSelection(unsigned char v) { ram_695 = v; }
void SeMenu_CopyWriteUpdate_Step3_Helper14(unsigned char v) { ram_6b7 = v; }
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
void SeMenu_ClearNotification(unsigned char v) { ram_e3dc = v; ram_e3de |= 0x02; }
void SeMenu_TriggerNotification(unsigned char v) { GLOBAL_ERROR_CODE = v; ram_e3dc = 238; ram_e3de |= 0x40; }

void SeMenu_StoreAbsoluteValue(char a, char *p) { if (a < 0) a = -a; *p = a; }
unsigned int SeMenu_InterpolateEdgeX(unsigned int a, unsigned int b, unsigned int d) { return (a * b) / d; }
