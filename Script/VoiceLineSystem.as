import Telegram;
import VoiceInsanety;
import VoiceBox;
import Painting;
import void playVoiceLine(USoundCue voiceLine) from "PlayerCharacter";

class UVoiceLineSystem: UActorComponent
{
    UPROPERTY(EditAnywhere)
    float delay;
    UPROPERTY(EditAnywhere)
    Telegram locationBased;
    
    Telegram insanityBased; 
    UPROPERTY()
    VoiceInsanety voiceInsanityComponent;
    float deleyTime, isplayingTime;
    bool isPlaying;
    UPROPERTY()
    bool ableToPlay = false;

    void messageHandeling(Telegram msg)
    {
        AActor sender = msg.sender;
        APainting painting = Cast<APainting>(sender);
        AVoiceBox voiceBox = Cast<AVoiceBox>(sender);

        
        if((msg.sender == painting || msg.sender == voiceBox))
        {
            // Print("Got to say stuff");
            locationBased = msg;
        }
        else
            insanityBased = msg;
    }
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if(!isPlaying && ableToPlay)
            checkVoiceLineToPlay();
        else if(isPlaying && isplayingTime <= GetCurrentWorld().GetTimeSeconds())
            isPlaying = false;
    }

    bool checkPlayability(Telegram msg)
    {
        AActor sender = msg.sender;
        APainting painting = Cast<APainting>(sender);
        AVoiceBox voiceBox = Cast<AVoiceBox>(sender);

        if(painting != nullptr)
        {
            if(painting.isLookingAtPainting)
            {
                return true;
            }
        }
        else if (voiceBox != nullptr){
            if(voiceBox.playerIsInside)
            {
                return true;
            }
        }
        return false;
    }
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        voiceInsanityComponent = Cast<VoiceInsanety>(Gameplay::GetPlayerPawn(0).GetComponentByClass(VoiceInsanety::StaticClass()));
        deleyTime = GetWorld().GetTimeSeconds() + deleyTime;
    }

    UFUNCTION()
    void checkVoiceLineToPlay()
    {
        if(locationBased.extraSoundque != nullptr && this.checkPlayability(locationBased))
        {

            playVoiceLine(locationBased.extraSoundque);
            deleyTime = GetWorld().GetTimeSeconds() + locationBased.extraSoundque.Duration + delay;
            isplayingTime = GetWorld().GetTimeSeconds() + locationBased.extraSoundque.Duration + 1;
            locationBased.extraSoundque = nullptr;
            isPlaying = true;

            AVoiceBox voiceBox = Cast<AVoiceBox>(locationBased.sender);
            if(voiceBox != nullptr)
            {
                voiceBox.destroyItem();
            }
        }
        else if(insanityBased.sender != nullptr && deleyTime <= GetWorld().GetTimeSeconds())
        {
            USoundCue temp = voiceInsanityComponent.choiceVoiceLine(); 
            if(temp != nullptr)
            {
                playVoiceLine(temp);
                deleyTime = GetWorld().GetTimeSeconds() + temp.Duration + delay;
                isplayingTime = GetWorld().GetTimeSeconds() + temp.Duration;
            }
            insanityBased.sender = nullptr;
            isPlaying = true;
        }
    }
}