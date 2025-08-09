local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrTasks = import 'LrTasks'
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'

LrFunctionContext.callWithContext('verifySetup', function()
  LrTasks.startAsyncTask(function()
    local plugin_dir = _PLUGIN.path
    local logs_dir = LrPathUtils.child(plugin_dir, 'logs')
    local log_file = LrPathUtils.child(logs_dir, 'site-publisher.log')

    LrFileUtils.createAllDirectories(logs_dir)

    local ok, err = pcall(function()
      local fh, ioerr = io.open(log_file, 'a')
      assert(fh, ioerr)
      fh:write(os.date('!%Y-%m-%dT%H:%M:%SZ'), ' [Verify] Test write from Verify Setup\n')
      fh:close()
    end)

    if ok then
      LrDialogs.message('Site Publisher', 'Wrote to: ' .. log_file, 'info')
    else
      LrDialogs.message('Site Publisher', 'Failed to write log at: ' .. log_file .. '\nError: ' .. tostring(err), 'error')
    end
  end)
end)


