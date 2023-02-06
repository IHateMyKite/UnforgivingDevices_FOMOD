Unit UD_Libs;

Var
    zadscripts       : array[0..100] of string;
    zadtoudscript : array[0..100] of string;
    iZadScriptNum : Integer;
    UDscripts : array[0..100] of string;
    iUDScriptNum : Integer;
    iTotalPatchedDevice : Integer;
    iNewDevices : Integer;
    eUDFile : IInterface;
    eZadFile : IInterface;
    ePatchFile : IInterface;
    ePatchKW : IInterface;
    ePatchNoModeKW : IInterface;
    ePatchInvKW : IInterface;
    eZadInvKW : IInterface;
    eUDKW : IInterface;
    eArmors : IInterface;
    eUDCDmain : IInterface;
    bUseModes : bool;
{-------------------------INTERFACE---------------------------}
Interface
    Procedure setArrays();
    Function getFileByName(sFileName : String) : iwbFile;
    Function addOrderToFormID(aeFile : iwbFile; cFormID : cardinal) : Cardinal;
    Function getArmorName(aeForm: IInterface) : String;
    Procedure copyInventoryScriptValuesToRender(eInventoryScript : IInterface;eRenderScript : IInterface;bCreateNew : bool);
    Procedure addKeywords(eRenderDevice : IInterface);
    Function getObjectNativeValue(eProperty : IInterface) : IInterface;
    Function getObjectEditValue(eProperty : IInterface) : String;
    Function getPropertyByName(eScript : IInterface; sPropertyName : String) : IInterface;
    Procedure copyAllProperties(eOldScript : IInterface; eNewScript : IInterface);
    Function GetArmorScript(aeForm: IInterface; asName: String): IInterface;
    Function ArmorHaveAttachedScript(aeForm: IInterface) : Bool;
    Function ArmorHaveUDScript(aeForm: IInterface) : Bool;
    Function ArmorHaveKeyword(aeArmorForm : IInterface; sKeywordEditorID : AnsiString) : Bool;
    Function DDeviceHaveKeyword(aeInventoryDeviceScript : IInterface; sKeywordEditorName : AnsiString) : Bool;
    Function containsWord(sMainString : String ; sSubstring : String; iStart : Integer) : Bool;
    Function getSubStringPos(sMainString : String ; sSubstring : String; iStart : Integer) : Integer;
    Function GetPropertyFromScript(aeScript: IInterface; asPropertyName: String) : IInterface;
    Function AttachArmorScript(aeForm: IInterface; asName: String; abRedundant: Boolean): IInterface;
    Procedure RemoveArmorScript(aeForm: IInterface; asName: String);
    Function getFileNameFromPath(sPath : String) : String;
    Procedure patchDevice(eInventoryDevice: IInterface);
    Function selectNewUDScript(eInventoryDevice : IInterface; eInventoryScript : IInterface; iOldScriptType : Integer) : String;
{-----------------------IMPLEMENTATION------------------------}    
Implementation

Procedure addZadScriptParse(sZadScriptName : String);
Begin
    If iZadScriptNum = 100 Then Begin
        AddMessage('ERROR: Number of zad scripts is too big!');
        Exit;
    End;
    iZadScriptNum := iZadScriptNum + 1;
    zadscripts[iZadScriptNum - 1] := sZadScriptName;
    //zadtoudscript[iZadScriptNum - 1] := sUDScriptName;
End;

Procedure addUDScript(sScriptName : String);
Begin
    If iUDScriptNum = 100 Then Begin
        AddMessage('ERROR: Number of UD scripts is too big!');
        Exit;
    End;
    iUDScriptNum := iUDScriptNum + 1;
    UDscripts[iUDScriptNum - 1] := sScriptName;
End;

Procedure addScript(sZadScriptName : String, sScriptName : String);
Begin
    If iUDScriptNum = 100 Then Begin
        AddMessage('ERROR: Number of UD or Zad scripts is too big!');
        Exit;
    End;
    iUDScriptNum := iUDScriptNum + 1;
    UDscripts[iUDScriptNum - 1] := sScriptName;
    zadscripts[iUDScriptNum - 1] := sZadScriptName;
End;

