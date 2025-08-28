**********************************************************************************
* Purpose: Manage your private PKI from VFP
* Author: Marcio R. Rosemberg DSc
* Last Update: 2025-08-22
* Remarks: the Class was originally designed for ECC only. RSA added succeedingly
* You can use or modify at your own risk. 
**********************************************************************************
DEFINE CLASS eccCertificate as Custom 
        
        CommonName = '' &&& Certificate CommonName
        Email = '' &&& Certificate Email
        Organization = "" &&& Certificate Organization
        OrganizationalUnit = "" &&& Certificate OrganizationUnit
        Locality = "" &&& Certificate Locality
        State = "" &&& Certificate State or Province
        Country = '' &&& Certificate Country Code
        SanList = '' &&& Comma Separeted Subject ALternative Names. email:someuser@somefqdn MANDATORY for SMIME purposes
        hidden loBridge &&& bridge object for the wwwDotNetBridge
        loBridge = .null.
        hidden lastError &&& LastError occurred
        hidden CertObj &&& instance of the Certificate Class of the SysnetCertificates .net 4.0 Library
        CertObj = .null.
        
        *** <summary>
        *** Constructor for the class
        *** </summary>
        *** <param name="registeredASM">.t. if SysnetCertificates.dll was registered; .f. for bridged (default)</param>
        *** <remarks></remarks>
        FUNCTION init(registeredASM as Boolean)
                 this.CommonName = '' 
                 this.Email = '' 
                 this.Organization = "My Organization" 
                 this.OrganizationalUnit = "Main Office" 
                 this.Locality = "São Paulo"
                 this.State = "SP" 
                 this.Country = 'BR'
                 this.SanList = ''
                 IF ISNULL(registeredASM)
                    registeredASM = .f.
                 ENDIF 
                 IF registeredASM
                    this.startASM()
                 ELSE 
                    this.startBridged()   
                 ENDIF    
        ENDFUNC
        
        *** <summary>
        *** Instantiate SysnetCertificates.Certificate bridged by wwDotNetBridge
        *** </summary>
        *** <remarks>wwDotNetBridge.dll must be previously registered. See https://www.west-wind.com/wwDotnetBridge.aspx </remarks>
        HIDDEN PROCEDURE startBridged()
               LOCAL lbRet as Boolean
               lbRet = .t.
               TRY 
                    IF Type('this.loBridge') <> 'O'
                       do wwDotNetBridge
                       this.loBridge = GetwwDotNetBridge()
                       *this.loBridge = CreateObject("wwDotNetBridge","V4")
                    ENDIF 
                    IF Type('this.loBridge') <> 'O'
                       this.loBridge = .null.
                       this.CertObj = .null.
                       this.lastError = 'Unable to instantiate wwwDotNetBridge'
                       lbRet = .f.
                    ENDIF
                    IF lbRet    
                       this.loBridge.LoadAssembly('SysnetCertificates.dll')
                       if NOT empty(this.loBridge.cErrorMsg)
                          this.lastError ='Unable to load SysnetCertificates.dll'+CHR(13)+CHR(10)+loBridge.cErrorMsg
                          lbRet = .f.
                       ENDIF 
                    ENDIF 
                    IF lbRet
                        this.CertObj = this.loBridge.CreateInstance('SysnetCertificates.Certificate')
                        IF TYPE("this.CertObj")<>'O'
                           this.lastError ='Unable to instantiate class Certificate in SysnetCertificates.dll'
                           lbRet = .f.
                        ENDIF 
                    ENDIF
                CATCH TO objError
                      this.lastError = objError.Message
                      lbRet = .f.
                ENDTRY
                IF lbRet 
                   this.lastError = ''
                ENDIF
        ENDPROC 
        
        *** <summary>
        *** Instantiate SysnetCertificates.Certificate as a COM Object
        *** </summary>
        *** <remarks>C:\Windows\Microsoft.NET\Framework\v4.0.30319\regasm.exe SysnetCertificates.dll /tlb:SysnetCertificates.tlb /codebase</remarks>
        HIDDEN PROCEDURE startASM()
               LOCAL lbRet as Boolean
               lbRet = .t.
               TRY 
                  this.CertObj = CREATEOBJECT('SysnetCertificates.Certificate')
                  IF TYPE("this.CertObj")<>'O'
                     this.lastError ='Class SysnetCertificates.dll is not registered'
                     lbRet = .f.
                  ENDIF 
               CATCH TO objError
                     this.lastError = objError.Message
                     lbRet = .f.
               ENDTRY
               IF lbRet 
                  this.lastError = ''
               ENDIF
        ENDPROC
        
        *** <summary>
        *** Gets the Certificate Subject Properties
        *** </summary>
        *** <remarks></remarks>
        PROCEDURE getProps
               IF NOT ISNULL(this.CertObj.CommonName) AND NOT Empty(this.CertObj.CommonName)
                  this.CommonName = this.CertObj.CommonName
               ENDIF
               IF NOT ISNULL(this.CertObj.Email) AND NOT Empty(this.CertObj.Email)
                  this.Email = this.CertObj.Email
               ENDIF
               IF NOT ISNULL(this.CertObj.Organization) AND NOT Empty(this.CertObj.Organization)
                  this.Organization = this.CertObj.Organization
               ENDIF
               IF NOT ISNULL(this.CertObj.OrganizationalUnit) AND NOT Empty(this.CertObj.OrganizationalUnit)
                  this.OrganizationalUnit = this.CertObj.OrganizationalUnit
               ENDIF
               IF NOT ISNULL(this.CertObj.Locality) AND NOT Empty(this.CertObj.Locality)
                  this.Locality = this.CertObj.Locality
               ENDIF
               IF NOT ISNULL(this.CertObj.State) AND NOT Empty(this.CertObj.State)
                  this.State = this.CertObj.State
               ENDIF
               IF NOT ISNULL(this.CertObj.Country) AND NOT Empty(this.CertObj.Country)
                  this.Country = this.CertObj.Country
               ENDIF
               IF NOT ISNULL(this.CertObj.SAN) AND NOT Empty(this.CertObj.SAN)
                  this.SanList = this.CertObj.SanList
               ENDIF
        ENDPROC
        
        *** <summary>
        *** Sets the Certificate Subject Properties
        *** </summary>
        *** <remarks></remarks>
        PROCEDURE setProps
               IF NOT Empty(this.CommonName)
                  this.CertObj.CommonName = this.CommonName
               ENDIF 
               IF NOT Empty(this.Email)
                  this.CertObj.Email = this.Email
               ENDIF
               IF NOT Empty(this.Organization)
                  this.CertObj.Organization = this.Organization
               ENDIF
               IF NOT Empty(this.OrganizationalUnit)
                  this.CertObj.OrganizationalUnit = this.OrganizationalUnit
               ENDIF
               IF NOT Empty(this.Locality)
                  this.CertObj.Locality = this.Locality
               ENDIF
               IF NOT Empty(this.State)
                  this.CertObj.State = this.State
               ENDIF
               IF NOT Empty(this.Country)
                  this.CertObj.Country = this.Country
               ENDIF
               IF NOT Empty(this.SanList)
                  this.CertObj.SanList = this.SanList
               ENDIF
        ENDPROC
        
        *** <summary>
        ***  Returns the last error occurred
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getLastError() as String 
                 RETURN this.lastError
        ENDFUNC 
        
        *** <summary>
        ***  Returns the Asymmetric Cypher
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getAsymmetricKeyType() as String 
                 RETURN this.CertObj.getAsymmetricKeyType()
        ENDFUNC 
        
        *** <summary>
        *** Set Asymmetric Cypher to RSA
        *** </summary>
        *** <remarks></remarks>
        PROCEDURE setAsymmetricKeyTypeRSA()
                  this.CertObj.setAsymmetricKeyTypeRSA()
        ENDPROC
        
        *** <summary>
        *** Set Asymmetric Cypher to ECC (Default)
        *** </summary>
        *** <remarks></remarks>
        PROCEDURE setAsymmetricKeyTypeECC()
                  this.CertObj.setAsymmetricKeyTypeECC()
        ENDPROC
        
        *** <summary>
        *** Sets the size in bits of the RSA key pair
        *** </summary>
        *** <param name="int">2048, 3072 or 4096 (Default)</param>
        *** <remarks></remarks>
        FUNCTION setRSAEncryptionLength(nBits as Integer) as Boolean
               IF NOT this.CertObj.setRSAEncryptionLength(nBits)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.  
        ENDFUNC 
        
        *** <summary>
        *** Returns the RSA Key Size in bits
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getRSAKeySize() as Integer 
                 RETURN this.CertObj.getRSAKeySize()
        ENDFUNC 
        
        *** <summary>
        *** Set the signning algorithm. Either SHA512ECDSA or SHA256ECDSA (default)
        *** </summary>
        *** <param name="hashAlg">SHA512, SHA384 or SHA256 (Default)</param>
        *** <remarks></remarks>
        PROCEDURE setSignAlg(hashAlg as String)
                  DO CASE 
                     CASE Upper(hashAlg) = 'SHA512'
                          this.CertObj.setSignAlgSHA512()
                     CASE Upper(hashAlg) = 'SHA384'
                          this.CertObj.setSignAlgSHA384()     
                     OTHERWISE 
                          this.CertObj.setSignAlgSHA256() && default
                  ENDCASE
        ENDFUNC
        
        *** <summary>
        *** Returns the signing algorithm; either SHA256 (default), SHA384 or SHA512
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getSignAlg() as String 
                 RETURN Left(this.CertObj.getSignAlg(),6)
        ENDFUNC          
        
        *** <summary>
        *** Sets the size in bits of the ECC key pair
        *** </summary>
        *** <param name="nBits">192, 224, 256, 384 or 521 (Default)</param>
        *** <remarks></remarks>
        FUNCTION setEncryptionLength(nBits as Integer) as Boolean 
                 IF NOT this.CertObj.setECCEncryptionLength(nBits)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.   
        ENDFUNC 
        
        *** <summary>
        *** gets the size in bits of the key pair. Default 521
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getEncryptionLength() as Integer
                 LOCAL nRet as Integer, aux as String 
                 aux = this.CertObj.getEncryptionCurve()
                 aux = Substr(aux,5,3)
                 nRet = Int(Val(aux))
                 RETURN nRet
        ENDFUNC 
        
        *** <summary>
        *** Set the validity of the certificate issued or renewed
        *** </summary>
        *** <param name="nDays"># of days from 1 to 3650 (10 years)</param>
        *** <remarks></remarks>
        FUNCTION setValidity(nDays as Integer) as Boolean 
                 IF NOT this.CertObj.setValidity(nDays)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.   
        ENDFUNC
        
        *** <summary>
        *** Returns the validity of the certificate to be issued or renewed in days
        *** </summary>
        *** <remarks></remarks>
        FUNCTION getValidity() as Integer 
                RETURN this.CertObj.getValidity()
        ENDFUNC  
        
        *** <summary>
        *** Generates a self signed Certificate Authority Certifificate and Private Key
        *** </summary>
        *** <remarks></remarks>
        FUNCTION generateCA() as Boolean
                 this.setProps()
                 IF NOT this.CertObj.generateCA()
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC 
        
        *** <summary>
        *** Saves the CA Certificate generated or loaded into a secure PKCS#12 file
        *** </summary>
        *** <param name="outputPath">Full path of the PKCS#12 file</param>
        *** <param name="password">Password used to encrypt the Private Key</param>
        *** <remarks></remarks>
        FUNCTION saveCaToPkcs12(outputPath as String, password as String) as Boolean
                 IF IsNull(outputPath) OR Empty(outputPath)
                    this.lastError = 'Parameter outputPath is mandatory when invoking saveCaToPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF IsNull(password) OR Empty(password)
                    this.lastError = 'Parameter password is mandatory when invoking saveCaToPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.saveCaToPkcs12(outputPath, password)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC 
        
        *** <summary>
        *** Saves the CA Certificate to a .CER or .CRT file; optionally the private key (NOT RECOMMENDED)
        *** </summary>
        *** <param name="certPath">Full path of the file to save the CA Certificate with the public key only</param>
        *** <param name="keyPath">Optional - Full path of the file to save the UNENCRYPTED Private key.</param>
        *** <remarks></remarks>
        FUNCTION saveCaAsPEM(certPath as String, keyPath as String) as Boolean
                 LOCAL lbRet as Boolean
                 IF IsNull(certPath) OR Empty(certPath)
                    this.lastError = 'Parameter outputPath is mandatory when invoking saveCaToPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF Empty(keyPath)
                    lbRet = this.CertObj.saveCaAsPEM(certPath)
                 ELSE 
                    lbRet = this.CertObj.saveCaAsPEM(certPath, keyPath)
                 ENDIF 
                 IF NOT lbRet
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Load a previously created CA Certificate and Private key from a secure PKCS#12 file.
        *** </summary>
        *** <param name="pkcs12Path">Full path of the PKCS#12 file</param>
        *** <param name="password">Password to decrypt the private key</param>
        *** <remarks></remarks>
        FUNCTION loadCaFromPkcs12(pkcs12Path as String, password as String) as Boolean
                 IF IsNull(pkcs12Path) OR Empty(pkcs12Path)
                    this.lastError = 'Parameter pkcs12Path is mandatory when invoking loadCaFromPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF IsNull(password) OR Empty(password)
                    this.lastError = 'Parameter password is mandatory when invoking loadCaFromPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.loadCaFromPkcs12(pkcs12Path, password)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Issue a certificate with private key for key exchange plus Server authentication or Client authentication or SMIME
        *** </summary>
        *** <param name="forClient">.T. if the usage is for Client Authentication or SMIME; .F. for Server Authentication</param>
        *** <remarks></remarks>
        FUNCTION issueCertificate(forClient as Boolean) as Boolean
                 this.setProps()
                 IF IsNull(forClient) OR Empty(forClient)
                    forClient = .f.
                 ENDIF
                 IF NOT this.CertObj.issueCertificate(forClient)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Renews a previously loaded Server or Client Certificate.
        *** </summary>
        *** <param name="forClient">.F. for keeping the old key pair (default); .T. for new key pair</param>
        *** <remarks></remarks>
        FUNCTION renewCertificate(newKeys as Boolean) as Boolean
                 LOCAL lbRet as Boolean
                 IF ISNULL(newKeys)
                    newKeys = .f.
                 ENDIF 
                 IF NOT newKeys    
                    lbRet = this.CertObj.renewCertificate()
                 ELSE    
                    lbRet = this.CertObj.renewCertificateWithNewKeys()
                 ENDIF   
                 IF NOT lbRet
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC 
        
        *** <summary>
        *** Renews a previously loaded Server or Client Certificate generating new keys.
        *** </summary>
        *** <remarks></remarks>
        FUNCTION renewCertificateWithNewKeys() as Boolean
                 IF NOT this.CertObj.renewCertificateWithNewKeys()
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC 
        
        *** <summary>
        *** Saves the issued or renewed certificate to a PKCS#12 file.
        *** </summary>
        *** <param name="outputPath">Full path of the PKCS#12 file</param>
        *** <param name="password">Password to encrypt the private key</param>
        *** <remarks></remarks>
        FUNCTION saveCertToPkcs12(outputPath as String, password as String) as Boolean
                 IF IsNull(outputPath) OR Empty(outputPath)
                    this.lastError = 'Parameter outputPath is mandatory when invoking saveCertToPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF IsNull(password) OR Empty(password)
                    this.lastError = 'Parameter password is mandatory when invoking saveCertToPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.saveToPkcs12(outputPath, password)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Exports the Issued or Renewed Certificate
        *** </summary>
        *** <param name="filePath">Full Path of the .CER or .CRT file</param>
        *** <remarks></remarks>
        FUNCTION saveCertificateAsPem(filePath as String) as Boolean
                 IF IsNull(filePath) OR Empty(filePath)
                    this.lastError = 'Parameter filePath is mandatory when invoking saveCertificateAsPem() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.saveCertificateAsPem(filePath)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Exports the private key of the issued or renewed certificate
        *** </summary>
        *** <param name="filePath">Full Path of the .PEM or .KEY file</param>
        *** <remarks></remarks>
        FUNCTION savePrivateKeyAsPem(filePath as String) as Boolean
                 IF IsNull(filePath) OR Empty(filePath)
                    this.lastError = 'Parameter filePath is mandatory when invoking savePrivateKeyAsPem() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.savePrivateKeyAsPem(filePath)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Loads a previously saved issued Certificate
        *** </summary>
        *** <param name="filePath">Full Path of the .CER or .CRT file</param>
        *** <remarks></remarks>
        FUNCTION loadCertificateFromPem(filePath as String) as Boolean
                 IF IsNull(filePath) OR Empty(filePath)
                    this.lastError = 'Parameter filePath is mandatory when invoking loadCertificateFromPem() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.loadCertificateFromPem(filePath)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Loads the private key of a previously saved issued Certificate
        *** </summary>
        *** <param name="filePath">Full Path of the .PEM or .KEY file</param>
        *** <remarks></remarks>
        FUNCTION loadPrivateKeyFromPem(filePath as String) as Boolean
                 IF IsNull(filePath) OR Empty(filePath)
                    this.lastError = 'Parameter filePath is mandatory when invoking loadPrivateKeyFromPem() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.loadPrivateKeyFromPem(filePath)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Load a previously issued Certificate and Private key from a secure PKCS#12 file.
        *** </summary>
        *** <param name="pkcs12Path">Full path of the PKCS#12 file</param>
        *** <param name="password">Password to decrypt the private key</param>
        FUNCTION loadCertFromPkcs12(pkcs12Path as String, password as String) as Boolean
                 IF IsNull(pkcs12Path) OR Empty(pkcs12Path)
                    this.lastError = 'Parameter pkcs12Path is mandatory when invoking loadCertFromPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF IsNull(password) OR Empty(password)
                    this.lastError = 'Parameter password is mandatory when invoking loadCertFromPkcs12() method'
                    RETURN .f.
                 ENDIF 
                 IF NOT this.CertObj.loadCertFromPkcs12(pkcs12Path, password)
                    this.lastError = this.CertObj.getLastError()
                    RETURN .f.
                 ENDIF 
                 RETURN .t.
        ENDFUNC
        
        *** <summary>
        *** Gets all relevant certificate data as a JSON formatted string. Blank if an error occurs and sets lastError
        *** </summary>
           *** <remarks></remarks>
        FUNCTION getCertificateAsJSON() as String 
                 LOCAL lcRet as String 
                 lcRet = this.CertObj.exportCertificateToJSON()
                 IF EMPTY(lcRet)
                    this.lastError = this.CertObj.getLastError()
                 ENDIF    
                 RETURN lcRet
        ENDFUNC 
 ENDDEFINE 