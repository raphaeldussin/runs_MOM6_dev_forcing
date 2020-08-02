#!/bin/bash

module load gcc/5.3.0 netcdf/4.3.0-gcc5.3.0 openmpi/1.8.5_gcc5.3.0


mkdir -p build_om4/gnu/shared/repro/
(cd build_om4/gnu/shared/repro/; rm -f path_names; \
../../../../src/mkmf/bin/list_paths -l ../../../../src/FMS; \
../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/triton-gnu.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

(cd build_om4/gnu/shared/repro/; source ../../env; make NETCDF=3 REPRO=1 libfms.a -j)

mkdir -p build_om4/gnu/ice_ocean_SIS2/repro/
(cd build_om4/gnu/ice_ocean_SIS2/repro/; rm -f path_names; \
../../../../src/mkmf/bin/list_paths -l ./ ../../../../src/MOM6/config_src/{dynamic,coupled_driver} ../../../../src/MOM6/src/{*,*/*}/ ../../../../src/{atmos_null,coupler,land_null,ice_param,icebergs,SIS2,FMS/coupler,FMS/include}/)
(cd build_om4/gnu/ice_ocean_SIS2/repro/; \
../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/triton-gnu.mk -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names )

(cd build_om4/gnu/ice_ocean_SIS2/repro/; source ../../env; make NETCDF=3 REPRO=1 MOM6 -j)
