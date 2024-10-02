# cython: language_level = 3

from cpython.ref cimport PyObject
from libc.stddef cimport wchar_t
from libc.stdint cimport uint32_t
from libcpp cimport bool

cdef const char* empty_str = ""
cdef wchar_t* empty_w_str = NULL

cdef extern from "Python.h":
    void Py_INCREF(PyObject *o)
    void Py_DECREF(PyObject *o)
    void PyMem_Free(void* p)
    PyObject* PyUnicode_FromString(const char* u)
    PyObject* PyUnicode_FromWideChar(const wchar_t* w, Py_ssize_t size)
    const char* PyUnicode_AsUTF8(PyObject* unicode)  # Remove * from function name
    wchar_t* PyUnicode_AsWideCharString(PyObject* unicode, Py_ssize_t* size)

# Took sometime to find something equivelent to c/c++ platform macroes. 
# This is a replacement for the IF statement which is marked for future removal.
cdef extern from *:
    """
    #ifdef _WIN32
    #define ON_WINDOWS 1
    #else
    #define ON_WINDOWS 0
    #endif
    """
    cdef int ON_WINDOWS

cdef extern from "../include/SpeechCore.h":
    cdef void Speech_Init()
    cdef void Speech_Free()
    cdef void Speech_Detect_Driver()
    cdef const wchar_t* Speech_Current_Driver()
    cdef const wchar_t* Speech_Get_Driver(int index)
    cdef void Speech_Set_Driver(int index)
    cdef int Speech_Get_Drivers()
    cdef uint32_t Speech_Get_Flags()
    cdef bool Speech_Is_Loaded()
    cdef bool Speech_Is_Speaking()
    cdef bool Speech_Output(const wchar_t* text, bool _interrupt)
    cdef bool Speech_Braille(const wchar_t* text)
    cdef void Speech_Output_File(const char* filePath, const wchar_t* text)
    cdef float Speech_Get_Volume()
    cdef void Speech_Set_Volume(float offset)
    cdef float Speech_Get_Rate()
    cdef void Speech_Set_Rate(float offset)
    cdef const wchar_t* Speech_Get_Current_Voice()
    cdef const wchar_t* Speech_Get_Voice(int index)
    cdef void Speech_Set_Voice(int index)
    cdef int Speech_Get_Voices()
    cdef void Speech_Pause()
    cdef void Speech_Resume()
    cdef bool Speech_Stop()
    cdef void Speech_Prefer_Sapi(bool prefer_sapi)

#if ON_WINDOWS
    cdef extern from "../include/SpeechCore.h":
        cdef void Speech_Prefer_Sapi(bool prefer_sapi)
        cdef bool Speech_Sapi_Loaded()
        cdef void Sapi_Init()
        cdef void Sapi_Release()
        cdef int Sapi_Get_Voices()
        cdef const wchar_t* Sapi_Get_Current_Voice()
        cdef const wchar_t* Sapi_Get_Voice(int index)
        cdef void Sapi_Set_Voice(const wchar_t* voice)
        cdef void Sapi_Set_Voice_By_Index(int index)
        cdef float Sapi_Voice_Get_Rate()
        cdef void Sapi_Voice_Set_Rate(float offset)
        cdef float Sapi_Voice_Get_Volume()
        cdef void Sapi_Voice_Set_Volume(float offset)
        cdef void Sapi_Speak(const wchar_t* text, bool _interrupt, bool _xml)
        cdef void Sapi_Output_File(const char* filename, const wchar_t* text, bool _xml)
        cdef void Sapi_Resume()
        cdef void Sapi_Pause()
        cdef void Sapi_Stop()
#endif

cdef inline PyObject* Char_To_PyStr(const char* s):
    cdef PyObject* py_str = PyUnicode_FromString(s)
    return py_str

cdef inline PyObject* Wchar_t_To_PyStr(const wchar_t* s):
    cdef PyObject* py_str = PyUnicode_FromWideChar(s, -1)
    return py_str

cdef inline const char* PyStr_To_Char(PyObject* py_str):
    cdef const char* c_str = PyUnicode_AsUTF8(py_str)
    return c_str if c_str != NULL else empty_str

cdef inline wchar_t* PyStr_To_Wchar_t(PyObject* py_str):
    cdef Py_ssize_t size
    cdef wchar_t* str = PyUnicode_AsWideCharString(py_str, &size)
    return str if str != NULL else empty_w_str
