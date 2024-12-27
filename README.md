A Flutter project that use `ffmpeg` to send PCM audio data through a websocked.
![websocketd](https://github.com/user-attachments/assets/f31a793a-400c-40a2-8bf5-8d798576d945)

# Usage

Be sure to have `websocketd` and `ffmpeg` installed (on Linux these packages are available using you package manager).
Also modify in `main.dart` the `final audioPath` to point to an audio file on you PC.

You can then choose which PCM audio data format you want to use and send through the websocket.
There is also a slider to manage the flow speed of output packets. 0 means no limits, 1 means the packets are sent at 1x as the audio source.

Could happens that, when changing parameters, the `websocketd` process can't be killed and in the output window you see `Can't start server: listen tcp :8080: bind: address already in use`. Just hit the `kill all websocketd` and change some parameter.

PS: I just used and tested on Linux.
