class Movie < ApplicationRecord

  enum status: { waiting: 0, downloaded: 1, watched: 2 }
end
