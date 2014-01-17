import qualified Data.Map as M 
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



myManageHook = composeAll
    [ resource  =? "Firefox"       --> doFloat
    , resource  =? "Mozilla Firefox"       --> doFloat
    , className  =? "Firefox"       --> doFloat
    , resource  =? "Do"   --> doIgnore
    ]

myWorkspaces  = ["1:www","2:dev","3:server","4:doc","5","6", "7", "8", "9:chat"]

newKeys x = M.union (M.fromList (myKeys x)) (keys azertyConfig x)
myKeys conf@(XConfig {XMonad.modMask = modMask}) =
    [ ((modMask .|. shiftMask, xK_l), spawn "gnome-screensaver-command --lock")
    , ((modMask, xK_quoteleft), spawn "rotatexkbmap") -- with qwerty keyboard
    , ((modMask, xK_twosuperior), spawn "rotatexkbmap") -- with azerty keyboard  
    , ((modMask, xK_p), spawn "exe=`dmenu_run -nb black -nf yellow -sf yellow` && eval \"exec $exe\"") 
	]

-- Layouts
myLayout = (toggleLayouts $ noBorders Full) $ -- toggle fullscreen
  (layoutHook defaultConfig ||| noBorders tabbed ||| Grid)
  where tabbed = named "Tabbed" $ simpleTabbed

main = do
      xmproc <- spawnPipe "xmobar"
      xmonad $ withUrgencyHook NoUrgencyHook $ azertyConfig {
                          --manageHook = myManageHook <+> manageHook defaultConfig,
                          manageHook = manageDocks <+> manageHook defaultConfig,
                          keys = newKeys,
                          modMask    = mod4Mask,
                          workspaces = myWorkspaces,
                          layoutHook = smartBorders (avoidStruts $ myLayout),
                          startupHook = setWMName "LG3D",
                          terminal = "terminator",
                          logHook = (dynamicLogWithPP $ xmobarPP
                                    { ppOutput = hPutStrLn xmproc
                                    , ppCurrent = xmobarColor "#09F" "" . wrap "[" "]"
                                    , ppTitle = xmobarColor "pink" "" . shorten 50
                                    }) >> updatePointer (Relative 0.5 0.5) >> takeTopFocus  
}

