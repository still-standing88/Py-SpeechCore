# py-SpeechCore

Python bindings for the SpeechCore library, created using Cython.

## Installation

```bash
pip install speech_core
```

## Usage

See the examples folder.

## Building

Download SpeechCore binaries for your platform from [the releases page](https://github.com/still-standing88/SpeechCore/releases).

Clone the repo
```bash
git clone https://github.com/still_standing88/py-SpeechCore.git
```

Copy the lib folder extracted from the binary to the repo.
Navigate to the folder and run
```bash
cd Py-SpeechCore
pip install requirements.txt
```

For building:
```bash
python setup build_ext
```

For distribution:
```bash
python setup.py dist bdist_wheel
```
Then install
```bash
pip install dist/<resulting-dist-file>.whl
```

## Notes

* functions have bin separated into 2 classes: SpeechCore contains all of the speech methods to manage drivers. Sapi contains sapi only methods.
* Only one instance of SpeechCore mey exist at a time, this goes for sapi as well.
* All functions have bin converted to lower snake case and the Speech prefix have bin removed.
