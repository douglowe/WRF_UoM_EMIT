;
;  This contains routines for using shapefile data for 
;  mapping shapefile locations on the domain.
;
;  The code below is an adaptation of this script: 
;  https://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl
;  For more information on these routines see:
;  https://www.ncl.ucar.edu/Applications/shapefiles.shtml
;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"     ; include standard resources
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"




;======================================================================
; shapefile_label_locations
;
; This function labels the locations in a rectilinear, curvilinear, 
; or unstructured data array based on all the outlines in a shapefile, or 
; based on a string variable name in a shapefile and a list of strings
; to check for, like "Water body" or (/"Ohio","Michigan"/). 
;
; Input paramaters
;  data         : numeric - 1D or 2D data to mask or base mask array on
;  shp_file_name[1] : string  - Name of shapefile
;  shape_var[1] : string - Name of variable on shapefile that contains the
;                          string names of areas to be used as labels.
;  opt[1]       : logical - Use to set options for this function. If
;                           set to False, then all options will be ignored.
;
;  "opt" can have the following attributes:
;
;   "minlat", "maxlat", "minlon", "maxlon" - You can tell the masking 
;                   routine what rough lat/lon box you are interested 
;                   in, so that it doesn't check every lat/lon segment
;                   in the shapefile.
;                   [default is the min/max of the lat/lon on shapefile]
;
;   "debug"       - Whether to print debug information.
;                   [default False]
;
;  - If a rectilinear grid, then "data" must have coordinate arrays
;    attached. 
;  - If a curvilinear grid, then "data" must have the special lat2d 
;    and lon2d attributes attached.
;  - If a unstructured grid, then "data"must have the special lat1d 
;    and lon1d attributes attached.
;======================================================================
undef("shapefile_label_locations")
function shapefile_label_locations(data:numeric,shapefile_name[1]:string,\
											 shape_var[1]:string,opt[1]:logical)
local mask_start_time, mask_end_time,keep_true_value, keep_false_value, \
		dims, rank, grid_type, lat1d, lon1d, nlatlon1d, f, segments, geometry, \
		segsDims, geomDims, geom_segIndex, geom_numSegs, segs_xyzIndex, 
		segs_numPnts,numFeatures, lat, lon, shp_mask_names, found, nf, numFeatures, \
		startSegment, numSegments, seg, startPT, endPT, lon_sub, lat_sub, \
		min_lat_shp, max_lat_shp, min_lon_shp, max_lon_shp
