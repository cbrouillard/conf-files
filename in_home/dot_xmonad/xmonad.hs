import qualified Data.Map as M 
import qualified XMonad.StackSet as W

import System.IO
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.SpawnOn
import XMonad.Actions.UpdatePointer
import XMonad.Config.Azerty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import XMonad.Util.Run(spawnPipe)
import XMonad.Layout.Groups.Examples
import XMonad.Hooks.EwmhDesktops

myManageHook = composeAll
    [ resource  =? "Firefox"       --> doFloat
    , resource  =? "Mozilla Firefox"       --> doFloat
    , className  =? "Firefox"       --> doFloat
    , resource  =? "Do"   --> doIgnore
    ]

myWorkspaces  = ["1:www","2:dev","3:exec local","4:db","5:mails","6:webservices", "7", "8", "9","10:alpha & ext", "11:services", "12:chat"]

newKeys x = M.union (M.fromList (myKeys x)) (keys azertyConfig x)
myKeys conf@(XConfig {XMonad.modMask = modMask}) =
    [ ((modMask .|. shiftMask, xK_l), spawn "gnome-screensaver-command --lock")
    --[ ((modMask .|. shiftMask, xK_l), spawn "xtrlock")
    , ((modMask, xK_quoteleft), spawn "rotatexkbmap") -- with qwerty keyboard
    , ((modMask, xK_twosuperior), spawn "rotatexkbmap") -- with azerty keyboard  
    , ((modMask, xK_p), spawn "exe=`dmenu_run -p launch -nb black -nf yellow -sf yellow` && eval \"exec $exe\"")
    , ((0,0x1008FF11), spawn "pactl set-sink-volume 1 -- -1%")
    , ((0,0x1008FF13), spawn "pactl set-sink-volume 1 +1%")
    , ((0,0x1008FF12), spawn "pactl set-sink-mute 1 toggle")
    , ((0,0x1008FF02), spawn "xbacklight -inc 5")
    , ((0,0x1008FF03), spawn "xbacklight -dec 5")
    , ((0 ,              xK_Print ), spawn "scrot ~/Images/screen_%Y-%m-%d-%H-%M-%S.png -d 1")
    , ((modMask, xK_Print ), spawn "scrot ~/Images/window_%Y-%m-%d-%H-%M-%S.png -d 1 -u")
 -- moving workspaces
    , ((modMask, xK_Left),    prevWS )
    , ((modMask, xK_Right),   nextWS )
    , ((modMask .|. shiftMask, xK_Left),  shiftToPrev )
    , ((modMask .|. shiftMask, xK_Right), shiftToNext )
	]
    ++ 	
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_agrave, xK_parenright, xK_equal]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

-- Layouts
myLayout = (toggleLayouts $ noBorders Full) $ -- toggle fullscreen
  (layoutHook defaultConfig ||| noBorders tabbed ||| Grid)
  where tabbed = named "Tabbed" $ simpleTabbed

myFocusedBorderColor = "yellow"
myBorderColor = "#555"
myBorderWidth = 1

main = do
      xmproc <- spawnPipe "xmobar"
      xmonad $ ewmh $ withUrgencyHook NoUrgencyHook $ azertyConfig {
                           --manageHook = myManageHook <+> manageHook defaultConfig,
                          manageHook = manageDocks <+> manageHook defaultConfig,
                          keys = newKeys,
                          modMask    = mod4Mask,
                          workspaces = myWorkspaces,
                          layoutHook = smartBorders (avoidStruts $ myLayout),
                          startupHook = setWMName "LG3D",
			  focusedBorderColor = myFocusedBorderColor,
			  normalBorderColor = myBorderColor,
			  borderWidth = myBorderWidth,
                          terminal = "terminator",
                          logHook = (dynamicLogWithPP $ xmobarPP
                                    { ppOutput = hPutStrLn xmproc
                                    , ppCurrent = xmobarColor "#19F" "" . wrap "[" "]"
                                    , ppTitle = xmobarColor "pink" "" . shorten 50
                                    }) >> updatePointer (0.5, 0.5) (0, 0) >> takeTopFocus  
}

