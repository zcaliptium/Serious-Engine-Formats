# Copyright ZCaliptium 2021-2022
meta:
  id: wld
  file-extension: wld
  endian: le
seq:
  # Build Version
  - id: build_version
    type: build_version_section
    if: file_type == file_type::wld
  - id: world
    type: world_section
    if: file_type == file_type::wld
  - id: trar
    type: data_chunk
    if: file_type == file_type::wtr

instances:
  # Use 'wld' or 'wtr' to parse world documents or separately saved terrains.
  file_type:
    value: file_type::wld

  # Use 'classic'. To parse WLD from other SE1 games use 'abz' or 'nitro_family' 
  brush_format:
    value: brush_format::classic
    
  # Use 'classic' or 'last_chaos'.
  terrain_format:
    value: terrain_format::classic
    
  parse_entx:
    value: false
    
  parse_properties:
    value: false

types:
  # Build version
  build_version_section:
    seq:
      - id: magic
        contents: 'BUIV'
      - id: number
        type: u4
  world_section:
    seq:
      - id: start
        contents: 'WRLD'
      - id: chunks
        type: data_chunk
        repeat: eos
  
  data_chunk:
    seq:
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: body
        type:
          switch-on: type
          cases:
            '"WLIF"': world_info_chunk
            '"DPOS"': u4
            '"BRAR"': brushes_chunk
            '"TRAR"': terrains_chunk
            '"DICT"': dict_chunk
            '"WSTA"': state_chunk
        if: type != "WEND"
            
  state_chunk:
    seq:
      - id: version
        type: u4
      - id: info
        type: chunk_at_state
      - id: bcg_color
        type: u4
      - id: nfid
        type: chunk_at_state
      - id: bgvm
        type: chunk_at_state
      - id: backdrop
        type: chunk_at_state
      - id: bdro
        type: chunk_at_state
      - id: vwps
        type: chunk_at_state
      - id: tbps
        type: chunk_at_state
      - id: ens2
        type: chunk_at_state
      - id: enor
        type: chunk_at_state
      - id: esl2
        type: chunk_at_state
        
  chunk_at_state:
    seq:
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: body
        type:
          switch-on: type
          cases:
            '"WLIF"': world_info_chunk
            '"NFID"': state_nfid_chunk
            '"BGVW"': state_bgvw_chunk
            '"BRDP"': state_backdrop_chunk
            '"BDRO"': state_bdro_chunk
            '"VWPS"': state_vwps_chunk
            '"TBPS"': state_vwps_chunk
            '"ENs2"': state_ens2_chunk
            '"ENOR"': state_enor_chunk
            '"ESL2"': state_esl2_chunk
            
  state_nfid_chunk:
    seq:
      - id: id
        type: u4
            
  state_bgvw_chunk:
    seq:
      - id: id
        type: u4
        
  state_backdrop_chunk:
    seq:
      - id: up_len
        type: u4
      - id: up_str
        type: str
        size: up_len
        encoding: ASCII
      - id: ft_len
        type: u4
      - id: ft_str
        type: str
        size: ft_len
        encoding: ASCII
      - id: rt_len
        type: u4
      - id: rt_str
        type: str
        size: rt_len
        encoding: ASCII
      - id: upw
        type: f4
      - id: upl
        type: f4
      - id: upcx
        type: f4
      - id: upcz
        type: f4
      # Front
      - id: ftw
        type: f4
      - id: fth
        type: f4
      - id: ftcx
        type: f4
      - id: ftcy
        type: f4
      # Front
      - id: rtl
        type: f4
      - id: rth
        type: f4
      - id: rtcz
        type: f4
      - id: rtcy
        type: f4
        
  state_bdro_chunk:
    seq:
      - id: len
        type: u4
      - id: str
        type: str
        size: len
        encoding: ASCII
        
  state_vwps_chunk:
    seq:
      - id: focus
        type: placement3d
      - id: target_distance
        type: f4
        
  state_ens2_chunk:
    seq:
      - id: count
        type: u4 
      - id: entities_meta
        type: ens2_entry
        repeat: expr
        repeat-expr: count
      - id: entities_data
        type: entity_data
        repeat: expr
        repeat-expr: count
        
  state_enor_chunk:
    seq:
      - id: count
        type: u4
      - id: entities
        type: u4
        repeat: expr
        repeat-expr: count
        
  state_esl2_chunk:
    seq:
      - id: version
        type: u4
      - id: chunksize
        type: u4
      - id: bytes
        size: chunksize
      - id: end_id
        contents: 'ESLE'
        
  esl2_entry:
    seq:
      - id: id
        type: u4
