import PurpleQueen;
import StateMachineClass;

void ChangeToPatrolState(APurpuleQueen queen)
{
    queen.fsm.ChangeState(QPatrolState());
}

class QPatrolState : BaseState
{
    APurpuleQueen queen;
    APatrolPoint currentPP, previousPP;
    
    float originalSpeed, timerStart;
    bool isStandingAtPoint, isTurning, isSpeedingUp, isSlowingDown;
    // is only used if stayAndTurn is false
    float distanceToGoToNext;
    float patrolAcceleration = 200;

    // increments past empty patrol points and resets to 0 when at end of array
    void setToNextPatrolPoint()
    {
        queen.currentPatrollPoint++;
        if(!queen.patrollPoints.IsValidIndex(queen.currentPatrollPoint)) {
            queen.currentPatrollPoint = 0;
        }
        while(queen.patrollPoints[queen.currentPatrollPoint] == nullptr)
            queen.currentPatrollPoint++;
        if(!queen.patrollPoints.IsValidIndex(queen.currentPatrollPoint))
            queen.currentPatrollPoint = 0;
    }

    // Sets isStandingAtPoint to true if queen is in range of first patrol point. Else, MoveToActor.
    void Enter(AMessageCharacter actor) override
    {
        queen = Cast<APurpuleQueen>(actor);
        if(queen.patrollPoints.Num() == 0)
            return;
        currentPP = queen.patrollPoints[queen.currentPatrollPoint];
        originalSpeed = queen.CharacterMovement.MaxWalkSpeed;
        distanceToGoToNext = queen.distanceToStartTurning - 50;
        

        // check if queen needs to stay at currentPP
        if(currentPP.stayAndTurn && queen.ActorLocation.DistXY(currentPP.ActorLocation) < queen.distanceToStartTurning){
            isStandingAtPoint = true;
            previousPP = currentPP;
            timerStart = System::GameTimeInSeconds;
            // TODO: queen.isIdle = true;
        }
        else {
            isStandingAtPoint = false;
        }

        // check if queen needs to set currentPP to next patrol point
        if(queen.ActorLocation.DistXY(currentPP.ActorLocation) < queen.distanceToStartTurning) {
            setToNextPatrolPoint();
            currentPP = queen.patrollPoints[queen.currentPatrollPoint];
        }

        isTurning = false;
        isSpeedingUp = false;
        isSlowingDown = false;
        if(!isStandingAtPoint)
            AIBlueprintHelper::SimpleMoveToActor(queen.Controller, currentPP);
            
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        // if canSeePlayer, change to chasingState
        /* if(queen.detectPlayerComponent.canSeePlayer) {
            ChangeToChaseState(queen);
        } */
        // don't do anything if it doesn't have any patrol points
        if(queen.patrollPoints.Num() == 0) {

        }
        else {
            // have a delay/countdown here to make the queen stand still for a few moments
            if(isStandingAtPoint) {
                if(System::GameTimeInSeconds - timerStart >= queen.timeToStandStill) {
                    isStandingAtPoint = false;
                    isTurning = true;
                    // queen.isIdle = false;
                    queen.isTurning = true;
                }
            }
            // keep turning until turn returns true, then set isSpeedingUp to true and start moving
            else if(isTurning) {
                if(queen.turn(currentPP, DeltaSeconds)){
                    isTurning = false;
                    queen.isTurning = false;
                    queen.isTurningLeft = false;
                    queen.isTurningRight = false;
                    isSpeedingUp = true;
                    AIBlueprintHelper::SimpleMoveToActor(queen.Controller, currentPP);
                }
            }
            // Slow down to a halt, set next patrol point and start timer
            else if(isSlowingDown) {
                // Lerp makes it too smooth. Editing speed manually like this works better.
                //float percentageLeft = queen.ActorLocation.DistXY(currentPP.ActorLocation) / queen.distanceToStartTurning;
                queen.CharacterMovement.MaxWalkSpeed -= patrolAcceleration * DeltaSeconds;

                // TODO: queen.Mesh.SetPlayRate(percentageLeft);

                if(queen.CharacterMovement.Velocity == FVector(0)) {
                    queen.Controller.StopMovement();
                    isSlowingDown = false;
                    isStandingAtPoint = true;
                    // TODO: queen.isIdle = true;
                    timerStart = System::GameTimeInSeconds;

                    previousPP = queen.patrollPoints[queen.currentPatrollPoint];
                    setToNextPatrolPoint();
                    currentPP = queen.patrollPoints[queen.currentPatrollPoint];
                }
            }
            // if in range of current patrol point, start slowing down. Or keep walking and change pp.
            else if(queen.ActorLocation.DistXY(currentPP.ActorLocation) < queen.distanceToStartTurning) {
                if(currentPP.stayAndTurn) {
                    isSpeedingUp = false;
                    isSlowingDown = true;
                }
                else if(queen.ActorLocation.DistXY(currentPP.ActorLocation) < distanceToGoToNext) {
                    previousPP = queen.patrollPoints[queen.currentPatrollPoint];
                    setToNextPatrolPoint();
                    currentPP = queen.patrollPoints[queen.currentPatrollPoint];

                    AIBlueprintHelper::SimpleMoveToActor(queen.Controller, currentPP);
                }
            }
            // Speed up and then set MaxWalkSpeed and playRate to normal
            else if(isSpeedingUp) {
                // increase based on distanceToStartTurning
                // float percentageWalked = queen.ActorLocation.DistXY(previousPP.ActorLocation) / queen.distanceToStartTurning;
                
                queen.CharacterMovement.MaxWalkSpeed += patrolAcceleration * DeltaSeconds;
                // TODO: queen.Mesh.SetPlayRate(percentageWalked);

                if(queen.CharacterMovement.MaxWalkSpeed / originalSpeed >= 0.96f) {
                    queen.CharacterMovement.MaxWalkSpeed = originalSpeed;
                    // TODO: queen.Mesh.SetPlayRate(1);
                    isSpeedingUp = false;
                }
            }
        }
    }

    // Stop following path, and reset MaxWalkSpeed just in case
    void Exit(AMessageCharacter actor) override
    {
        queen.Controller.StopMovement();
        queen.CharacterMovement.MaxWalkSpeed = originalSpeed;
        // queen.isIdle = false;
        queen.isTurning = false;
        queen.isTurningRight = false;
        queen.isTurningLeft = false;
    }
}