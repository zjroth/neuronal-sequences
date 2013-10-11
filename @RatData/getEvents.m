% mtxEvents = getEvents(this)
function [mtxEvents, vPreCounts, vMuscCounts, vPostCounts] = getEvents(this)
    [mtxPreEvents, nR, nW, nPF] = getEvents(this.pre);
    vPreCounts = [nR, nW, nPF];

    [mtxMuscEvents, nR, nW, nPF] = getEvents(this.pre);
    vMuscCounts = [nR, nW, nPF];

    [mtxPostEvents, nR, nW, nPF] = getEvents(this.pre);
    vPostCounts = [nR, nW, nPF];

    mtxEvents = [ getEvents(this.pre);  ...
                  getEvents(this.musc); ...
                  getEvents(this.post)  ...
                ];
end
