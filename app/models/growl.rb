require "open-uri"

class Growl < ActiveRecord::Base
  attr_accessible :comment, :link, :user, :type,
                  :external_id, :original_created_at,
                  :user_id, :event_type
                  
  validates_presence_of :type
  belongs_to :user
  has_one :meta_data, :autosave => true, dependent: :destroy
  has_many :regrowls
  include HasUploadedFile
  scope :by_date, order("created_at DESC")
  after_create :set_original_created_at

  def self.by_type_and_date(type=nil)
    if type
      by_type(type).by_date.includes(:meta_data).includes(:user)
    else
      by_date.includes(:meta_data).includes(:user)
    end
  end

  def self.by_type(input)
    where(type: input)
  end

  ["title", "thumbnail_url", "description"].each do |method|
    define_method method.to_sym do
      meta_data ? meta_data.send(method.to_sym) : ""
    end
  end

  ["link", "message", "image"].each do |method|
     define_method "#{method}?".to_sym do
        self.type == method.capitalize
    end
  end

  def self.regrowled_new(id,user_id)
    growl = Growl.find(id).dup
    if growl.user_id != user_id
      growl.user_id = user_id
      growl.regrowled_from_id = id
      growl.save
    end
  end

  def original_growl?
    regrowled_from_id == nil
  end

  def get_display_name
    if original_growl?
      user.display_name
    else
      original_growl.user.display_name
    end
  end

  def get_gravatar
    if original_growl?
      user.avatar
    else
      original_growl.user.avatar
    end
  end

  def original_growl
    Growl.find(regrowled_from_id)
  end
  
  private

  def set_original_created_at
    self.original_created_at = DateTime.now unless self.original_created_at
    self.save
  end

end

# == Schema Information
#
# Table name: growls
#
#  id                  :integer         not null, primary key
#  type                :string(255)
#  comment             :text
#  link                :text
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  user_id             :integer
#  photo_file_name     :string(255)
#  photo_content_type  :string(255)
#  photo_file_size     :integer
#  photo_updated_at    :datetime
#  original_created_at :datetime
#  event_type          :string(255)
#

