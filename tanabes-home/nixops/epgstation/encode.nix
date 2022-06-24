[
  {
    name = "H.264";
    cmd =
      ''
        %FFMPEG% -i %INPUT% -threads 0 -c:a aac
        -ar 48000 -b:a 192k -ac 2 -c:v h264_v4l2m2m -vf yadif -b:v 5M
        -preset veryslow -tune zerolatency -movflags
        frag_keyframe+empty_moov+faststart+default_base_moof -y -f mp4 %OUTPUT%
      '';
    suffix = ".mp4";
  }
]
