require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_STAYS = 17
INTIAL_POT = 500

helpers do
  def calculate_total(cards)
    total = 0
    arr = cards.map { |element| element[1]}

    arr.each do |value|
      if value == "A"
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end
    
    arr.select{|value| value == "A"}.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end

  def card_image(card)
    suit = case card[0]
      when 'C' then 'clubs'
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'S' then 'spades'
    end
    
    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_images'>"
  end

  def winner!(msg)
    @success = "#{session[:player_name]} won! #{msg}"
    @show_hit_and_stay_buttons = false
    @show_play_again = true
    session[:player_pot] += session[:player_bet].to_i
  end

  def loser!(msg)
    @error = "Dealer won. #{msg}"
    @show_hit_and_stay_buttons = false
    @show_play_again = true
    session[:player_pot] -= session[:player_bet].to_i
  end

  def tie!
    @success = "It's a Draw at #{calculate_total(session[:players_cards])}."
    @show_hit_and_stay_buttons = false
    @show_play_again = true
  end
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else9mmm
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = INTIAL_POT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required."
    halt(erb :new_player)
  end
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

before do
  @show_hit_and_stay_buttons = true
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if params[:player_bet].nil? || params[:player_bet].to_i == 0
    @error = "You must make a bet."
    halt(erb :bet)
  elsif params[:player_bet].to_i > session[:player_pot]
    @error = "You can only bet as much as you have."
    halt(erb :bet)
  else
    session[:player_bet] = params[:player_bet].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['C', 'D', 'H', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!
  session[:players_cards] = []
  session[:dealers_cards] = []
  session[:players_cards] << session[:deck].pop
  session[:dealers_cards] << session[:deck].pop
  session[:players_cards] << session[:deck].pop
  session[:dealers_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:players_cards] << session[:deck].pop
  if calculate_total(session[:players_cards]) == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit Blackjack.")
  elsif calculate_total(session[:players_cards]) > BLACKJACK_AMOUNT
    loser!("Busted at #{calculate_total(session[:players_cards])}")
  end

  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_and_stay_buttons = false
  redirect '/game/dealer' 
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_and_stay_buttons = false

  dealer_total = calculate_total(session[:dealers_cards])
  if dealer_total == BLACKJACK_AMOUNT
    redirect '/game/compare'
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{calculate_total(session[:dealers_cards])}")
  elsif dealer_total >= DEALER_STAYS
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
     
  erb :game 
    
end

post '/game/dealer/hit' do
  session[:dealers_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_and_stay_buttons = false
  player_total = calculate_total(session[:players_cards])
  dealer_total = calculate_total(session[:dealers_cards])

  if dealer_total > player_total
    loser!("Dealer has #{calculate_total(session[:dealers_cards])} vs #{session[:player_name]}'s total of #{calculate_total(session[:players_cards])}")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} has #{calculate_total(session[:players_cards])} vs Dealer's total of #{calculate_total(session[:dealers_cards])}")
  else
    tie!
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end













