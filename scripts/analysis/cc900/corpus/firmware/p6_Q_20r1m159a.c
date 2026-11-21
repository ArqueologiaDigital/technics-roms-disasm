/* helper Q, round 20r1, module 159 (audio/sound_editor_ui.s, storage/flash_floppy_handlers.s, factory_test/test_init.s):
   the line helper (twin of DrawLineHelper), a flash-section table lookup, the 2HD format test step. */

struct pt { int x, y; };

extern unsigned char RhythmSlot_FlashSectionTable[];
extern unsigned char FDTest_Format2hdAndLabel_Str_TESTHAMA2HD[];
extern void DrawLine(struct pt *, struct pt *, int);
extern int format_FD(int);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);

void StylCnvStorOkFunc_DataBlock(struct pt *a, struct pt *b, int c, int swap)
{
  struct pt p1;
  struct pt p2;
  if (swap != 0) {
    p1.x = a->y;
    p1.y = a->x;
    p2.x = b->y;
    p2.y = b->x;
    a = &p1;
    b = &p2;
  }
  DrawLine(a, b, c);
}

unsigned char NoteEvent_Store(unsigned char i)
{
  return RhythmSlot_FlashSectionTable[i];
}

int FDTest_Format2hdAndLabel(void)
{
  format_FD(3);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2hdAndLabel_Str_TESTHAMA2HD);
  return 0;
}
