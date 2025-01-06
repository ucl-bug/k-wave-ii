function sS=absorptionCoeff(obj)
arguments
    obj
end
if ~isscalar(obj.absorptionCoeffPadded)
    V=obj.absorptionCoeffPadded;
    switch obj.kgrid.dimensions
        case 1
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1));
        case 2
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2));
        case 3
            sS=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2), obj.kgrid.gridPadding(3)+1:end-obj.kgrid.gridPadding(3));
    end
else
    sS=obj.absorptionCoeffPadded;
end