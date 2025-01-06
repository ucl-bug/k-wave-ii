function sS=absorptionCoeffPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,3),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,3);
end
end