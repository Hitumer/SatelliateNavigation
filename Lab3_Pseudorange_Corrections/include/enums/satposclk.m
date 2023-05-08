classdef satposclk
    enumeration
        Broadcast, IGS
    end
    
    methods
        function str_out = str(self)
            if self == satposclk.Broadcast
                str_out = 'Broadcast';
            elseif self == satposclk.IGS
                str_out = 'SP3';
            else
                str_out = 'unknown sat. corrections';
            end
        end
    end
end