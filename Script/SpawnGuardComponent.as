import Guard;
import GuardSpawnPoint;
import messagingSystem;

class USpawnGuardComponent : UActorComponent
{
    UPROPERTY()
    float spawnRange = 4000.0f;
    UPROPERTY()
    float spawnDelay = 8.0f;
    UPROPERTY()
    float spawnDelayDecrament = 0.2f;

    float currentSpawnDelay = spawnDelay;
    float spawnTimer        = spawnDelay;

    UPROPERTY(EditDefaultsOnly)
    TSubclassOf<AGuard> spawnClass;

    AMessageDispatcher messageDispatcher;
    ARecastNavMesh recastNavMesh;

    bool isPlayerSeen = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "No message dispatcher found.");
        messageDispatcher = messageDispatchers[0];

        TArray<ARecastNavMesh> navmeshes;
        GetAllActorsOfClass(navmeshes);
        ensure(navmeshes.Num() > 0, "No message dispatcher found.");
        recastNavMesh = navmeshes[0];

    }

    void StartSpawn()
    {
        currentSpawnDelay = spawnDelay;
        spawnTimer        = spawnDelay;
    }

    void Update(float DeltaSeconds)
    {

        if (!isPlayerSeen)
            return;

        if (spawnTimer < 0.0f)
        {
            SpawnGuard();
            spawnTimer = currentSpawnDelay;
            //currentSpawnDelay -= spawnDelayDecrament;
        }
        else
        {
            spawnTimer -= DeltaSeconds;
        }
    }

    void SpawnGuard()
    {
        auto playerPawn = Gameplay::GetPlayerPawn(0);
        FVector playerLocation = playerPawn.GetActorLocation();
        TArray<AGuardSpawnPoint> spawnPoints;
        GetAllActorsOfClass(spawnPoints);
        //Print("Attempting to spawn guard.");

        for (auto point : spawnPoints)
        {
            FVector location = point.GetActorLocation();
            float dist = location.Dist2D(playerLocation);
            float zDiff = FMath::Abs(location.Z - playerLocation.Z);
            if ( 1000.0f < dist && dist < 6000.0f && zDiff < 400.0f)
            {
                FHitResult hitResult;
                TArray<AActor> ignore;
                bool hit = System::LineTraceSingle(
                        playerLocation,
                        location,
                        ETraceTypeQuery::Walls,
                        false,
                        ignore,
                        EDrawDebugTrace::None,
                        hitResult,
                        true
                    );

                if (hit)
                {
                    //Print("Spawned.");

                    FVector loc;
                    UNavigationSystemV1::ProjectPointToNavigation(point.GetActorLocation(), loc, recastNavMesh, nullptr);
                    AGuard newGuard = Cast<AGuard>(SpawnActor(spawnClass, loc));
                    if (newGuard == nullptr)
                    {
                        //Print("Failed to actually spawn.");
                        return;
                    }

                    Telegram msg = Telegram(playerPawn, newGuard, messegeEnum::Attention, 0.0, "");
                    messageDispatcher.dispatchMessage(msg);

                    return;                                
                }
            }
        }
    }

    void SetIsPlayerSeen(bool seen)
    {
        isPlayerSeen = seen;
    }
}