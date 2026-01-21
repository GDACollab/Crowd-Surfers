# FMOD!!!!
[fmod gdextension docs](https://fmod-gdextension.readthedocs.io/en/latest/)

# Important things to know
Every scene with audio must have an `FmodBankLoader` at the top of the scene tree
(It must be processed before any other fmod nodes)
This includes nested scenes, don't worry about "loading multiple times", fmod is smart.
Wherever you need to control sound, make a bank loader

The bank loader must ALWAYS load, in this order:
1. res://Assets/Sound_Banks/Master.strings.bank
2. res://Assets/Sound_Banks/Master.bank
3. any other banks

# This demo
I was just learning fmod so i figured I'd share my test scene

Use arrow keys to move the player, background music should get quieter
when you move further from the sphere "speaker"

While the game is playing, edit the "Music Section" parameter of the event emitter
to progress through the 3 sections of music
