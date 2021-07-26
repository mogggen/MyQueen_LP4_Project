class AMessageCharacter : ACharacter
{
    UFUNCTION()
    void handleMessage(Telegram telegram) {
        //Print(telegram.extraInfo);
    }
}

enum messegeEnum{
    Damage,
    SuspiciousSound,
    Attention,
    hasDied,
    hasSpottedPlayer,
    isChasingPlayer,
    VOICELINE,
    SNEAK_KILL,
};

struct Telegram
{
    UPROPERTY()
    AActor sender;
    UPROPERTY()
    AMessageCharacter reciver;
    UPROPERTY()
    messegeEnum msg; //Messege type
    UPROPERTY()
    float dispatchTime;
    UPROPERTY()
    FString extraInfo;
    UPROPERTY()
    double help;

    FVector extraLocation;
    bool    extraBool; 
    float   extraFloat;
    USoundCue extraSoundque;


    Telegram(AActor senderIn, AMessageCharacter reciverIn, messegeEnum msgIn, float dispatchTimeIn, FString extraInfoIn){
        sender = senderIn;
        reciver = reciverIn;
        msg = msgIn;
        dispatchTime = dispatchTimeIn;
        extraInfo = extraInfoIn;
    }

}