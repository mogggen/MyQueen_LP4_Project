import Guard;
import StateMachineClass;
import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";
import GuardStates.PatrollState;

void ChangeToOpenDoorState(AGuard guard)
{
    // only change if guard is not in this state yet
    if(Cast<OpenDoorState>(guard.fsm.m_currentState) == nullptr)
    {
        guard.fsm.ChangeState(OpenDoorState());
    }
}

class OpenDoorState : BaseState
{
    AGuard guard;
    ARecastNavMesh recastNavMesh;

    void Enter(AMessageCharacter actor) override
    {
        guard = Cast<AGuard>(actor);
        if(Cast<PatrollState>(guard.fsm.m_previousState) != nullptr)
        {
            guard.isIdle = true;
        }

        TArray<ARecastNavMesh> navmeshes;
        GetAllActorsOfClass(navmeshes);
        ensure(navmeshes.Num() > 0, "No navmesh found.");
        recastNavMesh = navmeshes[0];
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        if (guard.detectPlayerComponent.canSeePlayer)
        {
            ChangeToChaseState(guard);
        }
    }

    void Exit(AMessageCharacter actor) override
    {
        guard.isIdle = false;
    }

    void HeardSound(AMessageCharacter actor, FVector location) override
    {
        FVector loc;
        UNavigationSystemV1::ProjectPointToNavigation(location, loc, recastNavMesh, nullptr);
        guard.goalPos = loc;
        guard.ShowHeardSomethingIcon();
        ChangeToInvestigatingState(guard);
    }

    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(guard);
    }

    void GoToPreviousState(AMessageCharacter actor) override
    {
        guard.fsm.RevertToPreviousState();
    }
}