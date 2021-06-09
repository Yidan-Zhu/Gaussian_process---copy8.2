extends Line2D

##################
#     PARAMS
##################

# finger control points
var events = {}
var pointmoved = false
var finger_loc
var touch_dist = 15
var movedpt = {}

# point drawing
var numpoints = 2
var pre_nump = 2
var point_coord = Array()
var rng = RandomNumberGenerator.new()
var overlapping_dist = 20
var margin_buff = 10

# axes position
var center = Vector2(280,270)
var box_width = 350
var box_height = 230

var axes_origin = center + Vector2(-box_width/2.0,box_height/2.0)

# slope
var slp_leg_loc = Vector2(590,130)
var spacingx = Vector2(-80,0)
var spacingy = Vector2(0,70)

onready var slider_slope1x = get_node("HSlider_slope1x")
onready var slider_max_text1x = get_node("HSlider_slope1x/Label_slope_max")
onready var slider_min_text1x = get_node("HSlider_slope1x/Label_slope_min")

onready var slider_slope1y = get_node("HSlider_slope1y")
onready var slider_max_text1y = get_node("HSlider_slope1y/Label_slope_max")
onready var slider_min_text1y = get_node("HSlider_slope1y/Label_slope_min")
onready var slider_slope2x = get_node("HSlider_slope2x")
onready var slider_max_text2x = get_node("HSlider_slope2x/Label_slope_max")
onready var slider_min_text2x = get_node("HSlider_slope2x/Label_slope_min")
onready var slider_slope2y = get_node("HSlider_slope2y")
onready var slider_max_text2y = get_node("HSlider_slope2y/Label_slope_max")
onready var slider_min_text2y = get_node("HSlider_slope2y/Label_slope_min")

onready var slider_title = get_node("slider_title")
var slope_txt_1x_spacing = Vector2(40,-1)
var slope_txt_1y_spacing = Vector2(80,-1)
var slope_txt_2x_spacing = Vector2(40,25)
var slope_txt_2y_spacing = Vector2(80,25)
var dot_text_yspacing = Vector2(0,60)

var color1 = Color(255/255.0,255/255.0,0,1)
var color2 = Color(0,240/255.0,231/255.0,1)
var color3 = Color(158/255.0,43/255.0,159/255.0,1)
var color4 = Color(47/255.0,57/255.0,200/255.0,1)

var slope_value = Array()
var slider_current_idx = -1
var slider_initial = true

# efficiency
var slider_pre1x
var slider_pre1y
var slider_pre2x
var slider_pre2y

var slider_now1x
var slider_now1y
var slider_now2x
var slider_now2y

#########################

