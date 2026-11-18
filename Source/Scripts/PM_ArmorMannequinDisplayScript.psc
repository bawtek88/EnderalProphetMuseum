Scriptname PM_ArmorMannequinDisplayScript extends ObjectReference

; The placed mannequin actor controlled by this activator.
Actor Property Mannequin Auto

; Configure any or all of the five supported display slots.
Armor Property OriginalHelmet Auto
Armor Property OriginalCuirass Auto
Armor Property OriginalGloves Auto
Armor Property OriginalBoots Auto
Armor Property OriginalCape Auto

; Optional replicas. A replica is preferred over its matching original.
Armor Property ReplicaHelmet Auto
Armor Property ReplicaCuirass Auto
Armor Property ReplicaGloves Auto
Armor Property ReplicaBoots Auto
Armor Property ReplicaCape Auto

; Optional compatibility overrides. Normally leave these empty.
GlobalVariable Property CurrentDisplays Auto
Message Property MenuMessage Auto

; Optional interaction-name override. Leave empty to use the armor set/item name.
String Property DisplayName Auto

; Saved per-reference state. These remember the exact forms donated.
Armor DonatedHelmet
Armor DonatedCuirass
Armor DonatedGloves
Armor DonatedBoots
Armor DonatedCape

Event OnInit()
    UpdateDisplayName()
    PrepareMannequin()
EndEvent

Event OnCellAttach()
    UpdateDisplayName()
    PrepareMannequin()
    ReequipDisplayedItems()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor playerRef = Game.GetPlayer()
    if akActionRef != playerRef
        return
    endif

    if Mannequin == None
        Debug.Notification("This armor display has no mannequin assigned.")
        return
    endif

    if !IsConfigurationValid()
        Debug.Notification("This armor display has not been configured correctly.")
        return
    endif

    Message menu = GetMenuMessage()
    if menu == None
        Debug.Notification("The armor display menu is unavailable.")
        return
    endif

    PrepareMannequin()
    Int choice = menu.Show()
    if choice == 0
        PlaceEligibleItems(playerRef)
    elseif choice == 1
        TakeDisplayedItems(playerRef)
    endif
EndEvent

Function PlaceEligibleItems(Actor playerRef)
    Int placedCount = 0
    Armor placedItem

    if DonatedHelmet == None && OriginalHelmet != None
        placedItem = PlaceOneItem(OriginalHelmet, ReplicaHelmet, playerRef)
        if placedItem != None
            DonatedHelmet = placedItem
            placedCount += 1
        endif
    endif

    if DonatedCuirass == None && OriginalCuirass != None
        placedItem = PlaceOneItem(OriginalCuirass, ReplicaCuirass, playerRef)
        if placedItem != None
            DonatedCuirass = placedItem
            placedCount += 1
        endif
    endif

    if DonatedGloves == None && OriginalGloves != None
        placedItem = PlaceOneItem(OriginalGloves, ReplicaGloves, playerRef)
        if placedItem != None
            DonatedGloves = placedItem
            placedCount += 1
        endif
    endif

    if DonatedBoots == None && OriginalBoots != None
        placedItem = PlaceOneItem(OriginalBoots, ReplicaBoots, playerRef)
        if placedItem != None
            DonatedBoots = placedItem
            placedCount += 1
        endif
    endif

    if DonatedCape == None && OriginalCape != None
        placedItem = PlaceOneItem(OriginalCape, ReplicaCape, playerRef)
        if placedItem != None
            DonatedCape = placedItem
            placedCount += 1
        endif
    endif

    if placedCount == 0
        Debug.Notification("I don't have any unequipped eligible items.")
        return
    endif

    GlobalVariable displayCounter = GetDisplayCounter()
    if displayCounter != None
        displayCounter.Mod(placedCount as Float)
    endif
    Debug.Notification("Eligible armor added to the display.")
EndFunction

Armor Function PlaceOneItem(Armor originalItem, Armor replicaItem, Actor playerRef)
    Armor selectedItem = None

    ; Prefer an unequipped replica. If that replica is equipped, an available
    ; unequipped original may still be used.
    if replicaItem != None && playerRef.GetItemCount(replicaItem) > 0 && !playerRef.IsEquipped(replicaItem)
        selectedItem = replicaItem
    elseif playerRef.GetItemCount(originalItem) > 0 && !playerRef.IsEquipped(originalItem)
        selectedItem = originalItem
    endif

    if selectedItem == None
        return None
    endif

    playerRef.RemoveItem(selectedItem, 1, true, Mannequin)
    Utility.Wait(0.1)

    ; Enderal's mannequin controller normally equips armor from OnItemAdded.
    ; This explicit call also makes the display reliable after unusual load order.
    if Mannequin.GetItemCount(selectedItem) > 0
        Mannequin.EquipItem(selectedItem, false, true)
        return selectedItem
    endif

    return None
