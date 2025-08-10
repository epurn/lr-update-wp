--[[
  Site Publisher - Skeleton Info.lua
  Minimal metadata and a single Library menu command for verifying setup.
]]

local ENABLE_SELF_TESTS = true

local libraryMenu = {
  { title = 'Verify Setup', file = 'VerifySetup.lua' },
  { title = 'Link Current Collection…', file = 'commands/LinkCollection.lua' },
  { title = 'Unlink Current Collection', file = 'commands/UnlinkCollection.lua' },
  { title = 'Manage Linked Collections…', file = 'commands/ManageLinkedCollections.lua' },
}

if ENABLE_SELF_TESTS then
  libraryMenu[#libraryMenu + 1] = { title = 'Run Plugin Self-Tests…', file = 'commands/RunSelfTests.lua' }
end

return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrToolkitIdentifier = 'io.github.epurn.lr.sitepublisher',
  LrPluginName = 'Site Publisher',
  LrLibraryMenuItems = libraryMenu,
  LrInitPlugin = 'Init.lua',
  VERSION = { major = 0, minor = 1, revision = 0 },
}


