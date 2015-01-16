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
    '<img src="images/cards/' + cards[1][1].downcase + "_" + cards[1][0].downcase + '.jpg">'
  end

  def show_one_image(card)
    '<img src="images/cards/' + card[1].downcase + "_" + card[0].downcase + '.jpg">'
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

end

get '/' do
  erb :index
end

post '/set_name' do
  session[:player_name] = params[:player_name].capitalize
  session[:player_pot] = 100
  redirect '/game'
end

get '/game' do
  session[:deck] = generate_deck
  # session[:stay] = false
  session[:player_hand] = []
  session[:dealer_hand] = []
  erb :game
end

post '/game' do
  if params[:player_bet].to_i == 0
    @error = "You cannot bet that amount!"
    halt erb(:game)
  elsif params[:player_bet].to_i > session[:player_pot]
    @error = "You cannot bet more than how much you have!"
    halt erb(:game)
  else
    session[:player_bet] = params[:player_bet].to_i
    redirect '/player_turn'
  end
end

get '/player_turn' do
  if session[:player_hand].empty?
    2.times { deal_card(session[:player_hand], session[:deck]) }
    begin
      deal_card(session[:dealer_hand], session[:deck])
    end until calculate_value(session[:dealer_hand]) > 17
  end
  erb :player_turn
end

get '/bye' do
  erb :bye
end

post '/borrow' do
  session[:player_pot] = 100
  redirect '/game'
end

get '/hit' do
  deal_card(session[:player_hand], session[:deck])
  redirect '/player_turn'
end

get '/stay' do
  erb :stay
end








#
