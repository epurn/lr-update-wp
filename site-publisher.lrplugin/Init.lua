local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'

local logger = LrLogger('site_publisher')
logger:enable('logfile')

logger:info('Site Publisher plugin initialized')

-- Write a simple line to a log file inside the plugin folder
local plugin_dir = _PLUGIN.path
local logs_dir = LrPathUtils.child(plugin_dir, 'logs')
local log_file = LrPathUtils.child(logs_dir, 'site-publisher.log')
LrFileUtils.createAllDirectories(logs_dir)
local fh, err = io.open(log_file, 'a')
if fh then
  fh:write(os.date('!%Y-%m-%dT%H:%M:%SZ'), ' [Init] Site Publisher initialized (plugin logs)\n')
  fh:close()
else
  logger:warn('Failed to open plugin log file at ', tostring(log_file), ': ', tostring(err))
end

return true