begin

	mask_start_time = get_cpu_time()

	;---Make sure we can open shapefile
	if(.not.isfilepresent(shapefile_name)) then
		print("shapefile_mask_data : Error: " + shapefile_name + \
				" either doesn't exist or is not a valid shapefile.")
		exit
	end if
	f = addfile(shapefile_name,"r")

	;---Parse options and check for errors
	DEBUG       = get_res_value_keep(opt,"debug",False)
	KEEP        = get_res_value_keep(opt,"keep",True)
	RETURN_MASK = get_res_value_keep(opt,"return_mask",False)
	LOOP_CHECK  = get_res_value_keep(opt,"loop_check",True)
	SHP_VAR     = opt.and.isatt(opt,"shape_var")


	;---Make sure shp_var_name is on shapefile.
	if(isfilevar(f,shape_var)) then
		shp_mask_names = f->$shape_var$
	else
		print("shapefile_mask_data : Error: The given variable name to use does not exist on the given shapefile.")
		exit
	end if



	;---Determine the grid type
	dims = dimsizes(data)
	rank = dimsizes(dims)

	grid_type = ""
	if(rank.eq.2.and. isdimnamed(data,0).and.iscoord(data,data!0).and.\
							isdimnamed(data,1).and.iscoord(data,data!1)) then
		;---Rectilinear
		lat1d = ndtooned(conform_dims(dims,data&$data!0$,0))
		lon1d = ndtooned(conform_dims(dims,data&$data!1$,1))
		grid_type = "rectilinear"
	else if(rank.eq.2.and.all(isatt(data,(/"lat2d","lon2d"/)))) then
		;---Curvilinear
		lat1d = ndtooned(data@lat2d)
		lon1d = ndtooned(data@lon2d)
		if(product(dims).eq.dimsizes(lat1d).and.\
				product(dims).eq.dimsizes(lon1d)) then
			grid_type = "curvilinear"
		end if
	else if(rank.eq.1.and.all(isatt(data,(/"lat1d","lon1d"/)))) then
		;---Unstructured
		lat1d = data@lat1d
		lon1d = data@lon1d
		if(dims.eq.dimsizes(lat1d).and.\
				product(dims).eq.dimsizes(lon1d)) then
			grid_type = "unstructured"
		end if
	end if
	end if
	end if

	if(grid_type.eq."") then
		print("shapefile_mask_data: Error: not a valid rectilinear, curvilinear, or unstructured grid")
		exit
	end if

	nlatlon1d = dimsizes(lat1d)
  


	;---Read data off the shapefile
	segments = f->segments
	geometry = f->geometry
	segsDims = dimsizes(segments)
	geomDims = dimsizes(geometry)

	;---Read global attributes  
	geom_segIndex = f@geom_segIndex
	geom_numSegs  = f@geom_numSegs
	segs_xyzIndex = f@segs_xyzIndex
	segs_numPnts  = f@segs_numPnts
	numFeatures   = geomDims(0)

	;---Read shapefile lat/lon
	lon = f->x
	lat = f->y
	;
	; If shp_var_name is specified, then get the approximate lat/lon box that 
	; encloses the shapefile areas of interest. This can make the 
	; gc_inout checking go faster later. If the user has input
	; all four "usr_min/max_lat/lon" attributes, then don't do the check.
	;
	if(SHP_VAR.and..not.(opt.and.isatt(opt,"minlat").and.isatt(opt,"maxlat").and.\
					   isatt(opt,"minlon").and.isatt(opt,"maxlon"))) then
		found = False
		do nf=0,numFeatures-1
			;      if(any(shp_mask_names(nf).eq.usr_mask_names)) then
			startSegment = geometry(nf, geom_segIndex)
			numSegments  = geometry(nf, geom_numSegs)
			do seg=startSegment, startSegment+numSegments-1
				startPT = segments(seg, segs_xyzIndex)
				endPT   = startPT + segments(seg, segs_numPnts) - 1
				lat_sub := lat(startPT:endPT)
				lon_sub := lon(startPT:endPT) 
				if(found) then
					min_lat_shp = min((/min_lat_shp,min(lat_sub)/))
					max_lat_shp = max((/max_lat_shp,max(lat_sub)/))
					min_lon_shp = min((/min_lon_shp,min(lon_sub)/))
					max_lon_shp = max((/max_lon_shp,max(lon_sub)/))
				else
					min_lat_shp = min(lat_sub)
					max_lat_shp = max(lat_sub)
					min_lon_shp = min(lon_sub)
					max_lon_shp = max(lon_sub)
					found       = True
				end if
			end do
			;      end if
		end do
	else
		;---Use the whole shapefile
		min_lat_shp = min(lat)
		max_lat_shp = max(lat)
		min_lon_shp = min(lon)
		max_lon_shp = max(lon)
	end if
  
	;--lat/lon coordinates of data array
	min_lat_data = min(lat1d)
	max_lat_data = max(lat1d)
	min_lon_data = min(lon1d)
	max_lon_data = max(lon1d)

	;---min/max lat/lon to use for checking the data lat/lon
	min_lat_chk = get_res_value(opt,"minlat",min_lat_shp)
	max_lat_chk = get_res_value(opt,"maxlat",max_lat_shp)
	min_lon_chk = get_res_value(opt,"minlon",min_lon_shp)
	max_lon_chk = get_res_value(opt,"maxlon",max_lon_shp)

	if(DEBUG) then
		print("==================================================")
		print("Shapefile:         " + shapefile_name)
		if(SHP_VAR) then
			print("Areas of interest: " + str_join(usr_mask_names,","))
		else
			print("Areas of interest: the whole shapefile")
		end if
		print("min_lat_chk:       " + min_lat_chk)
		print("max_lat_chk:       " + max_lat_chk)
		print("min_lon_chk:       " + min_lon_chk)
		print("max_lon_chk:       " + max_lon_chk)
		print("min_lat_data:      " + min_lat_data)
		print("max_lat_data:      " + max_lat_data)
		print("min_lon_data:      " + min_lon_data)
		print("max_lon_data:      " + max_lon_data)
		print(dimsizes(lat1d) + " data values originally")
	end if

	;---Create array to hold new data label
	data_label_1d = new(nlatlon1d,string)
	data_label_1d = "" ; default label  

	; loop through the features, identifying where they overlap our domain
	do nf=0,numFeatures-1
		; get start segment for shape, and number of segments
		startSegment = geometry(nf, geom_segIndex)
		numSegments  = geometry(nf, geom_numSegs)

		; loop through segments in the shape
		do seg=startSegment, startSegment+numSegments-1

			; get start and end points for segment
			startPT = segments(seg, segs_xyzIndex)
			endPT   = startPT + segments(seg, segs_numPnts) - 1
			; create temp arrays with lat/lon data for segment
			lat_sub := lat(startPT:endPT)
			lon_sub := lon(startPT:endPT) 

			; check to make sure that a square lat/lon box containing this shape
			; does overlap at least some locations within the domain of interest, and
			; note the indexes of these positions within the 1D array containing
			; the domain of interest.
			ii_latlon := ind(min(lat_sub).le.lat1d.and.lat1d.le.max(lat_sub).and.\
						   min(lon_sub).le.lon1d.and.lon1d.le.max(lon_sub))
			; if there is no overlap then jump to the next segment
			if(any(ismissing(ii_latlon))) then
				continue
			end if

			; loop through the list of indexes of points within the 1D array
			; of the domain which coincide with this box, and see which actually
			; within this segment of the shape
			nii = dimsizes(ii_latlon)
			do n=0,nii-1
				iltln = ii_latlon(n)
				if(gc_inout(lat1d(iltln),lon1d(iltln),lat_sub,lon_sub)) then
					; add the shape label to this location label
					data_label_1d(iltln) = data_label_1d(iltln) + " " + shp_mask_names(nf)
				end if
			end do

		end do
	end do


	if(DEBUG) then
		print("==================================================")
		print(num(data_label_1d.ne."") + " data values kept")
	end if

	;
	; Create a 2D data array of same size as original data,
	; but with the new strings.
	;
	data_label = onedtond(data_label_1d,dims)

	if(DEBUG) then
		;---Print timings
		mask_end_time = get_cpu_time()
		print("shapefile_mask_data: elapsed time: " + \
			  (mask_end_time-mask_start_time) + " CPU seconds.")
		print("==================================================")
	end if
	return(data_label)

end
