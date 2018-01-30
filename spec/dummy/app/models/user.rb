class User < ActiveRecord::Base
  scope :by_boolean, -> { where(:boolean => true) }
  scope :like, -> (filter) { where("UPPER(name) LIKE UPPER(?) OR UPPER(email) LIKE UPPER(?)", "%#{filter}%", "%#{filter}%")}

  def self.search(word)
    where('name LIKE :word OR email LIKE :word', word: "%#{word}%")
  end
end
