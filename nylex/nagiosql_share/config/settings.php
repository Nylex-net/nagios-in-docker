<?php
exit;
?>
;///////////////////////////////////////////////////////////////////////////////
;
; NagiosQL
;
;///////////////////////////////////////////////////////////////////////////////
;
; Project  : NagiosQL
; Component: Database Configuration
; Website  : https://sourceforge.net/projects/nagiosql/
; Date     : January 21, 2023, 3:51 am
; Version  : 3.4.1
;
;///////////////////////////////////////////////////////////////////////////////
[db]
type         = 'mysqli'
server       = 'localhost'
port         = '3306'
database     = 'db_nagiosql_v341'
username     = 'nagiosql_user'
password     = 'nagiosql_pass'
[path]
base_url     = '/nagios/nagiosql/'
base_path    = '/usr/local/nagios/share/nagiosql/'
