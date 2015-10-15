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

