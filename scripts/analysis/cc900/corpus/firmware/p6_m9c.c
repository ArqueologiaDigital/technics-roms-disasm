/* Phase 6, probe m9 (form c): the FileIO_* bit functions of file_demo_proc.s with an unsigned one (the ROM shifts
   with sll A,BC, where 1 << a gives V4.23's sla A,BC), and the clear forms with ^ 0xffff (the ROM complements with
   xor BC,0xffff, where ~ gives cpl). */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= 1U << a; }
void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) ram_272cc |= 1U << a; }
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= (1U << a) ^ 0xffff; }
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) ram_272cc &= ~(1U << a); }
