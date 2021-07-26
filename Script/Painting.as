import messagingSystem;

class APainting : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent painting;

    UPROPERTY(DefaultComponent, Attach = painting)
    UBoxComponent voiceTriggerBox;

    default voiceTriggerBox.OnComponentBeginOverlap.AddUFunction(this, n"turnOnLineTrace");
    default voiceTriggerBox.OnComponentEndOverlap.AddUFunction(this, n"turnOffLineTrace");

    TArray<AActor> overlappingActors;
    AActor player;
    bool playerIsInside = false;
    bool isLookingAtPainting = false;
    bool hasSentMessage = false; // becomes and stays true after a message has been sent to play a voice line

    UPROPERTY()
    USoundCue relevantDialog;
    FHitResult hitResult;
    TArray<AActor> actorsToIgnore;

    AMessageDispatcher dispatcher;

    UFUNCTION()
    void turnOnLineTrace(UPrimitiveComponent overlappedComponent, AActor otherActor, 
    UPrimitiveComponent otherComp, int otherBodyIndex, bool bFromSweep, const FHitResult&in sweepResult)
    {
        if (otherActor != Gameplay::GetPlayerPawn(0)) return;
        player = otherActor;

        playerIsInside = true;
        actorsToIgnore.AddUnique(player);
    }
    UFUNCTION()
    void turnOffLineTrace(UPrimitiveComponent overlappedComponent, AActor otherActor, UPrimitiveComponent otherComp, int otherBodyIndex)
    {
        if (otherActor != Gameplay::GetPlayerPawn(0)) return;
        playerIsInside = false;
        isLookingAtPainting = false;
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "Painting.as, BeginPlay(): No messagesDispatcher found!");
        dispatcher = messageDispatchers[0];
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(playerIsInside)
        {
            if(player == nullptr) return;
            if(painting.GetStaticMesh() == nullptr) return;

            UCameraComponent cameraComponent = Cast<UCameraComponent>(player.GetComponentByClass(UCameraComponent::StaticClass()));

            FVector start = cameraComponent.WorldLocation;
            FVector end = cameraComponent.WorldLocation + cameraComponent.ForwardVector * 500;
            System::LineTraceSingle(start, end, ETraceTypeQuery::Camera, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, false);

            // if hitResult is painting, play relevantDialog
            if(hitResult.Actor == nullptr) {
                isLookingAtPainting = false;
                return;
            }
            if(this.Name == hitResult.Actor.Name) {
                isLookingAtPainting = true;

                if(!hasSentMessage) {
                    // send message here, only happens once in the whole game for now
                    if(relevantDialog == nullptr) return; // don't send if relevantDialog is empty
                    Telegram telegram = Telegram(this, Cast<AMessageCharacter>(player), messegeEnum::VOICELINE, 0, "");
                    telegram.extraSoundque = relevantDialog;
                    dispatcher.dispatchMessage(telegram);
                    hasSentMessage = true;
                }

                return;
            }
            isLookingAtPainting = false;
        }
    }
}