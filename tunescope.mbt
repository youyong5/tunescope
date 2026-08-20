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
// Put public APIs and shared helpers here.
// Keep blocks small and focused for easy refactors.
