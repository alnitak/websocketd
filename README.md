A Flutter project that uses `ffmpeg` to send chunks of audio data through a websocked.

<img width="916" height="811" alt="websocketd" src="https://github.com/user-attachments/assets/49dfeb07-79ad-49d1-82af-808fe5abecb5" />

# Usage

Be sure to have [websocketd](http://websocketd.com/#download), [ffmpeg](https://www.ffmpeg.org/download.html), and [wget](https://www.gnu.org/software/wget/) installed (on Linux, these packages are available using your package manager).
Also, add in `send_plain_file.dart`, `ffmpeg_page.dart`, and `send_url.dart` the variables containing the paths or the URLs.

You can then choose which audio data format you want to use and send it through the websocket. 

It could happen that, when changing parameters, the `websocketd` process can't be killed, and in the output window, you see `Can't start server: listen tcp :8080: bind: address already in use`. Just hit the `kill all websocketd` and change some parameters.

PS: I just used and tested on Linux and MacOS.
