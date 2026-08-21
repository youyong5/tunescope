///|
pub struct Track {
  title : String
  artist : String
  album : String
} derive(Debug, Eq)

///|
pub fn new_track(title : String, artist : String, album : String) -> Track {
  { title, artist, album }
}

///|
pub fn count_tracks_by_artist(tracks : Array[Track], artist : String) -> Int {
  let mut count = 0
  for track in tracks {
    if track.artist == artist {
      count = count + 1
    }
  }
  count
}


///|
/// Parse one playlist row in the format: title,artist,album
pub fn parse_track_line(line : String) -> Track? {
  let fields = line.split(",").collect()

  if fields.length() != 3 {
    return None
  }

  let title = fields[0].trim().to_string()
  let artist = fields[1].trim().to_string()
  let album = fields[2].trim().to_string()

  if title == "" || artist == "" {
    return None
  }

  Some(new_track(title, artist, album))
}