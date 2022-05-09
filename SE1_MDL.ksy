# Copyright ZCaliptium 2021-2022
meta:
  id: se1_mdl
  file-extension: mdl
  endian: le
seq:
  - id: header
    type: header_chunk
  - id: chunkid
    type: str
    size: 4
    encoding: ASCII
  - id: vertices
    type:
      switch-on: chunkid
      cases:
        '"AFVX"': afvx_chunk
        '"AV17"': av17_chunk
  - id: frame_infos
    type: afin_chunk
  - id: main_mip_vertices
    type: ammv_chunk
  - id: mip_masks
    type: avmk_chunk
  - id: mip_count
    type: imip_chunk
  - id: mip_factors
    type: fmip_chunk
  - id: model_mip_infos
    type: model_mip_info
    repeat: expr
    repeat-expr: _root.mip_count.count
  - id: patches_v2
    type: ptc2_chunk
  - id: texture_width
    type: stxw_chunk
  - id: texture_height
    type: stxh_chunk
  - id: shadow_quality
    type: u4
  - id: stretch
    type: float3d
  - id: center
    type: float3d
  # Collision
  - id: col_box_count
    type: u4
  - id: col_boxes
    type: model_collision_box
    repeat: expr
    repeat-expr: col_box_count
  - id: col_info
    type: coli_chunk
  - id: attached_pos_count
    type: u4
  # Attachment Positions
  - id: attached_positions
    type: model_attached_position
    repeat: expr
    repeat-expr: attached_pos_count
  # Color Names
  - id: color_names
    type: icln_chunk
  # Animation Frame References
  - id: animation_data
    type: adat_chunk
  # Colors
  - id: color_d
    type: u4
  - id: color_r
    type: u4
  - id: color_s
    type: u4
  - id: color_b
    type: u4

