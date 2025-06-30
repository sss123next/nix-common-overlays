{ inputs }:
self: super: {
  gallery-dl =
    with super;
    with self.shiton3.pkgs;
    self.shiton3.pkgs.buildPythonPackage rec {
      pname = "gallery-dl";
      version = "git";
      format = "setuptools";
      src = fetchGit {
        url = "https://github.com/mikf/gallery-dl";
        ref = "master";
        #    rev = "842f964c498ab38e953229e95b0889514263311c";
      };

      propagatedBuildInputs = [
        requests
        self.yt-dlp
      ];

      doCheck = false;

      pythonImportsCheck = [
        "gallery_dl"
      ];

      meta = with lib; {
        description = "Command-line program to download image-galleries and -collections from several image hosting sites";
        homepage = "https://github.com/mikf/gallery-dl";
        changelog = "";
        license = licenses.gpl2Only;
      };
    };
}
