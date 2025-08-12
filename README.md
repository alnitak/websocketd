A Flutter project that use `ffmpeg` to send PCM audio data through a websocked.
![websocketd](https://github.com/user-attachments/assets/f31a793a-400c-40a2-8bf5-8d798576d945)

# Usage

Be sure to have [websocketd](http://websocketd.com/#download), [ffmpeg](https://www.ffmpeg.org/download.html) and [wget](https://www.gnu.org/software/wget/) installed (on Linux these packages are available using you package manager).
Also add in `send_plain_file.dart`, `ffmpeg_page.dart` and `send_url.dart` the variables containing the paths or the URLs.

You can then choose which audio data format you want to use and send through the websocket. 

Could happens that, when changing parameters, the `websocketd` process can't be killed and in the output window you see `Can't start server: listen tcp :8080: bind: address already in use`. Just hit the `kill all websocketd` and change some parameter.

PS: I just used and tested on Linux and MacOS.
