
%{
L_Mean: retorns the average of a two dimensional matrix
@param mtrx: input matrix used to calculate mean
@return ret: the calculated mean of mtrx}
%}
function ret = L_Mean(mtrx)
    %ret = mean(mean(mtrx)
    count = size(mtrx, 1)*size(mtrx,2);
    ret = sum(sum(mtrx))/count;
end