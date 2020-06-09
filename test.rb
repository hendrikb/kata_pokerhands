# frozen_string_literal: true

require_relative './main.rb'

def runTest(msg, expected, hand, other)
  player = PokerHand.new(hand)
  opponent = PokerHand.new(other)
  result = player.compare_with(opponent)
  unless result == expected
    puts "FAILED: #{msg}: My '#{hand}' vs Their '#{other}': expected My #{expected}, got #{result}"
  end
end

runTest('Highest straight flush wins',        'Loss', '2H 3H 4H 5H 6H', 'KS AS TS QS JS')
runTest('Straight flush wins of 4 of a kind', 'Win',  '2H 3H 4H 5H 6H', 'AS AD AC AH JD')
runTest('Highest 4 of a kind wins',           'Win',  'AS AH 2H AD AC', 'JS JD JC JH 3D')
runTest('4 Of a kind wins of full house',     'Loss', '2S AH 2H AS AC', 'JS JD JC JH AD')
runTest('Full house wins of flush',           'Win',  '2S AH 2H AS AC', '2H 3H 5H 6H 7H')
runTest('Highest flush wins',                 'Win',  'AS 3S 4S 8S 2S', '2H 3H 5H 6H 7H')
runTest('Flush wins of straight',             'Win',  '2H 3H 5H 6H 7H', '2S 3H 4H 5S 6C')
runTest('Equal straight is tie', 'Tie', '2S 3H 4H 5S 6C', '3D 4C 5H 6H 2S')
runTest('Straight wins of three of a kind',   'Win',  '2S 3H 4H 5S 6C', 'AH AC 5H 6H AS')
runTest('3 Of a kind wins of two pair',       'Loss', '2S 2H 4H 5S 4C', 'AH AC 5H 6H AS')
runTest('2 Pair wins of pair',                'Win',  '2S 2H 4H 5S 4C', 'AH AC 5H 6H 7S')
runTest('Highest pair wins',                  'Loss', '6S AD 7H 4S AS', 'AH AC 5H 6H 7S')
runTest('Pair wins of nothing',               'Loss', '2S AH 4H 5S KC', 'AH AC 5H 6H 7S')
runTest('Highest card loses',                 'Loss', '2S 3H 6H 7S 9C', '7H 3C TH 6H 9S')
runTest('Highest card wins',                  'Win',  '4S 5H 6H TS AC', '3S 5H 6H TS AC')
runTest('Equal cards is tie',		              'Tie', '2S AH 4H 5S 6C', 'AD 4C 5H 6H 2C')
runTest('complex1', 'Win', 'KC 4H KS 2H 8D', 'KD 6S 9D TH AD')

runTest('complex',  'Loss', 'JC 6H JS JD JH', 'JC KH JS JD JH')
runTest('complex',  'Win', 'KC 4H KS 2H 8D', '8C 4S KH JS 4D')
runTest('complex',  'Win', '3C KH 5D 5S KH', '5S 5D 2C KH KH')
runTest('complex',  'Win', '2H 2C 3S 3H 3D', '3D 2H 3H 2C 2D')
runTest('complex',  'Win', '4C 5C 9C 8C KC', '3S 8S 9S 5S KS')
runTest('complex',  'Loss', 'JC 6H JS JD JH', 'JC 7H JS JD JH')
runTest('complex',  'Loss', '3D 2H 3H 2C 2D', '2H 2C 3S 3H 3D')
runTest('complex',  'Win', 'KD 4S KC 3H 8S', 'QH 8H KD JH 8S')
runTest('complex',  'Loss', 'KS 8D 4D 9S 4S', 'KD 4S KC 3H 8S')
runTest('complex',  'Loss', '8C 4S KH JS 4D', 'KD 4S KC 3H 8S')
