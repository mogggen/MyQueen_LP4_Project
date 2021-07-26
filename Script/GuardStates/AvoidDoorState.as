import Guard;
import StateMachineClass;
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import GuardStates.OpenDoorState;
import GuardStates.FightState;
import GuardStates.ChaseState;

bool ChangeToAvoidDoorState(AGuard guard)
{
    // only change if guard is not in this state yet
    if(Cast<AvoidDoorState>(guard.fsm.m_currentState) == nullptr && 
        Cast<OpenDoorState>(guard.fsm.m_currentState) == nullptr &&
        Cast<FightState>(guard.fsm.m_currentState) == nullptr)
    {
        guard.fsm.ChangeState(AvoidDoorState());
        return true;
    }
    return false; 
}

class AvoidDoorState : BaseState
{
    AGuard guard;
    void Enter(AMessageCharacter actor) override
    {
        guard = Cast<AGuard>(actor);
        if(Cast<ChaseState>(guard.fsm.m_previousState) != nullptr)
        {
            guard.CharacterMovement.MaxWalkSpeed = guard.runningspeed;
            guard.isRunning = true;
        }
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {

    }

    void Exit(AMessageCharacter actor) override
    {
        guard.isRunning = false;
        guard.CharacterMovement.MaxWalkSpeed = guard.walkingSpeed;
    }

    void HeardSound(AMessageCharacter actor, FVector location) override
    {

    }

    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(guard);
    }

    void MoveCompleted(AMessageCharacter actor, EPathFollowingResult result) override
    {
        if (result == EPathFollowingResult::Aborted)
        {
            return;
        }
        guard.fsm.RevertToPreviousState();
    }
}