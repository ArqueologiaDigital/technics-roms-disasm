/* Phase 6, probe m18 (form b): the FileIO_* shifts through a block-local unsigned mask (m17 b's function-level
   local was set before the range test). */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) { unsigned int m = 1; m <<= a; ram_272ce |= m; } }
void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) { unsigned int m = 1; m <<= a; ram_272cc |= m; } }
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) { unsigned int m = 1; m <<= a; ram_272ce &= m ^ 0xffff; } }
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) { unsigned int m = 1; m <<= a; ram_272cc &= ~m; } }
