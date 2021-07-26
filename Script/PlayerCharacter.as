import messagingSystem;
import stone;
import InsanitySystemComponent;
import SpawnGuardComponent;
import StateMachineClass;
import SoundComponent;
import Telegram;
import VoiceLineSystem;
import VoiceInsanety;
import Letter;
import StoonePile;

class APlayerCharacter : AMessageCharacter
{
    // An input component that we will set up to handle input from the player 
    // that is possessing this pawn.

    UPROPERTY(EditAnywhere)
    float fadeDuration = .9f;

    UPROPERTY(DefaultComponent)
    UInputComponent ScriptInputComponent;
    UPROPERTY()
    UCameraComponent cameraComponent;

    UPROPERTY(DefaultComponent)
    UInsanitySystem insanitySystem;
    UPROPERTY(DefaultComponent)
    USpawnGuardComponent spawnGuardComponent;

    UPROPERTY(EditAnywhere)
    UAnimationAsset StoneTossAnim;

    TArray<AActor> guardsChasingPlayer;
    UPROPERTY(EditAnywhere)
    int nGuardsSeeingPlayer;

    UPROPERTY(EditAnywhere)
    TSubclassOf<AActor> stoneClass;

    UPROPERTY(DefaultComponent)
    VoiceInsanety VoiceInsanetyLines;

    UPROPERTY(DefaultComponent)
    UVoiceLineSystem voiceSystemComponent;
    //audio component
    UPROPERTY(DefaultComponent)
    UAudioComponent ambiantSoundComponent;
    UPROPERTY(DefaultComponent)
    UAudioComponent backgroundMusicComponent;
    UPROPERTY(DefaultComponent)
    UComponentSound soundEffectComponent;
    UPROPERTY(DefaultComponent)
    UAudioComponent queensVoiceComponent;

    UPROPERTY(DefaultComponent)
    UAudioComponent movingSoundComponent;
    UPROPERTY(EditAnywhere)
    USoundCue walkingCue;
    UPROPERTY(EditAnywhere)
    USoundCue runningCue;
    UPROPERTY(EditAnywhere)
    USoundCue trippingCue;

    AMessageDispatcher dispatcher;

    AGuard guard;

    float dt;
    UPROPERTY()
    int floor = 0;

    float dot;
    FVector prevVelocity;
    float prevDot;

    //RayCast
    FHitResult hitResult;
    TArray<AActor> actorsToIgnore;
    FVector startPos;

    UPROPERTY(EditAnywhere)
    bool lockControls = false;

    float currentMoveFactor = .5f;

    float damageToDeal = 0.f;
    AActor actorToDamage = nullptr;

    //UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float desiredMoveFactor = .5f;

    float currentStance = 1.f;

    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float desiredStance = 1.f;
    bool performingSneakAttack = false;

    float currentArm = 1.f;
    float desiredArm = 1.f;

    FVector currentLookAt;
    FVector desiredLookAt;

    float currentLoudness = 0.f;

    float OutOfCombatCooldown = 0.f;
    UPROPERTY()
    float currentAttackCooldown = 0.f;
    float currentThrowingCooldown = 0.f;
    float dispatchCooldown = 0.f;
    float berserkCooldown = 0.f;
    float coolDownUntilNextBeserk = 0.f;

    UPROPERTY(EditAnywhere)
    USoundCue backGroundMusic;

    UPROPERTY(EditAnywhere, Category = "Settings")
    bool toggleChrouch = true;
    UPROPERTY(EditAnywhere, Category = "Stance")
    bool jumping;

    UPROPERTY(EditAnywhere, Category = "Inventory")
    int heldStones = 3;

    UPROPERTY(EditAnywhere, Category = "Inventory")
    int maxStones = 100; // Regenarate stones over time instead of

    //player stats
    UPROPERTY(EditAnywhere, Category = "Health")
    float health = 100.f;
    UPROPERTY(EditAnywhere, Category = "Health")
    const float maxHealth = 100.f;
    UPROPERTY(EditAnywhere, Category = "Health")
    const float healthRegain = 50.f;
    UPROPERTY(EditAnywhere, Category = "Health")
    const float healthRegainDelay = 5.f;


    UPROPERTY(EditAnywhere, Category = "Damage")
    const float attackRange = 300.f;
    UPROPERTY(EditAnywhere, Category = "Damage")
    const float attackSpeed = 0.9;
    UPROPERTY(EditAnywhere, Category = "Damage")
    const float attackDamage = 30.f;

    UPROPERTY(EditAnywhere, Category = "Berserk")
    const float randomKillChance = 0.2f;
    UPROPERTY(EditAnywhere, Category = "Berserk")
    float berserkTurnRate = 0.8f;
    UPROPERTY(EditAnywhere, Category = "Berserk")
    float berserkMaxCooldown = 3.0f;
    bool inBeserkMode = false;

