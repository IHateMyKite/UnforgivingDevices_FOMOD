Unit UD_AddModifier;

Uses UD_Libs;
Var
    bFileLoaded : Bool;
    aeModifierNum   : Integer;
    aeModifierQuest : array[0..255] of IInterface;
    aeModifierAlias : array[0..255] of integer;

Function Initialize : integer;
Begin
    loadGlobals();
End;

Function Process(aeElement: IInterface) : Integer; 
Var
    sPatchFilePath : String;
    sPatchName : String;
    clb: TCheckListBox;
    frm: TForm;
    gQUEST: IInterface;
    i1: integer;
    i2: integer;
    i3: integer;
    aeSelectedSlots: IInterface;
    aeFile: IInterface;
    aeModifier: IInterface;
    sPara : string;
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
        
        
        frm := frmFileSelect;
        frm.Caption := 'Select modifier';
        clb := TCheckListBox(frm.FindComponent('CheckListBox1'));
        
        for i2 := 0 to Pred(FileCount) do
        begin
            aeFile := FileByIndex(i2);
            
            if HasMaster(aeFile,'UnforgivingDevices.esp') or (BaseName(aeFile) = 'UnforgivingDevices.esp') then
            begin
                
                gQUEST := GroupBySignature(aeFile,'QUST');
                
                for i1 := 0 to Pred(ElementCount(gQUEST)) do
                begin
                    if GetElementEditValues(ElementByIndex(ElementByPath(ElementByIndex(gQUEST, i1),'VMAD\Scripts'),0),'ScriptName') = 'UD_ModifierStorage' then
                    begin
                        for i3 := 0 to ElementCount(ElementByName(ElementByIndex(gQUEST, i1),'Aliases')) do
                        begin
                            aeModifier := ElementByIndex(ElementByName(ElementByIndex(gQUEST, i1),'Aliases'),i3);
                            if ElementExists(aeModifier, 'ALID') then 
                            begin
                                aeModifierQuest[aeModifierNum] := ElementByIndex(gQUEST, i1);
                                aeModifierAlias[aeModifierNum] := i3;
                                aeModifierNum := aeModifierNum + 1;
                                
                                clb.Items.AddObject((GetElementEditValues(aeModifier, 'ALID')), aeModifier );
                            end;
                        end;
                    end;
                end;
            end;
        end;
        
        if frm.ShowModal = mrOk then
        begin
            //inventory device
            if ArmorHaveKeyword(aeElement,eUDKW) then
            Begin
                for i1 := 0 to Pred(clb.Items.Count) do
                begin
                    if clb.Checked[i1] then 
                    begin
                        AddModifier(aeElement,i1,GetInput(clb.Items[i1]));
                    end;
                end;
            End;
        end;
    End;
End;

function GetInput(asModifier : string) : void;
var 
    sResult : string;
begin
    if InputQuery('Enter', Format('String parameter (%s)',[asModifier]), sResult) then begin
    end else begin
        sResult := '';
    end;
    
    Result := sResult;
end;

function AddModifier(aeArmor: IInterface; iSelectedMod: integer; sParameter : string) : void;
var
   eVMAD: IInterface;
   eScripts: IInterface;
   eUDscript: IInterface;
   eProperties: IInterface;
   
   eProperty_ModRef: IInterface;
   eProperty_ModRef_NewValue: IInterface;
   iModRefExist: Integer;
   
   eProperty_ModDataStr: IInterface;
   eProperty_ModDataStr_NewValue: IInterface;
   iModDataStrExist: Integer;
   
   eProperty_ModDataForm1: IInterface;
   eProperty_ModDataForm1_NewValue: IInterface;
   iModDataForm1Exist: Integer;
   
   eProperty_ModDataForm2: IInterface;
   eProperty_ModDataForm2_NewValue: IInterface;
   iModDataForm2Exist: Integer;
   
   eProperty_ModDataForm3: IInterface;
   eProperty_ModDataForm3_NewValue: IInterface;
   iModDataForm3Exist: Integer;
   
   iIterator: Integer;
