;
;  General routines needed for applying vertical distributions to 
;  our emissions data.
;  
;   Contents:
;
;		create_vertical_emission_files
;
;
;		impose_vertical_distribution
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"     ; include standard resources
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./emission_script_data.ncl"







undef("impose_vertical_distribution")
procedure impose_vertical_distribution(OUTFILE:file, var_name:string, invar_data:numeric, \
											orig_sectors:string, vert_sectors:string)
local outvar, vs, vdist
begin

	; get the variable, to use as a template for processing
	outvar := OUTFILE->$var_name$

	; determine which vertical scheme to use
	vs = ""
	do ii = 0, dimsizes(orig_sectors)-1
		if(isStrSubset(var_name,orig_sectors(ii)))
			vs = vert_sectors(ii)
		end if
	end do ; ii in orig_sectors	
	
	; only apply a vertical distribution if we have a scheme to use
	if(.not.(vs.eq.""))
		vdist = Vert_Dist@$vs$
		
		do ii = 0, Vert_Dist@Number_of_Layers - 1
			
			outvar(:,ii,:,:) = invar_data(:,0,:,:) * vdist(ii)
		
		end do ; ii in number of layers 
		
	else
		print("no emission category recognised for emission variable "+var_name)
		print("  all emissions will be put into the lowest layer")
		
		outvar = 0.0
		
		outvar(:,0,:,:) = invar_data(:,0,:,:)
		
	end if

	;;; copy data to the output file
	OUTFILE->$var_name$ = outvar
	

end




undef("create_vertical_emission_files")
procedure create_vertical_emission_files(INDIR:string, OUTDIR:string, \
										fname:string, scheme:string, \
										orig_sectors:string, vert_sectors:string)
local INFILE, OUTFILE, dim_sizes, dim_names, dim_Unlim, dim_new_sizes, \
		input_var, var_num
