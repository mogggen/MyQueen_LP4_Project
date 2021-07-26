import Guard;
import StateMachineClass;
import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";

void ChangeToStandGuardState(AGuard guard)
{
    guard.fsm.ChangeState(StandGuardState());
}

class StandGuardState : BaseState
{
    AGuard guard;

    void Enter(AMessageCharacter actor) override
    {
        guard = Cast<AGuard>(actor);
        guard.isIdle = true;
        float randomDelay = FMath::RandRange(guard.minTimeUntilTap, guard.maxTimeUntiltap);
        System::SetTimer(guard, n"startFootTap", randomDelay, false);
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {   
        if (guard.detectPlayerComponent.canSeePlayer)
        {
            ChangeToChaseState(guard);
        }
    }

    void Exit(AMessageCharacter actor)
    {
        guard.isIdle = false;
        guard.isBored = false;
    }
    
    void HeardSound(AMessageCharacter actor, FVector location) override
    {
        guard.goalPos = location;
        ChangeToInvestigatingState(guard);
        guard.ShowHeardSomethingIcon();
    }

    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(Cast<AGuard>(actor));
    }

    void startTappingFoot(AMessageCharacter actor) override
    {
        guard.isBored = true;
    }

    void endTappingFoot(AMessageCharacter actor) override
    {
        guard.isBored = false;
        float randomDelay = FMath::RandRange(guard.minTimeUntilTap, guard.maxTimeUntiltap);
        System::SetTimer(guard, n"startFootTap", randomDelay, false);
    }
}
