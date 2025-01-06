function sS=soundSpeed(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGrid,1),size(obj.gridSize));
else
    sS=obj.materialTable(obj.materialIDGrid,1);
end
end