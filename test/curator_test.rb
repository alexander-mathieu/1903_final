require 'minitest/autorun'
require 'minitest/pride'
require './lib/photograph'
require './lib/artist'
require './lib/curator'
require 'csv'

class CuratorTest < MiniTest::Test

  def setup
    @photo_1 = Photograph.new({id:        "1",
                               name:      "Rue Mouffetard, Paris (Boy with Bottles)",
                               artist_id: "1",
                               year:      "1954"})

    @photo_2 = Photograph.new({id:        "2",
                               name:      "Moonrise, Hernandez",
                               artist_id: "2",
                               year:      "1941"})

    @photo_3 = Photograph.new({id:        "3",
                               name:      "Identical Twins, Roselle, New Jersey",
                               artist_id: "3",
                               year:      "1967"})

    @photo_4 = Photograph.new({id:        "4",
                               name:      "Monolith, The Face of Half Dome",      artist_id: "3",
                               year:      "1927"})

    @artist_1 = Artist.new({id:      "1",
                            name:    "Henri Cartier-Bresson",
                            born:    "1908",
                            died:    "2004",
                            country: "France"})

    @artist_2 = Artist.new({id:      "2",
                            name:    "Ansel Adams",
                            born:    "1902",
                            died:    "1984",
                            country: "United States"})

    @artist_3 = Artist.new({id:      "3",
                            name:    "Diane Arbus",
                            born:    "1923",
                            died:    "1971",
                            country: "United States"})

    @curator = Curator.new
  end

  def test_it_exists
    assert_instance_of Curator, @curator
  end

  def test_by_default_it_has_no_photos
    assert_empty @curator.photos
  end

  def test_it_can_add_photographs
    @curator.add_photo(@photo_1)
    @curator.add_photo(@photo_2)

    assert_equal [@photo_1, @photo_2], @curator.photos
  end

  def test_by_default_it_has_no_artists
    assert_empty @curator.artists
  end

  def test_it_can_add_artists
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal [@artist_1, @artist_2], @curator.artists
  end

  def test_it_can_find_an_artist_by_id
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal @artist_1, @curator.find_artist_by_id("1")
  end

  def test_it_can_find_a_photo_graph_by_id
    @curator.add_photo(@photo_1)
    @curator.add_photo(@photo_2)

    assert_equal @photo_2, @curator.find_photo_by_id("2")
  end

  def test_it_can_find_photos_by_artist
    @curator.add_photo(@photo_1)
    @curator.add_photo(@photo_2)
    @curator.add_photo(@photo_3)
    @curator.add_photo(@photo_4)

    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)

    assert_equal [@photo_3, @photo_4], @curator.find_photos_by_artist(@artist_3)
  end

  def test_it_can_find_artists_with_multiple_photos
    @curator.add_photo(@photo_1)
    @curator.add_photo(@photo_2)
    @curator.add_photo(@photo_3)
    @curator.add_photo(@photo_4)

    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)

    assert_equal [@artist_3], @curator.artists_with_multiple_photos
  end

  def test_it_can_find_all_artists_by_country
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)

    assert_equal [@artist_2, @artist_3], @curator.find_artists_by_country("United States")
  end

  def test_it_can_find_all_artist_ids_by_country
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)

    assert_equal ["2", "3"], @curator.find_artist_ids_by_country("United States")
  end

  def test_it_can_find_all_photos_taken_by_artists_from_a_country
    @curator.add_photo(@photo_1)
    @curator.add_photo(@photo_2)
    @curator.add_photo(@photo_3)
    @curator.add_photo(@photo_4)

    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)

    assert_equal [@photo_2, @photo_3, @photo_4], @curator.photos_taken_by_artists_from("United States")

    assert_empty @curator.photos_taken_by_artists_from("Argentina")
  end

  def test_it_can_load_photos_from_a_csv
    @curator.load_photos('./data/photographs.csv')

    assert_equal 4, @curator.photos.count

    @curator.photos.each do |photo|
      assert_instance_of Photograph, photo
    end
  end

  def test_it_can_load_artists_from_a_csv
    @curator.load_artists('./data/artists.csv')

    assert_equal 6, @curator.artists.count

    @curator.artists.each do |artist|
      assert_instance_of Artist, artist
    end
  end

  def test_it_can_return_photos_taken_between_a_range
    @curator.load_photos('./data/photographs.csv')

    assert_equal 2, @curator.photos_taken_between(1950..1965).count
  end

  def test_it_can_return_artist_photos_by_age
    @curator.load_photos('./data/photographs.csv')
    @curator.load_artists('./data/artists.csv')
    
    @diane_arbus = @curator.find_artist_by_id("3")

    expected = {44 => "Identical Twins, Roselle, New Jersey",
                39 => "Child with Toy Hand Grenade in Central Park"}

    assert_equal expected, @curator.artists_photographs_by_age(@diane_arbus)
  end

end
