require 'spec_helper'

describe Etherlite::Account::PrivateKey do
  let(:connection) { double('Etherlite::Connection') }
  let(:pk) { '409b803827d8a02c987e6b18a668b6333ff97f24f8075938b63d0ed737fcccb1' }
  let(:pk_address) { '4cd677f0f71185775f45e897aec2727914c0ed56' }
  let(:account) { described_class.new connection, pk }
  let(:gas_price) { 10_000 }
  let(:tx_count) { 20 }

  before do
    Etherlite::NonceManager.clear_cache

    allow(connection).to receive(:chain_id).and_return 1
    allow(connection).to receive(:use_parity).and_return false
    allow(connection).to receive(:eth_gas_price).and_return gas_price
    allow(connection).to receive(:eth_get_transaction_count)
      .with('0x' + pk_address, 'pending').and_return tx_count
    allow(connection).to receive(:eth_send_raw_transaction).and_return 'foo'
  end

  describe "#normalized_address" do
    it "returns the address corresponding to the given PK" do
      expect(account.normalized_address).to eq pk_address
    end
  end

  describe "#send_transaction" do
    let(:target_address) { '0x5e575279bf9f4acf0a130c186861454247394c06' }
    let(:amount) { 20_000_000 }
    let(:gas_limit) { 100_000 }
    let(:data) { '0xda7a' }

    it "calls 'eth_send_raw_transaction' with function data and returns a Transaction" do
      expect(connection).to receive(:eth_send_raw_transaction) do |raw|
        tx = Eth::Tx.decode raw
        expect(tx.value).to eq amount
        expect(tx.data).to eq data
        expect(tx.gas_limit).to eq gas_limit
        expect(tx.gas_price).to eq gas_price
        expect(binary_to_hex(tx.to)).to eq target_address
        expect(tx.nonce).to eq tx_count

        'a_hash'
      end

      tx = account.send_transaction(
        to: target_address, data: data, value: amount, gas: gas_limit
      )

      expect(tx).to be_a Etherlite::Transaction
      expect(tx.tx_hash).to eq 'a_hash'
    end

    context "when use_parity flag is set to true" do
      before do
        allow(connection).to receive(:use_parity).and_return true
      end

      it "calls parity_next_nonce instead of eth_get_transaction_count" do
        expect(connection).to receive(:parity_next_nonce).with('0x' + pk_address).and_return 2
        expect(connection).not_to receive(:eth_get_transaction_count)

        account.send_transaction(
          to: target_address, data: data, value: amount, gas: gas_limit
        )
      end
    end
  end

  def binary_to_hex(_string)
    '0x' + _string.unpack('H*').first
  end
end
