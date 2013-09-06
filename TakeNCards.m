function [ draw_deck, hand, num_remaining ] = TakeNCards( draw_deck, hand, Ncards )
%Draw Ncards from the draw_deck into the hand
%if there are not enough cards to draw, num_remaining indicates how many
%more to draw in a subsequent call (e.g. after reshuffling the discard deck).

Nhand = length(hand);
Ndeck = length(draw_deck);

if length(Ncards == 1)
    NCardsToTake = Ncards;
    TakeFromTop = 1;
else
    NCardsToTake = length(Ncards);
    TakeFromTop = 0;
end

if Ncards > Ndeck
    num_remaining = NCardsToTake - Ndeck;
    Ncards = Ndeck;
else
    num_remaining = 0;
end



for card = 1:Ncards
    if TakeFromTop
        [NewCard, draw_deck] = PopCard(draw_deck);
    else
        [NewCard, draw_deck] = PopCard(draw_deck,Ncards(card));
    end
    hand = PushCard(hand,NewCard);
end
end
