/matrix/proc/TurnTo(old_angle, new_angle)
	. = new_angle - old_angle
	Turn(.) //BYOND handles cases such as -270, 360, 540 etc. DOES NOT HANDLE 180 TURNS WELL, THEY TWEEN AND LOOK LIKE SHIT

/atom/proc/SpinAnimation(speed = 10, loops = -1, clockwise = 1, segments = 3, parallel = TRUE)
	if(!segments)
		return
	var/segment = 360/segments
	if(!clockwise)
		segment = -segment
	var/list/matrices = list()
	for(var/i in 1 to segments-1)
		var/matrix/M = matrix(transform)
		M.Turn(segment*i)
		matrices += M
	var/matrix/last = matrix(transform)
	matrices += last

	speed /= segments

	if(parallel)
		animate(src, transform = matrices[1], time = speed, loops , flags = ANIMATION_PARALLEL)
	else
		animate(src, transform = matrices[1], time = speed, loops)
	for(var/i in 2 to segments) //2 because 1 is covered above
		animate(transform = matrices[i], time = speed)
		//doesn't have an object argument because this is "Stacking" with the animate call above
		//3 billion% intentional

//Dumps the matrix data in format a-f
/matrix/proc/tolist()
	. = list()
	. += a
	. += b
	. += c
	. += d
	. += e
	. += f

//Dumps the matrix data in a matrix-grid format
/*
*  a d 0
*  b e 0
*  c f 1
*/
/matrix/proc/togrid()
	. = list()
	. += a
	. += d
	. += 0
	. += b
	. += e
	. += 0
	. += c
	. += f
	. += 1

//The X pixel offset of this matrix
/matrix/proc/get_x_shift()
	. = c

//The Y pixel offset of this matrix
/matrix/proc/get_y_shift()
	. = f

/matrix/proc/get_x_skew()
	. = b

/matrix/proc/get_y_skew()
	. = d

//Skews a matrix in a particular direction
//Missing arguments are treated as no skew in that direction

//As Rotation is defined as a scale+skew, these procs will break any existing rotation
//Unless the result is multiplied against the current matrix
/matrix/proc/set_skew(x = 0, y = 0)
	b = x
	d = y


/////////////////////
// COLOUR MATRICES //
/////////////////////

/* Documenting a couple of potentially useful color matrices here to inspire ideas
// Greyscale - indentical to saturation @ 0
list(LUMA_R,LUMA_R,LUMA_R,0, LUMA_G,LUMA_G,LUMA_G,0, LUMA_B,LUMA_B,LUMA_B,0, 0,0,0,1, 0,0,0,0)

// Color inversion
list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)

// Sepiatone
list(0.393,0.349,0.272,0, 0.769,0.686,0.534,0, 0.189,0.168,0.131,0, 0,0,0,1, 0,0,0,0)
*/

//Does nothing
/proc/color_matrix_identity()
	return list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)

//Adds/subtracts overall lightness
//0 is identity, 1 makes everything white, -1 makes everything black
/proc/color_matrix_lightness(power)
	return list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, power,power,power,0)

//Changes distance hues have from grey while maintaining the overall lightness. Greys are unaffected.
//1 is identity, 0 is greyscale, >1 oversaturates colors
/proc/color_matrix_saturation(value)
	var/inv = 1 - value
	var/R = round(LUMA_R * inv, 0.001)
	var/G = round(LUMA_G * inv, 0.001)
	var/B = round(LUMA_B * inv, 0.001)

	return list(R + value,R,R,0, G,G + value,G,0, B,B,B + value,0, 0,0,0,1, 0,0,0,0)

//Changes distance colors have from rgb(127,127,127) grey
//1 is identity. 0 makes everything grey >1 blows out colors and greys
/proc/color_matrix_contrast(value)
	var/add = (1 - value) / 2
	return list(value,0,0,0, 0,value,0,0, 0,0,value,0, 0,0,0,1, add,add,add,0)

//Moves all colors angle degrees around the color wheel while maintaining intensity of the color and not affecting greys
//0 is identity, 120 moves reds to greens, 240 moves reds to blues
/proc/color_matrix_rotate_hue(angle)
	var/sin = sin(angle)
	var/cos = cos(angle)
	var/cos_inv_third = 0.333*(1-cos)
	var/sqrt3_sin = sqrt(3)*sin
	return list(
round(cos+cos_inv_third, 0.001), round(cos_inv_third+sqrt3_sin, 0.001), round(cos_inv_third-sqrt3_sin, 0.001), 0,
round(cos_inv_third-sqrt3_sin, 0.001), round(cos+cos_inv_third, 0.001), round(cos_inv_third+sqrt3_sin, 0.001), 0,
round(cos_inv_third+sqrt3_sin, 0.001), round(cos_inv_third-sqrt3_sin, 0.001), round(cos+cos_inv_third, 0.001), 0,
0,0,0,1,
0,0,0,0)

//These next three rotate values about one axis only
//x is the red axis, y is the green axis, z is the blue axis.
/proc/color_matrix_rotate_x(angle)
	var/sinval = round(sin(angle), 0.001); var/cosval = round(cos(angle), 0.001)
	return list(1,0,0,0, 0,cosval,sinval,0, 0,-sinval,cosval,0, 0,0,0,1, 0,0,0,0)

