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
}
