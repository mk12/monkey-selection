# Copyright 2015 Mitchell Kember. Subject to the MIT License.

require './monkey.rb'

describe 'Selector' do
  def sel(s, w, p)
    Selector.new(s, w, p).select
  end

  def avg(s, w, p, n)
    Selector.new(s, w, p).average(n)
  end

  it 'takes zero generations to select nothing' do
    expect(sel('', 0, 0)).to eq(0)
    expect(sel('', 20, 0)).to eq(0)
    expect(sel('', 0, 1)).to eq(0)
  end

  it 'takes a nonnegative number of generations' do
    expect(sel('A', 5, 0.2)).to be >= 0
    expect(sel('W', 7, 0.1)).to be >= 0
    expect(sel('Q', 10, 0.3)).to be >= 0
  end

  it 'handles invalid sample sizes' do
    expect { avg('', 5, 0, 0) }.to raise_error
    expect { avg('ABC', 5, 0, -1) }.to raise_error
  end
end

describe 'Phrase' do
  before(:all) do
    @rand1 = Phrase.random(1)
    @rand10 = Phrase.random(10)
    @monty = Phrase.new('monty')
    @python = Phrase.new('python')
  end

  def valid(p)
    p.chars.all? { |c| c.ord >= 'A'.ord && c.ord <= 'Z'.ord }
  end

  it 'has the correct length' do
    expect(Phrase.random(0).length).to eq(0)
    expect(@rand1.length).to eq(1)
    expect(@rand10.length).to eq(10)
    expect(@monty.length).to eq(5)
    expect(@python.length).to eq(6)
  end

  it 'consists of uppercase letters' do
    expect(@rand1).to satisfy { |p| valid(p) }
    expect(@rand10).to satisfy { |p| valid(p) }
    expect(@monty).to satisfy { |p| valid(p) }
    expect(@python).to satisfy { |p| valid(p) }
  end

  it 'reproduces perfectly for p=0' do
    expect(@rand1.reproduce(0)).to eq(@rand1)
    expect(@rand10.reproduce(0)).to eq(@rand10)
    expect(@monty.reproduce(0)).to eq(@monty)
    expect(@python.reproduce(0)).to eq(@python)
  end

  it 'reproduces imperfectly different for p=1' do
    expect(@rand1.reproduce(1)).to_not eq(@rand1)
    expect(@rand10.reproduce(1)).to_not eq(@rand10)
    expect(@monty.reproduce(1)).to_not eq(@monty)
    expect(@python.reproduce(1)).to_not eq(@python)
  end

  it 'reports zero MSE for identical phrases' do
    expect(@rand1.mean_sqr_err(@rand1)).to eq(0)
    expect(@rand10.mean_sqr_err(@rand10)).to eq(0)
    expect(@monty.mean_sqr_err(@monty)).to eq(0)
    expect(@python.mean_sqr_err(@python)).to eq(0)
  end

  it 'reports the correct MSE and has symmetry' do
    @a = Phrase.new('A')
    @m = Phrase.new('M')
    @z = Phrase.new('Z')
    expect(@monty.mean_sqr_err(@python)).to be_within(0.001).of(0.12448)
    expect(@monty.mean_sqr_err(@python)).to be_within(0.001).of(0.12448)
    expect(@a.mean_sqr_err(@z)).to be_within(0.001).of(1)
    expect(@z.mean_sqr_err(@a)).to be_within(0.001).of(1)
    expect(@a.mean_sqr_err(@m)).to be_within(0.001).of(0.48**2)
    expect(@m.mean_sqr_err(@a)).to be_within(0.001).of(0.48**2)
  end
end

describe 'clamping' do
  it 'does not affect intermediate values' do
    expect(5.clamp(0,10)).to eq(5)
    expect(0.clamp(-1,1)).to eq(0)
    expect(7.clamp(3,11)).to eq(7)
    expect(-3.clamp(-4,-1)).to eq(-3)
  end

  it 'is inclusive of boundaries' do
    expect(3.clamp(3,3)).to eq(3)
    expect(3.clamp(3,4)).to eq(3)
    expect(4.clamp(3,4)).to eq(4)
  end

  it 'clamps values that are out of bounds' do
    expect(0.clamp(1,2)).to eq(1)
    expect(3.clamp(1,2)).to eq(2)
    expect(100.clamp(-2,-1)).to eq(-1)
  end
end
