;   Script for taking emission data from 
;   EDGAR sources and turn them into 
;   WRF-Chem input files.
;
;


;*********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "./diurnal_cycle_routines.ncl"
load "./preprocess_emissions_routines.ncl"
load "./speciating_emissions_routines.ncl"
load "./vertical_distribution_routines.ncl"
; Hard coded data will be loaded from these scripts

;*********************************************
begin


;==============================================================================
;Define working directories:
;rootdir = "/Volumes/Odin/emissions_files/YRD_emission_generating/example_code/"
rootdir   = "../" 
SOURCEDIR = rootdir+"emission_source_files/"
DIUDIR    = rootdir+"intermediate_files/DIUDir/"
VERTDIR   = rootdir+"intermediate_files/VERTDir/"
OUTDIR    = rootdir+"final_output/BASEDir/"
;==============================================================================

; select month & year
month = "07"
year  = "2015"

; select the model domains
domains = (/"d01","d02","d03","d04"/)

; set the fraction of NOx that is NO  (NO2 fraction will be 1-nox_frac)
nox_frac = 0.9

; set the OC -> OM scale up that we will use
oc_om_scale = 1.4

; decide which wrf-chem scheme we're working to
wrfchem_scheme = "cri_mos_edgar_htap"
;wrfchem_scheme = "fail!"

; choice of NMVOC speciation scheme to use
nmvoc_scheme = "EDGAR"
;
;     method --- decides on the use of the scheme
;              "fraction" = use the chemical species to determine mass 
;								fractionation of lumped NMVOC emission
;              "direct"   = directly use these chemical species to build 
;								the NMVOC emissions
;
nmvoc_scheme@method = "direct"


; switch for choosing how to calculate the time offset from UTC,
;  if it is False then just use UTC. If True then use these options:
;
;   method --- decides how to determine offset
;			"fixed"     = use a single value (given by the attributes)
;   		"timezones" = use timezone maps to calculate the offset (all
;						   emissions at sea are assumed to be UTC still)
;   
;   fixed_offset --- if using "fixed" method this gives the offset from UTC
;
;   daylightsaving --- if using "timezones", and this is True, then we
;                      will use (where applicable) the winter daylight
;                      saving offset.
;


UTC_offset = True
UTC_offset@method = "timezones"
UTC_offset@fixed_offset = 8		; this is for China
;UTC_offset@fixed_offset = 0	; this is for UK
UTC_offset@daylightsaving = False	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; control what we're going to do ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STEP1_create_diurnal_cycle_and_prescaling 	= True
regional_modification_of_emissions  		= False
STEP2_apply_vertical_power_emissions 		= True
use_vertical_power_emission_files 			= True
STEP3_create_emissions_for_WRF_Chem 		= True
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Information for regional modification of emissions ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; min and max latitude data for masking emissions
regional_modification_of_emissions@latitude_limits = (/29.0,32.0/)
; min and max longitude data for masking emissions
regional_modification_of_emissions@longitude_limits = (/118.0,125.0/)
; list of variables for masking (use full name)
regional_modification_of_emissions@vars_mask = (/"E_NOx_ANT_TRA","E_SO2_ANT_IND"/)
; list of scaling factor to apply to emissions
regional_modification_of_emissions@vars_scale = (/0.0,50.0/)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; END OF CONFIGURATION CODE, START OF OPERATIONAL CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;; checks to make sure we're not going anything stupid

;; check our NMVOC scheme
if(.not. isStrSubset(available_nmvoc_schemes,nmvoc_scheme))
	print("Scheme '"+nmvoc_scheme+"' is unsupported - check 'available_nmvoc_schemes' in emission_script_data.ncl to see what is supported")
	exit()
end if

;; check scheme we're going to produce
if(.not. isStrSubset(available_schemes,wrfchem_scheme))
	print("Scheme '"+wrfchem_scheme+"' is unsupported - check 'available_schemes' in emission_script_data.ncl to see what is supported")
	exit()
end if








