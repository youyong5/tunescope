// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.
// Keep them focused; public behavior belongs in `_test.mbt`.

///|
test "count tracks by artist" {
  let tracks = [
    new_track("浮躁", "王菲", "浮躁"),
    new_track("分裂", "王菲", "浮躁"),
    new_track("不来也不去", "陈奕迅", "H3M"),
  ]
  let count = count_tracks_by_artist(tracks, "王菲")
  assert_eq(count, 2)
}

///|
test "parse valid playlist row" {
  let actual = parse_track_line("浮躁,王菲,浮躁")
  let expected = Some(new_track("浮躁", "王菲", "浮躁"))
  assert_eq(actual, expected)
}

///|
test "trim playlist fields" {
  let actual = parse_track_line("  浮躁  , 王菲 , 浮躁 ")
  let expected = Some(new_track("浮躁", "王菲", "浮躁"))
  assert_eq(actual, expected)
}

///|
test "reject row with too few fields" {
  assert_eq(parse_track_line("浮躁,王菲"), None)
}

///|
test "reject row with too many fields" {
  assert_eq(parse_track_line("浮躁,王菲,浮躁,其他"), None)
}

///|
test "reject row without title or artist" {
  assert_eq(parse_track_line(",王菲,浮躁"), None)
  assert_eq(parse_track_line("浮躁,,浮躁"), None)
}

///|
test "allow empty album" {
  let actual = parse_track_line("浮躁,王菲,")
  let expected = Some(new_track("浮躁", "王菲", ""))
  assert_eq(actual, expected)
}

///|
test "parse playlist with header" {
  let content = "title,artist,album\n浮躁,王菲,浮躁\n分裂,王菲,浮躁"
  let result = parse_playlist(content)

  assert_eq(result.total_rows, 2)
  assert_eq(result.tracks.length(), 2)
  assert_eq(result.invalid_rows, 0)
  assert_eq(result.tracks[0], new_track("浮躁", "王菲", "浮躁"))
}

///|
test "parse playlist without header" {
  let content = "浮躁,王菲,浮躁\n不来也不去,陈奕迅,H3M"
  let result = parse_playlist(content)

  assert_eq(result.total_rows, 2)
  assert_eq(result.tracks.length(), 2)
  assert_eq(result.invalid_rows, 0)
}

///|
test "ignore blank lines and support Windows line endings" {
  let content = "title,artist,album\r\n\r\n浮躁,王菲,浮躁\r\n  \r\n"
  let result = parse_playlist(content)

  assert_eq(result.total_rows, 1)
  assert_eq(result.tracks.length(), 1)
  assert_eq(result.invalid_rows, 0)
}

///|
test "count invalid playlist rows" {
  let content = "title,artist,album\n浮躁,王菲,浮躁\n错误数据\n,王菲,浮躁"
  let result = parse_playlist(content)

  assert_eq(result.total_rows, 3)
  assert_eq(result.tracks.length(), 1)
  assert_eq(result.invalid_rows, 2)
}

///|
test "parse empty playlist" {
  let result = parse_playlist("\n  \n\r\n")

  assert_eq(result.total_rows, 0)
  assert_eq(result.tracks.length(), 0)
  assert_eq(result.invalid_rows, 0)
}

///|
test "rank artists by track count" {
  let tracks = [
    new_track("浮躁", "王菲", "浮躁"),
    new_track("分裂", "王菲", "浮躁"),
    new_track("闷", "王菲", "王菲"),
    new_track("不来也不去", "陈奕迅", "H3M"),
    new_track("反高潮", "陈奕迅", "我的快乐时代"),
    new_track("两者", "张悬", "神的游戏"),
  ]

  let ranking = artist_ranking(tracks)

  assert_eq(ranking.length(), 3)
  assert_eq(ranking[0].artist, "王菲")
  assert_eq(ranking[0].count, 3)
  assert_eq(ranking[1].artist, "陈奕迅")
  assert_eq(ranking[1].count, 2)
  assert_eq(ranking[2].artist, "张悬")
  assert_eq(ranking[2].count, 1)
}

///|
test "sort equally ranked artists by name" {
  let tracks = [new_track("Song B", "B", ""), new_track("Song A", "A", "")]

  let ranking = artist_ranking(tracks)

  assert_eq(ranking[0].artist, "A")
  assert_eq(ranking[1].artist, "B")
}

///|
test "rank artists in empty playlist" {
  let ranking = artist_ranking([])
  assert_eq(ranking.length(), 0)
}

///|
test "detect duplicate tracks" {
  let tracks = [
    new_track("浮躁", "王菲", "浮躁"),
    new_track("浮躁", "王菲", "王菲"),
    new_track("分裂", "王菲", "浮躁"),
  ]

  let duplicates = duplicate_tracks(tracks)

  assert_eq(duplicates.length(), 1)
  assert_eq(duplicates[0].title, "浮躁")
  assert_eq(duplicates[0].artist, "王菲")
  assert_eq(duplicates[0].count, 2)
}

///|
test "detect duplicates ignoring spaces and English case" {
  let tracks = [
    new_track("  Song  ", " Artist ", "Album A"),
    new_track("song", "artist", "Album B"),
  ]

  let duplicates = duplicate_tracks(tracks)

  assert_eq(duplicates.length(), 1)
  assert_eq(duplicates[0].title, "Song")
  assert_eq(duplicates[0].artist, "Artist")
  assert_eq(duplicates[0].count, 2)
}

