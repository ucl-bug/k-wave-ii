function sS=thermalConductivityPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,7),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,7);
end
end