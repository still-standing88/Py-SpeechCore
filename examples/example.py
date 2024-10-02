import speech_core as sc

# Variables and function defines
# Just a placeholder for a phrase to be spoken
phrase = "Some text"

# Menu string
menu_str = """
1: Speak a phrase
2: Speak phrase with low volume
3: Speak a phrase with fast rate
4: List available voices
5: Change voice
6: Test speech flags
7: Exit
"""

def set_rate(instance: sc.SpeechCore, rate: float):
    instance.set_rate(rate)
    print(f"Speaking rate set to {instance.get_rate()}")
    instance.output(phrase)

def set_volume(instance: sc.SpeechCore, volume: float):
    instance.set_volume(volume)
    print(f"Speaking volume set to {instance.get_volume()}")
    instance.output(phrase)

def get_voices(instance: sc.SpeechCore):
    voices = instance.get_voices()
    if voices is not None:
        print(f"Number of voices: {voices}")
        for voice in range(voices):
            print(f"Voice: {instance.get_voice(voice)}")

def set_voice(instance: sc.SpeechCore, index: int):
    print(f"Setting voice to {instance.get_voice(index)}")
    instance.set_voice(index)

def test_flags(instance: sc.SpeechCore):
    braille_flag = bool(instance.check_speech_flags(sc.SC_HAS_BRAILLE))
    speech_flag = bool(instance.get_speech_flags() & sc.SC_HAS_SPEECH)
    print(f"Braille: {braille_flag}\nSpeech: {speech_flag}")

# You can instantiate the SpeechCore class and initialize it using the init method. Or use it as a context manager.
speech = sc.SpeechCore()
# Initialize
speech.init()

# Menu with options to test out various speech functionality.
while True:
    print("SpeechCore example\nSelect an option")
    print(menu_str)
    choice = input("Type an option: ")
    
    match choice:
        case "1":
            speech.output(phrase)
        case "2":
            set_volume(speech, 43)
        case "3":
            set_rate(speech, 89)
        case "4":
            get_voices(speech)
        case "5":
            set_voice(speech, 1)
        case "6":
            test_flags(speech)
        case "7":
            print("Exiting")
            speech.free()
            break
        case _:
            print("Unknown option")
