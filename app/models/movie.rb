class Movie < ApplicationRecord

  enum status: { waiting: 0, downloaded: 1, watched: 2 }

  before_save do
    self.name = name.mb_chars.upcase.to_s
    self.original_title = original_title.mb_chars.upcase.to_s
  end

  def self.get_url(name, year)
    url = "http://www.zeronave.com/search/"+URI.encode(name)
    src = nil
    Timeout::timeout(10) do
      doc = Nokogiri::HTML(open(url))
      nodes = doc.css(".block.margin-tb-10")
      nodes.each do |node|
        if node.css(".movie-heading small").text.to_i == year.to_i
          src = node.css(".box-movie.medium").attr('src')
          break
        end
      end
    end
  src
  end
end