    // A factor to scale all the other movespeeds by.
    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float moveSpeedScalar = .35f; 

    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float walkFactor = .5f;
    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float paranoidFactor = .4f;
    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float sneakingFactor = .55f;
    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float runningFactor = 1.3f;
    UPROPERTY(EditAnywhere, Category = "MoveSpeed")
    float fatiguedFactor = .1f;

    UPROPERTY(EditAnywhere, Category = "Stamina")
    const float capacity = 10.f;
    UPROPERTY(EditAnywhere, Category = "Stamina")
    float stamina = 10.f;
    UPROPERTY(EditAnywhere, Category = "Stamina")
    const float fatigued = 0.f;
    UPROPERTY(EditAnywhere, Category = "Stamina")
    const float regainingStamina = 1.5f;
    UPROPERTY(EditAnywhere, Category = "Stamina")
    const float losingStamina = 3.f;

    // A factor to scale all the other sounds by.
    UPROPERTY(EditAnywhere, Category = "Loudness")
    float loudnessScalar = 1.f;
    UPROPERTY(EditAnywhere, Category = "Loudness")
    float runSteps = 3000.f;
    UPROPERTY(EditAnywhere, Category = "Loudness")
    float walkSteps = 900.f;
    UPROPERTY(EditAnywhere, Category = "Loudness")
    float sneakSteps = 0.f;

    UPROPERTY(EditAnywhere, Category = "Stone")
    float timeSpentInAir = 1.f;
    UPROPERTY(EditAnywhere, Category = "Stone")
    float throwingStrength = 4000.f;
    UPROPERTY(EditAnywhere, Category = "Stone")
    float throwingSpeed = 1.f;

    FVector v;

    UPROPERTY(EditAnywhere, Category = "Stance")
    bool LShift;

    UPROPERTY(EditAnywhere, Category = "Stance")
    bool LCtrl;
    
    UPROPERTY(EditAnywhere, Category = "Movment")
    int forward;
    UPROPERTY(EditAnywhere, Category = "Movment")
    int right;
    
    float height;

    FTimerHandle tripCameraShakeDelay;

