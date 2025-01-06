function sS=soundSpeedPadded(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)
    sS=reshape(obj.materialTable(obj.materialIDGridPadded,1),size(obj.materialIDGridPadded));
else
    sS=obj.materialTable(obj.materialIDGridPadded,1);
end
end
