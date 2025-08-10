local LrTasks = import 'LrTasks'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'

local Core = require 'LinkedCollectionsCore'
local Log = require 'Log'

local M = {}

local json_encode = Core.json_encode
local json_decode = Core.json_decode
local make_link_key = Core.make_link_key

function M.get_active_collection(catalog)
  local sources = catalog:getActiveSources()
  if not sources or #sources ~= 1 then return nil end
  local col = sources[1]
  if col and col.type and col:type() == 'LrCollection' then
    if col.isSmartCollection and col:isSmartCollection() then return nil end
    return col
  end
  return nil
end

function M.read_link_info(catalog, collection)
  local key = make_link_key(collection)
  local raw = catalog:getPropertyForPlugin(_PLUGIN, key)
  if not raw or raw == '' then return nil end
  local decoded = json_decode(raw)
  if not decoded then
    Log.warn('Failed to decode link info for key', key)
  end
  return decoded
end

function M.list_all_links(catalog)
  local results = {}
  local allCollections = catalog:getChildCollections()
  for _, c in ipairs(allCollections or {}) do
    if not (c.isSmartCollection and c:isSmartCollection()) then
      local info = M.read_link_info(catalog, c)
      if info then
        table.insert(results, { collectionLocalId = c.localIdentifier, collectionName = c:getName(), info = info })
      end
    end
  end
  return results
end

local function violates_uniqueness(catalog, currentCollection, info)
  local entries = M.list_all_links(catalog)
  local conflict = Core.check_uniqueness(entries, currentCollection.localIdentifier, info.wp_type, info.wp_id)
  if conflict then return true, conflict end
  return false, nil
end

function M.write_link_info(catalog, collection, info)
  local violates, existing = violates_uniqueness(catalog, collection, info)
  if violates then
    return false, string.format('This WordPress object is already linked by collection "%s" (ID %s).', existing.collectionName, tostring(existing.collectionLocalId))
  end
  local key = make_link_key(collection)
  local json = json_encode(info)
  local result = catalog:withWriteAccessDo('Link collection', function()
    catalog:setPropertyForPlugin(_PLUGIN, key, json)
  end)
  return true
end

function M.unlink(catalog, collection)
  local key = make_link_key(collection)
  local result = catalog:withWriteAccessDo('Unlink collection', function()
    catalog:setPropertyForPlugin(_PLUGIN, key, nil)
  end)
  return true
end

function M.remove_orphaned_links(catalog)
  return true
end

M.json_encode = json_encode
M.json_decode = json_decode
M.make_link_key = make_link_key

return M


