function UiElement(_xscale=0,_yscale=0,_xoffset=0,_yoffset=0,_wscale=1,_hscale=1,_woffset=0,_hoffset=0,_anchor_x=0,_anchor_y=0) constructor
{
	//ELEMENT
	derived = undefined
	parent = undefined
	children = []
	
	//POSITIONING
	anchor_x = _anchor_x
	anchor_y = _anchor_y
	xscale = _xscale
	yscale = _yscale
	xoffset = _xoffset
	yoffset = _yoffset
	
	wscale = _wscale
	hscale = _hscale
	woffset = _woffset
	hoffset = _hoffset
	
	///IMAGE VARIABLES
	image = spr_uipanel
	imageindex = 0
	imagealpha = 1
	imageblend = c_white
	
	imageanimated = false
	imageanimationspeed = 0.1
	
	//TEXT
	text = ""
	text_alpha = 1
	text_color = c_white
	text_xscale = 0.5
	text_yscale = 0.5
	text_xoffset = 0
	text_yoffset = 0
	text_halign = fa_middle
	text_valign = fa_center
	text_scale = 1
	
	//BUTTON
	is_button = false
	button_func = undefined
	button_func_argument = undefined
	button_is_toggle = false
	button_toggle = false
	button_icon = undefined
	button_icon_index = 0
	button_func_argument_is_toggle = false
	button_sound = undefined
	button_text_blend_hover = c_yellow
	button_text_blend_normal = text_color
	
	//TEXTBOX
	
	is_textbox = false
	textbox_selected = false
	textbox_number = false
	textbox_number_default = 64
	
	//tooltip
	tooltip = ""
	
	///GENERAL
	is_visible = true
	dx = 0
	dy = 0
	dw = 0
	dh = 0
	
	static Draw = function()
	{
		if not is_visible { return }
		
		if !is_undefined(image) {
			draw_sprite_stretched_ext(image,imageindex,dx,dy,dw,dh,imageblend,imagealpha)	
		}
		if (!is_undefined(button_icon)) {
			if button_is_toggle {
				draw_sprite_stretched(button_icon,button_toggle,dx,dy,dw,dh)	
			}
			else {
				draw_sprite_stretched(button_icon,button_icon_index,dx,dy,dw,dh)
			}
		}
		if string_length(text) > 0 {
			draw_set_halign(text_halign)
			draw_set_valign(text_valign)
			draw_set_alpha(text_alpha)
			draw_set_color(text_color)
			draw_text_transformed(dx+(dw*text_xscale)+text_xoffset,dy+(dh*text_yscale)+text_yoffset,text,text_scale,text_scale,0)	
		}
		
		//draw children
		for (var i = 0; i<array_length(children); i++) {
			children[i].Draw();	
		}
	}
	
	static Update = function()
	{
		
		dw = (parent.dw * wscale) + woffset
		dh = (parent.dh * hscale) + hoffset
		
		dx = (parent.dx + xoffset + (parent.dw*xscale)) - (anchor_x*dw)
		dy = (parent.dy + yoffset + (parent.dh*yscale)) - (anchor_y*dh)
		
		if (not is_visible) {
			return	
		}
		
		if (imageanimated) {
			imageindex += imageanimationspeed
		}
		
		if tooltip != "" and !is_undefined(derived) {
			if self.MouseInside() {
				if derived.tooltip != tooltip or !derived.tooltip_visible {
					derived.tooltip = tooltip
					derived.tooltip_visible = true
				}
			}else {
				if derived.tooltip == tooltip {
					derived.tooltip_visible = false	
				}
			}
		}
		
		if (is_textbox) {
			if (self.MouseInside()) {
				if mouse_check_button_pressed(mb_left) {
					textbox_selected = true
					imageindex = 1	
				}
			}
			else {
				if mouse_check_button_pressed(mb_left) {
					textbox_selected = false	
					imageindex = 0
					
					if textbox_number {
						if text == "" {
							text = string(textbox_number_default)	
						}
						else {
							text = string_digits(text)	
						}	
					}
				}
			}
			
			if textbox_selected && keyboard_check_pressed(vk_anykey) {
				var _k = keyboard_lastchar
				if (string_length(_k) == 1) {
					text += _k
				}
				if (keyboard_check_pressed(vk_backspace)) {
					text = string_copy(text,1,string_length(text)-2)	
				}
			}
		}
		
		if (is_button) {
			if button_is_toggle {
				imageindex = button_toggle	
			}
			if (self.MouseInside()) {
				if !button_is_toggle {
					imageindex = 1	
				}
				text_color = button_text_blend_hover
				if (mouse_check_button_pressed(mb_left)) {
					if button_is_toggle {
						button_toggle = !button_toggle
					}
					if (!is_undefined(button_func)) {
						if !is_undefined(button_func_argument) or button_func_argument_is_toggle {
							if button_func_argument_is_toggle {
								button_func(button_toggle);	
							}
							else {
								button_func(button_func_argument);	
							}
						}
						else {
							button_func();
						}
					}
					if (!is_undefined(button_sound)) {
						audio_play_sound(button_sound,1,false)	
					}
				}
			}
			else {
				if !button_is_toggle {
					imageindex = 0
				}
				text_color = button_text_blend_normal
			}
		}
		
		//update children
		for (var i = 0; i<array_length(children); i++) {
			children[i].Update();	
		}
	}
	
	static Add = function(_element)
	{
		_element.parent = self
		_element.derived = derived
		array_push(children,_element)
	}
	
	static Remove = function(i)
	{
		array_delete(children,i,1)
	}
	
	static Clear = function()
	{
		for (var i = 0; i<array_length(children); i++) {
			delete children[i];
		}
		children = []
	}
	
	static SetDerived = function(_ui) {
		derived = _ui
		for (var i = 0; i<array_length(children); i++) {
			children[i].SetDerived(_ui);	
		}
	}
	
	static MouseInside = function()
	{
		return mouse_x > dx and mouse_y > dy and mouse_x < dx+dw and mouse_y < dy+dh and is_visible
	}
}

