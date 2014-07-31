;this function maps a lon lat in degrees to a pixel on the MODIS sinusoidal 1km 
;global grid   . returned x,y index are 0 based indices
function ddlonlat_to_mod250m_xy, ddlon, ddlat
  ;43200 x 21600
  xdim = 172800ULL
  ydim = 86400ULL
  pix_size = 231.6563583333d0   ;modis 250m pixel size in m
  PI = 3.141592653589793238d0

  ;convert from degrees to radians
  rad_lon = ddlon / 180.0d0 * PI
  rad_lat = ddlat / 180.0d0 * PI
  ;print, rad_lon, rad_lat
 
  ;first check if we have negative or positive longitude
  ;western half
  ;if (ddlon le 0.) then begin
  ; sin_xy = lonlat_to_sin(rad_lon, rad_lat)
  ; print, sin_xy
  ; delta_x = -sin_xy[0]
  ; ret_x = xdim/2 - long(delta_x / pix_size)
  ;endif else begin
  ;;eastern half
  ; sin_xy = lonlat_to_sin(rad_lon, rad_lat)
  ; ret_x = xdim/2 + long(sin_xy[0] / pix_size)
  ;endelse

  sin_xy = lonlat_to_sin(rad_lon, rad_lat)
  ret_x = long(xdim/2 + (sin_xy[0] / pix_size))
  ret_y = long(ydim/2 - (sin_xy[1] / pix_size))

  ret_val = [ret_x, ret_y]
  return, ret_val
end

