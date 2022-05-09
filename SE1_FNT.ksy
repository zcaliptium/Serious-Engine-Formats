# Copyright ZCaliptium 2021-2022
meta:
  id: fnt
  file-extension: fnt
  endian: le
seq:
  - id: magic
    contents: 'FTTF'
  - id: texture
    type: dfnm
  - id: char_width
    type: u4
  - id: char_height
    type: u4
  - id: chars
    type: font_char_data
    repeat: expr
    repeat-expr: 256
types:
  dfnm:
    seq:
      - id: magic
        contents: 'DFNM'
      - id: len
        type: u4
      - id: type
        type: str
        size: len
        encoding: ASCII
  font_char_data:
    seq:
      - id: offset_x
        type: u4
      - id: offset_y
        type: u4
      - id: start_x
        type: u4
      - id: start_y
        type: u4