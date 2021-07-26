import OutlineComponent;

class AStoonePile : AActor 
{
    UPROPERTY(DefaultComponent)
    UOutlineComponent outlineComponent;

    int stooneInPile = 10;

    void pickedUp()
    {
        DestroyActor();
    }
}