function sS=absorptionPower(obj)
arguments
    obj
end
if ~isscalar(obj.materialIDGridPadded)

    disp('abosrptionPower value must be scalar, setting to averaged')
    V=obj.materialIDGridPadded;

    switch obj.kgrid.dimensions
        case 1
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1));
        case 2
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2));
        case 3
            V2=V(obj.kgrid.gridPadding(1)+1:end-obj.kgrid.gridPadding(1), obj.kgrid.gridPadding(2)+1:end-obj.kgrid.gridPadding(2), obj.kgrid.gridPadding(3)+1:end-obj.kgrid.gridPadding(3));
    end

    sS=mean(obj.materialTable(V2,4));

else
    sS=obj.materialTable(obj.materialIDGridPadded,4);
end