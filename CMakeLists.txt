cmake_minimum_required(VERSION 3.16)
project(TrackViewer VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.0 REQUIRED COMPONENTS
    Core
    Qml
    Quick
    Location
    Positioning
)

set(PROJECT_SOURCES
    main.cpp
    src/csvreader.h
    src/csvreader.cpp
    src/trackmanager.h
    src/trackmanager.cpp
)

if(WIN32)
    list(APPEND PROJECT_SOURCES app.rc)
endif()

qt_add_executable(${PROJECT_NAME} WIN32 ${PROJECT_SOURCES})

qt_add_resources(${PROJECT_NAME} "qml_resources"
    PREFIX "/"
    FILES
        qml/main.qml
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Location
    Qt6::Positioning
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
