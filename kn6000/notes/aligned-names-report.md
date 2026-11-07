# kn6000: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 1065, 490 of them by mapped operands (rounds: 756, 250, 34, 15, 5, 3, 2, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 1375
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 726 right, 2 wrong (of them paired by operand pointers alone: 12 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 48, 'tables refused (named words disagree, or too few agree)': 1930, 'tables used': 10}
- routine names carried on pointer supports alone (an operand or a table word): 17
- audit, same-body routines B names already, picked by mapped operands: 356 right, 0 wrong
- RAM address pairs: 2317: 1864 by aligned operands (of 1876 B addresses seen in them), 453 between two of one delta (runs; the premise on the voted pairs: 1335 right, 2 wrong); named from A: 8; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   1375 A's callee is unnamed too (the pair anchors the next round)
  -    178 A's callee is unnamed too
  -     70 one aligned call site only
  -     30 body skeleton similarity below 0.6
  -      7 the bodies' callees or strings disagree
  -      3 pairs with more than one routine
  -      2 the name is taken in B

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `Draw2BpFile_Impl` 0x4C0177F1 / `DrawBitmapFile_Impl` 0x48424B05 (1)
- `M3HookDispatch` 0x4C03CC6E / `M3SetSpecialDispatch` 0x4C0216A3 (3)
