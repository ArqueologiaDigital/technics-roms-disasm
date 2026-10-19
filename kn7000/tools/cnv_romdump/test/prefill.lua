-- (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
--
-- prefill.lua -- test data for the ROMs nobody has dumped, so that the dumper's reads can be checked
-- byte for byte (verify_dump.py makes the same data). Run once, before the dump starts, in upstream
-- MAME's kn7000 (dofile from a remote.lua command file):
--   * each wave ROM region (waveform_main_y/_x, waveform_sub_y/_x; NO_DUMP, so zero-filled) gets
--     u32 i = H(seed, i), written little-endian with write_u32;
--   * the picture window 0x57800000-0x57FFFFFF, which the driver does not map, answers every read
--     with the u32 H(seed, (address - 0x57800000) >> 2), through a read tap;
--   * so does each of the SURVEY build's six 8 MB windows (CS0 0x40000000, 0x40800000; CS5 0x54000000,
--     0x54800000, 0x55000000, 0x55800000), with seed = its base >> 16. None is mapped by the driver.
-- H(seed, i) = lowbias32((i * 0x9E3779B9 + seed) mod 2^32).
local function h32(x)
  x = x & 0xffffffff
  x = x ~ (x >> 16); x = (x * 0x7feb352d) & 0xffffffff
  x = x ~ (x >> 15); x = (x * 0x846ca68b) & 0xffffffff
  x = x ~ (x >> 16)
  return x
end
local SEEDS = { [":waveform_main_y"] = 0x203, [":waveform_main_x"] = 0x204,
                [":waveform_sub_y"] = 0x207, [":waveform_sub_x"] = 0x208 }
local PICTURE_SEED = 0x19
for tag, seed in pairs(SEEDS) do
  local r = manager.machine.memory.regions[tag]
  if r then
    for i = 0, r.size // 4 - 1 do r:write_u32(i * 4, h32(i * 0x9E3779B9 + seed)) end
    emu.print_error(string.format("PREFILL %s %d bytes seed %#x", tag, r.size, seed))
  else
    emu.print_error("PREFILL no region " .. tag)
  end
end
local sp = manager.machine.devices[":maincpu"].spaces["program"]
_G.PREFILL_TAP = sp:install_read_tap(0x57800000, 0x57ffffff, "picture_test", function(offset, data, mask)
  return h32(((offset - 0x57800000) >> 2) * 0x9E3779B9 + PICTURE_SEED)
end)
emu.print_error("PREFILL picture tap 0x57800000-0x57FFFFFF seed 0x19")
_G.PREFILL_SURVEY = {}
for _, base in ipairs({ 0x40000000, 0x40800000, 0x54000000, 0x54800000, 0x55000000, 0x55800000 }) do
  local seed = base >> 16
  _G.PREFILL_SURVEY[#_G.PREFILL_SURVEY + 1] = sp:install_read_tap(base, base + 0x7fffff,
    string.format("survey_%08x", base), function(offset, data, mask)
      return h32(((offset - base) >> 2) * 0x9E3779B9 + seed)
    end)
end
emu.print_error("PREFILL survey taps: 6 x 8 MB at 0x40000000, 0x40800000, 0x54000000-0x55800000, seed base >> 16")
