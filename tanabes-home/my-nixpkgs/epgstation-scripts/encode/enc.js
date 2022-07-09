const spawn = require("child_process").spawn;
const ffmpeg = process.env.FFMPEG;

const input = process.env.INPUT;
const output = process.env.OUTPUT;
const analyzedurationSize = "10M"; // Mirakurun の設定に応じて変更すること
const probesizeSize = "32M"; // Mirakurun の設定に応じて変更すること
const maxMuxingQueueSize = 1024;
const dualMonoMode = "main";
const videoHeight = parseInt(process.env.VIDEORESOLUTION, 10);
const isDualMono = parseInt(process.env.AUDIOCOMPONENTTYPE, 10) == 2;
const audioBitrate = videoHeight > 720 ? "192k" : "128k";
const preset = "veryslow";
const codec = "libx264";
const crf = 23;

const args = [
  "-y",
  "-analyzeduration",
  analyzedurationSize,
  "-probesize",
  probesizeSize,
];

// dual mono 設定
if (isDualMono) {
  args.push("-dual_mono_mode", dualMonoMode);
  args.push("-filter_complex", "channelsplit");
}

// input 設定
Array.prototype.push.apply(args, ["-i", input]);

// メタ情報を先頭に置く
Array.prototype.push.apply(args, [
  "-movflags",
  "frag_keyframe+empty_moov+faststart+default_base_moof",
]);

// 字幕データを含めたストリームをすべてマップ
// Array.prototype.push.apply(args, ['-map', '0', '-ignore_unknown', '-max_muxing_queue_size', maxMuxingQueueSize, '-sn']);

// video filter 設定
let videoFilter = "yadif";
Array.prototype.push.apply(args, ["-vf", videoFilter]);

// その他設定
// prettier-ignore
Array.prototype.push.apply(args,[
    '-pix_fmt', 'yuv420p',
    '-g:v', '25',
    '-b:v', '4000000',
    '-minrate:v', '500000',
    '-maxrate:v', '5000000',
    '-bufsize:v', '5000000',
    '-level', '5.2',
    '-tune', 'fastdecode,zerolatency',
    '-preset', preset,
    '-aspect', '16:9',
    '-c:v', codec,
    '-crf', crf,
    '-f', 'mp4',
    '-c:a', 'aac',
    '-ar', '48000',
    '-ab', audioBitrate,
    '-ac', '2',
    output
]);

let str = "";
for (let i of args) {
  str += ` ${i}`;
}
console.error(str);

const child = spawn(ffmpeg, args);

child.stderr.on("data", (data) => {
  console.error(String(data));
});

child.on("error", (err) => {
  console.error(err);
  throw new Error(err);
});

process.on("SIGINT", () => {
  child.kill("SIGINT");
});
