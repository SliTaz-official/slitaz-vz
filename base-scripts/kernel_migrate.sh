#!/bin/sh
#

KVER=2.6.32
PREFIX=ovzkernel-
SUFFIX=
EXTRAVERSION=-i686


for i in linux-*
do
	if [ ! -d ${PREFIX}$(echo ${i##linux-})${SUFFIX} ]; then
		cp -pa  $i ${PREFIX}$(echo ${i##linux-})${SUFFIX}
		sed -i -e "s/PACKAGE=.*/PACKAGE=\"${PREFIX}$(echo ${i##linux-})\"/" \
			-e "s/VERSION=.*/VERSION=\"${KVER}\"/" \
			-e "s/DEPENDS.*/DEPENDS=\"${PREFIX%%-}\"/" \
			-e "s/WANTED=.*/WANTED=\"${PREFIX%%-}\"/" \
			-e "s/\(WEB_SITE.*\)/\1\nEXTRAVERSION=\"${EXTRAVERSION}\"/" \
			-e "s/\(EXTRA.*\)/\1\nSOURCE=\"linux\"/" \
			-e "s!\(local path\)!\1\n\tsrc=\$WOK/\$WANTED/\$SOURCE-\$VERSION\n\t_pkg=\$WOK/\$WANTED/\$SOURCE-\$VERSION/_pkg\n\tKERNELRELEASE=\$( cat \$src/include/config/kernel.release 2> /dev/null)!" \
			-e "s!slitaz/list_modules.sh!\OpenVZ/list_modules.sh \${KERNELRELEASE}!" \
			-e "s/\$VERSION-slitaz/\${KERNELRELEASE}/" \
			-e "s/depmod -a \$VERSION-slitaz/depmod -a \${KERNELRELEASE}/" \
			${PREFIX}$(echo ${i##linux-})${SUFFIX}/receipt
			
			sed -i '/chroot/ {
				i\KERNELRELEASE=$(cat $1\/etc\/ovzkernel\/kernel\.release)
			}' ${PREFIX}$(echo ${i##linux-})${SUFFIX}/receipt
			
			sed -i '/\tdepmod/ {
				i\
		\		KERNELRELEASE=$(cat $1\/etc\/ovzkernel\/kernel\.release)
			}' ${PREFIX}$(echo ${i##linux-})${SUFFIX}/receipt
	fi
done

