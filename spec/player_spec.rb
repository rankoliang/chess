# frozen_string_literal: true

require_relative '../lib/player'

RSpec.describe Player do
  describe '#to_s' do
    subject(:name) { described_class.new(color).to_s }

    context 'when the color is a symbol' do
      let(:color) { :black }

      it do
        expect(name).to eq color.to_s
      end
    end

    context 'when the color is not a symbol' do
      let(:color) { 'black' }

      it do
        expect(name).to eq color.to_s
      end
    end
  end
end
