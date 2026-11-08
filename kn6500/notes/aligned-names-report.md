# kn6500: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 1056, 507 of them by mapped operands (rounds: 775, 218, 38, 15, 5, 3, 2, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 1449
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 761 right, 3 wrong (of them paired by operand pointers alone: 14 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 48, 'tables refused (named words disagree, or too few agree)': 1962, 'tables used': 10}
- routine names carried on pointer supports alone (an operand or a table word): 13
- audit, same-body routines B names already, picked by mapped operands: 357 right, 0 wrong
- RAM address pairs: 2317: 1878 by aligned operands (of 1891 B addresses seen in them), 439 between two of one delta (runs; the premise on the voted pairs: 1354 right, 2 wrong); named from A: 9; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   1449 A's callee is unnamed too (the pair anchors the next round)
  -    165 A's callee is unnamed too
  -     74 one aligned call site only
  -     29 body skeleton similarity below 0.6
  -      7 the bodies' callees or strings disagree
  -      4 the name is taken in B
  -      3 pairs with more than one routine

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `Draw2BpFile_Impl` 0x4C01792B / `DrawBitmapFile_Impl` 0x48424B05 (1)
- `M3HookDispatch` 0x4C03CDDE / `M3SetSpecialDispatch` 0x4C0216A3 (3)
- `SoundRamSumUpdate` 0x4C07DDA4 / `SoundRamHeaderStamp` 0x4844B431 (1)
