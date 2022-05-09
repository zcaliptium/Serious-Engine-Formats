# Copyright ZCaliptium 2021-2022
meta:
  id: se1_bae
  file-extension: bae
  endian: le

seq:
  - id: header
    type: file_header
  - id: effects
    type: effect
    repeat: expr
    repeat-expr: header.count

types:
  file_header:
    seq:
      - id: magic
        contents: "AEFF"
      - id: count
        type: u4
        
  effect:
    seq:
      - id: magic
        contents: "ANEF"
      - id: version
        type: u1
      - id: anim_name
        type: ctstring
      - id: group_count
        type: u4
      - id: groups
        type: effect_group
        repeat: expr
        repeat-expr: group_count
        
  effect_group:
    seq:
      - id: name
        type: ctstring
      - id: start_time
        type: f4
      - id: flags
        type: u4
        
        
  ctstring:
    seq:
      - id: size
        type: u4
      - id: data
        type: str
        encoding: ASCII
        size: size