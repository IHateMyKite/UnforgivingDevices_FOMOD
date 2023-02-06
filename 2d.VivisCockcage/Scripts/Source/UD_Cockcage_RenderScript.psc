Scriptname UD_Cockcage_RenderScript extends UD_CustomVibratorBase_RenderScript

import UnforgivingDevicesMain

Function InitPost()
    parent.InitPost()
    UD_DeviceType = "Cockcage"
EndFunction

float Function getAccesibility()
    if GetWearer().WornHasKeyword(libs.zad_DeviousBelt) ;belted
        return 0.0
    endif
    
    float loc_res = 1.0
    bool loc_hashelper = HasHelper()
        
    if !wearerFreeHands() && (!loc_hashelper || !HelperFreeHands())
        loc_res *= 0.25
    elseif !wearerFreeHands(true) && (!loc_hashelper || !HelperFreeHands(true))
        loc_res *= 0.5
    endif
    
    if getWearer().wornhaskeyword(libs.zad_DeviousHobbleSkirt)
        loc_res *= 0.7
    elseif getWearer().wornhaskeyword(libs.zad_DeviousHobbleSkirtRelaxed)
        loc_res *= 0.8
    elseif getWearer().wornhaskeyword(libs.zad_DeviousSuit)
        loc_res *= 0.9
    endif
    
    return fRange(loc_res,0.0,1.0)
EndFunction