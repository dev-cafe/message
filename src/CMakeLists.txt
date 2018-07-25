# Search for pkg-config and UUID
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_search_module(UUID uuid IMPORTED_TARGET)
  if(UUID_FOUND)
    message(STATUS "Found libuuid")
  endif()
endif()

# <<< Build targets >>>

# OBJECT library
add_library(message OBJECT "")

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

target_include_directories(message
  PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  )

set_target_properties(message
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN 1
  )

target_compile_definitions(message
  PUBLIC
    message_EXPORTS
    $<$<BOOL:${UUID_FOUND}>:HAVE_UUID>
    $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:message_STATIC_DEFINE>
  INTERFACE
    $<INSTALL_INTERFACE:USING_message>
  )

# SHARED library

add_library(message-shared SHARED $<TARGET_OBJECTS:message>)

set_target_properties(message-shared
  PROPERTIES
    MACOSX_RPATH ON
    SOVERSION ${PROJECT_VERSION_MAJOR}
    OUTPUT_NAME "message"
    PUBLIC_HEADER "Message.hpp;${CMAKE_CURRENT_BINARY_DIR}/messageExport.h"
  )

target_compile_definitions(message-shared
  PUBLIC
    message_EXPORTS
  )

target_include_directories(message-shared
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
  )

target_link_libraries(message-shared
  PUBLIC
    $<$<BOOL:${UUID_FOUND}>:PkgConfig::UUID>
  )

# STATIC library from object files

add_library(message-static STATIC $<TARGET_OBJECTS:message>)

set_target_properties(message-static
  PROPERTIES
    OUTPUT_NAME "message_s"
    PUBLIC_HEADER "Message.hpp;${CMAKE_CURRENT_BINARY_DIR}/messageExport.h"
  )

target_compile_definitions(message-static
  PUBLIC
    message_STATIC_DEFINE
  INTERFACE
    $<INSTALL_INTERFACE:USING_message>
  )

target_include_directories(message-static
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
  )

target_link_libraries(message-static
  PUBLIC
    $<$<BOOL:${UUID_FOUND}>:PkgConfig::UUID>
  )

# STATIC library from sources

add_library(message-static2 STATIC Message.cpp)

set_target_properties(message-static2
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN 1
    OUTPUT_NAME "message_s2"
    PUBLIC_HEADER "Message.hpp;${CMAKE_CURRENT_BINARY_DIR}/messageExport.h"
  )

target_compile_definitions(message-static2
  PUBLIC
    message_STATIC_DEFINE
    $<$<BOOL:${UUID_FOUND}>:HAVE_UUID>
  INTERFACE
    $<INSTALL_INTERFACE:USING_message>
  )

target_include_directories(message-static2
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
  )

target_link_libraries(message-static2
  PUBLIC
    $<$<BOOL:${UUID_FOUND}>:PkgConfig::UUID>
  )

# EXECUTABLE

add_executable(hello-world hello-world.cpp)
target_link_libraries(hello-world
  PUBLIC
    message-shared
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

add_executable(hello-world-static hello-world.cpp)

target_link_libraries(hello-world-static
  PUBLIC
    message-static
  )

add_executable(hello-world-static2 hello-world.cpp)

target_link_libraries(hello-world-static2
  PUBLIC
    message-static2
  )

# <<< Install and export targets >>>

install(
  TARGETS
    message-shared
  EXPORT
    messageTargets
  ARCHIVE
    DESTINATION ${INSTALL_LIBDIR}
    COMPONENT lib
  RUNTIME
    DESTINATION ${INSTALL_BINDIR}
    COMPONENT bin
  LIBRARY
    DESTINATION ${INSTALL_LIBDIR}
    COMPONENT lib
  PUBLIC_HEADER
    DESTINATION ${INSTALL_INCLUDEDIR}/message
    COMPONENT dev
  )

install(
  EXPORT
    messageTargets
  NAMESPACE
    "message::"
  DESTINATION
    ${INSTALL_CMAKEDIR}
  COMPONENT
    dev
  )

install(
  TARGETS
    hello-world
  EXPORT
    messageTargets-hello-world
  RUNTIME
    DESTINATION ${INSTALL_BINDIR}
    COMPONENT bin
  )

install(
  EXPORT
    messageTargets-hello-world
  NAMESPACE
    "message::"
  DESTINATION
    ${INSTALL_CMAKEDIR}
  COMPONENT
    bin
  )

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/messageConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
  )

configure_package_config_file(
  ${PROJECT_SOURCE_DIR}/cmake/messageConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/messageConfig.cmake
  INSTALL_DESTINATION ${INSTALL_CMAKEDIR}
  )

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/messageConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/messageConfigVersion.cmake
  DESTINATION
    ${INSTALL_CMAKEDIR}
  )