func _ready():
	slider_current_idx = numpoints-1
	
	rng.randomize()
	# generate initial two fixed points
	for _i in range(numpoints):
		var add_point = Vector2(rng.randf_range(margin_buff, \
			box_width-margin_buff),\
			rng.randf_range(-box_height+margin_buff,-margin_buff))
		var test_flag = true	
		
		for item in point_coord:
			if dist_two_points(item,add_point) < overlapping_dist:
				test_flag = false

		while test_flag == false:
			add_point = Vector2(rng.randf_range(0, box_width),\
				rng.randf_range(0,box_height))	
			test_flag = true
			for item in point_coord:
				if dist_two_points(item,add_point) < overlapping_dist:
					test_flag = false					
		
		point_coord.append(add_point)
		
		slope_value.append([0,0,0,0])

	# title of sliders
	var dynamic_font2 = DynamicFont.new()
	dynamic_font2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font2.size = 17

	slider_title.set_global_position(\
		slp_leg_loc+spacingy*0.35+0.55*spacingx)
	slider_title.text = "Jacobian:    surf 1,x       surf 1,y  \n(Slopes)       surf 2,x       surf 2,y"
	slider_title.add_color_override("font_color", \
		ColorN("Brown"))
	slider_title.add_font_override("font",dynamic_font2)
		
	# initialize the sliders:1x
	slider_slope1x.set_global_position(slp_leg_loc+spacingx)
	slider_slope1x.rect_size = Vector2(100,16)
	slider_slope1x.min_value = -5
	slider_slope1x.max_value = 5
	slider_slope1x.step = 0.01
	slider_slope1x.value = 0
	
	slider_min_text1x.set_position(Vector2(-16,2))
	slider_max_text1x.set_position(Vector2(105,2))	
		
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 15

	slider_min_text1x.text = str(slider_slope1x.min_value)
	slider_min_text1x.add_color_override("font_color",color1)
	slider_min_text1x.add_font_override("font",dynamic_font)	

	slider_max_text1x.text = str(slider_slope1x.max_value)
	slider_max_text1x.add_color_override("font_color",color1)
	slider_max_text1x.add_font_override("font",dynamic_font)

	# initialize the sliders:1y
	slider_slope1y.set_global_position(slp_leg_loc-spacingx)
	slider_slope1y.rect_size = Vector2(100,16)
	slider_slope1y.min_value = -5
	slider_slope1y.max_value = 5
	slider_slope1y.step = 0.01
	slider_slope1y.value = 0
	
	slider_min_text1y.set_position(Vector2(-16,2))
	slider_max_text1y.set_position(Vector2(105,2))	

	slider_min_text1y.text = str(slider_slope1x.min_value)
	slider_min_text1y.add_color_override("font_color",color2)
	slider_min_text1y.add_font_override("font",dynamic_font)	

	slider_max_text1y.text = str(slider_slope1x.max_value)
	slider_max_text1y.add_color_override("font_color",color2)
	slider_max_text1y.add_font_override("font",dynamic_font)

	# initialize the sliders:2x
	slider_slope2x.set_global_position(slp_leg_loc+spacingx+spacingy)
	slider_slope2x.rect_size = Vector2(100,16)
	slider_slope2x.min_value = -5
	slider_slope2x.max_value = 5
	slider_slope2x.step = 0.01
	slider_slope2x.value = 0
	
	slider_min_text2x.set_position(Vector2(-16,2))
	slider_max_text2x.set_position(Vector2(105,2))	

	slider_min_text2x.text = str(slider_slope1x.min_value)
	slider_min_text2x.add_color_override("font_color",color3)
	slider_min_text2x.add_font_override("font",dynamic_font)	

	slider_max_text2x.text = str(slider_slope1x.max_value)
	slider_max_text2x.add_color_override("font_color",color3)
	slider_max_text2x.add_font_override("font",dynamic_font)

	# initialize the sliders:2y
	slider_slope2y.set_global_position(slp_leg_loc-spacingx+spacingy)
	slider_slope2y.rect_size = Vector2(100,16)
	slider_slope2y.min_value = -5
	slider_slope2y.max_value = 5
	slider_slope2y.step = 0.01
	slider_slope2y.value = 0
	
	slider_min_text2y.set_position(Vector2(-16,2))
	slider_max_text2y.set_position(Vector2(105,2))	

	slider_min_text2y.text = str(slider_slope1x.min_value)
	slider_min_text2y.add_color_override("font_color",color4)
	slider_min_text2y.add_font_override("font",dynamic_font)	

	slider_max_text2y.text = str(slider_slope1x.max_value)
	slider_max_text2y.add_color_override("font_color",color4)
	slider_max_text2y.add_font_override("font",dynamic_font)


	slider_pre1x = slider_slope1x.value
	slider_pre1y = slider_slope1y.value
	slider_pre2x = slider_slope2x.value
	slider_pre2y = slider_slope2y.value

func _input(event):
# take the most recent one finger-touch inputs
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
			pointmoved = true
		else:
			events.erase(event.index)	
			movedpt.erase(0)
			slider_initial = true
			pointmoved = true

# use the touch in the axis region
	if event.position.x > axes_origin.x and \
		event.position.x < axes_origin.x+box_width \
		and event.position.y < axes_origin.y and \
		event.position.y > axes_origin.y-box_height:
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and \
			event.is_pressed()):  # drag or touch input
			events[event.index] = event
			if events.size() == 1: # one finger input
				finger_loc = event.position - axes_origin
				if movedpt.size() == 1:
					point_coord[movedpt[0]] = finger_loc
					update()
				else:
					for i in range(numpoints):			
						if dist_two_points(finger_loc,point_coord[i]) \
							< touch_dist:
							#pointmoved = true
							movedpt[0] = i
							point_coord[i] = finger_loc	
							
							if slider_initial:
								slider_slope1x.value = slope_value[movedpt[0]][0]
								slider_slope1y.value = slope_value[movedpt[0]][1]
								slider_slope2x.value = slope_value[movedpt[0]][2]
								slider_slope2y.value = slope_value[movedpt[0]][3]
								slider_initial = false
								slider_current_idx = movedpt[0]	
								
							update()
							break					

