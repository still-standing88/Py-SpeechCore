# cython: language_level=3

# SpeechCore python wrapper.
# functions have bin separated into 2 classes: 
# SpeechCore contains all of the speech methods to manage drivers.
# Sapi contains sapi only methods.
# Only one instance of SpeechCore mey exist at a time, this goes for sapi as well.
# All functions have bin converted to lower snake case and the Speech prefix have bin removed.
# PyMem_free lines have bin commented out ince they tent to cause issues with sapi  output when memory is freed early. This will remain so until i could find a solution.

from cpython.ref cimport PyObject
from libc.stddef cimport wchar_t
from cpython.mem cimport PyMem_Free
from . cimport SpeechCore as sc

from functools import wraps
from typing import Optional
from .common import *

import os, sys
os.environ['Path'] += os.path.dirname(__file__)
if sys.platform == 'win32':
    from .sapi import *

SC_SPEECH_FLOW_CONTROL = 1 << 0
SC_SPEECH_PARAMETER_CONTROL = 1 << 1
SC_VOICE_CONFIG = 1 << 2
SC_FILE_OUTPUT = 1 << 3
SC_HAS_SPEECH = 1 << 4
SC_HAS_BRAILLE = 1 << 5


def CheckInit(func):
    @wraps(func)
    def wrapper(self, *args, **kw):
        if self.is_loaded():
            res = func(self, *args, **kw)
            return res
        else:
            raise NotLoadedError("speech_core is not loaded. Initialize SpeechCore before calling any method.")
    return wrapper

def add_dll_path(path: str):
    os.environ['Path'] += path


class SpeechCore:

    @classmethod
    def init(cls):
        try:
            sc.Speech_Init()
        except Exception as e:
            raise InitializationError(f'Failed initializing SpeechCore {str(e)}')

    @classmethod
    def free(cls):
        if cls.is_loaded():
            sc.Speech_Free()

    @classmethod
    def prefer_sapi(cls, prefer_sapi: bool):
        sc.Speech_Prefer_Sapi(prefer_sapi)

    @classmethod
    def is_loaded(cls) -> bool:
        return sc.Speech_Is_Loaded()

    #@staticmethod
    #def sapi_loaded() -> bool:
            #return #sc.Speech_Sapi_Loaded() if sc.ON_WINDOWS == 1 else False

    def __enter__(self):
        self.init()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.free()
        return False

    @CheckInit
    def detect_driver(self) ->None :
        sc.Speech_Detect_Driver()

    @CheckInit
    def get_driver(self, index: int) ->str :
        cdef const wchar_t* driver_str = sc.Speech_Get_Driver(index)
        if driver_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(driver_str)
            return <object> py_str
        return ""

    @CheckInit
    def current_driver(self) ->str :
        cdef const wchar_t* driver_str = sc.Speech_Current_Driver()
        if driver_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(driver_str)
            return <object>py_str
        return ""

    @CheckInit
    def set_driver(self, index: int) ->None :
        sc.Speech_Set_Driver(index)

    @CheckInit
    def get_drivers(self) ->int :
        sc.Speech_Get_Drivers()

    @CheckInit
    def get_voice(self, index: int) ->str :
        cdef const wchar_t* voice_str = sc.Speech_Get_Voice(index)
        if voice_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(voice_str)
            return <object> py_str
        return ""

    @CheckInit
    def get_current_voice(self) ->str :
        cdef const wchar_t* voice_str = sc.Speech_Get_Current_Voice()
        if voice_str != NULL:
            py_str = sc.Wchar_t_To_PyStr(voice_str)
            return <object> py_str
        return ""

    @CheckInit
    def set_voice(self, index: int) ->None :
        sc.Speech_Set_Voice(index)

    @CheckInit
    def get_voices(self) ->int :
        sc.Speech_Get_Voices()

    @CheckInit
    def set_volume(self, offset: float) ->None :
        sc.Speech_Set_Volume(offset)

    @CheckInit
    def get_volume(self) ->float :
        return sc.Speech_Get_Volume()

    @CheckInit
    def set_rate(self, offset: float) ->None :
        sc.Speech_Set_Rate(offset)

    @CheckInit
    def get_rate(self) ->float :
        return sc.Speech_Get_Rate()

    @CheckInit
    def is_speaking(self) ->bool :
        return sc.Speech_Is_Speaking()


    @CheckInit
    def get_speech_flags(self) ->int :
        return sc.Speech_Get_Flags()

    def check_speech_flags(self, flags: int) -> bool:
        return (self.get_speech_flags() & flags)

    @CheckInit
    def output(self, text: str, interrupt: bool = False) -> bool:
        cdef wchar_t* text_str = sc.PyStr_To_Wchar_t(<PyObject*>text)
        if text_str != NULL:
            res = sc.Speech_Output(text_str, interrupt)
            #PyMem_Free(<void*>text_str)
            return res
        return False

    @CheckInit
    def braille(self, text: str) ->bool :
        cdef wchar_t* text_str = sc.PyStr_To_Wchar_t(<PyObject*>text)
        if text_str != NULL:
            res = sc.Speech_Braille(text_str)
            #PyMem_Free(<void*>text_str)
            return res
        return False

    @CheckInit
    def output_file(self, filename: str, text: str) ->None :
        cdef const char* name_str = sc.PyStr_To_Char(<PyObject*>filename)
        cdef wchar_t* text_str = sc.PyStr_To_Wchar_t(<PyObject*>text)
        if text_str != NULL:
            sc.Speech_Output_File(name_str, text_str)
            #PyMem_Free(<void*>text_str)

    @CheckInit
    def resume(self) ->None :
        sc.Speech_Resume()

    @CheckInit
    def pause(self) ->None :
        sc.Speech_Pause()

    @CheckInit
    def stop(self) ->None :
        sc.Speech_Stop()
