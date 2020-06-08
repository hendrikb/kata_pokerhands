require 'byebug'
require 'pry'

class PokerCard
  CARD_SUIT_MAPPING = {"S": :spades, "H": :hearts, "D": :diamonds, "C": :clubs}
  TEN = 10
  JOKER = 11
  QUEEN = 12
  KING = 13
  ACE = 14

  attr_reader :value, :suit

  def self.map_suit_from(character)
    CARD_SUIT_MAPPING[character.to_sym]
  end
  def self.map_value_from(character)
    return TEN if character == "T"
    return JOKER if character == "J"
    return QUEEN if character == "Q"
    return KING if character == "K"
    return ACE if character == "A"
    return character.to_i if (2..9).include?(character.to_i)
    raise "Determining card value from character #{character} failed!"
  end

  def initialize(value, suit)
    @value = value
    @suit = suit
  end
end


class PokerHand
  def initialize(my_hand_string)
    @my_hand = representation_of(my_hand_string)
  end

  def high_sequence_of(number_of_cards, of_suite = nil)
    byebug
  end

  def is_royalflush?(hand)
    highest_cards = hand.select {|card| card.value >= TEN}
    highest_cards.count == 5 && highest_cards.map(&:suit).uniq.count == 1
  end
  def is_straightflush?(hand)
    PokerHand.with_high_sequence_of(5).any?

  end
  def is_fourofakind?(hand)
    false
  end
  def is_fullhouse?(hand)
    false
  end
  def is_flush?(hand)
    hand.group_by(&:suit).select{|_,hand_of_suit|hand_of_suit.count ==5}.any?
  end
  def is_straight?(hand)
    PokerHand.with_high_sequence_of(5).any?
    false
  end
  def is_threeofakind?(hand)
    false
  end
  def is_twopairs?(hand)
    false
  end
  def is_pair?(hand)
    false
  end

  def representation_of(hand_string)
    hand_string.split(" ").map do |cardcode|
      begin
        card_value = PokerCard.map_value_from(cardcode[0])
        card_suit = PokerCard.map_suit_from(cardcode[1])
        PokerCard.new(card_value, card_suit)
      rescue => e
        raise "Did not recognize #{hand_string} card: #{e.message}"
      end
    end.sort_by {|card| card.value}
  end

  def identify_suite(hand)
    return :royalflush if is_royalflush?(hand)
    return :straightflush if is_straightflush?(hand)
    return :fourofakind if is_fourofakind?(hand)
    return :fullhouse if is_fullhouse?(hand)
    return :flush if is_flush?(hand)
    return :straight if is_straight?(hand)
    return :threeofakind if is_threeofakind?(hand)
    return :twopairs if is_twopairs?(hand)
    return :pair if is_pair?(hand)
    return :highcard
  end

  def compare_with(other_hand_string)
    other_hand = representation_of(other_hand_string)
    return "Tie" if other_hand == @my_hand
    return identify_suite(@my_hand)
  end
end

# HAND = "KS 2H 5C JD TD"
HAND = "9H TH JH QH KH"

ph = PokerHand.new(HAND)
puts ph.compare_with("KS 2H 5C JD TD")
