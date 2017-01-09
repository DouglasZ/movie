class Movie < ApplicationRecord

  enum status: { waiting: 0, downloaded: 1, watched: 2 }

  before_save do
    self.name = name.mb_chars.upcase.to_s
    self.original_title = original_title.mb_chars.upcase.to_s
  end
end