Procedure loadGlobals();
Begin
    iUDScriptNum := 0;
    iTotalPatchedDevice := 0;
    iNewDevices := 0;    
    
    eUDFile := getFileByName('UnforgivingDevices.esp');
    
    if Assigned(eUDFile) then Begin
        AddMessage(Format('File %s loaded!',[BaseName(eUDFile)]));
    end else Begin
        AddMessage('ERROR: UnforgivingDevices.esp couldnt be loaded!');
        exit;
    end;
        
    eZadFile := getFileByName('Devious Devices - Integration.esm');
    if Assigned(eZadFile) then Begin
        AddMessage(Format('File %s loaded!',[BaseName(eZadFile)]));
    end else Begin
        AddMessage('ERROR: Devious Devices - Integration.esm couldnt be loaded!');
        exit;
    end;    
    
    ePatchKW := RecordByFormID(eUDFile,addOrderToFormID(eUDFile,$0013A977),False);
    if Assigned(ePatchKW) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(ePatchKW)]));
    end else Begin
        AddMessage('ERROR: PatchedDevice keyword couldnt be loaded!');
        exit;
    End;
    
    ePatchInvKW := RecordByFormID(eUDFile,addOrderToFormID(eUDFile,$001553DD),False);
    if Assigned(ePatchInvKW) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(ePatchInvKW)]));
    end else Begin
        AddMessage('ERROR: PatchedinventoryDevice keyword couldnt be loaded!');
        exit;
    End;
    
    eUDKW := RecordByFormID(eUDFile,addOrderToFormID(eUDFile,$0011A352),False);
    if Assigned(eUDKW) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(eUDKW)]));
    end else Begin
        AddMessage('ERROR: UnforgivingDevice keyword couldnt be loaded!');
        exit;
    End;
    
    ePatchNoModeKW := RecordByFormID(eUDFile,addOrderToFormID(eUDFile,$001579BE),False);
    if Assigned(ePatchNoModeKW) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(ePatchNoModeKW)]));
    end else Begin
        AddMessage('ERROR: PatchNoMode keyword couldnt be loaded!');
        exit;
    End;
    
    eUDCDmain := RecordByFormID(eUDFile,addOrderToFormID(eUDFile,$0015E73C),True);
    if Assigned(eUDCDmain) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(eUDCDmain)]));
    end else Begin
        AddMessage('ERROR: UDCD Quest couldnt be loaded!');
        exit;
    End;
    
    eZadInvKW := RecordByFormID(eZadFile,addOrderToFormID(eZadFile,$0002B5F0),True);
    if Assigned(eZadInvKW) then Begin
        AddMessage(Format('Keyword %s loaded!',[Name(eZadInvKW)]));
    end else Begin
        AddMessage('ERROR: zad_inventoryDevice couldnt be loaded!');
        exit;
    End;
    
    bUseModes := true;
    
    eArmors := GroupBySignature(eUDFile,'ARMO');
End;

Function getFileByName(sFileName : String) : iwbFile;
Var
   iIterator : Integer;
   eFile : IwbFile;
Begin
    For iIterator := 0 To FileCount Do Begin
        eFile := FileByIndex(iIterator);
        if getFileName(eFile) = sFileName Then
        Begin
            result := eFile;
            exit;
        End;
    End;
End;

Function addOrderToFormID(aeFile : iwbFile; cFormID : cardinal) : Cardinal;
Begin
    Result := cFormID or (GetLoadOrder(aeFile) Shl 24);
    exit;
End;

Function getArmorName(aeForm: IInterface) : String;
Var
    eFULL : IInterface;
Begin
    eFULL := ElementBySignature(aeForm, 'FULL');
    Result := GetEditValue(eFULL);
    exit;
End;

Procedure copyInventoryScriptValuesToRender(eInventoryScript : IInterface;eRenderScript : IInterface;bCreateNew : bool);
Var
    eNewProperties : IInterface;
    eNewCurrentProperty : IInterface;
    eLibsProperty : IInterface;
    eKeywordProperty : IInterface;
    iIterator : Integer;
    sCurrentPropertyName : String;
    sNewPropertyName : String;
Begin
    if bCreateNew then
        eNewProperties := ElementByName(eRenderScript, 'Properties');
    
    
    for iIterator := 0 to 2 do Begin
        case (iIterator) of
            
            0 : Begin 
                sCurrentPropertyName := 'deviceInventory';
                sNewPropertyName := sCurrentPropertyName;
            End;
            1 : Begin 
                sCurrentPropertyName := 'libs';
                sNewPropertyName := sCurrentPropertyName;
            End;
            2 : Begin
                sCurrentPropertyName := 'zad_DeviousDevice';
                sNewPropertyName := 'UD_DeviceKeyword';
            End;
        End;
        
        if bCreateNew then Begin
            eNewCurrentProperty := ElementAssign(eNewProperties,HighInteger, nil,False);
            SetEditValue(ElementByName(eNewCurrentProperty, 'propertyName'), sNewPropertyName);    
        end else
            eNewCurrentProperty := getPropertyByName(eRenderScript,sNewPropertyName);
            
        SetNativeValue(ElementByName(eNewCurrentProperty, 'Type'), GetNativeValue(ElementByName(getPropertyByName(eInventoryScript,sCurrentPropertyName),'Type')));
        SetNativeValue(ElementByName(eNewCurrentProperty, 'Flags'), GetNativeValue(ElementByName(getPropertyByName(eInventoryScript,sCurrentPropertyName),'Flags'))); // "Edited"
        SetElementNativeValues(eNewCurrentProperty, 'Value\Object Union\Object v2\FormID', getObjectNativeValue(getPropertyByName(eInventoryScript,sCurrentPropertyName)));
        SetElementNativeValues(eNewCurrentProperty, 'Value\Object Union\Object v2\Alias', -1);    
    End;
End;


