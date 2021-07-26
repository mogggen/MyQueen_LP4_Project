import Telegram;

class AMessageDispatcher: AActor
{
    TArray<Telegram> PriorityQ;
    UPROPERTY()
    ETraceTypeQuery traceChannel;

    UFUNCTION()
    void discharge(AMessageCharacter reciver, Telegram msg){
        reciver.handleMessage(msg);
    }
    
    AMessageDispatcher()
    {
    }
   
   //AMessageDispatcher instance = AMessageDispatcher();
    

    UFUNCTION()
    void dispatchMessage(Telegram message)
    {
       Telegram msg = message;
       if( msg.dispatchTime <= 0.0 ){
           this.discharge(msg.reciver, message);
       }
       else{
            float currentTime = GetCurrentWorld().GetRealTimeSeconds();
            msg.dispatchTime = msg.dispatchTime + currentTime;
           
           PriorityQ.Add(message);
       }
    }
    UFUNCTION()
    void dispatchDeleyedMessages()
    {
        float currentTime = GetCurrentWorld().GetRealTimeSeconds();
        int n = 0;
        if (PriorityQ.Num() > 0)
        {
            while(PriorityQ[0].dispatchTime < currentTime ){
                this.discharge(PriorityQ[0].reciver, PriorityQ[0]);

                PriorityQ.RemoveAt(n);
                if (PriorityQ.Num() <= 0){ break; }
            }
        }
    }
    UFUNCTION()
    void dispatchMessageWithinRadius(Telegram message, float radius){
        TArray<AMessageCharacter> guards;
        GetAllActorsOfClass(guards);

        Telegram temp = message;

       for(int i = 0; i < guards.Num(); i++)
       {
            if (message.sender == guards[i]) continue;
            if(message.sender.ActorLocation.Distance(guards[i].ActorLocation)<= radius)
            {
                temp.reciver = guards[i];
                dispatchMessage(temp);
            }
       }
    }

    UFUNCTION()
    void dispatchSoundMessage(Telegram message, float radius)
    {
        TArray<AMessageCharacter> guards;
        GetAllActorsOfClass(guards);

        TArray<AActor> ignore;
        ignore.Add(nullptr);

        Telegram temp = message;

        float radiusWhenVisible = radius;
        float radiusThrouWalls = 0.33 * radius;

        for(int i = 0; i < guards.Num(); i++)
        {
            if (message.sender == guards[i]) continue;

            float zDistance = FMath::Abs(message.sender.ActorLocation.Z - guards[i].ActorLocation.Z);
            if(zDistance > 100.0f) continue;

            float distance = message.sender.ActorLocation.Distance(guards[i].ActorLocation);

            if(distance  <= radiusThrouWalls)
            {
                temp.reciver = guards[i];
                dispatchMessage(temp);
            }
            else if (distance <= radiusWhenVisible)
            {
                FHitResult hitResult;
                ignore[0] = guards[i];
                bool hit = System::LineTraceSingle(
                    message.sender.ActorLocation, 
                    guards[i].ActorLocation,
                    traceChannel,
                    false,
                    ignore,
                    EDrawDebugTrace::None,
                    hitResult,
                    true);

                if (hit)
                    continue;

                temp.reciver = guards[i];
                dispatchMessage(temp);
            }
        }
    }
}


