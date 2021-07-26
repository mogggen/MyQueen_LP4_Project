import messagingSystem;
import StateMachineClass;
import GuardDetectPlayerComponent;
import PatrolPoint;
import PurpleQueen;
import void ChangeToReturnToPostState(AGuard guard) from "GuardStates.ReturnToPostState";
import void ChangeToDeadState(AGuard guard) from "GuardStates.DeadState";
import void ChangeToOpenDoorState(AGuard guard) from "GuardStates.OpenDoorState";
import bool ChangeToAvoidDoorState(AGuard guard) from "GuardStates.AvoidDoorState";


// Hello!! Can anyone hear me!?!?!?!

class AGuard : AMessageCharacter
{
    UPROPERTY()
    TSubclassOf<AActor> cubeActor;

    UPROPERTY()
    float health;

    UPROPERTY()
    const float maxHealth = 100;

    //Sound
    UPROPERTY(DefaultComponent)
    UAudioComponent screamingComponent;
    UPROPERTY(DefaultComponent)
    UAudioComponent movingSoundComponent;

    UPROPERTY(EditAnywhere, Category = "Sounds")
    TArray<USoundCue> screamingAtPlayerSounds;
    UPROPERTY(EditAnywhere, Category = "Sounds")
    TArray<USoundCue> hurtScreamSounds;
    UPROPERTY(EditAnywhere, Category = "Sounds")
    USoundCue walkingSound;
    UPROPERTY(EditAnywhere, Category = "Sounds")
    USoundCue runingSound;
    
    stateMachine fsm;

    AMessageDispatcher messageDispatcher;

    FVector goalPos;
     
    /// Patrolling ---------------------
    int currentPatrollPoint = 0;
    UPROPERTY(EditAnywhere, Category = "Patrol")
    TArray<APatrolPoint> patrollPoints; 
    // Determines how far from a patrol point the guard will accelerate to and from a halt.
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float distanceToStartTurning = 180.f;
    // Seconds before turning and walking to next patrol point
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float timeToStandStill = 3.f;
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float rotationSpeed = 1.5f;

    /// GoToInvestigate ---------------------
    FVector lastHeardPosition;

    UPROPERTY(DefaultComponent)
    UDetectPlayer detectPlayerComponent;

    /// Fighting ---------------------
    UPROPERTY(EditAnywhere, Category = "Fight")
    const float attackRange = 300.0f;
    UPROPERTY(EditAnywhere, Category = "Fight")
    const float attackDamage = 10.0f;
    UPROPERTY(EditAnywhere, Category = "Fight")
    const float attackCooldown = 1.0f;
    UPROPERTY(EditAnywhere, Category = "Fight")
    const float attackArc = 30.0f;
    UPROPERTY(EditAnywhere, Category = "Fight")
    float attackRotationSpeed = 170.0f;

    float currentAttackCooldown = 0;

    UPROPERTY(EditAnywhere)
    const float investigativRadius;

    /// Chasing ----------------------
    FVector playersLastKnownLocation;

    /// Standing Guard ---------------
    FVector startLocation;
    FRotator startRotation;

    /// Speed
    UPROPERTY(EditAnywhere, Category = "Movment")
    float runningspeed = 600;
    UPROPERTY(EditAnywhere, Category = "Movment")
    float walkingSpeed = 120;
    UPROPERTY(EditAnywhere, Category = "Movment")
    float investigatingSpeed = 160;

    /// Animations -------------------
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isLookingAround;
    default isLookingAround = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurning;
    default isTurning = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isRunning;
    default isRunning = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isAttacking;
    default isAttacking = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isDying;
    default isDying = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isIdle;
    default isIdle = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurningLeft;
    default isTurningLeft = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurningRight;
    default isTurningRight = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isCautious;
    default isCautious = false;
    UPROPERTY(EditAnywhere, Category = "Animation")
    bool isBored;
    default isBored = false;
    UPROPERTY(EditAnywhere, Category = "Animation")
    FVector damageColor;
    default damageColor = FVector(0.03, 0, 0);
    UPROPERTY(EditAnywhere, Category = "Animation")
    float minTimeUntilTap = 6;
    UPROPERTY(EditAnywhere, Category = "Animation")
    float maxTimeUntiltap = 12;
    UFUNCTION()
    void startFootTap()
    {
        fsm.startTappingFoot(this);
    }
    UFUNCTION()
    void endFootTap()
    {
        fsm.endTappingFoot(this);
    }