Procedure addKeywordToArmor(eArmor : IInterface;eKeyWord : IInterface);
Var
    eNewKeyword : IInterface;
    eKeywords : IInterface;
Begin
    eKeywords := ElementBySignature(eArmor,'KWDA');
    
    if not ArmorHaveKeyword(eArmor,eKeyWord) then Begin
        eNewKeyword := ElementAssign(eKeywords,HighInteger, nil,False);
        SetEditValue(eNewKeyword,GetEditValue(eKeyWord));
    end;
End;

Procedure addKeywords(eRenderDevice : IInterface);
Var
    eNewPatchKW : IInterface;
    eNewUDKW : IInterface;
    eKeywords : IInterface;
    eNewPatchNoModeKW : IInterface;
Begin
    eKeywords := ElementBySignature(eRenderDevice,'KWDA');
    if not ArmorHaveKeyword(eRenderDevice,ePatchKW) then Begin
        eNewPatchKW := ElementAssign(eKeywords,HighInteger, nil,False);
        SetEditValue(eNewPatchKW,GetEditValue(ePatchKW));
    end;
    if not ArmorHaveKeyword(eRenderDevice,eUDKW) then Begin
        eNewUDKW := ElementAssign(eKeywords,HighInteger, nil,False);
        SetEditValue(eNewUDKW,GetEditValue(eUDKW));
    End;
    if not ArmorHaveKeyword(eRenderDevice,ePatchNoModeKW) and not bUseModes then Begin
        eNewPatchNoModeKW := ElementAssign(eKeywords,HighInteger, nil,False);
        SetEditValue(eNewPatchNoModeKW,GetEditValue(ePatchNoModeKW));
    end;
End;

Function getObjectNativeValue(eProperty : IInterface) : IInterface;
Begin
    Result := GetNativeValue(ElementByPath(eProperty,'Value\Object Union\Object v2\FormID'));
    Exit;
End;

Function getObjectEditValue(eProperty : IInterface) : String;
Begin
    Result := GetEditValue(ElementByPath(eProperty,'Value\Object Union\Object v2\FormID'));
    Exit;
End;

Function getPropertyByName(eScript : IInterface; sPropertyName : String) : IInterface;
Var
    eProperties : IInterface;
    iIterator : Integer;
Begin
    eProperties := ElementByName(eScript, 'Properties');
    for iIterator := 0 To ElementCount(eProperties) - 1 do Begin
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = sPropertyName  then Begin
            Result := ElementByIndex(eProperties,iIterator);
            Exit;
        End;
    End;
End;

Procedure copyAllProperties(eOldScript : IInterface; eNewScript : IInterface);
Var
    iCurrentProperty: Integer;
    iArrayIterator : Integer;
    eOldProperties : IInterface;
    eNewProperties : IInterface;
    eCurrentProperty : IInterface;
    eOldProperty : IInterface;
    iType : Integer;
    eOldArray : IInterface;
    eNewArray : IInterface;
    eNewArrayRecord : IInterface;
    eUDCDProperty : IInterface;
Begin
    eOldProperties := ElementByName(eOldScript, 'Properties');
    eNewProperties := ElementByName(eNewScript, 'Properties');
    
    
    //AddMessage(Format('Number of properties to copy: %d',[ElementCount(eOldProperties)]));
    
    for iCurrentProperty := 0 To ElementCount(eOldProperties) - 1 do Begin
        eCurrentProperty := ElementAssign(eNewProperties,HighInteger, nil,False);
        eOldProperty := ElementByIndex(eOldProperties,iCurrentProperty);
        SetEditValue(ElementByName(eCurrentProperty, 'propertyName'), getEditValue(ElementByName(eOldProperty, 'propertyName')));        
        SetNativeValue(ElementByName(eCurrentProperty, 'Type'), GetNativeValue(ElementByName(eOldProperty,'Type')));
        SetNativeValue(ElementByName(eCurrentProperty, 'Flags'), GetNativeValue(ElementByName(eOldProperty,'Flags'))); // "Edited"
        iType := GetNativeValue(ElementByName(eOldProperty,'Type'));
        
        case (iType) of 
            1 : Begin
                SetElementNativeValues(eCurrentProperty, 'Value\Object Union\Object v2\FormID', GetElementNativeValues(eOldProperty,'Value\Object Union\Object v2\FormID'));
                SetElementNativeValues(eCurrentProperty, 'Value\Object Union\Object v2\Alias', -1);
            End;
            2 : SetNativeValue(ElementByName(eCurrentProperty, 'String'), GetNativeValue(ElementByName(eOldProperty,'String'))); 
            3 : SetNativeValue(ElementByName(eCurrentProperty, 'Int32'), GetNativeValue(ElementByName(eOldProperty,'Int32')));
            4 : SetNativeValue(ElementByName(eCurrentProperty, 'Float'), GetNativeValue(ElementByName(eOldProperty,'Float')));
            5 : SetNativeValue(ElementByName(eCurrentProperty, 'Bool'), GetNativeValue(ElementByName(eOldProperty,'Bool')));
            11,12,13,14,15 : 
                Begin
                    eOldArray := ElementByIndex(ElementByName(eOldProperty, 'Value'),0);
                    eNewArray := ElementByIndex(ElementByName(eCurrentProperty, 'Value'),0);
                    //AddMessage(Format('Number of array records to copy from %s: %d',[getEditValue(ElementByName(eCurrentProperty,'propertyName')),ElementCount(eOldArray)]));
                    for iArrayIterator := 0 to ElementCount(eOldArray) - 1 do Begin
                        eNewArrayRecord := ElementAssign(eNewArray, HighInteger, nil, False);
                        case iType of 
                            11 : Begin
                                SetElementNativeValues(eNewArrayRecord, 'Object v2\FormID', GetElementNativeValues(ElementByIndex(eOldArray,iArrayIterator),'Object v2\FormID'));
                                SetElementNativeValues(eNewArrayRecord, 'Object v2\Alias', -1);        
                            End;
                        else
                            SetNativeValue(eNewArrayRecord, getNativeValue(ElementByIndex(eOldArray,iArrayIterator)));
                        End;
                    End;
                End;
        End;
        
    End;
    
    eUDCDProperty := ElementAssign(eNewProperties,HighInteger, nil,False);
    SetEditValue(ElementByName(eUDCDProperty, 'propertyName'), 'UDCDmain');        
    SetNativeValue(ElementByName(eUDCDProperty, 'Type'), 1);
    SetNativeValue(ElementByName(eUDCDProperty, 'Flags'), 1); // "Edited"    
    SetElementEditValues(eUDCDProperty, 'Value\Object Union\Object v2\FormID', getEditValue(eUDCDmain));
    SetElementNativeValues(eUDCDProperty, 'Value\Object Union\Object v2\Alias', -1);    
