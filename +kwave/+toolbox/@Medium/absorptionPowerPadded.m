function sS=absorptionPowerPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    disp('Value must be scalar, setting to averaged')
    sS=mean(obj.materialTable(obj.materialIDGridPadded,4));
else
    sS=obj.materialTable(obj.materialIDGridPadded,4);
end
end