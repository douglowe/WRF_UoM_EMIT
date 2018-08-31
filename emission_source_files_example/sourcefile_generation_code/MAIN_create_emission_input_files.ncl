;
; Script for creating example emission source files.
;
;
;
;
;

load "./library_create_input_files.ncl"


lat_limits = (/20.0,40.0/)
lon_limits = (/300.0,320.0/)
lat_size = 20
lon_size = 20

create_emission_source_file("filename",lat_limits,lon_limits,lat_size,lon_size)

define_emission_patterns()

add_emission_data("variable_name","pattern_name",scaling_factor)