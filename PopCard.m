function [ Card, Deck ] = PopCard( Deck, Position )
%Pop top card off deck, return.

if nargin < 2 || isempty(Position) || Position < 1 || Position < length(Deck)
    Position = length(Deck);
end
    
Card = Deck{Position};
Ncards = length(Deck)-1;
NewDeck = cell(1,Ncards);
for card = 1:Position-1
    NewDeck{card} = Deck{card};
end
for card = Position+1:length(Deck)
    NewDeck{card} = Deck{card};
end

Deck = NewDeck;

