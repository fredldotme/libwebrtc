from conans import ConanFile, tools
import os

class LibwebrtcConan(ConanFile):
  name = "libwebrtc"
  version = "0.1.1"
  settings = "os", "arch"
  description = "Libwebrtc"
  url = "https://github.com/Mersive-Technologies/libwebrtc"
  license = "Apache License 2.0" # TODO: Perhaps work out the legal ramifications later.
  author = "Mersive Technologies"
  topics = None

  def package(self):
    if self.settings.arch == "x86":
      self.copy("*.h", src="out32/webrtc", dst="webrtc")
      self.copy("*.lib", src="out32/lib", dst="lib")
    elif self.settings.arch == "x86_64":
      self.copy("*.h", src="out64/webrtc", dst="webrtc")
      self.copy("*.lib", src="out64/lib", dst="lib")
