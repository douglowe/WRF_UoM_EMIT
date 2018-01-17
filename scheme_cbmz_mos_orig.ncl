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
INORG_MAP_VAR_cbmz_mos_orig = True
INORG_MAP_VAR_cbmz_mos_orig@E_CO 	= "CO"
INORG_MAP_VAR_cbmz_mos_orig@E_NO 	= "NOx"
INORG_MAP_VAR_cbmz_mos_orig@E_NO2 	= "NOx"
INORG_MAP_VAR_cbmz_mos_orig@E_SO2 	= "SO2"
INORG_MAP_VAR_cbmz_mos_orig@E_NH3 	= "NH3"

INORG_MAP_TRN_cbmz_mos_orig = True
INORG_MAP_TRN_cbmz_mos_orig@E_CO 	= 1.0
INORG_MAP_TRN_cbmz_mos_orig@E_NO 	= -9999. 	; this will be replaced later with NOX_FRAC
INORG_MAP_TRN_cbmz_mos_orig@E_NO2 	= -9999.	; this will be replaced later with 1-NOX_FRAC
INORG_MAP_TRN_cbmz_mos_orig@E_SO2 	= 1.0
INORG_MAP_TRN_cbmz_mos_orig@E_NH3 	= 1.0


;;;;; aerosol data
; Note it is assumed that OC emissions have already been converted to Org 
; (e.g. Org = 1.4*OC), PM2.5 is the total mass for PM2.5, and PM10 is 
; total mass for PM10      
; e_PM10 and e_PM_10 are different (Found within module_mosaic_addemiss.F)
; For emiss_opt =4 use e_PM_10
; For emiss_opt = 5/6 use e_PM10, which is an added variable for GOCART emissions to MOSAIC mapping 

AERO_MAP_VAR_cbmz_mos_orig = True
AERO_MAP_VAR_cbmz_mos_orig@E_PM25i		= "PM2_5"	; Unspeciated primary PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_PM25j  	= "PM2_5" ; Unspeciated primary PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECI    	= "BC" ; Elemental Carbon PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECJ		= "BC" ; Elemental Carbon PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGI		= "OC" ; Organic Carbon PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGJ   	= "OC" ; Organic Carbon PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_SO4I		= "PM2_5" ; Sulfate PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_SO4J		= "PM2_5" ; Sulfate PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_NO3I		= "PM2_5" ; Nitrate PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_NO3J		= "PM2_5" ; Nitrate PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_PM_10		= "PM10" ; Unspeciated PM10 emissions 
AERO_MAP_VAR_cbmz_mos_orig@E_SO4C		= "PM2_5" ; Sulfate - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_NO3C		= "PM2_5" ; Nitrate - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGC		= "OC" ; Organic Carbon - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECC		= "BC" ; Elemental Carbon - course mode



