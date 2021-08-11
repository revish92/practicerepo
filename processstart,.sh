#!/bin/bash
 
FILEBEATPROCESS()
{
NO_FILEBEAT_PROCESSES=$(ps -ef | grep "filebeat" | grep -v "grep" | wc -l)
if [ ${NO_FILEBEAT_PROCESSES} -gt 0 ] ; then
echo "`date` There are Filebeat processes still running: Proceeding Next" >> /root/Script_logs/status
exit 0
else
cd /data/software/ELK/filebeat-6.3.1-linux-x86_64/
sudo -H -u elkuser bash -c 'sh 00.start.filebeat.sh'
echo "`date` Filebeat has been successfully started " >> /root/Script_logs/status
fi
}
 
Checking()
{
sleep 30
cd /data/jboss-prod/standalone/deployments
ls -l *.isdeploying >> /root/Script_logs/samp
if [ -s /root/Script_logs/samp ] ; then
echo "`date`isdeploying File are there , Waiting 30 seconds" >> /root/Script_logs/status
rm -rf /root/Script_logs/samp
return 1;
else
echo "`date` Jboss has been successfully Started" >> /root/Script_logs/status
SSOPROCESS
DISCOVERYPROCESS
GATEWAYPROCESS
FILEBEATPROCESS
fi
}
 
 
 
 
SSOPROCESS()
{
NO_SSO_PROCESSES=$(ps -ef | grep "SSO" | grep -v "grep" | wc -l)
if [ ${NO_SSO_PROCESSES} -gt 0 ] ; then
echo "`date` There are SSO processes still running: Proceeding Next" >> /root/Script_logs/status
else
cd /data/software/gateway/
sudo -H -u niitpoweruser bash -c 'sh sso.sh'
echo "`date`SSO has been successfully started " >> /root/Script_logs/status
fi
}
DISCOVERYPROCESS()
{
NO_DISCOVERY_PROCESSES=$(ps -ef | grep "Discovery" | grep -v "grep" | wc -l)
if [ ${NO_DISCOVERY_PROCESSES} -gt 0 ] ; then
echo "`date` There are Discovery processes still running: Proceeding Next" >> /root/Script_logs/status
else
cd /data/software/gateway
sudo -H -u niitpoweruser bash -c 'sh discovery.sh'
echo "`date` Discovery has been successfully started " >> /root/Script_logs/status
fi
}
GATEWAYPROCESS()
{
NO_GATEWAY_PROCESSES=$(ps -ef | grep "Gateway" | grep -v "grep" | wc -l)
if [ ${NO_GATEWAY_PROCESSES} -gt 0 ] ; then
echo "`date` There are Gateway processes still running: Proceeding Next" >> /root/Script_logs/status
else
cd /data/software/gateway
sudo -H -u niitpoweruser bash -c 'sh gateway.sh'
echo "`date` Gateway has been successfully started " >> /root/Script_logs/status
fi
}
 
#MAIN PROGRAM
NO_Jboss_PROCESSES=$(ps -ef | grep "jboss-prod" |grep standalon| grep -v "grep" | wc -l)
if [ ${NO_Jboss_PROCESSES} -gt 0 ] ; then
echo "`date` Jboss Processes Are ALready running" >> /root/Script_logs/status
exit 0
else
sudo -H -u wildfly bash -c 'sh /data/jboss-prod/bin/00.start.sa.full.sh'
echo "`date`Sleeping for 30seconds to wait for JBoss process to start..." >> /root/Script_logs/status
Checking
until Checking ; do : ; done
fi