End;

Function addNewPropertyToScript(eScript : IInterface; sPropertyName : String; iType : Integer) : IInterface;
Var
    eNewProperty : IInterface;
Begin
    eNewProperty := ElementAssign(ElementByName(eScript, 'Properties'),HighInteger, nil,False);
    SetEditValue(ElementByName(eNewProperty, 'propertyName'),sPropertyName);    
    SetNativeValue(ElementByName(eNewProperty, 'Type'), iType);
    SetEditValue(ElementByName(eNewProperty, 'Flags'),'Edited'); // "Edited"
    
    if iType = 1 Then SetElementNativeValues(eNewProperty, 'Value\Object Union\Object v2\Alias', -1);
End;

{Edited function by DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts to make it work on Armors}
Function GetArmorScript(aeForm: IInterface; asName: String): IInterface;
Var
   eVMAD: IInterface;
   eScripts: IInterface;
   iCurrentScript: Integer;
   eCurrentScript: IInterface;
   sCurrentScript: String;
Begin
   eVMAD := ElementBySignature(aeForm, 'VMAD');
   If Not Assigned(eVMAD) Then Exit;
   eScripts := ElementByPath(eVMAD, 'Scripts');
   For iCurrentScript := 0 To ElementCount(eScripts) - 1 Do Begin
      eCurrentScript := ElementByIndex(eScripts, iCurrentScript);
     If Name(eCurrentScript) = 'Script' Then Begin
        sCurrentScript := GetEditValue(ElementByName(eCurrentScript, 'scriptName'));
     If sCurrentScript = asName Then Begin
        Result := eCurrentScript;
        Exit;
     End;
      End;
   End;
   Result := nil;
   Exit;
End;

{Edited function by DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts to make it work on Armors}
Function GetQuestScript(aeForm: IInterface; asName: String): IInterface;
Var
   eVMAD: IInterface;
   eScripts: IInterface;
   iCurrentScript: Integer;
   eCurrentScript: IInterface;
   sCurrentScript: String;
Begin
    eVMAD := ElementBySignature(aeForm, 'VMAD');
    If Not Assigned(eVMAD) Then Exit;
    eScripts := ElementByPath(eVMAD, 'Scripts');
    For iCurrentScript := 0 To ElementCount(eScripts) - 1 Do Begin
        eCurrentScript := ElementByIndex(eScripts, iCurrentScript);
        If Name(eCurrentScript) = 'Script' Then Begin
            sCurrentScript := GetEditValue(ElementByName(eCurrentScript, 'scriptName'));
            If sCurrentScript = asName Then Begin
                Result := eCurrentScript;
                Exit;
            End;
        End;
    End;
    Result := nil;
    Exit;
End;

{Edited function by DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts to make it work on Armors}
Function ArmorHaveAttachedScript(aeForm: IInterface) : Bool;
Var
   eVMAD: IInterface;
   eScripts: IInterface;
Begin
    eVMAD := ElementBySignature(aeForm, 'VMAD');
    If Not Assigned(eVMAD) Then Begin
        Result := False;
        Exit;
    End;
    eScripts := ElementByPath(eVMAD, 'Scripts');
    if ElementCount(eScripts) > 0 then Begin
        Result := True;
    End;
    Exit;
End;


