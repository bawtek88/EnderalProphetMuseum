Scriptname PM_DisplayObjectBlocker extends ObjectReference

; Prevents the player from picking up or physically moving the displayed item.
Function LockDisplayObject()
    BlockActivation(true)
    SetMotionType(4, false) ; 4 = keyframed: frozen in place, with activation kept blocked
EndFunction

Event OnInit()
    LockDisplayObject()
EndEvent

Event OnLoad()
    LockDisplayObject()
EndEvent

Event OnCellAttach()
    LockDisplayObject()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    ; A held activation can ask Havok to grab the reference. Reassert the
    ; keyframed state immediately and once more on the following update.
    LockDisplayObject()
    RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
    LockDisplayObject()
EndEvent
