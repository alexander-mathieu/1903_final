class Curator
  attr_reader :photos,
              :artists

  def initialize
    @photos  = []
    @artists = []
  end

  def add_photo(photo)
    @photos << photo
  end

  def add_artist(artist)
    @artists << artist
  end

  def find_artist_by_id(id)
    @artists.find {|artist| artist.id == id}
  end

  def find_photo_by_id(id)
    @photos.find {|photo| photo.id == id}
  end

  def artists_with_multiple_photos
    @artists.find_all {|artist| find_photos_by_artist(artist).count > 1}
  end

  def find_photos_by_artist(artist)
    @photos.find_all {|photo| photo.artist_id == artist.id}
  end

  def photos_taken_by_artists_from(country)
    artist_ids = find_artist_ids_by_country(country)
    @photos.find_all {|photo| artist_ids.include?(photo.artist_id)}
  end

  def find_artist_ids_by_country(country)
    find_artists_by_country(country).map {|artist| artist.id}
  end

  def find_artists_by_country(country)
    @artists.find_all {|artist| artist.country == country}
  end

  def load_photos(file_path)
    format_options = {headers: true, header_converters: :symbol, force_quotes: true}
    photos = CSV.read(file_path, format_options)
    photos.map {|attributes| add_photo(Photograph.new(attributes))}
  end

  def load_artists(file_path)
    format_options = {headers: true, header_converters: :symbol, force_quotes: true}
    artists = CSV.read(file_path, format_options)
    artists.map {|attributes| add_artist(Artist.new(attributes))}
  end

  def photos_taken_between(range)
    @photos.find_all {|photo| range.to_a.include?(photo.year.to_i)}
  end

  def artists_photographs_by_age(artist)
    @photos.inject({}) do |ages, photo|
      if photo.artist_id == artist.id
        ages[photo.year.to_i - artist.born.to_i] = photo.name
      end
        ages
    end
  end

end