Function ArmorHaveUDScript(aeForm: IInterface) : Bool;
Var
   eVMAD: IInterface;
   eScripts: IInterface;    
   eCurrentScript : IInterface;
   sCurrentScript : String;
   iCurrentScript : Integer;
   iCurrentUDScript : Integer;
Begin
    eVMAD := ElementBySignature(aeForm, 'VMAD');
    If Not Assigned(eVMAD) Then Exit;
    eScripts := ElementByPath(eVMAD, 'Scripts');
    For iCurrentScript := 0 To ElementCount(eScripts) - 1 Do Begin
        For iCurrentUDScript := 0 To iUDScriptNum - 1 Do Begin
            eCurrentScript := ElementByIndex(eScripts, iCurrentScript);
            If Name(eCurrentScript) = 'Script' Then Begin
                sCurrentScript := GetEditValue(ElementByName(eCurrentScript, 'scriptName'));
                If sCurrentScript = UDscripts[iCurrentUDScript] Then Begin
                    //AddMessage(Format('Armor %s have UD script %s',[editorID(aeForm),UDscripts[iCurrentUDScript]]));
                    Result := True;
                    Exit;
                End;
            End;
        End;
    End;
    Result := False;
    Exit;
End;

{
Function ArmorHaveKeyword(aeArmorForm : IInterface; sKeywordEditorID : AnsiString) : Bool;
Var
    eKeywords : IInterface;
    iNumberOfKeywords : Integer;
    iIterator : Integer;
Begin
    eKeywords := ElementBySignature(aeArmorForm,'KWDA');
    iNumberOfKeywords := ElementCount(eKeywords);
    For iIterator := 0 To iNumberOfKeywords - 1 Do Begin
        if containsWord(GetEditValue(ElementByIndex(eKeywords,iIterator)),sKeywordEditorID,1) then Begin
            Result := True;
            Exit;
        End;
        
    End;
    Result := False;
    Exit;
End;
}

Function ArmorHaveKeyword(eArmor : IInterface; eKeyword : IInterface) : Bool;
Var
    eKeywords : IInterface;
    iNumberOfKeywords : Integer;
    iIterator : Integer;
Begin
    eKeywords := ElementBySignature(eArmor,'KWDA');
    iNumberOfKeywords := ElementCount(eKeywords);
    For iIterator := 0 To iNumberOfKeywords - 1 Do Begin
        if (GetEditValue(ElementByIndex(eKeywords,iIterator)) = ShortName(eKeyword)) then Begin
            Result := True;
            Exit;
        End;
        
    End;
    Result := False;
    Exit;
End;

Function DDeviceHaveKeyword(aeInventoryDeviceScript : IInterface; sKeywordEditorName : AnsiString) : Bool;
Begin
    if containsWord(getObjectEditValue(getPropertyByName(aeInventoryDeviceScript,'zad_DeviousDevice')),sKeywordEditorName,1) Then Begin
        Result := True;
        Exit;
    End;
    Result := False;
    Exit;
End;

Function containsWord(sMainString : String ; sSubstring : String; iStart : Integer) : Bool;
Var
    iMStrSize : Integer;
    iSStrSize : Integer;
    iIterator : Integer;
Begin
    iMStrSize := Length(sMainString);
    iSStrSize := Length(sSubstring);

    for iIterator := iStart To iMStrSize Do Begin
        if LowerCase(Copy(sMainString, iIterator, 1)) = LowerCase(Copy(sSubstring, 1, 1)) Then Begin
            if LowerCase(Copy(sMainString, iIterator, iSStrSize)) = LowerCase(sSubstring) Then Begin
                Result := True;
                Exit;
            End
        End;
    End;
    Result := False;
    Exit;
End;

Function getSubStringPos(sMainString : String ; sSubstring : String; iStart : Integer) : Integer;
Var
    iMStrSize : Integer;
    iSStrSize : Integer;
    iIterator : Integer;
Begin
    iMStrSize := Length(sMainString);
    iSStrSize := Length(sSubstring);

    for iIterator := iStart To iMStrSize Do Begin
        if Copy(sMainString, iIterator, 1) = Copy(sSubstring, 1, 1) Then Begin
            if Copy(sMainString, iIterator, iSStrSize) = sSubstring Then Begin
                Result := iIterator;
                Exit;
            End
        End;
    End;
    Result := -1;
    Exit;
End;

{Edited function by  DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts}
Function GetPropertyFromScript(aeScript: IInterface; asPropertyName: String) : IInterface;
Var
   eProperties: IInterface;
   iCurrentProperty: Integer;
   eCurrentProperty: IInterface;
Begin
    eProperties := ElementByName(aeScript, 'Properties');
    For iCurrentProperty := 0 To ElementCount(eProperties) - 1 Do Begin
        eCurrentProperty := ElementByIndex(eProperties, iCurrentProperty);
        If Name(eCurrentProperty) = 'Property' Then Begin
            If (GetEditValue(ElementByName(eCurrentProperty, 'propertyName')) = asPropertyName) Then Begin
                Result := eCurrentProperty;
                Exit;
            End;
        End;
    End;
