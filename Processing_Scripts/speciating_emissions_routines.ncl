;
;  General routines needed for applying the diurnal cycle to 
;  our emissions data.
;  
;   Contents:
;        create_emission_files
;            This routine creates the emissions files which
;            will contain the WRF-Chem readable data. We copy
;            file attributes from the original emissions files,
;            but change the variables to match those needed
;            by WRF-Chem
;
;        load_emission_data
;            This loads the emissions data, storing it in a 6-D data array.
;            1st dimension is emission category; 2nd is emission sector;
;            the rest are the 4 dimensions of the model data.
;
;        process_inorganic_gas_emissions
;            Processing routines specific to inorganic gaseous emissions.
;            This includes applying the fractionation of NOx emissions and
;            the combining of emission sectors. 
;
;        process_aerosol_emissions
;            Processing routines specific to aerosol emissions. This includes
;            creating the OIN emission variables:
;                    OIN_25 = PM2_5 - (BC+OC)   (assuming OC is now OM)
;                    OIN_10 = PM10 - PM2_5
;            and the combining of emission sectors.
;
;        nmvoc_fraction_calculations
;            This routine is called from "process_nmvoc_emissions_by_fraction".
;            It calculates the *mass* fraction values for the 
;            unspeciated NMVOC emissions from the MACCITY (or alternative)
;            speciated NMVOC emission data. These are calculated
;            from the summed emissions across the whole model domain.
;
;
;        process_nmvoc_emissions_by_fraction
;            This routine applies a NMVOC mass fractional
;            distribution to lumped NMVOC emissions data,
;            to give the scheme specific emissions.
;
;        process_nmvoc_emissions_direct
;            This routine takes a set of NMVOC emissions data,
;            combines sectors and compounds according to the 
;            final scheme, applies the molar masses, and returns
;            NMVOC emissions data.
;
;        generate_scheme_emissions
;            Called from "combine_emission_sectors". This then
;            calls the inorganic gas, aerosol, and nmvoc emission
;            processing routines (selecting between direct and
;            fractional nmvoc emission calculations).
;
;        combine_emission_sectors
;            This routine acts as a front-end for calling of 
;            the emission combining subroutine. Here we have
;            an IF statement, which selects for the appropriate
;            scheme, and passes the correct config arrays to the 
;            subroutine which does all the work.
;            *This routine will need changing whenever a new 
;            scheme is added to this program*
;



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"     ; include standard resources
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


load "./emission_script_data.ncl"



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; emission speciation routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




undef("create_emission_file")
procedure create_emission_files(INDIR:string,OUTDIR:string,fname:string,wrfchem_scheme:string)
local INFILE, OUTFILE, global_attnames, ig, dim_sizes, dim_names, dim_Unlim, \
		xlat, xlon, times, var_names, var_types, tz_off
begin

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; common information (Var_Dims, AERO_Att and GAS_NMVOC_Att, TZ_Att) defined in
	;;;                     emission_script_data.ncl
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;; open file we'll be copying the global attributes from
	INFILE = addfile(INDIR+wrfchem_scheme@$fname$+".nc","r")

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



	;;; copy the global attributes from the original file to the new files
	copy_VarAtts(INFILE,OUTFILE)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  here we should set author, creation date, etc
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	;;; get the dimension names and sizes from the input file
	dim_sizes = getfiledimsizes(INFILE)
	dim_names = getvardims(INFILE)

	;;; set all dimensions as Limited
	dim_Unlim = new(dimsizes(dim_sizes),logical)
	dim_Unlim(:) = False
	;;; now find the Time dimension, and set that to Unlimited
	dim_Unlim(ind(dim_names.eq."Time"))   = True


	;;; apply these dimensions to the output files
	filedimdef( OUTFILE, dim_names, dim_sizes, dim_Unlim )
	

	
	;;; create the variables that we're going to add to output file

	;;; copy common variables
	xlon   = INFILE->XLONG
	xlat   = INFILE->XLAT
	times  = INFILE->Times
	tz_off = INFILE->TZ_Offset
	
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


undef("load_emissions_data")
function load_emissions_data(INFILE:file)
local ic, ie, ecat, ecat_pointer, esect, esect_pointer, emiss_temp, edim, emission_data
begin

	;;; loop through the original emission categories
	do ic = 0,number_original_emission_variables-1

		; note the category
		ecat = emiss_orig(ic)

		; determine our pointer for the emission category
		ecat_pointer = emiss_cat_index@$ecat$

		
		;;; loop through the emission sectors for each category
		do ie = 0,dimsizes(emiss_cat@$ecat$)-1
		
			; note the sector
			esect = emiss_cat@$ecat$(ie)
			
			; determine our pointer for the emission sector
			esect_pointer = emiss_sector_index@$esect$
			
			;;; pull out emission variable from datafile (using the "parent" category name)
			emiss_temp = INFILE->$(/"E_"+ecat+"_ANT_"+esect/)$

			;;; first time through create our storage array
			if(ic.eq.0 .and. ie.eq.0)
				edim = dimsizes(emiss_temp)
				;; NOTE: we're assuming that the input data is 4 dimensional
				;;       if this is not the case then this script will break!!!
				emission_data = new( (/ dimsizes(emiss_cat), dimsizes(emiss_sector), edim(0), edim(1), edim(2), edim(3) /) ,\
										typeof(emiss_temp),emiss_temp@_FillValue)
			end if
			
			;;; copy the data into the storage array
			emission_data(ecat_pointer,esect_pointer,:,:,:,:) = emiss_temp
			
			;;; delete the temporary file
			delete(emiss_temp)
		
		end do ; ie = dim(emiss_cat@ecat)

	end do ; ic = number_original_emission_variables

	;;; return the temporary emission array
	return(emission_data)

