;
;  Data for processing emissions for the cri_mos_htap scheme
;
;  This file contains:
;		INORG_MAP_VAR_cri_mos_htap
;			this notes which original emission variables the gas-phase emissions are based on
;		INORG_MAP_TRN_cri_mos_htap
;			this gives the scaling factor from the original to the new gas-phase emissions
;		AERO_MAP_VAR_cri_mos_htap
;			this notes which original emission variables the aerosol emissions are based on
;		AERO_MAP_TRN_cri_mos_htap
;			this gives the scaling factor from the original to the new aerosol emissions
;		NMVOC_MAP_VAR_cri_mos_htap
;			this notes which original emission variables the NMVOC emissions are based on
;		NMVOC_MAP_TRN_cri_mos_htap
;			this gives the scaling factor from the original to the new NMVOC emissions
;
;*********************************************
begin



;;;;; inorganic gas-phase data
INORG_MAP_VAR_cri_mos_edgar_htap = True
INORG_MAP_VAR_cri_mos_edgar_htap@E_CO 	= "CO"
INORG_MAP_VAR_cri_mos_edgar_htap@E_NO 	= "NOx"
INORG_MAP_VAR_cri_mos_edgar_htap@E_NO2 	= "NOx"
INORG_MAP_VAR_cri_mos_edgar_htap@E_SO2 	= "SO2"
INORG_MAP_VAR_cri_mos_edgar_htap@E_NH3 	= "NH3"

INORG_MAP_TRN_cri_mos_edgar_htap = True
INORG_MAP_TRN_cri_mos_edgar_htap@E_CO 	= 1.0
INORG_MAP_TRN_cri_mos_edgar_htap@E_NO 	= -9999. 	; this will be replaced later with NOX_FRAC
INORG_MAP_TRN_cri_mos_edgar_htap@E_NO2 	= -9999.	; this will be replaced later with 1-NOX_FRAC
INORG_MAP_TRN_cri_mos_edgar_htap@E_SO2 	= 1.0
INORG_MAP_TRN_cri_mos_edgar_htap@E_NH3 	= 1.0


;;;;; aerosol data
; Note it is assumed that OC emissions have already been converted to Org 
; (e.g. Org = 1.4*OC), PM2.5 is the total mass for PM2.5, and PM10 is 
; total mass for PM10                   
AERO_MAP_VAR_cri_mos_edgar_htap = True
AERO_MAP_VAR_cri_mos_edgar_htap@E_BC_1		= "BC"
AERO_MAP_VAR_cri_mos_edgar_htap@E_EC_1_25		= "BC"
AERO_MAP_VAR_cri_mos_edgar_htap@E_EC_25_10	= "BC"
AERO_MAP_VAR_cri_mos_edgar_htap@E_OC_DOM		= "OC_DOM"
AERO_MAP_VAR_cri_mos_edgar_htap@E_OC_TRA		= "OC_TRA"
AERO_MAP_VAR_cri_mos_edgar_htap@E_OC_25_10	= "OC"
AERO_MAP_VAR_cri_mos_edgar_htap@E_PM25		= "PM2_5"
AERO_MAP_VAR_cri_mos_edgar_htap@E_OIN_25		= "PM2_5"
AERO_MAP_VAR_cri_mos_edgar_htap@E_OIN_10		= "PM10"


AERO_MAP_TRN_cri_mos_edgar_htap = True
AERO_MAP_TRN_cri_mos_edgar_htap@E_BC_1		= 1.0      ; Assume that all BC is in particles < 1 um
AERO_MAP_TRN_cri_mos_edgar_htap@E_EC_1_25		= 0.0
AERO_MAP_TRN_cri_mos_edgar_htap@E_EC_25_10	= 0.0      ; EDGAR emissions assume no BC above PM2.5
AERO_MAP_TRN_cri_mos_edgar_htap@E_OC_DOM		= 1.0
AERO_MAP_TRN_cri_mos_edgar_htap@E_OC_TRA		= 1.0
AERO_MAP_TRN_cri_mos_edgar_htap@E_OC_25_10	= 0.0      ; EDGAR emissions assume no OM above PM2.5
AERO_MAP_TRN_cri_mos_edgar_htap@E_PM25		= 1.0
AERO_MAP_TRN_cri_mos_edgar_htap@E_OIN_25		= 1.0   ; this will be modified by a calculation from PM2.5, OM and BC 
AERO_MAP_TRN_cri_mos_edgar_htap@E_OIN_10		= -9999.   ; this will be replaced by a calculation from PM10 and PM2.5





;;;;; organic gas-phase data
;
;  Below are the mappings of multiple NMVOC emission scheme databases to the specific
;  chemical input scheme that we are using.
;  
;  These will consist of 2 sets of information.
;
;     NMVOC_[nmvoc scheme]_MAP_VAR_[chem scheme]@[emiss var] = (/"[nmvoc var1]","[nmvoc var2]","[input var]"/)
;				This lists the NMVOC species matching a given emission species. 
;					[nmvoc scheme] - name of the input scheme (i.e. maccity, edgar, etc)
;					[chem scheme]  - name of the chemical emission scheme (i.e. cbmz_mos_htap)
;					[emiss var]    - name of the emission species to be created (i.e. E_PAR)
;                   [nmvoc var1/2] - names of the NMVOC species to be mapped to this emission species
;					[input var]    - name of the input variable we will fractionate (if needed - see other notes)
;

