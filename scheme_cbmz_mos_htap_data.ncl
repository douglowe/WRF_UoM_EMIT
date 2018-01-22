;
;  Data for processing emissions for the cbmz_mos_htap scheme
;
;  This file contains:
;		INORG_MAP_VAR_cbmz_mos_htap
;			this notes which original emission variables the gas-phase emissions are based on
;		INORG_MAP_TRN_cbmz_mos_htap
;			this gives the scaling factor from the original to the new gas-phase emissions
;		AERO_MAP_VAR_cbmz_mos_htap
;			this notes which original emission variables the aerosol emissions are based on
;		AERO_MAP_TRN_cbmz_mos_htap
;			this gives the scaling factor from the original to the new aerosol emissions
;		NMVOC_MAP_VAR_cbmz_mos_htap
;			this notes which original emission variables the NMVOC emissions are based on
;		NMVOC_MAP_TRN_cbmz_mos_htap
;			this gives the scaling factor from the original to the new NMVOC emissions
;
;*********************************************
begin



;;;;; inorganic gas-phase data
INORG_MAP_VAR_cbmz_mos_htap = True
INORG_MAP_VAR_cbmz_mos_htap@E_CO 	= "CO"
INORG_MAP_VAR_cbmz_mos_htap@E_NO 	= "NOx"
INORG_MAP_VAR_cbmz_mos_htap@E_NO2 	= "NOx"
INORG_MAP_VAR_cbmz_mos_htap@E_SO2 	= "SO2"
INORG_MAP_VAR_cbmz_mos_htap@E_NH3 	= "NH3"

INORG_MAP_TRN_cbmz_mos_htap = True
INORG_MAP_TRN_cbmz_mos_htap@E_CO 	= 1.0
INORG_MAP_TRN_cbmz_mos_htap@E_NO 	= -9999. 	; this will be replaced later with NOX_FRAC
INORG_MAP_TRN_cbmz_mos_htap@E_NO2 	= -9999.	; this will be replaced later with 1-NOX_FRAC
INORG_MAP_TRN_cbmz_mos_htap@E_SO2 	= 1.0
INORG_MAP_TRN_cbmz_mos_htap@E_NH3 	= 1.0


;;;;; aerosol data
; Note it is assumed that OC emissions have already been converted to Org 
; (e.g. Org = 1.4*OC), PM2.5 is the total mass for PM2.5, and PM10 is 
; total mass for PM10                   
AERO_MAP_VAR_cbmz_mos_htap = True
AERO_MAP_VAR_cbmz_mos_htap@E_BC_1		= "BC"
AERO_MAP_VAR_cbmz_mos_htap@E_EC_1_25	= "BC"
AERO_MAP_VAR_cbmz_mos_htap@E_EC_25_10	= "BC"
AERO_MAP_VAR_cbmz_mos_htap@E_OC_DOM		= "OC_DOM"
AERO_MAP_VAR_cbmz_mos_htap@E_OC_TRA		= "OC_TRA"
AERO_MAP_VAR_cbmz_mos_htap@E_OC_25_10	= "OC"
AERO_MAP_VAR_cbmz_mos_htap@E_PM25		= "PM2_5"
AERO_MAP_VAR_cbmz_mos_htap@E_OIN_25		= "PM2_5"
AERO_MAP_VAR_cbmz_mos_htap@E_OIN_10		= "PM10"


