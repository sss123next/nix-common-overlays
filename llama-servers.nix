{ inputs }:
self: super:
let
  # Три лама-пакета ставят одинаковый набор бинарников (llama-server,
  # llama-cli, llama-bench, ...), поэтому в один profile/env они не встают
  # из-за коллизий. Решение — симлинк-ферма: каждому пакету свой постфикс
  # на ВЕСЬ bin/*, коллизий нет ни с кем, все три доступны одновременно.
  #
  # Симлинки безопасны: rpath каждой бинарни указывает на её родной
  # $out/lib (patchelf — в fixup исходной derivation), поэтому lib в ферму
  # копировать не нужно, а чужой libllama.so они не подхватят.
  #
  # Постфиксы:
  #   -vulkan    — апстрим llama.cpp (ggml-org), Vulkan-сборка
  #   -ik        — ik_llama.cpp, CPU-сборка (AVX2)
  #   -ik-vulkan — ik_llama.cpp, Vulkan-сборка
  # Требует применённых оверлеев ik_llama-cpp, ik_llama-cpp-vulkan и
  # llama-cpp-vulkan (три источника бинарников).
  linkSuffixed =
    suffix: pkg:
    ''
      for f in ${pkg}/bin/*; do
        ln -s "$f" "$out/bin/$(basename "$f")${suffix}"
      done
    '';
in
{
  llama-servers-all = super.runCommand "llama-servers" {
    meta.description = "llama.cpp flavours (upstream Vulkan, ik CPU, ik Vulkan) with suffixed binaries";
  } ''
    mkdir -p $out/bin
    ${linkSuffixed "-vulkan" self.llama-cpp-vulkan-git}
    ${linkSuffixed "-ik" self.ik_llama-cpp-git}
    ${linkSuffixed "-ik-vulkan" self.ik_llama-cpp-vulkan-git}
  '';
}