function Ui(_x=0,_y=0,_w=640,_h=360) constructor
{
	dx=_x
	dy=_y
	dw=_w
	dh=_h
	children = []
	active = true
	
	tooltip = ""
	tooltip_visible = false
	
	static Add = function(_element)
	{
		_element.parent = self
		_element.SetDerived(self)
		array_push(children,_element)
	}
	
	static Remove = function(i)
	{
		array_delete(children,i,1)
	}
	
	static Move = function(_x,_y)
	{
		dx = _x
		dy = _y
	}
	
	static Scale = function(_w,_h)
	{
		dw = _w
		dh = _h
	}
	
	static Draw = function()
	{
		if not active {
			return
		}
		
		for (var i = 0; i<array_length(children); i++) {
			children[i].Draw();	
		}
	}
	
	static DrawTooltip = function() {
		if tooltip_visible {
			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
			var _w = string_width(tooltip)*0.5
			if mouse_x + _w > camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) {
				draw_set_halign(fa_right)
			}
			draw_set_color(c_black)
			draw_set_alpha(0.5)
			if draw_get_halign() == fa_left {
				draw_rectangle(mouse_x,mouse_y+8,mouse_x+8+_w,mouse_y+8+6,false)	
			}
			else {
				draw_rectangle(mouse_x,mouse_y+8,mouse_x-_w,mouse_y+8+6,false)
			}
			draw_set_color(c_white)
			draw_set_alpha(1)
			draw_text_transformed(mouse_x,mouse_y+8,tooltip,0.5,0.5,0)
		}	
	}
	
	static Update = function()
	{
		if not active {
			return
		}
		
		for (var i = 0; i<array_length(children); i++) {
			children[i].Update();	
		}
	}
}

///menus

global.menuselection_select = false

function MS_select() {
	if kennal_key_check_pressed(keycodes.kc_select) or mouse_check_button_pressed(mb_left) {
		global.menuselection_select = true	
	}
}

