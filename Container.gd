extends Container

#Creates a radial container node
   
@export var button_radius = 100 #in godot position units
@export var radial_width = 50 #in godot position units
@export var selector : Texture2D
@export var selected = 0
var selectionnables = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var c = find_child("Selector")
	c.find_child("TextureRect").texture = selector

	place_buttons()
		
		
func count_visibles():
	var buttons = get_children()
	var c = 0
	for b in buttons:
		if b.name != "Selector":
			if b.visble:
				c+=1
	return c
			
#Repositions the buttons
func place_buttons():
	var buttons = get_children()
	selected = selected % (buttons.size()-1)
	
	#Stop before we cause problems when no buttons are available
	if buttons.size() == 1:
		return
	
	#Amount to change the angle for each button
	var angle_offset = (2*PI)/(buttons.size()-1) #in degrees
	
	var angle = 0 #in radians
	var i = 0
	for btn in buttons:
		if btn.name != "Selector":
			if btn.has_method("is_selectable"):
				if btn.is_selectable():
					selectionnables.append(i)
			else:
				selectionnables.append(i)
				
			#calculate the x and y positions for the button at that angle
			var x = cos(angle)*button_radius
			var y = sin(angle)*button_radius
		
			var corner_pos = Vector2(x, -y)-(btn.get_size()/2) #Screen coordinates so calculated y must be negated
			btn.set_position(corner_pos)
			
			angle += angle_offset
			i += 1
	if selectionnables.size() == 0:
		return
	angle = selectionnables[selected] * angle_offset
	var x = cos(angle)*button_radius
	var y = sin(angle)*button_radius
	var corner_pos = Vector2(x, -y)-($Selector.get_size()/2) #Screen coordinates so calculated y must be negated
	$Selector.set_position(corner_pos)
		

func add_button(btn):
	add_child(btn)
	place_buttons()
