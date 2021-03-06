## # vcpkg_find_acquire_program
##
## Download or find a well-known tool.
##
## ## Usage
## ```cmake
## vcpkg_find_acquire_program(<VAR>)
## ```
## ## Parameters
## ### VAR
## This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.
##
## ## Notes
## The current list of programs includes:
##
## - 7Z
## - BISON
## - FLEX
## - GASPREPROCESSOR
## - PERL
## - PYTHON2
## - PYTHON3
## - JOM
## - MESON
## - NASM
## - NINJA
## - YASM
##
## Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
include(vcpkg_acquire_msys)
function(vcpkg_find_acquire_program VAR)
  if(${VAR} AND NOT ${VAR} MATCHES "-NOTFOUND")
    return()
  endif()

  unset(NOEXTRACT)
  unset(SUBDIR)
  unset(REQUIRED_INTERPRETER)

  vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
  vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)

  if(VAR MATCHES "PERL")
    vcpkg_acquire_msys(MSYS_ROOT)
    vcpkg_execute_required_process(
        COMMAND ${MSYS_ROOT}/usr/bin/bash.exe --noprofile --norc -c 'PATH=/usr/bin:\$PATH pacman -Sy --noconfirm --needed perl'
        WORKING_DIRECTORY ${MSYS_ROOT}
        LOGNAME acquire-perl-${TARGET_TRIPLET}
    )
    set(PERL "${MSYS_ROOT}/usr/bin/perl.exe" PARENT_SCOPE)
    return()
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.12.02)
    set(URL "http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip")
    set(ARCHIVE "nasm-2.12.02-win32.zip")
    set(HASH df7aaba094e17832688c88993997612a2e2c96cc3dc14ca3e8347b44c7762115f5a7fc6d7f20be402553aaa4c9e43ddfcf6228f581cfe89289bae550de151b36)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(PATHS ${DOWNLOADS}/tools/yasm)
    set(URL "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe")
    set(ARCHIVE "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH 850b26be5bbbdaeaf45ac39dd27f69f1a85e600c35afbd16b9f621396b3c7a19863ea3ff316b025b578fce0a8280eef2203306a2b3e46ee1389abb65313fb720)
  elseif(VAR MATCHES "PYTHON3")
    set(PROGNAME python)
    set(PATHS ${DOWNLOADS}/tools/python)
    set(URL "https://www.python.org/ftp/python/3.5.3/python-3.5.3-embed-win32.zip")
    set(ARCHIVE "python-3.5.3-embed-win32.zip")
    set(HASH c8cfdc09d052dc27e4380e8e4bf0d32a4c0def7e03896c1fa6cabc26dde78bb74dbb04e3673cc36e3e307d65a1ef284d69174f0cc80008c83bc6178f192ac5cf)
  elseif(VAR MATCHES "PYTHON2")
    find_program(PYTHON2 NAMES python2 python PATHS C:/python27 c:/Python27amd64 ENV PYTHON)
    if(NOT PYTHON2 MATCHES "NOTFOUND")
        execute_process(
            COMMAND ${PYTHON2} --version
            OUTPUT_VARIABLE PYTHON_VER_CHECK_OUT
            ERROR_VARIABLE PYTHON_VER_CHECK_ERR
        )
        set(PYTHON_VER_CHECK "${PYTHON_VER_CHECK_OUT}${PYTHON_VER_CHECK_ERR}")
        debug_message("PYTHON_VER_CHECK=${PYTHON_VER_CHECK}")
        if(NOT PYTHON_VER_CHECK MATCHES "Python 2.7")
            set(PYTHON2 PYTHON2-NOTFOUND)
            find_program(PYTHON2 NAMES python2 python PATHS C:/python27 ENV PYTHON NO_SYSTEM_ENVIRONMENT_PATH)
        endif()
    endif()
    if(PYTHON2 MATCHES "NOTFOUND")
        message(FATAL_ERROR "Python 2.7 was not found in the path or by searching inside C:\\Python27.\n"
        "There is no portable redistributable for Python 2.7, so you will need to install the MSI located at:\n"
        "    https://www.python.org/ftp/python/2.7.13/python-2.7.13.msi\n"
        )
    endif()
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-2.4.1-1-x86/bin)
    set(URL https://github.com/oneclick/rubyinstaller2/releases/download/2.4.1-1/rubyinstaller-2.4.1-1-x86.7z)
    set(ARCHIVE rubyinstaller-2.4.1-1-x86.7z)
    set(HASH b51112e9b58cfcbe8cec0607e8a16fff6a943d9b4e31b2a7fbf5df5f83f050bf0a4812d3dd6000ff21a3d5fd219cd0a309c58ac1c1db950a9b0072405e4b70f5)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.2")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL "http://download.qt.io/official_releases/jom/jom_1_1_2.zip")
    set(ARCHIVE "jom_1_1_2.zip")
    set(HASH 830cd94ed6518fbe4604a0f5a3322671b4674b87d25a71349c745500d38e85c0fac4f6995242fc5521eb048e3966bb5ec2a96a06b041343ed8da9bba78124f34)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/7-Zip" "${PROGRAM_FILES_32_BIT}/7-Zip" ${DOWNLOADS}/tools/7z/Files/7-Zip)
    set(URL "http://7-zip.org/a/7z1604.msi")
    set(ARCHIVE "7z1604.msi")
    set(HASH 556f95f7566fe23704d136239e4cf5e2a26f939ab43b44145c91b70d031a088d553e5c21301f1242a2295dcde3143b356211f0108c68e65eef8572407618326d)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(SUBDIR "ninja-1.7.2")
    set(PATHS ${DOWNLOADS}/tools/ninja/${SUBDIR})
    set(URL "https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-win.zip")
    set(ARCHIVE "ninja-win.zip")
    set(HASH cccab9281b274c564f9ad77a2115be1f19be67d7b2ee14a55d1db1b27f3b68db8e76076e4f804b61eb8e573e26a8ecc9985675a8dcf03fd7a77b7f57234f1393)
  elseif(VAR MATCHES "MESON")
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(SCRIPTNAME meson.py)
    set(PATHS ${DOWNLOADS}/tools/meson/meson-0.40.1)
    set(URL "https://github.com/mesonbuild/meson/archive/0.40.1.zip")
    set(ARCHIVE "meson-0.40.1.zip")
    set(HASH 4c1d07f32d527859f762c34de74d31d569573fc833335ab9652ed38d1f9e64b49869e826527c28a6a07cb8e594fd5c647b34aa95e626236a2707f75df0a2d435)
  elseif(VAR MATCHES "FLEX")
    set(PROGNAME win_flex)
    set(PATHS ${DOWNLOADS}/tools/win_flex)
    set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.9.zip/download")
    set(ARCHIVE "win_flex_bison-2.5.9.zip")
    set(HASH 9580f0e46893670a011645947c1becda69909a41a38bb4197fe33bd1ab7719da6b80e1be316f269e1a4759286870d49a9b07ef83afc4bac33232bd348e0bc814)
  elseif(VAR MATCHES "BISON")
    set(PROGNAME win_bison)
    set(PATHS ${DOWNLOADS}/tools/win_bison)
    set(URL "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-2.5.9.zip/download")
    set(ARCHIVE "win_flex_bison-2.5.9.zip")
    set(HASH 9580f0e46893670a011645947c1becda69909a41a38bb4197fe33bd1ab7719da6b80e1be316f269e1a4759286870d49a9b07ef83afc4bac33232bd348e0bc814)
  elseif(VAR MATCHES "GPERF")
    set(PROGNAME gperf)
    set(PATHS ${DOWNLOADS}/tools/gperf/bin)
    set(URL "https://sourceforge.net/projects/gnuwin32/files/gperf/3.0.1/gperf-3.0.1-bin.zip/download")
    set(ARCHIVE "gperf-3.0.1-bin.zip")
    set(HASH 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
  elseif(VAR MATCHES "GASPREPROCESSOR")
    set(NOEXTRACT true)
    set(PROGNAME gas-preprocessor)
    set(REQUIRED_INTERPRETER PERL)
    set(SCRIPTNAME "gas-preprocessor.pl")
    set(PATHS ${DOWNLOADS}/tools/gas-preprocessor)
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/36bacb4cba27003c572e5bf7a9c4dfe3c9a8d40d/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor.pl")
    set(HASH a25caadccd1457a0fd2abb5a0da9aca1713b2c351d76daf87a4141e52021f51aa09e95a62942c6f0764f79cc1fa65bf71584955b09e62ee7da067b5c82baf6b3)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT ${SCRIPTNAME} PATHS ${PATHS})
      set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT})
    endif()
  endmacro()

  do_find()
  if(${VAR} MATCHES "-NOTFOUND")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_HASH SHA512=${HASH}
      SHOW_PROGRESS
    )
    file(MAKE_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR})
    if(DEFINED NOEXTRACT)
      file(COPY ${DOWNLOADS}/${ARCHIVE} DESTINATION ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR})
    else()
      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
      if(${ARCHIVE_EXTENSION} STREQUAL ".msi")
        file(TO_NATIVE_PATH "${DOWNLOADS}/${ARCHIVE}" ARCHIVE_NATIVE_PATH)
        file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}" DESTINATION_NATIVE_PATH)
        execute_process(
          COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      else()
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
          WORKING_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}
        )
      endif()
    endif()

    do_find()
  endif()

  set(${VAR} ${${VAR}} PARENT_SCOPE)
endfunction()
