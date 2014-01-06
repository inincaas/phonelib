require 'spec_helper'
require 'json'

describe 'Phonelib' do

  it 'sanitizes an international number correctly' do
    parsed = Phonelib.parse('0035318141111', :gb)
    expect(parsed.sanitized).to eq('35318141111')
  end

  it 'can parse an international number' do
    parsed = Phonelib.parse('0035318141111')
    puts "international:#{parsed.international} national:#{parsed.national}"
    expect(parsed.valid?).to be_true
  end

  it 'can parse an international number' do
    parsed = Phonelib.parse('0035318141111', :gb)
    puts "international:#{parsed.international} national:#{parsed.national}"
    expect(parsed.valid?).to be_true
  end

  # basic country validity check for a set of world hotels
  # these should all be fixed line, or toll free
  [
    %w( +14165982475  CA ),
    %w( +4989177030   DE ),
    %w( +33142968590  FR ),
    %w( +390642020032 IT ),
    %w( +27214107100  ZA ),
    %w( +351214860141 PT ),
    %w( +441423871350 GB ),
    %w( +2304023100   MU ),
    %w( +62361731149  ID ),
    %w( +9606642672   MV ),
    %w( +902124023000 TR ),
    %w( +420225334111 CZ ),
    %w( +85671212194  LA ),
    %w( +84583624964  VN ),
    %w( +97148329900  AE ),
    %w( +17783274100  CA ),
    %w( +3612686000   HU ),
    %w( +442079171000 GB ),
    %w( +5184201620   PE ),
    %w( +18083258000  US ),
    %w( +903843545815 TR ),
    %w( +353749722208 IE ),
    %w( +41818303030  CH ),
    %w( +302244032110 GR ),
    %w( +421257784600 SK ),
    %w( +18778595095  US ),
    %w( +4588776655   DK ),
    %w( +3292339393   BE )
  ].each do |number, country|
    describe "Given input of #{number}" do
      it "maps to #{country}" do
        parsed = Phonelib.parse(number)
        puts "#{parsed.type} #{parsed.international} #{parsed.countries}"
        expect([:toll_free, :fixed_line, :fixed_or_mobile])
          .to include(parsed.type)
        expect(parsed.country).to eq(country)
      end
    end
  end

  # various worldwide mobile phone numbers (mostly government related)
  [
    %w( +923008541673 PK ),
    %w( +923215610687 PK ),
    %w( +923455194908 PK ),
    %w( +35058857000  GI ),
    %w( +35058465000  GI ),
    %w( +61419341178  AU ),
    %w( +61417364375  AU ),
    %w( +353861753747 IE ),
    %w( +353868126340 IE ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +447889650544 GB ),
    %w( +919830616214 IN ),
    %w( +27833131323  ZA )
  ].each do |number, country|
    describe "Given input of #{number}" do
      it "maps to a mobile number for #{country}" do
        parsed = Phonelib.parse(number)
        expect(parsed.country).to eq(country)
        expect(parsed.type).to eq(:mobile)
      end
    end
  end
end
