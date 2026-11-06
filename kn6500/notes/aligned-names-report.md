# kn6500: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 108, 27 of them by mapped operands (rounds: 82, 18, 5, 1, 2, 0, 0, 0, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 1888
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 491 right, 2 wrong
- audit, same-body routines B names already, picked by mapped operands: 125 right, 0 wrong
- RAM address pairs: 1636 (of 1649 B addresses seen in aligned operands); named from A: 9; RAM audit 14 right, 0 wrong
- not carried (last reason per call-site pair):
  -   1888 A's callee is unnamed too (the pair anchors the next round)
  -    214 A's callee is unnamed too
  -     22 body skeleton similarity below 0.6
  -     14 one aligned call site only
  -      2 the name is taken in B
  -      1 the bodies' callees or strings disagree

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `Draw2BpFile_Impl` 0x4C01792B / `DrawBitmapFile_Impl` 0x48424B05 (1)
- `M3HookDispatch` 0x4C03CDDE / `M3SetSpecialDispatch` 0x4C0216A3 (3)
