# Copyright (c) 2019-2020, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# cython: profile = False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from libcpp.memory cimport unique_ptr
from libc.stdint cimport uintptr_t

from rmm._lib.lib cimport cudaStream_t, cudaMemcpyAsync, cudaMemcpyDeviceToHost

cdef extern from "rmm/device_buffer.hpp" namespace "rmm" nogil:
    cdef cppclass device_buffer:
        device_buffer()
        device_buffer(size_t size) except +
        device_buffer(size_t size, cudaStream_t stream) except +
        device_buffer(const void* source_data, size_t size) except +
        device_buffer(const void* source_data,
                      size_t size, cudaStream_t stream) except +
        device_buffer(const device_buffer& other) except +
        void resize(size_t new_size) except +
        void shrink_to_fit() except +
        void* data()
        size_t size()
        size_t capacity()


cdef class DeviceBuffer:
    cdef unique_ptr[device_buffer] c_obj

    @staticmethod
    cdef DeviceBuffer c_from_unique_ptr(unique_ptr[device_buffer] ptr)

    @staticmethod
    cdef DeviceBuffer c_to_device(const unsigned char[::1] b,
                                  uintptr_t stream=*)
    cpdef copy_to_host(self, ary=*, uintptr_t stream=*)
    cpdef bytes tobytes(self, uintptr_t stream=*)

    cdef size_t c_size(self)
    cpdef void resize(self, size_t new_size)
    cpdef size_t capacity(self)
    cdef void* c_data(self)


cpdef DeviceBuffer to_device(const unsigned char[::1] b, uintptr_t stream=*)
cpdef void copy_ptr_to_host(uintptr_t db,
                            unsigned char[::1] hb,
                            uintptr_t stream=*) nogil except *


cdef extern from "<utility>" namespace "std" nogil:
    cdef unique_ptr[device_buffer] move(unique_ptr[device_buffer])