End;

{Edited function by  DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts}
Function AttachArmorScript(aeForm: IInterface; asName: String; abRedundant: Boolean): IInterface;
Var
   eVMAD: IInterface;
   eScripts: IInterface;
   eNewScript: IInterface;
Begin
    Result := GetArmorScript(aeForm, asName);
    If Not Assigned(Result) Or abRedundant Then Begin
        Add(aeForm, 'VMAD', True);
        SetElementNativeValues(aeForm, 'VMAD\Version', 5);
        SetElementNativeValues(aeForm, 'VMAD\Object Format', 2);
        eVMAD := ElementBySignature(aeForm, 'VMAD');
        eScripts := ElementByPath(eVMAD, 'Scripts');
        eNewScript := ElementAssign(eScripts, HighInteger, nil, False);
        SetEditValue(ElementByName(eNewScript, 'scriptName'), asName);
        Result := eNewScript;
    End;
End;

{Edited function by  DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts}
Function AttachQuestScript(aeForm: IInterface; asName: String): IInterface;
Var
   eVMAD: IInterface;
   eScripts: IInterface;
   eNewScript: IInterface;
Begin
    Result := GetArmorScript(aeForm, asName);
    If Not Assigned(Result) Then Begin
        Add(aeForm, 'VMAD', True);
        SetElementNativeValues(aeForm, 'VMAD\Version', 5);
        SetElementNativeValues(aeForm, 'VMAD\Object Format', 2);
        eVMAD := ElementBySignature(aeForm, 'VMAD');
        eScripts := ElementByPath(eVMAD, 'Scripts');
        eNewScript := ElementAssign(eScripts, HighInteger, nil, False);
        SetEditValue(ElementByName(eNewScript, 'scriptName'), asName);
        Result := eNewScript;
    End;
End;


Function getFileNameFromPath(sPath : String) : String;
Var
    iNameStartIndex : Integer;
    iNameEndIndex : Integer;
Begin
    iNameStartIndex := getSubStringPos(sPath,'] ',1) + 2;
    iNameEndIndex := getSubStringPos(sPath,' \ [',iNameStartIndex);
    Result := Copy(sPath, iNameStartIndex, iNameEndIndex - iNameStartIndex);
End;

Procedure patchDevice(eInventoryDevice: IInterface);
var
    eInventoryScript : IInterface;
    iIterator : Integer;
    eRenderDeviceFormID : IInterface;
    eRenderDevice : IInterface;
    eRenderDeviceProperty : IInterface;
    eNewRenderDeviceProperty : IInterface;
    //eNewInventoryScript: IInterface;
    eNewRenderScript: IInterface;
    sRenderScriptName : String;
    eNewRenderDevice : IInterface;
    eInventoryScriptUD : IInterface;
    bInventoryDeviceHaveUDScript : Bool;
    bRenderDeviceHaveUDScript : Bool;
    eInventoryScriptPoperties : IInterface;
    eUDCDProperty : IInterface;