;;;;;;; EDGAR information ;;;;;;;;;;;;;;;;;;;
; Mapping information for NMVOC species
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap = True
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C2H6	 = (/"VOC02","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C3H8	 = (/"VOC03","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_NC4H10	 = (/"VOC04","VOC05","VOC06","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C2H4	 = (/"VOC07","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C3H6	 = (/"VOC08","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_TBUT2ENE= (/"VOC12","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C2H2	 = (/"VOC09","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_HCHO	 = (/"VOC21","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_CH3CHO	 = (/"VOC22","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C2H5CHO = (/"VOC22","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_KET	 = (/"VOC23","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_MEK	 = (/"VOC23","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_CH3OH	 = (/"VOC01","VOC19","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C2H5OH	 = (/"VOC01","VOC19","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_HCOOH	 = (/"VOC24","VOC18","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_CH3CO2H = (/"VOC24","VOC18","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_BENZENE = (/"VOC13","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_TOLUENE = (/"VOC14","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_OXYL	 = (/"VOC15","VOC16","VOC17","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_C5H8	 = (/"VOC10","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_APINENE = (/"VOC11","NMVOC"/)
NMVOC_edgar_MAP_VAR_cri_mos_edgar_htap@E_BPINENE = (/"VOC11","NMVOC"/)


; Scaling factors for NMVOC species
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap = True
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C2H6	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C3H8	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_NC4H10	 = (/1.0,1.0,1.0/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C2H4	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C3H6	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_TBUT2ENE= 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C2H2	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_HCHO	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_CH3CHO	 = 0.5
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C2H5CHO = 0.5
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_KET	 = 0.67
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_MEK	 = 0.33
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_CH3OH	 = (/0.2,0.2/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C2H5OH	 = (/0.8,0.8/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_HCOOH	 = (/0.5,0.5/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_CH3CO2H = (/0.5,0.5/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_BENZENE = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_TOLUENE = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_OXYL	 = (/1.0,1.0,1.0/)
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_C5H8	 = 1.0
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_APINENE = 0.75
NMVOC_edgar_MAP_TRN_cri_mos_edgar_htap@E_BPINENE = 0.25

; emission formation:
; C2H6 = v02
; C3H8 = v03
; NC4H10 = v04 + v05 + v06
; C2H4 = v07
; C3H6 = v08
; TBUT2ENE = v12
; C2H2 = v09
; HCHO = v21
; CH3CHO = v22
; C2H5CHO = v22
; KET = v23*0.67
; MEK = v23*0.33 
; CH3OH = v01*0.2 + v19*0.2
; C2H5OH = v01*0.8 + v19*0.8
; HCOOH = v24*0.5 + v18*0.5
; CH3CO2H = v24*0.5 + v18*0.5
; BENZENE = v13
; TOLUENE = v14
; OXYL = v15 + v16 + v17
; C5H8 = v10
; APINENE = 0.75
; BPINENE = 0.25

;;; speciation for EDGAR species to CRI emissions
; v01 (alcohols)  = CH3OH*0.2 + C2H5OH*0.8
; v02 (ethane)    = C2H6
; v03 (propane)   = C3H8
; v04 (butane)    = NC4H10
; v05 (pentane)   = NC4H10
; v06 (hexanes)   = NC4H10
; v07 (ethene)    = C2H4
; v08 (propene)   = C3H6
; v09 (ethyne)    = C2H2
; v10 (isoprene)  = C5H8
; v11 (monoterpenes) = APINENE*0.75 + BPINENE*0.25
; v12 (other alkenes)= TBUT2ENE
; v13 (benzene)   = BENZENE
; v14 (toluene)   = TOLUENE
; v15 (xylene)    = OXYL
; v16 (trimethylbenzenes) = OXYL
; v17 (other aromatics)   = OXYL
; v18 (esters)    = HCOOH*0.5 + CH3CO2H*0.5
; v19 (ethers)    = CH3OH*0.2 + C2H5OH*0.8
; v20 (chlorinated hydrocarbons - not used for CRI or CBMZ) 
; v21 (formaldehyde)    = HCHO
; v22 (other aldehydes) = C2H5CHO
; v23 (ketones)         = KET*0.67 + MEK*0.33
; v24 (alkanoic acids)  = HCOOH*0.5 + CH3CO2H*0.5
; v25 (other VOC's - not used for CRI or CBMZ)


; molecular weight for NMVOC species
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap = True
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C2H6	 = 30.07
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C3H8	 = 44.1
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_NC4H10	 = 58.12
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C2H4	 = 28.05
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C3H6	 = 42.08
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_TBUT2ENE= 56.11
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C2H2	 = 26.04
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_HCHO	 = 30.03
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_CH3CHO	 = 44.05
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C2H5CHO = 58.08  ;;; same as KET?
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_KET	 = 58.08  ;;; same as C2H5CHO?
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_MEK	 = 72.11
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_CH3OH	 = 32.0419
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C2H5OH	 = 46.0684
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_HCOOH	 = 46.0254
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_CH3CO2H = 60.052
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_BENZENE = 78.1118
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_TOLUENE = 92.1384
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_OXYL	 = 106.165
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_C5H8	 = 68.117
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_APINENE = 136.234
NMVOC_edgar_MOL_WGT_cri_mos_edgar_htap@E_BPINENE = 136.234




end
;*********************************************


