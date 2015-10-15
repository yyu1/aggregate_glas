;Set of functions for transforming projection coordinates involving the MODIS sinusoidal projection.
;Author - Yifan Yu
;Date created - 4/17/2012
;Modified - 10/11/2012  : added sin_to_ddlonlat to return in degrees instead of radians

function sin_to_lonlat, in_x, in_y
	;MODIS definitions
	R_earth = 6371007.181   ;MODIS sinusoidal sphere radius in m
	PI = 3.141592653589793238d0
	HALF_PI = (PI * 0.5)
	return_lat = in_y / R_earth
	return_lon = in_x / (R_earth * cos(return_lat))
	return_val = [return_lon, return_lat]
	return, return_val
end

function sin_to_ddlonlat, in_x, in_y
	;MODIS definitions
	R_earth = 6371007.181   ;MODIS sinusoidal sphere radius in m
	PI = 3.141592653589793238d0
	HALF_PI = (PI * 0.5)
	return_lat = in_y / R_earth
	return_lon = in_x / (R_earth * cos(return_lat))
	return_val = [return_lon, return_lat]/PI*180.0d0
	return, return_val
end

function lonlat_to_sin, in_lon, in_lat  ;lon lat must be in radians
	;MODIS definitions
	R_earth = 6371007.181   ;MODIS sinusoidal sphere radius in m
	PI = 3.141592653589793238d0
	HALF_PI = (PI * 0.5)
	return_x = R_earth * in_lon * cos(in_lat)
	return_y = R_earth * in_lat
	return_val = [return_x, return_y]
	return, return_val
end

;this function maps a lon lat in degrees to a pixel on the MODIS sinusoidal 1km 
;global grid   . returned x,y index are 0 based indices
function ddlonlat_to_modimage_xy, ddlon, ddlat
	;43200 x 21600
	xdim = 43200L
	ydim = 21600L
	pix_size = 926.625433d0   ;modis 1km pixel size in m
	PI = 3.141592653589793238d0

	;convert from degrees to radians
	rad_lon = ddlon / 180.0d0 * PI
	rad_lat = ddlat / 180.0d0 * PI
	;print, rad_lon, rad_lat
	
	;first check if we have negative or positive longitude
	;western half
	;if (ddlon le 0.) then begin
	;	sin_xy = lonlat_to_sin(rad_lon, rad_lat)
	;	print, sin_xy
	;	delta_x = -sin_xy[0]
	;	ret_x = xdim/2 - long(delta_x / pix_size)
	;endif else begin
	;;eastern half
	;	sin_xy = lonlat_to_sin(rad_lon, rad_lat)
	;	ret_x = xdim/2 + long(sin_xy[0] / pix_size)
	;endelse

	sin_xy = lonlat_to_sin(rad_lon, rad_lat)
	ret_x = long(xdim/2 + (sin_xy[0] / pix_size))
	ret_y = long(ydim/2 - (sin_xy[1] / pix_size))

	ret_val = [ret_x, ret_y]
	return, ret_val
end

;return value of x y in coordinates in MODIS sinusoidal 1km global grid given
;pixel location
function sinpix_to_sinxy, pix_x, pix_y
	xdim = 43200L
	ydim = 21600L
	pix_size = 926.625433d0 ; modis 1km pixel size in m

	ul_x = - (xdim/2)*pix_size
	ul_y = (ydim/2) * pix_size

	ret_x = ul_x + pix_x * pix_size
	ret_y = ul_y - pix_y * pix_size	

	ret_val = [ret_x, ret_y]
	return, ret_val
end
