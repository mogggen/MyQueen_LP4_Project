import messagingSystem;

class stateMachine
{
    UPROPERTY()
    AMessageCharacter m_pOwner;
    
    UPROPERTY()
    BaseState m_currentState = nullptr;
    
    UPROPERTY()
    BaseState m_previousState = nullptr;

    stateMachine(AMessageCharacter p_Owner)
    {
        m_pOwner = p_Owner;
    }

    void Update(float DeltaSeconds) const
    {
        if(m_currentState != nullptr)
            m_currentState.Execute(m_pOwner, DeltaSeconds);
    }

    void ChangeState(BaseState newState)
    {
        ensure(newState != nullptr);
        
        m_previousState = m_currentState;

        if (m_currentState != nullptr)
            m_currentState.Exit(m_pOwner);

        m_currentState = newState;
        m_currentState.Enter(m_pOwner);
    }

    void RevertToPreviousState()
    {
        ChangeState(m_previousState);
    }

    void MoveComplete(AMessageCharacter actor, EPathFollowingResult result)
    {
        m_currentState.MoveCompleted(actor, result);
    }
    void HeardSound(AMessageCharacter actor, FVector location)
    {
        m_currentState.HeardSound(actor, location);
    }
    void Hurt(AMessageCharacter actor)
    {
        m_currentState.Hurt(actor);
    }
    void GoToPreviousState(AMessageCharacter actor)
    {
        m_currentState.GoToPreviousState(actor);
    }
    void startTappingFoot(AMessageCharacter actor)
    {
        m_currentState.startTappingFoot(actor);
    }
    void endTappingFoot(AMessageCharacter actor)
    {
        m_currentState.endTappingFoot(actor);
    }

}

class BaseState
{
    void Enter(AMessageCharacter actor)   {}
    void Execute(AMessageCharacter actor, float DeltaSeconds) {}
    void Exit(AMessageCharacter actor)    {}

    void MoveCompleted(AMessageCharacter actor, EPathFollowingResult result) {}
    void HeardSound(AMessageCharacter actor, FVector location)    {}
    void Hurt(AMessageCharacter actor) {}
    // is only used in and called by BP_Door blueprint and OpenDoorState
    void GoToPreviousState(AMessageCharacter actor) {}
    // is only used in and called by AGuard and StandGuardState
    void startTappingFoot(AMessageCharacter actor) {}
    void endTappingFoot(AMessageCharacter actor) {}
}