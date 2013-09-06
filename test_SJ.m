%SJ
clear all
close all

Nplayers = 3;
governor = ceil(rand*Nplayers)

%Data stored in space deliminted columns:
%column 1:  name(string)
%column 2:  number in deck (int)
%column 3:  cost (int)
%column 4:  victory points (int)
%column 5:  isPurple (logical) (0 = production, 1 = purple, 2 = ornamental)
fid = fopen('SJ_data.txt')
card_data = textscan(fid,'%s%d%d%d%d')
fclose(fid);

%Take out one indigo per player
card_data{2}(1) = card_data{2}(1) - Nplayers
bounds = cumsum(card_data{2});
deck_size = bounds(end);

draw_deck = cell(1,deck_size);
discard_deck = {};

shuffle = randperm(deck_size);
role_names = {'Builder','Councillor','Producer','Prospector','Trader'};

for card = 1:deck_size
    card_index = first(find(card <= bounds));
    draw_deck{shuffle(card)} = card_data{1}{card_index};
end

player_boards = cell(1,Nplayers);
player_cards = cell(1,Nplayers);
chapel_cards = cell(1,Nplayers);
goods_stored = cell(1,Nplayers);
victory_points = ones(1,Nplayers);

for player = 1:Nplayers
    player_boards{player} = PushCard(player_boards{player},card_data{1}{1});
    [draw_deck,player_cards{player}] = TakeNCards(draw_deck,player_cards{player},4);
end

%Nbuildings = sum(~cellfun(@isempty,player_boards))
Nbuildings = cellfun(@length,player_boards)
Ncards = cellfun(@length,player_cards)
Npurple = zeros(1,Nplayers);
Nornamental = zeros(1,Nplayers);

HasPalace = zeros(1,Nplayers)

