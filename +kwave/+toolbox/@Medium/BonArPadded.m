function sS=BonAPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,5),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,5);
end
end