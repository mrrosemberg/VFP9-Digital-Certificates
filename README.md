# VFP9-Digital-Certificates
Manage your private PKI through Visual FoxPro 9 classes.
Originally designed to work with ECC only. Option for RSA added after the tests with ECC.
You can create your own CA certificate and then use it to issue certificates for servers and clients (both TLS client authentication and SMIME Email protection). It **WILL NOT** issue certificates for code signing.

### About SysnetCertificates.dll
SysnetCertificates.dll is a C# project compiled with Visual Studio 2019 Community Edition.
Uses BouncyCastle 1.8.9 (merged) and works for both 32 and 64bit Operating Systems.
It can work as a COM Client or bridged through wwDotNetBridge (Visit [West Wind Technologies](https://www.west-wind.com/wwDotnetBridge.aspx))

**Minimum .net Version:** 4.0

### Author:
**Marcio R. Rosemberg D.Sc.**

CEO and Founder of [SYSNET Sistemas e Redes ](https://www.sysnetweb.com.br)

### Latest Release:
v.1.0.0 - 2025.08.28

### External References
EccCertificate.prg is wrapper for SysnetCertificates. It can instantiate SysnetCertificates.dll bridged by wwDotNetBridge or as a COM client transparently.

<pre>
  certBridged = NEWOBJECT('EccCertificate','EccCertificates.prg') && instantiate SysnetCertificates.dll bridged
  IF NOT EMPTY(certBridged.getLastError()) && either wwDotNetBridge.dll is not propperly registered or another issue
     messageBox(certBridged.getLastError())
     RETURN
  ENDIF
  certCOM = NEWOBJECT('EccCertificate','EccCertificate.prg','',.t.) && instantiate SysnetCertificates.dll as a COM client
  IF NOT EMPTY(certCOM.getLastError()) && SysnetCertificate.dll is not propperly registered
     messageBox(certCOMM.getLastError())
     RETURN
  ENDIF
</pre>

### Registering for COM 
Run CMD as an Administrator
<pre>
  C:\Windows\Microsoft.NET\Framework\v4.0.30319\regasm.exe SysnetCertificates.dll /tlb:SysnetCertificates.tlb /codebase
</pre>

### Examples
testECCcertificate.prg wil perform the following tasks:
1. Generate the CA Certificate (ECC 521bits, self signed with SHA512ECDSA)
2. Save the CA Certificate and Private key to a secure PKCS#12 file
3. Export the CA Certificate to ca.cer file (not the private key)
4. Create a Server Certificate (ECC 384bits, signed with the CA SHA256ECDSA Key)
5. Save the Server Certificate and Private key to a secure PKCS#12 file
6. Export the Server certificate and UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
7. Create a Client Certificate (ECC 256bits, , signed with the CA SHA256ECDSA Key)
8. Save the client Certificate and Private key to a secure PKCS#12 file
9. Export the client certificate and UNENCRYTPTED private key.
10. Renew the client certificate, keeping the original key pair.

testRSAcertificate.prg wil perform the following tasks:
1. Generate the CA Certificate (RSA 4096bits, self-signed with SHA512RSA)
2. Save the CA Certificate and Private key to a secure PKCS#12 file
3. Export the CA Certificate to ca.cer file (not the private key)
4. Create a Server Certificate (ECC 3072bits, signed with SHA256RSA)
5. Save the Server Certificate and Private key to a secure PKCS#12 file
6. Export the Server certificate and UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
7. Create a Client Certificate (ECC 2048bits, signed with SHA256RSA)
8. Save the client Certificate and Private key to a secure PKCS#12 file
9. Export the client certificate and UNENCRYTPTED private key.
10. Renew the client certificate, keeping the original key pair.

testcertificateRSAECC.prg wil perform the following tasks:
1. Generate the CA Certificate (RSA 4096bit, self-signed with SHA512RSA)
2. Save the CA Certificate and Private key to a secure PKCS#12 file
3. Export the CA Certificate to ca.cer file (not the private key)
4. Create a Server Certificate (ECC 384bits, signed with the SHA256RSA)
5. Save the Server Certificate and Private key to a secure PKCS#12 file
6. Export the Server certificate and UNENCRYTPTED private key. Necessary for Apache, NGINX, MYSQL
7. Create a Client Certificate (ECC 256bits, signed with the SHA256RSA)
8. Save the client Certificate and Private key to a secure PKCS#12 file
9. Export the client certificate and UNENCRYTPTED private key.
10. Renew the client certificate, keeping the original key pair.

### Distribution
You may distribute SysnetCertificates.dll freely with your projects.

### Warranty and Support
No Warranty or Support is provided. Use it at your own discretion and risk.
