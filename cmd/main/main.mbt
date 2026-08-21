///|
fn main {
  let args = @env.args()

  if args.length() < 2 {
    println("Usage: moon run cmd/main -- <playlist.csv>")
    return
  }

  let path = args[1]
  let content = @fs.read_file_to_string(path) catch {
    _ => {
      println("Failed to read file: \{path}")
      return
    }
  }

  let result = @lib.parse_playlist(content)

  println("TuneScope playlist report")
  println("File: \{path}")
  println("Total rows: \{result.total_rows}")
  println("Valid tracks: \{result.tracks.length()}")
  println("Invalid rows: \{result.invalid_rows}")

  let ranking = @lib.artist_ranking(result.tracks)

  println("")
  println("Top artists:")

  let mut position = 1
  for stat in ranking {
    if position > 5 {
      break
    }

    println("\{position}. \{stat.artist}: \{stat.count}")
    position = position + 1
  }

  let albums = @lib.album_ranking(result.tracks)

  println("")
  println("Unique artists: \{ranking.length()}")
  println("Known albums: \{albums.length()}")

  println("")
  println("Top albums:")

  let mut album_position = 1
  for album in albums {
    if album_position > 5 {
      break
    }

    println(
      "\{album_position}. \{album.album} — \{album.artist}: \{album.count}",
    )
    album_position = album_position + 1
  }

  let duplicates = @lib.duplicate_tracks(result.tracks)

  println("")
  println("Duplicate tracks: \{duplicates.length()} groups")

  if duplicates.length() == 0 {
    println("No duplicate tracks found.")
  } else {
    for duplicate in duplicates {
      println(
        "- \{duplicate.title} — \{duplicate.artist} (\{duplicate.count} copies)",
      )
    }
  }
}
