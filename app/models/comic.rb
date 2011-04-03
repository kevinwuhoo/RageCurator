# == Schema Information
# Schema version: 20110401212813
#
# Table name: comics
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  link       :string(255)
#  reddit     :string(255)
#  view       :boolean
#  tweet      :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Comic < ActiveRecord::Base

  def image?
    puts "slow?"
    !FastImage.type(link).nil?
  end

end
