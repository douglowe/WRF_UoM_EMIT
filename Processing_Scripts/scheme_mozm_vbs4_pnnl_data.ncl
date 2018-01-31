;
;  Data for processing emissions for the mozm_vbs4_pnnl scheme
;
;  This file contains:
;		NMVOC_MW_mozm_vbs_pnnl
;			this lists the molecular weights for the NMVOC compounds of interest
;		INORG_MAP_VAR_mozm_vbs_pnnl
;			this notes which original emission variables the gas-phase emissions are based on
;		INORG_MAP_TRN_mozm_vbs_pnnl
;			this gives the scaling factor from the original to the new gas-phase emissions
;		AERO_MAP_VAR_mozm_vbs_pnnl
;			this notes which original emission variables the aerosol emissions are based on
;		AERO_MAP_TRN_mozm_vbs_pnnl
;			this gives the scaling factor from the original to the new aerosol emissions
;		NMVOC_MAP_VAR_mozm_vbs_pnnl
;			this notes which original emission variables the NMVOC emissions are based on
;		NMVOC_MAP_TRN_mozm_vbs_pnnl
;			this gives the scaling factor from the original to the new NMVOC emissions
;
;*********************************************
begin


;;;;; gas-phase data
INORG_MAP_VAR_mozm_vbs_pnnl = True
INORG_MAP_VAR_mozm_vbs_pnnl@E_CO 	= "CO"
INORG_MAP_VAR_mozm_vbs_pnnl@E_NO 	= "NOx"
INORG_MAP_VAR_mozm_vbs_pnnl@E_NO2 	= "NOx"
INORG_MAP_VAR_mozm_vbs_pnnl@E_SO2 	= "SO2"
INORG_MAP_VAR_mozm_vbs_pnnl@E_NH3 	= "NH3"
INORG_MAP_VAR_mozm_vbs_pnnl@E_HONO 	= "CO"
INORG_MAP_VAR_mozm_vbs_pnnl@E_SULF 	= "SO2"

INORG_MAP_TRN_mozm_vbs_pnnl = True
INORG_MAP_TRN_mozm_vbs_pnnl@E_CO 	= 1.0
INORG_MAP_TRN_mozm_vbs_pnnl@E_NO 	= -9999. 	; this will be replaced later with NOX_FRAC
INORG_MAP_TRN_mozm_vbs_pnnl@E_NO2 	= -9999.	; this will be replaced later with 1-NOX_FRAC
INORG_MAP_TRN_mozm_vbs_pnnl@E_SO2 	= 1.0
INORG_MAP_TRN_mozm_vbs_pnnl@E_NH3 	= 1.0
INORG_MAP_TRN_mozm_vbs_pnnl@E_HONO 	= 0.0
INORG_MAP_TRN_mozm_vbs_pnnl@E_SULF 	= 0.0


; Note it is assumed that OC emissions have already been converted to Org 
; (e.g. Org = 1.4*OC), PM2.5 is really the other inorganic component of PM2.5
; (= PM2.5 - Org - BC), and PM10 is the PM mass between 2.5 and 10 um (=PM10 - PM2.5)                   
AERO_MAP_VAR_mozm_vbs_pnnl = True
AERO_MAP_VAR_mozm_vbs_pnnl@E_PM25J	= "PM2_5"
AERO_MAP_VAR_mozm_vbs_pnnl@E_PM_10	= "PM10"
AERO_MAP_VAR_mozm_vbs_pnnl@E_NO3J	= "PM10"
AERO_MAP_VAR_mozm_vbs_pnnl@E_NO3C	= "PM10"
AERO_MAP_VAR_mozm_vbs_pnnl@E_SO4J	= "PM10"
AERO_MAP_VAR_mozm_vbs_pnnl@E_SO4C	= "PM10"
AERO_MAP_VAR_mozm_vbs_pnnl@E_ECJ	= "BC"
AERO_MAP_VAR_mozm_vbs_pnnl@E_ECC	= "BC"
AERO_MAP_VAR_mozm_vbs_pnnl@E_ORGJ	= "OC"
AERO_MAP_VAR_mozm_vbs_pnnl@E_ORGC	= "OC"
AERO_MAP_VAR_mozm_vbs_pnnl@E_CO_A	= "CO"
AERO_MAP_VAR_mozm_vbs_pnnl@E_CO_BB	= "CO"

AERO_MAP_TRN_mozm_vbs_pnnl = True
AERO_MAP_TRN_mozm_vbs_pnnl@E_PM25J	= 1.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_PM_10	= 1.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_NO3J	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_NO3C	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_SO4J	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_SO4C	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_ECJ	= 1.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_ECC	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_ORGJ	= 1.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_ORGC	= 0.0
AERO_MAP_TRN_mozm_vbs_pnnl@E_CO_A	= 1.0    ; converted from mol/km2/hr=>ug/m2/s in WRF-chem
AERO_MAP_TRN_mozm_vbs_pnnl@E_CO_BB	= 0.0



; Map of NMVOCs. Need to divide by the MW to give emissions in mols.             
NMVOC_MAP_VAR_mozm_vbs_pnnl = True
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_BIGALK	= (/"BUTA", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_BIGENE	= (/"BUTE", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C2H4  	= (/"ETHE", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C2H5OH	= (/"OALC", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C2H6  	= (/"ETHA", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C3H6  	= (/"PRPE", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C3H8  	= (/"PRPA", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_CH2O  	= (/"FORM", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_CH3CHO	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_ISOP  	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_CH3COCH3	= (/"ACET", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_CH3OH 	= (/"METH", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_MEK   	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_TOLUENE	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_BENZENE	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_XYLENE	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C10H16	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_C2H2  	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_GLY   	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_MACR  	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_MGLY  	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_MVK   	= "CO"
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_HCOOH 	= (/"", "NMVOC"/)
NMVOC_MAP_VAR_mozm_vbs_pnnl@E_CH3COOH	= (/"", "NMVOC"/)

NMVOC_MAP_TRN_mozm_vbs_pnnl = True
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_BIGALK	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_BIGENE	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C2H4  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C2H5OH	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C2H6  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C3H6  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C3H8  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_CH2O  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_CH3CHO	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_ISOP  	= 0.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_CH3COCH3	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_CH3OH 	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_MEK   	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_TOLUENE	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_BENZENE	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_XYLENE	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C10H16	= 0.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_C2H2  	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_GLY   	= 0.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_MACR  	= 0.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_MGLY  	= 0.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_MVK   	= 2.4e-4   ; from Borbon et al., 2013, see MOZART_MOSAIC_readme_july2014.pdf
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_HCOOH 	= 1.0
NMVOC_MAP_TRN_mozm_vbs_pnnl@E_CH3COOH	= 1.0




end
;*********************************************


