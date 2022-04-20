  function [values, prob] = getProbabilities(X, keyType, keyAccessCallback)
            dict = containers.Map('KeyType',keyType,'ValueType','double');
            for i=1:length(X)
                key = keyAccessCallback(X,i);
                if(isKey(dict,key))
                    dict(key) = dict(key) + 1;
                else
                    dict(key) = 1.0;
                end
            end
            prob = cell2mat(dict.values);
            prob = prob/sum(prob);
            [prob, indexes] = sort(prob,'descend');
            keys = dict.keys;
            values = keys(indexes);
        end