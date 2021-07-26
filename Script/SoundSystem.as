struct FmultidamantionalArrary
{
    TArray<USoundCue> sounds;
    FmultidamantionalArrary()
    {
        sounds.SetNum(5);
    }
}

class SoundSystem: UActorComponent
{
    UPROPERTY()
    TArray<FmultidamantionalArrary> firstFloor;
    
}