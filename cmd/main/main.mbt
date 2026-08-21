///|
fn main {
  let args = @env.args()

  if args.length() < 2 {
    println(
      "Usage: moon run cmd/main -- <playlist.csv> [cleaned.csv] [report.md]",
    )
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
  if args.length() >= 3 {
    let output_path = args[2]
    let cleaned_csv = @lib.tracks_to_csv(result.tracks)

    @fs.write_string_to_file(output_path, cleaned_csv) catch {
      _ => {
        println("")
        println("Failed to write cleaned file: \{output_path}")
        return
      }
    }

    println("")
    println("Cleaned playlist written to: \{output_path}")
  }
  if args.length() >= 4 {
    let report_path = args[3]
    let report = @lib.generate_markdown_report(path, result)

    @fs.write_string_to_file(report_path, report) catch {
      _ => {
        println("")
        println("Failed to write Markdown report: \{report_path}")
        return
      }
    }

    println("Markdown report written to: \{report_path}")
  }
}
