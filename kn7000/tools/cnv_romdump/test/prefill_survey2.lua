-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- prefill_survey2.lua -- test data for the SURVEY2 build (romdump.s Survey2Table). Run once from dump.cmd.in's
-- @PREFILL_LATE@ line, after the boot: the firmware's own boot-time probes of these windows (the rhythm ROM
-- header, the expansion slots) then see what the driver maps there, not test data.
--   * Windows a KN7000 driver maps with nothing the test can predict -- SurveyTable's six (CS0 0x40000000,
--     0x40800000; CS5 0x54000000-0x55800000), the four expansion slots (0x41000000, 0x41800000, 0x56000000,
--     0x57000000, 64 KB each) and 0x56800000 (2 MB) -- answer every read with u32 H(base >> 16, (address -
--     base) >> 2), as prefill.lua's survey taps do. verify_dump.py makes the same data.
--   * The three RAM windows the firmware uses -- IC23 0x44000000-0x441FFFFF, the work RAM 0x50180000-0x50297FFF
--     and the library RAM 0x4C000000-0x4C03FFFF -- are not overwritten. Their reference is what the CPU reads
--     there when the dump has ended (PREFILL_END, called by dump.cmd.in's end line). A write tap on each,
--     and on the 0x84000000 and 0x8C000000 aliases, logs every word written once the dumper runs, which
--     accounts for any difference.
--   * The exception is 0x44040000-0x441FFFFF when the driver maps 0x44000000 as plain RAM (the 16 MB "ram44"
--     placeholder). The firmware never writes there, so it gets u32 H(0x4404, i), and the dump must show
--     it. When the driver models IC23 as a 256 KB chip mirrored through the window, that range is the chip
--     itself, and it is left alone. One word decides: write 0x44040100, see whether 0x44000100 follows, put
--     the word back at once.
-- H(seed, i) = lowbias32((i * 0x9E3779B9 + seed) mod 2^32), as in prefill.lua.
local function h32(x)
  x = x & 0xffffffff
  x = x ~ (x >> 16); x = (x * 0x7feb352d) & 0xffffffff
  x = x ~ (x >> 15); x = (x * 0x846ca68b) & 0xffffffff
  x = x ~ (x >> 16)
  return x
end
local sp = manager.machine.devices[":maincpu"].spaces["program"]
local S2 = { taps = {}, writes = {}, armed = false }
_G.S2 = S2

-- read taps: the windows with test data
local TAPPED = { { 0x40000000, 0x800000 }, { 0x40800000, 0x800000 }, { 0x54000000, 0x800000 },
                 { 0x54800000, 0x800000 }, { 0x55000000, 0x800000 }, { 0x55800000, 0x800000 },
                 { 0x56800000, 0x200000 }, { 0x41000000, 0x10000 }, { 0x41800000, 0x10000 },
                 { 0x56000000, 0x10000 }, { 0x57000000, 0x10000 } }
for _, w in ipairs(TAPPED) do
  local base, len, seed = w[1], w[2], w[1] >> 16
  S2.taps[#S2.taps + 1] = sp:install_read_tap(base, base + len - 1, string.format("survey2_%08x", base),
    function(offset, data, mask) return h32(((offset - base) >> 2) * 0x9E3779B9 + seed) end)
end
emu.print_error(string.format("PREFILL survey2: %d read taps, seed base >> 16", #TAPPED))

-- IC23: plain RAM or a mirrored 256 KB chip?
local a, m = 0x44040100, 0x44000100
local oa, om = sp:read_u32(a), sp:read_u32(m)
sp:write_u32(a, om ~ 0x5AA55AA5)
S2.mirrored = sp:read_u32(m) ~= om
sp:write_u32(a, oa)
if S2.mirrored then
  emu.print_error("PREFILL survey2: 0x44040000 mirrors 0x44000000 (IC23 as a 256 KB chip): left alone")
else
  for i = 0, 0x1C0000 // 4 - 1 do sp:write_u32(0x44040000 + i * 4, h32(i * 0x9E3779B9 + 0x4404)) end
  emu.print_error("PREFILL survey2: 0x44000000 is plain RAM: 0x44040000-0x441FFFFF filled, seed 0x4404")
end

-- write taps: every word written into the RAM windows once the dumper is running (S2.armed)
local RAMWIN = { { "44000000", 0x44000000, 0x200000 }, { "44000000", 0x84000000, 0x200000 },
                 { "50180000", 0x50180000, 0x118000 },
                 { "4c000000", 0x4C000000, 0x40000 }, { "4c000000", 0x8C000000, 0x40000 } }
for _, w in ipairs(RAMWIN) do
  local name, base, len = w[1], w[2], w[3]
  S2.writes[name] = S2.writes[name] or {}
  local log = S2.writes[name]
  S2.taps[#S2.taps + 1] = sp:install_write_tap(base, base + len - 1, string.format("survey2w_%08x", base),
    function(offset, data, mask)
      if S2.armed then log[(offset - base) & ~3] = true end
    end)
end
S2.tick = emu.register_periodic(function()
  if not S2.armed and sp:read_u32(0x502E0000) >= 1 then
    S2.armed = true
    emu.print_error(string.format("PREFILL survey2: the dumper runs, write logging armed at t=%.1f",
      manager.machine.time:as_double()))
  end
end)

-- at the end: what the CPU reads in each RAM window, and the words written there during the run
function _G.PREFILL_END(out)
  for _, w in ipairs({ { "44000000", 0x44000000, 0x200000 }, { "50180000", 0x50180000, 0x118000 },
                       { "4c000000", 0x4C000000, 0x40000 } }) do
    local name, base, len = w[1], w[2], w[3]
    local f = io.open(out .. "/ref_" .. name .. ".bin", "wb")
    local b = {}
    for p = base, base + len - 2, 2 do
      b[#b + 1] = string.pack("<I2", sp:read_u16(p))
      if #b == 4096 then f:write(table.concat(b)); b = {} end
    end
    f:write(table.concat(b)); f:close()
    local offs = {}
    for o in pairs(S2.writes[name]) do offs[#offs + 1] = o end
    table.sort(offs)
    local g = io.open(out .. "/writes_" .. name .. ".txt", "w")
    if name == "44000000" then g:write(S2.mirrored and "model mirrored\n" or "model plain\n") end
    for _, o in ipairs(offs) do g:write(string.format("%x\n", o)) end
    g:close()
    emu.print_error(string.format("PREFILL survey2 end: %s saved, %d words written during the run", name, #offs))
  end
end
