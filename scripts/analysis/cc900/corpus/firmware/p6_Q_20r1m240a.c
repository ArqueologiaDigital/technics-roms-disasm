/* helper Q, round 20r1, module 240 (sequencer/smf_event_processor.s): disk-type cells, format dispatch, handle check. */
/* cc900-module: FDC_Format2DD_Start FDC_Format2HD_Start */

extern unsigned char ram_3e3e4;
extern unsigned int ram_3e3e6;
extern unsigned char ram_3e3be;
extern unsigned char ram_3e3e2;
extern int FDC_Format2HD_Start(void);
extern int FDC_Format2DD_Start(void);

void __cdecl FDC_StoreDiskType(unsigned char t)
{
  ram_3e3e4 = t;
  ram_3e3e6 = 1;
  ram_3e3be = 0;
}

void FDC_ClearDiskChangeStatus(void)
{
  ram_3e3e6 = 0;
  ram_3e3e2 = ram_3e3e4;
}

unsigned char FDC_ReadDiskType(void)
{
  return ram_3e3e4;
}

int format_FD(unsigned char t)
{
  switch (t) {
  case 2:
    return FDC_Format2DD_Start();
  case 3:
    return FDC_Format2HD_Start();
  }
  return 0;
}

int FileIO_ValidateHandle(long h)
{
  if (h == 0) return -1;
  return 0;
}
