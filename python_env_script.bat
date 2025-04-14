@echo off
setlocal

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
pause
endlocal
