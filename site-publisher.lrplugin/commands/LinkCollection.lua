local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local LrBinding = import 'LrBinding'
local LrPrefs = import 'LrPrefs'
local LrApplication = import 'LrApplication'

local Log = require 'Log'
local Linked = require 'LinkedCollections'
local LrDialogs = import 'LrDialogs'

LrFunctionContext.postAsyncTaskWithContext('linkCollection', function(context)
  -- Route uncaught errors to a dialog and avoid using raw pcall which can cause yield issues
  LrDialogs.attachErrorDialogToFunctionContext(context)
      local catalog = LrApplication.activeCatalog()
      Log.info('Link command invoked')
      local collection = Linked.get_active_collection(catalog)
      if not collection then
        Log.warn('Link aborted: no valid active collection')
        LrDialogs.message('Site Publisher', 'Please select exactly one regular collection in Library.', 'info')
        return
      end

      local prefs = LrPrefs.prefsForPlugin()
      local f = LrView.osFactory()
      local props = LrBinding.makePropertyTable(context)
      props.base_url = prefs.wp_base_url or ''
      props.wp_type = 'post'
      props.wp_id = ''

      local c = f:column {
        bind_to_object = props,
        spacing = f:control_spacing(),
        f:row { f:static_text { title = 'WordPress Base URL:' }, f:edit_field { value = LrView.bind('base_url'), width_in_chars = 40 } },
        f:row { f:static_text { title = 'Object Type:' }, f:edit_field { value = LrView.bind('wp_type'), width_in_chars = 20 } },
        f:row { f:static_text { title = 'Object ID:' }, f:edit_field { value = LrView.bind('wp_id'), width_in_chars = 20 } },
        f:spacer { height = 10 },
        f:static_text { title = 'Note: Authentication will be added in a future step.', fill_horizontal = 1 },
      }

      local btn = LrDialogs.presentModalDialog { title = 'Link Current Collection', contents = c, blockTask = true }
      if btn ~= 'ok' then Log.info('Link dialog canceled'); return end

      props.base_url = (props.base_url or ''):gsub('%s+$','')
      if props.base_url == '' then
        Log.warn('Validation failed: base_url required')
        LrDialogs.message('Site Publisher', 'Base URL is required.', 'error')
        return
      end
      local wp_id_str = tostring(props.wp_id or ''):match('^%s*(.-)%s*$')
      if wp_id_str == '' then
        Log.warn('Validation failed: wp_id empty')
        LrDialogs.message('Site Publisher', 'Object ID is required.', 'error')
        return
      end

      prefs.wp_base_url = props.base_url

      local info = Linked.read_link_info(catalog, collection) or {}
      info.wp_type = tostring(props.wp_type or 'post')
      info.wp_id = wp_id_str
      info.wp_url = props.base_url
      info.linked_at = os.date('!%Y-%m-%dT%H:%M:%SZ')

      local wrote, werr = Linked.write_link_info(catalog, collection, info)
      if not wrote then
        Log.error('Link failed:', tostring(werr))
        LrDialogs.message('Site Publisher', 'Failed to link: ' .. tostring(werr), 'error')
        return
      end

      Log.info('Linked collection', collection:getName(), 'to', info.wp_type, '#' .. tostring(info.wp_id))
      LrDialogs.message('Site Publisher', 'Collection linked to ' .. info.wp_type .. ' #' .. info.wp_id .. '.', 'info')
  -- No raw pcall here; attachErrorDialogToFunctionContext will surface uncaught errors
end)


