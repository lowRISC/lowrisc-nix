{pkgs}: self: super: {
  chipwhisperer = super.chipwhisperer.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/newaetech/chipwhisperer-minimal/archive/2643131b71e528791446ee1bab7359120288f4ab.zip";
        sha256 = "19s8hp1n2hb2pbrvsdzi6z098hjcinr4aw8rsj0l5qg00bj8r404";
      };
    }
  );

  edalize = super.edalize.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/lowRISC/edalize/archive/refs/tags/v0.4.0.zip";
        sha256 = "0c4kc1d6wzixfn4161ax8q45qlzm0iiwhzyjl6kfrymv2l5hv5by";
      };
    }
  );

  fusesoc = super.fusesoc.overridePythonAttrs (
    _: {
      src = pkgs.fetchzip {
        url = "https://github.com/lowRISC/fusesoc/archive/refs/tags/ot-0.4.zip";
        sha256 = "0dkrfgbmma7fq10ya4jyc8w5bhy3wi4kyqsvr75m2ck5iv2z4dd6";
      };
    }
  );
}
