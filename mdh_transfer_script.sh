#!/bin/bash
#Contact rchelp@fas.harvard.edu for help with this transfer process and reference RT Ticket # 87048
#This script is executed by a user-space crontab on rclogin05 by RC user dbarnhart


# Remove previous log
rm /n/fawzi_lab/mdh_transfer_scripts/latestrun.log


#First copy the currently in place directory to a single backup deleting extraneous files from the receiving directory
#This gives you two copies the current one and the previous weeks - this can be abandoned if space becomes an issue
rsync -a --delete /n/fawzi_lab/mdh_current/* /n/fawzi_lab/mdh_backup
rsync -a --delete /n/fawzi_lab/pns_current/* /n/fawzi_lab/pns_backup
rsync -a --delete /n/fawzi_lab/macros/* /n/fawzi_lab/macros_backup

# Stage files from haven.bwh.harvard.edu in a scratch directory 
# This minimizes the amount of time that the files will not be in their expected directories.
# once staging is complete use rsync to quickly update the current directory (using delta alorithm)

#Clear out the staging directory before pulling data from haven
rm -rf /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_scratch/* #make sure its empty before we sftp into it 
rm -rf /n/fawzi_lab/mdh_transfer_scripts/pns_transfer_scratch/*
rm -rf /n/fawzi_lab/mdh_transfer_scripts/macros_transfer_scratch/*

# SFTP is the only option for transferring files from haven
# The batch file mdh_transfer_batch_file.txt coordinates from where and to where the sftp command gets and puts data
/usr/local/openssh-7.0p1_openssl-1.0.2d_tcpwrap/bin/sftp -r -b /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_batch_file.txt -i ~dbarnhart/.ssh/id_rsa sfdba@haven.bwh.harvard.edu

# Now rsync from the scratch location to the expected location deleting extraneous files in the receiving directory (--delete)
# and removing succesfully transfered files from the source directory (ie the scratch dir) (--remove-source-files)

#MDH
rsync -a --remove-source-files --delete /n/fawzi_lab/mdh_transfer_scripts/mdh_transfer_scratch/* /n/fawzi_lab/mdh_current
rm /n/fawzi_lab/mdh_current/date_transferred_to_odyssey

#PNS 
rsync -a --remove-source-files --delete /n/fawzi_lab/mdh_transfer_scripts/pns_transfer_scratch/* /n/fawzi_lab/pns_current
rm /n/fawzi_lab/pns_current/date_transferred_to_odyssey

#macros
rsync -a --remove-source-files --delete /n/fawzi_lab/mdh_transfer_scripts/macros_transfer_scratch/* /n/fawzi_lab/macros
rm /n/fawzi_lab/macros/date_transferred_to_odyssey

#finally put a timestamp on the most recent transfer

#MDH
echo "This data was received from haven on: " >> /n/fawzi_lab/mdh_current/date_transferred_to_odyssey
date >> /n/fawzi_lab/mdh_current/date_transferred_to_odyssey

#PNS
echo "This data was received from haven on: " >> /n/fawzi_lab/pns_current/date_transferred_to_odyssey
date >> /n/fawzi_lab/pns_current/date_transferred_to_odyssey

#macros
echo "This data was recieved from haven on :" >> /n/fawzi_lab/macros/date_transferred_to_odyssey
date >> /n/fawzi_lab/macros/date_transferred_to_odyssey
