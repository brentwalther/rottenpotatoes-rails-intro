class Movie < ActiveRecord::Base
  def self.all_ratings
    select(:rating).uniq.map(&:rating)
  end
end
