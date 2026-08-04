# Portable environment setup for VSCodium Ops Toolkit
# This file is sourced by /etc/profile for every MSYS2 shell.
# All paths are resolved relative to the msys64 root so the bundle works
# regardless of where VSCodium-portable/ is unpacked.

# Determine the Windows path of the msys64 root and convert it to a Windows path.
# /etc/profile is sourced before ~/.bashrc; MSYSTEM is already set by msystem.
_vscodium_msys_root=$(cd "/" 2>/dev/null && pwd -W 2>/dev/null || cygpath -m "/")
_vscodium_toolkit_root="${_vscodium_msys_root%/msys64}"

# Ensure toolkit binaries shipped in msys64/usr/local/bin are on PATH.
# /etc/profile already adds /usr/local/bin, but keep this explicit for clarity.
if [ -d "/usr/local/bin" ]; then
    case ":${PATH}:" in
        *:/usr/local/bin:*) ;;
        *) PATH="/usr/local/bin:${PATH}" ;;
    esac
fi

# Windows-native tools stored next to VSCodium-portable (none currently).
# If native Windows binaries are added later, prepend them here.
# if [ -d "${_vscodium_toolkit_root}/tools" ]; then
#     PATH="${_vscodium_toolkit_root}/tools:${PATH}"
# fi

# Point kubectl at a portable kubeconfig in the bundle if no user config exists.
# This keeps cluster credentials inside the toolkit folder when desired.
if [ -z "${KUBECONFIG}" ] && [ -f "${_vscodium_toolkit_root}/config/kubeconfig" ]; then
    export KUBECONFIG="${_vscodium_toolkit_root}/config/kubeconfig"
fi

# Make psql look for a portable pg_service.conf / pgpass in the bundle.
if [ -z "${PGSERVICEFILE}" ] && [ -f "${_vscodium_toolkit_root}/config/pg_service.conf" ]; then
    export PGSERVICEFILE="${_vscodium_toolkit_root}/config/pg_service.conf"
fi
if [ -z "${PGPASSFILE}" ] && [ -f "${_vscodium_toolkit_root}/config/pgpass" ]; then
    export PGPASSFILE="${_vscodium_toolkit_root}/config/pgpass"
fi

# Set a persistent location for VSCodium's runtime.sh data.
# configure-runtime.ps1 writes Python/Java overrides there.
# No action needed here; /etc/profile.d/runtime.sh is sourced automatically.

unset _vscodium_msys_root _vscodium_toolkit_root
