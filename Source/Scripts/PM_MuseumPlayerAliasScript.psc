Scriptname PM_MuseumPlayerAliasScript extends ReferenceAlias

Event OnInit()
    MigrateLegacyUnlock()
    CheckExistingReplicas()
EndEvent

Event OnPlayerLoadGame()
    MigrateLegacyUnlock()
    CheckExistingReplicas()
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    MiscObject GreenScarabeus = Game.GetFormFromFile(0x00146FBE, "Skyrim.esm") as MiscObject
    if akBaseItem == GreenScarabeus
        UnlockGreenScarabeus()
    endif
EndEvent

Function CheckExistingReplicas()
    Actor PlayerRef = GetReference() as Actor
    MiscObject GreenScarabeus = Game.GetFormFromFile(0x00146FBE, "Skyrim.esm") as MiscObject
    if PlayerRef && GreenScarabeus && PlayerRef.GetItemCount(GreenScarabeus) > 0
        UnlockGreenScarabeus()
    endif
EndFunction

Function UnlockGreenScarabeus()
    Quest ManagerQuest = Game.GetFormFromFile(0x0020E3, "ProphetMuseum.esp") as Quest
    if ManagerQuest && !ManagerQuest.IsStageDone(2000)
        ManagerQuest.SetStage(2000)
    endif
EndFunction

Function MigrateLegacyUnlock()
    Quest ManagerQuest = Game.GetFormFromFile(0x0020E3, "ProphetMuseum.esp") as Quest
    if ManagerQuest && ManagerQuest.IsStageDone(10) && !ManagerQuest.IsStageDone(2000)
        ManagerQuest.SetStage(2000)
    endif
EndFunction