#      - id: link_count
#        type: u4
#        if: u4 != -1
#      - id: links
#        type: u4
#        repeat: expr
#        repeat-expr: link_count
#        if: u4 != -1
        
  ens2_entry:
    seq:
      - id: id
        type: u4
      - id: class_id
        type: u4
      - id: placement
        type: placement3d
        
  entity_data:
    seq:
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: id
        type: u4
      - id: size
        type: u4
      - id: data
        size: size
        type:
          switch-on: type
          cases:
            '"ENT4"': ent4_chunk
#            '"ENT5"': ent4_chunk
            
  ent4_chunk:
    seq:
      - id: render_type
        type: u4
        enum: entity_render_type
      - id: physics_flags
        type: u4
      - id: collision_flags
        type: u4
      - id: spawn_flags
        type: u4
      - id: flags
        type: u4
      - id: rot_matrix
        type: floatmatrix3d
      - id: render_data
        type:
          switch-on: render_type
          cases:
            entity_render_type::brush: u4
            entity_render_type::fieldbrush: u4
            entity_render_type::model: model_object_root
            entity_render_type::editormodel: model_object_root
            entity_render_type::terrain: u4
            entity_render_type::skamodel: skamodel_instance
            entity_render_type::skaeditormodel: skamodel_instance
        if: _root.parse_entx == true
      # Nex
      - id: next_id
        type: str
        size: 4
        encoding: ASCII
        if: is_model == 0 and _root.parse_entx == true
      - id: parent
        type: parent_data
        if: is_model == 0 and _root.parse_entx == true and next_id == "PART"
      - id: properties_id
        contents: 'PRPS'
        if: is_model == 0 and _root.parse_entx == true and next_id == "PART"
        if: is_model == 0 and _root.parse_entx == true and _root.parse_properties == true
      - id: properties
        type: entity_properties
        if: _root.parse_entx == true and _root.parse_properties == true
    instances:
      is_model:
        value: (render_type == entity_render_type::model) or (render_type == entity_render_type::editormodel) ? (1) : (0)
     
  entity_properties:
    seq:
      - id: count
        type: u4
      - id: properties
        type: entity_property
        repeat: expr
        repeat-expr: count
        
  entity_property:
    seq:
      - id: id_and_type
        type: u4
      - id: data
        type:
          switch-on: property_type
          cases:
            entity_property_type::enum: u4
            entity_property_type::boolean: u4
            entity_property_type::float: f4
            entity_property_type::color: u4
            entity_property_type::string: ctstring
            entity_property_type::range: f4
            entity_property_type::entityptr: u4
            entity_property_type::filename: u4
            entity_property_type::index: s4
            entity_property_type::animation: s4
            entity_property_type::illuminationtype: s4
            entity_property_type::floataabbox3d: floataabbox3d
            entity_property_type::angle: f4
            entity_property_type::float3d: float3d
            entity_property_type::angle3d: float3d
            entity_property_type::floatplane3d: floatplane3d
            #entity_property_type::modelobject u4
            entity_property_type::placement3d: placement3d
            entity_property_type::animobject: anim_object_root
            entity_property_type::filenamenodep: ctstring
            entity_property_type::soundobject: sound_object
            entity_property_type::stringtrans: stringtrans
            entity_property_type::floatquat3d: floatquat3d
            entity_property_type::flags: u4
            #entity_property_type::modelinstance u4

    instances:
      property_id:
        value: 'id_and_type >> 8'
      property_type:
        value: 'id_and_type & 0x000000FF'
        enum: entity_property_type
  
  anim_object_root:
    seq:
      - id: res_id
        type: u4
      - id: object
        type: anim_object(1)
   
  sound_object:
    seq:
      - id: sound_id
        type: u4
      - id: dropped_out
        type: u4
      - id: flags
        type: u4
      - id: left_volume
        type: f4
      - id: right_volume
        type: f4
      - id: left_filter
        type: u4
      - id: right_filter
        type: u4
      - id: pitch_shift
        type: f4
      - id: phase_shift
        type: f4
      - id: delay
        type: f4
      - id: delayed
        type: f4
      - id: last_left_volume
        type: f4
      - id: last_right_volume
        type: f4
      - id: last_left_sample
        type: u2
      - id: last_right_sample
        type: u2
      - id: left_offset
        type: f4
      - id: right_offset
        type: f4
      - id: offset_delta
        type: f4
      - id: falloff
        type: f4
      - id: hotspot
        type: f4
      - id: max_volume
        type: f4
      - id: pitch
        type: f4
        
  model_object_root:
    seq:
      - id: object
        type: model_render_data(1)

  model_render_data:
    params:
      - id: anob_has_magic
        type: u4
    seq:
      - id: ref
        type: u4
      - id: animation
        type: anim_object(anob_has_magic)
      - id: magic_2
        contents: 'MODT'
      - id: blend_color
        type: u4
      - id: patch_mask
        type: u4
      - id: stretch
        type: float3d
      - id: color_mask
        type: u4
      # Textures
      - id: magic_3
        contents: 'MTEX'
      - id: texture_d
        type: texture_object
      - id: texture_b
        type: texture_object
      - id: texture_r
        type: texture_object
      - id: texture_s
        type: texture_object
      # Attachments
      - id: next_magic
        type: str
        size: 4
        encoding: ASCII
      - id: attachments
        type: model_attachments
        if: next_magic == "ATCH"
      - id: parent
        type: parent_data
        if: next_magic == "PART"
      - id: prps_id
        type: u4
        if: next_magic == "PART"
        
  model_attachments:
    seq:
      - id: count
        type: u4
      - id: entries
        type: model_attachments_entry(_index)
        repeat: expr
        repeat-expr: count
        
  parent_data:
    seq:
      - id: id
        type: u4
      - id: offset
        type: placement3d
        
  model_attachments_entry:
    params:
      - id: i
        type: u4
    seq:
      - id: position_id
        type: u4
      - id: relative_offset
        type: placement3d
      - id: object
        type:
          switch-on: i
          cases:
            0: model_render_data(1) # First one always has magic tag.
            _: model_render_data(0)

  skamodel_instance:
    seq:
      - id: start_id
        contents: 'MI03'
      # MISF chunk may be optional
      - id: misf_or_len
        type: u4
      - id: source_resource_id
        type: u4
        if: misf_or_len == 1179863373
      # Instance name
      - id: instance_name_len
        type: u4
        if: misf_or_len == 1179863373
      - id: instance_name
        type: str
        size: name_len_inst
        encoding: ASCII
      - id: current_box_id
        type: u4
      - id: stretch
        type: float3d
      - id: color
        type: u4
      - id: instances
        type: skamodel_mshi
      - id: skeleton
        type: skamodel_skel
      - id: animations
        type: skamodel_anas
      - id: anim_queue
        type: skamodel_miaq
      - id: collision_info
        type: skamodel_micb
      - id: offset_and_children
        type: skamodel_miof_entry
      - id: end_magic
        contents: 'ME03'
    instances:
      name_len_inst:
        value: (misf_or_len == 1179863373) ? (instance_name_len) : (misf_or_len)
        
  skamodel_mshi:
    seq:
      - id: start_id
        contents: 'MSHI'
      - id: mesh_count
        type: u4
      - id: entries
        type: skamodel_mshi_entry
        repeat: expr
        repeat-expr: mesh_count
        
  skamodel_mshi_entry:
    seq:
      - id: start_magic
        contents: 'MESH'
      - id: mesh_res_id
        type: u4
      - id: textures_magic
        contents: 'MITS'
      - id: texture_count
        type: u4
      - id: textures
        type: skamodel_mshi_texture
        repeat: expr
        repeat-expr: texture_count
        
  skamodel_mshi_texture:
    seq:
      - id: start_magic
        contents: 'TITX'
      - id: resource_id
        type: u4
      - id: name
        type: ctstring
        
  skamodel_skel:
    seq:
      - id: start_id
        contents: 'SKEL'
      - id: has_skeleton
        type: u4
      - id: resource_id
        type: u4
        if: has_skeleton > 0
  
  skamodel_anas:
    seq:
      - id: anas_magic
        contents: 'ANAS'
      - id: set_count
        type: u4
      - id: anim_sets
        type: u4
        repeat: expr
        repeat-expr: set_count
        
  skamodel_miaq:
    seq:
      - id: miaq_magic
        contents: 'MIAQ'
      - id: anim_count
        type: u4
      - id: anim_list
        type: skamodel_miaq_entry
        repeat: expr
        repeat-expr: anim_count
        
  skamodel_miaq_entry:
    seq:
      - id: start_magic
        contents: 'AQAL'
      - id: start_time
        type: f4
      - id: fade_time
        type: f4
      - id: played_anim_count
        type: u4
      - id: played_anims
        type: skamodel_miaq_aqal_entry
        repeat: expr
        repeat-expr: played_anim_count
        
  skamodel_miaq_aqal_entry:
    seq:
      - id: start_magic
        contents: 'ALPA'
      - id: start_time
        type: f4
      - id: flags
        type: u4
      - id: strength
        type: f4
      - id: group_id
        type: u4
      # TODO: Nitro Family
      - id: unknown_nf
        type: u4
      - id: player_anim_id
        type: ctstring
      - id: pasp_magic
        contents: 'PASP'
      - id: speed_multiplier
        type: f4
        
  skamodel_micb:
    seq:
      - id: start_magic
        contents: 'MICB'
      - id: box_count
        type: u4
      - id: entries
        type: skamodel_micb_entry
        repeat: expr
        repeat-expr: box_count
      - id: afbb_magic
        contents: 'AFBB'
      - id: afbb_min
        type: float3d
      - id: afbb_max
        type: float3d
        
  skamodel_micb_entry:
    seq:
      - id: min
        type: float3d
      - id: max
        type: float3d
      - id: name
        type: ctstring
        
  skamodel_miof_entry:
    seq:
      - id: start_magic
        contents: 'MIOF'
      - id: offset_qvect
        type: qvect
      - id: parent_bode_id
        type: ctstring
      - id: mich_magic
        contents: 'MICH'
      - id: children_count
        type: u4
      - id: children
        type: skamodel_instance
        repeat: expr
        repeat-expr: children_count

  # WriteTextureObject_t   
  texture_object:
    seq:
      - id: id
        type: u4
      - id: animation
        type: anim_object(1)
     
  # CAnimObject 
  anim_object:
    params:
      - id: has_magic
        type: u4
    seq:
      - id: magic
        contents: 'ANOB'
        if: has_magic > 0
      - id: time
        type: f4
      - id: currentanim
        type: u4
      - id: lastanim
        type: u4
      - id: flags
        type: u4

  dict_chunk:
    seq:
      - id: dict_count
        type: u4
      - id: names
        type: dict_entry
        repeat: expr
        repeat-expr: dict_count
      - id: end_id
        contents: 'DEND'

  dict_entry:
    seq:
      - id: dfnm
        type: u4
      - id: len
        type: u4
      - id: type
        type: str
        size: len
        encoding: ASCII
  
  # CTerrainArchive
  terrains_chunk:
    seq:
      - id: count
        type: u4
      - id: container
        type: terrain_any
        repeat: expr
        repeat-expr: count
      - id: end_id
        contents: "EOTA"
      
  terrain_any:
    seq:
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: body
        type:
          switch-on: type
          cases:
            '"TERR"': terrain_old
            '"TRVR"': terrain

  terrain:
    seq:
      - id: version
        type: u4
      - id: data
        type: terrain_global_data
      - id: trhm_magic
        contents: "TRHM"
      - id: height_map
        size: height_map_size
      - id: trem_magic
        contents: "TREM"
      - id: edge_map
        size: edge_map_size
      - id: edge_dfnm
        type: dict_entry
        if: _root.terrain_format == terrain_format::last_chaos
      - id: trsm_chunk
        type:
          switch-on: _root.terrain_format
          cases:
            terrain_format::classic: trsm_chunk
            terrain_format::last_chaos: trsm_chunk_lc

      # Last Chaos Specific
      - id: trtm_lc
        type: trtm_chunk_lc
        if: _root.terrain_format == terrain_format::last_chaos
      # Last Chaos Specific END

      - id: layers
        type: terrain_layer_new
        repeat: expr
        repeat-expr: data.layer_count

      # Last Chaos Specific
      - id: atrribute_map_lc
        type: tram_chunk_lc
        if: _root.terrain_format == terrain_format::last_chaos
      # Last Chaos Specific END

      - id: end_marker
        contents: "TRDE"
        
    instances:
      height_map_size:
        value: data.hm_width * data.hm_height * 2
        
      edge_map_width:
        value: data.hm_width - 1
        
      edge_map_height:
        value: data.hm_height - 1
        
      edge_map_size:
        value: edge_map_width * edge_map_height
  
      shadow_map_width:
        value: data.shadow_map_size_aspect < 0 ? (data.hm_width - 1) >> (-data.shadow_map_size_aspect) : (data.hm_width - 1) << data.shadow_map_size_aspect
      
      shadow_map_height:
        value: data.shadow_map_size_aspect < 0 ? (data.hm_height - 1) >> (-data.shadow_map_size_aspect) : (data.hm_height - 1) << data.shadow_map_size_aspect
      
      shadow_map_size:
        value: shadow_map_width * shadow_map_height * 4
    
  terrain_global_data:
    seq:
      - id: trgd_magic
        contents: "TRGD"
      - id: hm_width
        type: u4
      - id: hm_height
        type: u4
      - id: tm_width
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: tm_height
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: shadow_map_size_aspect
        type: u4
      - id: shading_map_size_aspect
        type: u4
      - id: attribute_map_size_aspect
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: first_topmap_lod
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: layer_count
        type: u4
      - id: shadow_layer_count
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: dist_factor
        type: f4
      - id: stretch
        type: float3d
      - id: metric_size
        type: float3d
        
  trsm_chunk:
    seq:
      - id: trsm_magic
        contents: "TRSM"
      - id: shadow_map
        size: _parent.shadow_map_size

  # Last Chaos Specific 
  trsm_chunk_lc:
    seq:
      - id: trsm_magic
        contents: "TRSM"
      - id: maps
        type: tr_shadow_map_lc
        repeat: expr
        repeat-expr: _parent.data.shadow_layer_count
      - id: shadow_time_lc
        type: u4
      - id: shadow_overbright_lc
        type: f4
        
  tr_shadow_map_lc:
    seq:
      - id: time
        type: u4
      - id: blur_radius
        type: f4
      - id: object_shadow_color
        type: u4
      - id: texture
        type: dict_entry
        
  trtm_chunk_lc:
    seq:
      - id: magic
        contents: "TRTM"
      - id: texture
        type: dict_entry
        
  tram_chunk_lc:
    seq:
      - id: magic
        contents: "TRAM"
      - id: map
        size: map_size
  
    instances:
      map_width:
        value: _parent.data.metric_size.x.to_i
    
      map_height:
        value: _parent.data.metric_size.z.to_i
    
      map_size:
        value: map_width * map_height
       
  # CTerrain
  terrain_old:
    seq:
      - id: version
        type: u4
      - id: hm_width
        type: u4
      - id: hm_height
        type: u4
      - id: stretch
        type: float3d
      - id: dist_factor
        type: f4
      - id: terrain_size
        type: float3d
      - id: trsm_magic
        contents: "TRSM"
      - id: shadow_map_size_aspect
        type: u4
      - id: shading_map_size_aspect
        type: u4
      - id: shadow_map
        size: shadow_map_size
      - id: shading_map
        size: shading_map_size
      - id: tsen_magic
        contents: "TSEN"
      - id: after_tsen
        type: str
        size: 4
        encoding: ASCII
      # Edge Map (optional)
      - id: edge_map
        size: edge_map_size
        if: after_tsen == "TREM"
      - id: teen_magic
        contents: "TEEN"
        if: after_tsen == "TREM"
      # Height Map
      - id: trhm_magic
        contents: "TRHM"
        if: after_tsen == "TREM"
      - id: height_map
        size: height_map_size
      - id: then_magic
        contents: "THEN"
      - id: layers
        type: terrain_layers
      - id: end_magic
        contents: "TREN"

    instances:
      height_map_size:
        value: hm_width * hm_height * 2
    
      edge_map_size:
        value: hm_width * hm_height
    
      shadow_map_width:
        value: shadow_map_size_aspect < 0 ? (hm_width - 1) >> (-shadow_map_size_aspect) : (hm_width - 1) << shadow_map_size_aspect
      
      shadow_map_height:
        value: shadow_map_size_aspect < 0 ? (hm_height - 1) >> (-shadow_map_size_aspect) : (hm_height - 1) << shadow_map_size_aspect
      
      shadow_map_size:
        value: shadow_map_width * shadow_map_height * 4
      
      shading_map_width:
        value: shadow_map_width >> shading_map_size_aspect
        
      shading_map_height:
        value: shadow_map_height >> shading_map_size_aspect
        
      shading_map_size:
        value: shading_map_width * shading_map_height * 2
        
  terrain_layers:
    seq:
      - id: start_magic
        contents: "TRLR"
      - id: layer_count
        type: u4
      - id: layers
        type: terrain_layer
        repeat: expr
        repeat-expr: layer_count
      - id: end_magic
        contents: "TLEN"
        
  terrain_layer:
    seq:
      - id: magic
        contents: "TLTX"
      - id: texture_id
        type: u4
      - id: tlma_magic
        contents: "TLMA"
      - id: mask_width
        type: u4
      - id: mask_height
        type: u4
      - id: colors
        size: mask_size
      - id: params
        type: terrain_layer_params

    instances:
      mask_size:
        value: mask_width * mask_height
        
  terrain_layer_new:
    seq:
      - id: trlt_magic
        contents: "TRLT"
      - id: texture
        type:
          switch-on: _root.file_type
          cases:
            file_type::wld: u4
            file_type::wtr: dict_entry
      - id: version_magic
        contents: "TRLV"
      - id: version
        type: u4
      - id: params
        type: terrain_layer_global_data
      - id: trlm_magic
        contents: "TRLM"
      - id: mask
        size: mask_size
      - id: alpha_texture
        type:
          switch-on: _root.file_type
          cases:
            file_type::wld: u4
            file_type::wtr: dict_entry
        if: _root.terrain_format == terrain_format::last_chaos
        
    instances:
      mask_width:
        value: _parent.data.hm_width - 1

      mask_height:
        value: _parent.data.hm_height - 1
    
      mask_size:
        value: mask_width * mask_height
        
  terrain_layer_global_data:
    seq:
      - id: trlg_magic
        contents: "TRLG"
      - id: name_len
        type: u4
      - id: name_str
        type: str
        size: name_len
        encoding: ASCII
      - id: is_visible
        type: u4
      - id: layer_type
        type: u4
      - id: multiply_color
        type: u4
      - id: flags
        type: u4
      - id: mask_stretch
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: sound_index
        type: u4
        if: _root.terrain_format == terrain_format::last_chaos
      - id: offset_x
        type: f4
      - id: offset_y
        type: f4
      - id: rotate_x
        type: f4
      - id: rotate_y
        type: f4
      - id: stretch_x
        type: f4
      - id: stretch_y
        type: f4
      - id: is_auto_regenerated
        type: u4
      - id: coverage
        type: f4
      - id: coverage_noise
        type: f4
      - id: coverage_random
        type: f4
      # Altitude
      - id: is_apply_min_altitude
        type: u4
      - id: is_apply_max_altitude
        type: u4
      - id: min_altitude
        type: f4
      - id: max_altitude
        type: f4
      - id: min_altitude_fade
        type: f4
      - id: max_altitude_fade
        type: f4
      - id: min_altitude_noise
        type: f4
      - id: max_altitude_noise
        type: f4
      - id: min_altitude_random
        type: f4
      - id: max_altitude_random
        type: f4
      # Slope
      - id: is_apply_min_slope
        type: u4
      - id: is_apply_man_slope
        type: u4
      - id: min_slope
        type: f4
      - id: max_slope
        type: f4
      - id: min_slope_fade
        type: f4
      - id: max_slope_fade
        type: f4
      - id: min_slope_noise
        type: f4
      - id: max_slope_noise
        type: f4
      - id: min_slope_random
        type: f4
      - id: max_slope_random
        type: f4
        
  terrain_layer_params:
    seq:
      - id: magic
        contents: "TLPR"
      - id: name_len
        type: u4
      - id: name_str
        type: str
        size: name_len
        encoding: ASCII
      - id: is_visible
        type: u4
      - id: rotate_x
        type: f4
      - id: rotate_y
        type: f4
      - id: stretch_x
        type: f4
      - id: stretch_y
        type: f4
      - id: offset_x
        type: f4
      - id: offset_y
        type: f4
      - id: is_auto_regenerated
        type: u4
      - id: coverage
        type: f4
      - id: coverage_noise
        type: f4
      - id: coverage_random
        type: f4
      # Min Altitude
      - id: is_apply_min_altitude
        type: u4
      - id: min_altitude
        type: f4
      - id: min_altitude_fade
        type: f4
      - id: min_altitude_noise
        type: f4
      - id: min_altitude_random
        type: f4
      # Max Altitude
      - id: is_apply_max_altitude
        type: u4
      - id: max_altitude
        type: f4
      - id: max_altitude_fade
        type: f4
      - id: max_altitude_noise
        type: f4
      - id: max_altitude_random
        type: f4
      # Min Slope
      - id: is_apply_min_slope
        type: u4
      - id: min_slope
        type: f4
      - id: min_slope_fade
        type: f4
      - id: min_slope_noise
        type: f4
      - id: min_slope_random
        type: f4
      # Max Slope
      - id: is_apply_max_slope
        type: u4
      - id: max_slope
        type: f4
      - id: max_slope_fade
        type: f4
      - id: max_slope_noise
        type: f4
      - id: max_slope_random
        type: f4
      - id: multiply_color
        type: u4
      - id: smoothness
        type: f4
      - id: type
        type: u4
      # Tile Layer Properties
      - id: tiles_in_row
        type: u4
      - id: tiles_in_col
        type: u4
      - id: selected_tile
        type: u4
      - id: tile_width
        type: u4
      - id: tile_height
        type: u4
      - id: tile_u
        type: f4
      - id: tile_v
        type: f4

  world_info_chunk:
    seq:
      - id: len_or_magic
        type: u4
      - id: data
        type:
          switch-on: is_old
          cases:
            1: wld_info
            1: wld_info_old
    instances:
      is_old:
        value: 'len_or_magic != 0x46494C57 ? 1 : 0'

  wld_info_old:
    seq:
      - id: description_len
        type: u4
      - id: description_str
        type: str
        size: description_len
        encoding: ASCII
  wld_info:
    seq:
      - id: len_or_magic
        type: u4
      - id: len
        type: u4
        if: has_dtrs
      - id: name_str
        type: str
        size: name_len
        encoding: ASCII
      - id: spawn_flags
        type: u4
      - id: description_len
        type: u4
      - id: description_str
        type: str
        size: description_len
        encoding: ASCII
    instances:
      has_dtrs:
        value: len_or_magic == 0x53525444
      name_len:
        value: 'has_dtrs ? len : len_or_magic'

  brushes_chunk:
    seq:
      - id: count
        type: u4
      - id: data
        type: brush_info
        repeat: expr
        repeat-expr: count
      - id: portal_sector_links
        type: portal_sector_links
      - id: end_id
        contents: "EOAR"
  portal_sector_links:
    seq:
      - id: start_id
        contents: "PSLS"
      - id: version
        type: u4
      - id: chunk_size
        type: u4
      - id: sectors
        type: psl_entry
        repeat: until
        repeat-until: _.sector_id == -1
      - id: end_id
        contents: "PSLE"
        
  psl_entry:
    seq:
      - id: sector_id
        type: s4
      - id: link_count
        type: u4
        if: sector_id != -1
      - id: polygons
        type: u4
        repeat: expr
        repeat-expr: link_count
        
  brush_info:
    seq:
      - id: start_id
        contents: "BR3D"
      - id: version
        type: u4
      - id: mip_count
        type: u4
      - id: mips
        type: brush_mip_info
        repeat: expr
        repeat-expr: mip_count
      - id: end_id
        contents: "BREN"
  brush_mip_info:
    seq:
      - id: magic
        contents: "BRMP"
      - id: max_distance
        type: f4
      - id: sector_count
        type: u4
      - id: sectors
        type: brush_sector
        repeat: expr
        repeat-expr: sector_count
  brush_sector:
    seq:
      - id: magic
        contents: "BSC "
      - id: version
        type: u4
        enum: brush_sector_ver
      - id: name_len
        type: u4
        if: version.to_i >= brush_sector_ver::withname.to_i
      - id: name_str
        type: str
        size: name_len
        encoding: ASCII
        if: version.to_i >= brush_sector_ver::withname.to_i
      - id: color
        type: u4
      - id: ambient_color
        type: u4
      - id: flags
        type: u4
      - id: flags2
        type: u4
        if: version.to_i >= brush_sector_ver::withflags2.to_i
      - id: vis_flags
        type: u4
        if: version.to_i >= brush_sector_ver::withvisflags.to_i
      # NitroFamily specific.
      - id: nf_flags
        type: u4
        if: _root.brush_format == brush_format::nitro_family
      - id: vertices_id
        contents: "VTXs"
      - id: vertex_count
        type: u4
      - id: vertices
        type: double3d
        repeat: expr
        repeat-expr: vertex_count
      - id: planes_id
        contents: "PLNs"
      - id: plane_count
        type: u4
      - id: planes
        type: doubleplane3d
        repeat: expr
        repeat-expr: plane_count
      - id: edges_id
        contents: "EDGs"
      - id: edge_count
        type: u4
      - id: edges
        type: brush_edge
        repeat: expr
        repeat-expr: edge_count
      - id: polygons_id
        contents: "BPOs"
      - id: polygons_ver
        type: u4
        enum: brush_polygon_ver
      - id: polygon_count
        type: u4
      - id: polygons
        type: brush_polygon
        repeat: expr
        repeat-expr: polygon_count
      - id: bsp0_id
        contents: "BSP0"
      - id: bsp_tree
        type: double_bps_tree_3d
        # TODO

  float3d:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
        
  floatmatrix3d:
    seq:
      - id: row_1
        type: float3d
      - id: row_2
        type: float3d
      - id: row_3
        type: float3d

  placement3d:
    seq:
      - id: pos
        type: float3d
      - id: rot
        type: float3d
        
  floatplane3d:
    seq:
      - id: h
        type: f4
      - id: p
        type: f4
      - id: b
        type: f4
      - id: d
        type: f4

  double3d:
    seq:
      - id: x
        type: f8
      - id: y
        type: f8
      - id: z
        type: f8
  doubleplane3d:
    seq:
      - id: h
        type: f8
      - id: p
        type: f8
      - id: b
        type: f8
      - id: d
        type: f8
  double_bps_tree_3d:
    seq:
      - id: version
        type: u4
      - id: size
        type: u4
      - id: node_count
        type: u4
      - id: nodes
        type: double_bps_tree_3d_node
        repeat: expr
        repeat-expr: node_count
      - id: end_marker
        contents: "BSPE"
  double_bps_tree_3d_node:
    seq:
      - id: node
        type: doubleplane3d
      - id: location
        type: u4
      - id: front
        type: u4
      - id: back
        type: u4
      - id: plane_tag
        type: u4
  brush_edge:
    seq:
      - id: vtx0
        type: u4
      - id: vtx1
        type: u4

  # CBrushPolygon
  brush_polygon:
    seq:
      - id: plane_id
        -orig-id: iPlane
        type: u4
      - id: color
        -orig-id: bpo_colColor
        type: u4
      - id: flags
        -orig-id: bpo_ulFlags
        type: u4
      # ABZ & EuroCops
      - id: abzf_marker
        contents: "ABZF"
        if: _root.brush_format == brush_format::abz
      - id: abzf_flags
        type: u4
        if: _root.brush_format == brush_format::abz
      - id: textures
        -orig-id: bpo_abptTextures
        type: brush_polygon_texture  
        repeat: expr
        repeat-expr: texture_count
      - id: properties
        -orig-id: bpo_bppProperties
        type: brush_polygon_properties
      - id: edge_count
        -orig-id: ctPolygonEdges
        type: u4
      - id: edges
        type: u4  
        repeat: expr
        repeat-expr: edge_count
      - id: triangles
        type: brush_polygon_triangles
      # TODO: Add support for CTSM
      - id: shadow_map
        type: brush_shadow_map
      - id: shadow_color
        type: u4
      - id: lc_attribute
        type: u1
        if: _root.brush_format == brush_format::last_chaos
        
    instances:
      texture_count:
        value: _root.brush_format == brush_format::nitro_family ? (5) : (3)
      
  brush_polygon_triangles:
    seq:
      - id: vtx_count
        type: u4
      - id: vtxs
        type: u4  
        repeat: expr
        repeat-expr: vtx_count
      - id: element_count
        type: u4
      - id: elements
        -orig-id: bpo_aiTriangleElements
        type: u4  
        repeat: expr
        repeat-expr: element_count
        
  brush_shadow_map:
    seq:
      - id: magic
        contents: "LSHM"
      - id: flags
        type: u4
      - id: first_mip_level
        type: u4
      - id: offset_x
        type: s4
      - id: offset_y
        type: s4
      - id: width
        type: s4
      - id: height
        type: s4
      - id: layers
        type: brush_shal
        
  brush_shal:
    seq:
      - id: magic
        contents: "SHAL"
      - id: version
        type: u4
      - id: polygon_size_u
        type: u4
      - id: polygon_size_v
        type: u4
      - id: layer_count
        type: u4
      - id: layers
        type: brush_shal_layer  
        repeat: expr
        repeat-expr: layer_count
        
  brush_shal_layer:
    seq:
      - id: flags
        type: u4
      - id: size_in_pixels
        type: u4
      - id: layer
        size: (size_in_pixels + 7) / 8
        if: size_in_pixels > 0
      - id: min_u
        type: u4
      - id: min_v
        type: u4
      - id: size_u
        type: u4
      - id: size_v
        type: u4

  # CBrushPolygonTexture
  brush_polygon_texture:
    seq:
      # Texture ID at dictionary.
      - id: texture_id
        type: u4
      #- id: filename_str
      #  type: str
      #  size: filename_len
      #  encoding: ASCII
      - id: mapping
        type: mapping_definition
      # Following 8 bytes are properties
      - id: scroll
        type: u1
      - id: blend
        type: u1
      - id: flags
        type: u1
      - id: dummy
        type: u1
      - id: color
        type: u4
  # CBrushPolygonProperties
  brush_polygon_properties:
    seq:
      - id: surface_type
        type: u1
        enum: brush_surface_type
      - id: illumination_type
        type: u1
      - id: shadow_blend
        type: u1
      - id: mirror_type
        type: u1
      - id: gradient_type
        type: u1
      - id: shadow_cluster_size
        type: s1
      - id: pretender_distance
        type: u2
  # CMappingDefinition
  mapping_definition:
    seq:
      # Six floats / 6 x 4 = 24 bytes
      - id: uos
        type: f4
      - id: uot
        type: f4
      - id: vos
        type: f4
      - id: vot
        type: f4
      - id: uoffset
        type: f4
      - id: vofsset
        type: f4
        
  ctstring:
    seq:
      - id: len
        type: u4
      - id: type
        type: str
        size: len
        encoding: ASCII
        
  stringtrans:
    seq:
      - id: magic
        contents: "DTRS"
      - id: data
        type: ctstring
        
  floatquat3d:
    seq:
      - id: w
        type: f4
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  qvect:
    seq:
      - id: pos
        type: float3d
      - id: quat
        type: floatquat3d
        
  floataabbox3d:
    seq:
      - id: min
        type: float3d
      - id: max
        type: float3d
