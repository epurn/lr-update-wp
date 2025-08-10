local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'

local Log = require 'Log'
local Core = require 'LinkedCollectionsCore'

local function assert_eq(a, b, msg)
  if a ~= b then error((msg or 'assert_eq failed') .. ': ' .. tostring(a) .. ' ~= ' .. tostring(b)) end
end

local function test_json_roundtrip()
  local t = { wp_type = 'post', wp_id = 123, wp_url = 'https://x', linked_at = 't' }
  local s = Core.json_encode(t)
  local d = Core.json_decode(s)
  assert_eq(d.wp_type, 'post', 'wp_type')
  assert_eq(d.wp_id, 123, 'wp_id')
  assert_eq(d.wp_url, 'https://x', 'wp_url')
end

local function test_make_key()
  local k = Core.make_link_key({ localIdentifier = 42 })
  assert_eq(k, 'wp.linkedCollections.42')
end

local function test_uniqueness()
  local entries = {
    { collectionLocalId = 1, info = { wp_type = 'post', wp_id = 100 } },
    { collectionLocalId = 2, info = { wp_type = 'post', wp_id = 200 } },
  }
  local c = Core.check_uniqueness(entries, 1, 'post', 200)
  assert(c and c.collectionLocalId == 2, 'should conflict with collection 2')
  local none = Core.check_uniqueness(entries, 1, 'page', 200)
  assert(none == nil, 'should not conflict with different type')
end

local tests = {
  { name = 'json roundtrip', fn = test_json_roundtrip },
  { name = 'make key', fn = test_make_key },
  { name = 'uniqueness', fn = test_uniqueness },
}

LrFunctionContext.callWithContext('runSelfTests', function()
  LrTasks.startAsyncTask(function()
    Log.info('Self-tests started')
    -- Write a quick self-test banner to logs
    Log.info('Running self-tests')
    local passes, failures = 0, 0
    local msgs = {}
    for _, t in ipairs(tests) do
      local ok, err = pcall(t.fn)
      if ok then
        passes = passes + 1
        Log.info('Test passed:', t.name)
      else
        failures = failures + 1
        table.insert(msgs, t.name .. ': ' .. tostring(err))
        Log.error('Test failed:', t.name, tostring(err))
      end
    end
    local summary = string.format('Self-tests: %d passed, %d failed', passes, failures)
    local detail = summary
    if failures == 0 then
      Log.info(summary)
      LrDialogs.message('Site Publisher', detail, 'info')
    else
      Log.error(summary)
      LrDialogs.message('Site Publisher', detail .. '\n\n' .. table.concat(msgs, '\n'), 'error')
    end
  end)
end)


