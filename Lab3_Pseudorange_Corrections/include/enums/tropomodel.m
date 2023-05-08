classdef tropomodel
    enumeration
        None, Collins, IGS, Estimate
    end
    
    methods
        function str_out = str(self)
            if self == tropomodel.None
                str_out = 'No model';
            elseif self == tropomodel.Collins
                str_out = 'Collins';
            elseif self == tropomodel.IGS
                str_out = 'ZPD';
            elseif self == tropomodel.Estimate
                str_out = 'Estimation';
            else
                str_out = 'unknown model';
            end
        end
    end
end