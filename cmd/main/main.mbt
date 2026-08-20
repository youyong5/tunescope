///|
fn main {
  let tracks = [
    @lib.new_track("浮躁", "王菲", "浮躁"),
    @lib.new_track("分裂", "王菲", "浮躁"),
    @lib.new_track("不来也不去", "陈奕迅", "H3M"),
  ]
  let count = @lib.count_tracks_by_artist(tracks, "王菲")
  println("TuneScope demo")
  println("王菲：\{count} 首")
}
