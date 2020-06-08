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
  def ==(o)
    o.class == self.class && o.value == value && o.suit == suit
  end
end


class PokerHand
  attr_reader :my_hand
  def initialize(my_hand_string)
    @my_hand = representation_of(my_hand_string)
  end

  ## Helper methods identifying special suits ##

  def has_flush
    my_hand.group_by(&:suit).select{|_,hand_of_suit|hand_of_suit.count ==5}
  end

  def has_straight
    sequence = [my_hand.first]
    my_hand.each do |card|
      next if card == sequence.first
      if sequence.last.value == card.value+1
        sequence << card
      else
        sequence = [card]
      end
    end
    return [] unless sequence.count == 5
    sequence
  end

  def self.has_of_a_kind(hand,number)
    hand.group_by(&:value).select{|_,many_of_a_kind| many_of_a_kind.count == number}.values
  end
  def has_of_a_kind(number)
    PokerHand.has_of_a_kind(my_hand,number)
  end

  ## booleans figuring out each named suit

  def is_royalflush?
    highest_cards = my_hand.select {|card| card.value >= PokerCard::TEN}
    highest_cards.count == 5 && highest_cards.map(&:suit).uniq.count == 1
  end
  def is_straightflush?
    has_straight.map(&:suit).uniq.count == 1
  end
  def is_fourofakind?
    not(has_of_a_kind(4).empty?)
  end
  def has_threeofakind
    has_of_a_kind(3).flatten
  end
  def has_fullhouse
    threeofakind = has_threeofakind
    remaining_cards = my_hand - threeofakind
    return my_hand if remaining_cards.map(&:value).uniq.count == 1
    []
  end
  def is_fullhouse?
    has_fullhouse.any?
  end
  def is_flush?
    has_flush.any?
  end
  def is_straight?
    has_straight.any?
  end
  def is_threeofakind?
    has_threeofakind.any?
  end
  def has_twopairs
    if is_pair?
      higher_pair = has_pair
      lower_pair = PokerHand.has_of_a_kind(my_hand - higher_pair,2).flatten
      return higher_pair + lower_pair if lower_pair.any?
    end
    []
  end
  def is_twopairs?
    has_twopairs.any?
  end
  def has_pair
    pair = has_of_a_kind(2)
    return pair.first unless pair.empty?
    []
  end
  def is_pair?
    has_pair.any?
  end

  def identify_suit
    return :royalflush if is_royalflush?
    return :straightflush if is_straightflush?
    return :fourofakind if is_fourofakind?
    return :fullhouse if is_fullhouse?
    return :flush if is_flush?
    return :straight if is_straight?
    return :threeofakind if is_threeofakind?
    return :twopairs if is_twopairs?
    return :pair if is_pair?
    return :highcard
  end

  def compare_with(other_hand_string)
    other_hand = PokerHand.new(other_hand_string)
    return "Tie" if other_hand == @my_hand
    return identify_suit
  end

  private
  def representation_of(hand_string)
    hand_string.split(" ").map do |cardcode|
      begin
        card_value = PokerCard.map_value_from(cardcode[0])
        card_suit = PokerCard.map_suit_from(cardcode[1])
        PokerCard.new(card_value, card_suit)
      rescue => e
        raise "Did not recognize #{hand_string} card: #{e.message}"
      end
    end.sort_by {|card| card.value}.reverse
  end
end

# HAND = "KS 2H 5C JD TD"
HAND = "KH KS 9C 9D 9H"

ph = PokerHand.new(HAND)
puts ph.compare_with("KS 2H 5C JD TD")