begin
    eVMAD := ElementBySignature(aeArmor, 'VMAD');
    If Not Assigned(eVMAD) Then Exit;
    eScripts := ElementByPath(eVMAD, 'Scripts');
    
    //get first script
    eUDscript := ElementByIndex(eScripts, 0);
    
    eProperties := ElementByName(eUDscript, 'Properties');
    
    iModRefExist := 0;
    iModDataStrExist := 0;
    iModDataForm1Exist := 0;
    iModDataForm2Exist := 0;
    iModDataForm3Exist := 0;
    
    for iIterator := 0 To ElementCount(eProperties) - 1 do Begin
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = 'UD_ModifiersRef'  then Begin
            //AddMessage('UD_ModifiersRef already present');
            eProperty_ModRef := ElementByIndex(eProperties,iIterator);
            iModRefExist := 1;
        End;
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = 'UD_ModifiersDataStr'  then Begin
            AddMessage('UD_ModifiersDataStr already present');
            eProperty_ModDataStr := ElementByIndex(eProperties,iIterator);
            iModDataStrExist := 1;
        End;
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = 'UD_ModifiersDataForm1'  then Begin
            //AddMessage('UD_ModifiersDataForm1 already present');
            eProperty_ModDataForm1 := ElementByIndex(eProperties,iIterator);
            iModDataForm1Exist := 1;
        End;
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = 'UD_ModifiersDataForm2'  then Begin
            //AddMessage('UD_ModifiersDataForm2 already present');
            eProperty_ModDataForm2 := ElementByIndex(eProperties,iIterator);
            iModDataForm2Exist := 1;
        End;
        if getEditValue(ElementByName(ElementByIndex(eProperties,iIterator), 'propertyName')) = 'UD_ModifiersDataForm3'  then Begin
            //AddMessage('UD_ModifiersDataForm3 already present');
            eProperty_ModDataForm3 := ElementByIndex(eProperties,iIterator);
            iModDataForm3Exist := 1;
        End;
    End;
    
    if (iModRefExist = 0) then
    begin
        eProperty_ModRef := ElementAssign(eProperties,HighInteger, nil,False);
        SetEditValue(ElementByName(eProperty_ModRef, 'Type'), 11);
        SetEditValue(ElementByName(eProperty_ModRef, 'propertyName'), 'UD_ModifiersRef');
        AddMessage('Added property UD_ModifierRef');
    end;
    
    if (iModDataStrExist = 0) then
    begin
        eProperty_ModDataStr := ElementAssign(eProperties,HighInteger, nil,False);
        SetEditValue(ElementByName(eProperty_ModDataStr, 'Type'), 12);
        SetEditValue(ElementByName(eProperty_ModDataStr, 'propertyName'), 'UD_ModifiersDataStr');
        AddMessage('Added property UD_ModifierDataStr');
    end;
    
    if (iModDataForm1Exist = 0) then
    begin
        eProperty_ModDataForm1 := ElementAssign(eProperties,HighInteger, nil,False);
        SetEditValue(ElementByName(eProperty_ModDataForm1, 'Type'), 11);
        SetEditValue(ElementByName(eProperty_ModDataForm1, 'propertyName'), 'UD_ModifiersDataForm1');
        AddMessage('Added property UD_ModifierDataForm1');
    end;
    
    if (iModDataForm2Exist = 0) then
    begin
        eProperty_ModDataForm2 := ElementAssign(eProperties,HighInteger, nil,False);
        SetEditValue(ElementByName(eProperty_ModDataForm2, 'Type'), 11);
        SetEditValue(ElementByName(eProperty_ModDataForm2, 'propertyName'), 'UD_ModifiersDataForm2');
        AddMessage('Added property UD_ModifierDataForm2');
    end;
    
    if (iModDataForm3Exist = 0) then
    begin
        eProperty_ModDataForm3 := ElementAssign(eProperties,HighInteger, nil,False);
        SetEditValue(ElementByName(eProperty_ModDataForm3, 'Type'), 11);
        SetEditValue(ElementByName(eProperty_ModDataForm3, 'propertyName'), 'UD_ModifiersDataForm3');
        AddMessage('Added property UD_ModifierDataForm3');
    end;
    
    eProperty_ModRef_NewValue       := ElementAssign(ElementByIndex(ElementByName(eProperty_ModRef,'Value'),0),HighInteger,nil,False);
    eProperty_ModDataStr_NewValue   := ElementAssign(ElementByIndex(ElementByName(eProperty_ModDataStr,'Value'),0),HighInteger,nil,False);
    eProperty_ModDataForm1_NewValue := ElementAssign(ElementByIndex(ElementByName(eProperty_ModDataForm1,'Value'),0),HighInteger,nil,False);
    eProperty_ModDataForm2_NewValue := ElementAssign(ElementByIndex(ElementByName(eProperty_ModDataForm2,'Value'),0),HighInteger,nil,False);
    eProperty_ModDataForm3_NewValue := ElementAssign(ElementByIndex(ElementByName(eProperty_ModDataForm3,'Value'),0),HighInteger,nil,False);
    
    SetNativeValue(ElementByIndex(ElementByIndex(eProperty_ModRef_NewValue,0),0),GetNativeValue(aeModifierQuest[iSelectedMod]));
    SetEditValue(ElementByIndex(ElementByIndex(eProperty_ModRef_NewValue,0),1),aeModifierAlias[iSelectedMod]);
    
    SetEditValue(eProperty_ModDataStr_NewValue,sParameter);
end;


function Finalize : integer;
begin
end;

End.