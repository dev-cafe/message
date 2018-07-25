# Search for pkg-config and UUID
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_search_module(UUID uuid IMPORTED_TARGET)
  if(UUID_FOUND)
    message(STATUS "Found libuuid")
  endif()
endif()

# <<< Build targets >>>

add_library(message SHARED "")

include(GenerateExportHeader)
generate_export_header(message
  BASE_NAME "message"
  EXPORT_MACRO_NAME "message_EXPORT"
  EXPORT_FILE_NAME "messageExport.h"
  DEPRECATED_MACRO_NAME "message_DEPRECATED"
  NO_EXPORT_MACRO_NAME "message_NO_EXPORT"
  STATIC_DEFINE "message_STATIC_DEFINE"
  NO_DEPRECATED_MACRO_NAME "message_NO_DEPRECATED"
  DEFINE_NO_DEPRECATED
  )

target_sources(message
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/Message.cpp
  )

set_target_properties(message
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN 1
    OUTPUT_NAME "message"
    PUBLIC_HEADER "Message.hpp;${CMAKE_CURRENT_BINARY_DIR}/messageExport.h"
    MACOSX_RPATH ON
    SOVERSION ${PROJECT_VERSION_MAJOR}
  )

target_compile_definitions(message
  PUBLIC
    message_EXPORTS
    $<$<BOOL:${UUID_FOUND}>:HAVE_UUID>
  INTERFACE
    $<INSTALL_INTERFACE:USING_message>
  )

target_include_directories(message
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
  )

target_link_libraries(message
  PUBLIC
    $<$<BOOL:${UUID_FOUND}>:PkgConfig::UUID>
  )

# EXECUTABLE

add_executable(hello-world hello-world.cpp)

target_link_libraries(hello-world
  PUBLIC
    message
  )

# RPATH fixing
set_target_properties(hello-world
  PROPERTIES
    MACOSX_RPATH ON
    SKIP_BUILD_RPATH OFF
    BUILD_WITH_INSTALL_RPATH OFF
    INSTALL_RPATH "${message_RPATH}"
    INSTALL_RPATH_USE_LINK_PATH ON
  )
