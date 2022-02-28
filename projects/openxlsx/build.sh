#!/bin/bash -eu
# Copyright (C) 2021 ISP RAS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Build targets for libfuzzer

mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS="-DNDEBUG -g -fsanitize=fuzzer-no-link,address" \
      ..
cmake --build . --target OpenXLSX --config Release

CXX="clang++"
CXXFLAGS="-g -fsanitize=fuzzer,address"

# Building Document fuzztarget
$CXX $CXXFLAGS -std=c++17 -I/openxlsx/OpenXLSX -I./OpenXLSX \
    -I/openxlsx/OpenXLSX/external/zippy -I/openxlsx/OpenXLSX/external/nowide \
    -c /fuzzer.cc -o fuzzer.o

$CXX $CXXFLAGS ./fuzzer.o ./output/libOpenXLSX.a -o /fuzzer


# Build targets for Sydr

cd .. && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS=-g \
      ..
cmake --build . --target OpenXLSX --config Release
CXX="clang++"
CXXFLAGS="-g"

# Building sydr target
$CXX $CXXFLAGS -std=c++17 -I/openxlsx/OpenXLSX -I./OpenXLSX \
    -I/openxlsx/OpenXLSX/external/zippy -I/openxlsx/OpenXLSX/external/nowide \
    -c /sydr.cc -o sydr.o

$CXX $CXXFLAGS ./sydr.o ./output/libOpenXLSX.a -o /sydr
