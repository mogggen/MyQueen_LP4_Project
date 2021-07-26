import Guard;
import StateMachineClass;
import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";

void ChangeToPatrollState(AGuard guard)
{
    guard.fsm.ChangeState(PatrollState());
}

class PatrollState : BaseState
{
    AGuard guard;
    APatrolPoint currentPP, previousPP;
    
    float timerStart;
    bool isStandingAtPoint, isTurning, isSpeedingUp, isSlowingDown;
    // is only used if stayAndTurn is false
    float distanceToGoToNext;
    float patrolAcceleration = 0.000002;

    // increments past empty patrol points and resets to 0 when at end of array
    void setToNextPatrolPoint()
    {
        guard.currentPatrollPoint++;
        if (!guard.patrollPoints.IsValidIndex(guard.currentPatrollPoint)) {
            guard.currentPatrollPoint = 0;
        }
        while (guard.patrollPoints[guard.currentPatrollPoint] == nullptr)
            guard.currentPatrollPoint++;
        if(!guard.patrollPoints.IsValidIndex(guard.currentPatrollPoint))
            guard.currentPatrollPoint = 0;
    }

    // Sets isStandingAtPoint to true if guard is in range of first patrol point. Else, MoveToActor.
    void Enter(AMessageCharacter actor) override
    {
        guard = Cast<AGuard>(actor);
        if(guard.patrollPoints.Num() == 0)
            return;
        currentPP = guard.patrollPoints[guard.currentPatrollPoint];
        distanceToGoToNext = guard.distanceToStartTurning - 50;
        

        // check if guard needs to stay at currentPP
        if(currentPP.stayAndTurn && guard.ActorLocation.DistXY(currentPP.ActorLocation) < guard.distanceToStartTurning){
            isStandingAtPoint = true;
            previousPP = currentPP;
            timerStart = System::GameTimeInSeconds;
            guard.isIdle = true;
        }
        else {
            isStandingAtPoint = false;
        }

        // check if guard needs to set currentPP to next patrol point
        if(guard.ActorLocation.DistXY(currentPP.ActorLocation) < guard.distanceToStartTurning) {
            setToNextPatrolPoint();
            currentPP = guard.patrollPoints[guard.currentPatrollPoint];
        }

        isTurning = false;
        isSpeedingUp = false;
        isSlowingDown = false;
        if(!isStandingAtPoint)
            AIBlueprintHelper::SimpleMoveToActor(guard.Controller, currentPP);
            
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        // if canSeePlayer, change to chasingState
        if(guard.detectPlayerComponent.canSeePlayer) {
            ChangeToChaseState(guard);
        }
        // don't do anything if it doesn't have any patrol points
        else if(guard.patrollPoints.Num() == 0) {

        }
        else {
            // have a delay/countdown here to make the guard stand still for a few moments
            if(isStandingAtPoint) {
                if(System::GameTimeInSeconds - timerStart >= guard.timeToStandStill) {
                    isStandingAtPoint = false;
                    isTurning = true;
                    guard.isIdle = false;
                    guard.isTurning = true;
                }
            }
            // keep turning until turn returns true, then set isSpeedingUp to true and start moving
            else if(isTurning) {
                if(guard.turn(currentPP, DeltaSeconds)){
                    isTurning = false;
                    guard.isTurning = false;
                    guard.isTurningLeft = false;
                    guard.isTurningRight = false;
                    isSpeedingUp = true;
                    AIBlueprintHelper::SimpleMoveToActor(guard.Controller, currentPP);
                }
            }
            // Slow down to a halt, set next patrol point and start timer
            else if(isSlowingDown) {
                if(guard.CharacterMovement.Velocity == FVector(0)) {
                    guard.Controller.StopMovement();
                    isSlowingDown = false;
                    isStandingAtPoint = true;
                    guard.isIdle = true;
                    timerStart = System::GameTimeInSeconds;

                    previousPP = guard.patrollPoints[guard.currentPatrollPoint];
                    setToNextPatrolPoint();
                    currentPP = guard.patrollPoints[guard.currentPatrollPoint];
                }
            }
            // if in range of current patrol point, start slowing down. Or keep walking and change pp.
            else if(guard.ActorLocation.DistXY(currentPP.ActorLocation) < guard.distanceToStartTurning) {
                if(currentPP.stayAndTurn) {
                    isSpeedingUp = false;
                    isSlowingDown = true;
                }
                else if(guard.ActorLocation.DistXY(currentPP.ActorLocation) < distanceToGoToNext) {
                    previousPP = guard.patrollPoints[guard.currentPatrollPoint];
                    setToNextPatrolPoint();
                    currentPP = guard.patrollPoints[guard.currentPatrollPoint];

                    AIBlueprintHelper::SimpleMoveToActor(guard.Controller, currentPP);
                }
            }
            // Speed up and then set MaxWalkSpeed and playRate to normal
            else if(isSpeedingUp) {
                guard.Mesh.SetPlayRate(1);
                isSpeedingUp = false;
            }
        }
    }

    // Stop following path, and reset MaxWalkSpeed just in case
    void Exit(AMessageCharacter actor) override
    {
        guard.Controller.StopMovement();
        guard.isIdle = false;
        guard.isTurning = false;
        guard.isTurningRight = false;
        guard.isTurningLeft = false;
    }

    void HeardSound(AMessageCharacter actor, FVector location) override
    {
        guard.goalPos = location;
        guard.ShowHeardSomethingIcon();
        ChangeToInvestigatingState(guard);
    }
    
    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(guard);
    }
}