#
# This is a CMake makefile.  You can find the cmake utility and
# information about it at http://www.cmake.org
#

cmake_minimum_required(VERSION 2.8.4)

PROJECT(examples)

include(dlib/cmake)

ADD_EXECUTABLE(get_landmarks face_landmark_detection_ex.cpp)
TARGET_LINK_LIBRARIES(get_landmarks dlib )