;;;;; domain loop
do idom = 0, dimsizes(domains)-1
	
	dom = domains(idom)
	
	;;;;; month loop

		;;;;; set the names of the general emission files that we wish to process 
		wrfchem_scheme@fname1 = "wrfchemi_00z_"+dom+"_"+year+"_"+month
		wrfchem_scheme@fname2 = "wrfchemi_12z_"+dom+"_"+year+"_"+month
		
		;;;;; NMVOC input file(s) - kept in SOURCEDIR 
		nmvoc_scheme@fname1 = "wrfchemi_00z_NMVOC_"+nmvoc_scheme+"_"+dom+"_"+year+"_"+month
		nmvoc_scheme@fname2 = "wrfchemi_12z_NMVOC_"+nmvoc_scheme+"_"+dom+"_"+year+"_"+month

		;;;;; creating diurnal cycle data and preprocess some emissions (OC->OM, and checking PM emissions)
		if(STEP1_create_diurnal_cycle_and_prescaling)
			print("==== Preparing the emission files ====")
			;;;;; copy the main emission source files into place
			emission_file_setup(SOURCEDIR,DIUDIR,wrfchem_scheme)

			;;;;; impose a diurnal cycle onto the data
			print("== Imposing diurnal cycle information onto emissions ==")
			impose_diurnal_cycle(DIUDIR,wrfchem_scheme,UTC_offset)
			
			;;;;; preprocess the required emissions
			print("== Preprocessing emissions ==")
			emission_preprocess(DIUDIR,wrfchem_scheme,oc_om_scale,regional_modification_of_emissions)

			
			;;;;; working on the NMVOC data files ;;;;;;
			
			;;;;; copy the NMVOC emission source files into place
			emission_file_setup(SOURCEDIR,DIUDIR,nmvoc_scheme)

			;;; if we are using "direct" method for NMVOC emissions then perform the same process for these too
			if(nmvoc_scheme@method .eq. "direct")			
				;;;;; impose a diurnal cycle onto the data
				print("== Imposing diurnal cycle information onto NMVOC emissions ==")
				impose_nmvoc_diurnal_cycle(DIUDIR,UTC_offset,wrfchem_scheme,nmvoc_scheme)

				;;;;; preprocess the required emissions
				print("== Preprocessing NMVOC emissions ==")
				emission_nmvoc_preprocess(DIUDIR,nmvoc_scheme,regional_modification_of_emissions)
			end if
			
		end if
		;;;;; end creating diurnal cycle data and preprocess some emissions (OC->OM, and checking PM emissions)



		;;;;; if applying vertical power emissions
		if(STEP2_apply_vertical_power_emissions)
			print("==== Applying a vertical distribution to the emissions ====")

			;;;;; creating new emission files (with increased vertical layers)
			;;;;; and impose a vertical distribution for all inputs
			apply_vertical_distributions(DIUDIR,VERTDIR,"fname1",wrfchem_scheme,nmvoc_scheme)
			apply_vertical_distributions(DIUDIR,VERTDIR,"fname2",wrfchem_scheme,nmvoc_scheme)

		end if
		;;;;; end applying vertical power emissions


		;;;;; if speciating the emissions for WRF-Chem
		if(STEP3_create_emissions_for_WRF_Chem)
			print("==== Creating the Emissions for WRFChem ====")
			;;; check for final directory, create it if it doesn't exist
			if(.not.fileexists(OUTDIR))
				print("== Creating Final Directory: "+OUTDIR)
				system("mkdir -p "+OUTDIR)
			end if


			;;;;; decide which input files we should use
			if(use_vertical_power_emission_files)
				print("== Using multi-layered emission files. ==")
				PROCDIR = VERTDIR
			else
				print("== Using single layered emission files. ==")
				PROCDIR = DIUDIR
			end if


			;;;;; creating new emission files
			print("== Creating new emission files ==")
			create_emission_files(PROCDIR,OUTDIR,"fname1",wrfchem_scheme)
			create_emission_files(PROCDIR,OUTDIR,"fname2",wrfchem_scheme)
		
			;;;;; combine emission sectors, and speciate NMVOC emissions
			print("== Combining emission sectors for first file ==")
			combine_emission_sectors(PROCDIR,OUTDIR,"fname1",wrfchem_scheme,nmvoc_scheme,nox_frac)
			print("== Combining emission sectors for second file ==")
			combine_emission_sectors(PROCDIR,OUTDIR,"fname2",wrfchem_scheme,nmvoc_scheme,nox_frac)
		
	
	
		end if
		;;;;; end speciating the emissions for WRF-Chem


	;;;;; end month loop
end do
;;;;; end domain loop


end
;*********************************************
