Unit UD_PatchingScript;

Uses UD_Libs;

Var
    bFileLoaded : Bool;
Function Initialize : integer;
Begin
    loadGlobals();
    addZadScriptParse('zadequipscript'); //0
    addZadScriptParse('zadGagScript');
    addZadScriptParse('zadBeltScript');
    addZadScriptParse('zadCorsetScript');
    addZadScriptParse('zadPlugScript');
    addZadScriptParse('zadPlugSoulgemScript');
    addZadScriptParse('zadPlugChargeableScript');
    addZadScriptParse('zadPlugPumpsScript');
    addZadScriptParse('zadGagPanelScript');
    addZadScriptParse('zadBodyHarnessScript');
    addZadScriptParse('zadBodyHarnessBeltScript');
    addZadScriptParse('zadBlockingHarnessScript');
    addZadScriptParse('zadRestraintScript');
    addZadScriptParse('zadRestraintFullScript');
    addZadScriptParse('zadRestraintArmsScript');
    addZadScriptParse('zadRestraintLegsScript');
    addZadScriptParse('zadRestraintArmBinderScript');
    addZadScriptParse('zadBlockingBlindfoldScript');
    addZadScriptParse('zadBlindfoldScript');
    addZadScriptParse('zadSlaveBootsScript');
    addZadScriptParse('zadBlindfoldScript');
    addZadScriptParse('zadSlaveBootsUnlockedScript');
    addZadScriptParse('zadCollarScript');
    addZadScriptParse('zadxChainHarnessNippleChainScript');
    addZadScriptParse('zadGlovesScript');
    addZadScriptParse('zadCollarNPiercingsScript');
    addZadScriptParse('zadBraScript');
    addZadScriptParse('zadx_HobbleSkirtScript');
    addZadScriptParse('zadx_RopeHarnessScript');
    addZadScriptParse('zadx_BondageMittensScript');
    addZadScriptParse('zadxAnkleShacklesScript');
    addZadScriptParse('zadPiercingVaginalScript');
    addZadScriptParse('zadPiercingNippleScript');
    addZadScriptParse('zadBodyNoCollarHarnessScript');
    addZadScriptParse('zadBodyNoCollarHarnessBeltScript');
    addZadScriptParse('zadCorsetBeltScript');
    
    addUDScript('UD_CustomDevice_RenderScript');
    addUDScript('UD_CustomGag_RenderScript');
    addUDScript('UD_CustomBelt_RenderScript');
    addUDScript('UD_CustomBra_RenderScript');
    addUDScript('UD_CustomCorset_RenderScript');
    addUDScript('UD_CustomPlug_RenderScript');
    addUDScript('UD_CustomInflatablePlug_RenderScript');
    addUDScript('UD_CustomHeavyBondage_RenderScript');
    addUDScript('UD_CustomBlindfold_RenderScript');
    addUDScript('UD_CustomBoots_RenderScript');
    addUDScript('UD_CustomCollar_RenderScript');
    addUDScript('UD_CustomGloves_RenderScript');
    addUDScript('UD_CustomPiercing_RenderScript');
    addUDScript('UD_CustomChargPlug_RenderScript');
    addUDScript('UD_CustomPanelGag_RenderScript');
    addUDScript('UD_CustomInflatableGag_RenderScript');
    addUDScript('UD_CustomMittens_RenderScript');
    addUDScript('UD_CustomSuit_RenderScript');
    addUDScript('UD_CustomHood_RenderScript');
    addUDScript('UD_ControlablePlug_RenderScript');
    addUDScript('UD_AbadonPlug_RenderScript');
    addUDScript('UD_CursedGasmask_RenderScript');
    addUDScript('UD_CustomDynamicHeavyBondage_RS');
    addUDScript('UD_CustomArmCuffs_RenderScript');
    addUDScript('UD_CustomLegCuffs_RenderScript');
    addUDScript('UD_CustomHarness_RenderScript');
    addUDScript('UD_CustomGasMask_RenderScript');
    addUDScript('UD_CustomBPDevice_RenderScript');
    addUDScript('UD_CustomCrotchDevice_RenderScript');
    addUDScript('UD_CustomDevice_EquipScript');
End;

Function Process(aeElement: IInterface) : Integer; 
Var
    sPatchFilePath : String;
    sPatchName : String;
Begin
    If (ElementType(aeElement) = etMainRecord) and (Signature(aeElement) = 'ARMO') Then 
    Begin
        if not bFileLoaded then Begin
            bFileLoaded := True;
            sPatchFilePath := FullPath(aeElement);
            sPatchName := getFileNameFromPath(sPatchFilePath);
            ePatchFile := getFileByName(sPatchName);
            addMessage('File ' + name(ePatchFile) + ' loaded!');
        End;
        //inventory device
        if ArmorHaveKeyword(aeElement,eZadInvKW) then
        Begin
            //AddMessage('Device found');
            patchDevice(aeElement);
        End;
    End;
End;

function Finalize : integer;
begin
    AddMessage(Format('Patching done! Total of %d devices patched! New devices: %d', [iTotalPatchedDevice,iNewDevices]));
end;

End.