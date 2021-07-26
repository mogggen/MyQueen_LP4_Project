import messagingSystem;
import StateMachineClass;
import PatrolPoint;
import void ChangeToPatrolState(APurpuleQueen queen) from "QueenStates.QPatrolState";
import void ChangeToDeadState(APurpuleQueen queen) from "QueenStates.QDeadState";
import void ChangeToIdleState(APurpuleQueen queen) from "QueenStates.QIdleState";

class APurpuleQueen : AMessageCharacter
{
    float health = 10;
    stateMachine fsm;

    /// Patrolling ---------------------
    int currentPatrollPoint = 0;
    UPROPERTY(EditAnywhere, Category = "Patrol")
    TArray<APatrolPoint> patrollPoints; 
    // Determines how far from a patrol point the guard will accelerate to and from a halt.
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float distanceToStartTurning = 100.f;
    // Seconds before turning and walking to next patrol point
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float timeToStandStill = 2.f; 
    UPROPERTY(EditAnywhere, Category = "Patrol")
    float rotationSpeed = 0.7;

    /// Animations -------------------
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurning;
    default isTurning = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurningLeft;
    default isTurningLeft = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isTurningRight;
    default isTurningRight = false;
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Animation")
    bool isDying;
    default isDying = false;

    APurpuleQueen()
    {
        fsm = stateMachine(this);
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        ChangeToPatrolState(this);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        fsm.Update(DeltaSeconds);
    }

    void handleMessage(Telegram telegram)// override
    {
        if (telegram.msg == messegeEnum::Damage)
        {
            health -= 10.f;
            if (health <= 0)
            {
                ChangeToDeadState(this);
                //endLevel();
                return;
            }
            //Print("health: " + health);
        }
    }
    UFUNCTION(BlueprintEvent)
    void endLevel(){
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

    UFUNCTION(BlueprintCallable)
    void lookAtPlayer()
    {
        ChangeToIdleState(this);
        isTurning = true;
    }
}

