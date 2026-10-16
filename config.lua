-- List model names you want automatically deletable.
-- Use the object model name (as seen in GTA V model lists), e.g. "prop_barrel_02a", "prop_chair_01a", "prop_tree_pine_01"
-- You can also add model hashes (numbers) instead of names.
--
-- Example:
-- models = {
--   "prop_tree_pine_01",
--   "prop_chair_01a",
--   1234567890, -- hash example
-- }

Config = {}
Config.models = {
  -- add model names or hashes here:
  -- "prop_tree_pine_01",
  -- "prop_chair_01a",
}

-- Default radius (meters) used by the /delobjs command if no radius is supplied
Config.defaultRadius = 50

-- When true, the resource will automatically scan and remove matching objects near the player every `Config.autoScanInterval` ms.
-- Use with caution (may remove a lot of props and is client-side only).
Config.autoScan = false
Config.autoScanInterval = 5000 -- ms
