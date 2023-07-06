# https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Write-Platform-Checks#platform-variables

if(UNIX)
    if(APPLE)
        message(STATUS "  Operating System: macOS")
        add_definitions(-Dmacx64)
    elseif(CYGWIN)
        message(STATUS "  Operating System: Windows (Cygwin)")
        add_definitions(-Dwin64)
    else()
        message(STATUS "  Operating System: Linux")
        add_definitions(-Dlinx64)
    endif()

    set(LaGriT_STATIC_LINKER_FLAGS "-static-libgcc -static-libstdc++")

elseif(WIN32)
    message(STATUS "  Operating System: Windows")
    add_definitions(-Dwin64)

elseif(MINGW)
    message(STATUS "  Operating System: Windows (MinGW)")
    add_definitions(-Dwin64)

else()
    message("cmake/PlatformSettings.cmake OPERATING SYSTEM UNDEFINED")
endif()
