# kn6500: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 1069, 493 of them by mapped operands (rounds: 754, 252, 38, 15, 5, 3, 2, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 1451
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 735 right, 2 wrong (of them paired by operand pointers alone: 13 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 48, 'tables refused (named words disagree, or too few agree)': 1954, 'tables used': 10}
- routine names carried on pointer supports alone (an operand or a table word): 13
- audit, same-body routines B names already, picked by mapped operands: 357 right, 0 wrong
- RAM address pairs: 2318: 1879 by aligned operands (of 1892 B addresses seen in them), 439 between two of one delta (runs; the premise on the voted pairs: 1354 right, 2 wrong); named from A: 9; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   1451 A's callee is unnamed too (the pair anchors the next round)
  -    166 A's callee is unnamed too
  -     71 one aligned call site only
  -     30 body skeleton similarity below 0.6
  -      7 the bodies' callees or strings disagree
  -      3 pairs with more than one routine
  -      3 the name is taken in B

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `Draw2BpFile_Impl` 0x4C01792B / `DrawBitmapFile_Impl` 0x48424B05 (1)
- `M3HookDispatch` 0x4C03CDDE / `M3SetSpecialDispatch` 0x4C0216A3 (3)
