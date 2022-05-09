# Copyright ZCaliptium 2021-2022
meta:
  id: se1_skamesh_bs
  file-extension: bs
  endian: le
seq:
  - id: header
    type: header_chunk
  - id: lods
    type: skeleton_lod
    repeat: expr
    repeat-expr: _root.header.lod_count

types:
  header_chunk:
    seq:
      - id: magic
        contents: 'SKEL'
      - id: version
        type: u4
      - id: lod_count
        type: u4
        
  skeleton_lod:
    seq:
      - id: source_file
        type: ctstring
      - id: max_distance
        type: f4
      - id: bone_count
        type: u4
      - id: bones
        type: skeleton_bone
        repeat: expr
        repeat-expr: bone_count
        
  skeleton_bone:
    seq:
      - id: id
        type: ctstring
      - id: parent_id
        type: ctstring
      - id: absolute_placement_matrix
        type: f4
        repeat: expr
        repeat-expr: 12
      - id: absolute_placement_q_vect
        type: qvect
      - id: offset_length
        type: f4
      - id: bone_length
        type: f4

  # VEC3F + Quaternion<float>
  qvect:
    seq:
      - id: pos
        type: float3d
      - id: w
        type: f4
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  
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
