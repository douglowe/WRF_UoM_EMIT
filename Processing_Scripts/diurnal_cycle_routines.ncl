;
;  General routines needed for applying the diurnal cycle to 
;  our emissions data.
;  
;   Contents:
;        utc_offset_calculation
;            This routine calculates the offset from
;            UTC to apply to the diurnal cycle. Currently
;            this applies a single value (so, is only suitable
;            for work over unified timezones, such as China).
;            In future we will use shapefiles to make this a 
;            more nuanced routine.
;
;            We use timezone shapefiles downloaded from this source:
;            http://efele.net/maps/tz/world/
;
;
;
;        create_timezone_scaling_arrays
;            This routine takes the UTC offsets calculated for
;            each grid point, and combines these with the 
;            diurnal cycles for each sector to create maps of
;            scaling factors (for each hour of the day) 
;            to be applied to our emissions.
;
;        modify_emissions
;            This takes the maps of scaling factors for each
;            emission sector, and applies them to the emissions
;            data to create our diurnally cycling emissions data.
;
;        modify_nmvoc_emissions
;            This applies the maps of scaling factors for each 
;            emission sector to the NMVOC emissions.
;
;        impose_diurnal_cycle
;            This is the main function - which loads 
;            the files to be modified, and calls the 
;            other routines above. It also saves the
;            UTC offset information to the intermediate
;            emission files.
;
;        impose_nmvoc_diurnal_cycle
;            This replicates the main function, but
;            for processing NMVOC emissions. It uses
;            the UTC offset information saved in the
;            intermediate emission files (rather than
;            recalculating this again), so must be run
;            after the main function.
;
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"     ; include standard resources
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


load "./emission_script_data.ncl"
load "./timezone_data.ncl"
load "./shapefiles_manipulate.ncl"

;;; define where our shapefile information is stored
;sname = "~/Dropbox/Work/Code_Development/Shape_Files/world/tz_world_mp.shp"
sname = "./shape_files/tz_world_mp.shp"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; diurnal cycle routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

undef("utc_offset_calculation")
function utc_offset_calculation(lat_data:float,lon_data:float,UTC_offset:logical)
local mask_array, shape_opt, timezone_labels, template_array, timezone_list, data_position
begin

	;;; create mask array
	mask_array = new(dimsizes(lat_data),float)
	copy_VarMeta(lat_data,mask_array)
	
	;;; check how to calculate the UTC offset
	if (UTC_offset .and. isatt(UTC_offset,"method"))

		;;; fixed value for whole domain
		if (UTC_offset@method .eq. "fixed")
	
			if (isatt(UTC_offset,"fixed_offset"))
				mask_array = UTC_offset@fixed_offset
			else
				print("Fixed UTC offset selected, but no 'fixed_offset' value given - we will assume a value of 0")
				mask_array = 0.0
			end if

		;;; use timezone maps to determine the offsets
		else if (UTC_offset@method .eq. "timezones")

			;;; set up control information for domain
			shape_opt = True
			shape_opt@debug = False

			;;; add the lat and lon data as attributes to
			;;; the template array - this will enable us to 
			;;; pass them to the shapefile processing routine
			template_array = lat_data
			template_array@lat2d = (/lat_data/)
			template_array@lon2d = (/lon_data/)
	
			print("= Getting Timezone Labels (this will take a while...) =")
			;;; determine the timezone label information
			timezone_labels = shapefile_label_locations(template_array,sname,"TZID",shape_opt)
			
			;;; strip off leading / trailing spaces
			timezone_labels = str_squeeze(timezone_labels)
			
			print("= Listing Timezones in Grid =")
			;;; get a 1D list of the timezones
			timezone_list = get_unique_values(timezone_labels)
			

			;;; determine if we're using daylight saving time or not
			if(isatt(UTC_offset,"daylightsaving"))
				if(UTC_offset@daylightsaving .eq. True)
					data_position = 1
				else
					data_position = 0
				end if
			else
				data_position = 0
			end if
						
			;;; initialise the mask_array with zeros
			mask_array = 0.0
			
			
			print("= Determining UTC offsets for grid =")
			;;; loop through list of timezones, recording the offset (in seconds) where needed
			do ii = 0,dimsizes(timezone_list)-1
			
				if(isatt(TimeZone,timezone_list(ii)))
					mask_array = where(timezone_labels.eq.timezone_list(ii),\
										TimeZone@$timezone_list(ii)$(data_position), mask_array)
				else
					; if this is not an empty entry then print a warning
					if(timezone_list(ii).ne."")
						print("Time Zone location '"+timezone_list(ii)+"' is not recognised")
					end if
				end if
			
			end do
						
			;;; convert the offset from seconds to hours
			mask_array = mask_array / 3600.0
						
			
		;;; unrecognised option
		else 
			print("UTC offset option '"+UTC_offset@method+"' is not recognised - we will assume a value of 0 instead")
			mask_array = 0.0
		end if
		end if



	else ; if we've no UTC_offset then set the mask to zero
	
		mask_array = 0

	end if

	print("= UTC offsets determined =")

	return(mask_array)

