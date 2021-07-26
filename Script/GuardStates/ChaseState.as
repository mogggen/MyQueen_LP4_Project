import Guard;
import StateMachineClass;
import void ChangeToInvestigatingState(AGuard guard) from "GuardStates.InvestigatingState";
import void ChangeToFightState(AGuard guard) from "GuardStates.FightState";
import PlayerCharacter;

void ChangeToChaseState(AGuard guard)
{
    guard.fsm.ChangeState(ChaseState());
}

class ChaseState : BaseState
{
    bool chasingPlayer = false;
    FVector prevLocation;

    void Enter(AMessageCharacter actor) override
    {
        // send message to tell player that it's being seen
        AGuard guard = Cast<AGuard>(actor);
        auto player = Cast<AMessageCharacter>(Gameplay::GetPlayerPawn(0));
        auto aPlayer =Cast<APlayerCharacter>(player);
        if (player == nullptr) return;
        guard.messageDispatcher.dispatchMessage(Telegram(guard, player, messegeEnum::isChasingPlayer, 0, "true"));

        // Plays a sound
        if(!aPlayer.voiceSystemComponent.isPlaying)
        {
            int x = FMath::RandRange(0, guard.screamingAtPlayerSounds.Num()-1);
            guard.screamingComponent.SetSound(guard.screamingAtPlayerSounds[x]);
            guard.screamingComponent.Play();
        }

        guard.CharacterMovement.MaxWalkSpeed = guard.runningspeed;
        chasingPlayer = true;
        guard.isRunning = true;
        guard.moveToActor();       
        prevLocation = guard.ActorLocation;
    }

    void Execute(AMessageCharacter actor, float DeltaSeconds) override
    {
        AGuard guard = Cast<AGuard>(actor);
        AActor playerPawn = Gameplay::GetPlayerPawn(0);

        if (guard.detectPlayerComponent.canSeePlayer)
        {
            if(!chasingPlayer)
            {
                chasingPlayer = true;
                guard.moveToActor();
            }

            if(prevLocation.Distance(guard.ActorLocation) < 0.01f)
                guard.moveToActor();
                 
            guard.playersLastKnownLocation = playerPawn.GetActorLocation();

            if (guard.GetActorLocation().DistXY(playerPawn.GetActorLocation()) < guard.attackRange * 0.6) // Maybe begin the attack while the guard is still running.
                ChangeToFightState(guard);
        }
        else if (guard.GetActorLocation().Dist2D(guard.playersLastKnownLocation) > 50.f && chasingPlayer)
        {
            chasingPlayer = false;
            guard.moveToLocation(guard.playersLastKnownLocation);
        }
        else if (guard.GetActorLocation().Dist2D(guard.playersLastKnownLocation) > 50.f)
        {
            guard.moveToLocation(guard.playersLastKnownLocation);
        }
        else
        {                
            ChangeToInvestigatingState(guard);
        }
        prevLocation = guard.ActorLocation;
    }

    void Exit(AMessageCharacter actor) override
    {
        // if !guard.detectPlayerComponent.canSeePlayer (changing to investigatingState),
        // send message to tell player that it's no longer being seen
        AGuard guard = Cast<AGuard>(actor);
        if(!guard.detectPlayerComponent.canSeePlayer) 
        {
            guard.messageDispatcher.dispatchMessage(Telegram(guard, Cast<AMessageCharacter>(Gameplay::GetPlayerPawn(0)), messegeEnum::isChasingPlayer, 0, "false"));
        }

        guard.isRunning = false;
        guard.CharacterMovement.MaxWalkSpeed = guard.walkingSpeed;

    }

    void Hurt(AMessageCharacter actor) override
    {
        ChangeToFightState(Cast<AGuard>(actor));
    }

    void MoveCompleted(AMessageCharacter actor, EPathFollowingResult result) override
    {
        
    }
}