#ifndef PLAYER_FFMPEG_WEBRTC_DECODER_H_
#define PLAYER_FFMPEG_WEBRTC_DECODER_H_
// Nix stub: Yang/WebRTC-видео отключено (библиотеки metartc/yang нет в nixpkgs).
// API-совместим с src/video/WebRTCDecoder.h для вызовов из GUI (Linux-ветки).
// getFrameData() возвращает пустой кадр — видео просто не показывается.
#include <string>
#include <vector>

class WebRTCDecoder {
public:
  static WebRTCDecoder *GetInstance()
  {
    static WebRTCDecoder instance;
    return &instance;
  }
  void stopPlay() {}
  void startPlay(const std::string &) {}
  std::vector<unsigned char> &getFrameData()
  {
    static std::vector<unsigned char> empty;
    return empty;
  }
};

#endif // PLAYER_FFMPEG_WEBRTC_DECODER_H_
