Scriptname PM_MuseumStatusScript extends ObjectReference

GlobalVariable Property CurrentDisplays Auto
FormList Property AllDisplayStands Auto

Event OnActivate(ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif

    Int currentCount = 0
    Int totalCount = 0

    if CurrentDisplays != None
        currentCount = CurrentDisplays.GetValueInt()
    endif

    if AllDisplayStands != None
        totalCount = AllDisplayStands.GetSize()
    endif

    Debug.MessageBox("Museum displays: " + currentCount + " / " + totalCount)
EndEvent