end ;;;;; utc_offset_calculation




undef("create_timezone_scaling_arrays")
function create_timezone_scaling_arrays(utc_offset_map:float,lat_data:float)
local ii, kk, ll, grid_dim, time_dim, emis_dim, scaling_arrays, unique_offsets, \
		offset, hour_frac, dc_ind, offset_down, offset_up, dc_ind_up
begin

	;;;; get the dimensions of the model grid
	grid_dim = dimsizes(lat_data)
	;;;; get the dimensions of the diurnal cycle
	time_dim = dimsizes(diurnal_cycles@$diurnal_cycles(0)$)
	;;;; get the number of diurnal cycle sectors
	emis_dim = dimsizes(diurnal_cycles)

	;;;; create the data arrays, one for each emission sector
	scaling_arrays = new((/emis_dim,time_dim,grid_dim(0),grid_dim(1)/),float)

	
	print("= Creating scaling arrays from UTC offsets =")
	
	;;; find the unique offset values in the model domain
	unique_offsets = get_unique_values(utc_offset_map)


	;;; loop through the unique offset values
	do ii=0,dimsizes(unique_offsets)-1
		;;;; obtain our UTC offset for this grid point 
		offset = unique_offsets(ii)
		
		;;; get the fraction of the hour remaining (if zero, then we are on the hour)
		hour_frac = mod(offset,1.0)

		
		if(hour_frac.eq.0.0) ; technique for whole hour offsets

			;;;; loop through our diurnal timesteps
			do kk=0,time_dim(0)-1

				;;;; determine the diurnal cycle index for this timestep
				dc_ind = kk + floattoint(offset)
				if(dc_ind .lt. 0)
					dc_ind = 24 + dc_ind
				else if(dc_ind .ge. 24)
					dc_ind = dc_ind - 24
				end if
				end if

				;;;; loop through the emission sectors, and add the scaling factor
				do ll=0,emis_dim-1
					scaling_arrays(ll,kk,:,:) = where(utc_offset_map.eq.offset,\
													diurnal_cycles@$diurnal_cycles(ll)$(dc_ind),\
													scaling_arrays(ll,kk,:,:))	
				end do ; ll = emis_dim
		
			end do ; kk = time_dim

		else ; technique for part-hour offsets (need to interpolate data)

			;;; round down the offset
			offset_down = floor(offset)
			;;; get the offset for the next hour
			offset_up = offset + 1

			;;;; loop through our diurnal timesteps
			do kk=0,time_dim(0)-1

				;;;; determine the diurnal cycle index for this timestep
				dc_ind = kk + floattoint(offset_down)
				if(dc_ind .lt. 0)
					dc_ind = 24 + dc_ind
				else if(dc_ind .ge. 24)
					dc_ind = dc_ind - 24
				end if
				end if

				;;;; determine the diurnal cycle index for the following hour for this timestep
				dc_ind_up = kk + floattoint(offset_up)
				if(dc_ind_up .lt. 0)
					dc_ind_up = 24 + dc_ind_up
				else if(dc_ind_up .ge. 24)
					dc_ind_up = dc_ind_up - 24
				end if
				end if

				;;;; loop through the emission sectors, and add the scaling factor
				do ll=0,emis_dim-1
					scaling_arrays(ll,kk,:,:) = where(utc_offset_map.eq.offset,\
													diurnal_cycles@$diurnal_cycles(ll)$(dc_ind)*hour_frac \
														+ diurnal_cycles@$diurnal_cycles(ll)$(dc_ind_up)*(1.0-hour_frac),\
													scaling_arrays(ll,kk,:,:))	
				end do ; ll = emis_dim
		
			end do ; kk = time_dim
		

		
		end if


	end do
	

	return(scaling_arrays)

