import Guard;
import StateMachineClass;
import void ChangeToChaseState(AGuard guard) from "GuardStates.ChaseState";
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";

void ChangeToFightState(AGuard guard)
{
    guard.fsm.ChangeState(FightState());
}

class FightState : BaseState
{
    private bool isTurning = false;
    
    void Enter(AMessageCharacter actor) override
    {
        AGuard guard = Cast<AGuard>(actor);
        guard.messageDispatcher.dispatchSoundMessage(Telegram(
                Cast<AMessageCharacter>(guard), //TODO (Morgan) Fix Type
                Cast<AMessageCharacter>(nullptr),
                messegeEnum::Attention,
                0,
                ""),
                1400.f);

        guard.isAttacking = true;
    }
    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        AGuard guard = Cast<AGuard>(actor);
        AActor playerPawn = Gameplay::GetPlayerPawn(0);
        if (Cast<AActor>(Gameplay::GetPlayerPawn(0)) == nullptr)
        {
            //Print("FightState, Execute: Player not Found!");
            //guard.fsm.ChangeState(ReturnToPostState());
            ChangeToChaseState(guard);
            guard.messageDispatcher.dispatchMessage(Telegram(guard, Cast<AMessageCharacter>(playerPawn), messegeEnum::hasSpottedPlayer, 0, "false"));
            return;
        }

        FVector guardPos  = guard.GetActorLocation();
        FVector playerPos = playerPawn.GetActorLocation();

        // Set playersLastKnownLocation while seeing player
        if(guard.detectPlayerComponent.canSeePlayer)
        {
            guard.playersLastKnownLocation = playerPos;
        }

        // Am I in attack range of the player.
        if ((playerPos - guardPos).Size() > guard.attackRange)
        {
            // Change to chase state
            //guard.fsm.ChangeState(ChaseState());
            ChangeToChaseState(guard);
            return;
        }


        // Do I need to rotate towards the player.
        if (isTurning)
        {
            // get how much there is left to rotate
            FVector GtoP = (playerPos - guardPos);
            GtoP.Z = 0.0f;
            GtoP.Normalize();

            FVector guardRight = guard.GetActorRightVector();
            FVector guardForward = guard.GetActorForwardVector();

            float dot = guardForward.DotProduct(GtoP);
            float angleToRotate = FMath::Acos(dot);

            // done rotating?
            if (dot >= 0.999f)
            {
                isTurning = false;
                guard.isTurning = false;
                return;
            }

            FRotator rotation = guard.GetActorRotation();

            if (guardRight.DotProduct(GtoP) > 0)
                rotation.Yaw += guard.attackRotationSpeed * (angleToRotate + 0.4f) * DeltaSeconds;
            else
                rotation.Yaw -= guard.attackRotationSpeed * (angleToRotate + 0.4f) * DeltaSeconds;

            guard.SetActorRotation(rotation, false);

            return;
        }
        else if (guard.GetDotProductTo(playerPawn) <= FMath::Cos(guard.attackArc * FMath::PI / 180))
        {
            isTurning = true;
            guard.isTurning = true;

            return;
        }

        

        // Is my attack on cooldown or I'm currently attacking.
        if (guard.currentAttackCooldown <= 0.0f)
        {
            // Moved to guard.DamagedPlayer() which is called when the sword hits the player
            
            guard.currentAttackCooldown = guard.attackCooldown;
        }

    }
    void Exit(AMessageCharacter actor) override
    {
        AGuard guard = Cast<AGuard>(actor);
        guard.isAttacking = false;
    }
    
    void HeardSound(AMessageCharacter actor, FVector location) override
    {
    }
}