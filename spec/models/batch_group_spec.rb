require 'spec_helper'

describe BatchGroup do
  it { should belong_to(:course) }
  it { should have_many(:grouped_batches).dependent(:destroy) }
  it { should have_many(:batches).through(:grouped_batches) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:course_id) }

  describe '#has_active_batches?' do
    let(:batch_group) do
      bg = FactoryGirl.create(:batch_group)
      FactoryGirl.create(:grouped_batch, :batch => batch, :batch_group => bg)
      bg
    end

    context 'one batch is active and not deleted' do
      let(:batch) { FactoryGirl.create(:batch, :is_active => true, :is_deleted => false ) }

      it 'returns true' do
        batch_group.should be_has_active_batches
      end
    end

    context 'no batch is inactive' do
      let(:batch) { FactoryGirl.create(:batch, :is_active => false, :is_deleted => true ) }

      it 'returns false' do
        batch_group.should_not be_has_active_batches
      end
    end

    context 'no batch is deleted' do
      let(:batch) { FactoryGirl.create(:batch, :is_active => true, :is_deleted => true ) }

      it 'returns false' do
        batch_group.should_not be_has_active_batches
      end
    end

  end
end