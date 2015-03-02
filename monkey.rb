# Copyright 2015 Mitchell Kember. Subject to the MIT License.

# This script implements the idea of cumulative selection described in the
# third chapter of The Blind Watchmaker by Richard Dawkins.

A = 'A'.ord
Z = 'Z'.ord

class Numeric
  def clamp(lo, hi)
    [[self, hi].min, lo].max
  end
end

# Returns a random array of 'len' uppercase alphabetical letters.
def rand_chars(len)
  (0..len-1).map { (A + rand(26)).chr }
end

# Returns a letter adjacent to the given character (chooses one at random).
def mistake(c)
  (c.ord + (rand <=> 0.5)).clamp(A, Z).chr
end

# Returns a slightly imperfect copy of 'chars'. For each character, there is a
# probability 'k' between 0 and 1 of an incorrect copy.
def mutant(chars, k)
  chars.map { |c| rand < k ? mistake(c) : c }
end

# Calculates the mean squared error (MSE) of the 'got' character array
# compared the the expected 'want'.
def mean_sqr_err(got, want)
  len = [got.length, want.length].min
  sum = (0..len-1).reduce 0 do |sum, i|
    o = (got[i].ord.to_f - A) / 25.0
    e = (want[i].ord.to_f - A) / 25.0
    sum + (o - e)**2
  end
  sum / len
end

# Returns the number of generations it takes to produce the given string
# using cumulative selection with 'w' children in each generation and using
# 'k' as the mutation probability.
def cum_sel(str, w, k)
  gen = 0
  goal = str.upcase.chars
  parent = rand_chars(str.length)
  until parent == goal
    children = w.times.map { mutant(parent, k) }
    parent = children.min_by { |c| mean_sqr_err(c, goal) }
    gen += 1
    # puts parent.join
  end
  gen
end

# Returns the average number of generations it takes for cumulative selection
# to obtain the correct characters, doing 'n' trials.
def avg_gens(str, w, k, n)
  raise "invalid n" unless n > 0
  n.times.reduce(0) { |sum| sum + cum_sel(str, w, k) } / n.to_f
end

# It appears that a 20% mutation probability (k=0.2) works best. Wider
# generations (w-values) are better, but the difference becomes smaller and
# smaller as they get bigger (perhaps it varies logarithmically?).
