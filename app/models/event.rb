# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  start       :datetime
#  finish      :datetime
#  description :text
#  location_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ActiveRecord::Base
  belongs_to :location
  has_many :items

  def subtitle
    def format d
      d.strftime Media::DATE_FORMAT
    end
    date = if start.to_date == finish.to_date
             format start
           else
             "#{format start} - #{format finish}"
           end
    return "#{date}" unless location
    return "#{date} - #{location.name}"
  end


  def to_s
    name || start.to_date.to_s
  end

  before_save :fix_name
  before_save :fix_dates

  private
  def fix_name
    self.name = nil if @name =~ /^\s*$/
    true
  end

  def fix_dates
    return true if items.empty?
    dates = items.map { |i| i.taken }

    self.start = dates.min
    self.finish = dates.max
    true
  end
end