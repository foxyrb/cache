# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Foxy::Cache) do
  class Counter
    def initialize
      @i = 0
    end

    def number
      @i += 1
    end
  end

  it "has a version number" do
    expect(Foxy::Cache::VERSION).not_to be nil
  end

  let(:store) do
    Foxy::Cache::Store::Namespace.new(
      namespace: "#{__dir__}/tmp/#{EXECUTION}",
      store: Foxy::Cache::Store::Fs.new
    )
  end

  after { subject.config[:store].delete("/") }

  subject { described_class.new(store: store) }

  let(:counter) { Counter.new }

  it "counter works" do
    expect(counter.number).to be 1
    expect(counter.number).to be 2
    expect(counter.number).to be 3
  end

  it "#yaml" do
    expect(subject.config[:store].get("/this/is/the/key.yaml")).to eq nil
    expect(subject.yaml("this", "is", "the", "key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq(val: 1)
    expect(subject.config[:store].get("/this/is/the/key.yaml")).to eq nil
    expect(subject.yaml("this", "is", "the", "key") { { val: counter.number } }).to eq(val: 2)
    expect(subject.yaml("this", "is", "the", "key") { { val: counter.number } }).to eq(val: 2)
    expect(subject.yaml("this", "is", "the", "key", force_not_found: true) { { val: counter.number } }).to eq(val: 3)
    expect(subject.yaml("this", "is", "the", "key") { { val: counter.number } }).to eq(val: 3)
    expect(subject.yaml("this", "is", "another", "key") { { val: counter.number } }).to eq(val: 4)
    expect(subject.yaml("this", "is", "another", "key") { { val: counter.number } }).to eq(val: 4)
    expect(subject.config[:store].get("/this/is/the/key.yaml")).to eq "--- {}\n\r\n---\r\n---\n:val: 3\n"
  end

  it "#json" do
    expect(subject.config[:store].get("/this/is/the/key.json")).to eq nil
    expect(subject.json("this", "is", "the", "key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("val" => 1)
    expect(subject.config[:store].get("/this/is/the/key.json")).to eq nil
    expect(subject.json("this", "is", "the", "key") { { val: counter.number } }).to eq("val" => 2)
    expect(subject.json("this", "is", "the", "key") { { val: counter.number } }).to eq("val" => 2)
    expect(subject.json("this", "is", "the", "key", force_not_found: true) { { val: counter.number } }).to eq("val" => 3)
    expect(subject.json("this", "is", "the", "key") { { val: counter.number } }).to eq("val" => 3)
    expect(subject.json("this", "is", "another", "key") { { val: counter.number } }).to eq("val" => 4)
    expect(subject.json("this", "is", "another", "key") { { val: counter.number } }).to eq("val" => 4)
    expect(subject.config[:store].get("/this/is/the/key.json")).to eq "--- {}\n\r\n---\r\n{\"val\":3}"
  end

  it "#raw" do
    expect(subject.config[:store].get("/this/is/the/key.txt")).to eq nil
    expect(subject.raw("this", "is", "the", "key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("{:val=>1}")
    expect(subject.config[:store].get("/this/is/the/key.txt")).to eq nil
    expect(subject.raw("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.raw("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.raw("this", "is", "the", "key", force_not_found: true) { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.raw("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.raw("this", "is", "another", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.raw("this", "is", "another", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.config[:store].get("/this/is/the/key.txt")).to eq  "--- {}\n\r\n---\r\n{:val=>3}"
  end

  it "#html" do
    expect(subject.config[:store].get("/this/is/the/key.html")).to eq nil
    expect(subject.html("this", "is", "the", "key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("{:val=>1}")
    expect(subject.config[:store].get("/this/is/the/key.html")).to eq nil
    expect(subject.html("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.html("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.html("this", "is", "the", "key", force_not_found: true) { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.html("this", "is", "the", "key") { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.html("this", "is", "another", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.html("this", "is", "another", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.config[:store].get("/this/is/the/key.html")).to eq "--- {}\n\r\n---\r\n{:val=>3}"
  end

  it "#marshal" do
    expect(subject.config[:store].get("/this/is/the/key.bin")).to eq nil
    expect(subject.marshal("this", "is", "the", "key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq({ val: 1 })
    expect(subject.config[:store].get("/this/is/the/key.bin")).to eq nil
    expect(subject.marshal("this", "is", "the", "key") { { val: counter.number } }).to eq({ val: 2 })
    expect(subject.marshal("this", "is", "the", "key") { { val: counter.number } }).to eq({ val: 2 })
    expect(subject.marshal("this", "is", "the", "key", force_not_found: true) { { val: counter.number } }).to eq({ val: 3 })
    expect(subject.marshal("this", "is", "the", "key") { { val: counter.number } }).to eq({ val: 3 })
    expect(subject.marshal("this", "is", "another", "key") { { val: counter.number } }).to eq({ val: 4 })
    expect(subject.marshal("this", "is", "another", "key") { { val: counter.number } }).to eq({ val: 4 })
    expect(subject.config[:store].get("/this/is/the/key.bin")).to eq "--- {}\n\r\n---\r\n\x04\b{\x06:\bvali\b"
  end
end
