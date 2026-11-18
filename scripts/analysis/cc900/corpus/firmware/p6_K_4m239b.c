/* Phase 6, lane_p6 helper K, round 4, module 239 (sequencer/smf_event_processor.s, the FAT library's floppy layer),
   form b: as form a, but the labels inside the two two-label cases in the other order (51, 53 and 49, 48), the
   track loop written with nested ifs instead of continue.
   All __cdecl.  struct io is the transfer request: volume +0 (flags byte +2, geometry +26), buffer +12,
   count +16, status +20, a one-sector buffer +26.  Geometry: bytes per sector +38, sectors per track +50,
   heads +52.
   Fat_HandleDiskIoError(err, io): after a transfer; 0 stays 0.  Counts the attempt (int 0x2271e) and maps the FDC
   code: 47 -> 31 (return 0), 51/53 -> 33, 6 -> 6, 48/49 -> 32, other -> 36; clears the volume's bit 3, calls
   SeqChan_ByteBlockA (not for 6) and re-mounts (Fat_MountVolume): a failure goes to io->status, a success means
   retry (1; the 48/49 path returns 0) unless 0x2271e has reached 1.  The case labels are written in the reverse of
   the ROM's compare order (V4.23 compares the last case first), the bodies in the ROM's order.  The 6 path loads the
   volume's geometry pointer and drops it (an expression statement here).
   SeqChan_ByteBlockE / _F(pos, io): read (SeqChan_ByteBlockC) / write (SeqChan_ByteBlockD) io->count sectors from
   sector pos: pos -> sector (remainder), head, cylinder (the long quotient reused), then track by track (n in IZ:
   the rest of the track or the rest of the count), advancing the buffer by n * bytes-per-sector; without a buffer
   one sector into io+26.  Every pass ends in Fat_HandleDiskIoError(&rc, io), repeated while it asks for a retry.
   The track loop's three back edges written as continue. */
/* cc900-module: Fat_HandleDiskIoError SeqChan_ByteBlockA SeqChan_ByteBlockC SeqChan_ByteBlockD */   /* scripts/analysis/cc900/module_calls.py v10 */

struct geom { char pad[38]; unsigned int bps; char pad2[10]; unsigned int spt; unsigned int heads; };
struct vol { char pad[2]; unsigned char vflags; char pad3[23]; struct geom *geom; };
struct io { struct vol *vol; char pad4[8]; unsigned char *buf; unsigned int count; char pad18[2]; int status;
	char pad22[4]; unsigned char x26[2]; };

extern int ram_2271e;
extern int __cdecl SeqChan_ByteBlockA(struct vol *v);
extern int __cdecl Fat_MountVolume(struct vol *v);
extern int __cdecl SeqChan_ByteBlockC(struct vol *v, int cyl, int head, int sec, int n, unsigned char *buf);
extern int __cdecl SeqChan_ByteBlockD(struct vol *v, int cyl, int head, int sec, int n, unsigned char *buf);
extern int __cdecl Fat_HandleDiskIoError(int *err, struct io *io);
extern int __cdecl SeqChan_ByteBlockE(unsigned long pos, struct io *io);
extern int __cdecl SeqChan_ByteBlockF(unsigned long pos, struct io *io);

int __cdecl Fat_HandleDiskIoError(int *err, struct io *io)
{
	int rc;
	int e;

	rc = 0;
	if (*err == 0)
		return 0;
	ram_2271e++;
	switch (*err) {
	case 47:
		*err = 31;
		return 0;
	case 51:
	case 53:
		io->vol->vflags &= ~8;
		*err = 33;
		SeqChan_ByteBlockA(io->vol);
		if ((e = Fat_MountVolume(io->vol)) != 0)
			io->status = e;
		else
			rc = 1;
		break;
	case 6:
		io->vol->vflags &= ~8;
		*err = 6;
		io->vol->geom;
		if ((e = Fat_MountVolume(io->vol)) != 0)
			io->status = e;
		else
			rc = 1;
		break;
	case 49:
	case 48:
		io->vol->vflags &= ~8;
		*err = 32;
		SeqChan_ByteBlockA(io->vol);
		if ((e = Fat_MountVolume(io->vol)) != 0)
			io->status = e;
		else
			return 0;
		break;
	default:
		io->vol->vflags &= ~8;
		*err = 36;
		SeqChan_ByteBlockA(io->vol);
		if ((e = Fat_MountVolume(io->vol)) != 0)
			io->status = e;
		else
			rc = 1;
		break;
	}
	if (ram_2271e >= 1)
		return 0;
	return rc;
}

int __cdecl SeqChan_ByteBlockE(unsigned long pos, struct io *io)
{
	struct geom *g;
	unsigned int head;
	unsigned int cyl;
	unsigned int sec;
	int rc;
	unsigned int n;

	ram_2271e = 0;
	g = io->vol->geom;
	sec = pos % g->spt;
	head = pos / g->spt % g->heads;
	cyl = pos / g->spt / g->heads;
	do {
		if (io->buf != 0) {
			for (;;) {
				n = g->spt - sec;
				if (io->count < n)
					n = io->count;
				rc = SeqChan_ByteBlockC(io->vol, cyl, head, sec + 1, n, io->buf);
				if (rc != 0)
					break;
				io->count -= n;
				if (io->count == 0)
					break;
				io->buf += (unsigned long)n * g->bps;
				sec += n;
				if (sec >= g->spt) {
					sec = 0;
					head++;
					if (head == g->heads) {
						head = 0;
						cyl++;
					}
				}
			}
		} else
			rc = SeqChan_ByteBlockC(io->vol, cyl, head, sec + 1, 1, io->x26);
	} while (Fat_HandleDiskIoError(&rc, io) != 0);
	return rc;
}

int __cdecl SeqChan_ByteBlockF(unsigned long pos, struct io *io)
{
	struct geom *g;
	unsigned int head;
	unsigned int cyl;
	unsigned int sec;
	int rc;
	unsigned int n;

	ram_2271e = 0;
	g = io->vol->geom;
	sec = pos % g->spt;
	head = pos / g->spt % g->heads;
	cyl = pos / g->spt / g->heads;
	do {
		if (io->buf != 0) {
			for (;;) {
				n = g->spt - sec;
				if (io->count < n)
					n = io->count;
				rc = SeqChan_ByteBlockD(io->vol, cyl, head, sec + 1, n, io->buf);
				if (rc != 0)
					break;
				io->count -= n;
				if (io->count == 0)
					break;
				io->buf += (unsigned long)n * g->bps;
				sec += n;
				if (sec >= g->spt) {
					sec = 0;
					head++;
					if (head == g->heads) {
						head = 0;
						cyl++;
					}
				}
			}
		} else
			rc = SeqChan_ByteBlockD(io->vol, cyl, head, sec + 1, 1, io->x26);
	} while (Fat_HandleDiskIoError(&rc, io) != 0);
	return rc;
}
