# Ytelse: -O3, THP always, thin-LTO og BBR3 + FQ pacing
# (tilsvarer _cc_harder=yes, _hugepage=always, _use_llvm_lto=thin, _tcp_bbr3=yes).
[
  "-d CC_OPTIMIZE_FOR_PERFORMANCE"
  "-e CC_OPTIMIZE_FOR_PERFORMANCE_O3"

  "-d TRANSPARENT_HUGEPAGE_MADVISE"
  "-e TRANSPARENT_HUGEPAGE_ALWAYS"

  "-e LTO_CLANG_THIN"

  # I cachy-treet er BBR3 egen algoritme ("bbr3"); "bbr" er vanilla BBR v1.
  "-m TCP_CONG_CUBIC"
  "-d DEFAULT_CUBIC"
  "-e TCP_CONG_BBR3"
  "-e DEFAULT_BBR3"
  "--set-str DEFAULT_TCP_CONG bbr3"
  "-m NET_SCH_FQ_CODEL"
  "-e NET_SCH_FQ"
  "-d DEFAULT_FQ_CODEL"
  "-e DEFAULT_FQ"
]
