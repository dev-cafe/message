rem Finally found a use for De Morgan's laws of boolean algebra!
rem We can't use logical OR in IF statements, so we check for the negation of
rem the AND (implicit when chaining IF-s) of the negation of each separate statement
set nonVSGenerator=true
if not "%GENERATOR%"=="Ninja" if not "%GENERATOR%"=="MSYS Makefiles" set nonVSGenerator=false

if "%nonVSGenerator%"=="true" (
  echo "Using non-VS generator %GENERATOR%"
  echo "Let's get MSYS64 working"

  rem upgrade the msys2 platform
  bash -lc "pacman -S --needed --noconfirm pacman-mirrors"

  rem --ask=127 is taken from https://github.com/appveyor/ci/issues/2074#issuecomment-364842018
  bash -lc "pacman -Syuu --needed --noconfirm --ask=127"

  rem we will run the tests inside pipenv
  bash -lc "pip install pipenv"

  rem more packages
  bash -lc "pacman -S --noconfirm mingw64/mingw-w64-x86_64-ninja"
  bash -lc "pacman -S --noconfirm mingw64/mingw-w64-x86_64-pkg-config"
) else (
  echo "Using VS generator %GENERATOR%"
  echo "Let's get VcPkg working"

  cd c:\tools\vcpkg
  vcpkg integrate install
  cd %APPVEYOR_BUILD_FOLDER%
)