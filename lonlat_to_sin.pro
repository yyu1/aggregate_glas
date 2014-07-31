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
