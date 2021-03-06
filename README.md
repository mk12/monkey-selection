# Monkey Selection

Monkey Selection is a simulation of cumulative selection. I wrote it after reading about the concept in _The Blind Watchmaker_ by Richard Dawkins.

## Cumulative selection

Consider constructing the phrase "METHINKS IT IS LIKE A WEASEL" by throwing together letters at random. Even if you only take 27 characters (alphabet and space), the odds of this working are 27<sup>28</sup> to 1 against. This is called single-step selection, and it is so astronomically unlikely to achieve our goal that the probability is essentially zero.

Consider instead if we start with a random sequence of 28 characters, then make a few dozen **imperfect** copies of it. We compare each copy to the real phrase, and keep only the one that is closest to it (by some measure). We continue this for as many generations as it takes to get the correct phrase. This is cumulative selection, which is a much better model for how evolution works. In just a hundred generations or so, it will always succeed in constructing the phrase.

## Implementation

There are a few details left unspecified by that description of cumulative selection. Here is how I implemented it:

- There is a `Selector` class which takes three values on initialization:
	- `str`: the string phrase, which must only contain alphabetical characters (no spaces)
	- `width`: the number of offspring in each generation
	- `p`: the probability (between 0 and 1) of a letter being copied incorrectly
- The `select` method returns the number of generations it takes to match the goal phrase. It prints the chosen offspring along the way if `verbose` is true.
- There is also an `average` method which does `n` trials and returns the average number of generations required.
- When a letter is copied incorrectly, the copy will be an adjacent letter instead. For example, if the letter was Q, it will become either P or R (both are equally likely).
- The measure of "distance" between strings of characters is the [mean squared error][1] (MSE): the sum of the squares of the errors for each pair of characters, divided by the length of the string.
- The selected offspring from each generation almost always has a lower MSE than its parent, except in the rare case that all children mutate away from the correct phrase.
- You can run the tests like so: `rspec monkey_spec.rb`.

[1]: http://en.wikipedia.org/wiki/Mean_squared_error

## Results

After some quick experimenting, I determined that a p-value of about 20% seems to be optimal for reducing the number of generations required. (Too low and things take too long to change; too high and they go all over the place and take longer to stabilize). Also, the number of generations is generally reduced as we increase `width` (the number of children in each generation), but the effect of increase it becomes less and less as it gets large. Values between 20 and 50 seem to work well. All of this probably depends on the length of the phrase, which I did not vary very much.

**Update**: After some more testing, I discovered that the optimal p-value _does_ depends on the length of the phrase. A 20% error rate was good for very short phrases, but for much longer ones, a rate of 1% works _much_ better.

## License

© 2015 Mitchell Kember

Monkey Selection is available under the MIT License; see [LICENSE](LICENSE.md) for details.