# Copyright 2015 Mitchell Kember. Subject to the MIT License.

require './monkey.rb'

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

describe 'rand_chars' do
  it 'has the correct length' do
    expect(rand_chars(0).length).to eq(0)
    expect(rand_chars(1).length).to eq(1)
    expect(rand_chars(2).length).to eq(2)
    expect(rand_chars(10).length).to eq(10)
  end

  def valid(chars)
    chars.all? { |c| c.ord >= A && c.ord <= Z }
  end

  it 'consists of uppercase letters' do
    expect(rand_chars(10)).to satisfy { |s| valid(s) }
    expect(rand_chars(20)).to satisfy { |s| valid(s) }
  end
end

describe 'mistake' do
  it 'is different' do
    expect(mistake('Q')).not_to eq('Q')
    expect(mistake('W')).not_to eq('Q')
    expect(mistake('A')).not_to eq('Q')
    expect(mistake('Z')).not_to eq('Q')
  end

  it 'stays inside the alphabet' do
    expect(mistake('A')).to satisfy { |c| c == 'A' || c == 'B' }
    expect(mistake('Z')).to satisfy { |c| c == 'Z' || c == 'Y' }
  end

  it 'is close to the original' do
    expect(mistake('K').ord).to be_within(1).of('K'.ord)
    expect(mistake('W').ord).to be_within(1).of('W'.ord)
    expect(mistake('U').ord).to be_within(1).of('U'.ord)
  end
end

describe 'mutant' do
  it 'is always the same for k=0' do
    expect(mutant('MONTY'.chars, 0)).to eq('MONTY'.chars)
    expect(mutant('PYTHON'.chars, 0)).to eq('PYTHON'.chars)
  end

  it 'is always different for k=1' do
    expect(mutant('MONTY'.chars, 1)).to_not eq('MONTY'.chars)
    expect(mutant('PYTHON'.chars, 1)).to_not eq('PYTHON'.chars)
  end
end

describe 'mean_sqr_err' do
  it 'is zero for identical arrays' do
    expect(mean_sqr_err('THIS'.chars, 'THIS'.chars)).to eq(0)
    expect(mean_sqr_err('THAT'.chars, 'THAT'.chars)).to eq(0)
  end

  it 'is nonzero when there are differences' do
    expect(mean_sqr_err('A'.chars, 'Z'.chars)).to be_within(0.001).of(1)
    expect(mean_sqr_err('A'.chars, 'M'.chars)).to be_within(0.001).of(0.48**2)
  end
end

describe 'cum_sel' do
  it 'returns zero given the empty string' do
    expect(cum_sel('', 20, 0)).to eq(0)
    expect(cum_sel('', 0, 1)).to eq(0)
  end

  it 'returns a nonnegative integer' do
    expect(cum_sel('A', 5, 0.2)).to be >= 0
    expect(cum_sel('Q', 10, 0.1)).to be >= 0
  end
end

describe 'avg_gens' do
  it 'handles invalid sample sizes' do
    expect { avg_gens('ABC', 5, 0, 0) }.to raise_error
    expect { avg_gens('ABC', 5, 0, -1) }.to raise_error
  end
end
