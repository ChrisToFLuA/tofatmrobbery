# ToF ATM Robbery
- Preview video : https://www.youtube.com/watch?v=0MLVBTfSXqQ
- Forum about this script : https://forum.cfx.re/t/free-tof-atm-robbery-optimised-for-esx-legacy-using-qtarget-ox-lib-optionnal-ox-inventory/4912742
- Resmon 0.00 ms
- When you ensure the script the first time to test it, instead of discronnect / reconnect just use /robatm command.

# a lot of configurations in the script
```
OptionsATM.inventory = 'oxinventory'					-- configure here the invenotry use (oxinventory | default)
OptionsATM.props = 	921401054					        -- model props
OptionsATM.delaynotify = math.random(20000, 35000)	    -- delay in ms for the cops notify appears for them
OptionsATM.delayblip = 60000							-- delay in ms for the cops blip
OptionsATM.hacktime = 30000							-- time in ms to hack the atm
OptionsATM.stealtime = 30000							-- time in ms to steal money in the atm
OptionsATM.RobberyCooldown = 1800000                   -- configure the cooldown in ms between 2 atmrobbery  
OptionsATM.mincops = 0                                 -- configure the minimum count of police to start the robbery
OptionsATM.tracking = true                             -- configure if the player is tracking at the end of the robbery
OptionsATM.trackingtime = 60000                        -- configure in ms how much time the player in tracking
OptionsATM.trackinginterval = 6000                     -- configure in ms the interval between 2 blips
OptionsATM.item = 'card_hack'                          -- configure item needed to hack the atm
```

# Dependencies

- ox_lib : https://github.com/overextended/ox_lib
- qtarget : https://github.com/overextended/qtarget
- Optional : ox_inventory - https://github.com/overextended/ox_inventory