/proc/color_matrix_rotate_y(angle)
	var/sinval = round(sin(angle), 0.001); var/cosval = round(cos(angle), 0.001)
	return list(cosval,0,-sinval,0, 0,1,0,0, sinval,0,cosval,0, 0,0,0,1, 0,0,0,0)

/proc/color_matrix_rotate_z(angle)
	var/sinval = round(sin(angle), 0.001); var/cosval = round(cos(angle), 0.001)
	return list(cosval,sinval,0,0, -sinval,cosval,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)


//Returns a matrix addition of A with B
/proc/color_matrix_add(list/A, list/B)
	if(!istype(A) || !istype(B))
		return color_matrix_identity()
	if(A.len != 20 || B.len != 20)
		return color_matrix_identity()
	var/list/output = list()
	output.len = 20
	for(var/value in 1 to 20)
		output[value] = A[value] + B[value]
	return output

//Returns a matrix multiplication of A with B
/proc/color_matrix_multiply(list/A, list/B)
	if(!istype(A) || !istype(B))
		return color_matrix_identity()
	if(A.len != 20 || B.len != 20)
		return color_matrix_identity()
	var/list/output = list()
	output.len = 20
	var/x = 1
	var/y = 1
	var/offset = 0
	for(y in 1 to 5)
		offset = (y-1)*4
		for(x in 1 to 4)
			output[offset+x] = round(A[offset+1]*B[x] + A[offset+2]*B[x+4] + A[offset+3]*B[x+8] + A[offset+4]*B[x+12]+(y==5?B[x+16]:0), 0.001)
	return output

///Converts RGB shorthands into RGBA matrices complete of constants rows (ergo a 20 keys list in byond).
/proc/color_to_full_rgba_matrix(color)
	if(istext(color))
		var/list/L = ReadRGB(color)
		if(!L)
			CRASH("Invalid/unsupported color format argument in color_to_full_rgba_matrix()")
		return list(L[1]/255,0,0,0, 0,L[2]/255,0,0, 0,0,L[3]/255,0, 0,0,0,L.len>3?L[4]/255:1, 0,0,0,0)
	else if(!islist(color)) //invalid format
		return color_matrix_identity()
	var/list/L = color
	switch(L.len)
		if(3 to 5) // row-by-row hexadecimals
			. = list()
			for(var/a in 1 to L.len)
				var/list/rgb = ReadRGB(L[a])
				for(var/b in rgb)
					. += b/255
				if(length(rgb) % 4) // RGB has no alpha instruction
					. += a != 4 ? 0 : 1
			if(L.len < 4) //missing both alphas and constants rows
				. += list(0,0,0,1, 0,0,0,0)
			else if(L.len < 5) //missing constants row
				. += list(0,0,0,0)
		if(9 to 12) //RGB
			. = list(L[1],L[2],L[3],0, L[4],L[5],L[6],0, L[7],L[8],L[9],0, 0,0,0,1)
			for(var/b in 1 to 3)  //missing constants row
				. += L.len < 9+b ? 0 : L[9+b]
			. += 0
		if(16 to 20) // RGBA
			. = L.Copy()
			if(L.len < 20) //missing constants row
				for(var/b in 1 to 20-L.len)
					. += 0
		else
			CRASH("Invalid/unsupported color format argument in color_to_full_rgba_matrix()")

/atom/proc/shake_animation(intensity = 8, time = 2) //Makes the object visibly shake
	var/initial_transform = new/matrix(transform)
	var/init_px = pixel_x
	var/shake_dir = pick(-1, 1)
	var/rotation = 2+soft_cap(intensity, 1, 1, 0.94)
	var/offset = 1+soft_cap(intensity*0.3, 1, 1, 0.8)
	animate(src, transform=turn(transform, rotation*shake_dir), pixel_x=init_px + offset*shake_dir, time=1)
	animate(transform=initial_transform, pixel_x=init_px, time, easing=ELASTIC_EASING)

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMR 0.2126
#define LUMG 0.7152
#define LUMB 0.0722

//Still need color matrix addition, negation, and multiplication.

//Returns an identity color matrix which does nothing
/proc/color_identity()
	return list(1,0,0, 0,1,0, 0,0,1)

//Moves all colors angle degrees around the color wheel while maintaining intensity of the color and not affecting whites
//TODO: Need a version that only affects one color (ie shift red to blue but leave greens and blues alone)
/proc/color_rotation(angle)
	if(angle == 0)
		return color_identity()
	angle = Clamp(angle, -180, 180)
	var/cos = cos(angle)
	var/sin = sin(angle)

	var/constA = 0.143
	var/constB = 0.140
	var/constC = -0.283
	return list(
	LUMR + cos * (1-LUMR) + sin * -LUMR, LUMR + cos * -LUMR + sin * constA, LUMR + cos * -LUMR + sin * -(1-LUMR),
	LUMG + cos * -LUMG + sin * -LUMG, LUMG + cos * (1-LUMG) + sin * constB, LUMG + cos * -LUMG + sin * LUMG,
	LUMB + cos * -LUMB + sin * (1-LUMB), LUMB + cos * -LUMB + sin * constC, LUMB + cos * (1-LUMB) + sin * LUMB
	)

#undef LUMR
#undef LUMG
#undef LUMB