enums:
  brush_format:
    1: classic
    2: nitro_family
    3: abz
    4: last_chaos

  entity_property_type:
    1: enum
    2: boolean
    3: float
    4: color
    5: string
    6: range
    7: entityptr
    8: filename
    9: index
    10: animation
    11: illuminationtype
    12: floataabbox3d
    13: angle
    14: float3d
    15: angle3d
    16: floatplane3d
    17: modelobject
    18: placement3d
    19: animobject
    20: filenamenodep
    21: soundobject
    22: stringtrans
    23: floatquat3d
    24: floatmatrix3d
    25: flags
    26: modelinstance

  entity_render_type:
    1: illegal
    2: none
    3: model
    4: brush
    5: editormodel
    7: void
    8: fieldbrush
    9: skamodel
    10: skaeditormodel
    11: terrain
  brush_sector_ver:
    0: old
    1: withname
    2: withflags2
    3: withvisflags
  brush_polygon_ver:
    0: old
    1: withhypertextures
    2: multitexturing
    3: fakeportalflag
    4: triangles
  brush_surface_type:
    0: standard
    1: ice
    2: standard_no_step
    3: standard_high_impact
    4: ice_climbable_slope
    5: ice_sliding_slope
    6: ice_less_sliding
    7: roller_coaseter
    8: lava
    9: sand
    10: clibable_slope
    11: standard_no_impact
    12: surface_water
    13: red_sand
    14: ice_sliding_slope_no_impact
    15: roller_coaster_no_impact
    16: standard_high_stairs_no_impact
    17: grass
    18: wood
    19: grass_sliding
    20: grass_no_impact
    21: snow
    
  terrain_format:
    0: classic
    1: last_chaos
    
  file_type:
    0: wld
    1: wtr