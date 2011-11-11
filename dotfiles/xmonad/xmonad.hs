import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import System.IO
import qualified Data.Map as M

myTerminal = "/opt/local/bin/urxvt"

addKeys x = [((mod1Mask .|. shiftMask, xK_v), spawn "/opt/local/bin/gvim")
            ,((mod1Mask .|. shiftMask, xK_f), spawn "/opt/local/bin/firefox")
            ,((mod1Mask .|. shiftMask, xK_m), spawn "/opt/local/bin/urxvt -c 'ssh -lhurley monkey.org'")
            ,((mod1Mask .|. shiftMask, xK_l), spawn "/opt/local/bin/urxvt -c 'ssh -lhurley cailleach'")
            ]
delKeys x = []
newKeys x = M.union (keys defaultConfig x) (M.fromList (addKeys x))
myKeys x = foldr M.delete (newKeys x) (delKeys x)

main = do
    xmproc <- spawnPipe "~/.cabal/bin/xmobar ~/.xmobarrc"
    xmonad $ defaultConfig
        { keys = myKeys
        , terminal = myTerminal
        , manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "grey" ""
            , ppLayout = const "" -- to disable layout info on xmobar
            }
        }
