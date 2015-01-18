require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'

helpers do

  def generate_deck
    deck = []
    suits = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
    value = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
    deck = value.product(suits).shuffle
  end

  def show_dealer_image(cards)
    '<img class="card" src="images/cardset/' + cards[1][0].downcase + "_of_" + cards[1][1].downcase + '.png">'
  end

  def show_all_image(hand)
    return_value = ""
    hand.each do |card|
      return_value += '<img class="card" src="images/cardset/' + card[0].downcase + "_of_" + card[1].downcase + '.png">'
    end
    return_value
  end

  def deal_card(hand, deck)
    hand << deck.pop
  end

  def calculate_value(hand)
    ace_num = hand.select { |card| card[0] == "Ace" }.length
    count = 0
    hand.each do |card|
      case
      when card[0] == 'Ace'
        count += 11
      when card[0] == 'Jack',
        card[0] == 'Queen',
        card[0] == 'King'
        count += 10
      else
        count += card[0].to_i
      end
    end
    ace_num.times do |correction|
      if count > 21
        count -= 10
      end
    end
    count
  end

  def win(msg)
    @play_again = true
    session[:player_pot] += session[:player_bet]
    @message = "#{msg} Hand <span class='highlight'>won</span> ($#{session[:player_bet]})."
  end

  def lose(msg)
    @play_again = true
    session[:player_pot] -= session[:player_bet]
    @message = "#{msg} Hand <span class='highlight'>lost</span> ($#{session[:player_bet]})."
  end

  def tie(msg)
    @play_again = true
    @message = "#{msg} Hand <span class='highlight'>pushed</span> ($#{session[:player_bet]})."
  end

  def game_engine
    if session[:player_turn]
      case
      when calculate_value(session[:player_hand]) == 21
        win("#{session[:player_name]} hits blackjack.")
      when calculate_value(session[:player_hand]) > 21
        lose("#{session[:player_name]} busted.")
      else
        @hit_or_stay = true
      end
    else
      if calculate_value(session[:dealer_hand]) >= 17
        case
        when calculate_value(session[:player_hand]) > calculate_value(session[:dealer_hand])
          win("#{session[:player_name]} beats dealer.")
        when calculate_value(session[:dealer_hand]) > 21
          win("Dealer busts.")
        when calculate_value(session[:dealer_hand]) <= 21 && calculate_value(session[:player_hand]) < calculate_value(session[:dealer_hand])
          lose("Dealer beats #{session[:player_name]}.")
        else
          tie("Dealer ties.")
        end
      elsif calculate_value(session[:dealer_hand]) < 17
        @dealer_hit = true
      end
    end
  end

end

get '/' do
  session[:player_name] = 'Player'
  session[:player_pot] = 0
  erb :index
end

post '/set_name' do
  session[:player_name] = 'Player'
  session[:player_pot] = 100
  if params[:player_name].empty?
    @error = "Please enter your name."
    halt erb(:index)
  else
    session[:player_name] = params[:player_name].capitalize
    redirect '/game'
  end
end

get '/game' do
  session[:deck] = generate_deck
  session[:game_over] = session[:player_pot] > 0 ? false : true
  session[:player_turn] = true
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:old_pot] = session[:player_pot]
  erb :game
end

post '/game' do
  if params[:player_bet].to_i == 0
    @error = "Bet cannot be zero."
    halt erb(:game)
  elsif params[:player_bet].to_i < 0
    @error = "Bet cannot be negative."
    halt erb(:game)
  elsif params[:player_bet].to_i > session[:player_pot]
    @error = "Bet cannot exceed $#{session[:player_pot]}."
    halt erb(:game)
  else
    session[:player_bet] = params[:player_bet].to_i
    redirect '/player_turn'
  end
end

get '/player_turn' do
  @play_again = false
  @hit_or_stay = false
  @dealer_hit = false
  @message = ''
  if session[:player_hand].empty?
    2.times { deal_card(session[:player_hand], session[:deck]) }
    2.times { deal_card(session[:dealer_hand], session[:deck]) }
  end
  game_engine
  erb :player_turn
end

get '/dealer_hit' do
  deal_card(session[:dealer_hand], session[:deck])
  game_engine
  erb :player_turn, layout: false
end

get '/bye' do
  erb :bye
end

get '/borrow' do
  session[:player_pot] = 100
  redirect '/game'
end

get '/hit' do
  deal_card(session[:player_hand], session[:deck])
  game_engine
  erb :player_turn, layout: false
end

get '/stay' do
  session[:player_turn] = false
  game_engine
  erb :player_turn, layout: false
end

get '/player_pot' do
  '<span id="pot">' + session[:player_pot].to_s + '</span>'
end






#
