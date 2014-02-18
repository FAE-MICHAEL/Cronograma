/*///////////////////////////////////////////////////////////////////////////////////////////
									ORDEM DE SHUTDOWN LV ORACLE
///////////////////////////////////////////////////////////////////////////////////////////*/
=============================================================================================
>RAC
=============================================================================================
1º [ORACLE ssh PROD1 E ssh PROD2]$ 			emctl stop dbconsole 
2º [ORACLE ssh PROD1 E ssh PROD2]$ 			$ORACLE_HOME/bin/srvctl stop listener -n prod1 -l LISTENER_PROD1 || $ORACLE_HOME/bin/srvctl stop listener -n prod2 -l LISTENER_PROD2 
3º [ORACLE ssh PROD1 E ssh PROD2]$ 			alter system checkpoint global; $ORACLE_HOME/bin/srvctl stop database -d prod1 || $ORACLE_HOME/bin/srvctl stop database -d prod2
4º [ORACLE ssh PROD1 E ssh PROD2]$ 			$ORACLE_HOME/bin/srvctl stop asm -n prod1 || $ORACLE_HOME/bin/srvctl stop asm -n prod2
5º [ORACLE e ROOT ssh PROD1 E ssh PROD2]$# 	$CRS_HOME/bin/crsctl check crs  || $CRS_HOME/bin/crsctl stop crs  

*PASSO 3 PARA AMBIENTE RAC NAO FUNCIONA.*
=============================================================================================
>STANDALONE (WMS)
=============================================================================================
1º [ORACLE]$ 								emctl stop dbconsole
2º [ORACLE]$ 								lsnrctl stop LISTENER 
3º [ORACLE]$ 								alter system checkpoint global; 
4º [ORACLE]$ 								shutdown immediate
							 
--Verificar status dos serviços
emctl status dbconsole
lsnrctl status LISTENER
sqlplus / as sysdba (select instance_name, status from v$instance;)

=============================================================================================
>STANDALONE (HOMOLOGACAO)
=============================================================================================
> PROD
1º [ORACLE]$ 								lsnrctl stop LISTENER 
2º [export ORACLE_SID=PROD *sysdba]$		alter system checkpoint global; 
3º [ORACLE]$								shutdown immediate 
4º [export ORACLE_SID=+ASM *sysdba]$		shutdown immediate;

> WMSPRD
1º [export ORACLE_SID=WMSPRD] 				alter system checkpoint global; 
2º [ORACLE]									SHUTDOWN IMMEDIATE 

--Verificar status dos serviços
emctl status dbconsole
lsnrctl status LISTENER
sqlplus / as sysdba (select instance_name, status from v$instance;)

/*///////////////////////////////////////////////////////////////////////////////////////////
									ORDEM DE START LV ORACLE
///////////////////////////////////////////////////////////////////////////////////////////*/

=============================================================================================
>RAC
=============================================================================================
1º [ROOT e ORACLE ssh PROD1 E ssh PROD2]$#	$CRS_HOME/bin/crsctl start crs || $CRS_HOME/bin/crsctl check crs
2º [ORACLE ssh PROD1 E ssh PROD2]$ 			$ORACLE_HOME/bin/srvctl start asm -n prod1 -i +ASM1 || $ORACLE_HOME/bin/srvctl stop asm -n prod2 -i +ASM2
3º [ORACLE ssh PROD1 E ssh PROD2]$ 			$ORACLE_HOME/bin/srvctl start database -d prod1 || $ORACLE_HOME/bin/srvctl start database -d prod2
4º [ORACLE ssh PROD1 E ssh PROD2]$ 			$ORACLE_HOME/bin/srvctl start listener -n prod1 -l LISTENER_PROD1 || $ORACLE_HOME/bin/srvctl start listener -n prod2 -l LISTENER_PROD2
5º [ORACLE ssh PROD1 E ssh PROD2]$			emctl start dbconsole 

-- Verificar serviços
/home/oracle/bin/status_rac

=============================================================================================
>STANDALONE (WMS)
=============================================================================================
1º [ORACLE]$								startup
2º [ORACLE]$								lsnrctl start LISTENER
3º [ORACLE]$								emctl start dbconsole

--Verificar status dos serviços
emctl status dbconsole
lsnrctl status LISTENER
select instance_name, status from v$instance;

=============================================================================================
>STANDALONE HOMOLOGAÇÃO 
=============================================================================================
> PROD
1º [export ORACLE_SID=+ASM *sysasm]$		startup;
2º [export ORACLE_SID=PROD *sysdba]$		startup; 
3º [ORACLE]$ 								lsnrctl start LISTENER 

> WMSPRD
1º [export ORACLE_SID=WMSPRD]				startup;

--Verificar status dos serviços
emctl status dbconsole
lsnrctl status LISTENER
select instance_name, status from v$instance;


/u01/app/oracle/product/10.2.0/db_1/prod1_prod1/sysman/log
/u01/app/oracle/product/10.2.0/db_1/serverdb_wms/sysman/log/123456789

