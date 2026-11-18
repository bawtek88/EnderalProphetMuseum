Scriptname PM_MuseumManagerQuestScript extends Quest

Event OnInit()
    CheckGreenScarabeusUnlock()
EndEvent

Function CheckGreenScarabeusUnlock()
    if IsStageDone(2000)
        return
    endif

    if IsStageDone(10)
        SetStage(2000)
        return
    endif

    Actor PlayerRef = Game.GetPlayer()
    MiscObject GreenScarabeus = Game.GetFormFromFile(0x00146FBE, "Skyrim.esm") as MiscObject
    if PlayerRef && GreenScarabeus && PlayerRef.GetItemCount(GreenScarabeus) > 0
        SetStage(2000)
    endif
EndFunction
