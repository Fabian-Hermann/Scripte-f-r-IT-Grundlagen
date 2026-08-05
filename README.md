# Scripte-f-r-IT-Grundlagen
Skripte für IT Grundlagen in Powershell.

Powershellscript for HyperV Usage to deploy Server with one Configuration.



NamingConvention: 
1. Englisch
2. Variabels in Camelcase: serverDeployment, userValidation
3. Functions in Camelcase starting with a verb: getUserInput(), validateInput(), stopService()
4. Boolian should be readable: isAdmin, hasError, isRunning
     if($hasError){
       ...
     }
