# Ytelse: -O3, THP always, thin-LTO og BBR3 + FQ pacing
# (tilsvarer _cc_harder=yes, _hugepage=always, _use_llvm_lto=thin, _tcp_bbr3=yes).
[
  "-d CC_OPTIMIZE_FOR_PERFORMANCE"
  "-e CC_OPTIMIZE_FOR_PERFORMANCE_O3"

  "-d TRANSPARENT_HUGEPAGE_MADVISE"
  "-e TRANSPARENT_HUGEPAGE_ALWAYS"

  "-e LTO_CLANG_THIN"

  "-m TCP_CONG_CUBIC"
  "-d DEFAULT_CUBIC"
  "-e TCP_CONG_BBR"
  "-e DEFAULT_BBR"
  "--set-str DEFAULT_TCP_CONG bbr"
  "-m NET_SCH_FQ_CODEL"
  "-e NET_SCH_FQ"
  "-d DEFAULT_FQ_CODEL"
  "-e DEFAULT_FQ"
]
