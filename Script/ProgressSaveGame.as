struct ProgressSaved
{
    UPROPERTY()
    int level;
    UPROPERTY()
    float insanity;
    UPROPERTY()
    float health;
    UPROPERTY()
    float stamina;
    UPROPERTY()
    int heldStones;
}

class UProgressSaveGame : USaveGame
{
    UPROPERTY()
    ProgressSaved progress;
}