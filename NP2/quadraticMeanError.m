function err = quadraticMeanError(A,B)
    arguments
        A (:,:) {mustBeNumeric, mustBeFinite}
        B (:,:) {mustBeNumeric, mustBeFinite, mustBeEqualSize(B,A)}
    end
    diff = (double(A) - double(B)).^2;
    err = sum(sum(diff))/numel(A);
end

function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = 'Inputs must have equal size.';
        throwAsCaller(MException(eid,msg))
    end
end