# WRF_UoM_EMIT

WRF_UoM_EMIT is an NCL based pre-processing script, for generating anthropogenic emissions files for use with WRF-Chem. It does not map emissions onto the model grid - this can be done using anthro_emis, or similar tools (which this tool will complement, rather than replace) - instead it is intended to be used for applying temporal and spatial variations to the emission data, mapping VOC emissions into chemical-scheme specific groupings, and combining emissions sectors into single emission variables.

This project is licensed under the terms of the GNU General Public License v3.0, as is provided with this repository.

## Table of Contents
1. [Overview](#Overview)
1. [Dependencies](#Dependencies)
2. [Inputs](#Inputs)
3. [Outputs](#Outputs)
4. [Run-time Options](#Run-time-Options)
5. [Methodology](#Methodology)
   1. [Diurnal Cycle](#Diurnal-cycle) 
   2. [Conforming Aerosol Emissions](#Conforming-aerosols)
   3. [Regional Modification of Emissions](Regional-modification)
   4. [Vertical Distribution of Emissions](Vertical-distribution)
   5. [Mapping to WRF-Chem Scheme](#WRF-mapping)
   5. [Mapping VOC emissions](#VOC-mapping)
6. [Contributing](#contributing)

## Overview<a name="Overview"></a>

The tool scripts are contained in the ``Processing_Scripts`` directory, while example source file headers are provided in the ``emission_source_files_example`` directory. The principal tool script is ``MAIN_emission_processing.ncl``. At the head of this script you can set the run-time options controlling the process of emission generation, the rest of the script organises the calling of the processing functions (in scripts ``diurnal_cycle_routines.ncl``, ``preprocess_emissions_routines.ncl``, ``speciating_emissions_routines.ncl``, and ``vertical_distribution_routines.ncl``). Settings for the different input and output schemes, and data for the different processing options, are stored in a variety of files ending ``*data.ncl``


## Dependencies<a name="Dependencies"></a>

WRF_UoM_EMIT has been written in NCL (https://www.ncl.ucar.edu/); it has been tested with version 6.3.0. Input files are generated using anthro_emis (https://www2.acom.ucar.edu/wrf-chem/wrf-chem-tools-community); example configuration scripts for using this tool with EDGAR-HTAP emissions datasets are available in this repository: https://github.com/douglowe/PROMOTE-emissions .

## Inputs<a name="Inputs"></a>

WRF_UoM_EMIT takes two sets of input files. The first are general emission variables, the second are the NMVOC emission variables. 

The general emission variables should be in input files with the following naming convention:
wrfchemi\_[HH]z\_[domain]\_[YYYY]\_[MM]

The NMVOC emission variables should be in input files with the following naming convention:
wrfchemi\_[HH]z\_NMVOC\_[domain]\_[YYYY]\_[MM]

[HH] will be the hour of day (either 00 or 12 - as generated by anthro_emis using option **XX**). [domain] will be the model domain (d01, d02, etc), [YYYY] will be a 4-digit year, and [MM] will be a 2 digit month.

The standard input datasets supported are:
* EDGAR-HTAP
* SAFAR

The NMVOC input datasets supported are:
* MACCity
* EDGAR v4.3.2

These lists will be amended as more options are added.

## Outputs<a name="Outputs"></a>

WRF_UoM_EMIT creates a single set of input files, containing WRF-Chem emission scheme specific inputs. The naming convention followed is the same as that for the input files: `wrfchemi_[HH]z_[domain]_[YYYY]_[MM]`.

The WRF-Chem input schemes that are supported are:
* `cbmz_mos_orig`:
  * Emissions for CBM-Z gas-phase, and MOSAIC aerosol, schemes
  * WRF-Chem namelist options: `emiss_opt = 4` (ecbmz_mosaic) and `emiss_inpt_opt = 101` (emiss_inpt_pnnl_cm)
  * config option: `wrfchem_scheme = "cbmz_mos_orig"`
* `cri_mos_edgar_htap`:
  * Emissions for CRIv2R5 gas-phase, and MOSAIC aerosol, schemes
  * WRF-Chem namelist options: `emiss_opt = 20` (ecrimechtno) and `emiss_inpt_opt = 121` (emiss_inpt_tno)
  * config option: `wrfchem_scheme = "cri_mos_edgar_htap"`
* `cbmz_mos_htap`:
  * Emissions for CBM-Z gas-phase, and MOSAIC aerosol, schemes
  * only usable with WRF-Chem code inluding local UoM modifications - ask for more information 
  * WRF-Chem namelist options: `emiss_opt = 25` (ecbmz_mos_htap) and `emiss_inpt_opt = 122` (emiss_inpt_htap)
  * config option: `wrfchem_scheme = "cbmz_mos_htap"`


This list will be amended as more options are added.

## Run-time Options<a name="Run-time-Options"></a>

* Time and domain controls:
  * `month`: single string value (2 digits long)
  * `year`: single string value (4 digits long)
  * `domains`: array of string identifiers for domains to be processed (of style "dNN")
* Chemical scaling factors:
  * `nox_frac`: fraction of NOx emissions which are NO (real value between 0-1)
  * `oc_om_scale`: scaling factor for calculating organic matter (OM) emitted mass from the input organic carbon (OC) emitted mass 
* Input scheme controls:
  * `input_scheme`: identifier string for the emission dataset used
  * `nmvoc_scheme`: identifier string for the speciated NMVOC emission dataset used
    * `nmvoc_scheme@method`: controls how the NMVOC emissions are used
      * `direct`: create emissions directly from the NMVOC dataset
      * `fraction`: use the NMVOC dataset to speciate lumped NMVOC variables in the main emission dataset
* Output scheme control:
  * `wrfchem_scheme`: identifier string for the emission scheme generated, see [Outputs](#Outputs)
* Diurnal cycle controls:
  * `UTC_offset`: logical controller, to determine if local offsets from UTC should be calculated or not
    * `UTC_offset@method`: controls how the offset is calculated
      * `fixed`: use a single fixed offset from UTC, defined in this script
      * `timezones`: use timezone information to calculate the offset from UTC
    * `UTC_offset@fixed_offset`: offset from UTC for fixed method
    * `UTC_offset@daylightsaving`: logical controller, to determine if local daylight saving shifts need to be included in the UTC offset calculation
* Process logical controllers: these allow for different stages of the main tool to be run independently, and for optional processing steps to be included
  * `STEP1_create_diurnal_cycle_and_prescaling`
  * `regional_modification_of_emissions`: optional modification of emission inputs
  * `STEP2_apply_vertical_power_emissions`
  * `use_vertical_power_emission_files`: set to True if STEP2 (vertical distribution of emissions) is used
  * `STEP3_create_emissions_for_WRF_Chem`
* Regional modification of emissions: this enables the modification of emissions within a defined region by sector and species (not for nmvoc inputs though). 
  * `regional_modification_of_emissions@latitude_limits`: array of two latitude values, first is minimum, second is maximum
  * `regional_modification_of_emissions@longitude_limits`: array of two longitude values, first is minimum, second is maximum
  * `regional_modification_of_emissions@vars_mask`: list of variable names to be modified
  * `regional_modification_of_emissions@vars_scale`: list of scaling factors to be applied, same length as `vars_mask`


## Methodology<a name="Methodology"></a>

Emissions processing is divided (roughly) into three steps, corresponding to the process logical controllers listed in [Run-time Options](Run-time-Options): 1) preprocessing of input emissions to add diurnal cycles, ensure conformity of aerosol emissions, and the regional modification of emission inputs (if needed); 2) distribution of emissions vertically; 3) mapping of input emissions to the desired WRF-Chem scheme (including VOC mapping, and NOx fractionation). Below the key features of these processes will be described, while more detailed information will be given on the [wiki](https://github.com/douglowe/WRF_UoM_EMIT/wiki).

The script takes input files from the directory defined by `SOURCEDIR`, stores intermediate files after step 1 in the `DIUDIR` directory, then can store intermediate files after step 2 in the `VERTDIR` directory, and outputs the final WRF-Chem input files in the `OUTDIR` directory.

### Diurnal Cycle and UTC Offset<a name="Diurnal-cycle"></a>

Diurnal cycle information is taken from Olivier et al. (2003), based on Western European data, for the following sectors: power, industrial, residential, solvent use, traffic, and agriculture. The representativity of these cycles for activity in other regions is highly uncertain. These factors are stored as hourly scaling factors within the `diurnal_cycles` arrays in `emission_script_data.ncl` - change these arrays if you wish to use diurnal cycle information that is more suitable for your region of interest.

Diurnal cycles are superimposed using the routines within `diurnal_cycle_routines.ncl`. The first step is determining whether any offsets from UTC are needed (by setting the `UTC_offset` logical operation); then if so whether a single fixed offset for the whole domain (by setting `UTC_offset@method = fixed` and defining a value for `UTC_offset@fixed_offset`) is to be used, or if the offset should be calculated for each grid cell using timezone information (by setting `UTC_offset@method = timezones`).

Timezones are defined using shapefiles which have been downloaded from [http://efele.net/maps/tz/world/](http://efele.net/maps/tz/world/), and are stored in the `shape_files` directory. These shapefiles cover timezones on land only, sea zones will be assumed to be in UTC (which is okay at the moment, as no diurnal variation is given for ship emissions). The timezone that each grid square is in is determined using the routines in `shapefiles_manipulate.ncl` (adapted from [https://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl](https://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl)), and then the UTC offset is determined using data stored in `timezone_data.ncl`, which includes both summer and daylight saving time offsets for each timezone region. The choice of which to use is controlled using the `UTC_offset@daylightsaving` logical operator - currently this has to be hardset by the user as the changeover date varies from region to region, and year to year, so this calculation has not been included in the model routines.

The final UTC offset values are stored to the intermediate emission datafiles in the `TZ_Offset` variable, so can be checked after this process to ensure they are correct. It should be noted that the timezone offset method relies on the land/sea boundaries in the timezone shapefiles and in the emissions data to roughly match. Where these do not (as can happen with coarse resolution emission datasets mapped onto high resolution model domains), then emissions along the coastline can be left without a UTC offset of zero. For these high resolution domains it is recommended, for the moment, to use a fixed UTC offset value.

Olivier, J., J. Peters, C. Granier, G. Pétron, J.F. Müller, and S. Wallens, Present and future surface emissions of atmospheric compounds, POET Report #2, EU project EVK2-1999-00011, 2003.

### Conforming Aerosol Emissions<a name="Conforming-aerosols"></a>

Aerosol emissions for each sector are conformed in a three stage process, using routines in the `preprocess_emissions_routines.ncl` module. Firstly the organic carbon (OC) emissions data provided is scaled by the `oc_om_scale` factor, to give a mass value for organic matter (OM) emissions (which is what WRF-Chem expects). Currently one scaling factor is used for all emission sectors. Secondly the PM2.5 emissions for each sector are compared with the summed black carbon (BC) and OM emissions, and increased to match the BC+OM sum if they are lower. Finally the PM10 emissions for each sector are compared with the PM2.5 emissions, and again increased to match this if they are lower.

### Regional Modification of Emissions<a name="Regional-modification"></a>

Emission variables can be modified within a defined rectangular region using routines in the `preprocess_emissions_routines.ncl` module. To do this the `regional_modification_of_emissions` flag needs to be set to True. The limits of the region are defined by maximum and minimum latitude and longitude values, and matching lists of the names of the variables to be modified, and the scaling factor to be applied, must be supplied as attributes for the `regional_modification_of_emissions` variable.

### Vertical Distribution of Emissions<a name="Vertical-distribution"></a>

Vertical distributions for each emission variable are applied using routines in the `vertical_distribution_routines.ncl` module. These simply apportion emissions across a number of emission levels according to fractional distributions for each sector, using definitions stored in the `scheme_vertical_dist.ncl` file. The provided example vertical distributions add predominately area emissions to the lowest 2 model levels, but treat industrial (IND) and power station (POW) emissions as small and large point sources (respectively), which should be emitted at higher elevations (roughly estimated to be about 300m above ground level for large point sources) (after the EPRES tool, personal communication, Yafang Cheng). Because emissions are mapped directly to WRF-Chem model levels, the exact elevation of these emissions will depend on the setup of your model domain. Users are strongly encouraged to check the vertical distribution of their model levels, to decide if the given vertical distributions are suitable or not.

### Mapping to WRF-Chem scheme<a name="WRF-mapping"></a>

The combining of input emissions from different sectors, and mapping of these to specified WRF-Chem compatible emission variables, is carried out by routines within the `speciating_emissions_routines.ncl` module. Lists of the WRF-Chem gas, NMVOC, and aerosol emission variables for each supported scheme are given in `emission_script_data.ncl`, while specific mapping information for these are given scheme specific modules (named `scheme_[schemeID]_data.ncl`). Within these scheme specific modules information on mapping inorganic gas-phase species from emission sources are stored as attributes for the `INORG_MAP_VAR_[schemeID]` and `INORG_MAP_TRN_[schemeID]` variables. The same information for aerosol species are stored as attributes for the `AERO_MAP_VAR_[schemeID]` and `AERO_MAP_TRN_[schemeID]` variables. `INORG_MAP_VAR_[schemeID]` and `AERO_MAP_VAR_[schemeID]` list the relationship between WRF-Chem and source emission variables, while `INORG_MAP_TRN_[schemeID]` and `AERO_MAP_TRN_[schemeID]` list the transformation factor to go from input to WRF-Chem variable (often this will be 1.0, for a direct translation, or 0.0, for just creating an empty emission variable). 

There are two special cases to this:

1. The calculation of NO and NO2 emissions from NOx are controlled by the `nox_frac` variable, not the values stored in `INORG_MAP_TRN_[schemeID]@E_NO` and `INORG_MAP_TRN_[schemeID]@E_NO2`.
2. PM2.5 and PM10 emission inputs for WRF-Chem (for MOSAIC aerosol, at least) are treated as simply other inorganic (OIN) emissions (e.g. dust) for these size ranges (the PM10 size range is 2.5 to 10 um). Most emission databases treat PM2.5 and PM10 emissions as total emitted mass (including OIN, BC, OM, etc). To convert to the WRF-Chem definition this tool subtracts BC and OM mass from PM2.5 mass, and then PM2.5 mass from PM10 mass.

If you wish to change these special cases, or to add your own, then you will need to edit the routines in `speciating_emissions_routines.ncl`.


### VOC mapping<a name="VOC-mapping"></a>

Two options are available for VOC mapping, chosen using the `nmvoc_scheme@method` control variable. Direct mapping will apportion emissions from the input NMVOC dataset to the relevant WRF-Chem emission variables. The fraction method uses the input NMVOC emissions to calculate the fractional breakdown of the bulk NMVOC emissions (for each grid cell) in the main emission dataset into the WRF-Chem emission variables. The latter method is useful where the spatial distribution of the NMVOC dataset is coarser than that of the main emission dataset.

The mapping information for NMVOC emissions are given in the scheme specific modules, as attributes for the `NMVOC_[nmvocID]_MAP_VAR_[schemeID]` and `NMVOC_[nmvocID]_MAP_TRN_[schemeID]` variables (as described above for the gas and aerosol species). The NMVOC molar masses are also defined, as attributes for the `NMVOC_[nmvocID]_MOL_WGT_[schemeID]` variable.

More detail on VOC mapping (particularly on multi-step mapping) can be found on the [wiki](https://github.com/douglowe/WRF_UoM_EMIT/wiki).

## Contributing<a name="Contributing"></a>


## Acknowledgements<a name="Acknowledgements"></a>

Rajash Kumar sharing the diurnal cycle information with me, as well as his IDL code which inspired the first version of this tool.

Scott Archer-Nicholls, Alex Archibald, and Gordon McFiggans, for the provision of MACCITY and EDGAR NMVOC mapping schemes.

Eric Muller for the provision of the timezone maps provided at [http://efele.net/maps/tz/world/](http://efele.net/maps/tz/world/).

Chris Webber and Ying Chen for the mapping of `cbmz_mos_orig` emissions.


