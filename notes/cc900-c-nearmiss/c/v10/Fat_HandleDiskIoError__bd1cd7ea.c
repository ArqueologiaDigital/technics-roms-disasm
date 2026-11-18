/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_4m239a.c (2026-11-18-33-p6-r37)
   sha256 bd1cd7eaba58e998df9b48ce4387019e9fcdc73efb057a02277c0b42b296aff4 (tar-sha256); compiled at -O3 -Xr */
struct geom { char pad[38]; unsigned int bps; char pad2[10]; unsigned int spt; unsigned int heads; };
struct vol { char pad[2]; unsigned char vflags; char pad3[23]; struct geom *geom; };
struct io { struct vol *vol; char pad4[8]; unsigned char *buf; unsigned int count; char pad18[2]; int status;
	char pad22[4]; unsigned char x26[2]; };
extern int ram_2271e;
extern int __cdecl SeqChan_ByteBlockA(struct vol *v);
extern int __cdecl Fat_MountVolume(struct vol *v);
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
	case 53:
	case 51:
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
	case 48:
	case 49:
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
