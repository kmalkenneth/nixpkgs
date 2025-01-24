{
  stdenv,
  lib,
  replaceVars,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  SDL2_gfx,
  SDL2_mixer,
}:

buildPythonPackage rec {
  pname = "pysdl2";
  version = "0.9.17";
  pyproject = true;

  pythonImportsCheck = [ "sdl2" ];

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SMbvAaTrEj219+RuGhtWVnV1WwfmFfP+IKYjyUc1tSs=";
  };

  patches = [
    (replaceVars ./PySDL2-dll.patch (
      builtins.mapAttrs
        (_: pkg: "${pkg}/lib/lib${pkg.pname}${stdenv.hostPlatform.extensions.sharedLibrary}")
        {
          inherit
            SDL2
            SDL2_ttf
            SDL2_image
            SDL2_gfx
            SDL2_mixer
            ;
        }
    ))
  ];

  build-system = [ setuptools ];

  # Deliberately not in propagated build inputs; users can decide
  # which library they want to include.
  buildInputs = [
    SDL2_ttf
    SDL2_image
    SDL2_gfx
    SDL2_mixer
  ];

  dependencies = [ SDL2 ];

  # The tests use OpenGL using find_library, which would have to be
  # patched; also they seem to actually open X windows and test stuff
  # like "screensaver disabling", which would have to be cleverly
  # sandboxed. Disable for now.
  doCheck = false;

  meta = {
    description = "Wrapper around the SDL2 library and as such similar to the discontinued PySDL project";
    homepage = "https://github.com/marcusva/py-sdl2";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ pmiddend ];
  };
}
