class UOutlineComponent : UActorComponent
{
    APawn playerPawn;
    UCameraComponent cameraComponent;
    FHitResult hitResult;
    TArray<AActor> actorsToIgnore;
    TArray<UStaticMeshComponent> meshes;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        playerPawn = Gameplay::GetPlayerPawn(0);
        cameraComponent = Cast<UCameraComponent>(playerPawn.GetComponent(UCameraComponent::StaticClass()));
        GetOwner().GetComponentsByClass(UStaticMeshComponent::StaticClass(), meshes);
        for(int i = 0; i < meshes.Num(); i++)
        {
            meshes[i].SetRenderCustomDepth(false);
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        // check if player is within range
        if(playerPawn == nullptr)
            return;

        if(playerPawn.ActorLocation.DistXY(GetOwner().ActorLocation) <= 300)
        {
            // use player's camera forward vector to determine if it's hitting this actor or not
            System::LineTraceSingle(cameraComponent.WorldLocation, cameraComponent.WorldLocation + cameraComponent.ForwardVector * 300.f,
            ETraceTypeQuery::Collectables, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, false);

            // if forward vector hits this actor, turn on outlines (CustomDepth pass)
            if(hitResult.Actor != nullptr)
            {
                if(hitResult.Actor == GetOwner())
                {
                    for(int i = 0; i < meshes.Num(); i++)
                    {
                        meshes[i].SetRenderCustomDepth(true);
                    }
                    return;
                }
            }
            
            // if player's in range but not looking at this actor
            for(int i = 0; i < meshes.Num(); i++)
            {
                meshes[i].SetRenderCustomDepth(false);
            }
        }
    }
}