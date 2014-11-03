
# qingdong.shi@intel.com, 2014_April_03
#nightly_new_sw = "http://shctsbdb01.sh.intel.com/httpserverfile/baytrail/anzhen4/mrd7_p0/nightly/20140411002515/"
#					http://shctsbdb01.sh.intel.com/httpserverfile/baytrail/anzhen4/mrd7/nightly/20140504000150/
#po http://shctsbdb01.sh.intel.com/httpserverfile/baytrail/anzhen4/mrd7_p0/nightly/20140504000133/

echo -e "Hello $1"
echo "I am slave ACS_BJ_MTBF_1 in Beijing MTBF-1-PC"
nightly_new_sw=`echo "$1" | sed -r 's/(.*[0-9]+).*/\1/'`
echo -e "Hello $nightly_new_sw"
echo "I am slave ACS_BJ_MTBF_1 in Beijing MTBF-1-PC"
 

exeDir=$(pwd)
rm -rf $exeDir/Image/*
#exit;

WaitDeviceUP()
{
    while [ 1 ]
    do
        adb shell echo "hello"
        if [ $? -eq 0 ]
        then
            echo "DUT is UP"
            break
        fi
        sleep 20
    done
}


# record log, at the same time, print log on screen.
# parameters,
# $1 is log file name
# $2 is the information printed on screen, and recorded into log
RecordLog()
{
    echo -e "$2"
    echo -e "$2" >> $1 2>&1
}




echo -e "\nget new SW ----> $nightly_new_sw"

nightly_new_sw1=${nightly_new_sw##*nightly\/}

echo "$nightly_new_sw" | mail -s "get new SW----> $nightly_new_sw" wentaox.hou@intel.com
echo "$nightly_new_sw" | mail -s "get new SW----> $nightly_new_sw" wentaox.hou@intel.com

#exit

declare -i run_acs_No=0

while true
do
    run_acs_No+=1
    if [[ $run_acs_No == 2 ]]; then
        echo "$nightly_new_sw" | mail -s "second time ----> $nightly_new_sw" wentaox.hou@intel.com
		exit 0;
    fi

    cd /home/buildbot/acs
    rm -fr shcts* *.bin *.zip index.html* ANZHEN4_MRD7-blankphone* ANZHEN4_MRD7-*fastboot* # remove the old binaries

    tmp_dir=/home/buildbot/acs/_ACS_Log/${nightly_new_sw1}_$(date +%Y%m%d_%H%M%S)
    mkdir -p $tmp_dir
    tmp_log=$tmp_dir/acs_tmp_$$.log
    tmp_flash_log=$tmp_dir/acs_tmp_flash_$$.log
    echo "the log file is $tmp_log"
    echo "the flash log file is $tmp_flash_log"
    touch $tmp_log

#exit;

    old_PWD=$(pwd)
    cd $tmp_dir
########################Step1: Download Image######################	
    RecordLog $tmp_log "download SW to run ACS..."
    RecordLog $tmp_log "\ndownload blankphone files..."
    sleep 3
    wget --no-proxy --no-parent -r ${nightly_new_sw}/ANZHEN4_MRD7/flash_files/blankphone/
    if [ $? != 0 ]; then
        RecordLog $tmp_log "wget blankphone failed, please check"
        echo "send email"
		#
        exit 1
    fi
    RecordLog $tmp_log "\nfinish download blankphone "

    RecordLog $tmp_log "\ndownload flash_files..."
    wget --no-proxy --no-parent -r ${nightly_new_sw}/ANZHEN4_MRD7/flash_files/build-userdebug/
    if [ $? != 0 ]; then
        RecordLog $tmp_log "wget flash_files failed, please check"
        echo "wget flash_files failed" | /usr/bin/mail -s "wget flash-files failed, pls check" wentaox.hou@intel.com
        exit 1
    fi
    RecordLog $tmp_log "\nfinish download flash_files\n"
	
########################Step2: unzip Image######################
	mkdir  -p $exeDir/Image/
	cp -f $(find $tmp_dir -name "*.zip") $exeDir/Image/
	cd $exeDir/Image/
    blank=$(ls *blank*.zip)
    userdebug=$(ls *fastboot*.zip)
    unzip $blank 	
	unzip -n $userdebug -x *.xml  *.cmd 	
    #spinor=$(ls *SPINOR.bin)
    #emmc=$(ls *EMMC.bin)

    # echo $spinor
    # echo $emmc
    # echo $blank
    # echo $userdebug
    

#exit
    #cp -f $efi efilinux-user.efi 
    #cp -f $spinor dediprog.bin
    #cp -f $emmc capsule.bin

    #RecordLog $tmp_log "\nbegin flashing..."


    # cd $old_PWD
    # pwd
    #RecordLog $tmp_log "\npython flash_manager.py -p $tmp_dir -l $tmp_flash_log dediprog.bin capsule.bin $blank $userdebug"
	
########################Step3: Burn Image######################
    cp $exeDir/fastboot .    
	echo "adb reboot dnx"	
	adb reboot dnx
	sleep 10
	echo "fastboot flash osloader efilinux-eng.efi"
	fastboot flash osloader efilinux-eng.efi
	echo "fastboot boot  droidboot.img"
    fastboot boot  droidboot.img
	echo "fastboot oem wipe ESP"
	sleep 10
	fastboot oem wipe ESP
	echo "fastboot oem start_partitioning"
	fastboot oem start_partitioning 	
	echo "fastboot flash /tmp/partition.tbl partition.tbl"
	fastboot flash /tmp/partition.tbl partition.tbl
	echo "fastboot oem partition /tmp/partition.tbl"
	fastboot oem partition /tmp/partition.tbl
	echo "fastboot erase system"
	fastboot erase system
	echo "fastboot erase cache"
	fastboot erase cache
	echo "fastboot erase config"
	fastboot erase config
	echo "fastboot erase data"
	fastboot erase data
	echo "fastboot erase logs"
	fastboot erase logs
	echo "fastboot erase spare"
	fastboot erase spare
	echo "fastboot erase factory"
	fastboot erase factory
	echo "fastboot oem stop_partitioning"
	fastboot oem stop_partitioning
	echo "fastboot flash ESP esp.img"
	fastboot flash ESP esp.img
	echo "fastboot flash fastboot droidboot.img"
	fastboot flash fastboot droidboot.img
	echo "fastboot flash boot boot.img"
	fastboot flash boot boot.img
	echo "fastboot flash recovery recovery.img"
	fastboot flash recovery recovery.img
	echo "fastboot flash system system.img"
	fastboot flash system system.img
	echo "fastboot continue"
	fastboot continue

########################Step4: Bootup Dev####################
	adb wait-for-device
########################Step4: Bootup Dev####################
	cd  /home/cts_tester/Desktop/share/Executable/
	sleep 2
    report_dir=$tmp_dir/_PRELOAD_SET_ENGLISH_CAMPAIGN_$(date +%Y%m%d_%H%M%S)
    python ACS.pyc --report_folder=$report_dir --dm=multi -c _PRELOAD_SET_ENGLISH_CAMPAIGN -b Bench_live
	
    sleep 3
    adb reboot
	adb wait-for-device
    sleep 3

    report_dir=$tmp_dir/_PRELOAD_Campaign_Long_$(date +%Y%m%d_%H%M%S)
    python ACS.pyc --report_folder=$report_dir --dm=multi -c _PRELOAD_Campaign_Long -b Bench_live

    #report_dir=$tmp_dir/_STAB_STRESS_Campaign_Long_$(date +%Y%m%d_%H%M%S)
   # python ACS.pyc --report_folder=$report_dir --dm=multi -c _STAB_STRESS_Campaign_Long -b Bench_live --nb=1

    uuid=$(grep uuid ${report_dir}/live_reporting.log  | head -1 | sed -r 's/.*uuid\=(.*) , b2b.*/\1/')
    echo -e "$nightly_new_sw\n https://acs.tl.intel.com/AWR/#campaigndetails:/uuid=$uuid" | mail -s "finished, log is in $tmp_dir" wentaox.hou@intel.com
    grep -i passrate ${report_dir}/*multi.xml | grep 100
    [[ $? == 0 ]] && exit

    [[ $run_acs_No == 2 ]] && exit
done 