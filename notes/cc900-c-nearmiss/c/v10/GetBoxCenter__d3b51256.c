/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -Xr */
struct box { int x0, y0, x1, y1; };
struct pt { int x, y; };
void GetBoxCenter(struct box *b, struct pt *c)
{
	int y;

	c->x = b->x0 + (b->x1 - b->x0 + 1) / 2;
	y = b->y0;
	c->y = y + (b->y1 - y + 1) / 2;
}
