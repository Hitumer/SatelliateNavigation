classdef ionomapping
    enumeration
        SLM
    end
    
    methods
        function str_out = str(self)
            if self == ionomapping.SLM
                str_out = 'SLM mapping';
            else
                str_out = 'unknown mapping';
            end
        end
    end
end