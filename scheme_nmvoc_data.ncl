;
;  Data for the NMVOC schemes.
;
;
;

begin



;;;;;;;;;; NMVOC EDGAR emissions information

	; list of NMVOC species/groups
	; voc1 = Alcohols
	; voc2 = Ethane
	; voc3 = Propane
	; voc4 = Butanes
	; voc5 = Pentanes
	; voc6 = Hexanes and Higher Alkanes
	; voc7 = Ethene
	; voc8 = Propene
	; voc9 = Ethyne
	; voc10 = Isoprenes
	; voc11 = Monoterpenes
	; voc12 = Other Olefins
	; voc13 = Benzene
	; voc14 = Methylbenzene
	; voc15 = Dimethylbenzenes
	; voc16 = Trimethylbenzenes
	; voc17 = Other Aromatics
	; voc18 = Esters
	; voc19 = Ethers
	; voc20 = Chlorinated Hydrocarbons --------- not used
	; voc21 = Formaldehyde
	; voc22 = Aldehydes
	; voc23 = Ketones
	; voc24 = Acids
	; voc25 = Other NMVOC ----------- not used


	edgar_nmvoc_species = (/ "VOC01", "VOC02", "VOC03", "VOC04", "VOC05", "VOC06", \
							 "VOC07", "VOC08", "VOC09", "VOC10", "VOC11", "VOC12", \
							 "VOC13", "VOC14", "VOC15", "VOC16", "VOC17", "VOC18", \
							 "VOC19", "VOC21", "VOC22", "VOC23", "VOC24" \
							 /)
	
	edgar_nmvoc_species_index = True
	edgar_nmvoc_species_index@VOC01 = 0
	edgar_nmvoc_species_index@VOC02 = 1
	edgar_nmvoc_species_index@VOC03 = 2
	edgar_nmvoc_species_index@VOC04 = 3
	edgar_nmvoc_species_index@VOC05 = 4
	edgar_nmvoc_species_index@VOC06 = 5
	edgar_nmvoc_species_index@VOC07 = 6
	edgar_nmvoc_species_index@VOC08 = 7
	edgar_nmvoc_species_index@VOC09 = 8
	edgar_nmvoc_species_index@VOC10 = 9
	edgar_nmvoc_species_index@VOC11 = 10
	edgar_nmvoc_species_index@VOC12 = 11
	edgar_nmvoc_species_index@VOC13 = 12
	edgar_nmvoc_species_index@VOC14 = 13
	edgar_nmvoc_species_index@VOC15 = 14
	edgar_nmvoc_species_index@VOC16 = 15
	edgar_nmvoc_species_index@VOC17 = 16
	edgar_nmvoc_species_index@VOC18 = 17
	edgar_nmvoc_species_index@VOC19 = 18

	edgar_nmvoc_species_index@VOC21 = 19
	edgar_nmvoc_species_index@VOC22 = 20
	edgar_nmvoc_species_index@VOC23 = 21
	edgar_nmvoc_species_index@VOC24 = 22
	
	
	;;; We don't have a list of EDGAR NMVOC molecular weights, as many of the groups are lumped species.
	;;; Instead we will divide these emissions by emitted mass between each scheme's emission variables,
	;;; and only after that then convert from mass to ppm
	edgar_nmvoc_mol_weights = False	
	
	


	; list of emission sectors for EDGAR NMVOC
	edgar_nmvoc_sectors = (/ "AWB", "ENE", "FFF", "IND", "PPA", "PRO", "RCO", "REF", "SWD", \
								"TNR_Other", "TNR_Ship", "TRF", "TRO" /)
	; info on how we're grouping these into the HTAP emission sectors
	edgar_nmvoc_groups = (/ "AGR", "POW", "IND", "IND", "SLV", "IND", "RES", "IND", "AGR", \
								"IND", "SHP", "IND", "TRA" /)









;;;;;;;;;; NMVOC MACCity emissions information

	; list of NMVOC species/groups
	; ACET = acetone
	; BUTA = butanes_and_higher_alkanes 
	; BUTE = butenes_and_higher_alkenes
	; ETHA = ethane
	; ETHE = ethene
	; FORM = formaldehyde
	; METH = methanol
	; OALC = other_alcohols
	; OALD = other_aldehydes
	; OKET = other_ketones
	; PRPA = propane
	; PRPE = propene
	; TARO = total_aromatics
	maccity_species = (/ "ACET", "BUTA", "BUTE", "ETHA", "ETHE", "FORM", \
					"METH", "OALC", "OALD", "OKET", "PRPA", "PRPE", "TARO" /)
	
	maccity_species_index = True
	maccity_species_index@ACET = 0
	maccity_species_index@BUTA = 1
	maccity_species_index@BUTE = 2
	maccity_species_index@ETHA = 3
	maccity_species_index@ETHE = 4
	maccity_species_index@FORM = 5
	maccity_species_index@METH = 6
	maccity_species_index@OALC = 7
	maccity_species_index@OALD = 8
	maccity_species_index@OKET = 9
	maccity_species_index@PRPA = 10
	maccity_species_index@PRPE = 11
	maccity_species_index@TARO = 12
	
	maccity_mol_weights = True     ; these are taken from the MACCity website
	maccity_mol_weights@ACET = 58
	maccity_mol_weights@BUTA = 58
	maccity_mol_weights@BUTE = 56
	maccity_mol_weights@ETHA = 30
	maccity_mol_weights@ETHE = 28
	maccity_mol_weights@FORM = 30
	maccity_mol_weights@METH = 32
	maccity_mol_weights@OALC = 32
	maccity_mol_weights@OALD = 44
	maccity_mol_weights@OKET = 72
	maccity_mol_weights@PRPA = 44
	maccity_mol_weights@PRPE = 42
	maccity_mol_weights@TARO = 126

	; list of emission sectors for MACCity
	maccity_sectors = (/ "AGRBURN", "AGRPROD", "ENERGY", "IND", "RES", "SHPS", "SOLV", "TRANS", "WASTE" /)
	; info on how we're grouping these into the HTAP emission sectors
	maccity_groups = (/ "AGR", "AGR", "POW", "IND", "RES", "SHP", "IND", "TRA", "IND" /)





end