# use touch to switch to a text 
	else:
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and \
			event.is_pressed()):  # drag or touch input
			events[event.index] = event
			if events.size() == 1: # one finger input
				if event.position.x >= 550 and event.position.x <= 630:
					# point 1
					if event.position.y >=238 and event.position.y <= 250 \
						and numpoints >=1:
						slider_current_idx = 0
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						#slider_initial = false
						update()
					# point 2
					elif event.position.y >=298 and event.position.y <= 308 \
						and numpoints >=2:
						slider_current_idx = 1
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						update()
					elif event.position.y >=358 and event.position.y <= 371 \
						and numpoints >=3:
						slider_current_idx = 2
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						update()
					elif event.position.y >=419 and event.position.y <= 430 \
						and numpoints >=4:
						slider_current_idx = 3
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						update()
					elif event.position.y >=479 and event.position.y <= 489 \
						and numpoints >=5:
						slider_current_idx = 4
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						update()
					elif event.position.y >=540 and event.position.y <= 550 \
						and numpoints >=6:
						slider_current_idx = 5
						slider_slope1x.value = slope_value[slider_current_idx][0]
						slider_slope1y.value = slope_value[slider_current_idx][1]
						slider_slope2x.value = slope_value[slider_current_idx][2]
						slider_slope2y.value = slope_value[slider_current_idx][3]
						update()
					

