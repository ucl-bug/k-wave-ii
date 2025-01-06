function sS=densityPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,2),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,2);
end
end