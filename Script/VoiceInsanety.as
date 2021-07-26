import InsanityStateEnums;
import FloorEnums;
import InsanityState GetInsanityState() from "InsanitySystemComponent";

USTRUCT()
struct array2d
{
    TArray<USoundCue> myArray;
}

class VoiceInsanety: UActorComponent
{
    //UPROPERTY()
    int state;

    TArray<array2d> basement;
    TArray<array2d> firstFloor;
    TArray<array2d> finalFloor;

    UPROPERTY()
    TArray<array2d> currentArray2d;

    // basement insanety
    UPROPERTY()
    TArray<USoundCue> basement_InsanetyBerserk;
    UPROPERTY()
    TArray<USoundCue> basement_InsanetyGoingBerserk;
    UPROPERTY()
    TArray<USoundCue> basement_InsanetyNeutral;
    UPROPERTY()
    TArray<USoundCue> basement_InsanetyGoingParanoid;
    UPROPERTY()
    TArray<USoundCue> basement_InsanetyParanoid;

    // first floor insanety
    UPROPERTY()
    TArray<USoundCue> firstFloor_InsanetyBerserk;
    UPROPERTY()
    TArray<USoundCue> firstFloor_InsanetyGoingBerserk;
    UPROPERTY()
    TArray<USoundCue> firstFloor_InsanetyNeutral;
    UPROPERTY()
    TArray<USoundCue> firstFloor_InsanetyGoingParanoid;
    UPROPERTY()
    TArray<USoundCue> firstFloor_InsanetyParanoid;
    
     // final floor insanety
    UPROPERTY()
    TArray<USoundCue> finalFloor_InsanetyBerserk;
    UPROPERTY()
    TArray<USoundCue> finalFloor_InsanetyGoingBerserk;
    UPROPERTY()
    TArray<USoundCue> finalFloor_InsanetyNeutral;
    UPROPERTY()
    TArray<USoundCue> finalFloor_InsanetyGoingParanoid;
    UPROPERTY()
    TArray<USoundCue> finalFloor_InsanetyParanoid;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        basement.SetNum(5);
        firstFloor.SetNum(5);
        finalFloor.SetNum(5);

        //reads in sound fiels
        //basment
        basement[0].myArray.Append(basement_InsanetyParanoid);
        basement[1].myArray.Append(basement_InsanetyGoingParanoid);
        basement[2].myArray.Append(basement_InsanetyNeutral);
        basement[3].myArray.Append(basement_InsanetyGoingBerserk);
        basement[4].myArray.Append(basement_InsanetyBerserk);
        //Firstfloor
        firstFloor[0].myArray.Append(firstFloor_InsanetyParanoid);
        firstFloor[1].myArray.Append(firstFloor_InsanetyGoingParanoid);
        firstFloor[2].myArray.Append(firstFloor_InsanetyNeutral);
        firstFloor[3].myArray.Append(firstFloor_InsanetyGoingBerserk);
        firstFloor[4].myArray.Append(firstFloor_InsanetyBerserk);
         //Firstfloor
        finalFloor[0].myArray.Append(finalFloor_InsanetyParanoid);
        finalFloor[1].myArray.Append(finalFloor_InsanetyGoingParanoid);
        finalFloor[2].myArray.Append(finalFloor_InsanetyNeutral);
        finalFloor[3].myArray.Append(finalFloor_InsanetyGoingBerserk);
        finalFloor[4].myArray.Append(finalFloor_InsanetyBerserk);

        //currentArray2d.Append(basement);
    }

    void switchInsanetyState(InsanityState newState)
    {
        switch(newState){
            case InsanityState::PARANOID:
                state = 0;
                break;
            case InsanityState::GOINGPARANOID:
                state = 1;
                break;
            case InsanityState::NEUTRAL:
                state = 2;
                break;
            case InsanityState::GOINGBERSERK:
                state = 3;
                break;
            case InsanityState::BERSERK:
                state = 4;
                break;
            default:
                break;
        }
        //Print("newState: "+newState+" state: "+state);
    }
    void switchFloor(int floor)
    {
        currentArray2d.Empty();
        switch(floor)
        {
            case 0:
                currentArray2d.Append(basement);
                break;
            case 1:
                currentArray2d.Append(firstFloor);
                break;
            case 2:
                currentArray2d.Append(finalFloor);
                break;
        }
    }
    USoundCue choiceVoiceLine()
    {
        int STATE;
        switch(GetInsanityState()){
            case InsanityState::PARANOID:
                STATE = 0;
                break;
            case InsanityState::GOINGPARANOID:
                STATE = 1;
                break;
            case InsanityState::NEUTRAL:
                STATE = 2;
                break;
            case InsanityState::GOINGBERSERK:
                STATE = 3;
                break;
            case InsanityState::BERSERK:
                STATE = 4;
                break;
        }

        if(currentArray2d[STATE].myArray.Num() <= 0)
            return nullptr;


        int i = FMath::RandRange(0, currentArray2d[STATE].myArray.Num()-1);

        auto vl = currentArray2d[STATE].myArray[i];
        currentArray2d[STATE].myArray.RemoveAt(i);
        return vl;
    }
}