require 'spec_helper'

describe Arx do
  it 'has a version number' do
    expect(Arxutils::VERSION).not_to be nil
  end

  it 'has a dirname' do
    expect(Arxutils::Arxutils.dirname).not_to be nil
  end

  it 'has a rakefile' do
    expect(Arxutils::Arxutils.rakefile).not_to be nil
  end

  it 'has a configdir' do
    expect(Arxutils::Arxutils.configdir).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
