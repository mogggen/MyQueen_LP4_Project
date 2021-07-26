import messagingSystem;
import Telegram;
import Guard;

class AStone : AActor
{
    AMessageDispatcher dispatcher;

    UPROPERTY(DefaultComponent)
    UAudioComponent audioComponent;

    UPROPERTY(EditAnywhere)
    USoundCue sound1;

    UPROPERTY(EditAnywhere)
    USoundCue sound2;

    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent mesh;

    UPROPERTY(EditAnywhere)
    float damege = 5;

    float dot;
    float prevDot;
    FVector prevVelocity;
    bool hasTouchedGround = false;

    UPROPERTY()
    float stoneLoudness = 2000.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);

         audioComponent.SetSound(sound1);

        ensure(messageDispatchers.Num() > 0, "stone.as, BeginPlay(): No messagesDispatcher found!");
        dispatcher = messageDispatchers[0];
    }
    
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (prevVelocity.Size() != 0)
        {
            dot = FMath::Abs((Velocity.DotProduct(prevVelocity) / prevDot - 1));
            if (dot >= .1f) // the intensity of the hit
            {
                if (!hasTouchedGround)
                {
                    dispatcher.dispatchSoundMessage(Telegram(
                        this,
                        Cast<AMessageCharacter>(nullptr),
                        messegeEnum::SuspiciousSound,
                        0,
                        ""
                        ), stoneLoudness);
                    audioComponent.Play();
                    hasTouchedGround = true;
                }
                if (dot >= .3f)
                    audioComponent.PitchMultiplier = dot;
            }
        }
        
        prevVelocity = Velocity;
        prevDot = Velocity.DotProduct(prevVelocity);
    }

    void addVelocity(FVector start)
    {
        mesh.AddImpulse(start);
    }

    UFUNCTION()
    void DamegeGuard(AActor hitActor)
    {
        AActor stone = Cast<AActor>(this);
        AMessageCharacter guard = Cast<AMessageCharacter>(hitActor);
        Telegram msg = Telegram(stone, guard, messegeEnum::Damage, 0, "");
        msg.extraFloat = damege;

        dispatcher.dispatchMessage(msg);
    }
}