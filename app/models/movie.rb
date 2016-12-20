class Movie < ApplicationRecord

  enum status: { waiting: 0, watched: 1, downloaded: 2  }
end
