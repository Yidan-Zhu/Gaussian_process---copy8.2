extends Line2D

##################
#     PARAMS
##################

# math param
var fixed_coord
var slopes
var step = 0.01

var trial_fx_loc = Array()
var trial_slopes1 = []
var trial_slopes2 = []
var total_fx_yL1 = []  # y vector
var total_fx_yL2 = []
var total_fx_locL1 = []
var total_fx_locL2 = []
var slope_point_x = Vector2()
var slope_point_y = Vector2()

# other param
onready var node_point = get_node("../draw_and_control_thepoints")

# draw vectors
var drawVecL1 = []
var center = Vector2(280,270)
var box_width = 350
var box_height = 230
var conversion_index = 30.0
var arrow_colr = Color(1,0,0,0.5)
var step_dist = 0.1

# calculation efficiency
onready var flag_node = get_node("../draw_and_control_thepoints")
var flag_moved

# smooth vector lines
var vector_limit = 0.3  # the real number
var shrink_cof

###################

func _ready():
	center = center + Vector2(-box_width/2.0,box_height/2.0)

func _process(_delta):
	fixed_coord = node_point.point_coord
	slopes = node_point.slope_value
	flag_moved = flag_node.pointmoved


	if flag_moved == true:  # calculate only when something is changed
	
	# have a list of fixed points + slope points
	# have a corresponding z values of those points
		trial_fx_loc = fixed_coord
		trial_slopes1 = []
		trial_slopes2 = []
			
#		trial_fx_loc = [conversion_index*Vector2(-1,1), \
#			conversion_index*Vector2(-1,-1)]	
#		trial_slopes1 = [Vector2(0,-2),Vector2(0,-2)]
#		trial_slopes2 = [Vector2(-1,-2),Vector2(-1,2)]
#		step_dist = 0.01
		
		for k in range(len(slopes)):
			trial_slopes1.append(Vector2(slopes[k][0],slopes[k][1]))
			trial_slopes2.append(Vector2(slopes[k][2],slopes[k][3]))
		step_dist = 0.05
			
		total_fx_yL1 = []  # y vector
		total_fx_yL2 = []
		total_fx_locL1 = []
		total_fx_locL2 = []
		slope_point_x = Vector2()
		slope_point_y = Vector2()
		
		for i in range(len(trial_fx_loc)):
			# fixed zero point, y vector
			total_fx_yL1.append(0)
			total_fx_locL1.append(trial_fx_loc[i]/conversion_index)
			
			total_fx_yL2.append(0)
			total_fx_locL2.append(trial_fx_loc[i]/conversion_index)
			
			# x direction
			if trial_slopes1[i].x != 0:
				slope_point_x.x = trial_fx_loc[i].x/conversion_index + step
				slope_point_x.y = trial_fx_loc[i].y/conversion_index
				total_fx_locL1.append(slope_point_x)
				total_fx_yL1.append(step*trial_slopes1[i].x)
	
			if trial_slopes2[i].x != 0:
				slope_point_x.x = trial_fx_loc[i].x/conversion_index + step
				slope_point_x.y = trial_fx_loc[i].y/conversion_index
				total_fx_locL2.append(slope_point_x)
				total_fx_yL2.append(step*trial_slopes2[i].x)
						
			# y direction
			if trial_slopes1[i].y != 0:
				slope_point_y.x = trial_fx_loc[i].x/conversion_index
				slope_point_y.y = trial_fx_loc[i].y/conversion_index - step # y is negative on canvas
				total_fx_locL1.append(slope_point_y)
				total_fx_yL1.append(step*trial_slopes1[i].y)
	
			if trial_slopes2[i].y != 0:
				slope_point_y.x = trial_fx_loc[i].x/conversion_index
				slope_point_y.y = trial_fx_loc[i].y/conversion_index - step
				total_fx_locL2.append(slope_point_y)
				total_fx_yL2.append(step*trial_slopes2[i].y)
		
		var matrix_middle1 = matrix_base(total_fx_locL1)
		matrix_middle1 = inverse_big_matrix(matrix_middle1)
		
		var matrix_middle2 = matrix_base(total_fx_locL2)
		matrix_middle2 = inverse_big_matrix(matrix_middle2)	
	
		# data to draw the vector fields
		var new_pt
		var kernel_vec1
		var kernel_vec2
		var mean_x
		var mean_y
		drawVecL1 = []
	
		var new_end
		# from the upper-edge of the box
		for i in range(10,box_width+1,30):
			for k in range(-10, -box_height-1, -30):
				new_pt = Vector2(i/conversion_index, k/conversion_index) 
					# the point coordinate should be the number, not canvas coord
		
				kernel_vec1 = kernel_vector(total_fx_locL1,new_pt)
				kernel_vec2 = kernel_vector(total_fx_locL2,new_pt)
		
				mean_x = vec_matx_vec_multiply(kernel_vec1, matrix_middle1, \
					total_fx_yL1)
				mean_y = vec_matx_vec_multiply(kernel_vec2, matrix_middle2, \
					total_fx_yL2)
				
				var vector_len = dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0))
					
				if dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0)) \
					<= vector_limit:
					drawVecL1.append([new_pt.x, -new_pt.y, mean_x, mean_y,vector_len]) # the normal number	
					new_end = new_pt + Vector2(mean_x, -mean_y)  # y is negative
				else:
					shrink_cof = dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0))
					shrink_cof = vector_limit/shrink_cof
					mean_x = mean_x*shrink_cof
					mean_y = mean_y*shrink_cof
					drawVecL1.append([new_pt.x, -new_pt.y, mean_x, mean_y,vector_len]) # the normal number	
					new_end = new_pt + Vector2(mean_x, -mean_y)  # y is negative					
				
				#for _j in range(40):
				while (new_end != new_pt) and\
					vector_len > step_dist and\
					new_end.x > 0 and\
					new_end.x < box_width/conversion_index and\
					new_end.y < 0 and\
					new_end.y > -box_height/conversion_index:				
				
					new_pt = new_end
		
					kernel_vec1 = kernel_vector(total_fx_locL1,new_pt)
					kernel_vec2 = kernel_vector(total_fx_locL2,new_pt)
		
					mean_x = vec_matx_vec_multiply(kernel_vec1, matrix_middle1, \
						total_fx_yL1)
					mean_y = vec_matx_vec_multiply(kernel_vec2, matrix_middle2, \
						total_fx_yL2)
						
					vector_len = dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0))
						
					if dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0)) \
						<= vector_limit:
						drawVecL1.append([new_pt.x, -new_pt.y, mean_x, mean_y,vector_len]) # the normal number	
						new_end = new_pt + Vector2(mean_x, -mean_y)  # y is negative
					else:
						shrink_cof = dist_two_points(Vector2(mean_x, mean_y),Vector2(0,0))
						shrink_cof = vector_limit/shrink_cof
						mean_x = mean_x*shrink_cof
						mean_y = mean_y*shrink_cof
						drawVecL1.append([new_pt.x, -new_pt.y, mean_x, mean_y,vector_len]) # the normal number	
						new_end = new_pt + Vector2(mean_x, -mean_y)  # y is negative					
		
					# break the loop if out of the region
