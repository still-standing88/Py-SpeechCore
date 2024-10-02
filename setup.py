import platform as pf
import sys
import os
import glob
import shutil

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize
from setuptools.command.build_ext import build_ext
from setuptools.command.install import install
from setuptools.command.sdist import sdist
from wheel.bdist_wheel import bdist_wheel

def get_readme():
    with open("./readme.md", 'r') as file:
        return file.read()

def detect_platform():
    platform = sys.platform
    if platform == 'win32':
        return 'windows'
    elif platform == 'darwin':
        return 'macos'
    elif platform == 'linux':
        return 'linux'
    else:
        print(f'Unknown platform {platform}. Defaulting to windows.')
        return 'windows'

def detect_host_arch():
    machine = pf.machine().lower()
    if machine in ['x86_64', 'amd64']:
        return 'x86_64'
    elif machine in ['i386', 'i686']:
        return 'x86'
    elif machine in ['arm64', 'aarch64']:
        return 'arm64'
    else:
        print(f"Warning: Unrecognized architecture '{machine}'. Defaulting to x86_64.")
        return 'x86_64'

platform = detect_platform()
arch = detect_host_arch()
lib_path = f'lib/{platform}/{arch}/debug/static'
lib_name = 'SpeechCore.lib' if platform == 'windows' else 'libSpeechCore.a'
sources = glob.glob('./speech_core/*.pyx')
extra_compile_args = ['-D__SPEECH_C_STATIC']
extra_link_args = [f'{lib_path}/{lib_name}',]
if platform == 'windows':
    extra_compile_args += ['/std:c++20', '/EHsc', '/MD', '/D_WIN32',]
    extra_link_args += []
else:
    extra_compile_args += ['-std=c++2a' if platform == 'linux' else '-std=c++20', '-Wall', '-Wextra']

ext = [Extension(
    name='speech_core.SpeechCore', 
    sources=['./speech_core/SpeechCore.pyx'], 
    include_dirs=['../include/'],
         extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
    language='c++'),]

if platform == 'windows':
        ext.append(Extension(
        name='speech_core.sapi',
            sources=['./speech_core/sapi.pyx'],
            include_dirs=['../include/'],
            extra_compile_args=extra_compile_args,
            extra_link_args=extra_link_args,
            language='c++'
    ))

class dllDist(sdist):

    def run(self):
        super().run()
        if platform == 'windows':
            print("Copying dll files")
            dll_dir = f"bin/{'x64' if '64' in arch else 'x86'}"
            dll_target_dir = "speech_core"
            if os.path.exists(dll_dir):
                for file in os.listdir(dll_dir):
                    if file.endswith('.dll'):
                        source = os.path.join(dll_dir, file)
                        target = os.path.join(dll_target_dir, file)
                        print(f'Copying file: {source}. To {target}')
                        self.copy_file(source, target)

class postCleanup(bdist_wheel):

    def run(self):
        super().run()
        if platform == 'windows':
            print('Cleaning dll files.')
            for file in os.listdir('./speech_core'):
                if file.endswith('.dll'):
                    os.remove(f'./speech_core/{file}')

setup(
    name='SpeechCore',
    version='1.0.0',
    description='A python wrapper for the speech_core library',
    long_description=get_readme(),
    long_description_content_type='text/markdown',
    url='https://github.com/still_standing88/Py-SpeechCore/',
    license='MIT',
    packages=find_packages(),
    ext_modules=cythonize(ext, include_path=['speech_core']),
    package_data={'speech_core': ['*.dll']},
    cmdclass={'build_ext': build_ext,
    'sdist': dllDist,
    'bdist_wheel': postCleanup},
    classifiers=[
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.8',
)