    // camera lean function ----------------
    UPROPERTY()
    bool isLeaning = false;
    UPROPERTY()
    FVector originCameraLocation;
    UPROPERTY()
    FVector originPlayerLocation;
    
    

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // float maxMoveSpeed = 2400.f;
        // Print(""+walkFactor * moveSpeedScalar* maxMoveSpeed);
        // Print(""+paranoidFactor * maxMoveSpeed);
        // Print(""+sneakingFactor * maxMoveSpeed);
        // Print(""+runningFactor * maxMoveSpeed);
        // Print(""+fatiguedFactor * maxMoveSpeed);
        
        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);

        backgroundMusicComponent.SetSound(backGroundMusic);
        backgroundMusicComponent.Play();

        if(ScriptInputComponent == nullptr)
        {ScriptInputComponent = UInputComponent(this);}
        
        ensure(messageDispatchers.Num() > 0, "PlayerCharacter.as, BeginPlay(): No messagesDispatcher found!");
        dispatcher = messageDispatchers[0];
        
        movingSoundComponent.SetSound(walkingCue);

        ScriptInputComponent.BindAxis(n"LookUp", FInputAxisHandlerDynamicSignature(this, n"OnLookUpAxisChanged"));
        ScriptInputComponent.BindAxis(n"LookRight", FInputAxisHandlerDynamicSignature(this, n"OnLookRightAxisChanged"));
        
        ScriptInputComponent.BindAxis(n"MoveForward", FInputAxisHandlerDynamicSignature(this, n"MoveForwardAxisChanged"));
        ScriptInputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"MoveRightAxisChanged"));

        ScriptInputComponent.BindKey(EKeys::F, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnInteractKeyPressed"));

        ScriptInputComponent.BindKey(EKeys::Q, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnLeanLeftKeyPressed"));
        ScriptInputComponent.BindKey(EKeys::Q, EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnLeanLeftKeyReleased"));
        ScriptInputComponent.BindKey(EKeys::E, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnLeanRightKeyPressed"));
        ScriptInputComponent.BindKey(EKeys::E, EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnLeanRightKeyReleased"));

        //Jumping key binds
        ScriptInputComponent.BindKey(EKeys::SpaceBar, EInputEvent::IE_Pressed,FInputActionHandlerDynamicSignature(this, n"OnSpaceBarPressed"));


        //Sprinting key binding
        ScriptInputComponent.BindKey(EKeys::LeftShift, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnLShiftPressed"));
        ScriptInputComponent.BindKey(EKeys::LeftShift, EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnLShiftReleased"));

        //Chroucing key binding
        ScriptInputComponent.BindKey(EKeys::LeftControl, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnLCtrlPressed"));
        ScriptInputComponent.BindKey(EKeys::LeftControl, EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnLCtrlReleased"));

        ScriptInputComponent.BindKey(EKeys::LeftMouseButton, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnLMousePressed"));

        ScriptInputComponent.BindKey(EKeys::RightMouseButton, EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnRMousePressed"));
        
        // Change insanity (for debugging)
        //ScriptInputComponent.BindKey(EKeys::One, EInputEvent::IE_Pressed,FInputActionHandlerDynamicSignature(this,n"IncreaseInsanity"));
        //ScriptInputComponent.BindKey(EKeys::Two, EInputEvent::IE_Released,FInputActionHandlerDynamicSignature(this,n"DecreaseInsanity"));

        FString level = GetCurrentWorld().GetName();
        if (level == "Basement")
        {
            floor = 0;
            
        }
        else if (level == "FirstFloor")
        {
            floor = 1;
        }
        else if (level == "FinalFloor")
        {
            floor = 2;
        }
        else if (level == "MainMenu")
        {
            floor = 5;
        }
        else
        {
            //Print("PlayerCharacter.as, BeginPlay(): level name not found!");
        }

        lockControls = false;

        VoiceInsanetyLines.switchFloor(floor);

        originCameraLocation = cameraComponent.RelativeLocation;
        originPlayerLocation = Cast<USkeletalMeshComponent>(GetComponent(USkeletalMeshComponent::StaticClass(), n"MainCharacter")).RelativeLocation;

        //needs to be last(inizaliatiar saker i blue print)
        onStartBp();
    }

    void handleMessage(Telegram telegram)
    {
        switch(telegram.msg)
        {
            case messegeEnum::Damage:
            {
                tintScreenDamege();
                health -= telegram.extraFloat;
                if (health <= 0)
                {
                    lockControls = true;
                    playerDeath();
                    return;
                }
                
                OutOfCombatCooldown = healthRegainDelay;
                break;
            }

            case messegeEnum::hasDied:
            {
                insanitySystem.changeInsanityValue(telegram.extraFloat);
                if (telegram.sender == guard) guard = nullptr;
                guardsChasingPlayer.Remove(telegram.sender);
                // if empty, start timer with a delay
                if(guardsChasingPlayer.Num() == 0) {
                    //insanitySystem.startDecreaseTimer();
                }
                break;
            }

            case messegeEnum::isChasingPlayer:
            {
                if(telegram.extraInfo == "true") {
                    guardsChasingPlayer.AddUnique(telegram.sender);
                    // stop timer here since a guard sees you
                    //System::PauseTimerHandle(insanitySystem.decreaseTimerHandle);
                }
                else if(telegram.extraInfo == "false"){
                    guardsChasingPlayer.Remove(telegram.sender);
                    // if empty, start timer with a delay
                    if(guardsChasingPlayer.Num() == 0) {
                        //insanitySystem.startDecreaseTimer();
                    }
                }
                break;
            }

            case messegeEnum::hasSpottedPlayer:
            {
                if (telegram.extraBool)
                    nGuardsSeeingPlayer += 1;
                else
                    nGuardsSeeingPlayer -= 1;

                if (nGuardsSeeingPlayer < 0)
                    nGuardsSeeingPlayer = 0;

                spawnGuardComponent.SetIsPlayerSeen(nGuardsSeeingPlayer > 0);
                if(nGuardsSeeingPlayer <= 0)
                    insanitySystem.startDecreaseTimer();
                else
                    System::PauseTimerHandle(insanitySystem.decreaseTimerHandle);
                    
                break;
            }

            case messegeEnum::VOICELINE:
            {
                voiceSystemComponent.messageHandeling(telegram);
                break;
            }
        }

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        dt = DeltaSeconds;
        
        //Health regain out of combat
        if (OutOfCombatCooldown > 0) OutOfCombatCooldown -= DeltaSeconds;
        else if (health < maxHealth) health += DeltaSeconds * healthRegain;
        else if (health >= maxHealth) health = maxHealth;
        
        currentAttackCooldown -= currentAttackCooldown > 0.f ? DeltaSeconds : 0.f;
        currentThrowingCooldown -= currentThrowingCooldown > 0.f ? DeltaSeconds : 0.f;
        berserkCooldown -= berserkCooldown > 0.f ? dt : 0.f;
        coolDownUntilNextBeserk -= coolDownUntilNextBeserk > 0.f ? dt : 0.f;

        //don't spam messages
        if (dispatchCooldown <= 0)
        {
            dispatcher.dispatchSoundMessage(Telegram(
            Cast<AMessageCharacter>(this),
            Cast<AMessageCharacter>(nullptr),
            messegeEnum::SuspiciousSound,
            0,
            ""
            ), currentLoudness);

            dispatchCooldown = 0.75f;
        }
        else dispatchCooldown -= DeltaSeconds;
        if(jumping && !LCtrl)
        {
            Jump();
        }

        // activate trip timer if crouching and moving on the ground
        if(LCtrl && MovementComponent.IsMovingOnGround() && (forward != 0 || right != 0)) {
            if(!System::IsTimerActiveHandle(insanitySystem.tripTimerHandle)) {
                float randomDelay = FMath::RandRange(insanitySystem.minTimeBeforeTrip, insanitySystem.maxTimeBeforeTrip);
                insanitySystem.tripTimerHandle = System::SetTimer(insanitySystem, n"trip", randomDelay, false);
            }
        }
        else {
            System::ClearAndInvalidateTimerHandle(insanitySystem.tripTimerHandle);
        }
        
        if (coolDownUntilNextBeserk <= 0.f &&
            insanitySystem.insanityValue >= insanitySystem.toBerserkValue &&
            !lockControls)
        {
            if (randomKillChance > FMath::RandRange(0.f, 1.f))
                ChooseRandomGuardToAttack();
            else
                coolDownUntilNextBeserk = 5.f;
        }

        if(inBeserkMode)
            RandomlyAttackGuard(DeltaSeconds);
            
        performStance(DeltaSeconds);
        
        // stamina
        if (stamina <= capacity && !LShift)
            stamina += regainingStamina * DeltaSeconds;
    }

    UFUNCTION()
    void OnLookRightAxisChanged(float axisValue)
    {
        if (!lockControls)
        {
            AddControllerYawInput(axisValue);
        }
    }

    UFUNCTION()
    void OnLookUpAxisChanged(float axisValue)
    {
        if (!lockControls || isLeaning)
        {
            FRotator delta;
            delta.Pitch = axisValue * 2.f;
        
            if (cameraComponent.GetRelativeRotation().Pitch + delta.Pitch < 85 && cameraComponent.GetRelativeRotation().Pitch + delta.Pitch > -85)
                cameraComponent.AddLocalRotation(delta);
        }
    }

    //sprinting
    UFUNCTION()
    void OnLShiftPressed(FKey key)
    {
        if (!lockControls)
            LShift = true;
    }
    UFUNCTION()
    void OnLShiftReleased(FKey key)
    {
        LShift = false;
    }


    //chrouching
    UFUNCTION()
    void OnLCtrlPressed(FKey key)
    {
        if (!lockControls && MovementComponent.IsMovingOnGround())
            LCtrl = toggleChrouch ? !LCtrl : true;
    }
    UFUNCTION()
    void OnLCtrlReleased(FKey key)
    {
        if (!toggleChrouch && MovementComponent.IsMovingOnGround())
            LCtrl = false;
    }

    //jumping
    UFUNCTION()
    void OnSpaceBarPressed(FKey key)
    {
        if (!lockControls && !LCtrl)
            Jump();
    }

    UFUNCTION(BlueprintEvent)
    void MoveForwardAxisChanged(float axisValue)
    {
        if (!lockControls)
        {
            forward = axisValue;
            if (LShift && !LCtrl && axisValue > 0 && stamina > 0 && insanitySystem.insanityValue >= insanitySystem.toParanoidValue)
            {
                desiredMoveFactor = runningFactor;
                stamina -= losingStamina * dt;
                getStance();
            }
            else
            {
                desiredMoveFactor = walkFactor;
                if (stamina <= fatigued)
                {
                    desiredMoveFactor = fatiguedFactor;
                }
            }

            if (LCtrl)
            {
                desiredMoveFactor = sneakingFactor;
                if (insanitySystem.insanityValue < insanitySystem.toGoingParanoidValue)
                {
                    desiredMoveFactor = paranoidFactor;
                }
                getStance();
            }

            if (!LCtrl && !LShift)
            {
                desiredMoveFactor = walkFactor;
                if (stamina < fatigued)
                    desiredMoveFactor = fatiguedFactor;
                getStance();
            }
        }
        else
        {
            forward = right = 0;
        }
        v = GetActorForwardVector() * forward + GetActorRightVector() * right;
        v.Normalize();
        
        if (dt != 0)
            currentMoveFactor += (desiredMoveFactor * moveSpeedScalar - currentMoveFactor) / (dt * 700.f);

        AddMovementInput(v, currentMoveFactor);
    }

    UFUNCTION(BlueprintEvent)
    void MoveRightAxisChanged(float axisValue)
    {
        if (desiredMoveFactor == runningFactor)
        {
            currentLoudness = runSteps * loudnessScalar;
            if (movingSoundComponent.Sound != runningCue || !movingSoundComponent.IsPlaying())
            {
                movingSoundComponent.Sound = runningCue;
                movingSoundComponent.Play();
            }
        }
        else if ((desiredMoveFactor == walkFactor || desiredMoveFactor == fatiguedFactor) && (forward != 0 || right != 0))
        {
            currentLoudness = walkSteps * loudnessScalar;
            if (movingSoundComponent.Sound != walkingCue || !movingSoundComponent.IsPlaying())
            {
                movingSoundComponent.Sound = walkingCue;
                movingSoundComponent.Play();
            }
        }
        else if (desiredMoveFactor == sneakingFactor || desiredMoveFactor == paranoidFactor)
        {
            currentLoudness = sneakSteps * loudnessScalar;
            movingSoundComponent.Stop();
        }
        else if (forward == 0 && right == 0)
        {
            currentLoudness = 0;
            movingSoundComponent.Stop();
        }

        if (!lockControls)
            right = axisValue;        
        
        v.Normalize();
        v *= dt * currentMoveFactor;
        
        AddMovementInput(v, currentMoveFactor);
    }

    UFUNCTION()
    void OnInteractKeyPressed(FKey key)
    {
        System::LineTraceSingle(cameraComponent.WorldLocation, cameraComponent.WorldLocation + cameraComponent.ForwardVector * 300.f,
        ETraceTypeQuery::Collectables, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, true);
        
        ALetter letter = Cast<ALetter>(hitResult.Actor);
        AStoonePile stoonePile = Cast<AStoonePile>(hitResult.Actor);

        if (letter != nullptr)
        {
            letter.openLetterEvent();
            letter.readLetterEvent();
            openLetter(letter.letterIndex);
        }
        else if (stoonePile != nullptr)
        {
            if(pickupStoonePile(stoonePile))
                stoonePile.pickedUp();
        }

    }

    // leaning ----------------------------------------------------
    // check once when a lean key is pressed
    bool canLean(FString direction)
    {
        TArray<AActor> ignoreList;
        TArray<FHitResult> hitResults;
        float traceLength = 80;
        FVector traceEnd = cameraComponent.WorldLocation;
        if(direction == "left")
        {
            traceEnd.Y += -cameraComponent.RightVector.Y * traceLength;
            traceEnd.X += -cameraComponent.RightVector.X * traceLength;
        }
        else // right
        {
            traceEnd.Y += cameraComponent.RightVector.Y * traceLength;
            traceEnd.X += cameraComponent.RightVector.X * traceLength;
        }

        System::LineTraceMulti(cameraComponent.WorldLocation, traceEnd, ETraceTypeQuery::Visibility, false, ignoreList,
            EDrawDebugTrace::None, hitResults, true, FLinearColor::Green, FLinearColor::Red);
        
        if(hitResults.Num() > 0)
        {
            // if hitResult is something visible, return false, can't lean
            return false;
        }
        return true; // no wall was hit, can lean
        
    }
    UFUNCTION(BlueprintEvent)
    void LeftBtnPressed() {}
    UFUNCTION(BlueprintEvent)
    void LeftBtnReleased() {}
    UFUNCTION(BlueprintEvent)
    void RightBtnPressed() {}
    UFUNCTION(BlueprintEvent)
    void RightBtnReleased() {}
    UFUNCTION()
    void OnLeanLeftKeyPressed(FKey key)
    {
        // return if jumping or if something visible is in the way
        if(!MovementComponent.IsMovingOnGround() || !canLean("left"))
            return;

        // disable movement
        // TODO: keep camera movement on
        forward = 0;
        right = 0;
        lockControls = true;

        LeftBtnPressed();
    }
    UFUNCTION()
    void OnLeanLeftKeyReleased(FKey key)
    {
        lockControls = false;

        LeftBtnReleased();
    }
    UFUNCTION()
    void OnLeanRightKeyPressed(FKey key)
    {
        // return if jumping or if something visible is in the way
        if(!MovementComponent.IsMovingOnGround() || !canLean("right"))
            return;

        // disable movement
        // TODO: keep camera movement on
        forward = 0;
        right = 0;
        lockControls = true;

        RightBtnPressed();
    }
    UFUNCTION()
    void OnLeanRightKeyReleased(FKey key)
    {
        lockControls = false;

        RightBtnReleased();
    }

    UFUNCTION(BlueprintEvent)
    void openLetter(int letter)
    {
        
    }

    UFUNCTION()
    void OnLMousePressed(FKey key)
    {
        if ((currentAttackCooldown > 0 || currentThrowingCooldown > 0) || lockControls)
        {
            return;
        }
        // if insanity is goingBerserk or above, make cooldown less than attackSpeed
        if(insanitySystem.insanityValue >= insanitySystem.toGoingBerserkValue)
            currentAttackCooldown = attackSpeed - 0.4 > 0 ? attackSpeed - 0.4 : 0;
        else
            currentAttackCooldown = attackSpeed;
        
        AGuard target;
        for(int i = -1; i <= 1; i++)
        {
            FRotator aimDirection = cameraComponent.WorldRotation + FRotator(0.f, i * 10.f, 0.f);
            System::LineTraceSingle(cameraComponent.WorldLocation, cameraComponent.GetWorldLocation() + aimDirection.ForwardVector * attackRange,
            ETraceTypeQuery::Guard, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, true, FLinearColor::Blue, FLinearColor::Yellow);
            target = Cast<AGuard>(hitResult.Actor);
            
            if (target != nullptr)
            {
                if (target.ActorRotation.ForwardVector.DotProduct(ActorRotation.ForwardVector) >= 0 && 
                nGuardsSeeingPlayer <= 0 && // https://www.youtube.com/watch?v=2PrSUK1VrKA&t=92s
                !target.isDying &&
                MovementComponent.IsMovingOnGround())
                {
                    currentAttackCooldown = 3.f;
                    performingSneakAttack = true;
                    desiredStance = 1.f;

                    Telegram telegram = Telegram(Cast<AMessageCharacter>(this), Cast<AMessageCharacter>(target), messegeEnum::SNEAK_KILL, 0, "");

                    dispatcher.dispatchMessage(telegram);
                    AssassinateGuard();
                    insanitySystem.changeInsanityValue(-10.f);
                    System::SetTimer(this, n"ResetStance", 0.8f, false);
                    return;
                }
                
            }
        }
        System::SetTimer(this, n"normalAttack", 0.25f, false);
        SwordSwing();
    }
    
    UFUNCTION()
    void OnRMousePressed(FKey key)
    {
        if(!lockControls)
        {
            if(heldStones <= 0) return;
            if (currentThrowingCooldown > 0 || currentAttackCooldown > 0) return;
            heldStones--;
            AStone stone = Cast<AStone>(SpawnActor(stoneClass));

            bool isAHit = System::LineTraceSingle(cameraComponent.WorldLocation, cameraComponent.WorldLocation + cameraComponent.ForwardVector * throwingStrength,
            ETraceTypeQuery::Visibility, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, true, FLinearColor::Blue, FLinearColor::Yellow);
            
            if (!isAHit) return;
            FVector landing = getStoneToss(hitResult.Location, t = timeSpentInAir);
            
            stone.SetActorLocation(cameraComponent.WorldLocation + cameraComponent.ForwardVector * 30.f + cameraComponent.RightVector * 30.f + cameraComponent.UpVector * 15.f, false, hitResult, true);
            
            RockThrow();
            stone.addVelocity(landing);
            
            currentThrowingCooldown = throwingSpeed;
        }
    }

    UFUNCTION()
    void IncreaseInsanity(FKey key)
    {
        insanitySystem.changeInsanityValue(10.0f);
    }
    
    UFUNCTION()
    void DecreaseInsanity(FKey key)
    {
        insanitySystem.changeInsanityValue(-10.0f);
    }

    void ChooseRandomGuardToAttack()
    {
        TArray<AGuard> guards;
        GetAllActorsOfClass(guards);
        FVector playerLocation = GetActorLocation();

        bool foundGuard = false;
        
        TArray<AActor> ignore;
        for (auto g : guards)
        {
            FVector location = g.GetActorLocation();
            float dist = location.Dist2D(playerLocation);
            float zDiff = FMath::Abs(location.Z - playerLocation.Z);
            if (dist < 6000.0f && zDiff < 400.0f)
            {
                bool hit = System::LineTraceSingle(
                        playerLocation,
                        location,
                        ETraceTypeQuery::Camera,
                        false,
                        ignore,
                        EDrawDebugTrace::None,
                        hitResult,
                        true
                    );
                ignore.Add(g);

                // if hitResult is a living guard, stop searching for a guard
                if (Cast<AGuard>(hitResult.Actor) != nullptr)
                {
                    if (!Cast<AGuard>(hitResult.Actor).isDying)
                    {
                        guard = g; 
                        foundGuard = true;
                        break;
                    }
                }
            }
        }

        if (!foundGuard)
        {
            return;
        }
        tintScreenBeserk();
        inBeserkMode = true;
        //LCtrl = false;
        forward = right = 0.f;
        lockControls = true;
        berserkCooldown = berserkMaxCooldown; // cooldown begin when rotation is done.
        desiredMoveFactor = runningFactor * 300;
        currentLoudness = runSteps; //TODO: playsound here as well
        getStance();
    }

    void RandomlyAttackGuard(float dt)
    {
        if (guard == nullptr || berserkCooldown <= 0) // || don't stay in this state for more than berserkMaxCooldown + 1
        {
            EndAttackRandomGuard();
            return;
        }
        

        // OnLookRight
        desiredLookAt = guard.ActorLocation - this.ActorLocation;
        desiredLookAt.Normalize();
        currentLookAt = cameraComponent.ForwardVector;

        float rightDot = cameraComponent.RightVector.DotProduct(desiredLookAt);
        float upDot    = cameraComponent.UpVector.DotProduct(desiredLookAt);
        float currentDot = currentLookAt.DotProduct(desiredLookAt);
        float step = (1.f - currentDot) * dt * 10.0f;

        float deltaAngleCos = FMath::Acos(currentLookAt.DotProduct(desiredLookAt));
        float deltaAngleSin = FMath::Asin(currentLookAt.DotProduct(desiredLookAt));

        if (rightDot >= 0)
            AddControllerYawInput(deltaAngleCos * berserkTurnRate);
        else
            AddControllerYawInput(deltaAngleCos * -berserkTurnRate);

        if (upDot >= 0)
        {
            FRotator delta;
            delta.Pitch = deltaAngleSin * berserkTurnRate;
        
            if (cameraComponent.GetRelativeRotation().Pitch + delta.Pitch < 85 && cameraComponent.GetRelativeRotation().Pitch + delta.Pitch > -85)
                cameraComponent.AddLocalRotation(delta);
        }
        else
        {
            FRotator delta;
            delta.Pitch = deltaAngleSin * -berserkTurnRate;
        
            if (cameraComponent.GetRelativeRotation().Pitch + delta.Pitch < 85 && cameraComponent.GetRelativeRotation().Pitch + delta.Pitch > -85)
                cameraComponent.AddLocalRotation(delta);
        }

        if (deltaAngleCos < .6f )
        { // MoveForwardAxis
            if(cameraComponent.GetWorldLocation().Dist2D(guard.ActorLocation) >= attackRange)
            {
                v = GetActorForwardVector();
                v.Normalize();
                currentMoveFactor += (runningFactor * moveSpeedScalar - currentMoveFactor) / (dt * 700.f);
                AddMovementInput(v, currentMoveFactor);
            }
            getStance();
            if (dispatchCooldown > 0.f)
            {
                System::LineTraceSingle(cameraComponent.GetWorldLocation(), cameraComponent.GetWorldLocation() + cameraComponent.GetForwardVector() * attackRange,
                ETraceTypeQuery::Guard, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, true, FLinearColor::Blue, FLinearColor::Yellow);
                AMessageCharacter guardHit = Cast<AMessageCharacter>(hitResult.GetActor());

                dispatchCooldown = .75f;
                if (guardHit != nullptr)
                {
                    actorToDamage = hitResult.GetActor();
                    System::SetTimer(this, n"berserkAttack", 0.25f, false);
                    SwordSwing();
                    EndAttackRandomGuard();
                }
            }
        }
    }

    void EndAttackRandomGuard()
    {
        inBeserkMode = false;
        lockControls = false;
        berserkCooldown = 0.f;
        coolDownUntilNextBeserk = 5.f;

        tintScreenBeserk();

        desiredMoveFactor = walkFactor;
        currentLoudness = walkSteps;

        getStance();
    }

    void getStance()
    {
        if(performingSneakAttack) return;

        desiredStance = LCtrl ? .5f : 1.f;
        desiredArm = LCtrl ? 2.f : 1.f;
    }

    UFUNCTION()
    void ResetStance()
    {
        performingSneakAttack = false;
    }

    void performStance(float DeltaSeconds)
    {
        const float crouchSpeedFactor = 8.0f;

        FVector parrent = GetActorScale3D();
        if (DeltaSeconds != 0)
            currentStance += (desiredStance - currentStance) * DeltaSeconds * crouchSpeedFactor;
        parrent.Z = currentStance;
        SetActorScale3D(parrent);
        

        FVector child = cameraComponent.RelativeScale3D;
        if (DeltaSeconds != 0)
            currentArm += (desiredArm - currentArm) * DeltaSeconds * crouchSpeedFactor;
        child.Z = currentArm;

        

        cameraComponent.SetRelativeScale3D(child);


    }

    FVector getStoneToss(FVector landing, float t = 1.f, float g = -980.f)
    {
        FVector throwPos = cameraComponent.WorldLocation + cameraComponent.ForwardVector * 100.f;
        FVector2D v0 = FVector2D(landing.DistXY(cameraComponent.GetWorldLocation()), landing.Z - cameraComponent.GetWorldLocation().Z);
        
        float vx = (landing.X - throwPos.X) / t;
        float vy = (landing.Y - throwPos.Y) / t;

        float vz = (throwPos.Z - landing.Z + .5 * g * t*t) / -t / 2;

        return FVector(vx, vy, vz);
    }

    UFUNCTION()
    void Trip()
    {
        soundEffectComponent.SetSound(trippingCue);
        soundEffectComponent.Play();

        tripCameraShakeDelay = System::SetTimer(this, n"TripCameraShake", 0.4, false);
        //TripCameraShake();
    }

    UFUNCTION(BlueprintEvent)
    void playerDeath()
    {}

    UFUNCTION(BlueprintEvent)
    void onStartBp()
    {}

    UFUNCTION(BlueprintEvent)
    void SwordSwing()
    {}

    UFUNCTION(BlueprintEvent)
    void RockThrow()
    {}

    UFUNCTION(BlueprintEvent)
    void AssassinateGuard()
    {}

    UFUNCTION(BlueprintEvent)
    void tintScreenBeserk()
    {}
    UFUNCTION(BlueprintEvent)
    void tintScreenDamege()
    {}
    UFUNCTION(BlueprintEvent)
    void TripCameraShake() {}

    UFUNCTION(BlueprintEvent)
    void tintScreenVoiceLine(USoundCue voiceLine)
    {}

    UFUNCTION()
    void berserkAttack()
    {
        if(actorToDamage == nullptr)
            return;
        
        Telegram msg = Telegram(
        Cast<AMessageCharacter>(this),
        Cast<AMessageCharacter>(actorToDamage),
        messegeEnum::Damage,
        0,
        ""
        );

        msg.extraFloat = attackDamage;

        dispatcher.dispatchMessage(msg);
    }
    UFUNCTION()
    void normalAttack()
    {
        AMessageCharacter target;
        for(int i = -1; i <= 1; i++)
        {
            FRotator aimDirection = cameraComponent.WorldRotation + FRotator(0.f, i * 10.f, 0.f);
            System::LineTraceSingle(cameraComponent.WorldLocation, cameraComponent.GetWorldLocation() + aimDirection.ForwardVector * attackRange,
            ETraceTypeQuery::Guard, false, actorsToIgnore, EDrawDebugTrace::None, hitResult, true, FLinearColor::Blue, FLinearColor::Yellow);
            target = Cast<AMessageCharacter>(hitResult.Actor);
            if (target != nullptr)
            {
                DamageGuard(hitResult.Actor, hitResult.Component);
                return;
            }
        }
    }

    UFUNCTION()
    void DamageGuard(AActor hitActor, UActorComponent hitComponent)
    {
        if (hitComponent == nullptr)
            return;

        if (!hitComponent.ComponentHasTag(n"GuardHitBox"))
            return;
        
        actorToDamage = hitActor;

        if (hitComponent.ComponentHasTag(n"HeadHitBox"))
        {
            damageToDeal = attackDamage;
        }
        else if (hitComponent.ComponentHasTag(n"ChestHitBox"))
        {
            damageToDeal = attackDamage * 0.75f;
        }
        else if (hitComponent.ComponentHasTag(n"LegsHitBox"))
        {
            damageToDeal = attackDamage * 0.5f;
        }

        if(damageToDeal <= 0)
            return;
        
        Telegram msg = Telegram(
            Cast<AMessageCharacter>(this),
            Cast<AMessageCharacter>(actorToDamage),
            messegeEnum::Damage,
            0,
            ""
            );

        msg.extraFloat = damageToDeal;

        dispatcher.dispatchMessage(msg);

        damageToDeal = 0.0f;
        actorToDamage = nullptr;
    }

    bool pickupStoonePile(AStoonePile stoonePile) 
    {
        if(heldStones<maxStones && heldStones + stoonePile.stooneInPile <= maxStones)
        {
            heldStones += stoonePile.stooneInPile;
            return true;
        }
        else if(heldStones + stoonePile.stooneInPile > maxStones && heldStones <maxStones)
        {

            heldStones = maxStones;
            return true;
        }
        else{
            return false;
        }
    }
};

void playVoiceLine(USoundCue voiceLine)
{
    TArray<APlayerCharacter> player;
    GetAllActorsOfClass(player);

    player[0].tintScreenVoiceLine(voiceLine);

    player[0].queensVoiceComponent.SetSound(voiceLine);
    player[0].queensVoiceComponent.Play();
}

void TripCameraShake()
{
    Cast<APlayerCharacter>(Gameplay::GetPlayerPawn(0)).Trip();
}