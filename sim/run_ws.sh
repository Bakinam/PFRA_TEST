#!/bin/bash
#v05
s3rootfolder="s3://hecrasmodels/pfra"

# Parse path 
project=$(echo $1 | cut -d "_" -f1)
modeltype=$(echo $1 | cut -d "_" -f2)
subtype=$(echo $1 | cut -d "_" -f3)
eventid=$(echo $1 | cut -d "_" -f4)
sim_name=$project"_"$modeltype"_"$subtype

# Working folder
work_folder="/home/ubuntu/sim"

# Create dedicated forlder for sim
mkdir $work_folder/$1

# Copy simulation base file
aws s3 cp $s3rootfolder/$project/basemodels/$modeltype/$subtype/$sim_name.zip $work_folder/$1/

# Copy simulation event file
aws s3 cp s3://hecrasmodels/pfra/$project/$modeltype/$subtype/$eventid/$sim_name.p01.tmp.hdf $work_folder/$1/

# Add cron job to monitor progress (every 5 mins)
(crontab -l ; echo "*/5 * * * * $work_folder/getpct.sh $1 $sim_name") | sort | uniq | crontab -

# unzip base data
cd $work_folder/$1
unzip -o $sim_name.zip
rm $sim_name.zip

# Start the analysis
echo "Analysis started on "$(date) > $sim_name-start.txt
#aws s3api put-object --bucket $bucket_name --key $folder_name/$2/output/
#aws s3 cp  $sim_name.txt  s3://$folder_name/$2/output/
aws s3 cp $sim_name-start.txt $s3rootfolder/$project/$modeltype/$subtype/$eventid/

RAS_BIN_PATH="/home/ubuntu/bin-v508a"

export LD_LIBRARY_PATH=$RAS_BIN_PATH:$LD_LIBRARY_PATH
$RAS_BIN_PATH/rasUnsteady64 $sim_name.c01 b01 >> $sim_name.runlog
mv $sim_name.p01.tmp.hdf $sim_name.p01.hdf

# Analysis done. Copy results back to S3
echo "Analysis completed on "$(date) > $sim_name-end.txt

aws s3 cp $sim_name-end.txt $s3rootfolder/$project/$modeltype/$subtype/$eventid/
zip $1.zip *.bco01
zip $1.zip *.dss
zip $1.zip *.ic.o01
zip $1.zip *.p01.hdf
zip $1.zip *.p01.blf
zip $1.zip *.x01
zip $1.zip *.runlog
zip $1.zip ../$1.out
aws s3 cp $1.zip $s3rootfolder/$project/$modeltype/$subtype/$eventid/

# Delete cron job - definition must much 100% one above
(crontab -l ; echo  "*/1 * * * * $work_folder/getpct.sh $1 $sim_name") | grep -v $sim_name | sort | uniq | crontab -


# cleanup
rm -r $work_folder/$1
#rm ../$1.out
exit



