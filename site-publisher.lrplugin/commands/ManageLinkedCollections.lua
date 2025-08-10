local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local LrBinding = import 'LrBinding'
local LrApplication = import 'LrApplication'

local Log = require 'Log'
local Linked = require 'LinkedCollections'

local function open_edit_dialog(context, catalog, collection, existing)
  local f = LrView.osFactory()
  local props = LrBinding.makePropertyTable(context)
  props.base_url = existing.wp_url or ''
  props.wp_type = existing.wp_type or 'post'
  props.wp_id = tostring(existing.wp_id or '')
  local c = f:column {
    bind_to_object = props,
    spacing = f:control_spacing(),
    f:row { f:static_text { title = 'WordPress Base URL:' }, f:edit_field { value = LrView.bind('base_url'), width_in_chars = 40 } },
    f:row { f:static_text { title = 'Object Type:' }, f:edit_field { value = LrView.bind('wp_type'), width_in_chars = 20 } },
    f:row { f:static_text { title = 'Object ID:' }, f:edit_field { value = LrView.bind('wp_id'), width_in_chars = 20 } },
    f:spacer { height = 10 },
    f:static_text { title = 'Note: Authentication will be added in a future step.' },
  }
  local btn = LrDialogs.presentModalDialog { title = 'Edit Link', contents = c, blockTask = true }
  if btn ~= 'ok' then return end
  local wp_id_str = tostring(props.wp_id or ''):match('^%s*(.-)%s*$')
  if wp_id_str == '' then
    Log.warn('Manage edit: wp_id empty')
    LrDialogs.message('Site Publisher', 'Object ID is required.', 'error')
    return
  end
  local info = {
    wp_type = tostring(props.wp_type or 'post'),
    wp_id = wp_id_str,
    wp_url = props.base_url or '',
    linked_at = existing.linked_at or os.date('!%Y-%m-%dT%H:%M:%SZ'),
  }
  LrTasks.startAsyncTask(function()
    local ok, err = Linked.write_link_info(catalog, collection, info)
    if not ok then
      Log.error('Manage edit save failed:', tostring(err))
      LrDialogs.message('Site Publisher', 'Failed to save: ' .. tostring(err), 'error')
      return
    end
    Log.info('Manage edit saved for collection', tostring(collection.localIdentifier))
  end)
end

LrFunctionContext.postAsyncTaskWithContext('manageLinkedCollections', function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)
  Log.info('Manage Linked Collections opened')
  local catalog = LrApplication.activeCatalog()
  local entries = Linked.list_all_links(catalog)
  local f = LrView.osFactory()
  local rows = {}
  for _, e in ipairs(entries) do
    table.insert(rows, f:row {
      spacing = f:control_spacing(),
      f:static_text { title = e.collectionName, width_in_chars = 28 },
      f:static_text { title = string.format('%s #%s', tostring(e.info.wp_type), tostring(e.info.wp_id)), width_in_chars = 18 },
      f:push_button {
        title = 'Edit',
        action = function()
          Log.info('Edit link for', e.collectionName)
          open_edit_dialog(context, catalog, { localIdentifier = e.collectionLocalId, getName = function() return e.collectionName end }, e.info)
        end,
      },
      f:push_button {
        title = 'Unlink',
        action = function()
          Log.info('Unlink from Manage dialog for', e.collectionName)
          local resp = LrDialogs.confirm('Unlink', 'Unlink collection "' .. e.collectionName .. '"?', 'Unlink', 'Cancel')
          if resp == 'ok' then
            local fakeCollection = { localIdentifier = e.collectionLocalId }
            LrTasks.startAsyncTask(function()
              local ok, err = Linked.unlink(catalog, fakeCollection)
              if not ok then
                Log.error('Unlink from manage failed:', tostring(err))
                LrDialogs.message('Site Publisher', 'Failed to unlink: ' .. tostring(err), 'error')
              else
                Log.info('Unlinked from manage for collection', tostring(fakeCollection.localIdentifier))
              end
            end)
          end
        end,
      },
    })
  end
  if #rows == 0 then
    rows = { f:static_text { title = 'No linked collections.' } }
  end
  local contents = f:column {
    spacing = f:control_spacing(),
    unpack(rows),
  }
  LrDialogs.presentModalDialog { title = 'Manage Linked Collections', contents = contents, blockTask = true }
end)