begin


	;;; open file we'll be copying the global attributes from
	INFILE = addfile(INDIR+scheme@$fname$+".nc","r")


	;;; check that OUTDIR exists - if not then create it
	system("if ! test -d  "+OUTDIR+" ; then mkdir "+OUTDIR+"; fi")

	;;; ensure that we don't accidentally overwrite preexisting files
	if(isfilepresent(OUTDIR+scheme@$fname$))
		system("mv "+OUTDIR+scheme@$fname$+" "+OUTDIR+scheme@$fname$+".backup")
	end if
	;;; delete any broken files from previous attempts
	if(isfilepresent(OUTDIR+scheme@$fname$+".nc"))
		system("rm "+OUTDIR+scheme@$fname$+".nc")
	end if

	;;; open the new files that we wish to create
	;;;   NOTE - NCL determines the format of the file by the file extension.
	;;;          We can't create a file without a file extension, so these 
	;;;          intermediates will have a ".nc" at the end of their file name.
	OUTFILE = addfile(OUTDIR+scheme@$fname$+".nc","c")

	;;; copy the global attributes from the original file to the new files
	copy_VarAtts(INFILE,OUTFILE)


	;;; get the dimension names and sizes from the input file
	dim_sizes = getfiledimsizes(INFILE)
	dim_names = getvardims(INFILE)

	;;; set all dimensions as Limited
	dim_Unlim = new(dimsizes(dim_sizes),logical)
	dim_Unlim(:) = False
	;;; now find the Time dimension, and set that to Unlimited
	dim_Unlim(ind(dim_names.eq."Time"))   = True

	;;; replace the size of the zdim variable with our chosen emission grid size
	dim_new_sizes = dim_sizes
	dim_new_sizes(ind(dim_names.eq."emissions_zdim_stag")) = Vert_Dist@Number_of_Layers

	;;; apply these dimensions to the output files
	filedimdef( OUTFILE, dim_names, dim_new_sizes, dim_Unlim )

	;;; copy common variables
	xlon   = INFILE->XLONG
	xlat   = INFILE->XLAT
	times  = INFILE->Times
	
    filevardef(OUTFILE, "XLAT" ,typeof(xlat) ,getvardims(xlat))                     
    filevardef(OUTFILE, "XLONG",typeof(xlon) ,getvardims(xlon))                          
    filevardef(OUTFILE, "Times",typeof(times) ,getvardims(times))                          
	
    filevarattdef(OUTFILE,"XLAT"  ,xlat)
    filevarattdef(OUTFILE,"XLONG" ,xlon)
    filevarattdef(OUTFILE,"Times" ,times)

	OUTFILE->XLAT  = (/xlat/)
	OUTFILE->XLONG = (/xlon/)
	OUTFILE->Times = (/times/)
	
	if(isfilevar(INFILE,"TZ_Offset"))
		;;; create a variable for carrying timezone offset information
		tz_off = INFILE->TZ_Offset
		filevardef(OUTFILE, "TZ_Offset", "float", Var_Dims(2:3))                     
		filevarattdef(OUTFILE, "TZ_Offset", TZ_Att)
		OUTFILE->TZ_Offset = (/tz_off/)
	end if

	;;; get a list of the variables in the input file
	input_vars = getfilevarnames(INFILE)
	var_num = dimsizes(input_vars)

	;;; loop through the variables in the input file
	do ivar = 0, var_num-1

		; pull out the variable name
		var_name := input_vars(ivar)
	
		;;; filter for emissions data - assuming that they start with "E_" 
		if(isStrSubset(var_name,"E_"))

			; load input data
			invar_data := INFILE->$var_name$

			; check units to double check that this is an emission variable!!!
			if(invar_data@units .eq. "ug m^-2 s^-1" .or. invar_data@units .eq. "mol km^-2 hr^-1")
			
				; create the variable in the output file
				filevardef(OUTFILE, var_name, typeof(invar_data), Var_Dims)
				filevarattdef(OUTFILE, var_name, invar_data)


			else 
				print(" units of "+invar_data@units+" for input variable "+input_vars(ivar)+" not recognised")
				print("          so skipping this variable")
			end if

	
	
		end if ; var_name contains "E_"
	
	end do
	
	; close outfile
	delete(OUTFILE)
	
	
	;;;;; reopen outfile in write mode
	; 
	;   We do this because writing data into the netcdf file while it is in "create"
	;   mode is *massively* inefficient (taking >100 times longer to run). 
	;   It is far better to create the file, with all variables inside it, close it, 
	;   then reopen in write mode to add the required data.
	;
	OUTFILE = addfile(OUTDIR+scheme@$fname$+".nc","w")
	

	;;; loop through the variables in the input file
	do ivar = 0, var_num-1

		; pull out the variable name
		var_name := input_vars(ivar)
	
		;;; filter for emissions data - assuming that they start with "E_" 
		if(isStrSubset(var_name,"E_"))

			; load input data
			invar_data := INFILE->$var_name$

			; check units to double check that this is an emission variable!!!
			if(invar_data@units .eq. "ug m^-2 s^-1" .or. invar_data@units .eq. "mol km^-2 hr^-1")
			
				; impose a vertical distribution on the data, and save to the output file
				impose_vertical_distribution(OUTFILE,var_name,invar_data,orig_sectors,vert_sectors)


			else 
				print(" units of "+invar_data@units+" for input variable "+input_vars(ivar)+" not recognised")
				print("          so skipping this variable")
			end if

	
	
		end if ; var_name contains "E_"
	
	end do

				
	;;; rename the created files in order to match WRF-Chem convention
	system("mv "+OUTDIR+scheme@$fname$+".nc "+OUTDIR+scheme@$fname$)
	

end


undef("apply_vertical_distributions")
procedure apply_vertical_distributions(INDIR:string,OUTDIR:string,fname:string,wrfchem_scheme:string,nmvoc_scheme:string)
local orig_sectors, vert_sectors
begin

	;;; processing the standard emission data
	create_vertical_emission_files(INDIR, OUTDIR, fname, wrfchem_scheme, emiss_sector, emiss_sector)


	;;; setup processing the nmvoc emission data
	if(nmvoc_scheme.eq."MACCITY")
	
		orig_sectors = maccity_sectors
		vert_sectors = maccity_groups

	else if(nmvoc_scheme.eq."EDGAR")

		orig_sectors = edgar_nmvoc_sectors
		vert_sectors = edgar_nmvoc_groups

	end if
	end if

	;;; processing the nmvoc emission data
	create_vertical_emission_files(INDIR,OUTDIR,fname,nmvoc_scheme,orig_sectors,vert_sectors)


end


