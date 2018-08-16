;
;  General routines needed for applying the diurnal cycle to 
;  our emissions data.
;  
;   Contents:
;        process_oc_om_emissions
;            This routine applies the OC:OM scaling factor to
;            the emissions data. Currently this applies a single 
;            value, so we assume the ratio is the same for all 
;            emission sectors. In future we could apply 
;            one ratio per emission sector to make this a 
;            more nuanced routine.
;
;        conform_pm_emissions
;            This calculates the "unspeciated" (i.e. none OM or BC)
;            particulate masses, using PM2.5, PM10, BC and OM masses.
;            We assume that all OM and BC is in the PM2.5 size range.
;            PM2.5 becomes PM2.5 - (OM+BC)
;            PM10 becomes PM10 - PM2.5
;            (any negative values are set to 0.0) 
;            We apply this check to each emission sector (so we don't 
;            balance emissions from different sectors) before we combine 
;            them later.
;
;        regional_mod_emissions
;            This routine takes minimum and maximum Latitude and 
;            Longitude values, a list of emissions (by sector) to
;            modify, and a corresponding list of scaling values.
;            The routine will scale the given emissions within the
;            defined region by the given values.
;
;        emission_preprocess
;            This is the main function - which loads 
;            the files to be modified, and calls the 
;            other routines.
;
;        emission_nmvoc_preprocess
;            This replicates the main function, for
;            processing extra NMVOC emissions. It only
;            calls the regional_mod_emissions routine.
;
;        emission_file_setup
;            This checks for the existence of the intermediate
;            directory (creating it if necessary), and will also
;            check that the source files exist (and will fail
;            gracefully if they are not).
;
;        copy_input_scheme_information
;            This copies the variable attributes which control the 
;            input sectors which are used for each of our input species.
;
;
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"     ; include standard resources
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


load "./emission_script_data.ncl"


undef("process_oc_om_emissions")
procedure process_oc_om_emissions(FILE:file,oc_om_scale:float)
local emiss_name, esec, sect_name, sect_ind, var_name, data_array
begin

	;; define OC as the emission variable to process
	emiss_name = "OC"

	;; loop through the emission sectors for that variable
	do esec=0,dimsizes(emiss_cat@$emiss_name$)-1

		;; grab the emission sector name
		sect_name = emiss_cat@$emiss_name$(esec)

		;; obtain the emission index
		sect_ind = emiss_sector_index@$sect_name$

		;; create the variable name
		;;    naming style is: E_SO2_ANT_IND 
		var_name = "E_"+emiss_name+"_ANT_"+sect_name

		;; pull the data from the input file
		data_array = FILE->$var_name$

		;; apply the scaling factor
		data_array = data_array * oc_om_scale

		;; push the data back into the input file
		FILE->$var_name$ = data_array

		;; delete our temporary arrays
		delete([/sect_name,var_name,data_array/])


	end do ;; emission sector loop


end ;;;;; process_oc_om_emissions


undef("conform_pm_emissions")
procedure conform_pm_emissions(FILE:file)
local esec, sect_name, pm10_name, pm25_name, om_name, bc_name, \
	flag_om_bc, data_om_bc, flag_pm25, flag_pm10, \
	data_pm10, data_pm25, data_om, data_bc