end ;;;;; load_emissions_data


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; processing of inorganic gas emissions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef("process_inorganic_gas_emissions")
procedure process_inorganic_gas_emissions(OUTFILE:file,VAR_LIST_GAS:string,INORG_MAP_VAR:logical,\
											INORG_MAP_TRN:logical,nox_frac:float,emissions_data:float)
local ig, pname, ename, epname, e_point, cfac, ies, esname, s_point, emissions
begin

	do ig = 0, dimsizes(VAR_LIST_GAS)-1
		;;; grab the name of the gas we're processing
		pname = VAR_LIST_GAS(ig)
		;;; grab the name of the emission category we're using
		ename = INORG_MAP_VAR@$pname$
		;;; grab the name of the parent emission category (in case this is different)
		epname = emiss_orig(emiss_cat_index@$ename$)
		;;; get the pointer for the emissions we'll be converting (using the parent emission category)
		e_point = emiss_cat_index@$epname$

		
		;;; check if we're processing NO or NO2 - as these need special conversion factors
		if(pname .eq. "E_NO")
			cfac = nox_frac
		else if(pname .eq. "E_NO2")
			cfac = 1.0 - nox_frac
		else  ;;; otherwise just take the standard conversion factor
			cfac = INORG_MAP_TRN@$pname$
		end if
		end if
		
		;;; loop through the emission sectors for this gas, summing up the emissions
		do ies = 0, dimsizes(emiss_cat@$ename$)-1
			;;; get the sector name
			esname = emiss_cat@$ename$(ies)
			;;; get the sector pointer
			s_point = emiss_sector_index@$esname$
			
			;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
			if(ies .eq. 0)
				emissions = emissions_data(e_point,s_point,:,:,:,:) * cfac
			else
				emissions = emissions + emissions_data(e_point,s_point,:,:,:,:) * cfac			
			end if		
		
		end do
		
		;;; push the emissions data to the outfile
		OUTFILE->$pname$ = (/emissions/)
		
		;;; tidy up
		delete(emissions)
	
	end do

end ;;; process_inorganic_gas_emissions



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; processing of aerosol emissions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef("process_aerosol_emissions")
procedure process_aerosol_emissions(OUTFILE:file,VAR_LIST_AERO:string,AERO_MAP_VAR:logical,\
										AERO_MAP_TRN:logical,emissions_data:float)
local ig, pname, ename, epname, e_point, e_point_bc, e_point_oc, e_point_pm, \
		ies, esname, s_point, emissions, e_point_pm25, cfac 
