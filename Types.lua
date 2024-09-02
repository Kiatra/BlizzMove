--- @meta _

----------------------------------------
-- BlizzMove API Types
----------------------------------------
--- @alias BlizzMoveAPI_FrameTable table<string, BlizzMoveAPI_FrameData> # Frame name as key
--- @alias BlizzMoveAPI_AddonFrameTable table<string, BlizzMoveAPI_FrameTable> # Addon name as key, these can be LoD addons

--- @class BlizzMoveAPI_FrameData
--- @field SubFrames table<string, BlizzMoveAPI_SubFrameData>|nil # Sub frame name as key, sub frames may be nested to any depth
--- @field FrameReference Frame|nil # Reference to the frame to be moved, if nil, the frame will be looked up by name
--- @field MinVersion number|nil # First Interface version that is considered compatible
--- @field MaxVersion number|nil # Last Interface version that is consider compatible
--- @field MinBuild number|nil # First Interface build number that is considered compatible
--- @field MaxBuild number|nil # Last Interface build number that is considered compatible
--- @field VersionRanges BlizzMoveAPI_Range[]|nil # Interface version ranges, can be combined with MinVersion and MaxVersion
--- @field BuildRanges BlizzMoveAPI_Range[]|nil # Interface build number ranges, can be combined with MinBuild and MaxBuild
--- @field SilenceCompatabilityWarnings boolean|nil # Suppress warnings caused by compatibility checks against Interface version and build number
--- @field IgnoreMouse boolean|nil # Ignore all mouse events, same as setting both IgnoreMouseWheel and NonDraggable to true
--- @field IgnoreMouseWheel boolean|nil # Ignore mouse wheel events
--- @field NonDraggable boolean|nil # Ignore mouse drag events
--- @field IgnoreClamping boolean|nil # If true, BlizzMove will not modify the frame's clamping behaviour
--- @field DefaultDisabled boolean|nil # Disables moving the frame in the settings by default, requiring the user to enable it manually
--- @field IgnoreSavedPositionWhenMaximized boolean|nil # Ignore the stored position when the frame is maximized (checks frame.isMaximized for this)

--- @class BlizzMoveAPI_SubFrameData: BlizzMoveAPI_FrameData
--- @field Detachable boolean|nil # Allow the frame to be detached from the parent and moved independently
--- @field ForceParentage boolean|nil # Will call child:SetParent(parent) on registration
--- @field ManuallyScaleWithParent boolean|nil # Manually scale the frame with the parent; will call SetScale on the child whenever the parent's scale is updated

--- @class BlizzMoveAPI_Range
--- @field Min number|nil # Either Min, Max, or both must be filled
--- @field Max number|nil # Either Min, Max, or both must be filled

----------------------------------------
-- BlizzMove Internal Types
----------------------------------------
--- @class BlizzMove_FrameData: BlizzMoveAPI_SubFrameData
--- @field storage BlizzMove_FrameStorage
--- @field SubFrames table<string, BlizzMove_FrameData>|nil

--- @class BlizzMove_FrameStorage
--- @field frame Frame
--- @field frameName string
--- @field addOnName string
--- @field frameParent Frame?
--- @field points BlizzMove_PointsStorage?
--- @field isMoving boolean?
--- @field detached boolean?
--- @field disabled boolean?
--- @field hooked boolean

--- @class BlizzMove_PointsStorage
--- @field dragged boolean|nil
--- @field startPoints BlizzMove_FramePoint[]|nil
--- @field dragPoints BlizzMove_FramePoint[]|nil
--- @field detachPoints BlizzMove_FramePoint[]|nil

--- @class BlizzMove_FramePoint
--- @field anchorPoint FramePoint
--- @field relativeFrame Frame?
--- @field relativeFrameName string?
--- @field relativePoint FramePoint
--- @field offX number
--- @field offY number

--- @class BlizzMove_CombatLockdownQueueItem
--- @field func function
--- @field args any[]

--- @class BlizzMoveDB
--- @field DebugPrints boolean?
--- @field requireMoveModifier boolean?
--- @field savePosStrategy BlizzMove_SavePosStrategy
--- @field saveScaleStrategy BlizzMove_SaveScaleStrategy
--- @field points table<string, BlizzMove_PointsStorage> # [frameName] = BlizzMove_PointsStorage
--- @field scales table<string, number> # [frameName] = scale
--- @field disabledFrames table<string, table<string, boolean>>|nil # [addonName][frameName] = true
--- @field enabledFrames table<string, table<string, boolean>>|nil # [addonName][frameName] = true

--- @alias BlizzMove_SavePosStrategy "session"|"permanent"|"off"
--- @alias BlizzMove_SaveScaleStrategy "session"|"permanent"|
