# Build 941 vs build 893 — the drift profile

Derived from 37 transcribed screens (9,472 bytes, 17 unknown cells) by correlating each
screen against the archived build-941 program image at every shift in ±0x8000.

## The headline correction

An earlier reading of 12 screens suggested build 941 was build 893 **plus one ~6,451-byte
block**. With 37 screens that is wrong. **The drift accumulates in at least four steps**:

| covered address | drift of 941 vs 893 | agreement |
|---|---|---|
| 0x48400000 – 0x48400D00 | **0** | 93.0 – 99.2 % |
| 0x48459000 | **+201** (0x00C9) | 96.1 % |
| 0x48789000 | **+6428** (0x191C) | **100.0 %** |
| 0x487B9000 – 0x487DA000 | **+6453** (0x1935) | 94.1 – 97.7 % |
| 0x487E9000 – 0x487F4900 | **+6451** (0x1933) | 91.0 – 100.0 % |

So build 941 is build 893 with **several separate insertions** totalling 6,451 bytes —
an ordinary recompilation with code added in more than one place, not a single patch.

The final step is **−2 bytes**, which is either a genuine small deletion or a near-tie in
the correlation over a data region. It is the least trustworthy row here.

## Where the insertions are

| bracket | inserted | width | bisect at |
|---|---|---|---|
| 0x48400E00 – 0x48459000 | +201 | 0.34 MB | **0x4842CF00** |
| 0x48459100 – 0x48789000 | **+6227** | **3.19 MB** | **0x485F1000** |
| 0x48789100 – 0x487B9000 | +25 | 0.19 MB | 0x487A1000 |
| 0x487DA100 – 0x487E9000 | −2 | 0.06 MB | 0x487E1800 |

The second bracket carries 97 % of the total change and is 3.19 MB wide — that is the one
worth bisecting.

## Table half

Shift 0 and 96.1 – 100 % agreement from 0x48000000 up to 0x48159000, then **+3** at
0x48259000 and 0x48359000. So table build 84 has a **3-byte insertion** somewhere in
0x48159100 – 0x48259000. Bisect at **0x481D9000**.

⚠ One anomaly: the screen at **0x48029000** correlates best at **−1088** with 100 %
agreement. A negative drift there contradicts every neighbour. Most likely a spurious
high-correlation match in a repetitive record table, but it has not been checked against
the photograph and should not be trusted until it is.

## Why agreement is 91–99 % rather than 100 %

The residual mismatches are concentrated where **absolute pointers** are dense — note the
low-address program screens (0x48400000–0x48400600, the vector table and early boot) score
93–97 %, while a pure-code screen like 0x48789000 scores exactly 100.0 %. Any absolute
address above an insertion must change by the drift amount, so those bytes *should* differ.
This is evidence for the model, not against it.

## What this means for reconstruction

Reconstructing 893 from 941 is still conceivable but is **harder than a single shift**: it
needs every breakpoint located, and each region's absolute pointers relocated by that
region's own drift. Any such artifact would be **derived, not a dump**, and must be labelled
so. Nothing of the sort has been produced here.
