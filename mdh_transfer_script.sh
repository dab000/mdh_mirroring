#!/bin/bash
#Contact rchelp@fas.harvard.edu for help with this transfer process and reference RT Ticket # 87048
#This script is executed by a user-space crontab on rclogin05 by RC user dbarnhart

rm /n/fawzi_lab/mdh_transfer_scripts/latestrun.log
#First copy mdh_current to mdh backup deleting extraneous files from the receiving directory
rsync -a --delete /n/fawzi_lab/mdh_current/* /n/fawzi_lab/mdh_backup

#stage files from haven.bwh.harvard.edu (this minimizes the amount of time that the files will not be in their expected directory /n/fawzi_lab/mdh_current) Stage the files in scratch directory and then use rsync to quickly update the mdh_current (using delta alorithm)


rm -rf /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_scratch/* #make sure its empty before we sftp into it 

#sftp is the only option for transferring files from haven
/usr/local/openssh-7.0p1_openssl-1.0.2d_tcpwrap/bin/sftp -r -b /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_batch_file.txt -i ~dbarnhart/.ssh/id_rsa sfdba@haven.bwh.harvard.edu

# Now rsync from the scratch location to the expected location deleting extraneous files in the receiving directory (--delete)
# and removing succesfully transfered files from the source directory (--remove-source-files)
rsync -a --remove-source-files --delete /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_scratch/* /n/fawzi_lab/mdh_current
rm /n/fawzi_lab/mdh_current/date_transferred_to_odyssey
echo "This data was received from the channing on: " >> /n/fawzi_lab/mdh_current/date_transferred_to_odyssey
date >> /n/fawzi_lab/mdh_current/date_transferred_to_odyssey

