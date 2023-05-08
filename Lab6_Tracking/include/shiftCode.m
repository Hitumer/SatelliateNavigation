% code = shiftCode( code, offset )
% 
% performs a cyclic shift of a given code
% 
% code......the code to be shifted
% offset....the number of samples to be shifted
function code = shiftCode( code, offset )

offset = round(length(code)-mod(offset,length(code)));

if size(code,1)>size(code,2)
    code = [code(offset+1:end);code(1:offset)];
else
    code = [code(offset+1:end),code(1:offset)];
end