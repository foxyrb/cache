# frozen_string_literal: true

require "spec_helper"

RSpec.describe(Foxy::Cache) do
  let(:mutexer) { Hash.new { |h, k| h[k] = Mutex.new }.to_proc }

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

  after { subject.config[:store].delete("/") }

  subject { described_class.new(namespace: "tmp/#{EXECUTION}/", locker: mutexer) }

  let(:counter) { Counter.new }

  it "counter works" do
    expect(counter.number).to be 1
    expect(counter.number).to be 2
    expect(counter.number).to be 3
  end

  it "locker:" do
    thread = Thread.new do
      result = subject.yaml("locker") { sleep(2) && counter.number }
      expect(result).to eq(1)
    end

    sleep 1

    expect(subject.yaml("locker") { raise }).to eq(1)

    thread.join
  end

  it "#yaml" do
    expect(subject.config[:store].get("/key.yaml")).to eq nil
    expect(subject.yaml("key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq(val: 1)
    expect(subject.config[:store].get("/key.yaml")).to eq nil
    expect(subject.yaml("key") { { val: counter.number } }).to eq(val: 2)
    expect(subject.yaml("key") { { val: counter.number } }).to eq(val: 2)
    expect(subject.yaml("key", force_not_found: true) { { val: counter.number } }).to eq(val: 3)
    expect(subject.yaml("key") { { val: counter.number } }).to eq(val: 3)
    expect(subject.yaml("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq(val: 4)
    expect(subject.yaml("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq(val: 4)
    expect(subject.config[:store].get("/key.yaml")).to eq "--- {}\n\r\n---\r\n---\n:val: 3\n"
    expect(subject.config[:store].get("/this/is/another/longer/key.yaml")).to eq "--- {}\n\r\n---\r\n---\n:val: 4\n"
  end

  it "#json" do
    expect(subject.config[:store].get("/key.json")).to eq nil
    expect(subject.json("key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("val" => 1)
    expect(subject.config[:store].get("/key.json")).to eq nil
    expect(subject.json("key") { { val: counter.number } }).to eq("val" => 2)
    expect(subject.json("key") { { val: counter.number } }).to eq("val" => 2)
    expect(subject.json("key", force_not_found: true) { { val: counter.number } }).to eq("val" => 3)
    expect(subject.json("key") { { val: counter.number } }).to eq("val" => 3)
    expect(subject.json("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("val" => 4)
    expect(subject.json("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("val" => 4)
    expect(subject.config[:store].get("/key.json")).to eq "--- {}\n\r\n---\r\n{\"val\":3}"
    expect(subject.config[:store].get("/this/is/another/longer/key.json")).to eq "--- {}\n\r\n---\r\n{\"val\":4}"
  end

  it "#raw" do
    expect(subject.config[:store].get("/key.txt")).to eq nil
    expect(subject.raw("key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("{:val=>1}")
    expect(subject.config[:store].get("/key.txt")).to eq nil
    expect(subject.raw("key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.raw("key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.raw("key", force_not_found: true) { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.raw("key") { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.raw("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.raw("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.config[:store].get("/key.txt")).to eq  "--- {}\n\r\n---\r\n{:val=>3}"
    expect(subject.config[:store].get("/this/is/another/longer/key.txt")).to eq "--- {}\n\r\n---\r\n{:val=>4}"
  end

  it "#html" do
    expect(subject.config[:store].get("/key.html")).to eq nil
    expect(subject.html("key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq("{:val=>1}")
    expect(subject.config[:store].get("/key.html")).to eq nil
    expect(subject.html("key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.html("key") { { val: counter.number } }).to eq("{:val=>2}")
    expect(subject.html("key", force_not_found: true) { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.html("key") { { val: counter.number } }).to eq("{:val=>3}")
    expect(subject.html("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.html("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq("{:val=>4}")
    expect(subject.config[:store].get("/key.html")).to eq "--- {}\n\r\n---\r\n{:val=>3}"
    expect(subject.config[:store].get("/this/is/another/longer/key.html")).to eq "--- {}\n\r\n---\r\n{:val=>4}"
  end

  it "#marshal" do
    expect(subject.config[:store].get("/key.bin")).to eq nil
    expect(subject.marshal("key") { |c| c.result(:no_cache, { val: counter.number }) }).to eq({ val: 1 })
    expect(subject.config[:store].get("/key.bin")).to eq nil
    expect(subject.marshal("key") { { val: counter.number } }).to eq({ val: 2 })
    expect(subject.marshal("key") { { val: counter.number } }).to eq({ val: 2 })
    expect(subject.marshal("key", force_not_found: true) { { val: counter.number } }).to eq({ val: 3 })
    expect(subject.marshal("key") { { val: counter.number } }).to eq({ val: 3 })
    expect(subject.marshal("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq({ val: 4 })
    expect(subject.marshal("this", "is", "another", "longer", "key") { { val: counter.number } }).to eq({ val: 4 })
    expect(subject.config[:store].get("/key.bin")).to eq "--- {}\n\r\n---\r\n\x04\b{\x06:\bvali\b"
    expect(subject.config[:store].get("/this/is/another/longer/key.bin")).to eq "--- {}\n\r\n---\r\n\x04\b{\x06:\bvali\t"
  end
end
