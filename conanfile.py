from conans import ConanFile, tools
import os

class LibwebrtcConan(ConanFile):
  name = "libwebrtc"
  settings = "os", "arch"
  description = "Libwebrtc"
  url = "https://github.com/Mersive-Technologies/libwebrtc"
  license = "Apache License 2.0" # TODO: Perhaps work out the legal ramifications later.
  author = "Mersive Technologies"
  topics = None
  exports = "version.txt"

  def init(self):
    with open(os.path.join(self.recipe_folder, "version.txt"), "r") as file:
      self.version = file.read().rstrip()

  def package(self):
    self.copy("*.h", src="out/webrtc", dst="webrtc")
    self.copy("*.lib", src="out/lib", dst="lib")
