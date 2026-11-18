Scriptname PM_DisplayStandScript extends ObjectReference

; Fill exactly ONE original property for each stand.
Weapon Property RequiredWeapon Auto
Armor Property RequiredArmor Auto
Book Property RequiredBook Auto
MiscObject Property RequiredMisc Auto

; Fill the matching replica property when this display supports a replica.
Weapon Property ReplicaWeapon Auto
Armor Property ReplicaArmor Auto
Book Property ReplicaBook Auto
MiscObject Property ReplicaMisc Auto

; Optional compatibility overrides. New stands can leave these empty.
GlobalVariable Property CurrentDisplays Auto
ObjectReference Property DisplayObject Auto

; Optional interaction-name override. Leave empty to use the required item's name.
String Property DisplayName Auto

; Saved state for this placed stand.
Bool Property Donated = false Auto
Form DonatedItem = None

Event OnInit()
    UpdateDisplayName()
    PrepareDisplayObject()
EndEvent

Event OnCellAttach()
    ; Reapply it whenever the museum cell loads. This also updates old stands
    ; after their configured required item has been changed in the editor.
    UpdateDisplayName()
    PrepareDisplayObject()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor playerRef = Game.GetPlayer()

    if akActionRef != playerRef
        return
    endif

    Form requiredItem = GetRequiredItem()
    Form replicaItem = GetReplicaItem()
    ObjectReference displayRef = GetDisplayObject()
    GlobalVariable displayCounter = GetDisplayCounter()

    if requiredItem == None || !IsReplicaConfigurationValid()
        Debug.Notification("This display has not been configured.")
        return
    endif

    if displayRef == None
        Debug.Notification("This display has no visual object assigned.")
        return
    endif

    ; If the item is already on display, clicking the stand retrieves it.
    if Donated
        displayRef.Disable()
        if DonatedItem == None
            DonatedItem = requiredItem
        endif
        playerRef.AddItem(DonatedItem, 1, true)
        DonatedItem = None
        Donated = false
        if displayCounter != None
            displayCounter.Mod(-1.0)
        endif
        return
    endif

    ; Prefer the replica, then fall back to the original.
    Form itemToDonate = None
    if replicaItem != None && playerRef.GetItemCount(replicaItem) > 0
        itemToDonate = replicaItem
    elseif playerRef.GetItemCount(requiredItem) > 0
        itemToDonate = requiredItem
    endif

    if itemToDonate == None
        Debug.Notification("I don't have that item.")
        return
    endif

    playerRef.RemoveItem(itemToDonate, 1, true)
    ; Enabling a reference can restore the base object's Havok motion type.
    ; Therefore it must be enabled first and frozen only after its 3D appears.
    displayRef.Enable()
    Utility.Wait(0.1)
    PrepareDisplayObject()
    DonatedItem = itemToDonate
    Donated = true
    if displayCounter != None
        displayCounter.Mod(1.0)
    endif
EndEvent

Function UpdateDisplayName()
    if DisplayName != ""
        SetDisplayName(DisplayName, true)
        return
    endif

    Form requiredItem = GetRequiredItem()
    if requiredItem == None
        return
    endif

    String itemName = requiredItem.GetName()
    if itemName != ""
        ; SetDisplayName changes this placed reference only, so every stand can
        ; keep using the same shared activator base.
        SetDisplayName(itemName, true)
    endif
EndFunction

Function PrepareDisplayObject()
    ObjectReference displayRef = GetDisplayObject()
    if displayRef == None
        return
    endif

    displayRef.BlockActivation(true)
    displayRef.SetMotionType(4, false) ; keyframed: remains exactly where placed
EndFunction

Form Function GetRequiredItem()
    Int configuredCount = 0
    Form selectedItem = None

    if RequiredWeapon != None
        configuredCount += 1
        selectedItem = RequiredWeapon
    endif

    if RequiredArmor != None
        configuredCount += 1
        selectedItem = RequiredArmor
    endif

    if RequiredBook != None
        configuredCount += 1
        selectedItem = RequiredBook
    endif

    if RequiredMisc != None
        configuredCount += 1
        selectedItem = RequiredMisc
    endif

    if configuredCount != 1
        return None
    endif

    return selectedItem
EndFunction

Form Function GetReplicaItem()
    Int configuredCount = 0
    Form selectedItem = None

    if ReplicaWeapon != None
        configuredCount += 1
        selectedItem = ReplicaWeapon
    endif

    if ReplicaArmor != None
        configuredCount += 1
        selectedItem = ReplicaArmor
    endif

    if ReplicaBook != None
        configuredCount += 1
        selectedItem = ReplicaBook
    endif

    if ReplicaMisc != None
        configuredCount += 1
        selectedItem = ReplicaMisc
    endif

    if configuredCount > 1
        return None
    endif

    return selectedItem
EndFunction

Bool Function IsReplicaConfigurationValid()
    Int configuredCount = 0

    if ReplicaWeapon != None
        configuredCount += 1
    endif
    if ReplicaArmor != None
        configuredCount += 1
    endif
    if ReplicaBook != None
        configuredCount += 1
    endif
    if ReplicaMisc != None
        configuredCount += 1
    endif

    return configuredCount <= 1
EndFunction

ObjectReference Function GetDisplayObject()
    ObjectReference linkedDisplay = GetLinkedRef()
    if linkedDisplay != None
        return linkedDisplay
    endif
    return DisplayObject
EndFunction

GlobalVariable Function GetDisplayCounter()
    if CurrentDisplays != None
        return CurrentDisplays
    endif
    return Game.GetFormFromFile(0x0052C6, "ProphetMuseum.esp") as GlobalVariable
EndFunction