end ;;;;; creat_timezone_scaling_arrays




undef("modify_emissions_diurnal_cycle")
procedure modify_emissions_diurnal_cycle(FILE:file,scaling_arrays:float,start_index:integer,emission_sectors:string,id_string:string)
local var_list, var_num, evar, var_name, sect_name, esec, sect_ind, itime, data_array, emiss_name, \
		missing_variables
begin

	;;; pull out a list of the variables in the emission file
	var_list = getfilevarnames(FILE)
	var_num = dimsizes(var_list)
	
	;;; initalise string to record emission variables that we aren't processing
	missing_variables = ""
	
	;;;;; apply the scaling arrays to the emission data
	
	
	;; loop through all variables
	do evar=0,var_num-1
	
		;; get variable name
		var_name = var_list(evar)
	
		;; check that this is an emission variable
		if(isStrSubset(var_name,id_string))
	
			;; obtain the emission sector info
			sect_name = "None"
			do esec = 0,dimsizes(emission_sectors)-1
				;; checking for the NMVOC group
				if(isStrSubset(var_name,emission_sectors(esec)))
					;; pulling out the matching standard emission sector name
					sect_name = emission_sectors@$emission_sectors(esec)$
					break
				end if
			end do

			;; make sure we have emission sector info
			if(sect_name .ne. "None")
				
				;; obtain the emission index
				sect_ind = emiss_sector_index@$sect_name$

				;; pull the data from the input file
				data_array = FILE->$var_name$

				;; loop through the time slices in the file (assumed there's 12!)
				do itime = 0,11
			
					;; apply our scaling factor
					;;    NOTE: we're assuming that there is only 1 vertical layer in this dataset!!!!!!
					data_array(itime,0,:,:) = data_array(itime,0,:,:) * \
											scaling_arrays(sect_ind,start_index+itime,:,:)
				
				end do ;; time slice loop
			
				;; push the data back into the input file
				FILE->$var_name$ = data_array
			
			
				;; delete our temporary arrays
				delete([/data_array/])

			else ; let the user know we're not processing this variable
				missing_variables = missing_variables + var_name + " "
			end if


		end if ;; if E_VOC variable

	end do ;; emiss var loop

	;;; if we've missed any variables, let the user know
	if(missing_variables .ne. "")
		print("No diurnal cycle applied to the following emission variables, because of lack of sector information (was this intended?):")
		print(str_split(missing_variables, " "))
	end if


end ;;;;; modify_emissions_diurnal_cycle





undef("impose_diurnal_cycle")
procedure impose_diurnal_cycle(DIR:string,UTC_offset:logical,wrfchem_scheme:string,input_scheme:string)
local emission_sectors, start_index, FILE1, FILE2, lat_data, lon_data, utc_offset_map, scaling_arrays
begin

	;;;;; get the diurnal cycle settings for the emission scheme we are using
	if(input_scheme.eq."EDGAR_HTAP")
		emission_sectors = emiss_cycle_EDGAR_HTAP_sectors
	else if(input_scheme.eq."EDGAR_AP_V432")
		emission_sectors = emiss_cycle_EDGAR_AP_V432_sectors
	else if(input_scheme.eq."IITM")
		emission_sectors = emiss_cycle_IITM_sectors
	else
		print("scheme "+input_scheme+" is not supported, failing in impose_diurnal_cycle")
		exit()
	end if
	end if
	end if

	;;;;; open the files for processing
	FILE1 = addfile(DIR+wrfchem_scheme@fname1+".nc","w")
	FILE2 = addfile(DIR+wrfchem_scheme@fname2+".nc","w")
	
	;;;;; pull out the latitude and longitude data
	lat_data = FILE1->XLAT
	lon_data = FILE1->XLONG
	
	;;;;; determine which countries we cover, 
	;;;;;      and calculate the offset from UTC for each grid point
	utc_offset_map = utc_offset_calculation(lat_data,lon_data,UTC_offset) 

	;;; create a variable in each file for carrying timezone offset information
    filevardef(FILE1, "TZ_Offset", "float", Var_Dims(2:3))                     
    filevarattdef(FILE1, "TZ_Offset", TZ_Att)
    filevardef(FILE2, "TZ_Offset", "float", Var_Dims(2:3))                     
    filevarattdef(FILE2, "TZ_Offset", TZ_Att)

	;;;;; save the UTC offset information to the intermediate emission files
	FILE1->TZ_Offset = (/utc_offset_map/)
	FILE2->TZ_Offset = (/utc_offset_map/)
	
	;;;;; create scaling arrays for each emission sector for this domain
	scaling_arrays = create_timezone_scaling_arrays(utc_offset_map,lat_data)


	;;;;; modify emissions in file 1
	start_index = 0
	modify_emissions_diurnal_cycle(FILE1,scaling_arrays,start_index,emission_sectors,"_ANT_")

	;;;;; modify emissions in file 2
	start_index = 12
	modify_emissions_diurnal_cycle(FILE2,scaling_arrays,start_index,emission_sectors,"_ANT_")
	
	;;;;; close the files again
	delete([/FILE1,FILE2/])


end ;;;;; impose_diurnal_cycle




undef("impose_nmvoc_diurnal_cycle")
procedure impose_nmvoc_diurnal_cycle(DIR:string,UTC_offset:logical,wrfchem_scheme:string,nmvoc_scheme:string)
local filename_1, filename_2, \
	nmvoc_sectors, start_index, OFF_FILE, FILE1, FILE2, \
	lat_data, lon_data, utc_offset_map, scaling_arrays
begin

	filename_1 = DIR + nmvoc_scheme@fname1
	filename_2 = DIR + nmvoc_scheme@fname2

	;;;;; get the diurnal settings for the NMVOC scheme we are using
	if(nmvoc_scheme.eq."EDGAR_NMVOC_V432")
		nmvoc_sectors = edgar_nmvoc_sectors
	else if(nmvoc_scheme.eq."MACCITY_NMVOC")
		nmvoc_sectors = maccity_sectors
	end if
	end if

	;;;;; open prev file, and load the utc_offset_map variable
	OFF_FILE = addfile(DIR+wrfchem_scheme@fname1+".nc","r")
	utc_offset_map = OFF_FILE->TZ_Offset
	

	;;;;; open the files for processing
	FILE1 = addfile(filename_1+".nc","w")
	FILE2 = addfile(filename_2+".nc","w")
	
	;;;;; pull out the latitude and longitude data
	lat_data = FILE1->XLAT
	lon_data = FILE1->XLONG
		
	;;;;; create scaling arrays for each emission sector for this domain
	scaling_arrays = create_timezone_scaling_arrays(utc_offset_map,lat_data)

	;;;;; modify emissions in file 1
	start_index = 0
	modify_emissions_diurnal_cycle(FILE1,scaling_arrays,start_index,nmvoc_sectors,"E_VOC")

	;;;;; modify emissions in file 2
	start_index = 12
	modify_emissions_diurnal_cycle(FILE2,scaling_arrays,start_index,nmvoc_sectors,"E_VOC")
	
	;;;;; close the files again
	delete([/FILE1,FILE2/])


end ;;;;; impose_nmvoc_diurnal_cycle


