import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as StackSet
import qualified Data.Map        as Map

myKeys conf@(XConfig {XMonad.modMask = modm}) = Map.fromList $
  [
    -- launch a terminal
    ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
    -- launch dmenu
    ((modm, xK_p), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\""),

    -- close focused window
    ((modm .|. shiftMask, xK_c), kill),

    -- Rotate through the available layout algorithms
    ((modm, xK_space ), sendMessage NextLayout),
    --  Reset the layouts on the current workspace to default
    ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),

    -- Resize viewed windows to the correct size
    ((modm, xK_n), refresh),


    -- Move focus to the next window
    ((modm, xK_j), windows StackSet.focusDown),
    -- Move focus to the previous window
    ((modm, xK_k), windows StackSet.focusUp),

    -- Swap the focused window with the next window
    ((modm .|. shiftMask, xK_j), windows StackSet.swapDown),
    -- Swap the focused window with the previous window
    ((modm .|. shiftMask, xK_k), windows StackSet.swapUp),


    -- Go to the previous workspace
    ((modm, xK_h), prevWS),
    -- Go to the next workspace
    ((modm, xK_l), nextWS),

    -- Move to the previous workspace
    ((modm .|. shiftMask, xK_h), shiftToPrev >> prevWS),
    -- Move to the next workspace
    ((modm .|. shiftMask, xK_l), shiftToNext >> nextWS),

    -- Shrink the master area
    ((modm .|. controlMask .|. shiftMask, xK_h), sendMessage Shrink),
    -- Expand the master area
    ((modm .|. controlMask .|. shiftMask, xK_l), sendMessage Expand),


    -- Move focus to the master window
    ((modm, xK_m), windows StackSet.focusMaster),

    -- Swap the focused window and the master window
    ((modm, xK_Return), windows StackSet.swapMaster),

    -- Push window back into tiling
    ((modm, xK_t), withFocused $ windows . StackSet.sink),

    -- Increment the number of windows in the master area
    ((modm, xK_comma), sendMessage (IncMasterN 1)),

    -- Deincrement the number of windows in the master area
    ((modm, xK_period), sendMessage (IncMasterN (-1))),

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- ((modm              , xK_b     ), sendMessage ToggleStruts),
    -- Restart xmonad
    ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart"),
    -- Quit xmonad
    ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))
  ]
  ++

  --
  -- mod-[1..9], Switch to workspace N
  --
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  --
  [
    ((m .|. modm, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
        (f, m) <- [(StackSet.greedyView, 0), (StackSet.shift, shiftMask)]
  ]
  ++

  --
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  --
  [
    ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
      , (f, m) <- [(StackSet.view, 0), (StackSet.shift, shiftMask)]
  ]


myMouseBindings (XConfig {XMonad.modMask = modm}) = Map.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                     >> windows StackSet.shiftMaster)),
    -- mod-button2, Raise the window to the top of the stack
    ((modm, button2), (\w -> focus w >> windows StackSet.shiftMaster)),
    -- mod-button3, Set the window to floating mode and resize by dragging
    ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                     >> windows StackSet.shiftMaster))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

myLayout = tiled ||| Mirror tiled ||| Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 2/3
    -- Percent of screen to increment by when resizing panes
    delta = 1/9

myManageHook = composeAll
  [
    className =? "MPlayer"        --> doFloat,
    className =? "Gimp"           --> doFloat,
    resource  =? "desktop_window" --> doIgnore,
    resource  =? "kdesktop"       --> doIgnore
  ]

myEventHook = mempty

myLogHook = return ()

myStartupHook = return ()

myBar = "xmobar"
myPP  = xmobarPP { ppCurrent = xmobarColor "#336699" "" . wrap "<" ">" }
-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myConfig = defaultConfig {
  -- simple stuff
  terminal           = "~/.bin/terminal",
  focusFollowsMouse  = True,
  borderWidth        = 1,
  modMask            = mod4Mask,
  workspaces         = map show [1..9],
  normalBorderColor  = "#666666",
  focusedBorderColor = "#336699",

  -- key bindings
  keys               = myKeys,
  mouseBindings      = myMouseBindings,

  -- hooks, layouts
  layoutHook         = myLayout,
  manageHook         = myManageHook,
  handleEventHook    = myEventHook,
  logHook            = myLogHook,
  startupHook        = myStartupHook
}

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

