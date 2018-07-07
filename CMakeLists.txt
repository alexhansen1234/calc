cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(calc VERSION 0.1)

add_executable(calc ${PROJECT_BINARY_DIR}/src/parser.c ${PROJECT_BINARY_DIR}/src/lexer.c)

add_custom_target(lexer DEPENDS ${PROJECT_BINARY_DIR}/src/lexer.c)

add_custom_target(parser DEPENDS ${PROJECT_BINARY_DIR}/src/parser.c ${PROJECT_BINARY_DIR}/src/parser.tab.h
    )

include_directories(
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_BINARY_DIR}/src
    )

add_dependencies(calc parser lexer)

target_include_directories(calc
    PUBLIC
    ${PROJECT_BINARY_DIR}/src
    ${PROJECT_SOURCE_DIR}/src
    )

target_link_libraries(calc
    PUBLIC
    m
    )

find_package(BISON REQUIRED)
if(BISON_FOUND)
    set(BISON_OUTPUT ${PROJECT_BINARY_DIR}/src/parser.c)
    set(BISON_DEFINES ${PROJECT_BINARY_DIR}/src/parser.tab.h)
    add_custom_command(
        OUTPUT  ${BISON_OUTPUT}
        COMMAND ${BISON_EXECUTABLE}
                --defines=${BISON_DEFINES}
                --output=${BISON_OUTPUT}
                ${PROJECT_SOURCE_DIR}/src/parser.y
        COMMENT "Generating parser.c"
    )
endif(BISON_FOUND)

find_package(FLEX REQUIRED)
if(FLEX_FOUND)
    set(FLEX_OUTPUT ${PROJECT_BINARY_DIR}/src/lexer.c)

    add_custom_command(
        OUTPUT  ${FLEX_OUTPUT}
        COMMAND ${FLEX_EXECUTABLE}
                -o ${FLEX_OUTPUT}
                ${PROJECT_SOURCE_DIR}/src/lexer.l
        COMMENT "Generating lexer.c"
        )
endif(FLEX_FOUND)