AERO_MAP_TRN_cbmz_mos_htap = True
AERO_MAP_TRN_cbmz_mos_htap@E_BC_1		= 1.0      ; Assume that all BC is in particles < 1 um
AERO_MAP_TRN_cbmz_mos_htap@E_EC_1_25	= 0.0
AERO_MAP_TRN_cbmz_mos_htap@E_EC_25_10	= 0.0      ; EDGAR emissions assume no BC above PM2.5
AERO_MAP_TRN_cbmz_mos_htap@E_OC_DOM		= 1.0
AERO_MAP_TRN_cbmz_mos_htap@E_OC_TRA		= 1.0
AERO_MAP_TRN_cbmz_mos_htap@E_OC_25_10	= 0.0      ; EDGAR emissions assume no OM above PM2.5
AERO_MAP_TRN_cbmz_mos_htap@E_PM25		= 1.0
AERO_MAP_TRN_cbmz_mos_htap@E_OIN_25		= 1.0   ; this will be modified by a calculation from PM2.5, OM and BC 
AERO_MAP_TRN_cbmz_mos_htap@E_OIN_10		= -9999.   ; this will be replaced by a calculation from PM10 and PM2.5


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
NMVOC_edgar_MAP_VAR_cbmz_mos_htap = True
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_ETH		= (/"ETH_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_PAR		= (/"C3H8_INT","NC4H10_4_INT","NC4H10_5_INT",\
												"NC4H10_6_INT","C3H6_INT","C2H2_INT",\
												"TBUT2ENE_INT","BENZENE_INT","XYL_2_INT",\
												"XYL_3_INT","MEK_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_ISO		= (/"ISO_INT","APINENE_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_HC3		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_HC5		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_HC8		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_XYL		= (/"XYL_1_INT","XYL_2_INT","XYL_3_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_OL2		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_OLT		= (/"C3H6_INT","TBUT2ENE_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_OLI		= (/"TBUT2ENE_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_TOL		= (/"BENZENE_INT","TOL_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_CSL		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_HCHO	= (/"HCHO_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_ALD		= (/"ALD_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_KET		= (/"KET_INT","MEK_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_ORA2	= (/"ORA2_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_CH3OH	= (/"CH3OH_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_C2H5OH	= (/"C2H5OH_INT","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@E_C2H4    = (/"C2H4_INT","NMVOC"/)

NMVOC_edgar_MAP_VAR_cbmz_mos_htap@ETH_INT		= "VOC02"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@C3H8_INT		= "VOC03"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@NC4H10_4_INT	= "VOC04"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@NC4H10_5_INT	= "VOC05"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@NC4H10_6_INT	= "VOC06"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@C3H6_INT		= "VOC08"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@C2H2_INT		= "VOC09"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@TBUT2ENE_INT	= "VOC12"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@BENZENE_INT	= "VOC13"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@XYL_2_INT		= "VOC16"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@XYL_3_INT		= "VOC17"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@MEK_INT		= "VOC23"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@ISO_INT		= "VOC10"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@APINENE_INT	= "VOC11"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@XYL_1_INT		= "VOC15"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@TOL_INT		= "VOC14"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@HCHO_INT		= "VOC21"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@ALD_INT		= "VOC22"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@KET_INT		= "VOC23"
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@ORA2_INT		= (/"VOC18","VOC24"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@CH3OH_INT		= (/"VOC01","VOC19"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@C2H5OH_INT	= (/"VOC01","VOC19"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap@C2H4_INT		= "VOC07"



; Scaling factors for NMVOC species
NMVOC_edgar_MAP_TRN_cbmz_mos_htap = True
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_ETH		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_PAR		= (/3.0, 4.0, 5.0, 6.0, 1.0, \
												2.0, 1.0, -1.0, 1.0, 1.0, 1.0 /)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_ISO		= (/1.0, 2.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_HC3		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_HC5		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_HC8		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_XYL		= (/1.0, 1.0, 1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_OL2		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_OLT		= (/1.0, 1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_OLI		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_TOL		= (/1.0, 1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_CSL		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_HCHO	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_ALD		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_KET		= (/1.0, 1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_ORA2	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_CH3OH	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_C2H5OH  = 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@E_C2H4    = 1.0

NMVOC_edgar_MAP_TRN_cbmz_mos_htap@ETH_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@C3H8_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@NC4H10_4_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@NC4H10_5_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@NC4H10_6_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@C3H6_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@C2H2_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@TBUT2ENE_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@BENZENE_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@XYL_2_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@XYL_3_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@MEK_INT		= 0.4
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@ISO_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@APINENE_INT	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@XYL_1_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@TOL_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@HCHO_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@ALD_INT		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@KET_INT		= 0.6
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@ORA2_INT		= (/1.0,1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@CH3OH_INT		= (/0.2,0.8/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@C2H5OH_INT	= (/0.2,0.8/)
NMVOC_edgar_MAP_TRN_cbmz_mos_htap@C2H4_INT		= 1.0

; emission formation from intermediates:
; ETH = ETH_INT
; PAR = 3.0*C3H8_INT + 4.0*NC4H10_4_INT + 5.0*NC4H10_5_INT + 6.0*NC4H10_6_INT + C3H6_INT 
;		+ 2.0*C2H2_INT + TBUT2ENE_INT + (-1.0)*BENZENE_INT + XYL_2_INT + XYL_3_INT + MEK_INT
; ISO = ISO_INT + 2.0*APINENE_INT
; HC3 = 0.0 
; HC5 = 0.0
; HC8 = 0.0
; XYL = XYL_1_INT + XYL_2_INT + XYL_3_INT
; OL2 = 0.0
; OLT = C3H6_INT + TBUT2ENE_INT ?
; OLI = TBUT2ENE_INT ?
; TOL = BENZENE_INT + TOL_INT
; CSL = 0.0
; HCHO = HCHO_INT
; ALD = ALD_INT ?
; KET = KET_INT + MEK_INT
; ORA2 = ORA2_INT
; CH3OH = CH3OH_INT
; C2H5OH = C2H5OH_INT
; C2H4 = C2H4_INT

; intermediate formation from sources
; ETH_INT  = v02
; C3H8_INT = v03
; NC4H10_4_INT = v04
; NC4H10_5_INT = v05
; NC4H10_6_INT = v06
; C3H6_INT = v08
; C2H2_INT = v09
; TBUT2ENE_INT = v12
; BENZENE_INT = v13
; XYL_2_INT = v16
; XYL_3_INT = v17
; MEK_INT = 0.4 * v23
; ISO_INT = v10
; APININE_INT = v11
; XYL_1_INT = v15
; TOL_INT = v14
; HCHO_INT = v21
; ALD_INT = v22
; KET_INT = 0.6 * v23
; ORA2_INT = v18 + v24
; CH3OH_INT = 0.2 * v01 + 0.2 * v19
; C2H5OH_INT = 0.8 * v01 + 0.8 * v19
; C2H4_INT = v07

;;; speciation for EDGAR species to CBMZ emissions (via mid-stage "CRIMech")
;;;
;;;  We apportion by mass to the mid-stage components, then convert using their
;;;  molecular weights to emissions of moles, and finally split those emissions
;;;  between the appropriate CBM-Z species.
;;;
;;;  This will make use of two sets of mapping arrays (and require us to use
;;;  multiple versions of the same chemical in the mid-stage to avoid cross-over
;;;  in certain pathways).
;;;
; v01 (alcohols)  => CH3OH*0.2 + C2H5OH*0.8 (=> CH3OH and => C2H5OH respectively)
; v02 (ethane)    => ETH (=> ETH)
; v03 (propane)   => C3H8 => PAR * 3.0 
; v04 (butane)    => NC4H10_4 => PAR * 4.0
; v05 (pentane)   => NC4H10_5 => PAR * 5.0
; v06 (hexanes)   => NC4H10_6 => PAR * 6.0
; v07 (ethene)    => C2H4 (=> C2H4)
; v08 (propene)   => C3H6 => OLT + PAR
; v09 (ethyne)    => C2H2 => PAR * 2.0    (needs checking????)
; v10 (isoprene)  => ISO  (=> ISO)
; v11 (monoterpenes) => APINENE => ISO * 2.0
; v12 (other alkenes)=> TBUT2ENE => OLI + OLT + PAR  (needs checking????)
; v13 (benzene)   => BENZENE => TOL - PAR
; v14 (toluene)   => TOL (=> TOL)
; v15 (xylene)    => XYL_1 (=> XYL)
; v16 (trimethylbenzenes) => XYL_2 => XYL + PAR
; v17 (other aromatics)   => XYL_3 => XYL + PAR    (needs checking????)
; v18 (esters)    => ORA2 (=> ORA2)
; v19 (ethers)    => CH3OH*0.2 + C2H5OH*0.8 (=> CH3OH and => C2H5OH respectively)
; v20 (chlorinated hydrocarbons - not used for CRI or CBMZ) 
; v21 (formaldehyde)    => HCHO (=> HCHO)
; v22 (other aldehydes) => ALD (=> ALD)
; v23 (ketones)         => KET*0.6 + MEK*0.4 (=> KET and => KET + PAR respectively)
; v24 (alkanoic acids)  => ORA2 (=> ORA2)
; v25 (other VOC's - not used for CRI or CBMZ)

; molecular weight for NMVOC species from the mid-step array
NMVOC_edgar_MOL_WGT_cbmz_mos_htap = True
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@CH3OH_INT	 	= 32.0419
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@C2H5OH_INT	= 46.0684
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@ETH_INT		= 30.07
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@C3H8_INT	 	= 44.1
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@NC4H10_4_INT 	= 58.12
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@NC4H10_5_INT 	= 58.12
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@NC4H10_6_INT 	= 58.12
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@C2H4_INT	 	= 28.05
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@C3H6_INT	 	= 42.08
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@C2H2_INT	 	= 26.04
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@ISO_INT		= 68.117
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@APINENE_INT  	= 136.234
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@TBUT2ENE_INT 	= 56.11
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@BENZENE_INT  	= 78.1118
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@TOL_INT		= 92.1384
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@XYL_1_INT	 	= 106.165
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@XYL_2_INT	 	= 106.165
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@XYL_3_INT	 	= 106.165
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@CH3CO2H_INT  	= 60.052
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@HCHO_INT	 	= 30.03
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@ALD_INT		= 44.05
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@KET_INT	 	= 58.08
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@MEK_INT	 	= 72.11
NMVOC_edgar_MOL_WGT_cbmz_mos_htap@ORA2_INT	 	= 60.05 ;;; using CH3COOH (acetic acid) molar mass 






;;;;;;; MACCity information ;;;;;;;;;;;;;;;;;;;

;;; currently the same (as not used for MACCITY) --- change this if needed?
NMVOC_maccity_MOL_WGT_cbmz_mos_htap = NMVOC_edgar_MOL_WGT_cbmz_mos_htap


; Mapping information for NMVOC species
NMVOC_maccity_MAP_VAR_cbmz_mos_htap = True
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_PAR	= (/"PRPA","BUTA","PRPE","BUTE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_ISO	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_ETH	= (/"ETHA","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_HC3	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_HC5	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_HC8	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_XYL	= (/"TARO","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_OL2	= (/"ETHE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_OLT	= (/"PRPE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_OLI	= (/"BUTE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_TOL	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_CSL	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_HCHO	= (/"FORM","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_ALD	= (/"OALD","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_KET	= (/"ACET","OKET","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_ORA2	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_CH3OH	= (/"METH","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_C2H5OH= (/"OALC","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_htap@E_C2H4  = "CO"



; Scaling factors for NMVOC species
NMVOC_maccity_MAP_TRN_cbmz_mos_htap = True
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_PAR	= (/3.0,5.0,1.0,2.0/)
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_ISO	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_ETH	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_HC3	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_HC5	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_HC8	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_XYL	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_OL2	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_OLT	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_OLI	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_TOL	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_CSL	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_HCHO	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_ALD	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_KET	= (/1.0,1.0/)
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_ORA2	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_CH3OH	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_C2H5OH=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_htap@E_C2H4  =    0.0

; emission formation:
; ETH = ETHA
; PAR = 3xPRPA + 5xBUTA + PRPE + 2xBUTE
; OL2 = ETHE
; OLT = PRPE
; OLI = BUTE
; CH3OH = METH
; C2H5OH = OALC
; HCHO = FORM
; ALD = OALD
; KET = ACET + OKET
; XYL = TARO

;;; speciation for MACCity species to CBMZ emissions
; ETHA = ethane, ETH
; PRPA = propane, 3xPAR
; BUTA = butanes & higher alkanes, 5xPAR
; ETHE = ethene, OL2
; PRPE = propene, OLT+PAR
; BUTE = butenes & higher alkenes, OLI+2xPAR
; METH = methanol, CH3OH
; OALC = other alcohols, C2H5OH
; FORM = formaldehyde, HCHO
; OALD = other aldehydes, ALD
; ACET = acetone, KET
; OKET = other ketones, KET
; TARO = total aromatics, XYL


;;;; reminder of the differences in chemical variable names 
;;;; between WRF and the CBM-Z KPP mechanism
;! left column     right column
;! name in WRF     name in KPP
;HO                OH
;SULF              H2SO4
;ETH  	          C2H6
;ALD  	          ALD2
;KET  	          AONE
;OL2  	          C2H4
;OLT  	          OLET
;OLI  	          OLEI
;CSL  	          CRES
;ISO               ISOP
;OP1               CH3OOH
;OP2               ETHOOH
;ORA1              HCOOH
;ORA2              RCOOH
;C2H5OH            ANOL
;OP3               ROOH



end
;*********************************************