begin


	;; loop through *all* emission sectors
	do esec=0,dimsizes(emiss_sector)-1

		;; grab the emission sector name
		sect_name = emiss_sector(esec)

		;; create the variable names
		;;    naming style is: E_SO2_ANT_IND 
		pm10_name = "E_"+"PM10"+"_ANT_"+sect_name
		pm25_name = "E_"+"PM2_5"+"_ANT_"+sect_name
		om_name   = "E_"+"OC"+"_ANT_"+sect_name
		bc_name   = "E_"+"BC"+"_ANT_"+sect_name
		
		;; how we check conformation depends on existence of emission variables
	
		;; sum up the OM & BC masses, *if* they exist
		if(isfilevar(FILE,om_name) .and. isfilevar(FILE,bc_name))
			flag_om_bc = True
			data_om    = FILE->$om_name$
			data_bc    = FILE->$bc_name$
			data_om_bc = data_om + data_bc
			delete([/data_om,data_bc/])
		else if(isfilevar(FILE,om_name))
			flag_om_bc = True
			data_om_bc = FILE->$om_name$
		else if(isfilevar(FILE,bc_name))
			flag_om_bc = True
			data_om_bc = FILE->$bc_name$
		else
			flag_om_bc = False
		end if
		end if
		end if
		
		;; load and conform PM2.5 masses, *if* they exist
		if(isfilevar(FILE,pm25_name))
			flag_pm25 = True
			data_pm25 = FILE->$pm25_name$
			
			if(flag_om_bc)
				;; perform the check for PM2.5 (we assume that all OM & BC is within this size range)
				data_pm25 = where(data_pm25.gt.data_om_bc, data_pm25 - data_om_bc, 0.0)
			end if
		else
			flag_pm25 = False
		end if
		
		;; load and conform PM10 masses, *if* they exist
		if(isfilevar(FILE,pm10_name))
			flag_pm10 = True
			data_pm10 = FILE->$pm10_name$
		
			if(flag_pm25)
				;; now check that PM10 isn't smaller than PM2.5
				data_pm10 = where(data_pm10.gt.data_pm25, data_pm10 - data_pm25, 0.0)
			else if(flag_om_bc)
				;; now check that PM10 isn't smaller than PM2.5
				data_pm10 = where(data_pm10.gt.data_om_bc, data_pm10 - data_om_bc, 0.0)
			end if
			end if
		else
			flag_pm10 = False
		end if
		

		;; write the PM10 and PM2.5 data back to the file, and delete temporary arrays
		if(flag_pm10)
			FILE->$pm10_name$ = data_pm10
			delete(data_pm10)
		end if
		if(flag_pm25)
			FILE->$pm25_name$ = data_pm25
			delete(data_pm25)
		end if
		if(flag_om_bc)
			delete(data_om_bc)
		end if
				
	end do ;; emission sector loop


end ;;;;; conform_pm_emissions



undef("regional_mod_emissions")
procedure regional_mod_emissions(FILE:file,control:logical)
local xlat_temp, xlong_temp, dom_sizes, xlat, xlong, isp, var

begin

	;;; load latitude and longitude data
	xlat_temp = FILE->XLAT
	xlong_temp = FILE->XLONG
	
	dom_sizes = dimsizes(xlat_temp)
	
	;;; create data arrays the same size as the emissions data
	;;;   for storing the long/lat data
	;;; NOTE: for the moment we assume 12 times, and 1 vertical level - this will break if this changes !!!!!!!!!!!!!!
	xlat = new((/12,1,dom_sizes(0),dom_sizes(1)/),typeof(xlat_temp))
	xlong = new((/12,1,dom_sizes(0),dom_sizes(1)/),typeof(xlong_temp))
	do isp = 0, (12-1)
		xlat(isp,0,:,:)  = xlat_temp
		xlong(isp,0,:,:) = xlong_temp
	end do

	;;; note our Lat / Lon limits
	lat_min = control@latitude_limits(0)
	lat_max = control@latitude_limits(1)
	long_min = control@longitude_limits(0)
	long_max = control@longitude_limits(1)
	

	;;; loop through the variables to be masked
	do isp = 0, dimsizes(control@vars_mask)-1
	
		;;; check that this variable is in the file
		if(isfilevar(FILE,vars_mask(isp)))
			;;; extract variable to process
			var = FILE->$control@vars_mask(isp)$
		
			;;; scale the variable within the masked region
			var = where( (xlat .ge. lat_min) .and. (xlat .le. lat_max) .and. \
							(xlong .ge. long_min) .and. (xlong .le. long_max), \
							var*control@vars_scale(isp), var )
	
			;;; push the variable back into our data array
			FILE->$control@vars_mask(isp)$ = var
		end if
	
	end do	


end ;;;;; regional mod emissions


undef("emission_preprocess")
procedure emission_preprocess(DIR:string,scheme:string,oc_om_scale:float, \
								regional_modification_of_emissions:logical)