    bool swordEnabled = false;
    bool hasAttackedPlayer = false;

    // health indicator --------------
    UPROPERTY()
    bool healthBarVisible;
    default healthBarVisible = false;

    AGuard()
    {
        fsm = stateMachine(this);
    }



    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        health = maxHealth;

        CharacterMovement.MaxWalkSpeed = walkingSpeed;

        AAIController aicontroller = Cast<AAIController>(this.Controller);
        aicontroller.ReceiveMoveCompleted.AddUFunction(this, n"MoveCompleted");

        goalPos = this.GetActorLocation();
        ChangeToReturnToPostState(this);


        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "No message dispatcher found.");
        messageDispatcher = messageDispatchers[0];

        startLocation = GetActorLocation();
        startRotation = GetActorRotation();

        Mesh.SetVectorParameterValueOnMaterials(n"colorParameter", damageColor);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        fsm.Update(DeltaSeconds);

        if (this.currentAttackCooldown > 0)
            this.currentAttackCooldown -= DeltaSeconds;
    }

    UFUNCTION(BlueprintEvent)
    void isHurt() {}
    
    void handleMessage(Telegram telegram) 
    {
        if (telegram.msg == messegeEnum::Damage)
        {
            AGuard guard = Cast<AGuard>(telegram.reciver);
            if (guard == nullptr) return;
            if (guard.health <= 0.f) return;
            
            int x = FMath::RandRange(0,guard.hurtScreamSounds.Num() - 1);
            guard.screamingComponent.SetSound(guard.hurtScreamSounds[x]);
            guard.screamingComponent.Play();

            isHurt();
            float newHealth = health - telegram.extraFloat;
            if (newHealth <= 0 && health > 0) {
                Die(30);
                health = newHealth;
                return;
            }
            health = newHealth;
            healthBarVisible = true;

            fsm.m_currentState.Hurt(this);
		}

        // face the right way when dying
        if (telegram.msg == messegeEnum::SNEAK_KILL)
        {
            ActorRotation = telegram.sender.ActorRotation;
            ActorLocation = telegram.sender.ActorLocation + telegram.sender.ActorForwardVector * 100.f;
            Die(0);
            health -= maxHealth;
        }

        // Suspicious sound
        if(telegram.msg == messegeEnum::SuspiciousSound) 
        {
            //Print("Sound was heard by guard.");
            // line trace to check if sound source is behind wall
            TArray<AActor> actorsToIgnore;
            TArray<FHitResult> hitResults;
            System::LineTraceMulti(ActorLocation, telegram.sender.ActorLocation, ETraceTypeQuery::Walls, false, actorsToIgnore,
                EDrawDebugTrace::None, hitResults, true, FLinearColor::Green, FLinearColor::Red);
            
            if(hitResults.Num() > 0)
            {
                // if sound is behind wall brush, don't handle message
                if(hitResults[0].Actor == nullptr) // nullptr means it's a brush
                    return;
            }

            // if it's not a brush, handle message
            fsm.HeardSound(this, telegram.sender.ActorLocation);
        }

        if (telegram.msg == messegeEnum::Attention)
        {
            //Print("Guard was alerted by another guard.");
            fsm.HeardSound(this, telegram.sender.ActorLocation);
        }

    }

    
    // Must be used in update/execute/tick. Returns true when rotation is done.
    bool turn(FRotator newRotation, float DeltaSeconds)
    {
        // if yaw is negative, convert it to positive (should become a value between 180 and 359)
        float newRotationYaw = newRotation.Yaw;
        if(newRotation.Yaw < 0)
            newRotationYaw = 360 + newRotation.Yaw;
        float actorYaw = ActorRotation.Yaw;
        if(ActorRotation.Yaw < 0)
            actorYaw = 360 + ActorRotation.Yaw;

        // if true, turn right. If false, turn left.
        if(((actorYaw - newRotationYaw + 360) % 360) > 180) {
            isTurningRight = true;
            ActorRotation += FRotator(0, rotationSpeed, 0); // right
        }
        else{
            isTurningLeft = true;
            ActorRotation -= FRotator(0, rotationSpeed, 0); // left
        }

        // if difference in rotation is < 1 degrees, return true ❤️
        if(ActorRotation.Equals(newRotation, 1))
            return true;
        else
            return false;
    }

    // Must be used in update/execute/tick. Returns true when rotation is done.
    bool turn(AActor destination, float DeltaSeconds)
    {
        // make it actually turn towards the destination
        FVector newLocation = destination.ActorLocation - ActorLocation;
        FRotator newRotation = FRotator(0, newLocation.Rotation().Yaw, 0);

        return turn(newRotation, DeltaSeconds);
    }

    UFUNCTION()
    void destroyGuard()
    {
        DestroyActor();
    }

    void Die(float increaseValue)
    {
        AActor playerPawn = Gameplay::GetPlayerPawn(0);
        DisablePawnCollision();
        
        AAIController controller = Cast<AAIController>(this.Controller);
        controller.StopMovement();
        
        ChangeToDeadState(this);
        
        ensure(Cast<AMessageCharacter>(this) != nullptr);
        ensure(Cast<AMessageCharacter>(playerPawn) != nullptr);
        ensure(messageDispatcher != nullptr);

        Telegram telegram = Telegram(Cast<AMessageCharacter>(this), Cast<AMessageCharacter>(playerPawn), messegeEnum::hasDied, 0, "");
        telegram.extraFloat = increaseValue;
        messageDispatcher.dispatchMessage(telegram);

        auto msg = Telegram(Cast<AMessageCharacter>(this), Cast<AMessageCharacter>(playerPawn), messegeEnum::hasSpottedPlayer, 0, "");
        msg.extraBool = false;
        messageDispatcher.dispatchMessage(msg);
        
        // TODO(Magnus) maybe call exit() on current state instead of this.
        if(!detectPlayerComponent.canSeePlayer) 
        {
            messageDispatcher.dispatchMessage(Telegram(this, Cast<AMessageCharacter>(Gameplay::GetPlayerPawn(0)), messegeEnum::isChasingPlayer, 0, "false"));
        }

        detectPlayerComponent.DestroyComponent(detectPlayerComponent);

        // start destroy timer
        System::SetTimer(this, n"destroyGuard", 20.f, false);
    }


    UFUNCTION()
    void MoveCompleted(FAIRequestID id, EPathFollowingResult result)
    {
        this.movingSoundComponent.Stop();
        fsm.MoveComplete(this, result);
        //Print("MoveComplete: "+result);

        //if (result != EPathFollowingResult::Success)
        //    Print("Could not follow path");
    }
    UFUNCTION()
    void moveToLocation(FVector pos)
    {
        if(isRunning)
            movingSoundComponent.SetSound(runingSound);
        else
            movingSoundComponent.SetSound(walkingSound);

        movingSoundComponent.Play();

        AAIController controller = Cast<AAIController>(this.Controller);
        controller.MoveToLocation(pos, 50.0f, false, true, true, false, nullptr, true);
    }
    UFUNCTION()
    void moveToActor()
    {
        if(isRunning)
        {
            movingSoundComponent.SetSound(runingSound);
        }
        else
        {
            movingSoundComponent.SetSound(walkingSound);
        }

        movingSoundComponent.Play();

        AAIController controller = Cast<AAIController>(this.Controller);
        controller.MoveToActor(Gameplay::GetPlayerPawn(0), 50.0f, true, true, false, nullptr, true);
    }

    UFUNCTION()
    void EnableSword()
    {
        swordEnabled = true;
    }
    UFUNCTION()
    void DisableSword()
    {
        swordEnabled = false;
        hasAttackedPlayer = false;
    }

    UFUNCTION()
    void DamagedPlayer(AActor player)
    {
        if (!swordEnabled || hasAttackedPlayer)
            return;

        AMessageCharacter playerMC = Cast<AMessageCharacter>(player);

        if (playerMC == nullptr)
            return;

        if (Cast<AGuard>(player) != nullptr)
            return;

        if (Cast<APurpuleQueen>(player) != nullptr)
            return;

        auto msg = Telegram(Cast<AMessageCharacter>(this), playerMC, messegeEnum::Damage, 0, "");
        msg.extraFloat = attackDamage;
        messageDispatcher.dispatchMessage(msg);

        hasAttackedPlayer = true;
    }

    UFUNCTION(BlueprintCallable)
    void startOpeningDoor()
    {
        ChangeToOpenDoorState(this);
    }
    UFUNCTION(BlueprintCallable)
    bool avoidDoor()
    {
        return ChangeToAvoidDoorState(this);
    }
    UFUNCTION(BlueprintCallable)
    void ChangeToPreviousState()
    {
        fsm.GoToPreviousState(this);
    }

    UFUNCTION(BlueprintEvent)
    void DisablePawnCollision() {}

    UFUNCTION(BlueprintEvent)
    void ShowHeardSomethingIcon() {}
}