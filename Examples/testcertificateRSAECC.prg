LOCAL ecc, rsa as Object 
**************************
* Example 1: Create a CA
**************************
rsa = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(rsa.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(rsa.getLastError(),0+16,'Exception')
   RETURN 
ENDIF    
rsa.setAsymmetricKeyTypeRSA() && uses RSA
* Sets the size of the key in bits
IF NOT rsa.setRSAEncryptionLength(4096)
   MESSAGEBOX('Error setting the encryption length. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the signing algorithm SHA-512(RSA)
IF NOT rsa.setSignAlg('sha512')
   MESSAGEBOX('Error setting the signing algorithm. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Set the certificate subject fields
rsa.CommonName = 'myCompany.local'
rsa.Email = 'admin@mycompany.local'
rsa.Locality = 'Rio de Janeiro'
rsa.State = 'RJ'
rsa.Organization = 'My Company-RSA'
rsa.OrganizationalUnit = 'My Company - Certification Authority'
rsa.Country = 'BR'
* Set the certificate validity
IF NOT rsa.setvalidity(730) && 2 years
   MESSAGEBOX('Error setting the certificate validity. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Generate the CA Certificate
IF NOT rsa.generateCA()
   MESSAGEBOX('Error creating CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the CA Certificate and Private key to a secure PKCS#12 file
IF NOT rsa.saveCaToPkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error saving the CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the CA Certificate. No need to export the private key
IF NOT rsa.savecaaspem('ca.cer')
   MESSAGEBOX('Error exporting the CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE rsa
*** All done

******************************************
* Example 2: Create a Server Certificate
******************************************
ecc = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(ecc.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(ecc.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT ecc.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the size of the key in bits
IF NOT ecc.setencryptionlength(384)
   MESSAGEBOX('Error setting the encryption length. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the signing algorithm SHA-256(ECDSA)
IF NOT ecc.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Set the certificate subject fields
ecc.CommonName = 'server.mycompany.local'
ecc.Email = 'support@mycompany.local'
ecc.Locality = 'Rio de Janeiro'
ecc.State = 'RJ'
ecc.Organization = 'My Company'
ecc.OrganizationalUnit = 'Server Farm'
ecc.Country = 'BR'
* Set the certificate Alternative Names
ecc.SanList = 'mycompany.local, *.mycompany.local, localhost, 192.168.0.1'
* Set the certificate validity
IF NOT ecc.setvalidity(180) && 6 months
   MESSAGEBOX('Error setting the certificate validity. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Issue the certificate, signed with the ca private key
IF NOT ecc.issueCertificate(.f.) && .F. for server
   MESSAGEBOX('Error issuing the server certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the Server Certificate and Private key to a secure PKCS#12 file
IF NOT ecc.saveCertToPkcs12('server.p12','Change-me$123')
   MESSAGEBOX('Error saving the Server Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the Server certificate and private key 
IF NOT ecc.saveCertificateAsPem('server.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the Server Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT ecc.savePrivatekeyAsPem('server.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the Server Private Key. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE ecc
*** All done

******************************************
* Example 3: Create a Client Certificate
******************************************
ecc = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(ecc.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(ecc.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT ecc.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the size of the key in bits
IF NOT ecc.setencryptionlength(256)
   MESSAGEBOX('Error setting the encryption length. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the signing algorithm SHA-256(ECDSA)
IF NOT ecc.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Set the certificate subject fields
ecc.CommonName = 'Employee Name-ID: 123456'
ecc.Email = 'emplyoee@mycompany.local'
ecc.Locality = 'São Paulo'
ecc.State = 'SP'
ecc.Organization = 'My Company'
ecc.OrganizationalUnit = 'Branch Office'
ecc.Country = 'BR'
* Set the certificate Alternative Names
* Do not use spaces 
ecc.SanList = "email:emplyoee@mycompany.local, Employee_Name.company.local, upn:emplyoee@mycompany.local, uri:urn:Employee_Name:123456"
* Set the certificate validity
IF NOT ecc.setvalidity(90) && 3 months
   MESSAGEBOX('Error setting the certificate validity. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Issue the certificate, signed with the ca private key
IF NOT ecc.issueCertificate(.t.) && .T. for client
   MESSAGEBOX('Error issuing the client certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the client Certificate and Private key to a secure PKCS#12 file
IF NOT ecc.saveCertToPkcs12('client.p12','Change-me$123')
   MESSAGEBOX('Error saving the client Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the client certificate and private key 
IF NOT ecc.saveCertificateAsPem('client.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the client Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT ecc.savePrivatekeyAsPem('client.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the client Private Key. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE ecc
*** All done

******************************************
* Example 4: Renew a Client Certificate
******************************************
ecc = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(ecc.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(ecc.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT ecc.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* load the Certificate to be renewed
IF NOT ecc.loadCertificateFromPem('client.cer')
   MESSAGEBOX('Error loading the Certificate to be renewed. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* load the Certificate private key (No need, since we are keeping the key pair. Demonstrates the keys are kept)
* When loading the prvate key, consider the use of the method ecc.loadCertFromPkcs12(pkcs12Path as String, password as String)
* No need to specify the subject DN fields. They will be loaded from thge supplied certificate
IF NOT ecc.loadPrivateKeyFromPem('client.key')
   MESSAGEBOX('Error loading the Private Key. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Sets the signing algorithm SHA-256(ECDSA)
IF NOT ecc.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF
IF NOT ecc.setvalidity(120) && 4 months
   MESSAGEBOX('Error setting the certificate validity. '+ecc.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Renew the certificate keeping the key pair
IF NOT ecc.renewCertificate(.F.) && false for keeping the key pair. .T. for new keys
   MESSAGEBOX('Error renewing certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the renewed Certificate and Private key to a secure PKCS#12 file. For this to work, the prvivate key must be loaded.
IF NOT ecc.saveCertToPkcs12('renewed.pfx','Change-me$123')
   MESSAGEBOX('Error saving the renewed Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the client certificate and private key 
IF NOT ecc.saveCertificateAsPem('renewed.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the renewed Certificate. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT ecc.savePrivatekeyAsPem('renewed.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the renewed Private Key. '+ecc.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE ecc
*** All done