#					if new_end.x < 0 \
#						or new_end.x > box_width/conversion_index \
#						or new_end.y < 0 \
#						or new_end.y > box_height/conversion_index:
#						break
#
#					if new_end == new_pt:
#						break
#
#					if dist_two_points(new_end, new_pt) < 0.1:
#						break	
			
		update()
		flag_moved = false
		flag_node.pointmoved = false

func _draw():
	var current_loc
	var end_loc
	for i in range(len(drawVecL1)):
		current_loc = center + Vector2(conversion_index*drawVecL1[i][0],\
			-conversion_index*drawVecL1[i][1])  # center is the origin point
			# y value here is positive

		end_loc = current_loc+Vector2(conversion_index*drawVecL1[i][2],\
			-conversion_index*drawVecL1[i][3])
			
		if current_loc.x > center.x \
			and current_loc.x < (center.x + box_width) \
			and current_loc.y < center.y \
			and current_loc.y > (center.y - box_height) \
			and end_loc.x > center.x \
			and end_loc.x < (center.x + box_width) \
			and end_loc.y < center.y \
			and end_loc.y > (center.y - box_height):
			if current_loc != end_loc: # not zero vector
				# mark the color by gradient
				# gradual color change
				arrow_colr = Color(drawVecL1[i][4]/3.0, 0, \
					1-drawVecL1[i][4]/5.0,1)

				# draw lines and arrows					
				draw_line(current_loc, end_loc, arrow_colr, 1.5, true)
				# draw an arrow every 20 points
				if i%20 == 0:
					draw_small_arrow(end_loc, Vector2(drawVecL1[i][2],-drawVecL1[i][3]),\
						arrow_colr)
						

######### define the functions ##########
func kernel(loc1:Vector2, loc2:Vector2, L=2):
	var nominator = (loc1.x - loc2.x)*(loc1.x - loc2.x)+\
		(loc1.y - loc2.y)*(loc1.y - loc2.y)
	var denominator = 2*L*L
	return exp(-nominator/denominator)

func matrix_base(fixed_point_locL):
	var matx = []
	for x in range(len(fixed_point_locL)):
		matx.append([])
		for y in range(len(fixed_point_locL)):
			matx[x].append(kernel(fixed_point_locL[x],fixed_point_locL[y]))
	return matx
	
	
func det_of_matrix(matrixA):
	var dimension = len(matrixA) 

