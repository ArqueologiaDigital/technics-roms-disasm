/* Probe round 36r1, helper C, form a: storage/flash_floppy_handlers.s (module 159), the xr_screen.py shape at -O3 -Xr.
   AccPatch_ConvertLegacySectionLayout(): copy a legacy style image into the work image (byte 16, 1,951 bytes from
   +96, 61,439 bytes from +0x800 to +0x1400: struct assignments, ldirw + ldi), run cmp_ld_mae, then copy sections
   0..11 to themselves and the old sections 12..19 to their new numbers with the built AccPatch_CopySection; the
   result is the last nonzero error.  Frame (last declared lowest): i +0, r +4; s / d stay in XHL / XDE. */
/* cc900-module: AccPatch_CopySection */

struct blk1 { unsigned char b[1951]; };
struct blk2 { unsigned char b[61439]; };
extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern void cmp_ld_mae(void);
extern int AccPatch_CopySection(void);
extern int AccPatch_ConvertLegacySectionLayout(void);

#define COPY_SECTION(a, b) \
	STYLE_COPY_SRC_SECTION = (a); \
	STYLE_COPY_DST_SECTION = (b); \
	if ((t = AccPatch_CopySection()) != 0) \
		r = t

int AccPatch_ConvertLegacySectionLayout(void)
{
	unsigned char *s;
	unsigned char *d;
	int r;
	unsigned long i;
	int t;

	r = 0;
	s = (unsigned char *)RHYTHM_PATTERN_BUF_PTR;
	d = (unsigned char *)STYLE_WORK_IMAGE_PTR;
	d[16] = s[16];
	*(struct blk1 *)(d + 96) = *(struct blk1 *)(s + 96);
	*(struct blk2 *)(d + 0x1400) = *(struct blk2 *)(s + 0x800);
	cmp_ld_mae();
	STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
	STYLE_DST_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
	for (i = 0; i < 12; i++) {
		COPY_SECTION(i, i);
	}
	COPY_SECTION(12, 12);
	COPY_SECTION(13, 14);
	COPY_SECTION(14, 15);
	COPY_SECTION(15, 16);
	COPY_SECTION(16, 24);
	COPY_SECTION(17, 26);
	COPY_SECTION(18, 27);
	COPY_SECTION(19, 28);
	COPY_SECTION(12, 18);
	COPY_SECTION(13, 20);
	COPY_SECTION(14, 21);
	COPY_SECTION(15, 22);
	COPY_SECTION(12, 13);
	COPY_SECTION(15, 17);
	COPY_SECTION(16, 25);
	COPY_SECTION(19, 29);
	COPY_SECTION(12, 19);
	COPY_SECTION(15, 23);
	return r;
}
