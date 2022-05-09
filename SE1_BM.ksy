# Copyright ZCaliptium 2021-2022
meta:
  id: se1_skamesh_bm
  file-extension: bm
  endian: le
seq:
  - id: header
    type: header_chunk
  - id: lods
    type:
      switch-on: _root.header.version
      cases:
        11: lod_chunk_old
        12: lod_chunk_old
        16: lod_chunk
    repeat: expr
    repeat-expr: _root.header.lod_count

types:
  header_chunk:
    seq:
      - id: magic
        contents: 'MESH'
      - id: version
        type: u4
      - id: size
        type: u4
        if: version > 12
      - id: lod_count
        type: u4
        
  lod_chunk_old:
    seq:
      - id: source_file
        type: ctstring
      - id: max_distance
        type: f4
      - id: flags
        type: lod_flags
      - id: vtx_count
        type: u4
      # Vertices.
      - id: vertices
        type: mesh_vertex_old
        repeat: expr
        repeat-expr: vtx_count
      # Normals.
      - id: normals
        type: mesh_normal
        repeat: expr
        repeat-expr: vtx_count
      # UV Maps.
      - id: uv_count
        type: u4
      - id: uv_maps
        type: mesh_uv_old
        repeat: expr
        repeat-expr: uv_count
      # Surfaces.
      - id: surface_count
        type: u4
      - id: surfaces
        type: mesh_surface_old
        repeat: expr
        repeat-expr: surface_count
      # Weight Maps.
      - id: weight_count
        type: u4
      - id: weight_maps
        type: mesh_weight_map
        repeat: expr
        repeat-expr: weight_count
      # Morph Maps.
      - id: morph_count
        type: u4
      - id: morph_maps
        type: mesh_morph_map_old
        repeat: expr
        repeat-expr: morph_count

  lod_chunk:
    seq:
      # VTX count.
      - id: vtx_count
        type: u4
      # UV count.
      - id: uv_count
        type: u4
      - id: surface_count
        type: u4
      - id: weight_count
        type: u4
      - id: morph_count
        type: u4
      - id: weight_info_count
        type: u4
      - id: source_file
        type: ctstring
      - id: max_distance
        type: f4
      - id: flags
        type: lod_flags
      # Vertices / 3 x 4 byte float
      - id: vertices
        type: float3d
        repeat: expr
        repeat-expr: vtx_count
      # Normal / 3 x 4 byte float
      - id: normals
        type: float3d
        repeat: expr
        repeat-expr: vtx_count
      # UV maps.
      - id: uv_maps
        type: mesh_uv
        repeat: expr
        repeat-expr: uv_count
      # Surfaces.
      - id: surfaces
        type: mesh_surface
        repeat: expr
        repeat-expr: surface_count
      # Weight Maps.
      - id: weight_maps
        type: mesh_weight_map
        repeat: expr
        repeat-expr: weight_count
      # Morph Maps.
      - id: morph_maps
        type: mesh_morph_map
        repeat: expr
        repeat-expr: morph_count
      # Weight Map Infos.
      - id: weight_map_infos
        type: mesh_weight_map_info
        repeat: expr
        repeat-expr: weight_info_count
        
  lod_flags:
    seq:
      - id: data
        type: u4

    instances:
      is_half_face_forward:
        value: (data & 1) >> 0
    
      is_full_face_forward:
        value: (data & 2) >> 1
      
      is_use_vertex_program:
        value: (data & 4) >> 2
        
      is_surface_relative_vertices:
        value: (data & 8) >> 3
        
      is_normalized_weights:
        value: (data & 16) >> 4
  
  # BM 12
  mesh_uv_old:
    seq:
      - id: id
        type: ctstring
      - id: uv_coords
        type: mesh_uv_coord
        repeat: expr
        repeat-expr: _parent.vtx_count

  # BM 16
  mesh_uv:
    seq:
      - id: id
        type: ctstring
      - id: uv_coords
        type: mesh_uv_coord
        repeat: expr
        repeat-expr: _parent.vtx_count
    
  ctstring:
    seq:
      - id: len
        type: u4
      - id: type
        type: str
        size: len
        encoding: ASCII
        
  mesh_vertex_old:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: dummy
        type: u4
        
  mesh_normal:
    seq:
      - id: nx
        type: f4
      - id: ny
        type: f4
      - id: nz
        type: f4
      - id: dummy
        type: u4
        
  mesh_uv_coord:
    seq:
      - id: u
        type: f4
      - id: v
        type: f4
        
  # BM 12
  mesh_surface_old:
    seq:
      - id: id
        type: ctstring
      - id: first_vtx
        type: s4
      - id: vtx_count
        type: u4
      - id: tri_count
        type: u4
      - id: triangles
        type: mesh_triangle_old
        repeat: expr
        repeat-expr: tri_count
      - id: shader_exists
        type: u4
      - id: shader_params
        type: mesh_shader_params
        if: shader_exists > 0
        
  # BM 16
  mesh_surface:
    seq:
      - id: id
        type: ctstring
      - id: flags
        type: u4
      - id: first_vtx
        type: u4
      - id: vtx_count
        type: u4
      - id: tri_count
        type: u4
      - id: triangles
        type: mesh_triangle
        repeat: expr
        repeat-expr: tri_count
      - id: relative_wmi_count
        type: u4
      - id: relative_wmi
        type: u1
        repeat: expr
        repeat-expr: relative_wmi_count
      - id: shader_exists
        type: u4
      - id: shader_params
        type: mesh_shader_params
        if: shader_exists > 0

  mesh_shader_params:
    seq:
      # Param Count
      - id: tex_count
        type: u4
      - id: uv_count
        type: u4
      - id: color_count
        type: u4
      - id: float_count
        type: u4
      # Shader Name
      - id: shader_name
        type: ctstring
      # Params
      - id: textures
        type: ctstring
        repeat: expr
        repeat-expr: tex_count
      - id: uv_maps
        type: u4
        repeat: expr
        repeat-expr: uv_count
      - id: colors
        type: u4
        repeat: expr
        repeat-expr: color_count
      - id: float_params
        type: f4
        repeat: expr
        repeat-expr: float_count
      - id: shader_flags
        type: u4
        if: _root.header.version > 11
        
  # BM 12
  mesh_triangle_old:
    seq:
      - id: vertices
        type: u4
        repeat: expr
        repeat-expr: 3
        
  # BM 16
  mesh_triangle:
    seq:
      - id: vertices
        type: u2
        repeat: expr
        repeat-expr: 3
        
  mesh_weight_map:
    seq:
      - id: id
        type: ctstring
      - id: vtx_count
        type: u4
      - id: vertices
        type: mesh_vertex_weight
        repeat: expr
        repeat-expr: vtx_count
        
  mesh_vertex_weight:
    seq:
      - id: vtx
        type: u4
      - id: weight
        type: f4
  
  # BM 12
  mesh_morph_map_old:
    seq:
      - id: id
        type: ctstring
      - id: is_relative
        type: u4
      - id: set_count
        type: u4
      - id: sets
        type: mesh_vertex_morph_old
        repeat: expr
        repeat-expr: set_count
  
  # BM 12
  mesh_vertex_morph_old:
    seq:
      - id: vtx
        type: u4
      - id: pos
        type: float3d
      - id: normal
        type: float3d
      - id: dummy
        type: u4
  
  # BM 16
  mesh_morph_map:
    seq:
      - id: id
        type: ctstring
      - id: is_relative
        type: u4
      - id: set_count
        type: u4
      - id: sets
        type: mesh_vertex_morph
        repeat: expr
        repeat-expr: set_count
        
  # BM 16
  mesh_vertex_morph:
    seq:
      - id: vtx
        type: u4
      - id: pos
        type: float3d
      - id: normal
        type: float3d
        
  mesh_weight_map_info:
    seq:
      - id: indices
        type: u1
        repeat: expr
        repeat-expr: 4
      - id: weights
        type: u1
        repeat: expr
        repeat-expr: 4
        
  float3d:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4