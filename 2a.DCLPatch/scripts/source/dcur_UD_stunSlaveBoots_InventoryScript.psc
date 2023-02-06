Scriptname dcur_UD_stunSlaveBoots_InventoryScript extends UD_CustomDevice_EquipScript  

dcur_mcmconfig Property dcumenu  Auto  
dcur_shockbootsquestscript Property sbqs Auto
dcur_mastercontrollerscript Property mcs Auto

Event OnEquipped(Actor akActor)
	if !zad_DeviousDevice
	; Fix duplicate keyword baked in to savegames
	zad_DeviousDevice = (Game.GetFormFromFile(0x00027f29, "Devious Devices - Assets.esm") as Keyword)
	EndIf
	Parent.OnEquipped(akActor)
EndEvent

Function OnEquippedPre(actor akActor, bool silent=false)
	string msg = ""
	if akActor == libs.PlayerRef						
		msg = "You sit down to slip your feet into the steel boots and lock them shut. They raise your heels by almost seven inches and when you push yourself up to stand on the thin metal rings, you need all your concentration not to fall. But with the steel boots now securely locked on you, you know that you will get ample time to practice walking in them. The tickling sensation on your feet also reminds you what the boots will do to you should you try to run..."		
	Else
		msg = "You place the steel 'boots' onto "+GetMessageName(akActor)+" feet, and they lock in place with a soft click."
	EndIf
	if !silent
		libs.NotifyActor(msg, akActor, true)
	EndIf	
	Parent.OnEquippedPre(akActor, silent)
EndFunction

int Function OnEquippedFilter(actor akActor, bool silent=false)
	if SKSE.GetPluginVersion("NiOverride") < 5 && SKSE.GetPluginVersion("skee") < 1 || NiOverride.GetScriptVersion() < 5
    		libs.NotifyPlayer("This device ("+deviceName+") requires NetImmerse Override, which you do not have installed.", true)
		return 2
	EndIf
	return 0
EndFunction