function MenuSelection(_optwidth=1,_optheight=1,_cell_wid=64,_cell_heit=12) constructor {
	selected = [0,0]
	options = ds_grid_create(_optwidth,_optheight)
	ds_grid_clear(options,undefined)
	
	dx=0
	dy=0
	dw=ds_grid_width(options)*_cell_wid
	dh=ds_grid_height(options)*_cell_heit
	
	cell_width = _cell_wid
	cell_height = _cell_heit
	
	is_enabled = true
	dropshadow = false
	text_scale = 1
	selector_box = false
	selector_sprite = undefined
	
	ui=undefined
	
	static AddOption = function(_optfunc=undefined,_optx=0,_opty=0,_opt_text="Option",_opt_sprite=undefined,_func_argument=undefined,_tooltip="")  {
		ds_grid_set(options,_optx,_opty,[_optfunc,_opt_text,_opt_sprite,_func_argument,_tooltip])
	}
	
	static AddOptionFillHorizontal = function(_optfunc=undefined,_opt_text="Option",_opt_sprite=undefined,_func_argument=undefined,_tooltip="") {
		var _optx = 0
		var _opty = 0
		while true {
			if !is_undefined(ds_grid_get(options,_optx,_opty)) {
				_optx += 1
				if _optx > ds_grid_width(options)-1 {
					_optx = 0
					_opty += 1
					if _opty > ds_grid_height(options)-1 {
						show_debug_message("COULD NOT FIND SPOT FOR OPTION!")
						return false
					}
				}
			}
			else {
				break	
			}
		}
		ds_grid_set(options,_optx,_opty,[_optfunc,_opt_text,_opt_sprite,_func_argument,_tooltip])
		return true
	}
	
	static RemoveOption = function(_optx=0,_opty=0) {
		ds_grid_set(options,_optx,_opty,undefined)
	}
	
	static ClearOptions = function(_except=[-1,-1]) {
		for (var _y = 0; _y<ds_grid_height(options); _y++) {
			for (var _x = 0; _x<ds_grid_width(options); _x++) {
				if _x != _except[0] and _y != _except[1] {
					self.RemoveOption(_x,_y)
				}
			}
		}
	}
	
	static MoveSelector = function(_mx=0,_my=0) {
		while true {
			if selected[0]+_mx < 0 or selected[0]+_mx > ds_grid_width(options)-1 or selected[1]+_my < 0 or selected[1]+_my > ds_grid_height(options)-1 {
				break	
			}
			
			selected[0] += _mx
			selected[1] += _my
			
			if !is_undefined(ds_grid_get(options,selected[0],selected[1])) {
				break
			}
		}
	}
	
	static Select = function(_sx=0,_sy=0) {
		selected = [clamp(_sx,0,ds_grid_width(options)-1),clamp(_sy,0,ds_grid_height(options)-1)]
	}
	
	static Update = function() {
		if !is_enabled {
			return
		}
		
		if kennal_key_check_pressed(keycodes.kc_right) {
			self.MoveSelector(1)
		}
		if kennal_key_check_pressed(keycodes.kc_left) {
			self.MoveSelector(-1)
		}
		if kennal_key_check_pressed(keycodes.kc_down) {
			self.MoveSelector(0,1)
		}
		if kennal_key_check_pressed(keycodes.kc_up) {
			self.MoveSelector(0,-1)
		}
		
		if global.menuselection_select {
			global.menuselection_select = false
			var _opt = ds_grid_get(options,selected[0],selected[1])
			if !is_undefined(_opt) {
				var _func = _opt[0]
				var _funcarg = _opt[3]
				if !is_undefined(_func) {
					if is_undefined(_funcarg) {
						_func();
					}
					else {
						_func(_funcarg);	
					}
				}
			}
		}
	}
	
	static Draw = function() {
		if !is_enabled {
			return	
		}
		draw_set_alpha(1)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		for (var _y = 0; _y<ds_grid_height(options); _y++) {
			for (var _x = 0; _x<ds_grid_width(options); _x++) {
				draw_set_color(c_white)
				var _opt = ds_grid_get(options,_x,_y)
				var _ox = dx+(_x*cell_width)
				var _oy = dy+(_y*cell_height)
				var _ox2 = _ox+cell_width
				var _oy2 = _oy+cell_height
				
				if _x==selected[0] and _y==selected[1] {
					if mouse_x > _ox and mouse_x < _ox2 and mouse_y > _oy and mouse_y < _oy2 {
						if !is_undefined(ui) and !is_undefined(_opt) {
							if ui.tooltip != _opt[4] {
								ui.tooltip = _opt[4]
								ui.tooltip_visible = true
							}
						}
					}
					if selector_box {
						draw_rectangle(_ox,_oy,_ox2,_oy2,true)	
					}
					if !is_undefined(selector_sprite) {
						if dropshadow {
							draw_sprite_dropshadow(selector_sprite,0,_ox-16,_oy2-(cell_height/2))	
						}
						else {
							draw_sprite(selector_sprite,0,_ox-16,_oy2-(cell_height/2))	
						}
					}
					draw_set_color(c_yellow)
				}
				else {
					if mouse_x > _ox and mouse_x < _ox2 and mouse_y > _oy and mouse_y < _oy2 {
						self.Select(_x,_y)
					}
					else {
						if !is_undefined(ui) and !is_undefined(_opt) {
							if ui.tooltip == _opt[4] {
								ui.tooltip = ""
								ui.tooltip_visible = false
							}		
						}
					}
				}
				
				if !is_undefined(_opt) {
					var _spr  = _opt[2]
					var _sx = dx+(_x*cell_width)
					var _sy = dy+(_y*cell_height)
					var _tx = _sx+(cell_width/2)
					var _ty = _sy+(cell_height/2)
					var _tt = _opt[1]
					var _twidth = string_width(_tt)*text_scale
					
					if _twidth > cell_width and string_height_ext(_tt,13,cell_width)==12 {
						var _est = floor((_twidth-cell_width)/floor(8*text_scale))+floor(1*text_scale)
						_tt = string_copy(_tt,1,string_length(_tt)-_est) + "..."
					}
					
					if !is_undefined(_spr) {
						_ty = dy+(_y*cell_height)+cell_height-12
						var _c = draw_get_color()
						draw_set_color(c_white)
						draw_sprite_stretched(_spr,0,_sx+6,_sy+6,cell_width-12,cell_height-12)	
						draw_set_color(_c)
					}
					if dropshadow {
						draw_text_dropshadow_ext_transformed(_tx,_ty,_tt,13,cell_width,text_scale,text_scale,0)		
					}
					else {
						draw_text_ext_transformed(_tx,_ty,_tt,13,cell_width,text_scale,text_scale,0)	
					}
				}
			}	
		}
	}
	
	static MouseInside = function()
	{
		return mouse_x > dx and mouse_y > dy and mouse_x < dx+dw and mouse_y < dy+dh and is_enabled
	}
}