begin
	do ig = 0, dimsizes(VAR_LIST_AERO)-1
		;;; grab the name of the aerosol variable we're processing
		pname = VAR_LIST_AERO(ig)
		;;; grab the name of the emission category we're using
		ename = AERO_MAP_VAR@$pname$
		;;; grab the name of the parent emission category (in case this is different)
		epname = emiss_orig(emiss_cat_index@$ename$)
		;;; get the pointer for the emissions we'll be converting (using the parent emission category)
		e_point = emiss_cat_index@$epname$
		
		;;; check if we're processing special data, if so follow the required rules
		if(pname .eq. "E_OIN_25" .or. pname .eq. "E_PM25i" .or. pname .eq. "E_PM25j") ; OIN (other inorganics) for CBMZ_MOS_TNO
			
			;;; get the BC & OC pointers
			e_point_bc = emiss_cat_index@BC
			e_point_oc = emiss_cat_index@OC
			
			;;; get the PM pointer
			e_point_pm = emiss_cat_index@PM2_5

			;;; get the standard conversion factor (giving the split between modes i and j)
			cfac = AERO_MAP_TRN@$pname$

			;;; loop through the emission sectors for this gas, summing up the emissions
			do ies = 0, dimsizes(emiss_cat@$ename$)-1
				;;; get the sector name
				esname = emiss_cat@$ename$(ies)
				;;; get the sector pointer
				s_point = emiss_sector_index@$esname$
			
				;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
				;;; This will be PM_2.5 - ( BC + OC ), OC is really OM (scaling factor already applied)
				;;; All BC & OM is assumed to be in PM2.5
				if(ies .eq. 0)
					emissions = ( emissions_data(e_point_pm,s_point,:,:,:,:) - \ 
								  ( emissions_data(e_point_bc,s_point,:,:,:,:) + emissions_data(e_point_oc,s_point,:,:,:,:) ) \
								) * cfac
				else
					emissions = emissions + \
								( emissions_data(e_point_pm,s_point,:,:,:,:) - \ 
								  ( emissions_data(e_point_bc,s_point,:,:,:,:) + emissions_data(e_point_oc,s_point,:,:,:,:) ) \	
							    ) * cfac
				end if
		
			end do
			
		else if(pname .eq. "E_OIN_10" .or. pname .eq. "E_PM_10")

			;;; get the PM2.5 pointer (and assume that we made sure earlier that PM2.5 > (BC + OM)!!!!)
			e_point_pm25 = emiss_cat_index@PM2_5

			;;; get the PM pointer
			e_point_pm = emiss_cat_index@PM10


			;;; loop through the emission sectors for this gas, summing up the emissions
			do ies = 0, dimsizes(emiss_cat@$ename$)-1
				;;; get the sector name
				esname = emiss_cat@$ename$(ies)
				;;; get the sector pointer
				s_point = emiss_sector_index@$esname$
			
				;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
				;;; This will be PM_10 - PM_2.5
				if(ies .eq. 0)
					emissions = emissions_data(e_point_pm,s_point,:,:,:,:) - emissions_data(e_point_pm25,s_point,:,:,:,:)
				else
					emissions = emissions + emissions_data(e_point_pm,s_point,:,:,:,:) - emissions_data(e_point_pm25,s_point,:,:,:,:)	
				end if		
		
			end do
		
		else ; standard data

			;;; get the standard conversion factor
			cfac = AERO_MAP_TRN@$pname$

			;;; loop through the emission sectors for this gas, summing up the emissions
			do ies = 0, dimsizes(emiss_cat@$ename$)-1
				;;; get the sector name
				esname = emiss_cat@$ename$(ies)
				;;; get the sector pointer
				s_point = emiss_sector_index@$esname$
		
				;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
				if(ies .eq. 0)
					emissions = emissions_data(e_point,s_point,:,:,:,:) * cfac
				else
					emissions = emissions + emissions_data(e_point,s_point,:,:,:,:) * cfac			
				end if		
	
			end do

		end if
		end if
		
		;;; push the emissions data to the outfile
		OUTFILE->$pname$ = (/emissions/)
	
		;;; tidy up
		delete(emissions)
	
	end do

end ;;; process_aerosol_emissions



undef("nmvoc_fraction_calculations")
function nmvoc_fraction_calculations(INDIR:string,nmvoc_scheme:string,fname:string,\
										nmvoc_species:string,nmvoc_species_index:logical,\
										nmvoc_groups:string,nmvoc_sectors:string)
local FILE, total_emissions, im, js, sector_pointer, species_pointer, emiss_data, total_mass, \
		var_list, var_num, emiss_name, cat_var, \
		first_time, ia, ib, ic, id
