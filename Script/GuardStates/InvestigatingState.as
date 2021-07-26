import Guard;
import StateMachineClass;
//import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToReturnToPostState(AGuard guard) from "GuardStates.ReturnToPostState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";
import GuardStates.ChaseState;

void ChangeToInvestigatingState(AGuard guard)
{
    guard.fsm.ChangeState(InvestigatingState());
}

enum InvestigateTuringState {
    NOT_TURNING,
    LOOKING_AROUND,
    TO_NEXT_GOAL_POS
}

class InvestigatingState : BaseState
{
    int q;
    TArray<FVector> posisons;
    InvestigateTuringState turningState;
    FVector startDirektion;
    FRotator startRotation;

    ARecastNavMesh recastNavMesh;

    AGuard guard;
    float lookAroundTimer;

    void Enter(AMessageCharacter actor) override
    {   
        TArray<ARecastNavMesh> navmeshes;
        GetAllActorsOfClass(navmeshes);
        ensure(navmeshes.Num() > 0, "No navmesh found.");
        recastNavMesh = navmeshes[0];

        guard = Cast<AGuard>(actor);

        FVector temp = guard.GetActorLocation();
        q = FMath::RandRange(3, 5);

        guard.isCautious = true;
        guard.CharacterMovement.MaxWalkSpeed = guard.investigatingSpeed;
        
        posisons.Empty();
        for(int i = 0; i < q; i++)
        {
            if(UNavigationSystemV1::GetRandomReachablePointInRadius(guard.goalPos, temp, guard.investigativRadius))
            {
                // if successful in getting reachable point, add temp to posisons
                posisons.Add(temp);
            }
            else
                return;
        }
        
        if(Cast<ChaseState>(guard.fsm.m_previousState) != nullptr)
        {
            // look around first if previous state was ChaseState
            turningState = InvestigateTuringState::LOOKING_AROUND;
            lookAroundTimer = 3;
            guard.isLookingAround = true;
            guard.detectPlayerComponent.fieldOfView = 1.6;
        }
        else
        {
            turningState = InvestigateTuringState::NOT_TURNING;
            guard.moveToLocation(guard.goalPos);
        }
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        auto rotation = guard.GetActorRotation();

        if(guard.detectPlayerComponent.canSeePlayer)
        {
            ChangeToChaseState(guard);
            return;
        }

        if(guard.goalPos.Distance(guard.GetActorLocation()) > 50 && posisons.Num() > 0 && turningState == InvestigateTuringState::NOT_TURNING)
        {
            //Print("Moving");
        }
        else if(turningState != InvestigateTuringState::NOT_TURNING) 
        {
            switch(turningState)
            {
                case InvestigateTuringState::NOT_TURNING: break;
                case InvestigateTuringState::LOOKING_AROUND:
                {
                    lookAroundTimer -= DeltaSeconds;
                    if(lookAroundTimer <= 0) {
                        turnTowardsNextGoal();
                        guard.detectPlayerComponent.fieldOfView = 0.8;
                    }
                    break;
                }
                case InvestigateTuringState::TO_NEXT_GOAL_POS: 
                {
                    FVector newLocation = guard.goalPos - guard.GetActorLocation();
                    FRotator newRotation = FRotator(0, newLocation.Rotation().Yaw, 0);

                    if(guard.turn(newRotation, DeltaSeconds)){
                        turningState = InvestigateTuringState::NOT_TURNING;
                        guard.isTurning = false;
                        guard.isTurningLeft = false;
                        guard.isTurningRight = false;
                        if(posisons.Num() <= 0)
                        {
                            ChangeToReturnToPostState(guard);
                        }
                        else
                            guard.moveToLocation(guard.goalPos);
                    }

                }
            }
        }
    }

    void Exit(AMessageCharacter actor) override
    {
        guard.isTurning = false;
        guard.isTurningRight = false;
        guard.isTurningLeft = false;
        guard.isCautious = false;
        guard.isLookingAround = false;
        guard.healthBarVisible = false;
        guard.CharacterMovement.MaxWalkSpeed = guard.walkingSpeed;
        guard.detectPlayerComponent.fieldOfView = 0.8;
    }

    void MoveCompleted(AMessageCharacter actor, EPathFollowingResult result) override
    {
        if (result == EPathFollowingResult::Aborted)
        {
            return;
        }

        if(turningState != InvestigateTuringState::NOT_TURNING)
        {
            return;
        }

        if(posisons.Num() <= 0)
        {
            // set goalPos to startLocation before looking around one last time
            guard.goalPos = guard.startLocation;
        }
        else
        {
            guard.goalPos = posisons[0];
            posisons.RemoveAt(0);
        }

        turningState = InvestigateTuringState::LOOKING_AROUND;
        lookAroundTimer = 3;
        guard.isLookingAround = true;
        guard.detectPlayerComponent.fieldOfView = 1.6;
    }
    
    void HeardSound(AMessageCharacter actor, FVector location) override
    {
        FVector loc;
        UNavigationSystemV1::ProjectPointToNavigation(location, loc, recastNavMesh, nullptr);
        guard.goalPos = loc;
        guard.ShowHeardSomethingIcon();
        guard.fsm.ChangeState(InvestigatingState());
    }

    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(guard);
    }

    void turnTowardsNextGoal()
    {
        turningState = InvestigateTuringState::TO_NEXT_GOAL_POS;
        guard.isLookingAround = false;
        guard.isTurning = true;
    }
}