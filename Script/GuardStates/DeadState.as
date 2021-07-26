import Guard;
import StateMachineClass;

void ChangeToDeadState(AGuard guard)
{
    guard.fsm.ChangeState(DeadState());
}

class DeadState : BaseState
{
    void Enter(AMessageCharacter actor) override
    {
        AGuard guard = Cast<AGuard>(actor);
        // use for fun
        /* auto rot = guard.GetActorRotation();
        rot.Pitch += 90;
        guard.SetActorRotation(rot); */
        guard.isDying = true;
        guard.healthBarVisible = false;
    }
}