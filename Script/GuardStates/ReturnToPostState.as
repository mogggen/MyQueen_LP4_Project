import Guard;
import StateMachineClass;
import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";
import void ChangeToPatrollState(AGuard guard) from "GuardStates.PatrollState";
import void ChangeToStandGuardState(AGuard guard) from "GuardStates.StandGuardState";

void ChangeToReturnToPostState(AGuard guard)
{
    guard.fsm.ChangeState(ReturnToPostState());
}

class ReturnToPostState : BaseState
{
    void Enter(AMessageCharacter actor) override
    {
        AGuard guard = Cast<AGuard>(actor);

        if (guard.patrollPoints.Num() > 0)
            ChangeToPatrollState(guard);
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        AGuard guard = Cast<AGuard>(actor);

        if (guard.detectPlayerComponent.canSeePlayer)
        {
            ChangeToChaseState(guard);
        }
        
        AIBlueprintHelper::SimpleMoveToLocation(guard.Controller, guard.startLocation);
        
        if (guard.GetActorLocation().DistXY(guard.startLocation) < 45.0f)
        {
            // Change to Standing Post state;
            if(guard.turn(guard.startRotation, DeltaSeconds))
            {
                ChangeToStandGuardState(guard);
            }
        
        }
    }

    void Exit(AMessageCharacter actor) override   
    {

    }
    
    void HeardSound(AMessageCharacter actor, FVector location) override
    {
        AGuard guard = Cast<AGuard>(actor);
        guard.goalPos = location;
        guard.ShowHeardSomethingIcon();
        ChangeToInvestigatingState(guard);
    }
     
    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(Cast<AGuard>(actor));
    }
}