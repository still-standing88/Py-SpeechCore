# cython: language_level=3

from cpython.ref cimport PyObject
from libc.stddef cimport wchar_t
from cpython.mem cimport PyMem_Free
from . cimport SpeechCore as sc
from .common import *

from functools import wraps
import sys


def CheckSapi(func):
    @wraps(func)
    def wrapper(self, *args, **kw):
        if sys.platform == 'win32':
            if not self.sapi_loaded():
                raise NotLoadedError('Sapi is not loaded. Initialize sapi before calling any function.')
            res = func(self, *args, **kw)
            return res
        else:
            raise NotImplementedError(f'Sapi functions are not available on {sys.platform}.')
    return wrapper


#if sc.ON_WINDOWS:
class Sapi:

    @classmethod
    def init(cls):
        if sys.platform != 'win32':
            raise NotImplementedError(f'Sapi functions are not available on{sys.platform}')
        try:
            sc.Sapi_Init()
        except Exception as e:
            raise InitializationError(f'Failed initializing sapi {str(e)}')

    @classmethod
    @CheckSapi
    def release(cls):
        sc.Sapi_Release()

    @classmethod
    def sapi_loaded(cls)-> bool :
        return sc.Speech_Sapi_Loaded()

    def __enter__(self):
        self.init()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.release()
        return False

    @CheckSapi
    def voice_set_rate(self, offset: float)->None :
        sc.Sapi_Voice_Set_Rate(offset)

    @CheckSapi
    def voice_get_rate(self)->float :
        return sc.Sapi_Voice_Get_Rate()

    @CheckSapi
    def voice_set_volume(self, offset: float)->None :
        sc.Sapi_Voice_Set_Volume(offset)

    @CheckSapi
    def voice_get_volume(self)->float :
        return sc.Sapi_Voice_Get_Volume()

    @CheckSapi
    def get_voice(self, index: int) ->str :
        cdef const wchar_t* voice_str = sc.Sapi_Get_Voice(index)
        if voice_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(voice_str)
            return <object> py_str
        return ""

    @CheckSapi
    def get_current_voice(self) ->str :
        cdef const wchar_t* voice_str = sc.Sapi_Get_Current_Voice()
        if voice_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(voice_str)
            return <object> py_str
        return ""

    @CheckSapi
    def set_voice_by_index(self, index: int) ->None :
        sc.Sapi_Set_Voice_By_Index(index)

    @CheckSapi
    def set_voice(self, voice_name: str)->None :
        cdef const wchar_t* name_str = sc.PyStr_To_Wchar_t(<PyObject*>voice_name)
        if name_str != NULL:
            sc.Sapi_Set_Voice(name_str)
            #PyMem_Free(<void*>name_str)


    @CheckSapi
    def get_voices(self) ->int :
        return sc.Sapi_Get_Voices()

    @CheckSapi
    def speak(self, text: str, interrupt: bool = False, xml: bool = False) ->None :
        cdef wchar_t* text_str = sc.PyStr_To_Wchar_t(<PyObject*>text)
        if text_str != NULL:
            sc.Sapi_Speak(text_str, interrupt, xml)
            #PyMem_Free(text_str)

    @CheckSapi
    def output_file(self, filename: str, text: str, xml: bool = False) ->None :
        cdef const char* name_str = sc.PyStr_To_Char(<PyObject*>filename)
        cdef wchar_t* text_str = sc.PyStr_To_Wchar_t(<PyObject*>text)
        if text_str != NULL:
            sc.Sapi_Output_File(name_str, text_str, xml)
            #PyMem_Free(<void*>text_str)

    @CheckSapi
    def resume(self)->None :
        sc.Sapi_Resume()

    @CheckSapi
    def pause(self)->None :
        sc.Sapi_Pause()

    @CheckSapi
    def stop(self)->None :
        sc.Sapi_Stop()
