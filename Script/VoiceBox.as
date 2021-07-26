import messagingSystem;

class AVoiceBox : ATriggerBox
{
    bool playerIsInside = false;
    AMessageDispatcher dispatcher;

    UPROPERTY()
    USoundCue relevantDialog;
    bool hasSentMessage = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "VoiceBox.as, BeginPlay(): No messagesDispatcher found!");
        dispatcher = messageDispatchers[0];
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if (OtherActor != Gameplay::GetPlayerPawn(0)) return;

        playerIsInside = true;
        
        // don't send if relevantDialog is empty or message already has been sent
        if(relevantDialog != nullptr || !hasSentMessage) { 
            //play sound once
            Telegram telegram = Telegram(this, Cast<AMessageCharacter>(OtherActor), messegeEnum::VOICELINE, 0, "");
            telegram.extraSoundque = relevantDialog;
            dispatcher.dispatchMessage(telegram);
            hasSentMessage = true;
        }
    }
    UFUNCTION(BlueprintOverride)
    void ActorEndOverlap(AActor OtherActor)
    {
        if (OtherActor != Gameplay::GetPlayerPawn(0)) return;

        playerIsInside = false;
    }

    void destroyItem()
    {
        this.DestroyActor();
    }

}