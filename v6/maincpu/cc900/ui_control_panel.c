/* Functions of ui/ui_control_panel.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near PART_SELECT;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ACTIVE_TITLE;

unsigned char GetCurrentPartSelect(void) { return PART_SELECT; }
int GetPartSelect(void) { return PART_SELECT; }
int SeqState_HasModeChanged(void) { return CURRENT_TITLE != ACTIVE_TITLE; }
