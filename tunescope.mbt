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

  let title = fields[0].trim().to_owned()
  let artist = fields[1].trim().to_owned()
  let album = fields[2].trim().to_owned()

  if title == "" || artist == "" {
    return None
  }

  Some(new_track(title, artist, album))
}

///|
pub(all) struct PlaylistParseResult {
  tracks : Array[Track]
  total_rows : Int
  invalid_rows : Int
} derive(Debug)

///|
/// Parse playlist text with an optional title,artist,album header.
pub fn parse_playlist(content : String) -> PlaylistParseResult {
  let tracks : Array[Track] = []
  let mut total_rows = 0
  let mut invalid_rows = 0
  let mut first_nonempty_line = true

  for raw_line in content.split("\n") {
    let line = raw_line.trim().to_owned()

    if line == "" {
      continue
    }

    if first_nonempty_line {
      first_nonempty_line = false
      if line == "title,artist,album" {
        continue
      }
    }

    total_rows = total_rows + 1

    match parse_track_line(line) {
      Some(track) => tracks.push(track)
      None => invalid_rows = invalid_rows + 1
    }
  }

  { tracks, total_rows, invalid_rows }
}
