import PurpleQueen;
import StateMachineClass;

void ChangeToIdleState(APurpuleQueen queen)
{
    queen.fsm.ChangeState(QIdleState());
}

class QIdleState : BaseState
{
    APurpuleQueen queen;
    APawn player;

    void Enter(AMessageCharacter actor) override
    {
        queen = Cast<APurpuleQueen>(actor);
        player = Gameplay::GetPlayerPawn(0);
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        // isTurning becomes true when queen.lookAtPlayer() is called
        if(queen.isTurning)
        {
            if(queen.turn(player, DeltaSeconds)){
                queen.isTurning = false;
                queen.isTurningLeft = false;
                queen.isTurningRight = false;
            }
        }
        else
            queen.turn(player, DeltaSeconds);
    }

    void Exit(AMessageCharacter actor) override
    {
        queen.isTurning = false;
        queen.isTurningLeft = false;
        queen.isTurningRight = false;
    }
}