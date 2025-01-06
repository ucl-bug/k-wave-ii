function sS=density(obj)
arguments
    obj
end
if ~isscalar(obj.densityPadded)
    V=obj.densityPadded;
    switch obj.kgrid.dimensions
        case 1
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1));
        case 2
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2));
        case 3
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2), obj.kgrid.gridPadding(3)+1:end-obj.kgrid.gridPadding(3));
    end
else
    sS=obj.densityPadded;
end