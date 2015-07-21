@ECHO OFF

REM **Check provider readyness
ECHO ***PCPTool(GetVersion)
PCPTool GetVersion
if ERRORLEVEL 1 goto :FAILURE
ECHO.

ECHO ***PCPTool(GetPCRs)
PCPTool GetPCRs goodPcrs
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **Create new keys on the PCP Provider
ECHO ***PCPTool(CreateKey)
PCPTool CreateKey pcptestkey1
if ERRORLEVEL 1 goto :FAILURE
ECHO.
ECHO ***PCPTool(CreateKey)
PCPTool CreateKey pcptestkey2 MySuperSecretUsagePIN 
if ERRORLEVEL 1 goto :FAILURE
ECHO.
ECHO ***PCPTool(CreateKey)
PCPTool CreateKey pcptestkey3 "" "" 0x0000ffff goodPcrs
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **Enumarate keys in the provider
ECHO ***PCPTool(EnumerateKeys)
PCPTool EnumerateKeys
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **Export public key from provider
ECHO ***PCPTool(GetPubKey)
PCPTool GetPubKey pcptestAIK Aikpub
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **Get key attestation
ECHO ***PCPTool(GetKeyAttestation)
PCPTool GetKeyAttestation pcptestkey1 pcptestAIK pcptestkey1Attest ThisIsANonceProvidedFromTheServer
if ERRORLEVEL 1 goto :FAILURE
ECHO.
ECHO ***PCPTool(GetKeyAttestation)
PCPTool GetKeyAttestation pcptestkey2 pcptestAIK pcptestkey2Attest ThisIsANonceProvidedFromTheServer MySuperSecretUsagePIN
if ERRORLEVEL 1 goto :FAILURE
ECHO.
ECHO ***PCPTool(GetKeyAttestation)
PCPTool GetKeyAttestation pcptestkey3 pcptestAIK pcptestkey3Attest ThisIsANonceProvidedFromTheServer
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **validate key attestation
ECHO ***PCPTool(ValidateKeyAttestation)
for %%N in (pcptestkey1 pcptestkey2) do (
	PCPTool ValidateKeyAttestation %%NAttest Aikpub ThisIsANonceProvidedFromTheServer
	if ERRORLEVEL 1 goto :FAILURE
)
ECHO.
ECHO ***PCPTool(ValidateKeyAttestation)
PCPTool ValidateKeyAttestation pcptestkey3Attest Aikpub ThisIsANonceProvidedFromTheServer 0x0000ffff goodPcrs
if ERRORLEVEL 1 goto :FAILURE
ECHO.

REM **get key properties
ECHO ***PCPTool(GetKeyProperties)
for %%N in (pcptestkey1 pcptestkey2 pcptestkey3) do (
	PCPTool GetKeyProperties %%NAttest
	if ERRORLEVEL 1 goto :FAILURE
)
ECHO.

REM **Delete keys from provider
ECHO ***PCPTool(DeleteKey)
for %%N in (pcptestkey1 pcptestkey2 pcptestkey3) do (
	PCPTool DeleteKey %%N
	if ERRORLEVEL 1 goto :FAILURE
)
ECHO.

REM **Cleanup
del pcptestkey1 pcptestkey2 pcptestkey3 2>NUL

ECHO ***TEST PASSED***
goto :EOF
:FAILURE
ECHO ***TEST FAILED***
:EOF