EndFunction

Function TakeDisplayedItems(Actor playerRef)
    Int removedCount = 0

    if DonatedHelmet != None
        RetrieveOneItem(DonatedHelmet, playerRef)
        DonatedHelmet = None
        removedCount += 1
    endif
    if DonatedCuirass != None
        RetrieveOneItem(DonatedCuirass, playerRef)
        DonatedCuirass = None
        removedCount += 1
    endif
    if DonatedGloves != None
        RetrieveOneItem(DonatedGloves, playerRef)
        DonatedGloves = None
        removedCount += 1
    endif
    if DonatedBoots != None
        RetrieveOneItem(DonatedBoots, playerRef)
        DonatedBoots = None
        removedCount += 1
    endif
    if DonatedCape != None
        RetrieveOneItem(DonatedCape, playerRef)
        DonatedCape = None
        removedCount += 1
    endif

    if removedCount == 0
        Debug.Notification("There are no items on this armor display.")
        return
    endif

    GlobalVariable displayCounter = GetDisplayCounter()
    if displayCounter != None
        displayCounter.Mod((0 - removedCount) as Float)
    endif
    Debug.Notification("Displayed armor returned.")
EndFunction

Function RetrieveOneItem(Armor donatedItem, Actor playerRef)
    if donatedItem == None || Mannequin.GetItemCount(donatedItem) <= 0
        return
    endif

    Mannequin.UnequipItem(donatedItem, false, true)
    Utility.Wait(0.05)
    Mannequin.RemoveItem(donatedItem, 1, true, playerRef)
EndFunction

Function PrepareMannequin()
    if Mannequin == None
        return
    endif

    ; The mannequin is visual-only. The player manages it through this activator.
    Mannequin.BlockActivation(true)
    Mannequin.EnableAI(false)

    ; Initialize Enderal's mannequin slot tracker before scripted transfers.
    _00E_Playerhousing_MannequinControl mannequinControl = Mannequin as _00E_Playerhousing_MannequinControl
    if mannequinControl != None
        mannequinControl.ConvertArmorSlots()
    endif
EndFunction

Function ReequipDisplayedItems()
    EquipIfPresent(DonatedHelmet)
    EquipIfPresent(DonatedCuirass)
    EquipIfPresent(DonatedGloves)
    EquipIfPresent(DonatedBoots)
    EquipIfPresent(DonatedCape)
EndFunction

Function EquipIfPresent(Armor donatedItem)
    if Mannequin != None && donatedItem != None && Mannequin.GetItemCount(donatedItem) > 0
        Mannequin.EquipItem(donatedItem, false, true)
    endif
EndFunction

Bool Function IsConfigurationValid()
    if OriginalHelmet == None && OriginalCuirass == None && OriginalGloves == None && OriginalBoots == None && OriginalCape == None
        return false
    endif

    if ReplicaHelmet != None && OriginalHelmet == None
        return false
    endif
    if ReplicaCuirass != None && OriginalCuirass == None
        return false
    endif
    if ReplicaGloves != None && OriginalGloves == None
        return false
    endif
    if ReplicaBoots != None && OriginalBoots == None
        return false
    endif
    if ReplicaCape != None && OriginalCape == None
        return false
    endif

    return true
EndFunction

Function UpdateDisplayName()
    if DisplayName != ""
        SetDisplayName(DisplayName, true)
        return
    endif

    Armor namingItem = OriginalCuirass
    if namingItem == None
        namingItem = OriginalHelmet
    endif
    if namingItem == None
        namingItem = OriginalCape
    endif
    if namingItem == None
        namingItem = OriginalGloves
    endif
    if namingItem == None
        namingItem = OriginalBoots
    endif

    if namingItem == None
        return
    endif

    String itemName = namingItem.GetName()
    if itemName == ""
        return
    endif

    ; Enderal prefixes armor pieces with their set in parentheses, for example
    ; "(Set of Inodan) Hood of Inodan". Use only that prefix for the activator.
    Int closingParenthesis = StringUtil.Find(itemName, ")", 1)
    if StringUtil.Find(itemName, "(", 0) == 0 && closingParenthesis > 1
        itemName = StringUtil.Substring(itemName, 1, closingParenthesis - 1)
    endif

    SetDisplayName(itemName, true)
EndFunction

Message Function GetMenuMessage()
    if MenuMessage != None
        return MenuMessage
    endif
    return Game.GetFormFromFile(0x00B682, "ProphetMuseum.esp") as Message
EndFunction

GlobalVariable Function GetDisplayCounter()
    if CurrentDisplays != None
        return CurrentDisplays
    endif
    return Game.GetFormFromFile(0x0052C6, "ProphetMuseum.esp") as GlobalVariable
EndFunction

