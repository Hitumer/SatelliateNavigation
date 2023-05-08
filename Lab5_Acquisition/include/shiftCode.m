function code = shiftCode( code, offset )
% Performs a cyclic shift of a given code
% 
% Inputs:
% code: The code to be shifted
% offset: The number of samples to shift the code

offset = round(length(code)-mod(offset,length(code)));

if size(code,1)>size(code,2)
    code = [code(offset+1:end);code(1:offset)];
else
    code = [code(offset+1:end),code(1:offset)];
end