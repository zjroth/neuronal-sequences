function mtxMu = computeMu(mtxM, vN)
    mtxDenoms = vN(:) * vN(:)';
    mtxDenomsNonZero = sparse(mtxDenoms ~= 0);
    mtxMu = zeros(size(mtxM));
    mtxMu(mtxDenomsNonZero) = (mtxM(mtxDenomsNonZero) ./ ...
        mtxDenoms(mtxDenomsNonZero)) - 0.5;
    mtxMu = sparse(mtxMu);
end