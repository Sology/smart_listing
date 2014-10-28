class User < ActiveRecord::Base
  def self.search(word)
    where('name LIKE :word OR email LIKE :word', word: "%#{word}%")
  end
end
