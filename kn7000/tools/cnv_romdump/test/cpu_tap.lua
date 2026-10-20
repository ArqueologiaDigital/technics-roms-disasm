-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- cpu_tap.lua -- does pass 9 (romdump_cputime.s) read and write only what it says? Run from dump.cmd.in's
-- @PREFILL_LATE@ line (run_test.sh --cputime). While a chunk is being measured (the probe's V_CTBUSY, 0x502E0248,
-- is 1; the wide taps are put in place at the next video frame, within the probe's 40 ms pause), every read and write in 0x20000000-0x5FFFFFFF and 0x80000000-0x9FFFFFFF whose PC is in the probe's code
-- (0x502BA000-0x502BFFFF) is counted by 64 KB block, and checked:
--   * a write must go to the converter area (0x502B8000-0x502E7FFF, or its uncached view 0x902B8000-...), to the
--     stack (within 0x100 bytes of SP), or to the LCD frame (0x9CE00000-0x9CE4AFFF) with the value already there;
--   * a read must not touch an I/O window other than the ones the probe names: timer 4 (0x34001080/90/A0), G17ICR
--     (0x3400015C), the bus controller (0x32000010-0x32000043), CHCTR (0x20000070) and the board strap (0x98070000);
--     0x36xxxxxx, the rest of 0x34xxxxxx, 0x98000000-0x9CDFFFFF and 0x9CE4B000-0x9FFFFFFF are not allowed.
-- PREFILL_END(out) writes OUT/cpu_tap.txt: "R <block> <count>", "W <block> <count>", then "BAD <r|w> <address>
-- <pc> <why>" for each access that broke a rule (the first 200), "LCDCHANGED <n>" and a summary line "TOTAL ...".
local mac = manager.machine
local cpu = mac.devices[":maincpu"]
local sp = cpu.spaces["program"]
local T = { armed = false, R = {}, W = {}, bad = {}, nbad = 0, lcdchg = 0, nr = 0, nw = 0, inner = false, chunks = 0,
            taps = {} }
_G.CPUT = T
local APP0, APP1 = 0x502BA000, 0x502C0000
local function pc() return cpu.state["PC"].value end
local function inapp(p) return p >= APP0 and p < APP1 end
local function note(kind, a, why)
  T.nbad = T.nbad + 1
  if #T.bad < 200 then T.bad[#T.bad + 1] = string.format("BAD %s %08X %08X %s", kind, a, pc(), why) end
end
local function readok(a)
  if a >= 0x36000000 and a < 0x37000000 then return false end
  if a >= 0x34000000 and a < 0x35000000 then
    local w = a & ~3
    return w == 0x34001080 or w == 0x34001090 or w == 0x340010A0 or w == 0x3400015C
  end
  if a >= 0x32000000 and a < 0x33000000 then return a >= 0x32000010 and a < 0x32000044 end
  if a >= 0x20000000 and a < 0x30000000 then return (a & ~3) == 0x20000070 end
  if a >= 0x98000000 and a < 0x9CE00000 then return (a & ~3) == 0x98070000 end
  if a >= 0x9CE4B000 and a < 0xA0000000 then return false end
  return true
end
local function writeok(a, data, mask)
  if (a >= 0x502B8000 and a < 0x502E8000) or (a >= 0x902B8000 and a < 0x902E8000) then return true end
  local s = cpu.state["SP"].value
  if a >= s - 0x100 and a < s + 0x100 then return true end
  if a >= 0x9CE00000 and a < 0x9CE4B000 then
    T.inner = true
    local old = sp:read_u32(a & ~3)
    T.inner = false
    if (old & mask) ~= (data & mask) then
      T.lcdchg = T.lcdchg + 1
      note("w", a, string.format("LCD value changed %08X -> %08X (mask %08X)", old & mask, data & mask, mask))
    end
    return true
  end
  return false
end
-- The probe's flag: a tap on its one word (cheap); the wide taps exist only while it is set, installed and
-- removed once per video frame (the probe pauses CT_SETTLE = 40 ms after setting it, so they are in place before
-- its first test). Every access in between still passes through the cheap check of T.armed.
T.taps[#T.taps + 1] = sp:install_write_tap(0x502E0248, 0x502E024B, "cput_busy", function(offset, data, mask)
  if (mask & 0xFF) == 0 then return end
  local on = (data & 0xFF) ~= 0
  if on and not T.armed then T.chunks = T.chunks + 1 end
  T.armed = on
end)
local function wide_on()
  T.wide = {}
  for _, r in ipairs({ { 0x20000000, 0x3FFFFFFF }, { 0x40000000, 0x5FFFFFFF }, { 0x80000000, 0x9FFFFFFF } }) do
    T.wide[#T.wide + 1] = sp:install_read_tap(r[1], r[2], "cput_r" .. r[1], function(offset, data, mask)
      if not T.armed or T.inner then return end
      if not inapp(pc()) then return end
      local b = offset >> 16
      T.R[b] = (T.R[b] or 0) + 1
      T.nr = T.nr + 1
      if not readok(offset) then note("r", offset, "read outside the allowed windows") end
    end)
    T.wide[#T.wide + 1] = sp:install_write_tap(r[1], r[2], "cput_w" .. r[1], function(offset, data, mask)
      if not T.armed or T.inner then return end
      if not inapp(pc()) then return end
      local b = offset >> 16
      T.W[b] = (T.W[b] or 0) + 1
      T.nw = T.nw + 1
      if not writeok(offset, data, mask) then note("w", offset, string.format("write of %08X (mask %08X) outside "
        .. "the scratch, the stack and the LCD", data, mask)) end
    end)
  end
  T.installs = (T.installs or 0) + 1
end
local function wide_off()
  for _, t in ipairs(T.wide or {}) do t:remove() end
  T.wide = nil
end
T.tick = emu.register_periodic(function()
  if T.armed and not T.wide then wide_on() elseif not T.armed and T.wide then wide_off() end
end)
emu.print_error(string.format("PREFILL cpu tap installed at t=%.4f (state PC, SP)", mac.time:as_double()))

function _G.PREFILL_END(out)
  local f = io.open(out .. "/cpu_tap.txt", "w")
  local keys = {}
  for b in pairs(T.R) do keys[#keys + 1] = b end
  table.sort(keys)
  for _, b in ipairs(keys) do f:write(string.format("R %08X %d\n", b << 16, T.R[b])) end
  keys = {}
  for b in pairs(T.W) do keys[#keys + 1] = b end
  table.sort(keys)
  for _, b in ipairs(keys) do f:write(string.format("W %08X %d\n", b << 16, T.W[b])) end
  for _, ln in ipairs(T.bad) do f:write(ln .. "\n") end
  f:write(string.format("LCDCHANGED %d\n", T.lcdchg))
  f:write(string.format("TOTAL chunks %d reads %d writes %d bad %d taps %d\n", T.chunks, T.nr, T.nw, T.nbad,
    T.installs or 0))
  f:close()
  emu.print_error(string.format("PREFILL cpu tap end: %d chunks armed, %d reads, %d writes by the probe, %d bad",
    T.chunks, T.nr, T.nw, T.nbad))
end
