import color.{type Color, to_pixel}
import file_streams/file_stream.{type FileStream, write_chars}
import gleam/int
import gleam/io

pub fn write_header(image_width: Int, image_height: Int) {
  io.println(
    "P3\n"
    <> int.to_string(image_width)
    <> " "
    <> int.to_string(image_height)
    <> "\n256",
  )
}

pub fn write_color(c: Color) {
  c |> to_pixel |> write_pixel
}

pub fn write_pixel(p: #(Int, Int, Int)) {
  let #(r, g, b) = p

  io.println(
    int.to_string(r) <> " " <> int.to_string(g) <> " " <> int.to_string(b),
  )
}

pub fn write_header_f(file: FileStream, image_width: Int, image_height: Int) {
  let assert Ok(_) =
    file
    |> write_chars(
      "P3\n"
      <> int.to_string(image_width)
      <> " "
      <> int.to_string(image_height)
      <> "\n256\n",
    )

  Nil
}

pub fn write_color_f(file: FileStream, c: Color) {
  write_pixel_f(file, to_pixel(c))
}

pub fn write_pixel_f(file: FileStream, p: #(Int, Int, Int)) {
  let #(r, g, b) = p

  let assert Ok(_) =
    file
    |> write_chars(
      int.to_string(r)
      <> " "
      <> int.to_string(g)
      <> " "
      <> int.to_string(b)
      <> "\n",
    )

  Nil
}
