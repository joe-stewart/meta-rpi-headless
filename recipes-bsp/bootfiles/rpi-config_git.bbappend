# Fix: strip commented lines from config.txt to avoid RPi5 file size boot issue
# https://github.com/raspberrypi/firmware/issues/1848

do_deploy:append() {
    sed -i '/^#/d' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    sed -i '/^$/d' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}