Begin
    //AddMessage(Format('Patching started for %s',[Name(eInventoryDevice)]));
    eInventoryScriptUD := GetArmorScript(eInventoryDevice, 'UD_CustomDevice_EquipScript');
    bInventoryDeviceHaveUDScript := False;
    bRenderDeviceHaveUDScript := False;
    for iIterator := 0 to iZadScriptNum - 1 do 
    Begin
        eInventoryScript := GetArmorScript(eInventoryDevice, zadscripts[iIterator]);
        if Assigned(eInventoryScript) then
            break;
    End;
    bInventoryDeviceHaveUDScript := ArmorHaveUDScript(eInventoryDevice);

    if Assigned(eInventoryScript) then Begin
        eRenderDeviceProperty := GetPropertyFromScript(eInventoryScript, 'deviceRendered');
    end else if bInventoryDeviceHaveUDScript then Begin
        eRenderDeviceProperty := GetPropertyFromScript(eInventoryScriptUD, 'deviceRendered');
    end else Begin
        AddMessage(Format('-Not supported script detected on %s! Skipping!-',[EditorID(eInventoryDevice)]));
        Exit;
    End;
        
    eRenderDeviceFormID := ElementByPath(eRenderDeviceProperty, 'Value\Object Union\Object v2\FormID');
    eRenderDevice := LinksTo(eRenderDeviceFormID);
    
    bRenderDeviceHaveUDScript := ArmorHaveUDScript(eRenderDevice);
    
    if bInventoryDeviceHaveUDScript and bRenderDeviceHaveUDScript then begin
        AddMessage(Format('-Device %s already patched! Skipping!-',[EditorID(eInventoryDevice)]));
        exit;
    end;
    
    addKeywordToArmor(eInventoryDevice,ePatchInvKW);
    
    
    if not bInventoryDeviceHaveUDScript then Begin
        
        SetEditValue(ElementByName(eInventoryScript, 'scriptName'), 'UD_CustomDevice_EquipScript');
        sRenderScriptName := selectNewUDScript(eInventoryDevice, eInventoryScript, iIterator);
        eUDCDProperty := ElementAssign(ElementByName(eInventoryScript, 'Properties'),HighInteger, nil,False);
        SetEditValue(ElementByName(eUDCDProperty, 'propertyName'), 'UDCDmain');        
        SetNativeValue(ElementByName(eUDCDProperty, 'Type'), 1);
        SetNativeValue(ElementByName(eUDCDProperty, 'Flags'), 1); // "Edited"    
        SetElementEditValues(eUDCDProperty, 'Value\Object Union\Object v2\FormID', getEditValue(eUDCDmain));
        SetElementNativeValues(eUDCDProperty, 'Value\Object Union\Object v2\Alias', -1);
        
        if not bRenderDeviceHaveUDScript then Begin
            eNewRenderScript := AttachArmorScript(eRenderDevice, sRenderScriptName, true);
            copyInventoryScriptValuesToRender(eInventoryScript,eNewRenderScript,True);
            AddMessage(Format('Device %s patched!', [name(eInventoryDevice)]));
            iTotalPatchedDevice := iTotalPatchedDevice + 1;
            addKeywords(eRenderDevice);
            exit;
        end else begin
            AddMessage(Format('WARNING: Render device %s already have UD script! Creating new render device!', [editorID(eRenderDevice)]));
            iNewDevices := iNewDevices + 1;
            eNewRenderDevice := wbCopyElementToFile(eRenderDevice,ePatchFile,True,True);
            SetEditorID(eNewRenderDevice,EditorID(eInventoryDevice) + '_AddedRenderDevice');
            eNewRenderScript := GetArmorScript(eNewRenderDevice, sRenderScriptName);//AttachArmorScript(eNewRenderDevice, sRenderScriptName, true);
            copyInventoryScriptValuesToRender(eInventoryScript,eNewRenderScript,False);
            eNewRenderDeviceProperty := GetPropertyFromScript(eInventoryScript, 'deviceRendered');
            SetElementNativeValues(eNewRenderDeviceProperty,'Value\Object Union\Object v2\FormID',GetNativeValue(eNewRenderDevice));
            AddMessage(Format('---NEW DEVICE %s CREATED!---', [Name(eNewRenderDevice)]));
            exit;    
        end;

    end else if not bRenderDeviceHaveUDScript then Begin
        AddMessage(Format('Device with patched INV but not patched REND detected. Patching renderDevice %s',[editorID(eRenderDevice)]));
        
        sRenderScriptName := selectNewUDScript(eInventoryDevice, eInventoryScriptUD, 0);
        eNewRenderScript := AttachArmorScript(eRenderDevice, sRenderScriptName, true);
        
        copyInventoryScriptValuesToRender(eInventoryScriptUD,eNewRenderScript,True);
        addKeywords(eRenderDevice);    
        iTotalPatchedDevice := iTotalPatchedDevice + 1;
        AddMessage(Format('Repatched RenderDevice of %s (Render device %s)!', [editorID(eInventoryDevice),editorID(eRenderDevice)]));
        exit;
    end;
End;

Function selectNewUDScript(eInventoryDevice : IInterface; eInventoryScript : IInterface; iOldScriptType : Integer) : String;
Var
    sNewScriptName : String;
