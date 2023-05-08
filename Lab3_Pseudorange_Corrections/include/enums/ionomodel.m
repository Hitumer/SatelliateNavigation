classdef ionomodel
    enumeration
        None, Klobuchar, GlobalMap, Estimation, IFCombination
    end
    
    methods
        function str_out = str(self)
            if self == ionomodel.None
                str_out = 'No model';
            elseif self == ionomodel.Klobuchar
                str_out = 'Klobuchar';
            elseif self == ionomodel.GlobalMap
                str_out = 'GIM';
            elseif self == ionomodel.Estimation
                str_out = 'Estimation';
            elseif self == ionomodel.IFCombination
                str_out = 'IF comb.';
            else
                str_out = 'unknown model';
            end
        end
    end
end