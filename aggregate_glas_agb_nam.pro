;aggregates GLAS values globally for 250m MODIS projection

;250m global MODIS projection :  172800 x 86400

;Use hash table to store GLAS shots.  x, y
;use 1 ULONG64 data type as key to store x,y coordinate as:  x*10E7 + y
;value of hash is list object

glas_hash_table = hash()

shots_histo = ulon64arr(5)

;max_pctslope = 30   //already filtered for 20% slope

out_file = '/Volumes/wd_3t/maxent/v5/samples/maxent_agb_v5_nam_20pctslope_2shotmin_250modgrid.csv'

;read in single GLAS shots from Lefsky's data.
;restore, '/Volumes/YifanLaCie1T/global/glas/lefsky/12_10_2012/global_comb_121012.idl'
data = read_csv('/Volumes/YifanLaCie1T/global/glas/lefsky/12_10_2012/global_agb_121012_20pctslp.csv')

;filter for North America
xmin = -13343406.2352
ymax = 8895604.1568
xmax = xmin + 231.65635825*48000
ymin = ymax - 231.65635825*33600


lonlat1 = sin_to_ddlonlat(xmin, ymax)
lonlat2 = sin_to_ddlonlat(xmin, ymin)
minlon = lonlat1[0] < lonlat2[0]
minlat = lonlat2[1]
maxlat = lonlat1[1]

lonlat1 = sin_to_ddlonlat(xmax, ymax)
lonlat2 = sin_to_ddlonlat(xmax, ymin)
maxlon = lonlat1[0] > lonlat2[0]

lats = data.(1)
lons = data.(0)
agbs = data.(2)

index = where((lats ge minlat) and (lats le maxlat) and (lons ge minlon) and (lons le maxlon),count)


for i=0ULL, count-1 do begin
	if (i mod 10000 eq 0) then print, i
	loc_ind = index[i]
	cur_lat = lats[loc_ind]
	cur_lon = lons[loc_ind]

	cur_pix = ddlonlat_to_mod250m_xy(cur_lon,cur_lat)

	if(cur_pix[0] lt 0 or cur_pix[0] ge 172800ULL) then begin
		print, 'GLAS Shot out of bounds. shot #', i
		break
	endif
	if(cur_pix[1] lt 0 or cur_pix[1] ge 86400ULL) then begin
		print, 'GLAS Shot out of bounds. shot #', i
		break
	endif


	cur_hash_key = ulong64(cur_pix[0]) * 10000000ULL + cur_pix[1]

	;see if a shot already exist at this pixel
	if glas_hash_table.HasKey(cur_hash_key) then begin
		;list already exist, add shot to list
		cur_list = glas_hash_table[cur_hash_key]
		cur_list.add, agbs[loc_ind]
	endif else begin
		;nothing exist here, add a new list and add the shot
		newList = list()
		newList.add, agbs[loc_ind]
		glas_hash_table[cur_hash_key] = newList
	end
endfor


openw, 1, out_file
printf, 1, 'modx,mody,n_shots,agb_v5'
hash_keys = glas_hash_table.Keys()

nhash = n_elements(hash_keys)
for i=0ULL, nhash-1 do begin
	n_shots = n_elements(glas_hash_table[hash_keys[i]])
	if (n_shots gt 1) then begin
		outline = ''
		cur_xpix = ulong64(hash_keys[i]/10000000ULL)
		cur_ypix = hash_keys[i] - cur_xpix*10000000ULL
		cur_modcoord = sinpix_to_250m_sinxy(cur_xpix, cur_ypix)
		coord_format = '(f12.2)'
		hlorey_format = '(f6.2)'

		hlorey_total = 0D	
		for ii=0, n_shots-1 do begin
			cur_location = glas_hash_table[hash_keys[i]]
			hlorey_total += cur_location[ii]
		endfor
		hlorey_avg = hlorey_total / n_shots
	
		outline = strtrim(string(cur_modcoord[0],format=coord_format),2) + ','
		outline += strtrim(string(cur_modcoord[1],format=coord_format),2) + ','
		outline += strtrim(string(n_shots),2) + ','
		outline += strtrim(string(hlorey_avg,format=hlorey_format),2)

		printf, 1, outline
	endif
endfor


close, 1

end


