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
