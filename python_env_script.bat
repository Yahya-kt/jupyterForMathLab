@echo off
setlocal

REM Python Installation Section
set PY_VERSION=3.13.3
set PY_INSTALLER=python-%PY_VERSION%-amd64.exe
set PY_URL=https://www.python.org/ftp/python/3.13.3/python-3.13.3-amd64.exe
set "CURRENT_DIR=%~dp0"

REM Step 1: Check if Python is already installed
python --version >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Python is already installed.
) ELSE (
    echo Python not found. Downloading Python %PY_VERSION%...
    powershell -Command "Invoke-WebRequest -Uri %PY_URL% -OutFile %PY_INSTALLER%"
    IF NOT EXIST %PY_INSTALLER% (
        echo Failed to download the installer.
        pause
        exit /b
    )
    echo Installing Python silently...
    %PY_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    IF %ERRORLEVEL% NEQ 0 (
        echo Python installation failed.
        pause
        exit /b
    )
    del %PY_INSTALLER%
)

REM Step 2: Create venv if not exists
IF EXIST "%CURRENT_DIR%jupyter\Scripts" (
    echo Virtual environment already exists.
) ELSE (
    echo Creating virtual environment...
    python -m venv "%CURRENT_DIR%jupyter"
    IF NOT EXIST "%CURRENT_DIR%jupyter\Scripts\activate.bat" (
        echo Failed to create virtual environment.
        pause
        exit /b
    )
)

REM Step 3: Activate venv
echo Activating virtual environment...
call "%CURRENT_DIR%jupyter\Scripts\activate.bat"

REM Step 4: Check if Jupyter is installed
pip show notebook >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Jupyter Notebook and packages already installed.
) ELSE (
    echo Installing Jupyter Notebook and required libraries...
    python -m pip install --upgrade pip
    python -m pip install notebook nbconvert numpy sympy scipy matplotlib pandas
)

REM Step 5: Launch Jupyter
echo Launching Jupyter Notebook...
start jupyter notebook

REM MiKTeX Installation Section (MiKTeX)
set download_url=https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-24.1-x64.exe

REM Step 6: Check if MiKTeX is installed by checking for the "latex" command
where latex >nul 2>nul
if %errorlevel% equ 0 (
    echo MiKTeX is already installed.
    goto :end
)

REM MiKTeX is not installed, so we proceed to download and install it
echo MiKTeX is not installed. Proceeding with the installation...

REM Step 7: Download MiKTeX installer
echo Downloading MiKTeX installer...
powershell -Command "Invoke-WebRequest -Uri %download_url% -OutFile miktex-setup-x64.exe"

REM Step 8: Install MiKTeX
echo Installing MiKTeX...
start /wait miktex-setup-x64.exe --install --verbose --global

REM Step 9: Clean up by deleting the installer
echo Cleaning up the installer...
del miktex-setup-x64.exe

REM Step 10: Verify MiKTeX installation
echo Verifying MiKTeX installation...
latex --version

:end
echo Installation or check completed.
pause
endlocal
