# Copyright 2015 Mitchell Kember. Subject to the MIT License.

# This script implements the idea of cumulative selection described in the
# third chapter of The Blind Watchmaker by Richard Dawkins.

# A selector performs cumulative selection on phrases.
class Selector
  # Creates a new cumulative selector with a 'goal' string, a generation
  # 'width' (number of offspring per litter), and an error probability 'p'.
  def initialize(str, width, p)
    @goal = Phrase.new(str)
    @width = width
    @p = p
  end

  # Returns the number of generations required to reach the goal phrase by
  # cumulative selection, starting from a random phrase. If 'verbose' is true,
  # prints the chosen phrase from each generation (on separate line).
  def select(verbose)
    gen = 0
    parent = Phrase.random(@goal.length)
    until parent == @goal
      litter = @width.times.map { parent.reproduce(@p) }
      parent = litter.min_by { |p| p.mean_sqr_err(@goal) }
      gen += 1
      if verbose
        mse = parent.mean_sqr_err(@goal)
        puts "#{parent} (%.8f)" % mse
      end
    end
    gen
  end

  # Returns the average number of generations selection takes over 'n' trials.
  def average(n)
    raise "invalid n" unless n > 0
    n.times.reduce(0) { |sum| sum + select(false) } / n.to_f
  end
end

# A phrase is a sequence of uppercase alphabetical characters.
class Phrase
  # Constants for the start and end of the alphabet.
  A = 'A'.ord
  Z = 'Z'.ord

  attr_reader :chars

  # Creates a random phrase of 'n' letters.
  def self.random(n)
    self.new (0...n).map { (A + rand(26)).chr }
  end

  # Creates a phrase from a string or from an array of characters.
  def initialize(s)
    @chars = s.respond_to?(:chars) ? s.upcase.chars : s
  end

  # Converts the phrase to a string.
  def to_s
    @chars.join
  end

  # Returns the number of letters in the phrase.
  def length
    @chars.length
  end

  # Returns the nth letter in the phrase.
  def [](n)
    @chars[n]
  end

  # Returns true if this phrase is the same as 'other'.
  def ==(other)
    @chars == other.chars
  end

  # Returns true if the phrase consists of uppercase alphabetical characters.
  # This might not be so if the phrase was initialized with a character array.
  def valid?
    @chars.all? { |c| c.ord >= A && c.ord <= Z }
  end

  # Creates an imperfect copy of this phrase. For each letter in the phrase,
  # there is a probability 'p' on [0,1] that it will be copied incorrectly,
  # meaning it will be an adjacent letter instead (so P becomes Q or R).
  def reproduce(p)
    copy = @chars.map do |c|
      if rand < p
        (c.ord + (rand <=> 0.5)).clamp(A, Z).chr
      else
        c
      end
    end
    self.class.new(copy)
  end

  # Calculates the mean squared error (MSE) of this phrase with respect to the
  # 'expected' phrase, letter by letter.
  def mean_sqr_err(expected)
    len = [length, expected.length].min
    sum = (0...len).reduce 0 do |sum, i|
      o = (self[i].ord - A) / 25.0
      e = (expected[i].ord - A) / 25.0
      sum + (o - e)**2
    end
    sum / len
  end
end

# Extend numbers with a clamping method.
class Numeric
  def clamp(lo, hi)
    [[self, hi].min, lo].max
  end
end

# Parse command line arugments to run 'select' or 'average'.
if __FILE__ == $PROGRAM_NAME
  if ARGV.length < 3
    $stderr.puts 'usage: monkey.rb phrase width p [n]'
  else
    s = Selector.new(ARGV[0], Integer(ARGV[1]), Float(ARGV[2]))
    if ARGV.length == 3
      puts s.select(true)
    else
      puts s.average(Integer(ARGV[3]))
    end
  end
end
