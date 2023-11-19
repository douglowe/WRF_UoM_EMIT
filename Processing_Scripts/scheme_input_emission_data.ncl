;
;  Data for the INPUT schemes.
;
;  This hard-codes the sector indexes to check for each emission species.
;
;  The hard-coding is necessary for split emission species (such as OC_DOM and OC_RES).
;  In theory it should not be necessary for any other species. However we will leave it
;  in, so that we can create warning messages in cases where there should be an emission
;  sector in the input file, but the user hasn't provided it for whatever reason.
;

begin


;;; EDGAR-HTAP input data

	emiss_cat_EDGAR_HTAP = ""
	;;;; define the sector indexes for each variable
	emiss_cat_EDGAR_HTAP@CO    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@NOx   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@SO2   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@NMVOC = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@BC    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@OC    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@PM2_5 = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@PM10  = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR_HTAP@NH3   = (/"IND","RES","TRA","AGR"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_EDGAR_HTAP@OC_DOM= (/"RES"/)
	emiss_cat_EDGAR_HTAP@OC_TRA= (/"POW","IND","TRA","SHP"/)

	; list of diurnal cycle matching emission sectors for EDGAR-HTAP
	emiss_cycle_EDGAR_HTAP_sectors = (/"POW","IND","RES","TRA","AGR","SHP"/)
	emiss_cycle_EDGAR_HTAP_sectors@POW = "POW"
	emiss_cycle_EDGAR_HTAP_sectors@IND = "IND"
	emiss_cycle_EDGAR_HTAP_sectors@RES = "RES" 
	emiss_cycle_EDGAR_HTAP_sectors@TRA = "TRA"
	emiss_cycle_EDGAR_HTAP_sectors@AGR = "AGR"
	emiss_cycle_EDGAR_HTAP_sectors@SHP = "SHP"



;;; IITM input data

	emiss_cat_IITM = ""
	;;;; define the sector indexes for each variable
	emiss_cat_IITM@CO    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_IITM@NOx   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_IITM@SO2   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_IITM@NMVOC = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_IITM@BC    = (/"POW","IND","RES","TRA","SHP","WBD"/)
	emiss_cat_IITM@OC    = (/"POW","IND","RES","TRA","SHP","WBD"/)
	emiss_cat_IITM@PM2_5 = (/"POW","IND","RES","TRA","SHP","WBD"/)
	emiss_cat_IITM@PM10  = (/"POW","IND","RES","TRA","SHP","WBD"/)
	emiss_cat_IITM@NH3   = (/"IND","RES","TRA","AGR"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_IITM@OC_DOM= (/"RES"/)
	emiss_cat_IITM@OC_TRA= (/"POW","IND","TRA","SHP","WBD"/)

	; list of diurnal cycle matching emission sectors for IITM
	emiss_cycle_IITM_sectors = (/"POW","IND","RES","TRA","AGR","SHP","WBD"/)
	emiss_cycle_IITM_sectors@POW = "POW"
	emiss_cycle_IITM_sectors@IND = "IND"
	emiss_cycle_IITM_sectors@RES = "RES" 
	emiss_cycle_IITM_sectors@TRA = "TRA"
	emiss_cycle_IITM_sectors@AGR = "AGR"
	emiss_cycle_IITM_sectors@SHP = "SHP"
	emiss_cycle_IITM_sectors@WBD = "WBD"


;;; EDGAR-HTAP input data

	emiss_cat_EDGAR_AP_V432 = ""
	;;;; define the sector indexes for each variable
	emiss_cat_EDGAR_AP_V432@CO    = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","NFE","FOO_PAP","AWB","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@NOx   = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"CHE","IRO","NFE","FOO_PAP","MNM","AGS","AWB","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@SO2   = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","NFE","FOO_PAP","AWB","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@NMVOC = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","FOO_PAP","PRU_SOL","AWB","SWD_LDF","WWT","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@BC    = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","NFE","FOO_PAP","AWB","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@OC    = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"AWB","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@PM2_5 = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","NFE","FOO_PAP","PRU_SOL","MNM","AGS","AWB",\
									"SWD_LDF","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@PM10  = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","IRO","NFE","FOO_PAP","NEU","PRU_SOL","MNM","AGS","AWB",\
									"SWD_LDF","SWD_INC","FFF"/)
	emiss_cat_EDGAR_AP_V432@NH3   = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO","NMM",\
									"CHE","PRU_SOL","MNM","AGS","AWB","SWD_LDF","WWT","SWD_INC"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_EDGAR_AP_V432@OC_DOM= (/"RCO","SWD_INC"/)
	emiss_cat_EDGAR_AP_V432@OC_TRA= (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship",\
									"AWB","FFF"/)


	; list of diurnal cycle matching emission sectors for EDGAR AP v432
	emiss_cycle_EDGAR_AP_V432_sectors = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO",\
											"PRO","NMM","CHE","IRO","NFE","FOO_PAP","NEU","PRU_SOL",\
											"MNM","AGS","AWB","SWD_LDF","WWT","SWD_INC","FFF"/)
	emiss_cycle_EDGAR_AP_V432_sectors@ENE 		= "POW"
	emiss_cycle_EDGAR_AP_V432_sectors@REF_TRF 	= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@IND 		= "IND" 
	emiss_cycle_EDGAR_AP_V432_sectors@TRO 		= "TRA"
	emiss_cycle_EDGAR_AP_V432_sectors@TNR_Other = "TRA"
	emiss_cycle_EDGAR_AP_V432_sectors@TNR_Ship  = "SHP"
	emiss_cycle_EDGAR_AP_V432_sectors@RCO 		= "RES"
	emiss_cycle_EDGAR_AP_V432_sectors@PRO 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@NMM 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@CHE 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@IRO 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@NFE 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@FOO_PAP 	= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@NEU 		= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@PRU_SOL 	= "IND"
	emiss_cycle_EDGAR_AP_V432_sectors@MNM 		= "AGR"
	emiss_cycle_EDGAR_AP_V432_sectors@AGS 		= "AGR"
	emiss_cycle_EDGAR_AP_V432_sectors@AWB 		= "AGR"
	emiss_cycle_EDGAR_AP_V432_sectors@SWD_LDF 	= "RES"
	emiss_cycle_EDGAR_AP_V432_sectors@WWT 		= "RES"
	emiss_cycle_EDGAR_AP_V432_sectors@SWD_INC 	= "RES"
	emiss_cycle_EDGAR_AP_V432_sectors@FFF		= "IND"



;;; SANH, with added HCl, input data

	emiss_cat_SANH_HCL = ""
	;;;; define the sector indexes for each variable
	emiss_cat_SANH_HCL@CO    = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"PRO","AWB","SWD_INC"/)
	emiss_cat_SANH_HCL@NOx   = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"PRO","AWB","SWD_INC","MNM","AGS"/)
	emiss_cat_SANH_HCL@SO2   = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"PRO","AWB","SWD_INC"/)
	emiss_cat_SANH_HCL@NMVOC = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"PRO","AWB","SWD_INC","MNM","AGS"/)
	emiss_cat_SANH_HCL@BC    = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"AWB","SWD_INC","PRO"/)
	emiss_cat_SANH_HCL@OC    = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"AWB","SWD_INC","PRO"/)
	emiss_cat_SANH_HCL@PM2_5 = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"AWB","SWD_INC","PRO","MNM","AGS"/)
	emiss_cat_SANH_HCL@PM10  = (/"ENE","IND","TRO","TNR_Other","RCO",\
									"AWB","SWD_INC","PRO","MNM","AGS"/)
	emiss_cat_SANH_HCL@NH3   = (/"ENE","IND","TRO","TNR_Other","TNR_Ship","RCO",\
									"AWB","MNM","AGS"/)
	emiss_cat_SANH_HCL@HCL   = (/"ENE","IND","RCO","AGS","AWB","SWD_INC"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_SANH_HCL@OC_DOM= (/"RCO","SWD_INC"/)
	emiss_cat_SANH_HCL@OC_TRA= (/"ENE","IND","TRO","TNR_Other","TNR_Ship",\
									"AWB","PRO"/)


	; list of diurnal cycle matching emission sectors for EDGAR AP v432
	emiss_cycle_SANH_HCL_sectors = (/"ENE","REF_TRF","IND","TRO","TNR_Other","TNR_Ship","RCO",\
											"PRO","NMM","CHE","IRO","NFE","FOO_PAP","NEU","PRU_SOL",\
											"MNM","AGS","AWB","SWD_LDF","WWT","SWD_INC","FFF"/)
	emiss_cycle_SANH_HCL_sectors@ENE 		= "POW"
	emiss_cycle_SANH_HCL_sectors@REF_TRF 	= "IND"
	emiss_cycle_SANH_HCL_sectors@IND 		= "IND" 
	emiss_cycle_SANH_HCL_sectors@TRO 		= "TRA"
	emiss_cycle_SANH_HCL_sectors@TNR_Other = "TRA"
	emiss_cycle_SANH_HCL_sectors@TNR_Ship  = "SHP"
	emiss_cycle_SANH_HCL_sectors@RCO 		= "RES"
	emiss_cycle_SANH_HCL_sectors@PRO 		= "IND"
	emiss_cycle_SANH_HCL_sectors@NMM 		= "IND"
	emiss_cycle_SANH_HCL_sectors@CHE 		= "IND"
	emiss_cycle_SANH_HCL_sectors@IRO 		= "IND"
	emiss_cycle_SANH_HCL_sectors@NFE 		= "IND"
	emiss_cycle_SANH_HCL_sectors@FOO_PAP 	= "IND"
	emiss_cycle_SANH_HCL_sectors@NEU 		= "IND"
	emiss_cycle_SANH_HCL_sectors@PRU_SOL 	= "IND"
	emiss_cycle_SANH_HCL_sectors@MNM 		= "AGR"
	emiss_cycle_SANH_HCL_sectors@AGS 		= "AGR"
	emiss_cycle_SANH_HCL_sectors@AWB 		= "AGR"
	emiss_cycle_SANH_HCL_sectors@SWD_LDF 	= "RES"
	emiss_cycle_SANH_HCL_sectors@WWT 		= "RES"
	emiss_cycle_SANH_HCL_sectors@SWD_INC 	= "RES"
	emiss_cycle_SANH_HCL_sectors@FFF		= "IND"




end