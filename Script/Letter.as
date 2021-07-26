import OutlineComponent;

class ALetter : AActor
{
    UPROPERTY(DefaultComponent)
    UAudioComponent openLetterAudio;
    UPROPERTY(DefaultComponent)
    UAudioComponent readLetterAudio;
    UPROPERTY(DefaultComponent)
    UOutlineComponent outlineComponent;
    
    UPROPERTY(EditAnywhere)
    int letterIndex = 0;

    UPROPERTY(EditAnywhere)
    USoundCue openLetterSoundCue;

    UPROPERTY(EditAnywhere)
    USoundCue LetterToReadCue;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        openLetterAudio.SetUISound(true);
        readLetterAudio.SetUISound(true);

        openLetterAudio.SetSound(openLetterSoundCue);
        readLetterAudio.SetSound(LetterToReadCue);
    }

    UFUNCTION(BlueprintEvent)
    void openLetterEvent()
    {}

    UFUNCTION(BlueprintEvent)
    void readLetterEvent()
    {}

    UFUNCTION()
    void playOpenLetterSoundCue()
    {
        openLetterAudio.Play();
    }

    UFUNCTION()
    void playReadLetter()
    {
        readLetterAudio.Play();
    }

    UFUNCTION()
    void consealLetter()
    {
        if (!Gameplay::IsGamePaused() && readLetterAudio.IsPlaying())
        {
            readLetterAudio.Stop();
            DestroyActor();
        }
    }
};
