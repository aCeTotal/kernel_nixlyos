# CPU-arkitektur per variant (tilsvarer _processor_opt=generic_v1/v3).
# generic (v1) støtter alle x86-64-CPUer, v3 utnytter AVX2-generasjonen.
let
  level = v: {
    flags = [
      "-e GENERIC_CPU"
      "-d MZEN4"
      "-d X86_NATIVE_CPU"
      "--set-val X86_64_VERSION ${toString v}"
    ];
    check = "X86_64_VERSION=${toString v}";
  };
in
{
  generic = level 1;
  v3 = level 3;
}
