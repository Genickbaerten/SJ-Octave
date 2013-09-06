function [ Attribute ] = GetAttribute( Cards, Name, AttributeIndex )
%Look up the AttributeIndex from Cards matching the desired Name

Attribute = Cards{AttributeIndex}(find(strcmpi(Cards{1}, Name)));
end

