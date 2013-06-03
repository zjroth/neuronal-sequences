% function U = unity(A)
% A is n x m  matrix, and each column is a signal.
% the function gives a unity signal for each column
% i.e. [signal-mean(signal)] / std(signal)
function U = unity(A,exclude)
    meanA = mean(A);
    if nargin>1;
        ii_ok = ones(size(A));
        for ii = 1:size(exclude,1)
            ii_ok(exclude(ii,1):exclude(ii,2)) = 0;
        end
        %     stdA = std(A(find(ii_ok)));
        stdA = median(abs(A(find(ii_ok)))/sqrt(2)/0.6745);
    else
        %     stdA = std(A);
        stdA = median(abs(A)/sqrt(2)/0.6745);
    end

    U = (A - repmat(meanA,size(A,1),1))./repmat(stdA,size(A,1),1);
end