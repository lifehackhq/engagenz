class Provider < ActiveRecord::Base
  attr_accessible :name, :description, :address, :phone_number, :email, :website, :region_id, :category_ids

  belongs_to :region
  has_and_belongs_to_many :categories

  validates :name, :region, presence: true
  # validates :phone_number, presence: true
end