///|
test "keep same title by different artists separate" {
  let tracks = [
    new_track("Home", "Artist A", ""),
    new_track("Home", "Artist B", ""),
  ]

  let duplicates = duplicate_tracks(tracks)

  assert_eq(duplicates.length(), 0)
}

///|
test "sort duplicate groups by occurrence count" {
  let tracks = [
    new_track("Song A", "Artist A", ""),
    new_track("Song A", "Artist A", ""),
    new_track("Song B", "Artist B", ""),
    new_track("Song B", "Artist B", ""),
    new_track("Song B", "Artist B", ""),
  ]

  let duplicates = duplicate_tracks(tracks)

  assert_eq(duplicates.length(), 2)
  assert_eq(duplicates[0].title, "Song B")
  assert_eq(duplicates[0].count, 3)
  assert_eq(duplicates[1].title, "Song A")
  assert_eq(duplicates[1].count, 2)
}

///|
test "find duplicates in empty playlist" {
  let duplicates = duplicate_tracks([])
  assert_eq(duplicates.length(), 0)
}

///|
test "rank albums by track count" {
  let tracks = [
    new_track("浮躁", "王菲", "浮躁"),
    new_track("分裂", "王菲", "浮躁"),
    new_track("不来也不去", "陈奕迅", "H3M"),
    new_track("无专辑歌曲", "测试歌手", ""),
  ]

  let ranking = album_ranking(tracks)

  assert_eq(ranking.length(), 2)
  assert_eq(ranking[0].album, "浮躁")
  assert_eq(ranking[0].artist, "王菲")
  assert_eq(ranking[0].count, 2)
  assert_eq(ranking[1].album, "H3M")
  assert_eq(ranking[1].count, 1)
}

///|
test "keep same album name by different artists separate" {
  let tracks = [
    new_track("Song A", "Artist A", "Greatest Hits"),
    new_track("Song B", "Artist B", "Greatest Hits"),
  ]

  let ranking = album_ranking(tracks)

  assert_eq(ranking.length(), 2)
  assert_eq(ranking[0].artist, "Artist A")
  assert_eq(ranking[1].artist, "Artist B")
}

///|
test "merge album names ignoring spaces and English case" {
  let tracks = [
    new_track("Song A", " Artist ", " Album "),
    new_track("Song B", "artist", "album"),
  ]

  let ranking = album_ranking(tracks)

  assert_eq(ranking.length(), 1)
  assert_eq(ranking[0].album, "Album")
  assert_eq(ranking[0].artist, "Artist")
  assert_eq(ranking[0].count, 2)
}

///|
test "rank albums in empty playlist" {
  let ranking = album_ranking([])
  assert_eq(ranking.length(), 0)
}

///|
test "parse quoted comma in title" {
  let actual = parse_track_line("\"Song, Part 1\",Artist,Album")
  let expected = Some(new_track("Song, Part 1", "Artist", "Album"))
  assert_eq(actual, expected)
}

///|
test "parse escaped double quotes" {
  let actual = parse_track_line("\"He said \"\"Hi\"\"\",Artist,Album")
  let expected = Some(new_track("He said \"Hi\"", "Artist", "Album"))
  assert_eq(actual, expected)
}

///|
test "parse quoted comma in album" {
  let actual = parse_track_line("Song,Artist,\"Album, Deluxe\"")
  let expected = Some(new_track("Song", "Artist", "Album, Deluxe"))
  assert_eq(actual, expected)
}

///|
test "reject unclosed quoted field" {
  assert_eq(parse_track_line("\"Song,Artist,Album"), None)
}

///|
test "reject text after closing quote" {
  assert_eq(parse_track_line("\"Song\"oops,Artist,Album"), None)
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

///|
test "generate markdown playlist report" {
  let result = parse_playlist(
    "title,artist,album\n浮躁,王菲,浮躁\n浮躁,王菲,浮躁\n",
  )

  let expected = "# TuneScope Playlist Report\n\n" +
    "## Summary\n\n" +
    "- Source: `playlist.csv`\n" +
    "- Total rows: 2\n" +
    "- Valid tracks: 2\n" +
    "- Invalid rows: 0\n" +
    "- Unique artists: 1\n" +
    "- Known albums: 1\n" +
    "\n## Top Artists\n\n" +
    "1. 王菲 — 2 tracks\n" +
    "\n## Top Albums\n\n" +
    "1. 浮躁 — 王菲: 2 tracks\n" +
    "\n## Duplicate Tracks\n\n" +
    "- 浮躁 — 王菲: 2 copies\n"

  assert_eq(generate_markdown_report("playlist.csv", result), expected)
}

///|
test "generate markdown report for empty playlist" {
  let result = parse_playlist("title,artist,album\n")

  let expected = "# TuneScope Playlist Report\n\n" +
    "## Summary\n\n" +
    "- Source: `empty.csv`\n" +
    "- Total rows: 0\n" +
    "- Valid tracks: 0\n" +
    "- Invalid rows: 0\n" +
    "- Unique artists: 0\n" +
    "- Known albums: 0\n" +
    "\n## Top Artists\n\n" +
    "No valid artists found.\n" +
    "\n## Top Albums\n\n" +
    "No known albums found.\n" +
    "\n## Duplicate Tracks\n\n" +
    "No duplicate tracks found.\n"

  assert_eq(generate_markdown_report("empty.csv", result), expected)
}
