
  
cd \program files (x86)\Java\jre1.8.0_73\lib\security



keytool -importcert  -alias fdadevrtca -storepass changeit  -file FDA_Dev_Ent_CA.cer -trustcacerts -keystore cacerts


keytool -importcert -alias hhsdomdevrtca -storepass changeit -file HHS_Dom_Dev_Root_CA.cer -trustcacerts -keystore cacerts 



rem keytool -list  -keystore cacerts -storepass changeit

rem pause