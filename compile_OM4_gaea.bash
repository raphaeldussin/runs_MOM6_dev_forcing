#!/bin/bash

module load intel/19.0.5.281
module load cray-netcdf

if [ ! -d MOM6-examples ] ; then 
  git clone --recursive git@github.com:NOAA-GFDL/MOM6-examples.git
fi

MOM6edir=$(pwd)/MOM6-examples
builddirfms=$(pwd)/build_OM4/intel/shared/repro
builddirmom=$(pwd)/build_OM4/intel/ice_ocean_SIS2/repro

# build FMS
mkdir -p $builddirfms
(cd $builddirfms ; rm -f path_names; \
$MOM6edir/src/mkmf/bin/list_paths -l $MOM6edir/src/FMS; \
$MOM6edir/src/mkmf/bin/mkmf -t $MOM6edir/src/mkmf/templates/ncrc-intel.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

(cd $builddirfms; source ../../env; make NETCDF=3 REPRO=1 libfms.a -j)

# build MOM6/SIS2
mkdir -p $builddirmom
(cd $builddirmom; rm -f path_names; \
$MOM6edir/src/mkmf/bin/list_paths -l  $MOM6edir/../code $MOM6edir/src/MOM6/config_src/{dynamic,coupled_driver,external} $MOM6edir/src/MOM6/src/{*,*/*}/ $MOM6edir/src/{atmos_null,coupler,land_null,ice_param,icebergs,SIS2,FMS/coupler,FMS/include}/)
(cd $builddirmom; \
$MOM6edir/src/mkmf/bin/mkmf -t $MOM6edir/src/mkmf/templates/ncrc-intel.mk -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names )

(cd $builddirmom; source ../../env; make NETCDF=3 REPRO=1 MOM6 -j)