# calculated the determinant
	var determinant = 0
	var element=1
	
	if dimension == 3: 
		# the positive part of det
		for i in range(dimension): # start column
			element=1
			for j in range(dimension): # row number
				if i+j<dimension:
					element=element*matrixA[j][i+j]
				else:
					element = element*matrixA[j][i+j-dimension]
			determinant = determinant+element
		# the negative part of det
		for i in range(dimension-1,-1,-1): # start column
			element=1
			for j in range(dimension): # row number
				if i-j >= 0:	
					element = element*matrixA[j][i-j]
				else:
					element = element*matrixA[j][i-j+dimension]
			determinant = determinant-element		
	elif dimension == 2:
		determinant = matrixA[0][0]*matrixA[1][1] - matrixA[0][1]*matrixA[1][0]
	elif dimension == 1: # only one point
		determinant = matrixA[0][0]	
	elif dimension == 4: ## use recursive method
		determinant = matrixA[0][0]*det_of_matrix(alg_cofactor_matrix(0,0,matrixA)) -\
			matrixA[0][1]*det_of_matrix(alg_cofactor_matrix(0,1,matrixA))+\
			matrixA[0][2]*det_of_matrix(alg_cofactor_matrix(0,2,matrixA))-\
			matrixA[0][3]*det_of_matrix(alg_cofactor_matrix(0,3,matrixA))
	elif dimension > 4:
		determinant = 0
		for i in range(dimension):
			determinant = determinant + matrixA[0][i]*pow(-1,i)*\
				det_of_matrix((alg_cofactor_matrix(0,i,matrixA)))
		
	return determinant


func inverse_big_matrix(matrixB):
	var det = det_of_matrix(matrixB)
# the conjugate matrix
	var conj_matx = []
	var coefficient
	var det_small_matx = []
	
	if len(matrixB) > 2:
		for i in range(len(matrixB)): # row number
			conj_matx.append([])  # define the conj_matx
			for j in range(len(matrixB)): # column number
				coefficient = pow(-1,i+j)
				det_small_matx = alg_cofactor_matrix(i,j,matrixB)						
				conj_matx[i].append(coefficient*det_of_matrix(det_small_matx))

	elif len(matrixB) == 2:
		for i in range(len(matrixB)):
			conj_matx.append([])
			if i == 0:
				conj_matx[i].append(matrixB[1][1])
				conj_matx[i].append(-matrixB[0][1])
			else:
				conj_matx[i].append(-matrixB[1][0])
				conj_matx[i].append(matrixB[0][0])
				
	else:
		conj_matx = matrixB	
	
	# divided by det		
	for i in range(len(conj_matx)):
		for j in range(len(conj_matx)):
			conj_matx[i][j] = conj_matx[i][j]/(det*1.0)		
	
	if len(conj_matx) > 2: 
	# the final result is the transpose of 3x3 and above, error somewhere
		var new_matx = conj_matx.duplicate(true)
		for i in range(len(new_matx)):
			for j in range(len(new_matx)):
				conj_matx[i][j] = new_matx[j][i]
			
	return conj_matx


func kernel_vector(fixedL, newPt:Vector2):
	var kernel_vec = []
	for i in range(len(fixedL)):
		kernel_vec.append(kernel(fixedL[i],newPt))
	
	return kernel_vec


func vec_matx_vec_multiply(leftV, matx, rightV):
	var transit_vec = []
	for i in range(len(leftV)): # col
		transit_vec.append(0)
		for j in range(len(leftV)): # row
			transit_vec[i] = transit_vec[i] + leftV[j]*matx[j][i]
	
	var mean = 0
	for i in range(len(leftV)):		
		mean = mean + transit_vec[i]*rightV[i]
	
	return mean

	
func draw_small_arrow(location, direction, color):
	var len_dir = direction.x * direction.x + direction.y * direction.y
	len_dir = sqrt(len_dir)
	direction = direction/len_dir
	
	var b = location + direction.rotated(PI*5.0/6.0)*7
	draw_line(b, location, color, 1.5, true)
	var c = location + direction.rotated(-PI*5.0/6.0)*7
	draw_line(c, location, color, 1.5, true)

func dist_two_points(point1, point2):
	var square_dist 
	square_dist = (point1.x - point2.x)*(point1.x - point2.x) + \
		(point1.y - point2.y)*(point1.y - point2.y)
	return sqrt(square_dist)

func alg_cofactor_matrix(row_id,col_id,big_matx):
	var alg_cofactor_matx = []
	
	# generate the small matrix for det calculation
	for k in range(len(big_matx)): # row number small
		if k==row_id:
			continue # skip row i
		else:
			if k < row_id: # before the row
				alg_cofactor_matx.append([])
				for g in range(len(big_matx)): # col number small
					if g==col_id:
						continue # skip col j
					else:
						alg_cofactor_matx[k].append(big_matx[k][g])
															
			else: # after the row
				alg_cofactor_matx.append([])
				for g in range(len(big_matx)): # col number small
					if g==col_id:
						continue # skip col j
					else:
						alg_cofactor_matx[k-1].append(big_matx[k][g])

	return alg_cofactor_matx
