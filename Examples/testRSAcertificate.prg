LOCAL rsa as Object 
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
rsa = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(rsa.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(rsa.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT rsa.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
rsa.setAsymmetricKeyTypeRSA() && uses RSA
* Sets the size of the key in bits
IF NOT rsa.setRSAEncryptionLength(3072)
   MESSAGEBOX('Error setting the encryption length. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the signing algorithm SHA-256(RSA)
IF NOT rsa.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Set the certificate subject fields
rsa.CommonName = 'server.mycompany.local'
rsa.Email = 'support@mycompany.local'
rsa.Locality = 'Rio de Janeiro'
rsa.State = 'RJ'
rsa.Organization = 'My Company'
rsa.OrganizationalUnit = 'Server Farm'
rsa.Country = 'BR'
* Set the certificate Alternative Names
rsa.SanList = 'mycompany.local, *.mycompany.local, localhost, 192.168.0.1'
* Set the certificate validity
IF NOT rsa.setvalidity(180) && 6 months
   MESSAGEBOX('Error setting the certificate validity. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Issue the certificate, signed with the ca private key
IF NOT rsa.issueCertificate(.f.) && .F. for server
   MESSAGEBOX('Error issuing the server certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the Server Certificate and Private key to a secure PKCS#12 file
IF NOT rsa.saveCertToPkcs12('server.p12','Change-me$123')
   MESSAGEBOX('Error saving the Server Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the Server certificate and private key 
IF NOT rsa.saveCertificateAsPem('server.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the Server Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT rsa.savePrivatekeyAsPem('server.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the Server Private Key. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE rsa
*** All done

******************************************
* Example 3: Create a Client Certificate
******************************************
rsa = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(rsa.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(rsa.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT rsa.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
rsa.setAsymmetricKeyTypeRSA() && uses RSA
* Sets the size of the key in bits
IF NOT rsa.setRSAEncryptionLength(2048)
   MESSAGEBOX('Error setting the encryption length. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Sets the signing algorithm SHA-256(ECDSA)
IF NOT rsa.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Set the certificate subject fields
rsa.CommonName = 'Employee Name-ID: 123456'
rsa.Email = 'emplyoee@mycompany.local'
rsa.Locality = 'São Paulo'
rsa.State = 'SP'
rsa.Organization = 'My Company'
rsa.OrganizationalUnit = 'Branch Office'
rsa.Country = 'BR'
* Set the certificate Alternative Names
*SanList = "email:emplyoee@mycompany.local, Employee_Name.company.local, upn:emplyoee@mycompany.local, uri:urn:Employee_Name:123456"
rsa.SanList = 'email:='+rsa.Email+', otherName: upn:'+rsa.Email+', uri:urn:Employee_Name:123456, Employee_Name.company.local'
* Set the certificate validity
IF NOT rsa.setvalidity(90) && 3 months
   MESSAGEBOX('Error setting the certificate validity. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Issue the certificate, signed with the ca private key
IF NOT rsa.issueCertificate(.t.) && .T. for client
   MESSAGEBOX('Error issuing the client certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the client Certificate and Private key to a secure PKCS#12 file
IF NOT rsa.saveCertToPkcs12('client.p12','Change-me$123')
   MESSAGEBOX('Error saving the client Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the client certificate and private key 
IF NOT rsa.saveCertificateAsPem('client.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the client Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT rsa.savePrivatekeyAsPem('client.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the client Private Key. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE rsa
*** All done

******************************************
* Example 4: Renew a Client Certificate
******************************************
rsa = NEWOBJECT('EccCertificate','EccCertificate.prg')
IF NOT EMPTY(rsa.getLastError()) && something went wrong while initializing wwDotNet.dll or EccCertificate.dll
   MESSAGEBOX(rsa.getLastError(),0+16,'Exception')
   RETURN
ENDIF
* load the CA Certificate and Private Key from PKCS#12 file.
IF NOT rsa.loadcafrompkcs12('ca.p12','Change-me$123')
   MESSAGEBOX('Error loading the CA Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* load the Certificate to be renewed
IF NOT rsa.loadCertificateFromPem('client.cer')
   MESSAGEBOX('Error loading the Certificate to be renewed. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* load the Certificate private key (No need, since we are keeping the key pair. Demonstrates the keys are kept)
* When loading the prvate key, consider the use of the method rsa.loadCertFromPkcs12(pkcs12Path as String, password as String)
* No need to specify the subject DN fields. They will be loaded from thge supplied certificate
IF NOT rsa.loadPrivateKeyFromPem('client.key')
   MESSAGEBOX('Error loading the Private Key. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
* Sets the signing algorithm SHA-256(ECDSA)
IF NOT rsa.setSignAlg('sha256')
   MESSAGEBOX('Error setting the signing algorithm. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF
IF NOT rsa.setvalidity(120) && 4 months
   MESSAGEBOX('Error setting the certificate validity. '+rsa.getLastError(),0+48,'Error')
   RETURN 
ENDIF    
* Renew the certificate keeping the key pair
IF NOT rsa.renewCertificate(.F.) && false for keeping the key pair. .T. for new keys
   MESSAGEBOX('Error renewing certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Save the renewed Certificate and Private key to a secure PKCS#12 file. For this to work, the prvivate key must be loaded.
IF NOT rsa.saveCertToPkcs12('renewed.pfx','Change-me$123')
   MESSAGEBOX('Error saving the renewed Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
* Export the client certificate and private key 
IF NOT rsa.saveCertificateAsPem('renewed.cer') && or .crt or .pem
   MESSAGEBOX('Error exporting the renewed Certificate. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
IF NOT rsa.savePrivatekeyAsPem('renewed.key') && or .crt or .pem; UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
   MESSAGEBOX('Error exporting the renewed Private Key. '+rsa.getLastError(),0+48,'Error')
   RETURN
ENDIF
RELEASE rsa
*** All done
