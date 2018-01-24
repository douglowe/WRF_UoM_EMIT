;
;  Data for the INPUT schemes.
;
;
;

begin


;;; EDGAR input data

	emiss_cat_EDGAR = ""
	;;;; define the sector indexes for each variable
	emiss_cat_EDGAR@CO    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@NOx   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@SO2   = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@NMVOC = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@BC    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@OC    = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@PM2_5 = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@PM10  = (/"POW","IND","RES","TRA","SHP"/)
	emiss_cat_EDGAR@NH3   = (/"IND","RES","TRA","AGR"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_EDGAR@OC_DOM= (/"RES"/)
	emiss_cat_EDGAR@OC_TRA= (/"POW","IND","TRA","SHP"/)



;;; IITM input data

	emiss_cat_IITM = ""
	;;;; define the sector indexes for each variable
	emiss_cat_IITM@CO    = (/"POW","IND","RES","TRA"/)
	emiss_cat_IITM@NOx   = (/"POW","IND","RES","TRA"/)
	emiss_cat_IITM@SO2   = (/"POW","IND","RES","TRA"/)
	emiss_cat_IITM@NMVOC = (/"POW","IND","RES","TRA"/)
	emiss_cat_IITM@BC    = (/"POW","IND","RES","TRA","WBD"/)
	emiss_cat_IITM@OC    = (/"POW","IND","RES","TRA","WBD"/)
	emiss_cat_IITM@PM2_5 = (/"POW","IND","RES","TRA","WBD"/)
	emiss_cat_IITM@PM10  = (/"POW","IND","RES","TRA","WBD"/)
	emiss_cat_IITM@NH3   = (/"AGR"/)
	; Definitions for DOM (domestic) and TRA (traffic) are taken from our original speciation for the RONOCO work
	;           In the long term we need to think about how we want to split these (especially when we're working
	;           with the individual VBS emission groups)
	emiss_cat_IITM@OC_DOM= (/"RES"/)
	emiss_cat_IITM@OC_TRA= (/"POW","IND","TRA","WBD"/)





end