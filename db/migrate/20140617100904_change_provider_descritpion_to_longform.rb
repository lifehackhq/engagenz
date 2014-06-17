class ChangeProviderDescritpionToLongform < ActiveRecord::Migration
  def up
    change_column :providers, :description, :text, default: ''
  end

  def down
    change_column :providers, :description, :string, default: ''
  end
end
