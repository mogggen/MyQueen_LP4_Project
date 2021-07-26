//import PlayerCharacter;
// either the playerCharacter gets a fsm, or this component imports global functions from PlayerCharacter.as.
// global functions such as scream() or trip()
import messagingSystem;
import InsanityStateEnums;
import VoiceInsanety;
import SpawnGuardComponent;
import void TripCameraShake() from "PlayerCharacter";

InsanityState GetInsanityState()
{
    return Cast<UInsanitySystem>(Gameplay::GetPlayerPawn(0).GetComponentByClass(UInsanitySystem::StaticClass())).insanityState;
}


class UInsanitySystem : UActorComponent
{
    // should match with the insanity state at start
    UPROPERTY()
    float insanityValue = 50;
    // should match with the insanity value at start
    UPROPERTY()
    InsanityState insanityState = InsanityState::NEUTRAL;

    float minInsanityValue = 0;
    float toParanoidValue = 19;
    float toGoingParanoidValue = 39;
    float toGoingBerserkValue = 59;
    float toBerserkValue = 79;
    float maxInsanityValue = 99;

    FTimerHandle decreaseTimerHandle, tripTimerHandle;

    USpawnGuardComponent spawnGuardComponent;


    // higher value means slower automatic decrease of insanity
    UPROPERTY()
    float decreaseCountdown = 1;
    // how long until automatic decrease starts (after a guard has stopped chasing you)
    UPROPERTY()
    float startTimerDelay = 4;

    AMessageDispatcher dispatcher;

    // determines how often the player trips when in paranoia
    UPROPERTY()
    float minTimeBeforeTrip = 4;
    // determines how often the player trips when in paranoia
    UPROPERTY()
    float maxTimeBeforeTrip = 8;
    UPROPERTY()
    float tripSoundRadius = 2000;
    // determines how often the player screams when in berserk
    UPROPERTY()
    float minTimeBeforeScream = 5;
    // determines how often the player screams when in berserk
    UPROPERTY()
    float maxTimeBeforeScream = 15;
    UPROPERTY()
    float screamSoundRadius = 5000;

    VoiceInsanety voiceInsanity;

    // changeTo and setTo functions are used to change values etc that only need to be changed once state is changed
    void setToParanoid()
    {
        voiceInsanity.switchInsanetyState(InsanityState::PARANOID);
    }
    void changeToParanoid() 
    {
        setToParanoid();
    }
    void setToGoingParanoid()
    {
        voiceInsanity.switchInsanetyState(InsanityState::GOINGPARANOID);
    }
    void changeToGoingParanoid() 
    {
        setToGoingParanoid();
    }
    void setToNeutral() 
    {
        voiceInsanity.switchInsanetyState(InsanityState::NEUTRAL);
    }
    void changeToNeutral() 
    {
        setToNeutral();
    }
    void setToGoingBerserk()
    {
        voiceInsanity.switchInsanetyState(InsanityState::GOINGBERSERK);
    }
    void changeToGoingBerserk() 
    {
        setToGoingBerserk();
    }
    void setToBerserk() 
    {
        float randomDelay = FMath::RandRange(minTimeBeforeScream, maxTimeBeforeScream);
        //System::SetTimer(this, n"scream", randomDelay, false);
        voiceInsanity.switchInsanetyState(InsanityState::BERSERK);
    }
    void changeToBerserk() 
    {
        setToBerserk();
    }

    bool insanityStateHasChanged()
    {
        switch(insanityState) {
            // if insanity is above toParanoidValue, change state
            case InsanityState::PARANOID: {
                if(insanityValue > toParanoidValue) {
                    insanityState = InsanityState::GOINGPARANOID;
                    return true;
                }
                break;
            }
            // if insanity is toParanoidValue or below, change state
            // if insanity is above toGoingParanoidValue, change state
            case InsanityState::GOINGPARANOID: {
                if(insanityValue <= toParanoidValue) {
                    insanityState = InsanityState::PARANOID;
                    return true;
                }
                else if(insanityValue > toGoingParanoidValue) {
                    insanityState = InsanityState::NEUTRAL;
                    return true;
                }
                break;
            }
            // if insanity is toGoingParanoidValue or below, change state
            // if insanity is above toGoingBerserkValue, change state
            case InsanityState::NEUTRAL: {
                if(insanityValue <= toGoingParanoidValue) {
                    insanityState = InsanityState::GOINGPARANOID;
                    return true;
                }
                else if(insanityValue > toGoingBerserkValue) {
                    insanityState = InsanityState::GOINGBERSERK;
                    return true;
                }
                break;
            }
            // if insanity is toGoingBerserkValue or below, change state
            // if insanity is above toBerserkValue, change state
            case InsanityState::GOINGBERSERK: {
                if(insanityValue <= toGoingBerserkValue) {
                    insanityState = InsanityState::NEUTRAL;
                    return true;
                }
                else if(insanityValue > toBerserkValue) {
                    insanityState = InsanityState::BERSERK;
                    return true;
                }
                break;
            }
            // if insanity is below toBerserkValue, change state
            case InsanityState::BERSERK: {
                if(insanityValue <= toBerserkValue) {
                    insanityState = InsanityState::GOINGBERSERK;
                    return true;
                }
                break;
            }
        }
        return false;
    }

