require 'open-uri'

class Movie < ApplicationRecord

  enum status: {waiting: 0, downloaded: 1, watched: 2}

  before_save do
    self.name = name.mb_chars.upcase.to_s
    self.original_title = original_title.mb_chars.upcase.to_s
  end

  def self.get_url(name, year)

    month = {}
    month['janeiro']= '01'
    month['fevereiro']= '02'
    month['marco']= '03'
    month['abril']= '04'
    month['maio']= '05'
    month['junho']= '06'
    month['julho']= '07'
    month['agosto']= '08'
    month['setembro']= '09'
    month['outubro']= '10'
    month['novembro']= '11'
    month['dezembro']= '12'

    url = URI.parse('http://www.adorocinema.com/busca/?q='+URI.encode(name))
    src = nil
    movie_name = nil
    original_title = nil
    release_date = nil
    director = ''
    cast = ''
    gender  = ''
    synopsis = nil

    Timeout::timeout(10) do
      doc = Nokogiri::HTML(open(url))
      nodes = doc.css('table.totalwidth.noborder.purehtml tr')
      nodes.each do |node|
        if node.css('span.fs11').text.to_i == year.to_i

          url_detail = URI.parse('http://www.adorocinema.com'+node.css('a')[0].xpath('@href').text)
          detail = Nokogiri::HTML(open(url_detail))

          movie_name = detail.css('.titlebar-title.titlebar-title-lg').text

          node_detail = detail.css('div.meta.col-xs-12.col-md-8')

          release_date = node_detail.css('.date.blue-link').text.split(' ')
          release_date[0] = release_date[0].to_i < 10 ? '0'+release_date[0] : release_date[0]
          release_date = release_date[0]+'/'+month[release_date[2].mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s]+'/'+release_date[4]

          directors = node_detail.css('.meta-body-item')[1].css('.blue-link')
          directors.each_with_index do |director_text, index|
            if directors.length == index+1
              director += director_text.text
            else
              director += director_text.text+', '
            end
          end

          node_detail.css('.meta-body-item')[2].css('.blue-link').each_with_index do |cast_text, index|
            if  index+1 == 3
              cast += cast_text.text
            elsif index+1 < 3
              cast += cast_text.text+', '
            end
          end

          genders = node_detail.css('.meta-body-item')[3].css('.blue-link')
          genders.each_with_index do |gender_text, index|
            if genders.length == index+1
              gender += gender_text.text
            else
              gender += gender_text.text+', '
            end
          end
          node_detail = detail.css('.section.ovw.ovw-synopsis')
          synopsis = node_detail.css('.content-txt').text.strip
          original_title = node_detail.css('.ovw-synopsis-info').css('h2.that').text
          original_title = !original_title.empty? ? original_title : movie_name
          break
        end
      end
    end

    url = URI.parse('https://www.themoviedb.org/search?query='+URI.encode(original_title)+'&language=en-US')
    Timeout::timeout(10) do
      doc = Nokogiri::HTML(open(url))
      nodes = doc.css('.image_content')
      nodes.each do |node|
        # if node.css('.result').attr('title').text == original_title
          src = node.css('.poster.lazyload.fade').attr('data-srcset').text.split(',')[1]
          src = src[0..src.length-4]
          break
        # end
      end
    end

    # url = URI.parse('https://www.zeronave.com/search/'+URI.encode(name))
    # Timeout::timeout(10) do
    #   doc = Nokogiri::HTML(open(url))
    #   nodes = doc.css('.block.margin-tb-10')
    #   nodes.each do |node|
    #     if node.css('.movie-heading small').text.to_i == year.to_i
    #       src = node.css('.box-movie.medium').attr('src')
    #       break
    #     end
    #   end
    # end
    OpenStruct.new('src': src, 'movie_name': movie_name, 'original_title': original_title, 'release_date': release_date, 'director': director, 'gender': gender, 'synopsis': synopsis, 'cast': cast)
  end
end
