:: DELETE all subdirs called "bin" except those in node_modules.

@echo off
echo Cleaning...

for /r %%f in (obj) do (
  if exist %%f (
    echo deleting %%f ...
    rd /s /q %%f
  )
  if errorlevel 1 goto fail
)

for /r %%f in (bin) do (
  if exist %%f (
    echo %%f | findstr /i /l "node_modules \\lut\\" 1>nul
    if errorlevel 1 (
      rem NB `more` below will reset errorlevel
      more < nul > nul
      echo deleting %%f ...
      rd /s /q %%f
      if errorlevel 1 goto fail
    ) else (
      echo // skipping %%f)
    )
  )
)

goto succeed

:pop
popd

:fail
echo.
echo.
echo FAILED.

goto eof

:succeed
echo.
echo Succeeded.

:eof
echo.