Begin
    sNewScriptName := 'UD_CustomDevice_RenderScript';
    case (iOldScriptType) of
        0,12,13,14,15,27,30,28 : sNewScriptName:= 'UD_CustomDevice_RenderScript';
        1 : sNewScriptName:= 'UD_CustomGag_RenderScript';
        2,9,10,11,23,33,34,35 : sNewScriptName:= 'UD_CustomBelt_RenderScript';
        26 : sNewScriptName:= 'UD_CustomBra_RenderScript';
        3 : sNewScriptName:= 'UD_CustomCorset_RenderScript';
        4,5 : sNewScriptName:= 'UD_CustomPlug_RenderScript';
        7 : sNewScriptName:= 'UD_CustomInflatablePlug_RenderScript';
        16 : sNewScriptName:= 'UD_CustomHeavyBondage_RenderScript';
        17,18 : sNewScriptName:= 'UD_CustomBlindfold_RenderScript';
        19,21 : sNewScriptName:= 'UD_CustomBoots_RenderScript';
        22,25 : sNewScriptName:= 'UD_CustomCollar_RenderScript';
        24 : sNewScriptName:= 'UD_CustomGloves_RenderScript';
        31,32 : sNewScriptName:= 'UD_CustomPiercing_RenderScript';
        6 : sNewScriptName:= 'UD_CustomChargPlug_RenderScript';
        8 : sNewScriptName:= 'UD_CustomPanelGag_RenderScript';
        29 : sNewScriptName:= 'UD_CustomMittens_RenderScript';
    End;
    
    //repatch default devices
    if sNewScriptName = 'UD_CustomDevice_RenderScript' then Begin
        if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousHeavyBondage') Then Begin
            sNewScriptName := 'UD_CustomHeavyBondage_RenderScript';
        end else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousSuit') Then Begin
            sNewScriptName := 'UD_CustomSuit_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousCollar') Then Begin
            sNewScriptName := 'UD_CustomCollar_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousBoots') Then Begin
            sNewScriptName := 'UD_CustomBoots_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousHood') Then Begin
            sNewScriptName := 'UD_CustomHood_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousGloves') Then Begin
            sNewScriptName := 'UD_CustomGloves_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousGag') Then Begin
            sNewScriptName := 'UD_CustomGag_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousBlindfold') Then Begin
            sNewScriptName := 'UD_CustomBlindfold_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousPlug') Then Begin
            sNewScriptName := 'UD_CustomPlug_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousCorset') Then Begin
            sNewScriptName := 'UD_CustomCorset_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousBelt') Then Begin
            sNewScriptName := 'UD_CustomBelt_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousHarness') Then Begin
            sNewScriptName := 'UD_CustomHarness_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousBra') Then Begin
            sNewScriptName := 'UD_CustomBra_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousArmCuffs') Then Begin
            sNewScriptName := 'UD_CustomArmCuffs_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousLegCuffs') Then Begin
            sNewScriptName := 'UD_CustomLegCuffs_RenderScript';
        End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousPiercingsNipple') or DDeviceHaveKeyword(eInventoryScript,'zad_DeviousPiercingsVaginal') Then Begin
            sNewScriptName := 'UD_CustomPiercing_RenderScript';        
        End;
    End else if (sNewScriptName = 'UD_CustomBelt_RenderScript') or (sNewScriptName = 'UD_CustomHarness_RenderScript') then Begin
        if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousHarness') Then Begin
            sNewScriptName := 'UD_CustomHarness_RenderScript';
        End;
    End;
    
    if sNewScriptName = 'UD_CustomGag_RenderScript' then Begin //Repatch gags
        if ContainsWord(getArmorName(eInventoryDevice),'(Panel)',1) then Begin
            sNewScriptName := 'UD_CustomPanelGag_RenderScript';
        End else if containsWord(getArmorName(eInventoryDevice),'Inflat',1) then Begin
            sNewScriptName := 'UD_CustomInflatableGag_RenderScript';
        End;    
    End else if sNewScriptName = 'UD_CustomPlug_RenderScript' then Begin //repatch plugs
        if ContainsWord(getArmorName(eInventoryDevice),'Grand',1) then Begin
            sNewScriptName := 'UD_ControlablePlug_RenderScript';
        End else if ContainsWord(getArmorName(eInventoryDevice),'Inflatable',1) then Begin
            sNewScriptName := 'UD_CustomInflatablePlug_RenderScript';
        End;
    End else if (sNewScriptName = 'UD_CustomBelt_RenderScript') or (sNewScriptName = 'UD_CustomHarness_RenderScript') then Begin //Repatch belts
        if ContainsWord(getArmorName(eInventoryDevice),'Crotch',1) then Begin
            sNewScriptName := 'UD_CustomCrotchDevice_RenderScript';
        End;
    End else if DDeviceHaveKeyword(eInventoryScript,'zad_DeviousHood') then Begin
        if ContainsWord(getArmorName(eInventoryDevice),'Gas',1) then Begin
            sNewScriptName := 'UD_CustomGasMask_RenderScript';
        End;
    End;
    Result := sNewScriptName
End;



{!!!!!!!!!!!!!!!!!!!!!!!UNUSED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{Edited function by  DavidJCobb - https://github.com/DavidJCobb/xedit-tesv-scripts}
Procedure RemoveArmorScript(aeForm: IInterface; asName: String);
Var
   sElemName: String;
   eVMAD: IInterface;
   eScripts: IInterface;
   iCurrentScript: Integer;
   eCurrentScript: IInterface;
   sCurrentScript: String;
   eNewScript: IInterface;
   iScriptsToKillCount: Integer;
   elScriptsToKill: Array[0..512] of IInterface;
Begin
   eVMAD := ElementBySignature(aeForm, 'VMAD');
   If Not Assigned(eVMAD) Then Exit;
   eScripts := ElementByPath(eVMAD, 'Scripts');
   //
   iScriptsToKillCount := 0;
   //
   For iCurrentScript := 0 To ElementCount(eScripts) - 1 Do Begin
      eCurrentScript := ElementByIndex(eScripts, iCurrentScript);
      If Name(eCurrentScript) = 'Script' Then Begin
         sCurrentScript := GetEditValue(ElementByName(eCurrentScript, 'scriptName'));
     If (sCurrentScript = asName) And (iScriptsToKillCount < 512) Then Begin
        //
        // Mark this script for removal.
        //
        elScriptsToKill[iScriptsToKillCount] := eCurrentScript;
        iScriptsToKillCount := iScriptsToKillCount + 1;
     End;
      End;
   End;
   //
   // Remove the found scripts.
   //
   For iCurrentScript := 0 To iScriptsToKillCount Do Begin
      Remove(elScriptsToKill[iCurrentScript]);
   End;
End;

End.