AERO_MAP_VAR_cbmz_mos_orig = True
AERO_MAP_VAR_cbmz_mos_orig@E_PM25i		= 0.2 ; Unspeciated primary PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_PM25j  	= 0.8 ; Unspeciated primary PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECI    	= 0.2 ; Elemental Carbon PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECJ		= 0.8 ; Elemental Carbon PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGI		= 0.2 ; Organic Carbon PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGJ   	= 0.8 ; Organic Carbon PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_SO4I		= 0.0 ; Sulfate PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_SO4J		= 0.0 ; Sulfate PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_NO3I		= 0.0 ; Nitrate PM2.5 - nuclei mode
AERO_MAP_VAR_cbmz_mos_orig@E_NOJ		= 0.0 ; Nitrate PM2.5 - accumulation mode
AERO_MAP_VAR_cbmz_mos_orig@E_PM_10		= 1.0 ; Unspeciated PM10 emissions 
AERO_MAP_VAR_cbmz_mos_orig@E_SO4C		= 0.0 ; Sulfate - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_NO3C		= 0.0 ; Nitrate - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_ORGC		= 0.0 ; Organic Carbon - course mode
AERO_MAP_VAR_cbmz_mos_orig@E_ECC		= 0.0 ; Elemental Carbon - course mode

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
NMVOC_edgar_MAP_VAR_cbmz_mos_htap_new = True
NMVOC_edgar_MAP_VAR_cbmz_mos_htap_new@E_ETH		= (/"VOC02","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_htap_new@E_PAR		= (/"VOC01","VOC03","VOC04","VOC05","VOC06","VOC08",\
												"VOC09","VOC12","VOC13","VOC16","VOC17","VOC19",\
												"VOC23","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_ISO		= (/"VOC10","VOC11","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_HC3		= "CO"
;;; using hc5 for par in chem/module_cbmz_addemiss.F (emiss_inpt_opt = 101)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_HC5		= (/"VOC01","VOC03","VOC04","VOC05","VOC06","VOC08",\
												"VOC09","VOC12","VOC13","VOC16","VOC17","VOC19",\
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_HC8		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_XYL		= (/"VOC15","VOC16","VOC17","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_OL2		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_OLT		= (/"VOC08","VOC12","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_OLI		= (/"VOC12","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_TOL		= (/"VOC13","VOC14","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_CSL		= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_HCHO	= (/"VOC21","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_ALD		= (/"VOC22","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_KET		= (/"VOC23","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_ORA2	= (/"VOC24","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_CH3OH	= (/"VOC01","VOC19","NMVOC"/)
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_C2H5OH	= "CO"
NMVOC_edgar_MAP_VAR_cbmz_mos_orig@E_C2H4    = (/"VOC07","NMVOC"/)


; Scaling factors for NMVOC species
NMVOC_edgar_MAP_TRN_cbmz_mos_orig = True
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_ETH		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_PAR		= (/0.8,3.0,4.0,5.0,6.0,1.0,\
												2.0,1.0,-1.0,1.0,1.0,0.8,\
												0.33/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_ISO		= (/1.0,2.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_HC3		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_HC5		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_HC8		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_XYL		= (/1.0,1.0,1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_OL2		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_OLT		= (/1.0,1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_OLI		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_TOL		= (/1.0,1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_CSL		= 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_HCHO	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_ALD		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_KET		= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_ORA2	= 1.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_CH3OH	= (/1.0,1.0/)
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_C2H5OH  = 0.0
NMVOC_edgar_MAP_TRN_cbmz_mos_orig@E_C2H4    = 1.0

; emission formation:
; ETH = v02
; PAR = 0.8*v01 + 3.0*v03 + 4.0*v04 + 5.0*v05 + 6.0*v06 + v08 
;		+ 2.0*v09 + v12 + (-1.0)*v13 + v16 + v17 + 0.8*v19
;		+ 0.33*v23
; ISO = v10 + 2.0*v11
; HC3 = 0.0 
; HC5 = 0.0
; HC8 = 0.0
; XYL = v15 + v16 + v17
; OL2 = 0.0
; OLT = v08 + v12 ?
; OLI = v12 ?
; TOL = v13 + v14
; CSL = 0.0
; HCHO = v21
; ALD = v22 ?
; KET = v23
; ORA2 = v24
; CH3OH = v01 + v19
; C2H5OH = 0.0
; C2H4 = v07

;;; speciation for EDGAR species to CBMZ emissions
; v01 (alcohols)  = CH3OH*0.2 + (PAR + CH3OH)*0.8
; v02 (ethane)    = ETH 
; v03 (propane)   = PAR * 3.0
; v04 (butane)    = PAR * 4.0
; v05 (pentane)   = PAR * 5.0
; v06 (hexanes)   = PAR * 6.0
; v07 (ethene)    = C2H4
; v08 (propene)   = OLT + PAR
; v09 (ethyne)    = PAR * 2.0    (needs checking????)
; v10 (isoprene)  = ISO
; v11 (monoterpenes) = ISO * 2.0
; v12 (other alkenes)= OLI + OLT + PAR  (needs checking????)
; v13 (benzene)   = TOL - PAR
; v14 (toluene)   = TOL
; v15 (xylene)    = XYL
; v16 (trimethylbenzenes) = XYL + PAR
; v17 (other aromatics)   = XYL + PAR    (needs checking????)
; v18 (esters)    = ORA2
; v19 (ethers)    = CH3OH*0.2 + (PAR + CH3OH)*0.8
; v20 (chlorinated hydrocarbons - not used for CRI or CBMZ) 
; v21 (formaldehyde)    = HCHO
; v22 (other aldehydes) = ALD
; v23 (ketones)         = KET*0.67 + (KET + PAR)*0.33
; v24 (alkanoic acids)  = ORA2
; v25 (other VOC's - not used for CRI or CBMZ)

; molecular weight for NMVOC species
NMVOC_edgar_MOL_WGT_cbmz_mos_orig = True
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_ETH	 	= 30.07
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_PAR	 	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_ISO	 	= 68.117
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_HC3	 	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_HC5	 	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_HC8	 	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_XYL	 	= 106.165
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_OL2	 	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_OLT	 	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_OLI	 	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_TOL	 	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_CSL	 	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_HCHO	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_ALD	 	= 58.08
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_KET	 	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_ORA2	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_CH3OH	= 99999.9 ; ?????? temporary value
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_C2H5OH	= 0.0
NMVOC_edgar_MOL_WGT_cbmz_mos_orig@E_C2H4	= 28.05







;;;;;;; MACCity information ;;;;;;;;;;;;;;;;;;;

;;; currently the same (as not used for MACCITY) --- change this if needed?
NMVOC_maccity_MOL_WGT_cbmz_mos_htap = NMVOC_edgar_MOL_WGT_cbmz_mos_htap


; Mapping information for NMVOC species
NMVOC_maccity_MAP_VAR_cbmz_mos_orig = True
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_PAR	= (/"PRPA","BUTA","PRPE","BUTE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_ISO	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_ETH	= (/"ETHA","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_HC3	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_HC5	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_HC8	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_XYL	= (/"TARO","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_OL2	= (/"ETHE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_OLT	= (/"PRPE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_OLI	= (/"BUTE","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_TOL	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_CSL	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_HCHO	= (/"FORM","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_ALD	= (/"OALD","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_KET	= (/"ACET","OKET","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_ORA2	= "CO"
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_CH3OH	= (/"METH","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_C2H5OH= (/"OALC","NMVOC"/)
NMVOC_maccity_MAP_VAR_cbmz_mos_orig@E_C2H4  = "CO"



; Scaling factors for NMVOC species
NMVOC_maccity_MAP_TRN_cbmz_mos_orig = True
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_PAR	= (/3.0,5.0,1.0,2.0/)
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_ISO	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_ETH	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_HC3	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_HC5	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_HC8	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_XYL	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_OL2	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_OLT	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_OLI	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_TOL	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_CSL	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_HCHO	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_ALD	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_KET	= (/1.0,1.0/)
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_ORA2	= 0.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_CH3OH	=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_C2H5OH=    1.0
NMVOC_maccity_MAP_TRN_cbmz_mos_orig@E_C2H4  =    0.0

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
; PRPA = propane, 3xPAR(/"VOC01","VOC03","VOC04","VOC05","VOC06","VOC08",\
												"VOC09","VOC12","VOC13","VOC16","VOC17","VOC19",\
								
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


