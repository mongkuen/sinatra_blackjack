require 'rubygems'
require 'sinatra'
require 'pry'

# set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'

helpers do

  def generate_deck
    deck = []
    suits = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
    value = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
    deck = value.product(suits)
  end

  def shuffle!(deck)
    deck.shuffle!
  end

  def prettify(card)
    "#{card[0]} of #{card[1]}"
  end

  def show_cards(cards)
    string = ''
    cards.each do |card|
      string += " #{card[0]} of #{card[1]} ||"
    end
    string
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
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = generate_deck
  session[:player_hand] = []
  session[:dealer_hand] = []
  erb :game
end

get '/shuffle' do
  shuffle!(session[:deck])
  erb :shuffle
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

get '/hit' do
  deal_card(session[:player_hand], session[:deck])
  redirect '/player_turn'
end

get '/stay' do
  erb :stay
end










#
