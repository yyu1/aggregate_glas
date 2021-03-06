pro aggregate_glas_sam_agb
;aggregates GLAS values globally for 250m MODIS projection

;250m global MODIS projection :  172800 x 86400

;Use hash table to store GLAS shots.  x, y
;use 1 ULONG64 data type as key to store x,y coordinate as:  x*10E7 + y
;value of hash is list object

;use agb values from 4.2.5

glas_hash_table = hash()

shots_histo = ulon64arr(5)

max_pctslope = 30

out_file = '~/glas/glas_agb_4.2.5_30pctslp_2shotmin_aggregate.csv'

;read in single GLAS shots from Lefsky's data.
restore, '~/glas/glas_shots_w_agb_4.2.5.sav'

;filter for South America
xmin = -11119505.1960D
ymax = 3335851.5590D
xmax = xmin + 231.65635825*38400
ymin = ymax - 231.65635825*43200

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

index = where((lats ge minlat) and (lats le maxlat) and (lons ge minlon) and (lons le maxlon),count)


for i=0ULL, count-1 do begin
	if (i mod 10000 eq 0) then print, i
	loc_ind = index[i]
	if (data.(5)[loc_ind] le max_pctslope) then begin
		cur_lat = data.(1)[loc_ind]
		cur_lon = data.(0)[loc_ind]

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
			cur_list.add, data.(11)[loc_ind]  ;11 : agb
		endif else begin
			;nothing exist here, add a new list and add the shot
			newList = list()
			newList.add, data.(11)[loc_ind]  ;11 : agb
			glas_hash_table[cur_hash_key] = newList
		end
	endif
endfor


openw, 1, out_file
printf, 1, 'modx,mody,n_shots,hlorey_avg'
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
		agb_format = '(f7.2)'

		agb_total = 0.	
		for ii=0, n_shots-1 do begin
			cur_location = glas_hash_table[hash_keys[i]]
			agb_total += cur_location[ii]
		endfor
		agb_avg = agb_total / n_shots
	
		outline = strtrim(string(cur_modcoord[0],format=coord_format),2) + ','
		outline += strtrim(string(cur_modcoord[1],format=coord_format),2) + ','
		outline += strtrim(string(n_shots),2) + ','
		outline += strtrim(string(agb_avg,format=agb_format),2)

		printf, 1, outline
	endif
endfor


close, 1

end


