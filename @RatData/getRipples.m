% mtxRipples = getRipples(this, vRippleNums)
function mtxRipples = getRipples(this, vRippleNums)
    % If specific ripple numbers were requested, we must be careful about
    % where those ripples belong (pre/musc/post)...
    if nargin == 2
        nPre = getRippleCount(this.pre);
        nMusc = getRippleCount(this.musc);
        nPost = getRippleCount(this.post);

        % Find vectors containing the indices of the ripple numbers that
        % correspond to pre/musc/post ripple numbers.
        vPre = (vRippleNums <= nPre);
        vMusc = (vRippleNums <= nPre + nMusc) & ~vPre;
        vPost = find(~(vPre | vMusc));
        vMusc = find(vMusc);
        vPre = find(vPre);

        % Retrieve the ripples for each group and concatenate them.
        mtxRipples = [ getRipples(this.pre, vPre); ...
                       getRipples(this.musc, vMusc - nPre); ...
                       getRipples(this.post, vPost - (nPre + nMusc)) ...
                     ];

        % Since the current matrix of ripples is sorted by groups
        % (pre/musc/post), we must sort the ripples into the requested order.
        [~, vOrder] = sort([vPre, vMusc, vPost]);
        mtxRipples = mtxRipples(vOrder, :);
    else
        % ...otherwise, we can just retrieve all ripples from each section.
        mtxRipples = [ getRipples(this.pre); ...
                       getRipples(this.musc); ...
                       getRipples(this.post) ...
                     ];
    end
end
