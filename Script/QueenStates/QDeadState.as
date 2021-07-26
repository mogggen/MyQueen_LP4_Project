import PurpleQueen;
import StateMachineClass;

void ChangeToDeadState(APurpuleQueen queen)
{
    queen.fsm.ChangeState(QDeadState());
}

class QDeadState : BaseState
{
    APurpuleQueen queen;
    void Enter(AMessageCharacter actor) override
    {
        queen = Cast<APurpuleQueen>(actor);
        queen.isDying = true;
    }
}