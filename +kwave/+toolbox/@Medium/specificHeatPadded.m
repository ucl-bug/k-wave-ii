function sS=specificHeatPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,6),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,6);
end
end