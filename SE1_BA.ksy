# Copyright ZCaliptium 2021-2022
meta:
  id: se1_skamesh_ba
  file-extension: ba
  endian: le
seq:
  - id: header
    type: header_chunk
  - id: lods
    type: bone_animation
    repeat: expr
    repeat-expr: _root.header.anim_count

types:
  header_chunk:
    seq:
      - id: magic
        contents: 'ANIM'
      - id: version
        type: u4
      - id: anim_count
        type: u4
        
  bone_animation:
    seq:
      - id: source_file
        type: ctstring
      - id: id
        type: ctstring
      - id: secs_per_frame
        type: f4
      - id: frame_count
        type: u4
      - id: threshold
        type: f4
      - id: is_compressed
        type: u4
      - id: is_custom_speed
        type: u4
      - id: bone_envelope_count
        type: u4
      - id: bone_envelopes
        type: bone_envelope
        repeat: expr
        repeat-expr: bone_envelope_count
      - id: morph_envelope_count
        type: u4
      - id: morph_envelopes
        type: morph_envelope
        repeat: expr
        repeat-expr: morph_envelope_count

  bone_envelope:
    seq:
      - id: id
        type: ctstring
      - id: default_pos_m12
        type: f4
        repeat: expr
        repeat-expr: 12
      - id: position_count
        type: u4
      - id: positions
        type: anim_pos # size: 16
        repeat: expr
        repeat-expr: position_count
      - id: rotation_count
        type: u4
      - id: rotations
        size: 20
        repeat: expr
        repeat-expr: rotation_count
      - id: offset_length
        type: f4

  # struct AnimPos
  anim_pos:
    seq:
      - id: frame_number
        type: u2
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: pad
        size: 2
 
  morph_envelope:
    seq:
      - id: id
        type: ctstring
      - id: factor_count
        type: u4
      - id: factors
        type: f4
        repeat: expr
        repeat-expr: factor_count
      
  # VEC3F / Vector<float, 3> 
  float3d:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      
  # CTString
  ctstring:
    seq:
      - id: len
        type: u4
      - id: data
        type: str
        size: len
        encoding: ASCII