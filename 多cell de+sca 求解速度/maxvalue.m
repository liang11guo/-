function [ value ] = maxvalue( fitvalue )
value=-inf;
for i=1:50
    if fitvalue(i)>value
        value=fitvalue(i);
    end
end


end

