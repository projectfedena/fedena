require 'spec_helper'

describe Asset do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount) }
end