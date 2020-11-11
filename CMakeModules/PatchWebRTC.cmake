
set(TARGET_FILE ${CMAKE_ARGV3})

file(READ ${TARGET_FILE} filedata)
string(REGEX REPLACE ":static_crt" ":dynamic_crt" filedata "${filedata}")
file(WRITE  ${TARGET_FILE} "${filedata}")
