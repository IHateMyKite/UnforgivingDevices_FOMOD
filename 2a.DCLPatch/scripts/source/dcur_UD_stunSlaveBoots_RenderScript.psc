Scriptname dcur_UD_stunSlaveBoots_RenderScript extends UD_CustomBoots_RenderScript 

dcur_mcmconfig Property dcumenu  Auto  
dcur_shockbootsquestscript Property sbqs Auto

Function InitPost()
	parent.InitPost()
	UD_DeviceType = "Stun Slave Boots"
	if UDCDmain.TraceAllowed()
		libs.Log("RestraintScript OnEquippedPost Boots")	
		libs.Notify("Shock Boots Effect started.")	
	endif
	sbqs.shockbootsquestactive = true
	sbqs.RegisterForSingleUpdate(1)	
EndFunction

Function onRemoveDevicePost(Actor akActor)	
	sbqs.shockbootsquestactive = false
	sbqs.UnRegisterForUpdate()	
EndFunction