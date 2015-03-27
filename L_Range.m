%{
@LRange: returns the range of a two dimensional matrix
@Param mtrx: matrix to take range from
@return r: the range of the values in mtrx
%}
function r = L_Range(mtrx)

    %attempt to use built in min and max to quickly find range
    try
        r = abs(max(max(mtrx)) - min(min(mtrx)));
    %if min or max throws an error calculate min and max of matrix and use
    %to find range
    catch
        L_max = mtrx(1);
        L_min = mtrx(1);
        
        %find the smallest and largest value of matrix
        for row = 1:size(mtrx,1);
            for col = 1:size(mtrx, 2);
                if mtrx(row, col) > L_max
                    L_max = mtrx(row, col);
                elseif mtrx(row, col) < L_min
                    L_min = mtrx(row, col);
                end
            end
        end
        
        %inform user that an error occurred
        fprintf('Error finding min or max. Using L_min and L_max instead \n');
        r = abs(L_max - L_min);
    end 
end