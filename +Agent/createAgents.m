function agents = createAgents(agentNumber,initialPosition,color)
    import Agent.Agent;
    agents = [];
    for i=1:agentNumber
        agents = [agents Agent(initialPosition,i,color)];
    end
end

