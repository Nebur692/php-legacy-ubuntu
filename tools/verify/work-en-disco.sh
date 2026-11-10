# work-en-disco.sh   (sourced by run.sh and run-el8.sh / lo cargan run.sh y run-el8.sh)
# EN: WORK must live on a disk. On a filesystem kept in RAM (tmpfs, ramfs, or rootfs such as Unraid's /tmp)
#     every file the tests write is charged to the container's memory, and nothing can push it out:
#     ext/standard/tests/file/bug81145.phpt alone reserves almost 4 GB with fallocate, so a 4 GB container
#     always dies and an 8 GB one sometimes does (the kernel then kills the biggest process, not the culprit).
#     WORK_EN_RAM=1 skips the check (only with memory to spare).
# ES: WORK tiene que estar en un disco. En un sistema de ficheros en RAM (tmpfs, ramfs, o rootfs como el /tmp
#     de Unraid) cada fichero que escriben las pruebas cuenta como memoria del contenedor, y no hay forma de
#     sacarlo de ahí: ext/standard/tests/file/bug81145.phpt reserva ella sola casi 4 GB con fallocate, así que
#     un contenedor de 4 GB muere siempre y uno de 8 GB a veces (y el sistema mata al proceso más grande, no
#     al culpable). WORK_EN_RAM=1 se salta la comprobación (solo con memoria de sobra).
if [ -n "${WORK:-}" ] && [ "${WORK_EN_RAM:-}" != 1 ]; then
  mkdir -p "$WORK" || exit 2
  case $(df --output=fstype "$WORK" | tail -1 | tr -d ' ') in
    tmpfs|ramfs|rootfs)
      echo "STOP/PARA: WORK=$WORK is in RAM / está en RAM ($(df --output=fstype "$WORK" | tail -1 | tr -d ' ')):"
      echo "  use a folder on a disk / usa una carpeta en un disco (or/o WORK_EN_RAM=1)"
      exit 2;;
  esac
fi