begin

	;;; set flag to control creation of data array
	first_time = True

	;;; open the NMVOC data file
	FILE = addfile(INDIR+nmvoc_scheme@$fname$+".nc","r")

	;;; pull out a list of the variables in the emission file
	var_list = getfilevarnames(FILE)
	var_num = dimsizes(var_list)
	

	;;; extract the emission data
	; loop through the input NMVOC emission sectors
	do im = 0, dimsizes(nmvoc_sectors)-1
		; determine our pointer for the standard emission sector we will populate
		sector_pointer = emiss_sector_index@$nmvoc_groups(im)$
		
		; loop through the input NMVOC emission species for each sector
		do js = 0, dimsizes(nmvoc_species)-1
			
			; determine our pointer for the emission species
			species_pointer = nmvoc_species_index@$nmvoc_species(js)$
			
			; create the emission variable name
			emiss_name = "E_"+nmvoc_species(js)+"_"+nmvoc_sectors(im)
			
			; check that this emission variable is in the file
			cat_var := str_match(var_list,emiss_name)
			if(.not. any(ismissing(cat_var)))
			
				; load data
				emiss_data = FILE->$emiss_name$


				;;; first time through create our storage array
				if(first_time)
					first_time = False
					edim = dimsizes(emiss_data)
					;; NOTE: we're assuming that the input data is 4 dimensional
					;;       if this is not the case then this script will break!!!

					;;; create data array for storing the generated information
					; 2 + 4 dimensions: 1st is input NMVOC Species; 2nd is standard (output) emission sector; last 4 are model domain info
					nmvoc_mass_fractions = new((/dimsizes(nmvoc_species),dimsizes(emiss_sector), edim(0), edim(1), edim(2), edim(3) /),\
											float)

					;;; create data array for storing the summed emission data
					;  2 + 4  dimensions: 1st is input NMVOC Species; 2nd is standard (output) emission sector; last 4 are model domain info
					total_emissions = new((/dimsizes(nmvoc_species),dimsizes(emiss_sector), edim(0), edim(1), edim(2), edim(3) /),\
											float)
					; initialise all the data to zero
					total_emissions = 0.0


				end if

			
				; sum up the data, and add the result to our storage array
				;  Note: we add, not replace, because a single (final) emission sector
				;        could contain multiple NMVOC input emission sectors 
				total_emissions(species_pointer,sector_pointer,:,:,:,:) = total_emissions(species_pointer,sector_pointer,:,:,:,:) + emiss_data
			
				; delete data array
				delete(emiss_data)
			
			end if

		end do
	
	end do

	;;; close the data file
	delete(FILE)


	;;; calculate the emission mass fractionation for each species by sector
	; loop through sectors
	do ies = 0, dimsizes(emiss_sector)-1
	do ia  = 0, edim(0)-1
	do ib  = 0, edim(1)-1
	do ic  = 0, edim(2)-1
	do id  = 0, edim(3)-1
	
		; calculate the total NMVOC emitted mass for this sector
		total_mass = sum(total_emissions(:,ies,ia,ib,ic,id))
	
		; divide species mass by total to get fraction (unless there's nothing, then set all to zero)
		if(total_mass .le. 0.0)
			nmvoc_mass_fractions(:,ies,ia,ib,ic,id) = 0.0
		else
			nmvoc_mass_fractions(:,ies,ia,ib,ic,id) = total_emissions(:,ies,ia,ib,ic,id) / total_mass
		end if	

		; delete temp data
		delete(total_mass)

	end do
	end do
	end do
	end do
	end do

	;;; return the fractionation data
	return(nmvoc_mass_fractions) 

end



undef("process_nmvoc_emissions_by_fraction")
procedure process_nmvoc_emissions_by_fraction(INDIR:string,OUTFILE:file,nmvoc_scheme:string,fname:string,\
												VAR_LIST_NMVOC:string,NMVOC_MAP_VAR:logical,\
												NMVOC_MAP_TRN:logical, NMVOC_MOL_WGT:logical,\
												emissions_data:float,\
												nmvoc_species:string,nmvoc_species_index:logical,\
												nmvoc_groups:string,nmvoc_sectors:string,\
												nmvoc_mol_weights:logical)
local ig, pname, enum, ename_list, ename, e_point, cfac_list, isp, ecname, cfac, mwgt, \
		ies, esname, s_point, mfac, emissions 
begin

	;;;;; calculate the NMVOC fractional values
	print("== Calculating the NMVOC fractions (this could take some time) ==")
	nmvoc_mass_fractions = nmvoc_fraction_calculations(INDIR,nmvoc_scheme,fname,\
														nmvoc_species,nmvoc_species_index,\
														nmvoc_groups,nmvoc_sectors)

	;;; get the pointer for the NMVOC emissions we'll be fractionating
	e_point = emiss_cat_index@NMVOC


	do ig = 0, dimsizes(VAR_LIST_NMVOC)-1

		;;; grab the name of the gas we're processing
		pname = VAR_LIST_NMVOC(ig)

		;;; grab the names of the emission inputs we're using
		ename_list := NMVOC_MAP_VAR@$pname$
			
		;;; count the emission mapping species
		enum = dimsizes(ename_list)

		;;; get the sector name
		ename = ename_list(enum-1)

		;;; check that the last category is "NMVOC" - if not then skip this species
		if(ename .eq. "NMVOC")

			;;; get the standard conversion factors
			cfac_list := NMVOC_MAP_TRN@$pname$

	
			;;; loop through the mapping species (not using the last species)
			do isp = 0, enum - 2 

				;;; get the input name
				ecname = ename_list(isp)

				;;; get the NMVOC source to new scheme multiplier
				cfac = cfac_list(isp)
				;print("cfac = "+cfac)
				
				;;; check if we're using intermediate compounds
				if(nmvoc_scheme@use_intermediates)

					;;; get the list of inputs for this intermediate
					input_list := NMVOC_MAP_VAR@$ecname$
					;;; get the conversion factors for the intermediate
					input_cfac_list := NMVOC_MAP_TRN@$ecname$
					;;; get number of inputs for the intermediate
					innum = dimsizes(input_list)

					;;; set the flag for our first step in next loop
					init_iint = True

					;;; we loop through the intermediates for this nmvoc
					do iint = 0, innum-1

						;;; get the (original) input name
						inname = input_list(iint)
						;;; get the (original) input conversion factor
						incfac = input_cfac_list(iint)

						;;; get the NMVOC molecular weight - with a choice of using
						;;;    either the molecular weights from the source scheme,
						;;;    or molecular weights for the destination scheme
						if(nmvoc_scheme@molweights .eq. "source")
							mwgt = nmvoc_mol_weights@$inname$
						else if(nmvoc_scheme@molweights .eq. "destination")
							mwgt = NMVOC_MOL_WGT@$ecname$
						end if
						end if

						;;; loop through the emission sectors for this gas, summing up the emissions
						do ies = 0, dimsizes(emiss_cat@$ename$)-1

							;;; get the sector name
							esname = emiss_cat@$ename$(ies)
							;;; get the sector pointer
							s_point = emiss_sector_index@$esname$

							;;; get the MACCity NMVOC mass fraction, for the given sector
							mfac = nmvoc_mass_fractions(nmvoc_species_index@$inname$,s_point,:,:,:,:)
							;print("mfac = "+mfac)

							;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
							; NMVOC emissions input is in kg/m2/s --- we multiple this by the mass fraction to
							;       get the emitted mass of the original NMVOC, then divide by the molecular weight
							;       of this to get the emission in mol/m2/s. The scheme multipliers (from original to
							;       intermediate, and intermediate to final) will modify this
							;       emission (if, for example, there are 2 moles of the scheme NMVOC for every one
							;       mole of the original NMVOC).
							if(isp .eq. 0 .and. iint .eq. 0 .and. ies .eq. 0)
								emissions = emissions_data(e_point,s_point,:,:,:,:) * (mfac/mwgt) * incfac * cfac
							else
								emissions = emissions + emissions_data(e_point,s_point,:,:,:,:) * (mfac/mwgt) * incfac * cfac	
							end if		

						end do ;; ies in emiss_cat

					end do ;; iint in iinum
					
				else ;;; carry on as normal, without intermediates
				
					;;; get the NMVOC molecular weight, choosing either source or final scheme
					if(nmvoc_scheme@molweights.eq."source")
						mwgt = nmvoc_mol_weights@$ecname$
					else if(nmvoc_scheme@molweights.eq."destination")
						mwgt = NMVOC_MOL_WGT@$pname$				
					end if
					end if
					;print("mwgt = "+mwgt)
			
			
					;;; loop through the emission sectors for this gas, summing up the emissions
					do ies = 0, dimsizes(emiss_cat@$ename$)-1

						;;; get the sector name
						esname = emiss_cat@$ename$(ies)
						;;; get the sector pointer
						s_point = emiss_sector_index@$esname$

						;;; get the MACCity NMVOC mass fraction, for the given sector
						mfac = nmvoc_mass_fractions(nmvoc_species_index@$ecname$,s_point,:,:,:,:)
						;print("mfac = "+mfac)
				
	
						;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
						; NMVOC emissions input is in kg/m2/s --- we multiple this by the mass fraction to
						;       get the emitted mass of the original NMVOC, then divide by the molecular weight
						;       of this to get the emission in mol/m2/s. The scheme multiplier will modify this
						;       emission (if, for example, there are 2 moles of the scheme NMVOC for every one
						;       mole of the original NMVOC).
						if(isp .eq. 0 .and. ies .eq. 0)
							emissions = emissions_data(e_point,s_point,:,:,:,:) * (mfac/mwgt) * cfac
						else
							emissions = emissions + emissions_data(e_point,s_point,:,:,:,:) * (mfac/mwgt) * cfac			
						end if		

					end do

				end if ;;; using intermediates?
	
			end do
	
	
		;;; if not then map straight from the emission species (usually setting to zero)
		else  
	
			;;; get the standard conversion factor
			cfac = NMVOC_MAP_TRN@$pname$
	
			;;; loop through the emission sectors for this gas, summing up the emissions
			do ies = 0, dimsizes(emiss_cat@$ename$)-1
				;;; get the sector name
				esname = emiss_cat@$ename$(ies)
				;;; get the sector pointer
				s_point = emiss_sector_index@$esname$
	
				;;; create the temporary emission dataset (assuming 4D datasets - this will break if they aren't!!!!)
				if(ies .eq. 0)
					emissions = emissions_data(e_point,s_point,:,:,:,:) * cfac
				else
					emissions = emissions + emissions_data(e_point,s_point,:,:,:,:) * cfac			
				end if		

			end do
		
	
		end if
	
		;;; push the emissions data to the outfile
		OUTFILE->$pname$ = (/emissions/)

		;;; tidy up
		delete(emissions)

	end do


end ;;; process_nmvoc_emissions_by_fraction


undef("process_nmvoc_emissions_direct")
procedure process_nmvoc_emissions_direct(INDIR:string,OUTFILE:file,nmvoc_scheme:string,fname:string,\
										VAR_LIST_NMVOC:string,NMVOC_MAP_VAR:logical,\
										NMVOC_MAP_TRN:logical,NMVOC_MOL_WGT:logical,\
										nmvoc_mol_weights:logical)
local INFILE, var_list, var_num, ig, pname, ename_list, enum, cfac_list, isp, ies, \
		ecname, cfac, cat_var, icat, emissions, \
		mwgt, init_isp, init_iint, init_icat, \
		input_list, input_cfac_list, innum, iint, inname, incfac, \
		esname, s_point, epname, e_point
begin

	;;; open the NMVOC emission data file
	INFILE = addfile(INDIR+nmvoc_scheme@$fname$+".nc","r")

	;;; pull out a list of the variables in the emission file
	var_list = getfilevarnames(INFILE)
	var_num = dimsizes(var_list)

	do ig = 0, dimsizes(VAR_LIST_NMVOC)-1
		;;; grab the name of the nmvoc variable we're processing
		pname = VAR_LIST_NMVOC(ig)
		;;; grab the names of the emission inputs we're using
		ename_list := NMVOC_MAP_VAR@$pname$
		;;; get number of emission inputs
		enum = dimsizes(ename_list)

		
		;;; check that the last category is "NMVOC" - if not then skip this species
		if(ename_list(enum-1) .eq. "NMVOC")

			;;; get the standard conversion factors
			cfac_list := NMVOC_MAP_TRN@$pname$

			;;; set the flag for our first step in next loop
			init_isp = True

			;;; loop through the emission inputs for this nmvoc, summing up the emissions
			do isp = 0, enum-2		;; last in list is "NMVOC", so we ignore this
			
				;;; get the input name
				ecname = ename_list(isp)
				;;; get the input conversion factor (ratio of nmvoc to the input)
				cfac = cfac_list(isp)
			
				;;; check if we are using intermediate compounds
				if(nmvoc_scheme@use_intermediates)
				
					;;; get the list of inputs for this intermediate
					input_list := NMVOC_MAP_VAR@$ecname$
					;;; get the conversion factors for the intermediate
					input_cfac_list := NMVOC_MAP_TRN@$ecname$
					;;; get number of inputs for the intermediate
					innum = dimsizes(input_list)

					;;; set the flag for our first step in next loop
					init_iint = True
					
					;;; we loop through the intermediates for this nmvoc
					do iint = 0, innum-1
					
						;;; get the (original) input name
						inname = input_list(iint)
						;;; get the (original) input conversion factor
						incfac = input_cfac_list(iint)

						;;; get the NMVOC molecular weight - with a choice of using
						;;;    either the molecular weights from the source scheme,
						;;;    or molecular weights for the destination scheme
						if(nmvoc_scheme@molweights .eq. "source")
							mwgt = nmvoc_mol_weights@$inname$
						else if(nmvoc_scheme@molweights .eq. "destination")
							mwgt = NMVOC_MOL_WGT@$ecname$
						end if
						end if
					
						;;; obtain a list of nmvoc variables for that input (covering different emission categories)
						cat_var := str_match(var_list,inname)

						;;; proceed if the list isn't empty
						if(.not. any(ismissing(cat_var)))
				
							;;; set the flag for our first step in next loop
							init_icat = True

							;;; loop through emission inputs, collecting them in the intermediate variable
							do icat = 0, dimsizes(cat_var)-1
					
								if(init_iint .and. init_icat)
									emissions_int = (/INFILE->$cat_var(icat)$/) * incfac / mwgt
									init_iint = False
									init_icat = False
								else
									emissions_int = emissions_int + ( (/INFILE->$cat_var(icat)$/) * incfac / mwgt )
								end if
	
							end do ;;; icat in cat_var

							;;; once we've collected all emissions in the intermediate then transfer them
							;;;    to the final emission variable
							
							if(init_isp)
								emissions = emissions_int * cfac
								init_isp = False
							else
								emissions = emissions + emissions_int * cfac							
							end if
					
						end if  ;;; cat_var not empty
					
					end do ;; iint in iinum
				
				
				else ;;; carry on as normal, without intermediates

					;;; get the NMVOC molecular weight - with a choice of using
					;;;    either the molecular weights from the source scheme,
					;;;    or molecular weights for the destination scheme
					if(nmvoc_scheme@molweights .eq. "source")
						mwgt = nmvoc_mol_weights@$ecname$
					else if(nmvoc_scheme@molweights .eq. "destination")
						mwgt = NMVOC_MOL_WGT@$pname$
					end if
					end if

					;;; obtain a list of nmvoc variables for that input (covering different emission categories)
					cat_var := str_match(var_list,ecname)
			
					;;; proceed if the list isn't empty
					if(.not. any(ismissing(cat_var)))

						;;; set the flag for our first step in next loop
						init_icat = True
				
						;;; loop through emission inputs, collecting them in the emission variable
						do icat = 0, dimsizes(cat_var)-1
					
							if(init_isp .and. init_icat)
								emissions = (/INFILE->$cat_var(icat)$/) * cfac / mwgt
								init_isp  = False
								init_icat = False
							else
								emissions = emissions + ( (/INFILE->$cat_var(icat)$/) * cfac / mwgt )
							end if
	
						end do ;;; icat in cat_var
					
					end if  ;;; cat_var not empty

				end if ;;; use_intermediates check
	
			end do ;;; isp in ename_list

			;;; make sure that we found some emissions (don't write to output if we didn't)
			if(.not.init_isp) 
				;;; push the emissions data to the outfile
				OUTFILE->$pname$ = (/emissions/)
				;;; tidy up
				delete(emissions)
			else
				print("no emissions data found for "+pname+"!")
			end if
	
		end if ;;; category is "NMVOC"
			
	end do ;;; ig in VAR_LIST_NMVOC


end ;; process_nmvoc_emissions_direct







undef("generate_scheme_emissions")
procedure generate_scheme_emissions(INDIR:string, OUTDIR:string, fname:string, \
			wrfchem_scheme:string, nmvoc_scheme:string, nox_frac:float, \
			INORG_MAP_VAR:logical, INORG_MAP_TRN:logical, \
			AERO_MAP_VAR:logical, AERO_MAP_TRN:logical, NMVOC_MAP_VAR:logical, \
			NMVOC_MAP_TRN:logical, NMVOC_MOL_WGT:logical, \
			nmvoc_species:string,nmvoc_species_index:logical, \
			nmvoc_groups:string,nmvoc_sectors:string, \
			nmvoc_mol_weights:logical)
local INFILE, emissions_data, OUTFILE, VAR_LIST_GAS, VAR_LIST_AERO, VAR_LIST_NMVOC
begin


	;;; open file we'll be copying the majority of the emission data from
	INFILE = addfile(INDIR+wrfchem_scheme@$fname$+".nc","r")

	;;; loading emissions data, without combining emission sectors
	;;;      this doesn't include information about the NMVOC speciation
	emissions_data = load_emissions_data(INFILE)

	;;; close the input file
	delete(INFILE)

	;;; open file we'll be copying the combined emission data to
	OUTFILE = addfile(OUTDIR+wrfchem_scheme@$fname$+".nc","w")



	;;; define our lists of emissions to generate
	VAR_LIST_GAS   = variable_lists@$(/"GAS_"+wrfchem_scheme/)$
	VAR_LIST_AERO  = variable_lists@$(/"AERO_"+wrfchem_scheme/)$
	VAR_LIST_NMVOC = variable_lists@$(/"NMVOC_"+wrfchem_scheme/)$
	

	;;; processing of inorganic gas emissions
	print("= Processing inorganic gases =")
	process_inorganic_gas_emissions(OUTFILE,VAR_LIST_GAS,INORG_MAP_VAR,INORG_MAP_TRN,\
																	nox_frac,emissions_data)


	;;; processing of aerosol emissions
	print("= Processing aerosol =")
	process_aerosol_emissions(OUTFILE,VAR_LIST_AERO,AERO_MAP_VAR,AERO_MAP_TRN,emissions_data)


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; processing of NMVOC emissions
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	print("= Processing NMVOC gases =")

	if(nmvoc_scheme@method .eq. "direct")

		process_nmvoc_emissions_direct(INDIR,OUTFILE,nmvoc_scheme,fname,VAR_LIST_NMVOC, \
												NMVOC_MAP_VAR,NMVOC_MAP_TRN,NMVOC_MOL_WGT, \
												nmvoc_mol_weights)


	else if(nmvoc_scheme@method .eq. "fraction")

		process_nmvoc_emissions_by_fraction(INDIR,OUTFILE,nmvoc_scheme,fname,VAR_LIST_NMVOC,\
												NMVOC_MAP_VAR,NMVOC_MAP_TRN,NMVOC_MOL_WGT,\
												emissions_data,nmvoc_species,nmvoc_species_index,\
												nmvoc_groups,nmvoc_sectors,nmvoc_mol_weights)

	end if  ;;; nmvoc_scheme@method selection
	end if




end ;;;;; generate_scheme_emissions






undef("combine_emission_sectors")
procedure combine_emission_sectors(INDIR:string,OUTDIR:string,fname:string,wrfchem_scheme:string, \
									nmvoc_scheme:string,nox_frac:float)
local INFILE, OUTFILE, emissions_data, \
		INORG_VAR, INORG_TRN, AERO_VAR, AERO_TRN, \
		NMVOC_VAR, NMVOC_TRN, NMVOC_WGT, \
		nmvoc_species, nmvoc_species_index, nmvoc_groups, nmvoc_sectors, nmvoc_mol_weights
begin

	;;; most combinations of schemes wont use intermediates for NMVOC mapping, so we
	;;; set the default value of this flag to be false. It will be changed below as needed. 
	nmvoc_scheme@use_intermediates = False

	;;; call the scheme specific routines for generating the emissions
	if(wrfchem_scheme .eq. "mozm_vbs4_pnnl")

		;INORG_VAR = INORG_MAP_VAR_mozm_vbs4_pnnl
		;INORG_TRN = INORG_MAP_TRN_mozm_vbs4_pnnl
		;AERO_VAR  = AERO_MAP_VAR_mozm_vbs4_pnnl
		;AERO_TRN  = AERO_MAP_TRN_mozm_vbs4_pnnl
		;NMVOC_VAR = NMVOC_MAP_VAR_mozm_vbs4_pnnl
		;NMVOC_TRN = NMVOC_MAP_TRN_mozm_vbs4_pnnl

		print("wrfchem_scheme "+wrfchem_scheme+" not supported at the moment")
		exit()

	else if(wrfchem_scheme .eq. "cbmz_mos_htap")

		INORG_VAR = INORG_MAP_VAR_cbmz_mos_htap
		INORG_TRN = INORG_MAP_TRN_cbmz_mos_htap
		AERO_VAR  = AERO_MAP_VAR_cbmz_mos_htap
		AERO_TRN  = AERO_MAP_TRN_cbmz_mos_htap

		if(nmvoc_scheme .eq. "MACCITY")
		
			NMVOC_VAR = NMVOC_maccity_MAP_VAR_cbmz_mos_htap
			NMVOC_TRN = NMVOC_maccity_MAP_TRN_cbmz_mos_htap
			NMVOC_WGT = NMVOC_maccity_MOL_WGT_cbmz_mos_htap
					
		else if(nmvoc_scheme .eq. "EDGAR")
		
			NMVOC_VAR = NMVOC_edgar_MAP_VAR_cbmz_mos_htap
			NMVOC_TRN = NMVOC_edgar_MAP_TRN_cbmz_mos_htap
			NMVOC_WGT = NMVOC_edgar_MOL_WGT_cbmz_mos_htap
			nmvoc_scheme@use_intermediates = True		;;; set flag to use intermediate compounds during mapping of NMVOCs
						
		end if
		end if

	else if(wrfchem_scheme .eq. "cri_mos_edgar_htap")

		INORG_VAR = INORG_MAP_VAR_cri_mos_edgar_htap
		INORG_TRN = INORG_MAP_TRN_cri_mos_edgar_htap
		AERO_VAR  = AERO_MAP_VAR_cri_mos_edgar_htap
		AERO_TRN  = AERO_MAP_TRN_cri_mos_edgar_htap


		if(nmvoc_scheme .eq. "MACCITY")
		
			;NMVOC_VAR = NMVOC_maccity_MAP_VAR_cri_mos_edgar_htap
			;NMVOC_TRN = NMVOC_maccity_MAP_TRN_cri_mos_edgar_htap
			;NMVOC_WGT = NMVOC_maccity_MOL_WGT_cri_mos_edgar_htap

			print("wrfchem_scheme"+wrfchem_scheme+" not currently supported with nmvoc_scheme "+nmvoc_scheme)
			exit()

		else if(nmvoc_scheme .eq. "EDGAR")
		
			NMVOC_VAR = NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap
			NMVOC_TRN = NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap
			NMVOC_WGT = NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap
			
		end if
		end if

	else if(wrfchem_scheme .eq. "cbmz_mos_orig")

		INORG_VAR = INORG_MAP_VAR_cbmz_mos_orig
		INORG_TRN = INORG_MAP_TRN_cbmz_mos_orig
		AERO_VAR  = AERO_MAP_VAR_cbmz_mos_orig
		AERO_TRN  = AERO_MAP_TRN_cbmz_mos_orig

		if(nmvoc_scheme .eq. "MACCITY")
		
			NMVOC_VAR = NMVOC_maccity_MAP_VAR_cbmz_mos_orig
			NMVOC_TRN = NMVOC_maccity_MAP_TRN_cbmz_mos_orig
			NMVOC_WGT = NMVOC_maccity_MOL_WGT_cbmz_mos_orig
					
		else if(nmvoc_scheme .eq. "EDGAR")
		
			NMVOC_VAR = NMVOC_edgar_MAP_VAR_cbmz_mos_orig
			NMVOC_TRN = NMVOC_edgar_MAP_TRN_cbmz_mos_orig
			NMVOC_WGT = NMVOC_edgar_MOL_WGT_cbmz_mos_orig
			nmvoc_scheme@use_intermediates = True		;;; set flag to use intermediate compounds during mapping of NMVOCs


		end if
		end if
	else
	
		print("wrfchem_scheme "+wrfchem_scheme+" not recognised in procedure combine_emission_sectors (speciating_emissions_routines.ncl)")
		exit()

	end if
	end if
	end if
    end if
    
	;;; load the NMVOC information which is generic for all chemical schemes
	if(nmvoc_scheme .eq. "MACCITY")

			nmvoc_species       = maccity_species
			nmvoc_species_index = maccity_species_index
			nmvoc_groups        = maccity_groups
			nmvoc_sectors       = maccity_sectors
			nmvoc_mol_weights   = maccity_mol_weights

			nmvoc_scheme@molweights = "source"			;;; set flag to use MACCITY molecular weights for NMVOC calculations


	else if(nmvoc_scheme .eq. "EDGAR")

			nmvoc_species       = edgar_nmvoc_species
			nmvoc_species_index = edgar_nmvoc_species_index
			nmvoc_groups        = edgar_nmvoc_groups
			nmvoc_sectors       = edgar_nmvoc_sectors
			nmvoc_mol_weights   = edgar_nmvoc_mol_weights

			nmvoc_scheme@molweights = "destination"		;;; set flag to use final scheme molecular weights for NMVOC calculations

	end if
	end if
	
	;;; check to make sure we aren't using intermediates when we're also using fractional apportionment
	;if(nmvoc_scheme@use_intermediates .and. nmvoc_scheme@method .eq. "fraction")
	;	print("the use of NMVOC intermediates and fractional apportionment is not supported at this time")
	;	print("please set nmvoc_scheme@method = 'direct' instead")
	;	exit()
	;end if
	
	generate_scheme_emissions(INDIR, OUTDIR, fname, wrfchem_scheme, nmvoc_scheme, nox_frac, \
					INORG_VAR, INORG_TRN, AERO_VAR, AERO_TRN, NMVOC_VAR, NMVOC_TRN, NMVOC_WGT, \
					nmvoc_species, nmvoc_species_index, nmvoc_groups, nmvoc_sectors, nmvoc_mol_weights)




end ;;;;; combine_emission_sectors
