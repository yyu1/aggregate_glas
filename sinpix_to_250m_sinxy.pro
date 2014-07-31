;return value of x y in coordinates in MODIS sinusoidal 250m global grid given
;pixel location
function sinpix_to_250m_sinxy, pix_x, pix_y
  xdim = 172800ULL
  ydim = 86400ULL
  pix_size = 231.6563583333d0 ; modis 250m pixel size in m

  ul_x = - (xdim/2)*pix_size
  ul_y = (ydim/2) * pix_size

  ret_x = ul_x + pix_x * pix_size
  ret_y = ul_y - pix_y * pix_size

  ret_val = [ret_x, ret_y]
  return, ret_val
end
