# frozen_string_literal: true

require 'byebug'
require 'pry'

class PokerCard
  CARD_SUIT_MAPPING = { "S": :spades, "H": :hearts, "D": :diamonds, "C": :clubs }.freeze
  TEN = 10
  JOKER = 11
  QUEEN = 12
  KING = 13
  ACE = 14

  attr_reader :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def ==(other)
    other.class == self.class && other.value == value && other.suit == suit
  end

  def self.map_suit_from(character)
    CARD_SUIT_MAPPING[character.to_sym]
  end

  def self.map_value_from(character)
    return TEN if character == 'T'
    return JOKER if character == 'J'
    return QUEEN if character == 'Q'
    return KING if character == 'K'
    return ACE if character == 'A'
    return character.to_i if (2..9).include?(character.to_i)

    raise "Determining card value from character #{character} failed!"
  end
end

class PokerHand
  SUIT_RANK = %i[highcard pair twopairs threeofakind straight flush fullhouse fourofakind straightflush royalflush].freeze

  def initialize(my_hand_string)
    @my_hand = representation_of(my_hand_string)
    @highest = identify_suit
  end

  def compare_with(other_hand_string)
    other_hand = PokerHand.new(other_hand_string)
    my_highest = SUIT_RANK.find_index(highest)
    puts "My #{highest} vs. Their #{other_hand.highest}"
    their_highest = SUIT_RANK.find_index(other_hand.highest)
    return 'Loss' if my_highest < their_highest
    return 'Tie' if  my_highest == their_highest
    return 'Win' if  my_highest > their_highest
  end

  protected

  attr_reader :my_hand, :highest

  private

  ## Helper methods identifying special suits ##

  def flush
    my_hand.group_by(&:suit).select { |_, hand_of_suit| hand_of_suit.count == 5 }
  end

  def straight
    sequence = [my_hand.first]
    my_hand.each do |card|
      next if card == sequence.first

      if sequence.last.value == card.value + 1
        sequence << card
      else
        sequence = [card]
      end
    end
    return [] unless sequence.count == 5

    sequence
  end

  def self.of_a_kind(hand, number)
    hand.group_by(&:value).select { |_, many_of_a_kind| many_of_a_kind.count == number }.values
  end

  def of_a_kind(number)
    PokerHand.of_a_kind(my_hand, number)
  end

  ## booleans figuring out each named suit

  def royalflush?
    highest_cards = my_hand.select { |card| card.value >= PokerCard::TEN }
    highest_cards.count == 5 && highest_cards.map(&:suit).uniq.count == 1
  end

  def straightflush?
    straight.map(&:suit).uniq.count == 1
  end

  def fourofakind?
    !of_a_kind(4).empty?
  end

  def threeofakind
    of_a_kind(3).flatten
  end

  def fullhouse
    threeofakind = threeofakind
    remaining_cards = my_hand - threeofakind
    return my_hand if remaining_cards.map(&:value).uniq.count == 1

    []
  end

  def fullhouse?
    fullhouse.any?
  end

  def flush?
    flush.any?
  end

  def straight?
    straight.any?
  end

  def threeofakind?
    threeofakind.any?
  end

  def twopairs
    if pair?
      higher_pair = pair
      lower_pair = PokerHand.of_a_kind(my_hand - higher_pair, 2).flatten
      return higher_pair + lower_pair if lower_pair.any?
    end
    []
  end

  def twopairs?
    twopairs.any?
  end

  def pair
    pair = of_a_kind(2)
    return pair.first unless pair.empty?

    []
  end

  def pair?
    pair.any?
  end

  def identify_suit
    return :royalflush if royalflush?
    return :straightflush if straightflush?
    return :fourofakind if fourofakind?
    return :fullhouse if fullhouse?
    return :flush if flush?
    return :straight if straight?
    return :threeofakind if threeofakind?
    return :twopairs if twopairs?
    return :pair if pair?

    :highcard
  end

  def representation_of(hand_string)
    hand_string.split(' ').map do |cardcode|
      begin
        card_value = PokerCard.map_value_from(cardcode[0])
        card_suit = PokerCard.map_suit_from(cardcode[1])
        PokerCard.new(card_value, card_suit)
      rescue StandardError => e
        raise "Did not recognize #{hand_string} card: #{e.message}"
      end
    end.sort_by(&:value).reverse
  end
end

# Execute my Game here:

MY_HAND    = '7C 7H 7D 7S 8C'
THEIR_HAND = '2C 3C 4C 5C 6C'

ph = PokerHand.new(MY_HAND)
puts ph.compare_with(THEIR_HAND)