//map selector

function MapSelector(_tooltip_layer,_selectedlevelcallback,_closecallback=undefined) constructor
{
	view = 0
	
	map_selector = new MenuSelection(8,4,64,64)
	map_selector.is_enabled = false
	map_selector.selector_box = true
	map_selector.dx = (camera_get_view_x(view_camera[view])+(camera_get_view_width(view_camera[view])/2))-(map_selector.dw/2)
	map_selector.dy = (camera_get_view_y(view_camera[view])+(camera_get_view_height(view_camera[view])/2))-(map_selector.dh/2)
	map_selector.text_scale = 1
	
	map_selector.ui = _tooltip_layer
	
	loaded_map_thumbnails = ds_map_create()
	
	map_selector_dir_history = []
	map_selector_dir_history_at = -1
	
	selected_level_callback = _selectedlevelcallback
	close_callback = _closecallback

	Open = function() {
		global.menuselection_select = false
		map_selector.is_enabled = true
		
		map_selector_dir_history = []
		map_selector_dir_history_at = -1
		Forward("");
	}
	
	Close = function() {
		map_selector.is_enabled = false
		if !is_undefined(close_callback) {
			close_callback()	
		}
	}
	
	Back = function() {
		map_selector_dir_history_at -= 1
		array_delete(map_selector_dir_history,array_length(map_selector_dir_history)-1,1)
		Load(map_selector_dir_history[map_selector_dir_history_at])
	}

	Forward = function(_dir) {
		array_push(map_selector_dir_history,_dir)
		map_selector_dir_history_at += 1
		Load(map_selector_dir_history[map_selector_dir_history_at])
	}
	
	static Load = function(_dir="") {
		show_debug_message(map_selector_dir_history)
		show_debug_message(_dir)
		
		ds_grid_clear(map_selector.options,undefined)
		if _dir == "" {
			map_selector.AddOption(Close,0,0,"back",spr_mapback)	
		}
		else {
			map_selector.AddOption(Back,0,0,"back",spr_mapback)	
		}
	
		var mapsdirectory = working_directory + "Maps/" + _dir
	
		///get cup folders
		var ds_folders = ds_list_create();
	
		var folder = file_find_first(mapsdirectory + "*", fa_directory);
		while(folder != "") {
			var path = mapsdirectory + folder
			if directory_exists(path) {
				ds_list_add(ds_folders, folder);	
			}
			folder = file_find_next();
		}

		for(var index = 0; index < ds_list_size(ds_folders); index++) {
			var _fname = ds_folders[| index]
			var _cup_name = _fname + " cup"
			var _optpos = idx_to_coord(index+1,ds_grid_width(map_selector.options))
			map_selector.AddOptionFillHorizontal(Forward,string_lower(_cup_name),spr_emptycup,_dir+ _fname + "/")
		}
	
		ds_list_destroy(ds_folders);
	
		///show levels
		if (directory_exists(mapsdirectory)) {
			//show_debug_message(mapsdirectory)
		    var fileName = file_find_first(mapsdirectory + "*.zip", 0);
			var t= 1
		    while(fileName != ""){
				var _filepath = _dir + fileName
				var _optpos = idx_to_coord(t,ds_grid_width(map_selector.options))
				var _spr = undefined
				if ds_map_exists(loaded_map_thumbnails,fileName) {
					_spr = ds_map_find_value(loaded_map_thumbnails,fileName)
				}
				else {
					var _thumb = get_map_thumbnail(_filepath)
					if !is_undefined(_thumb) {
						ds_map_add(loaded_map_thumbnails,fileName,_thumb)
						_spr = ds_map_find_value(loaded_map_thumbnails,fileName)
					}
				}
				map_selector.AddOptionFillHorizontal(selected_level_callback,string_lower(fileName),_spr,_filepath,string_lower(fileName))
				t += 1
		        fileName = file_find_next();
		    }
		    file_find_close();
		}
		else {
			show_debug_message("Maps directory not found")
			return false
		}
	
		return true
	}
	
	static Update = function() {
		map_selector.Update()
		map_selector.dx = (camera_get_view_x(view_camera[view])+(camera_get_view_width(view_camera[view])/2))-(map_selector.dw/2)
		map_selector.dy = (camera_get_view_y(view_camera[view])+(camera_get_view_height(view_camera[view])/2))-(map_selector.dh/2)
	}
	
	static Draw = function() {
		if map_selector.is_enabled {
			var _lip = 12+4
			draw_sprite_stretched(spr_uipanel2,0,map_selector.dx-8,map_selector.dy-8-_lip,map_selector.dw+16,map_selector.dh+16+_lip)
			draw_set_halign(fa_center)
			draw_set_valign(fa_top)
			draw_set_color(c_white)
			draw_set_alpha(1)
			draw_text(map_selector.dx+(map_selector.dw/2),map_selector.dy-8-_lip+4,"installed maps")
		}
		map_selector.Draw()	
	}
	
	static CleanUp = function() {
		var size = ds_map_size(loaded_map_thumbnails) ;
		var key = ds_map_find_first(loaded_map_thumbnails);
		for (var i = 0; i < size; i++;)
		{
			sprite_delete(ds_map_find_value(loaded_map_thumbnails,key))
		    key = ds_map_find_next(loaded_map_thumbnails, key);
		}
		
		show_debug_message("CLEANED UP MAP SELECTOR")
	}
	
	static MouseInside = function()
	{
		return map_selector.MouseInside()
	}
}