    // pass in a negative value to decrease, or positive to increase
    void changeInsanityValue(float amount) 
    {
        // make sure new value stays between max and min
        float newInsanityValue = insanityValue + amount;
        if(newInsanityValue < minInsanityValue) {
            insanityValue = minInsanityValue;
        }
        else if (newInsanityValue > maxInsanityValue) {
            insanityValue = maxInsanityValue;
        }
        else {
            insanityValue += amount;
        }

        // if insanityState has changed, change state
        if(insanityStateHasChanged()) {
            switch(insanityState) {
                case InsanityState::PARANOID: {
                    changeToParanoid();
                    break;
                }
                case InsanityState::GOINGPARANOID: {
                    changeToGoingParanoid();
                    break;
                }
                case InsanityState::NEUTRAL: {
                    changeToNeutral();
                    break;
                }
                case InsanityState::GOINGBERSERK: {
                    changeToGoingBerserk();
                    break;
                }
                case InsanityState::BERSERK: {
                    changeToBerserk();
                    break;
                }
            }
            Telegram msg = Telegram(GetOwner(),Cast<AMessageCharacter>(Gameplay::GetPlayerPawn(0)), messegeEnum::VOICELINE, 0,"");
            dispatcher.dispatchMessage(msg);
        }
    }

    UFUNCTION()
    void decreaseMeter() 
    {
        if(insanityState == InsanityState::BERSERK)
            changeInsanityValue(-1);
        else
            changeInsanityValue(-0.2);
    }

    UFUNCTION()
    void startDecreaseTimer()
    {
        System::ClearAndInvalidateTimerHandle(decreaseTimerHandle);
        float delay;

        if(insanityState == InsanityState::BERSERK)
            decreaseTimerHandle = System::SetTimer(this, n"decreaseMeter", decreaseCountdown, true, 0.0f);
        else
            decreaseTimerHandle = System::SetTimer(this, n"decreaseMeter", decreaseCountdown, true, startTimerDelay);

    }

    UFUNCTION()
    void trip()
    {
        // check state
        if(insanityState == InsanityState::PARANOID) {
            // send sound message
            // Print("Tripped");
            Telegram telegram = Telegram(GetOwner(), Cast<AMessageCharacter>(nullptr), messegeEnum::SuspiciousSound, 0, "");
            dispatcher.dispatchMessageWithinRadius(telegram, tripSoundRadius);
            PlayTripAnimation();
        }
    }

    UFUNCTION(BlueprintEvent)
    void PlayTripAnimation()
    {
        TripCameraShake();
    }

    UFUNCTION()
    void scream()
    {
        // check state
        if(insanityState == InsanityState::BERSERK) {
            // send sound message and set timer again
            //Print("Screamed");
            Telegram telegram = Telegram(GetOwner(), Cast<AMessageCharacter>(nullptr), messegeEnum::SuspiciousSound, 0, "");
            dispatcher.dispatchMessageWithinRadius(telegram, screamSoundRadius);
            float randomDelay = FMath::RandRange(minTimeBeforeScream, maxTimeBeforeScream);
            System::SetTimer(this, n"scream", randomDelay, false);
        }
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        spawnGuardComponent = Cast<USpawnGuardComponent>(GetOwner().GetComponentByClass(USpawnGuardComponent::StaticClass()));

        decreaseTimerHandle = System::SetTimer(this, n"decreaseMeter", decreaseCountdown, true);

        voiceInsanity = VoiceInsanety();

        // change state if not neutral
        switch(insanityState) {
            case InsanityState::PARANOID: {
                setToParanoid();
                break;
            }
            case InsanityState::GOINGPARANOID: {
                setToGoingParanoid();
                break;
            }
            case InsanityState::NEUTRAL: {
                setToNeutral();
                break;
            }
            case InsanityState::GOINGBERSERK: {
                setToGoingBerserk();
                break;
            }
            case InsanityState::BERSERK: {
                setToBerserk();
                break;
            }
        }

        TArray<AMessageDispatcher> messageDispatchers;
        GetAllActorsOfClass(messageDispatchers);
        ensure(messageDispatchers.Num() > 0, "InsanitySystemComponent.as, BeginPlay(): No messagesDispatcher found!");
        dispatcher = messageDispatchers[0];
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        switch(insanityState) {
            // make sound like the stone sometimes
            case InsanityState::PARANOID: {
                break;
            }
            // do nothing
            case InsanityState::GOINGPARANOID: {
                break;
            }
            // do nothing
            case InsanityState::NEUTRAL: {
                break;
            }
            // do nothing
            case InsanityState::GOINGBERSERK: {
                break;
            }
            // make sound sometimes that's louder than stone
            case InsanityState::BERSERK: {
                spawnGuardComponent.Update(DeltaSeconds);
                break;
            }
        }
    }
}