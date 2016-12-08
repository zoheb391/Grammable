class Gram < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  validates :message, presence: true
  validates :picture, presence: true

  mount_uploader :picture, PictureUploader
end
