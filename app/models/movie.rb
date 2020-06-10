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
      doc = Nokogiri::HTML.parse(open(url))
      nodes = doc.css("div.sub-body main.content-layout section.movies-results ul li.mdl")
      nodes.each do |node|
        checkYear = node.css('div.meta-body div.meta-body-info span.date').text.split(' ')
        checkYear = checkYear.length == 5 ? checkYear[4].to_i : checkYear[1].to_i

        if checkYear == year.to_i

          movie_name = node.css('div.content-title span.meta-title-link').text

          release_date = node.css('div.meta-body div.meta-body-info span.date').text.split(' ')
          if release_date.length == 2
            release_date = '01/'+month[release_date[0].mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s]+'/'+release_date[1]
          else
            release_date[0] = release_date[0].to_i < 10 ? '0'+release_date[0] : release_date[0]
            release_date = release_date[0]+'/'+month[release_date[2].mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s]+'/'+release_date[4]
          end

          directors = node.css('div.meta-body div.meta-body-direction span.blue-link')
          directors.each_with_index do |director_text, index|
            if directors.length == index+1
              director += director_text.text
            else
              director += director_text.text+', '
            end
          end

          node.css('div.meta-body div.meta-body-actor span').drop(1).each_with_index do |cast_text, index|
            if  index+1 == 3
              cast += cast_text.text
            elsif index+1 < 3
              cast += cast_text.text+', '
            end
          end
          break
        end
      end
    end

    url = URI.parse('https://www.themoviedb.org/search/movie?query='+URI.encode(name)+'&language=pt-BR')

    Timeout::timeout(10) do
      doc = Nokogiri::HTML.parse(open(url))
      nodes = doc.css("section.search_results div.search_results.movie div.results div.card.v4.tight")
      nodes.each do |node|

        date = node.css('div.details div.wrapper span.release_date').text.split(' ')
        checkYear = date[4].to_i
        checkMonth = month[date[2].mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s].to_i
        checkYear = checkYear == year.to_i ? checkYear : checkMonth == 12 ? checkYear+1 : checkYear
        if checkYear == year.to_i

          url_detail = URI.parse('https://www.themoviedb.org'+node.css('div.title a').xpath('@href').text)
          detail = Nokogiri::HTML(open(url_detail))

          genders = detail.css('section#original_header div.header_poster_wrapper div.title span.genres a')
          genders.each_with_index do |gender_text, index|
            if gender_text.text != "/"
              if genders.length == index+1
                gender += gender_text.text
              else
                gender += gender_text.text+', '
              end
            end
          end

          synopsis = detail.css('section#original_header div.header_poster_wrapper div.header_info div.overview p').text.strip

          url_detail_US = URI.parse('https://www.themoviedb.org'+node.css('div.title a').xpath('@href').text.split('?')[0]+'?language=en-US')
          detail_US = Nokogiri::HTML(open(url_detail_US))

          original_title = detail_US.css('section#original_header div.header_poster_wrapper div.title h2 a').text
          original_title = !original_title.empty? ? original_title : movie_name

          src = detail_US.css('section#original_header div.poster div.image_content img').attr('data-src')
          break
        end
      end
    end
    OpenStruct.new('src': src, 'movie_name': movie_name, 'original_title': original_title, 'release_date': release_date, 'director': director, 'gender': gender, 'synopsis': synopsis, 'cast': cast)
  end
end
