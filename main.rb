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

  def show_all_image(hand)
    return_value = ""
    hand.each do |card|
      return_value += '<img src="images/cards/' + card[1].downcase + "_" + card[0].downcase + '.jpg">'
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
    @message = "#{msg} #{session[:player_name]} wins!"
  end

  def lose(msg)
    @play_again = true
    session[:player_pot] -= session[:player_bet]
    @message = "#{msg} #{session[:player_name]} loses."
  end

  def tie(msg)
    @play_again = true
    @message = "#{msg} It's a tie."
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
  session[:game_over] = session[:player_pot] > 0 ? false : true
  session[:player_turn] = true
  session[:player_hand] = []
  session[:dealer_hand] = []
  session[:old_pot] = session[:player_pot]
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
  @play_again = false
  @hit_or_stay = false
  @dealer_hit = false
  @message = ''
  if session[:player_hand].empty?
    2.times { deal_card(session[:player_hand], session[:deck]) }
    2.times { deal_card(session[:dealer_hand], session[:deck]) }
  end
  if session[:player_turn]
    case
    when calculate_value(session[:player_hand]) == 21
      #"blackjack" win msg + add_pot + play_again + show_updated_pot
      win("#{session[:player_name]} hit blackjack!")
    when calculate_value(session[:player_hand]) > 21
      #"bust" lose msg + minus_pot + play_again + show_updated_pot
      lose("#{session[:player_name]} has busted...")
    else
      #hit_or_stay buttons
      @hit_or_stay = true
    end
  else
    if calculate_value(session[:dealer_hand]) >= 17
      case
      when calculate_value(session[:player_hand]) > calculate_value(session[:dealer_hand])
        #"Higher value" win msg + add_pot + play_again + show_updated_pot
        win("#{session[:player_name]} has a greater value!")
      when calculate_value(session[:dealer_hand]) > 21
        #"Dealer busts" win msg + add_pot + play_again + show_updated_pot
        win("The dealer busted!")
      when calculate_value(session[:dealer_hand]) <= 21 && calculate_value(session[:player_hand]) < calculate_value(session[:dealer_hand])
        #"lower value" lose msg + minus_pot + play_again + show_updated_pot
        lose("The dealer has a higher value...")
      else
        #"it's a tie" tie msg + play_again
        tie("The values are the same.")
      end
    elsif calculate_value(session[:dealer_hand]) < 17
      #dealer_must_hit
      @dealer_hit = true
    end
  end
  erb :player_turn
end

get '/dealer_hit' do
  deal_card(session[:dealer_hand], session[:deck])
  redirect '/player_turn'
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
  redirect '/player_turn'
end

get '/stay' do
  session[:player_turn] = false
  redirect '/player_turn'
end








#
