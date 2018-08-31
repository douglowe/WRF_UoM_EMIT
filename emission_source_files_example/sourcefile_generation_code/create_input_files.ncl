;
; library of functions for creating example input files for WRF_UoM_EMIT.
;
;
;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; generic variable information for the new output files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Var_Dims  = (/"Time", "emissions_zdim_stag", "south_north", "west_east"/)

GAS_NMVOC_Att = 0.0			; NOTE: this must be a float variable in order for the fill value to work 
GAS_NMVOC_Att@_FillValue  = 9.96921e36
GAS_NMVOC_Att@FieldType   = 104
GAS_NMVOC_Att@stagger     = "Z"
GAS_NMVOC_Att@units       = "mol km^-2 hr^-1"
GAS_NMVOC_Att@description = "EMISSIONS"
GAS_NMVOC_Att@MemoryOrder = "XYZ"

AERO_Att = 0.0 
AERO_Att@_FillValue  = 9.96921e36
AERO_Att@FieldType   = 104
AERO_Att@stagger     = "Z"
AERO_Att@units 	     = "ug m^-2 s^-1" 
AERO_Att@description = "EMISSIONS"
AERO_Att@MemoryOrder = "XYZ"



time_string_am = (/"2000-01-01_00:00:00","2000-01-01_01:00:00",\
					"2000-01-01_02:00:00","2000-01-01_03:00:00",\
					"2000-01-01_04:00:00","2000-01-01_05:00:00",\
					"2000-01-01_06:00:00","2000-01-01_07:00:00",\
					"2000-01-01_08:00:00","2000-01-01_09:00:00",\
					"2000-01-01_10:00:00","2000-01-01_11:00:00"/)

time_string_pm = (/"2000-01-01_12:00:00","2000-01-01_13:00:00",\
					"2000-01-01_14:00:00","2000-01-01_15:00:00",\
					"2000-01-01_16:00:00","2000-01-01_17:00:00",\
					"2000-01-01_18:00:00","2000-01-01_19:00:00",\
					"2000-01-01_20:00:00","2000-01-01_21:00:00",\
					"2000-01-01_22:00:00","2000-01-01_23:00:00"/)



undef("create_lat_lon_array")
function create_lat_lon_array(xlimits:float,lat_size:integer,lon_size:integer,latlon_flag:string)
local array
begin

	;; create array template, and add dimension labels
	array = new((/lat_size,lon_size/),typeof(xlimits))
	array!0 = "south_north"
	array!1 = "west_east"

	;; populate with lat or lon data
	if(latlon_flag.eq."latitudes")
		array1d = fspan(xlimits(0),xlimits(1),lat_size)
		array1d := reshape(array1d,(/1,lat_size/))
		do ii = 0,lon_size-1
			array(:,ii) = (/array1d/)
		end do
	else if(latlon_flag.eq."longitudes")
		array1d = fspan(xlimits(0),xlimits(1),lon_size)
		do ii = 0,lat_size-1
			array(ii,:) = (/array1d/)
		end do	
	else
		print("don't recognise latlon_flag string: "+latlon_flag)
		;stop()
	end if
	end if

	return(array)

end





undef("create_emission_source_file")
procedure create_emission_source_file(fname:string,xlat_limits:float,xlon_limits:float,\
										lat_size:integer,lon_size:integer)
local OUTFILE, global_attnames, ig, dim_sizes, dim_names, dim_Unlim, \
		xlat, xlon, times, var_names, var_types, tz_off
