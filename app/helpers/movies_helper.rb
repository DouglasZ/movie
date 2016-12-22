module MoviesHelper

  def icon_for(movie)
    case movie.status
      when 'waiting'
        'glyphicon-time orange'
      when 'downloaded'
        'glyphicon-save blue'
      when 'watched'
        'glyphicon-eye-open green'
    end
  end
end
