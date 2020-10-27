@echo off
echo Naive local build script that mimics what CI will do.
echo.
echo `localbuild`        build everything
echo `localbuild clean`  *delete* node_modules, obj, and bin folders
echo `localbuild dotnet` just the dotnet bits
echo `localbuild npm`    just the npm bits
echo `localbuild quick`  skip npm restores
echo `localbuild test`   just run the tests
echo.
echo.
if '%1'=='help' goto succeed
if '%1'=='/?' goto succeed
if '%1'=='-h' goto succeed

if not '%APPSETTING_NPM_TOKEN%'=='' goto SkipAuthToken
if not exist "%USERPROFILE%\.npmrc" goto SkipAuthToken
echo.
echo ********** Using your auth token for myget package restore **********
echo.
@for /f "tokens=2 delims==" %%f in ('find /i /n "authToken=" "%USERPROFILE%\.npmrc"') do set APPSETTING_NPM_TOKEN=%%f

:SkipAuthToken

:: Jump straight to tests if desired
if '%1'=='test' goto Tests
if '%1'=='tests' goto Tests

:: Allow us to skip a restore because it takes a while!
if '%1'=='quick' goto SkipNpmRestore
if '%1'=='dotnet' goto SkipNpmRestore
if '%1'=='clean' goto Clean

:: default is restore (skip clean)

goto Restore

:Clean
echo Deleting any node_modules...
rd /s /q node_modules
del package-lock.json

echo Deleting any bin and obj folders...
for /d %%f in (src\*) do (
  echo.
  echo Delete "%%f's ./bin & ./obj"
  echo.
  rd /s /q "%%f\bin"
  if errorlevel 1 goto fail
  rd /s /q "%%f\obj"
  if errorlevel 1 goto fail
)

goto succeed

:Restore
if not exist src\*.web goto SkipNpmRestore
echo.
echo ********** Restoring Packages **********
echo.
pushd src\*.web
call npm install
if errorlevel 1 goto pop
popd

if '%1'=='npm' goto Build

:SkipNpmRestore
echo.
echo ********** dotnet restore **********
echo.
echo dotnet restore
echo.
dotnet restore

:Build
if '%1'=='dotnet' goto dotnet

echo.
echo ********** Building **********

if not exist src\*.web goto dotnet
pushd src\*.web
call npm run build
if errorlevel 1 goto pop
popd

if '%1'=='npm' goto Tests

:dotnet
echo.
echo Building solution in "Release" configuration.
echo.
dotnet build -c Release --force --no-restore
if errorlevel 1 goto fail

:Tests
if '%1'=='dotnet' goto dotnettests

echo.
echo ********** Testing **********

if not exist src\*.web goto dotnettests
pushd src\*.web
call npm run test
if errorlevel 1 goto pop
popd

if '%1'=='npm' goto succeed

:dotnettests
echo.
echo Running dotnet tests (./tests/**/*.csproj in their "Release" configuration).
echo.
for /r . %%f in (*.Tests.csproj) do (
  echo.
  echo Testing "%%f"
  echo.
  dotnet test -c Release --no-build --no-restore %%f
  if errorlevel 1 goto fail
)

goto succeed

:pop
popd

:fail
echo.
echo.
echo BUILD FAILED.

goto eof

:succeed
echo.
echo Build succeeded.

:eof
echo.
