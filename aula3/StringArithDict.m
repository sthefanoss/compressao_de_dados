classdef StringArithDict
    properties
        alphabet char;
        frequencies;
        accumulated_frequencies;
        chars = '0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^-`abcdefghijklmnopqrstuvwxyz{|}~ ';
    end
    methods
        function obj = StringArithDict(alphabet, frequencies)
            arguments
                alphabet char
                frequencies {mustBeNumeric,mustBeReal}
            end
            obj.alphabet = alphabet;
            obj.frequencies = vpa(frequencies/sum(frequencies),100);
            obj.accumulated_frequencies = obj.frequencies(1);
            for i=2:length(frequencies)
                obj.accumulated_frequencies(i) = vpa(obj.frequencies(i) + obj.accumulated_frequencies(i-1),100);
            end
        end
        function [m, inf,sup] = encode(obj, data)
            arguments
                obj StringArithDict
                data char
            end
            inf = 0;
            l = 1;
            for i=1:length(data)
                [inf_data,sup_data] = obj.getRange(data(i));
                sup = vpa(inf + l*sup_data,100);
                inf = vpa(inf + l*inf_data,100);
                l = vpa(sup - inf,100);
            end
            m = vpa((sup+inf)/2,2);
        end
        function [inf,sup] = getRange(obj, c)
            arguments
                obj StringArithDict
                c char
            end
            for i=1:length(obj.alphabet)
                if(c == obj.alphabet(i))
                    sup = obj.accumulated_frequencies(i);
                    if(i==1)
                        inf = 0;
                    else
                        inf = obj.accumulated_frequencies(i-1);
                    end
                end
            end
        end
        function data = decode(obj,scalar,length)
            arguments
                obj StringArithDict
                scalar
                length int32
            end
            for i=1:length
                [c,inf,sup] = obj.getValue(scalar);
                scalar = vpa((scalar-inf)/(sup-inf), 100);
                data(i) = c;
            end
        end
        function [c, inf, sup] = getValue(obj, singleValue)
            index = find(singleValue <= obj.accumulated_frequencies, 1);
            c = obj.alphabet(index);
            sup = obj.accumulated_frequencies(index);
            if(index == 1)
                inf = 0;
            else
                inf = obj.accumulated_frequencies(index-1);
            end
        end
    end
end
