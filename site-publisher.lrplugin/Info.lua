--[[
  Site Publisher - Skeleton Info.lua
  Minimal metadata and a single Library menu command for verifying setup.
]]

return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,

  LrToolkitIdentifier = 'io.github.epurn.lr.sitepublisher',
  LrPluginName = 'Site Publisher',

  LrLibraryMenuItems = {
    {
      title = 'Verify Setup',
      file = 'VerifySetup.lua',
    },
  },

  LrInitPlugin = 'Init.lua',

  VERSION = { major = 0, minor = 1, revision = 0 },
}


