#!/usr/bin/env python3
"""prom_a power-on splash: which layer the first blit (0xF94131) draws into, and the logotype.

Answers open-items N-89745684 (the layer (0x2540) selects for the first blit) and N-37157ced (what
the script logotype of SplashImage_DitherA/B reads).

The layer.  LCD_Svc_03_BlitColumns writes to IX + LCD_CurrentLayerBase, the SAD word of layer
(0x2540).  Paint_PowerOnSplash's first-Enter path blits DitherA at IX 0 and DitherB at IX 0x4C00
WITHOUT writing (0x2540), then sets the SAD words to 0x2580 (layer 0, layer 1) and 0x2680
(layer 2); later Enters scroll layer 0 back to SAD 0 and layer 2 forward to SAD 0x4C00.  So the
end state shows display RAM 0x0000 on layer 0 and 0x4C00 on layer 2.  This script checks those
bytes and then tries the three possible layers: only layer 0 (base 0x0000, written by
LCD_Init_SED1330 and untouched until the blit) puts DitherA under layer 0's final window and
DitherB under layer 2's.  RESET zeroes 0x0080-0x51FF, so (0x2540) = 0 at power-on, and the only
boot-path writers of (0x2540) in the main-task module store 0 (VersionScreen_Show).

The logo.  The two halves are complementary (AND = 0, equal popcounts); their OR is the solid
picture.  `--render PATH` writes it as a PNG (x3, rows 60-164) for reading by eye.

Run (from wsa1/):
    python3 notes/open4-d-probes/splash_layer_and_logo.py --selftest
    python3 notes/open4-d-probes/splash_layer_and_logo.py --render ~/compartilhado/tmp/splash.png
"""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PA = open(os.path.join(ROOT, "original_ROMs/wsa1_prom_a.ic12"), "rb").read()
A0 = 0xF80000
rb = lambda a, n: PA[a - A0:a - A0 + n]
SCREEN = 0x2580          # 40 bytes x 240 lines, one layer's window


def checks():
    out = []
    c = lambda name, ok: out.append((name, bool(ok)))
    # RESET: ld BC,0x1460 / ld XIX,0x00000080 / xor XWA,XWA -> 0x1460 longs from 0x80 = 0x80..0x51FF
    c("RESET clears 0x0080-0x51FF (0xF8278A: ld BC,0x1460 / ld XIX,0x80)", rb(0xF8278A, 8) == bytes.fromhex("3160144480000000"))
    c("0x2540 lies inside the cleared range", 0x80 <= 0x2540 < 0x80 + 0x1460 * 4)
    # LCD_Init_SED1330 stores the three SAD words 0x0000 / 0x2600 / 0x4C00 into 0x2541/43/45
    c("LCD_Init: (0x2541) := 0x0000", rb(0xF8E8A2, 8) == bytes.fromhex("21002000f1412550"))
    c("LCD_Init: (0x2543) := 0x2600", rb(0xF8E8AA, 8) == bytes.fromhex("21002026f1432550"))
    c("LCD_Init: (0x2545) := 0x4C00", rb(0xF8E8B2, 8) == bytes.fromhex("2100204cf1452550"))
    # Paint_PowerOnSplash first-Enter path, 0xF94112..0xF9416F: no store to (0x2540) (f1 40 25 ..)
    path = rb(0xF94112, 0xF9416F - 0xF94112)
    c("no `ld (0x2540),n` between 0xF94112 and 0xF9416F", path.find(bytes.fromhex("f14025")) < 0)
    c("blit 1: XIY = 0xFF8000, IX = 0x0000 (0xF94131)", rb(0xF94131, 8) == bytes.fromhex("450080ff00340000"))
    c("blit 2: XIY = 0xFFA580, IX = 0x4C00 (0xF94142)", rb(0xF94142, 8) == bytes.fromhex("4580a5ff0034004c"))
    c("then (0x2541) := 0x2580", rb(0xF94158, 6) == bytes.fromhex("f14125028025"))
    c("then (0x2545) := 0x2680", rb(0xF9415E, 6) == bytes.fromhex("f14525028026"))
    c("then (0x2543) := 0x2580", rb(0xF94164, 6) == bytes.fromhex("f14325028025"))
    c("scroll stops when (0x2541) <= 0 (0xF9418A cpw (0x2541),0)", rb(0xF9418A, 6) == bytes.fromhex("d141253f0000"))
    c("scroll stops when (0x2545) >= 0x4C00 (0xF94195)", rb(0xF94195, 6) == bytes.fromhex("d145253f004c"))
    c("each phase starts exactly one window from its stop (0x2580)", 0x2580 - 0 == SCREEN and 0x4C00 - 0x2680 == SCREEN)
    # the three candidate layers: base = that layer's SAD word at blit time (LCD_Init values)
    sad = {0: 0x0000, 1: 0x2600, 2: 0x4C00}
    final = {0: 0x0000, 2: 0x4C00}               # where layers 0 and 2 end up
    fits = []
    for L, base in sad.items():
        a, b = base, base + 0x4C00
        if a == final[0] and b == final[2]:
            fits.append(L)
    c("only layer 0 lands DitherA under layer 0's final window and DitherB under layer 2's", fits == [0])
    # the boot-path writers of (0x2540) in the main-task module store 0
    c("VersionScreen_Show: ld (0x2540),0 twice (0xF82AAB, 0xF82AB0)",
      rb(0xF82AAB, 10) == bytes.fromhex("f140250000f140250000"))
    # the logo halves (from the committed PNGs)
    try:
        from PIL import Image
        import numpy as np
        A = np.array(Image.open(os.path.join(ROOT, "prom_a/images/SplashImage_DitherA.png")).convert("L")) < 128
        B = np.array(Image.open(os.path.join(ROOT, "prom_a/images/SplashImage_DitherB.png")).convert("L")) < 128
        c("DitherA AND DitherB = 0", not (A & B).any())
        c("equal popcounts 3983 / 3983", A.sum() == 3983 and B.sum() == 3983)
        rows = np.where((A | B).any(axis=1))[0]
        c("the picture spans rows 72-153", rows.min() == 72 and rows.max() == 153)
    except ImportError:
        c("PIL + numpy available for the PNG checks", False)
    return out


def render(path):
    from PIL import Image
    import numpy as np
    A = np.array(Image.open(os.path.join(ROOT, "prom_a/images/SplashImage_DitherA.png")).convert("L")) < 128
    B = np.array(Image.open(os.path.join(ROOT, "prom_a/images/SplashImage_DitherB.png")).convert("L")) < 128
    img = Image.fromarray(np.where(A | B, 0, 255).astype("uint8")).crop((0, 60, 320, 165))
    img.resize((960, 315), Image.NEAREST).save(path)
    print("wrote", path)


if __name__ == "__main__":
    if "--render" in sys.argv:
        render(sys.argv[sys.argv.index("--render") + 1])
        sys.exit(0)
    res = checks()
    for n, ok in res:
        print("%-4s %s" % ("ok" if ok else "FAIL", n))
    fails = sum(1 for _, ok in res if not ok)
    print("FAILURES: %d" % fails)
    sys.exit(1 if fails else 0)
