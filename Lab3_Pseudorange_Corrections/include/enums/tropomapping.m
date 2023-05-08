classdef tropomapping
    enumeration
        BlackAndEisner, Niell
    end
    
    methods
        function str_out = str(self)
            if self == tropomapping.BlackAndEisner
                str_out = 'BuE mapping';
            elseif self == tropomapping.Niell
                str_out = 'Niell mapping';
            else
                str_out = 'unknown mapping';
            end
        end
    end
end