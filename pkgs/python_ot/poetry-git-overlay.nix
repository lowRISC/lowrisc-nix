{pkgs}: final: prev: {
  chipwhisperer = prev.chipwhisperer.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/newaetech/chipwhisperer-minimal/archive/2643131b71e528791446ee1bab7359120288f4ab.zip";
        sha256 = "19s8hp1n2hb2pbrvsdzi6z098hjcinr4aw8rsj0l5qg00bj8r404";
      };
    }
  );

  edalize = prev.edalize.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/lowRISC/edalize/archive/refs/tags/v0.4.0.zip";
        sha256 = "0c4kc1d6wzixfn4161ax8q45qlzm0iiwhzyjl6kfrymv2l5hv5by";
      };
    }
  );

  fusesoc = prev.fusesoc.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/lowRISC/fusesoc/archive/refs/tags/ot-0.5.dev0.zip";
        sha256 = "131wc0icsfyv8kn9419i0n3qxi3fbhw12mjrai6h9zvd25q0a2dr";
      };
    }
  );
}
