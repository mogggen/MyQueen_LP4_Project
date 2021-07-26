import messagingSystem;

class UDetectPlayer : UActorComponent
{
    APawn playerPawn;

    // Detect player
    UPROPERTY()
    float fieldOfView = 0.80;
    UPROPERTY()
    float guardEyePosZ = 60;
    UPROPERTY()
    float viewDistance = 1000;
    float arccos, dotProduct;

    UPROPERTY()
    float detectionDelay = 0.5;
    float detectionTimer = detectionDelay;
    
    // Line trace player
    //FHitResult hitResult;
    TArray<FHitResult> hitResults;
    TArray<AActor> actorsToIgnore; // currently empty but needed as argument in LineTraceSingle()
    UPROPERTY()
    float endPos = 50;
    UPROPERTY()
    bool showDetectionLines = false;

    bool canSeePlayer = false;
    
    AMessageDispatcher messageDispatcher;
    USkeletalMeshComponent ownerMesh;
    // used to match head rotation with the 90 degrees rotated actor mesh
    FRotator headRotation = FRotator(0, 90, 0);

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // get player
        playerPawn = Gameplay::GetPlayerPawn(0);
        
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "No message dispatcher found.");
        messageDispatcher = messageDispatchers[0];

        // get skeletal mesh component of guard (owner)
        ownerMesh = Cast<USkeletalMeshComponent>(GetOwner().GetComponentByClass(USkeletalMeshComponent::StaticClass()));
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // check if player is in fieldOfView
        if (Cast<AActor>(playerPawn) == nullptr)
        {
            //Print("UDetectPlayer, Tick: Agitated guard, with eronius component, must die!");
            GetOwner().DestroyActor();
            return;
        }
            
        FVector start, endHead, endFoot;
        EDrawDebugTrace debugTrace;
        FVector normalizedDistance, normalizedForwardVector;
        bool newCanSeePlayer = true;
        
        normalizedDistance = playerPawn.ActorLocation - GetOwner().ActorLocation;
        normalizedDistance.Normalize(0.0001);
        
        // use forward vector of head
        float finalY = headRotation.RotateVector(ownerMesh.GetSocketRotation(n"Head").ForwardVector).Y;
        normalizedForwardVector = FVector(GetOwner().ActorForwardVector.X, finalY, GetOwner().ActorForwardVector.Z);
        normalizedForwardVector.Normalize(0.0001);

        dotProduct = normalizedForwardVector.DotProduct(normalizedDistance);
        arccos = FMath::Acos(dotProduct);

        // check distance
        float distance = playerPawn.ActorLocation.Distance(GetOwner().ActorLocation);


        // if player in fieldOfView and close enough, check raycast
        if((arccos <= fieldOfView || canSeePlayer) && distance <= viewDistance){

            debugTrace = showDetectionLines ? EDrawDebugTrace::ForOneFrame : EDrawDebugTrace::None;

            start = GetOwner().ActorLocation + FVector(0,0,guardEyePosZ);
            endHead = playerPawn.ActorLocation + FVector(0, 0, playerPawn.ActorScale3D.Z) * endPos;
            endFoot = playerPawn.ActorLocation + FVector(0, 0, -playerPawn.ActorScale3D.Z) * endPos;

            // Fredrik's tips 'n' tricks
            //
            // Maybe use channes to only raycast walls and other solids
            // Soldiers can wolk to the side so they can see the player if another guard is blocking them.
            //
            
            // check to head
            // TraceTypeQuery1 is also called "PlayerDetection" in ProjectSettings->Engine->Collision, and in every BP.
            System::LineTraceMulti(start, endHead, ETraceTypeQuery::Visibility, false, actorsToIgnore,
                debugTrace, hitResults, true, FLinearColor::Green, FLinearColor::Red);
            
            for (int i = 0; i < hitResults.Num(); i++)
            {
                // if result is not a message character or 
                if (Cast<AMessageCharacter>(hitResults[i].Actor) == nullptr)
                {
                    newCanSeePlayer = false;
                    break;
                }
                // if result is AMessageCharacter and is not player, it's a guard or queen
                else if(hitResults[i].Actor != playerPawn)
                {
                    newCanSeePlayer = false;
                    break;
                }
            }

            if (!newCanSeePlayer)
            {
                // check to foot
                System::LineTraceMulti(start, endFoot, ETraceTypeQuery::Visibility, false, actorsToIgnore,
                debugTrace, hitResults, true, FLinearColor::Green, FLinearColor::Red);
                for (int i = 0; i < hitResults.Num(); i++)
                {
                    if (Cast<AMessageCharacter>(hitResults[i].Actor) == nullptr)
                    {
                        newCanSeePlayer = false;
                        break;
                    }
                    else if(hitResults[i].Actor != playerPawn)
                    {
                        newCanSeePlayer = false;
                        break;
                    }
                }
            }
        }
        else {
            newCanSeePlayer = false;
        }

        if(newCanSeePlayer == true && canSeePlayer == false)
        {
            if(detectionTimer < 0)
            {
                auto msg = Telegram(GetOwner(), Cast<AMessageCharacter>(playerPawn), messegeEnum::hasSpottedPlayer, 0.0, "");
                msg.extraBool = newCanSeePlayer;
                messageDispatcher.dispatchMessage(msg);
                canSeePlayer = true;
            }
            else
                detectionTimer -= DeltaSeconds;
        }
        else if (newCanSeePlayer == false && canSeePlayer == true)
        {
            auto msg = Telegram(GetOwner(), Cast<AMessageCharacter>(playerPawn), messegeEnum::hasSpottedPlayer, 0.0, "");
            msg.extraBool = newCanSeePlayer;
            messageDispatcher.dispatchMessage(msg);
            canSeePlayer = false;
        }
        else
            detectionTimer = detectionDelay;
    }
}