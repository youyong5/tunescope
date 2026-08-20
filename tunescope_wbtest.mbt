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
