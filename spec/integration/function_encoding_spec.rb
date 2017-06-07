require 'spec_helper'

describe 'Function encoding' do
  let(:abi) { described_class }

  def load_and_encode(_signature, *_args)
    Etherlite::Abi.load_function(_signature).encode(_args)
  end

  it do
    expect(load_and_encode('void baz(uint32,bool)', 69, true))
      .to eq "0xcdcd77c0\
0000000000000000000000000000000000000000000000000000000000000045\
0000000000000000000000000000000000000000000000000000000000000001"
  end

  it do
    expect(load_and_encode('void bar(fixed[2])', [2.125, 8.5]))
      .to eq "0xab55044d\
0000000000000000000000000000000220000000000000000000000000000000\
0000000000000000000000000000000880000000000000000000000000000000"
  end

  it do
    expect(load_and_encode('void sam(bytes,bool,uint256[])', 'dave', true, [1, 2, 3]))
      .to eq "0xa5643bf2\
0000000000000000000000000000000000000000000000000000000000000060\
0000000000000000000000000000000000000000000000000000000000000001\
00000000000000000000000000000000000000000000000000000000000000a0\
0000000000000000000000000000000000000000000000000000000000000004\
6461766500000000000000000000000000000000000000000000000000000000\
0000000000000000000000000000000000000000000000000000000000000003\
0000000000000000000000000000000000000000000000000000000000000001\
0000000000000000000000000000000000000000000000000000000000000002\
0000000000000000000000000000000000000000000000000000000000000003"
  end
end