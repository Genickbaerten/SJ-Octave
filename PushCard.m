function [ Deck ] = PushCard( Deck, Card )
%Push a card onto the top of the Deck, return.
Deck{end+1} = Card;

end

