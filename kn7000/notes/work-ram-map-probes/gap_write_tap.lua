-- Question: does anything write work RAM 0x50298000..0x502B7FFF (between the slideshow
-- pool end 0x50297FFC and INSTALL_SCRATCH 0x502B8000) during a normal boot to the home
-- screen? Also: which pool does 0x50172C90 select at the end, and what are the main pool
-- header words (base 0x502031A0: +0x08 base, +0x0C size, +0x10 heap, +0x14 heap size,
-- +0x18 bump ptr, +0x1C free bytes, +0x20/+0x24/+0x28 script ptrs).
-- Signal: per-writer-PC counts and address ranges, printed at t = END seconds.
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local sp = cpu.spaces["program"]
local END = tonumber(os.getenv("GAP_END") or "60")
local w = {}
local function tap(lo, hi, tag)
  return sp:install_write_tap(lo, hi, tag, function(off, data, mask)
    local pc = cpu.state["PC"].value
    local k = tag .. string.format(" pc=%08X", pc)
    local e = w[k]
    if not e then e = {n = 0, lo = off, hi = off, nz = 0}; w[k] = e end
    e.n = e.n + 1
    if off < e.lo then e.lo = off end
    if off > e.hi then e.hi = off end
    if data ~= 0 then e.nz = e.nz + 1 end
  end)
end
_t1 = tap(0x50298000, 0x502B7FFF, "GAP")
_t2 = tap(0x502031A0, 0x502031CF, "POOLHDR")
_t3 = tap(0x50172C90, 0x50172C93, "POOLSEL")
local done = false
_f = emu.add_machine_frame_notifier(function()
  if done or mac.time.seconds < END then return end
  done = true
  for k, e in pairs(w) do
    print(string.format("%s writes=%d nonzero=%d range=%08X..%08X", k, e.n, e.nz, e.lo, e.hi))
  end
  print(string.format("SEL (0x50172C90)=%08X", sp:read_u32(0x50172C90)))
  for o = 0, 0x2C, 4 do
    print(string.format("HDR +%02X = %08X", o, sp:read_u32(0x502031A0 + o)))
  end
  print(string.format("ROMCHK u32@4857F0EA=%08X (expect 50297FFC) u32@4857F0CF=%08X (expect 4C03FFF0) t=%d", sp:read_u32(0x4857F0EA), sp:read_u32(0x4857F0CF), mac.time.seconds))
  mac:exit()
end)
