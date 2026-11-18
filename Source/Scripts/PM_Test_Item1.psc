Scriptname PM_Test_Item1 extends ObjectReference

Weapon Property RequiredItem Auto
ObjectReference Property DisplayObject Auto
GlobalVariable Property Donated Auto

Event OnActivate(ObjectReference akActionRef)
    Actor playerRef = Game.GetPlayer()

    if akActionRef != playerRef
        return
    endif

    if Donated.GetValueInt() == 1
        return
    endif

    if playerRef.GetItemCount(RequiredItem) >= 1
        playerRef.RemoveItem(RequiredItem, 1, true)
        DisplayObject.Enable()
        Donated.SetValue(1.0)
    endif
EndEvent