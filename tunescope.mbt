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
/// Split one CSV row, supporting quoted commas and escaped double quotes.
fn parse_csv_fields(line : String) -> Array[String]? {
  let fields : Array[String] = []
  let chars = line.to_array()
  let mut current : Array[Char] = []
  let mut index = 0
  let mut in_quotes = false
  let mut after_quote = false

  while index < chars.length() {
    let char = chars[index]

    if in_quotes {
      if char == '"' {
        if index + 1 < chars.length() && chars[index + 1] == '"' {
          current.push('"')
          index = index + 2
        } else {
          in_quotes = false
          after_quote = true
          index = index + 1
        }
      } else {
        current.push(char)
        index = index + 1
      }
    } else if after_quote {
      if char == ',' {
        fields.push(String::from_array(current))
        current = []
        after_quote = false
        index = index + 1
      } else if char == ' ' || char == '\t' {
        index = index + 1
      } else {
        return None
      }
    } else if char == ',' {
      fields.push(String::from_array(current))
      current = []
      index = index + 1
    } else if char == '"' {
      if current.length() != 0 {
        return None
      }

      in_quotes = true
      index = index + 1
    } else {
      current.push(char)
      index = index + 1
    }
  }

  if in_quotes {
    return None
  }

  fields.push(String::from_array(current))
  Some(fields)
}

///|
/// Parse one playlist row in the format: title,artist,album
pub fn parse_track_line(line : String) -> Track? {
  let fields = match parse_csv_fields(line) {
    Some(fields) => fields
    None => return None
  }

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

///|
pub(all) struct ArtistStat {
  artist : String
  count : Int
} derive(Debug, Eq)

///|
/// Count tracks by artist and return a descending ranking.
pub fn artist_ranking(tracks : Array[Track]) -> Array[ArtistStat] {
  let counts : Map[String, Int] = Map([])

  for track in tracks {
    counts.update_or_default(track.artist, 1, count => count + 1)
  }

  let ranking : Array[ArtistStat] = []

  counts.each((artist, count) => ranking.push({ artist, count }))

  ranking.sort_by((a, b) => {
    if a.count > b.count {
      -1
    } else if a.count < b.count {
      1
    } else if a.artist < b.artist {
      -1
    } else if a.artist > b.artist {
      1
    } else {
      0
    }
  })

  ranking
}

///|
pub(all) struct DuplicateStat {
  title : String
  artist : String
  count : Int
} derive(Debug, Eq)

///|
/// Find duplicate tracks by normalized title and artist.
pub fn duplicate_tracks(tracks : Array[Track]) -> Array[DuplicateStat] {
  let positions : Map[String, Int] = Map([])
  let groups : Array[DuplicateStat] = []

  for track in tracks {
    let title = track.title.trim().to_owned()
    let artist = track.artist.trim().to_owned()
    let title_key = title.to_lower()
    let artist_key = artist.to_lower()
    let key = "\{artist_key.length()}:\{artist_key}\{title_key}"

    match positions.get(key) {
      Some(index) => {
        let existing = groups[index]
        groups[index] = {
          title: existing.title,
          artist: existing.artist,
          count: existing.count + 1,
        }
      }
      None => {
        positions.set(key, groups.length())
        groups.push({ title, artist, count: 1 })
      }
    }
  }

  let duplicates : Array[DuplicateStat] = []

  for group in groups {
    if group.count > 1 {
      duplicates.push(group)
    }
  }

  duplicates.sort_by((a, b) => {
    if a.count > b.count {
      -1
    } else if a.count < b.count {
      1
    } else if a.artist < b.artist {
      -1
    } else if a.artist > b.artist {
      1
    } else if a.title < b.title {
      -1
    } else if a.title > b.title {
      1
    } else {
      0
    }
  })

  duplicates
}

///|
pub(all) struct AlbumStat {
  album : String
  artist : String
  count : Int
} derive(Debug, Eq)

///|
/// Count tracks by album and artist, excluding empty album names.
pub fn album_ranking(tracks : Array[Track]) -> Array[AlbumStat] {
  let positions : Map[String, Int] = Map([])
  let ranking : Array[AlbumStat] = []

  for track in tracks {
    let album = track.album.trim().to_owned()
    let artist = track.artist.trim().to_owned()

    if album == "" {
      continue
    }

    let album_key = album.to_lower()
    let artist_key = artist.to_lower()
    let key = "\{artist_key.length()}:\{artist_key}\{album_key}"

    match positions.get(key) {
      Some(index) => {
        let existing = ranking[index]
        ranking[index] = {
          album: existing.album,
          artist: existing.artist,
          count: existing.count + 1,
        }
      }
      None => {
        positions.set(key, ranking.length())
        ranking.push({ album, artist, count: 1 })
      }
    }
  }

  ranking.sort_by((a, b) => {
    if a.count > b.count {
      -1
    } else if a.count < b.count {
      1
    } else if a.artist < b.artist {
      -1
    } else if a.artist > b.artist {
      1
    } else if a.album < b.album {
      -1
    } else if a.album > b.album {
      1
    } else {
      0
    }
  })

  ranking
}

///|
/// Escape one field so it can be safely written into a CSV file.
fn escape_csv_field(value : String) -> String {
  let chars = value.to_array()
  let escaped : Array[Char] = []
  let mut needs_quotes = false

  for char in chars {
    if char == '"' {
      escaped.push('"')
      escaped.push('"')
      needs_quotes = true
    } else {
      if char == ',' || char == '\n' || char == '\r' {
        needs_quotes = true
      }

      escaped.push(char)
    }
  }

  let content = String::from_array(escaped)

  if needs_quotes {
    "\"\{content}\""
  } else {
    content
  }
}

///|
/// Convert tracks into a complete CSV document.
pub fn tracks_to_csv(tracks : Array[Track]) -> String {
  let mut csv = "title,artist,album\n"

  for track in tracks {
    csv = csv +
      "\{escape_csv_field(track.title)}," +
      "\{escape_csv_field(track.artist)}," +
      "\{escape_csv_field(track.album)}\n"
  }

  csv
}

///|
test "export tracks to csv" {
  let tracks = [new_track("浮躁", "王菲", "浮躁")]
  let expected = "title,artist,album\n浮躁,王菲,浮躁\n"
  assert_eq(tracks_to_csv(tracks), expected)
}

///|
test "quote commas when exporting csv" {
  let tracks = [new_track("Song, Part 1", "Artist", "Album, Deluxe")]
  let expected = "title,artist,album\n\"Song, Part 1\",Artist,\"Album, Deluxe\"\n"
  assert_eq(tracks_to_csv(tracks), expected)
}

///|
test "escape double quotes when exporting csv" {
  let tracks = [new_track("He said \"Hi\"", "Artist", "Album")]
  let expected = "title,artist,album\n\"He said \"\"Hi\"\"\",Artist,Album\n"
  assert_eq(tracks_to_csv(tracks), expected)
}

///|
test "export empty playlist with header" {
  let tracks : Array[Track] = []
  let expected = "title,artist,album\n"
  assert_eq(tracks_to_csv(tracks), expected)
}
