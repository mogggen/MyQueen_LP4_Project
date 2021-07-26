struct Settings
{
    UPROPERTY()
    bool toggleCrouch;
    UPROPERTY()
    bool motionBlur;
    UPROPERTY()
    float musicVolume;
    UPROPERTY()
    float sfxVolume;
}

UCLASS()
class USettingsSaveGame : USaveGame
{
    UPROPERTY()
    Settings settings;

    UFUNCTION()
    Settings getSettings()
    {
        return settings;
    }
    
    UFUNCTION()
    void setSettings(Settings settings)
    {
        this.settings = settings;
    }

    UFUNCTION(BlueprintEvent)
    void ApplySettingsToGame(APawn player) {}
}