func _process(_delta):
	# efficiency unit
	slider_now1x = slider_slope1x.value
	slider_now1y = slider_slope1y.value
	slider_now2x = slider_slope2x.value
	slider_now2y = slider_slope2y.value
	
	if slider_pre1x != slider_now1x:
		pointmoved = true
		slider_pre1x = slider_now1x
	if slider_pre1y != slider_now1y:
		pointmoved = true
		slider_pre1y = slider_now1y
	if slider_pre2x != slider_now2x:
		pointmoved = true
		slider_pre2x = slider_now2x
	if slider_pre2y != slider_now2y:
		pointmoved = true
		slider_pre2y = slider_now2y	
	
	# 
	if pre_nump < numpoints:
		pointmoved = true
		# generate more points
		for _i in range(pre_nump,numpoints):
			var add_point = Vector2(rng.randf_range(margin_buff, \
				box_width-margin_buff),\
				rng.randf_range(-box_height+margin_buff,-margin_buff))
			var test_flag = true	
			
			for item in point_coord:
				if dist_two_points(item,add_point) < overlapping_dist:
					test_flag = false
	
			while test_flag == false:
				add_point = Vector2(rng.randf_range(margin_buff, \
					box_width-margin_buff),\
					rng.randf_range(-box_height+margin_buff,-margin_buff))	
				test_flag = true
				for item in point_coord:
					if dist_two_points(item,add_point) < overlapping_dist:
						test_flag = false					
			
			point_coord.append(add_point)
			slope_value.append([0,0,0,0])
			
		pre_nump = numpoints
		update()
	
	elif pre_nump > numpoints:
		pointmoved = true
		# delete the points at the right side of the array
		for i in range(pre_nump-numpoints):
			point_coord.remove(numpoints-i)	
			slope_value.remove(numpoints-i)
			
		pre_nump = numpoints
		if slider_current_idx >= numpoints:
			slider_current_idx = len(point_coord)-1
		
		update()		
	

	# update the slope value and text
	if numpoints>=0:
		for _i in range(numpoints):
			# slope text
			if !get_node_or_null("val_slope"+str(_i)):
				var node = Label.new()
				node.name = "val_slope"+str(_i)
				add_child(node)		
				node.set_global_position(slp_leg_loc+\
					_i*dot_text_yspacing+dot_text_yspacing*1.8+0.5*spacingx)
					
			get_node("val_slope"+str(_i)).text = \
				"Slope of Pt "+str(_i+1)+": "
						
			# slope 1x
			if !get_node_or_null("val_slope1x"+str(_i)):
				var node = Label.new()
				node.name = "val_slope1x"+str(_i)
				add_child(node)		
				node.set_global_position(slp_leg_loc+_i*dot_text_yspacing+\
					dot_text_yspacing*1.8+slope_txt_1x_spacing-0.2*spacingx)
				node.text = str(slope_value[_i][0])	
					
			# slope 1y
			if !get_node_or_null("val_slope1y"+str(_i)):
				var node = Label.new()
				node.name = "val_slope1y"+str(_i)
				add_child(node)		
				node.set_global_position(slp_leg_loc+_i*dot_text_yspacing+\
					dot_text_yspacing*1.8+slope_txt_1y_spacing-0.2*spacingx)
				node.text = str(slope_value[_i][1])	
	
			# slope 2x
			if !get_node_or_null("val_slope2x"+str(_i)):
				var node = Label.new()
				node.name = "val_slope2x"+str(_i)
				add_child(node)		
				node.set_global_position(slp_leg_loc+_i*dot_text_yspacing+\
					dot_text_yspacing*1.8++slope_txt_2x_spacing-0.2*spacingx)
				node.text = str(slope_value[_i][2])	
		
			# slope 2y
			if !get_node_or_null("val_slope2y"+str(_i)):
				var node = Label.new()
				node.name = "val_slope2y"+str(_i)
				add_child(node)		
				node.set_global_position(slp_leg_loc+_i*dot_text_yspacing+\
					dot_text_yspacing*1.8++slope_txt_2y_spacing-0.2*spacingx)
				node.text = str(slope_value[_i][3])	
					
	# choose the values by sliders if choosen
			if slider_current_idx == _i:
				
				slope_value[_i][0]=slider_slope1x.value
				get_node("val_slope1x"+str(_i)).text = str(slope_value[_i][0])
				
				slope_value[_i][1]=slider_slope1y.value
				get_node("val_slope1y"+str(_i)).text = str(slope_value[_i][1])
				
				slope_value[_i][2]=slider_slope2x.value
				get_node("val_slope2x"+str(_i)).text = str(slope_value[_i][2])
				
				slope_value[_i][3]=slider_slope2y.value
				get_node("val_slope2y"+str(_i)).text = str(slope_value[_i][3])
				
	# slope value text set to black when choosen
			if slider_current_idx == _i:
				
				get_node("val_slope"+str(_i)).add_color_override(\
					"font_color", ColorN("Black"))		
				get_node("val_slope1x"+str(_i)).add_color_override(\
					"font_color", color1)	
				get_node("val_slope1y"+str(_i)).add_color_override(\
					"font_color", color2)	
				get_node("val_slope2x"+str(_i)).add_color_override(\
					"font_color", color3)	
				get_node("val_slope2y"+str(_i)).add_color_override(\
					"font_color", color4)	
																					
			else:	
				get_node("val_slope"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope1x"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope1y"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope2x"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope2y"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	

	# remove the text when some points are removed
	for i in range(len(point_coord),6):
		if get_node_or_null("val_slope"+str(i)):
			get_node_or_null("val_slope"+str(i)).queue_free()
			get_node_or_null("val_slope1x"+str(i)).queue_free()
			get_node_or_null("val_slope1y"+str(i)).queue_free()
			get_node_or_null("val_slope2x"+str(i)).queue_free()
			get_node_or_null("val_slope2y"+str(i)).queue_free()
	

func _draw():
	# draw all fixed points
	for i in range(numpoints):
		if i!= slider_current_idx:
			draw_circle(axes_origin+point_coord[i],
				5.0, Color(63/255.0,72/255.0,204/255.0,1))
		else: # use a different color
			draw_circle(axes_origin+point_coord[i],
				5.0, Color(16/255.0,21/255.0,102/255.0,1))				
			
##############################

func dist_two_points(point1, point2):
	var square_dist 
	square_dist = (point1.x - point2.x)*(point1.x - point2.x) + \
		(point1.y - point2.y)*(point1.y - point2.y)
	return sqrt(square_dist)
