-- Phase 2 exit test harness (run.sh).  After the firmware has booted, stop the main CPU's own work, copy the test
-- binary into work DRAM, point PC at it and let it run; then read the result block and compare.  Interrupts are
-- disabled by the test's first instruction, so the firmware does not run again.
local bin_path = os.getenv("CC900_TEST_BIN")
local load_at = tonumber(os.getenv("CC900_LOAD_AT"))
local res_at = tonumber(os.getenv("CC900_RESULTS_AT"))
local out_path = os.getenv("CC900_OUT")
local cpu = manager.machine.devices[":maincpu"]
local space = cpu.spaces["program"]
local frames, state = 0, "boot"
local function report(lines)
  local f = io.open(out_path, "w"); f:write(table.concat(lines, "\n") .. "\n"); f:close()
  manager.machine:exit()
end
emu.register_frame_done(function()
  frames = frames + 1
  if state == "boot" and frames == 600 then           -- about ten seconds: the firmware is up and idle
    local f = io.open(bin_path, "rb"); local data = f:read("*a"); f:close()
    for i = 1, #data do space:write_u8(load_at + i - 1, data:byte(i)) end
    space:write_u16(res_at, 0)
    cpu.state["PC"].value = load_at
    state = "run"
  elseif state == "run" and space:read_u16(res_at) == 0xc900 then
    local function u16(o) return space:read_u16(res_at + o) end
    local function u32(o)                              -- two words: cc900 aligns a long to 2, read_u32 wants 4
      return space:read_u16(res_at + o) + 65536 * space:read_u16(res_at + o + 2) end
    local function str(o, n) local s = {} for i = 0, n - 1 do local c = space:read_u8(res_at + o + i)
      if c == 0 then break end s[#s + 1] = string.char(c) end return table.concat(s) end
    report({ "len5 " .. u16(2), "len3 " .. u16(4), "cmp_lt " .. u16(6), "cmp_eq " .. u16(8),
             "chr_off " .. u16(10), "quot " .. u32(12), "rem " .. u32(16), "cat " .. str(20, 12),
             "hex " .. str(32, 12), "fill " .. str(44, 8) })
  elseif state == "run" and frames > 1200 then
    report({ "timeout: the test did not finish (PC " .. string.format("%06x", cpu.state["PC"].value) .. ")" })
  end
end)
