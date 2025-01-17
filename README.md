## ABOUT
Forked from OpenAvnu repo
WIP branch kernel_6.8.9-dev-gaurav

git clone --single-branch kernel_6.8.9-dev-gaurav <repo-git>

## Building for intel i1210 nic card
NOTE: 
1.kernel used 6.8.9 [built from source]
2.disable iommu

install dependencies as mentioned in MAIN REPO -> README.rst and lib/avtp_pipeline

git submodule sync
git submodule init
git submodule update

make PLATFORM_TOOLCHAIN=x86_i210_linux IGB_LAUNCHTIME_ENABLED=1 ATL_LAUNCHTIME_ENABLED=0 all  

make -C lib/igb_avb all