done = 0;
round = 0;
while ~done
    round = round + 1
    %check and see if anyone has too many cards, and reminder of the chapel
    for player = 1:Nplayers
        %Reminder of the chapel
        %check if they have a Chapel
        if sum(strcmpi(player_boards{:,player},'Chapel'))
            %Bury a card, if available
            if Ncards(player) > 0
                IndToBury = last(randperm(Ncards(player)));    
                [CardToBury,player_cards{player}] = PopCard(player_cards{player},IndToBury);
                chapel_cards{player} = PushCard(chapel_cards{player},CardToBury)
                victory_points(player) = victory_points(player) + 1;
                fprintf('round %d, player %d is adding card %s to their chapel',round,player,chapel_cards{player}{end});
            end
        end
        %check if they have Tower
        if sum(strcmpi(player_boards{:,player},'Tower'))
            MaxCards = 12;
        else
            MaxCards = 7;
        end
        NumExtra = Ncards(player) - MaxCards;
        if NumExtra > 0
            %Pick at random
            IndsToDiscard = last(randperm(Ncards(player)),NumExtra);
            [player_cards{player},discard_deck,] = TakeNCards(player_cards{player},discard_deck,IndsToDiscard);
        end
    end
    Nchapel = cellfun(@length,chapel_cards)
    Ncards = cellfun(@length,player_cards)
    %test just with builder role
    for player_index = 1:Nplayers
        player = modint(player_index+governor-1, Nplayers)
        
        %Code in properly later
        if player_index == 1
            BuildModifier = 1;
        else
            BuildModifier = 0;
        end
        
        %Take the top 2 cards from draw_deck,
        [draw_deck,player_cards{player}] = TakeNCards(draw_deck,player_cards{player},2);
                
        %pick a card at random to build
        ValidBuild = zeros(1,Ncards(player));
        BuildCost = zeros(1,Ncards(player));
        IsPurple = zeros(1,Ncards(player));
        for card = 1:Ncards(player)
            BuildCost(card) = GetAttribute(card_data,player_cards{player}{card},3)-BuildModifier;
            NumBuilt = sum(strcmpi(player_boards{player},player_cards{player}{card}));
            IsPurple(card) = (GetAttribute(card_data,player_cards{player}{card},5) > 0);
            if BuildCost(card) <= (Ncards(player)-1) && (~IsPurple(card) || (IsPurple(card) && NumBuilt == 0))
                ValidBuild(card) = 1;
            end
        end
        Nvalid = sum(ValidBuild);
        if Nvalid > 0
            %Pick a valid build at random
            ValidInds = find(ValidBuild);
            IndToBuild = ValidInds(first(randperm(Nvalid)));
            [CardToBuild,player_cards{player}] = PopCard(player_cards{player},IndToBuild);
            
            %Put in in the players board
            player_boards{player} = PushCard(player_boards{player},CardToBuild);
            
            %Update Victory Points
            starting_div4 = floor(victory_points(player)/4);
            victory_points(player) = victory_points(player) + GetAttribute(card_data,CardToBuild,4);
            Npurple(player) = Npurple(player) + (GetAttribute(card_data,CardToBuild,5) > 0);
            Nornamental(player) = Nornamental(player) + (GetAttribute(card_data,CardToBuild,5) == 2);
            
                        
            if strcmpi(CardToBuild,'City_Hall')
                %Add 1 VP per existing Purple Building
                victory_points(player) = victory_points(player) + Npurple(player);
            else
                %Add 1 VP if HasCityHall and IsPurple
                victory_points(player) = victory_points(player) + sum(strcmpi(player_boards{player},'City_Hall'))*IsPurple(IndToBuild);
            end
            
            if strcmpi(CardToBuild,'Guild_Hall')
                %Add 2 VP per existing Production Building
                Nproduction = Nbuildings(player)+1-Npurple(player);
                victory_points(player) = victory_points(player) + 2*Nproduction;
            else
                %Add 2 VP if HasGuildHall and ~IsPurple
                %victory_points(player) = victory_points(player) + 2*sum(strcmpi(player_boards{player},'Guild_Hall'))*(GetAttribute(card_data,CardToBuild,5) == 0);
                victory_points(player) = victory_points(player) + 2*sum(strcmpi(player_boards{player},'Guild_Hall'))*~IsPurple(IndToBuild);
            end
                            
            %Add 2*(Normamental+1) VP if building TriumphalArch
            if strcmpi(CardToBuild,'Triumphal_Arch')
                victory_points(player) = victory_points(player) + 2*(Nornamental(player)+1);
            end
            
            if Nornamental(player) == 1
                %Add 4 VP if HasTriumphalArch and building first
                %ornament
                victory_points(player) = victory_points(player) + 4*sum(strcmpi(player_boards{player},'Triumphal_Arch'))*(GetAttribute(card_data,CardToBuild,5) == 2);
            else
                %Add 2 VP if HasTriumphalArch if building additional
                %ornaments
                victory_points(player) = victory_points(player) + 2*sum(strcmpi(player_boards{player},'Triumphal_Arch'))*(GetAttribute(card_data,CardToBuild,5) == 2);
            end
            
            if strcmpi(CardToBuild,'Palace')
                HasPalace(player) = 1;
%                 %Add floor(victory_points/4) for a new Palace
%                 victory_points(player) = victory_points(player) + floor(victory_points(player)/4);
%             elseif sum(strcmpi(player_boards{player},'Palace'))
%                 %Add additional points for the delta in score
%                 victory_points(player) = victory_points(player) + floor(victory_points(player)/4) - starting_div4
             end
            
            
            %pick the oldest cards to discard
            IndsToDiscard = BuildCost(IndToBuild);
            [player_cards{player},discard_deck] = TakeNCards(player_cards{player},discard_deck,IndsToDiscard);
        end
        
    end
    
    %Update Card Count
    Ncards = cellfun(@length,player_cards)
    
    %check at end of builder phase if we are done
    Nbuildings = cellfun(@length,player_boards)
    if max(Nbuildings) == 12
        done = 1;
    end
    %increment the governor
    governor = modint(governor+1,Nplayers);

end



%Base Score
Score = victory_points + floor(HasPalace.*victory_points/4);

%Number of cards and goods for tie-breakers
Ncards = cellfun(@length,player_cards)
Ngoods = cellfun(@length,goods_stored)

