# def calculate_value(hand)
#   ace_num = hand.select { |card| card[0] == "Ace" }.length
#   count = 0
#   hand.each do |card|
#     case
#     when card[0] == 'Ace'
#       count += 11
#     when card[0] == 'Jack',
#       card[0] == 'Queen',
#       card[0] == 'King'
#       count += 10
#     else
#       count += card[0].to_i
#     end
#   end
#   ace_num.times do |correction|
#     if count > 21
#       count -= 10
#     end
#   end
#   count
# end
#
# hand = [['9', 'Spades'], ['Ace', 'Hearts'], ['Ace', 'Diamonds'], ['Ace', 'Spades']]
#
# p hand
# p calculate_value(hand)
#
# def show_all_image(cards)
#   string = ''
#   cards.each do |card|
#     # string += '<img src="images/cards/' + cards[card.index][1].downcase + "_" + cards[card.index][0] + '.jpg">'
#     string += '<img src="images/cards/' + cards[0][1] + '.jpg">'
#   end
#   string
# end
#

def show_one_image(card)
  '<img src="images/cards/' + card[1].downcase + "_" + card[0].downcase + '.jpg">'
end

cards = [['Ace', 'Spades'], ['2', 'Hearts']]

p cards

cards.each do |card|
  p show_one_image(card)
end








#
