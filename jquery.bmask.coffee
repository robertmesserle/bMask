$ ->

  class Mask

    constructor: ( @elem, @mask ) ->
      @raw = []
      @$elem = $( @elem )
      @create_map()
      @initialize_field()

    initialize_field: ->
      @$elem.val( @mask.join( '' ) )
      @$elem.bind
        focus: @focus,
        keydown: @keydown,
        keyup: @keyup
        mouseup: @mouseup
      @get_val()

    mouseup: =>
      @clear_selection()

    clear_selection: ->
      @get_position()
      @set_position()

    focus: ( e ) =>
      @clear_selection()
      @set_position( @map[ @raw.length ] )

    keydown: ( e ) =>
      @clear_selection()
      if ( @ctrl ) then return true
      switch e.keyCode
        when 9, 16, 35, 36, 37, 38, 39, 40 then true
        when 8 then @handle_backspace()
        when 46 then @handle_delete()
        when 17 then @ctrl = true
        else @handle_default()

    keyup: ( e ) =>
      @clear_selection()
      switch e.keyCode
        when 17 then @ctrl = false

    handle_delete: ( back = false ) ->
      @get_position()
      if back then @last_valid_slot( @pos - 1 )
      else @next_valid_slot()
      @set_position()
      @val[ @pos ] = '_'
      @update_val()
      @set_position()
      @get_raw_val()
      @set_val_from_raw()
      return false

    handle_backspace: ->
      @handle_delete( true )

    handle_default: ->
      @get_position()
      return false if @pos >= @mask.length
      setTimeout =>
        @get_position()
        @get_val()
        ch = @pop_char()
        @next_valid_slot()
        @val[ @pos ] = ch
        @get_raw_val()
        @update_val()
        @next_valid_slot( @pos + 1 )
        @set_position()

    last_valid_slot: ( @pos = @pos ) ->
      while @mask[ @pos ] != '_' && @pos > 0
        @pos--

    next_valid_slot: ( @pos = @pos ) ->
      while @mask[ @pos ] != '_' && @pos < @mask.length
        @pos++

    pop_char: ( val = @val, pos = @pos - 1 ) ->
      ch = val.splice( pos, 1 )[ 0 ]
      @update_val()
      @set_position( @pos - 1 )
      ch

    get_raw_val: ->
      @raw = []
      for ch, i in @mask
        @raw.push( @val[ i ] ) if ch != @val[ i ]

    set_val_from_raw: ->
      @val = @mask[0..]
      raw_index = 0
      for ch, i in @mask
        @val[ i ] = @raw[ raw_index++ ] if ch == '_' && raw_index < @raw.length
      @update_val()
      @set_position()

    update_val: ->
      @$elem.val( @val.join( '' ) )

    get_val: ->
      @val = @$elem.val().split( '' )

    get_position: ->
      @pos = @elem.selectionStart

    set_position: ( @pos = @pos ) ->
      @elem.setSelectionRange( @pos, @pos, 0 )

    create_map: ->
      @map = []
      for ch, i in @mask
        @map.push( i ) if ch == '_'


  $.fn.mask = ( mask ) ->
    $(@).each ->
      new Mask( @, mask.split('') )