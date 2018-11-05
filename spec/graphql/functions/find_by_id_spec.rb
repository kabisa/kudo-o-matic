# frozen_string_literal: true

RSpec.describe Functions::FindById do
  context "when id of existing record is provided" do
    it "returns the record" do
      user = create(:user)
      args = { id: user.id }
      query_result = Functions::FindById.new(User).call(nil, args, nil)
      expect(query_result).to eq(user)
    end
  end
  context "when id of not existing record is provided" do
    it "returns ActiveRecord::RecordNotFound error" do
      args = { id: 1 }
      expect do
        Functions::FindById.new(User).call(nil, args, nil)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when blank hash is provided" do
    it "returns ActiveRecord::RecordNotFound error" do
      args = {}
      expect do
        Functions::FindById.new(User).call(nil, args, nil)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
