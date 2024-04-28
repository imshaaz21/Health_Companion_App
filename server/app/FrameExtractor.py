import os
import subprocess
import json


class FrameExtractor:
    def __init__(self, video_path):
        self.video_path = video_path

    def extract_frames(self, temp_dir='temp', fps=10):
        if not os.path.exists(self.video_path):
            raise FileNotFoundError(f"Video file {self.video_path} not found")

        video_name = os.path.splitext(os.path.basename(self.video_path))[0]
        temp_dir = os.path.join(temp_dir, video_name)
        os.makedirs(temp_dir, exist_ok=True)

        try:
            output_pattern = os.path.join(temp_dir, "%04d.jpg")
            print(f"\033[1;32mStarted extracting frames\033[0m")
            print(f"\033[1;34mFPS: {fps}\033[0m")

            ffmpeg_command = ["ffmpeg", "-i", self.video_path,
                              "-vf", f"fps={fps}", output_pattern]
            subprocess.run(ffmpeg_command, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Error running FFmpeg: {e}")

        print(f"\033[1;34mFinished extracting frames...Frames saved in {temp_dir} at fps {fps}\033[0m")
        return temp_dir
