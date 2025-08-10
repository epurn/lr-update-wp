local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'
local LrApplication = import 'LrApplication'

local Log = require 'Log'
local Linked = require 'LinkedCollections'

LrFunctionContext.callWithContext('unlinkCollection', function()
  LrTasks.startAsyncTask(function()
    local catalog = LrApplication.activeCatalog()
    Log.info('Unlink command invoked')
    local collection = Linked.get_active_collection(catalog)
    if not collection then
      Log.warn('Unlink aborted: no valid active collection')
      LrDialogs.message('Site Publisher', 'Please select exactly one regular collection in Library.', 'info')
      return
    end
    local info = Linked.read_link_info(catalog, collection)
    if not info then
      Log.info('Unlink aborted: collection not linked')
      LrDialogs.message('Site Publisher', 'This collection is not linked.', 'info')
      return
    end
    local resp = LrDialogs.confirm(
      'Unlink Collection',
      string.format('Unlink "%s" from %s #%s?', collection:getName(), tostring(info.wp_type), tostring(info.wp_id)),
      'Unlink',
      'Cancel'
    )
    if resp ~= 'ok' then Log.info('Unlink canceled'); return end
    local ok, err = Linked.unlink(catalog, collection)
    if not ok then
      Log.error('Unlink failed:', tostring(err))
      LrDialogs.message('Site Publisher', 'Failed to unlink: ' .. tostring(err), 'error')
      return
    end
    Log.info('Unlinked collection', collection:getName())
    LrDialogs.message('Site Publisher', 'Unlinked.', 'info')
  end)
end)


