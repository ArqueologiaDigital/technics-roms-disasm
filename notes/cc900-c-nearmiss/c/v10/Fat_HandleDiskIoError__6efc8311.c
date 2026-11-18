/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_4m239b.c (2026-11-18-33-p6-r37)
   sha256 6efc8311043c5eb1121fb9a329e91ca8633b2c1f45b7c9b085f9cc727a7a2870 (tar-sha256); compiled at -Xr */
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