local FILE1, FILE2
begin

	;;;;; open the files for processing
	FILE1 = addfile(DIR+scheme@fname1+".nc","w")
	FILE2 = addfile(DIR+scheme@fname2+".nc","w")
	
	;;;;; regional modification of emissions (if required)
	if(regional_modification_of_emissions)
		print("== Applying regional modification of emissions ==")
		regional_mod_emissions(FILE1,regional_modification_of_emissions)
		regional_mod_emissions(FILE2,regional_modification_of_emissions)	
	end if
		

	;;;;; modify OC emissions
	process_oc_om_emissions(FILE1,oc_om_scale)
	process_oc_om_emissions(FILE2,oc_om_scale)
	
	;;;;; conform the PM emission data, so that it is never less than BC+OM
	conform_pm_emissions(FILE1)
	conform_pm_emissions(FILE2)
	
	
	;;;;; close the files again
	delete([/FILE1,FILE2/])


end ;;;;; emission_preprocess




undef("emission_nmvoc_preprocess")
procedure emission_nmvoc_preprocess(DIR:string,scheme:string, \
								regional_modification_of_emissions:logical)
local FILE1, FILE2
begin

	;;;;; open the files for processing
	FILE1 = addfile(DIR+scheme@fname1+".nc","w")
	FILE2 = addfile(DIR+scheme@fname2+".nc","w")
	
	;;;;; regional modification of emissions (if required)
	if(regional_modification_of_emissions)
		print("== Applying regional modification of emissions ==")
		regional_mod_emissions(FILE1,regional_modification_of_emissions)
		regional_mod_emissions(FILE2,regional_modification_of_emissions)	
	end if
		

	;;;;; close the files again
	delete([/FILE1,FILE2/])


end ;;;;; emission_nmvoc_preprocess




undef("emission_file_setup")
procedure emission_file_setup(SOURCEDIR:string,DIUDIR:string,scheme:string)
begin

	;;; check for intermediate directory, create it if it doesn't exist
	if(.not.fileexists(DIUDIR))
		print("== Creating Intermediate Directory: "+DIUDIR)
		system("mkdir -p "+DIUDIR)
	end if
	;;; check if the source files exist, fail if not
	if(.not.all(isfilepresent(SOURCEDIR+(/scheme@fname1,scheme@fname2/))))
		print("== Emission source files not accessible, failure in emission_file_setup, check these paths:")
		print(SOURCEDIR+scheme@fname1)
		print(SOURCEDIR+scheme@fname2)
		exit()
	end if
	;;;;; copy original files to diurnal cycle intermediate directory
	system("cp "+SOURCEDIR+scheme@fname1+" "+DIUDIR+scheme@fname1)
	system("cp "+SOURCEDIR+scheme@fname2+" "+DIUDIR+scheme@fname2)



end ;;;;; emission_file_setup


undef("copy_input_scheme_information")
function copy_input_scheme_information(input_scheme:string)
local emission_sectors
begin

	;;; Main Emission Schemes
	if(input_scheme.eq."EDGAR_HTAP")
		copy_VarAtts(emiss_cat_EDGAR_HTAP,emiss_cat)
		emission_sectors = emiss_cycle_EDGAR_HTAP_sectors

	else if(input_scheme.eq."IITM")
		copy_VarAtts(emiss_cat_IITM,emiss_cat)
		emission_sectors = emiss_cycle_IITM_sectors

	else if(input_scheme.eq."EDGAR_AP_V432")
		copy_VarAtts(emiss_cat_EDGAR_AP_V432,emiss_cat)
		emission_sectors = emiss_cycle_EDGAR_AP_V432_sectors

	;;; NMVOC Emission Schemes (note: don't need to copy attributes to emiss_cat for these)
	else if(input_scheme.eq."EDGAR_NMVOC_V432")
		emission_sectors = edgar_nmvoc_sectors

	else if(input_scheme.eq."MACCITY_NMVOC")
		emission_sectors = maccity_sectors

	else
		print("scheme "+input_scheme+" is not supported, failing in copy_input_scheme_information")
		exit()
	end if
	end if
	end if
	end if
	end if


	return(emission_sectors)

end ;;;;; copy_input_scheme_information





