local Core = {}

function Core.json_encode(tbl)
  local function escape(s)
    s = s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
    return s
  end
  local parts = {'{'}
  local first = true
  for k, v in pairs(tbl) do
    if not first then table.insert(parts, ',') end
    first = false
    table.insert(parts, '"' .. tostring(k) .. '"')
    table.insert(parts, ':')
    local t = type(v)
    if t == 'string' then
      table.insert(parts, '"' .. escape(v) .. '"')
    elseif t == 'number' then
      table.insert(parts, tostring(v))
    elseif t == 'boolean' then
      table.insert(parts, v and 'true' or 'false')
    elseif v == nil then
      table.insert(parts, 'null')
    else
      table.insert(parts, '"' .. escape(tostring(v)) .. '"')
    end
  end
  table.insert(parts, '}')
  return table.concat(parts)
end

function Core.json_decode(str)
  local ok, res = pcall(function()
    local obj = {}
    str = tostring(str or '')
    str = str:match('^%s*%{(.*)%}%s*$') or ''
    for key, val in str:gmatch('%s*"([^"]+)"%s*:%s*([^,]+)') do
      val = val:gsub('%s+$','')
      if val:sub(1,1) == '"' then
        local s = val:match('^"(.*)"$') or ''
        s = s:gsub('\\"','"'):gsub('\\n','\n'):gsub('\\r','\r'):gsub('\\\\','\\')
        obj[key] = s
      elseif val == 'true' or val == 'false' then
        obj[key] = (val == 'true')
      elseif val == 'null' then
        obj[key] = nil
      else
        obj[key] = tonumber(val)
      end
    end
    return obj
  end)
  if ok then return res else return nil end
end

function Core.make_link_key(collection)
  return 'wp.linkedCollections.' .. tostring(collection.localIdentifier)
end

function Core.check_uniqueness(entries, currentLocalId, wp_type, wp_id)
  for _, e in ipairs(entries or {}) do
    if e.collectionLocalId ~= currentLocalId then
      local i = e.info or {}
      if tostring(i.wp_type) == tostring(wp_type) and tostring(i.wp_id) == tostring(wp_id) then
        return e
      end
    end
  end
  return nil
end

return Core