types:
  header_chunk:
    seq:
      - id: magic
        contents: 'MDAT'
      - id: version
        type: chunkid
      - id: flags
        type: mdl_flags
      - id: vtx_count
        type: ivtx_chunk
      - id: frame_count
        type: ifrm_chunk

  ivtx_chunk:
    seq:
      - id: magic
        contents: 'IVTX'
      - id: size
        type: u4
      - id: value
        type: u4

  ifrm_chunk:
    seq:
      - id: magic
        contents: 'IFRM'
      - id: size
        type: u4
      - id: value
        type: u4
        
  afvx_chunk:
    seq:
      - id: size
        type: u4
      - id: data
        type: model_frame_vertex8
        repeat: expr
        repeat-expr: _root.header.vtx_count.value * _root.header.frame_count.value

  av17_chunk:
    seq:
      - id: size
        type: u4
      - id: data
        type: model_frame_vertex16
        repeat: expr
        repeat-expr: _root.header.vtx_count.value * _root.header.frame_count.value
    instances:
      vertices_len:
        value: _root.header.vtx_count.value * _root.header.frame_count.value * 8
        
  afin_chunk:
    seq:
      - id: magic
        contents: 'AFIN'
      - id: size
        type: u4
      - id: boxes
        type: aabbox3d
        repeat: expr
        repeat-expr: _root.header.frame_count.value
        
  ammv_chunk:
    seq:
      - id: magic
        contents: 'AMMV'
      - id: size
        type: u4
      - id: vertices
        type: float3d
        repeat: expr
        repeat-expr: _root.header.vtx_count.value
        
  avmk_chunk:
    seq:
      - id: magic
        contents: 'AVMK'
      - id: size
        type: u4
      - id: masks
        type: u4
        repeat: expr
        repeat-expr: _root.header.vtx_count.value
        
  imip_chunk:
    seq:
      - id: magic
        contents: 'IMIP'
      - id: size
        type: u4
      - id: count
        type: u4
        
  fmip_chunk:
    seq:
      - id: magic
        contents: 'FMIP'
      - id: size
        type: u4
      - id: values
        type: f4
        repeat: expr
        repeat-expr: 32
        
  model_mip_info:
    seq:
      - id: ipol
        type: ipol_chunk
      - id: polygons
        type: mdp2_chunk
        repeat: expr
        repeat-expr: ipol.count
      - id: vtx_tex_count
        type: u4
      - id: texture_vertices
        type: txv2_chunk
      - id: mapping_srf_count
        type: u4
      - id: mapping_surfaces
        type: model_mapping_surface
        repeat: expr
        repeat-expr: mapping_srf_count
      - id: flags
        type: u4
      - id: patch_count
        type: u4
      # TODO:

  ipol_chunk:
    seq:
      - id: magic
        contents: 'IPOL'
      - id: size
        type: u4
      - id: count
        type: u4
        
  mdp2_chunk:
    seq:
      - id: magic
        contents: 'MDP2'
      - id: vtx_count
        type: u4
      - id: vertices
        type: model_polygon_vertex
        repeat: expr
        repeat-expr: vtx_count
      - id: flags
        type: u4
      - id: color
        type: u4
      - id: surface
        type: u4
        
  txv2_chunk:
    seq:
      - id: magic
        contents: 'TXV2'
      - id: size
        type: u4
      - id: members
        type: model_texture_vertex
        repeat: expr
        repeat-expr: _parent.vtx_tex_count
        
  model_polygon_vertex:
    seq:
      - id: vtx
        type: u4
      - id: texture_vtx
        type: u4
        
  model_texture_vertex:
    seq:
      - id: pos
        type: float3d
      - id: uv
        type: mex2d
      - id: data
        type: u4
      - id: vtx_transformed
        type: u4
      - id: u
        type: float3d
      - id: v
        type: float3d
        
  model_mapping_surface:
    seq:
      - id: id
        type: ctstring
      - id: offset_2d
        type: float3d
      - id: hpb
        type: float3d
      - id: zoom
        type: f4
      - id: shading_type
        type: u4
      - id: translucency_type
        type: u4
      - id: flags
        type: u4
      - id: polygon_count
        type: u4
      - id: polygons
        type: u4
        repeat: expr
        repeat-expr: polygon_count
      - id: vtx_tex_count
        type: u4
      - id: vtx_tex
        type: u4
        repeat: expr
        repeat-expr: vtx_tex_count
      - id: color
        type: u4
      - id: color_d
        type: u4
      - id: color_r
        type: u4
      - id: color_s
        type: u4
      - id: color_b
        type: u4
      - id: on_color
        type: u4
      - id: off_color
        type: u4
        
  ptc2_chunk:
    seq:
      - id: magic
        contents: 'PTC2'
      - id: patches
        type: model_patch
        repeat: expr
        repeat-expr: 32
        
  model_patch:
    seq:
      - id: id
        type: ctstring
      - id: file
        type: ctfilename
      - id: pos
        type: mex2d
      - id: stretch
        type: f4
        
  stxw_chunk:
    seq:
      - id: magic
        contents: 'STXW'
      - id: size
        type: u4
      - id: value
        type: u4
        
  stxh_chunk:
    seq:
      - id: magic
        contents: 'STXH'
      - id: size
        type: u4
      - id: value
        type: u4
        
  coli_chunk:
    seq:
      - id: magic
        contents: 'COLI'
      - id: collide_as_cube
        type: u4
        
  icln_chunk:
    seq:
      - id: magic
        contents: 'ICLN'
      - id: size
        type: u4
      - id: value
        type: u4
        
  adat_chunk:
    seq:
      - id: magic
        contents: 'ADAT'
      - id: count
        type: u4
      - id: name
        type: str
        size: 32
        encoding: ASCII
      - id: velocity
        type: u4
      - id: frame_count
        type: u4
      - id: frames
        type: u4
        repeat: expr
        repeat-expr: frame_count
        
        
  model_collision_box:
    seq:
      - id: min
        type: float3d
      - id: max
        type: float3d
      - id: name
        type: ctstring
        
  model_attached_position:
    seq:
      - id: vtx_c
        type: u4
      - id: vtx_f
        type: u4
      - id: vtx_u
        type: u4
      - id: pos_rel
        type: float3d
      - id: ros_rel
        type: float3d

  model_frame_vertex8:
    seq:
      - id: x
        type: s1
      - id: y
        type: s1
      - id: z
        type: s1
      - id: norm_index
        type: u1
        
  model_frame_vertex16:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: z
        type: s2
      - id: norm_h
        type: s1
      - id: norm_p
        type: s1

  ctstring:
    seq:
      - id: len
        type: u4
      - id: type
        type: str
        size: len
        encoding: ASCII
        
  ctfilename:
    seq:
      - id: magic
        contents: 'DFNM'
      - id: name
        type: ctstring

  chunkid:
    seq:
      - id: value
        type: str
        size: 4
        encoding: ASCII
        
  float3d:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
        
  aabbox3d:
    seq:
      - id: a
        type: float3d
      - id: b
        type: float3d
        
  mex2d:
    seq:
      - id: u
        type: u4
      - id: v
        type: u4
        
  mdl_flags:
    seq:
      - id: raw
        type: u4
    instances:
      face_forward:
        value: (raw & (1 << 0)) != 0
      reflections:
        value: (raw & (1 << 1)) != 0
      reflections_half:
        value: (raw & (1 << 2)) != 0
      half_face_forward:
        value: (raw & (1 << 3)) != 0
      compressed_16bit:
        value: (raw & (1 << 4)) != 0
      stretch_detail:
        value: (raw & (1 << 5)) != 0