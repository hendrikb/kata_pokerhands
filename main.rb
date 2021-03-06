# frozen_string_literal: true

# Represents one card of a Poker game
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
    return map_value_from_named(character) if character =~ /^[TJQKA]$/
    return character.to_i if (2..9).include?(character.to_i)

    raise "Determining card value from character #{character} failed!"
  end

  def self.map_value_from_named(character)
    return TEN if character == 'T'
    return JOKER if character == 'J'
    return QUEEN if character == 'Q'
    return KING if character == 'K'
    return ACE if character == 'A'
  end
end

# Holds information about winning Poker cards
class PokerHand
  RANK = %i[highcard pair twopairs threeofakind straight flush fullhouse fourofakind straightflush royalflush].freeze

  def initialize(my_hand_string)
    @my_hand = representation_of(my_hand_string)
    @highest_hand_name, @highest_hand_sequence = identify_suit
  end

  def compare_with(other_hand)
    my_highest_hand_name = RANK.find_index(highest_hand_name)
    puts "My #{highest_hand_name} vs. Their #{other_hand.highest_hand_name}"
    their_highest_hand_name = RANK.find_index(other_hand.highest_hand_name)
    return 'Loss' if my_highest_hand_name < their_highest_hand_name
    return 'Win' if  my_highest_hand_name > their_highest_hand_name

    handle_complex_hands(other_hand)
  end

  def self.of_a_kind(hand, number)
    hand.group_by(&:value).select { |_, many_of_a_kind| many_of_a_kind.count == number }.values
  end

  protected

  attr_reader :my_hand, :highest_hand_name, :highest_hand_sequence

  private

  def handle_complex_hands(other_hand)
    return 'Loss' if highest_hand_sequence.first.value < other_hand.highest_hand_sequence.first.value
    return 'Win' if highest_hand_sequence.first.value > other_hand.highest_hand_sequence.first.value
    return decision_needs_kicker(other_hand) if other_hand.highest_hand_sequence.count <= 5
  end

  def decision_needs_kicker(other_hand)
    my_hand.each_with_index do |card, index|
      next if card.value == other_hand.my_hand[index].value
      return 'Loss' if card.value < other_hand.my_hand[index].value
      return 'Win' if card.value > other_hand.my_hand[index].value
    end
    'Tie'
  end

  ## Helper methods identifying named hands ##

  def flush
    my_hand.group_by(&:suit).select { |_, hand_of_suit| hand_of_suit.count == 5 }.values.flatten
  end

  def straight
    largest_straight = [my_hand.first]
    my_hand.drop(1).each do |card|
      if largest_straight.last.value == card.value + 1
        largest_straight << card
      else
        largest_straight = [card]
      end
    end
    return [] unless largest_straight.count == 5

    largest_straight
  end

  def of_a_kind(number)
    PokerHand.of_a_kind(my_hand, number)
  end

  ## booleans figuring showing a named hand is there

  def royalflush
    return my_hand if royalflush?

    []
  end

  def royalflush?
    straight? && flush? && my_hand.last.value == PokerCard::TEN
  end

  def straightflush
    return my_hand if straightflush?

    []
  end

  def straightflush?
    straight? && flush?
  end

  def fourofakind
    of_a_kind(4).flatten
  end

  def fourofakind?
    !fourofakind.empty?
  end

  def fullhouse
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

  def threeofakind
    of_a_kind(3).flatten
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

  def highcard
    [my_hand.first]
  end

  def highcard?
    true
  end

  def identify_suit
    RANK.reverse.each do |rank_name|
      relevant_hand_matched = instance_eval("#{rank_name}?", __FILE__, __LINE__)
      relevant_hand = instance_eval(rank_name.to_s, __FILE__, __LINE__)
      return rank_name, relevant_hand if relevant_hand_matched
    end
    raise 'This should never happen as :highcard is always true!'
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
