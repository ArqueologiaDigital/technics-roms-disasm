/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m159a.c (2026-11-21-21-p6-r66)
   sha256 74f969c37586b56b49dc59b966d0b0b8eb79f31b50c3fed2e6bc812c1c174a4c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: ResInfo_Str_TEST=ResInfo_GetResourceListPtr_Str_TEST */
struct resinfo { long addr; long size; };
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned int __near ram_ffbe;
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern unsigned char ram_1e0000[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char ram_b0000[];
extern unsigned char ram_fd800[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
extern char ResInfo_Str_TEST[];
void GetResouceInfo(unsigned int type, struct resinfo *r)
{
	switch (type) {
	case 0:
		r->addr = (long)LIVE_PANEL_BLOCK;
		r->size = (long)(&ram_ffbe + 1) - (long)LIVE_PANEL_BLOCK;
		break;
	case 1:
		r->addr = (long)ram_1e7800;
		r->size = (long)ram_1e8000 - (long)ram_1e7800;
		break;
	case 2:
		r->addr = (long)ram_1ed350;
		r->size = (long)ram_200000 - (long)ram_1ed350;
		break;
	case 6:
		r->addr = (long)ram_1e0000;
		r->size = (long)ram_1e7800 - (long)ram_1e0000;
		break;
	case 9:
		r->addr = 0x3d3000L;
		r->size = 0x400L;
		break;
	case 3:
		r->addr = (long)SEQ_SONG_SLOTS;
		r->size = 0x5000L;
		break;
	case 4:
		r->addr = (long)ram_b0000;
		r->size = (long)ram_fd800 - (long)ram_b0000;
		break;
	case 5:
		r->addr = (long)RHYTHM_PATTERN_BUF_A;
		r->size = (long)SEQ_SONG_SLOTS - (long)RHYTHM_PATTERN_BUF_A;
		break;
	case 7:
		r->addr = (long)ram_1e8800;
		r->size = (long)ram_1ec400 - (long)ram_1e8800;
		break;
	case 8:
		r->addr = (long)ResInfo_Str_TEST;
		r->size = 0;
		break;
	}
}