begin


	;;; check that OUTDIR exists - if not then create it
	system("if ! test -d  "+OUTDIR+" ; then mkdir "+OUTDIR+"; fi")

	;;; ensure that we don't accidentally overwrite preexisting files
	if(isfilepresent(OUTDIR+wrfchem_scheme@$fname$))
		system("mv "+OUTDIR+wrfchem_scheme@$fname$+" "+OUTDIR+wrfchem_scheme@$fname$+".backup")
	end if
	;;; delete any broken files from previous attempts
	if(isfilepresent(OUTDIR+wrfchem_scheme@$fname$+".nc"))
		system("rm "+OUTDIR+wrfchem_scheme@$fname$+".nc")
	end if

	;;; open the new files that we wish to create
	;;;   NOTE - NCL determines the format of the file by the file extension.
	;;;          We can't create a file without a file extension - so instead
	;;;          we will rename these files later (to make WRF-Chem happy).
	OUTFILE = addfile(OUTDIR+wrfchem_scheme@$fname$+".nc","c")



	;;; set global attributes
	OUTFILE@information = "Example input file for WRF_UoM_EMIT. Output not intended for use with WRF-Chem."
	OUTFILE@input_scheme = input_scheme


	;;; get the dimension names and sizes from the input file
	dim_sizes = (/lon_size,lat_size,1,19,12/)
	dim_names = (/"west_east","south_north","emissions_zdim_stag","DateStrLen","Time"/)

	;;; set all dimensions as Limited
	dim_Unlim = new(dimsizes(dim_sizes),logical)
	dim_Unlim(:) = False
	;;; now find the Time dimension, and set that to Unlimited
	dim_Unlim(ind(dim_names.eq."Time"))   = True


	;;; apply these dimensions to the output files
	filedimdef( OUTFILE, dim_names, dim_sizes, dim_Unlim )
	

	
	;;; create the variables that we're going to add to output file
	
	;;; time array
	times = tochar(time_string_am)
	times!0 = "Time"
	times!1 = "DateStrLen"
	
	;;; latitude and longitude arrays
	xlat = create_lat_lon_array(xlat_limits,lat_size,lon_size,"latitudes")
	xlon = create_lat_lon_array(xlat_limits,lat_size,lon_size,"longitudes")
	


	;;; copy common variables
	xlon   = INFILE->XLONG
	xlat   = INFILE->XLAT
	
    filevardef(OUTFILE, "XLAT" ,typeof(xlat) ,getvardims(xlat))                     
    filevardef(OUTFILE, "XLONG",typeof(xlon) ,getvardims(xlon))                          
    filevardef(OUTFILE, "Times",typeof(times) ,getvardims(times))                          
	
    filevarattdef(OUTFILE,"XLAT"  ,xlat)
    filevarattdef(OUTFILE,"XLONG" ,xlon)
    filevarattdef(OUTFILE,"Times" ,times)

	OUTFILE->XLAT  = (/xlat/)
	OUTFILE->XLONG = (/xlon/)
	OUTFILE->Times = (/times/)
	
	;;; create a variable for carrying timezone offset information
    filevardef(OUTFILE, "TZ_Offset", "float", Var_Dims(2:3))                     
    filevarattdef(OUTFILE, "TZ_Offset", TZ_Att)
    OUTFILE->TZ_Offset = (/tz_off/)
	
	
	;;; create the scheme-specific emission variables that we will use later
	
	
	
	;;; gases first
	var_names = variable_lists@$(/"GAS_"+wrfchem_scheme/)$
	var_types = new(dimsizes(var_names),string)
	var_types = "float"
	filevardef(OUTFILE, var_names, var_types, Var_Dims )
	filevarattdef(OUTFILE, var_names, GAS_NMVOC_Att)
	delete([/var_names,var_types/])

	;;; nmvoc's
	var_names = variable_lists@$(/"NMVOC_"+wrfchem_scheme/)$
	var_types = new(dimsizes(var_names),string)
	var_types = "float"
	filevardef(OUTFILE, var_names, var_types, Var_Dims )
	filevarattdef(OUTFILE, var_names, GAS_NMVOC_Att)
	delete([/var_names,var_types/])
	
	;;; aerosol's
	var_names = variable_lists@$(/"AERO_"+wrfchem_scheme/)$
	var_types = new(dimsizes(var_names),string)
	var_types = "float"
	filevardef(OUTFILE, var_names, var_types, Var_Dims )
	filevarattdef(OUTFILE, var_names, AERO_Att)
	delete([/var_names,var_types/])
	


	;;; tidy up after ourselves
	delete([/INFILE,OUTFILE/])

	;;; rename the created files in order to match WRF-Chem convention
	system("mv "+OUTDIR+wrfchem_scheme@$fname$+".nc "+OUTDIR+wrfchem_scheme@$fname$)
	

end ;;;;; create_emission_files
