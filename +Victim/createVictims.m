function victims = createVictims(victimNumber,initialPositionX, initialPositionY,color)
    import Victim.Victim;
    
    victims = [];
    
    for i=1:victimNumber
        victims = [victims Victim(initialPositionX,initialPositionY,i,color)];
    end
    
    
end

