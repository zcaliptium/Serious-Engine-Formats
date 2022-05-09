# Copyright ZCaliptium 2021-2022
meta:
  id: se2_metadata
  file-extension: tex
  endian: le
seq:
  - id: header
    type: file_header

types:
  file_header:
    seq:
      - id: magic
        contents: "CTSEMETA"
      - id: endianess
        type: u4
      - id: meta_version
        type: u4
      - id: version_string
        type: cstring
      - id: chunks
        type: data_chunk
        repeat: expr
        repeat-expr: 8
  
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
            '"INFO"': info_chunk
            '"RFIL"': resource_files_chunk
            '"IDNT"': idents_chunk
            '"EXTY"': external_types_chunk
            '"INTY"': internal_types_chunk
            '"EXOB"': external_objects_chunk
            '"OBTY"': object_types_chunk
            '"EDTY"': object_types_chunk
            
  info_chunk:
    seq:
      - id: is_initialized
        type: u4
      - id: resource_count
        type: u4
      - id: ident_count
        type: u4
      - id: total_type
        type: u4
      - id: total_objects
        type:  u4
        
  resource_files_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: resource_entry
        repeat: expr
        repeat-expr: count

  resource_entry:
    seq:
      - id: id
        type: u4
      - id: flags
        type: u4
      - id: path
        type: cstring
        
  idents_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: ident_entry
        repeat: expr
        repeat-expr: count
        
  ident_entry:
    seq:
      - id: id
        type: u4
      - id: id_len
        type: u4
      - id: id_str
        type: str
        size: id_len
        encoding: ASCII
        
  external_types_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: external_type
        repeat: expr
        repeat-expr: count
        
  external_type:
    seq:
      - id: type_id
        type: u4
      - id: identifier_len
        type: u4
      - id: identifier_str
        type: str
        size: identifier_len
        encoding: ASCII
        
  internal_types_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: internal_type
        repeat: expr
        repeat-expr: count
        
  internal_type:
    seq:
      - id: magic
        contents: "DTTY"
      - id: type_id
        type: u4
      - id: identifier_len
        type: u4
      - id: identifier_str
        type: str
        size: identifier_len
        encoding: ASCII
      - id: version
        type: u4
      - id: type
        type: u4
        enum: datatype_type
      - id: data
        type:
          switch-on: type
          cases:
            'datatype_type::simple': dtdef_simple
            'datatype_type::valuefield': u4
            'datatype_type::pointer': u4
            'datatype_type::array': dtdef_array
            'datatype_type::struct': dtdef_struct
            'datatype_type::staticarray': u4
            'datatype_type::staticstackarray': u4
            'datatype_type::dynamiccontainer': u4
            'datatype_type::smartpointer': u4
            'datatype_type::handle': u4
            'datatype_type::typedef': u4
            
  dtdef_simple:
    seq:
      - id: size_in_bytes
        type: u4
      - id: endianess_size
        type: u4
        
  dtdef_array:
    seq:
      - id: typeid
        type: u4
      - id: magic
        contents: "ADIM"
      - id: dimension_count
        type: u4
      - id: dimensions
        type: u4
        repeat: expr
        repeat-expr: dimension_count
  
  dtdef_struct:
    seq:
      - id: parent_type_id
        type: u4
      - id: magic
        contents: "STMB"
      - id: member_count
        type: u4
      - id: members
        type: dtdef_struct_member
        repeat: expr
        repeat-expr: member_count
      
  dtdef_struct_member:
    seq:
      - id: identifier_len
        type: u4
      - id: identifier_str
        type: str
        size: identifier_len
        encoding: ASCII
      - id: type_id
        type: u4
        
  dtdef_typedef:
    seq:
      - id: type_id
        type: u4
        
  dtdef_typedef:
    seq:
      - id: type_id
        type: u4
    
  external_objects_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: external_object
        repeat: expr
        repeat-expr: count
        
  external_object:
    seq:
      - id: id
        type: u4
      - id: resource_id
        type: u4
      - id: object_id
        type: u4
      - id: object_type_id
        type: u4
        
  object_types_chunk:
    seq:
      - id: count
        type: u4
      - id: entries
        type: object_type
        repeat: expr
        repeat-expr: count
        
  object_type:
    seq:
      - id: object_id
        type: u4
      - id: type_id
        type: u4
        
  # CString
  cstring:
    seq:
      - id: len
        type: u4
      - id: data
        type: str
        size: len
        encoding: ASCII
        
enums:
  datatype_type:
    0: simple
    1: valuefield
    2: pointer
    4: array
    5: struct
    6: staticarray
    7: staticstackarray
    8: dynamiccontainer
    11: smartpointer
    12: handle
    13: typedef
    14: template