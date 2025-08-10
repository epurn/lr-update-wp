-- Lightroom logger configuration for Site Publisher
-- Ensures verbose logging and file output are enabled for our logger.

loggers = loggers or {}
loggers.site_publisher = {
  logLevel = 'trace',
  action = 'logfile',
}


