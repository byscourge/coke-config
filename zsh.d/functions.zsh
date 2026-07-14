# some functions and aliases rely on Shizuku (https://github.com/RikkaApps/Shizuku) for priveleged actions, for the best experience i personally reccomend you install it

critical() {
  printf "\033[38;2;255;0;0m$*\033[0m" >&2; return 255
}

err() {
  printf "\033[31m$*\033[0m" >&2; return 1
}

warn() {
  printf "\033[38;5;208m$*\033[0m" >&2; return 1
}

pf() {
  printf "$*"
}

ok() {
  printf "\033[92m$*\033[0m"; return 0
}

info() {
  printf "\033[38;2;0;255;255m$*\033[0m";
}

rish() {
  # rish is a way to interact with LADB (local adb shell/uid 2000) via shizuku. ## https://github.com/RikkaApps/Shizuku
  sh /data/data/com.termux/files/home/.local/bin/rish "$@"
}


char() { echo -n "$@" | wc -m; }

search() {
  term=$(echo "$*" | sed 's/ /+/g')
  am start -a android.intent.action.VIEW -d "https://www.google.com/search?q=$term"
}

pkch() { ## simple pkg searching function
  rish -c "pm list packages | grep -i \"$*\" | sed 's/package://g'"
}

ccont() { ## stands for copy content (copy=c (conent=cont))
  cat "$@" | termux-clipboard-set
}

mfn() { #make file new
  local pussy
    for pussy in "$@"; do
        touch -d "today" "$pussy"
        termux-media-scan "$pussy"
    done
}

tms() { #termux-media-scan, scans media
    for titties in "$@"; do ## we love boobs
        termux-media-scan "$titties"
    done
}

cl() {                                                      
    if [[ -t 0 ]]; then
        # No pipe: use arguments
        if [[ $# -eq 0 ]]; then
            echo "cl: missing text or file" >&2
            return 1
        fi
        if [[ -f "$1" ]]; then
            ccont "$1"
        else
            printf '%s\n' "$*"
            printf '%s\n' "$*" | termux-clipboard-set
        fi
    else
        tee >(termux-clipboard-set)   # copies to clipboard and prints to screen
    fi
}

testruecolor() { ## tests colors
  awk 'BEGIN{
    s="/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510 - g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
}

cdb() { cd $(printf '../%.0s' $(seq 1 ${1:-1})); }

se() {echo -ne '\e[6 q'} # idk why i named it se.. set e? set cursor-e.....????????????????? maybe cuz echo -n "E" and set so uhhhhh... anyways it just makes your cursor a pipe (I-Beam) instead of the block 

shizuku() { ## open shizuku
  am start -n moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity 2>/dev/null
}

dur() { ## cats dev/urandom
  cat /dev/urandom|head -c "$1"
}

drc() { ## cats /dev/urandom with..... character counting
  cat /dev/urandom|head -c "$1"|tcs
}

mfe() { ## make file empty, makes files empty.
  dd if=/dev/null of="$1" bs=1K count=1
}

mfz() { ## makes files zeroes, useful for when u want a huge file
  dd if=/dev/zero of="$1" bs="$2" count="$3"
}

mfur() { ## makes files urandom, really nice for what mfz does and also fucking over data (overwriting)
  dd if=/dev/urandom of="$1" bs="$2" count="$3"
}

wtd() { ## while true do.. does thigns while true lol
  local allargs="$*"
  while true; do
    eval "$allargs" # rewrote
  done
}

wtw() { ## while true do with wait, what a surpriseeeeeeeeee
  local firstarg="$1"
  shift
  local allargs="$*"
  while true; do
    eval "$allargs"
    sleep "$firstarg" # rewrote
  done
}

fin() { ## for i in
  local firstarg="$1"
  shift
  local allargs="$*"
  for i in range {2..$firstarg}; do # 2 because of shift. either that or anything else because if its 1, for example fin 3 ls does ls 4 times or 0 does does it 5 times.
    eval "$allargs"
  done # i rewrote this myself (again) WITHOUT chatgpt because it sucks ass at shell coding lol, and yes this works better than the "((i++))" bullshit.
}

cg() { ## cd glob
    if [[ -z "$1" ]]; then
      cd *
    else
      cd $1*
    fi
  }

zg() { ## z glob
  if [[ -z "$1" ]]; then
    z *
  else
    z $1*
  fi
}


exap() { ## standing for ex(tract)ap(k). anyways what it does is extract the apk from an app e.g exap com.testapp, and it copies its apk to ./com.testapp.apk
  local pacname pacpath target
  pacname="$1"
  target="$2"

  pacpath=$(soap "$pacname")
  pacpath=${pacpath:8}

  if [[ -z "$target" ]]; then
    cp "$pacpath" "./$pacname.apk"
  else
    cp "$pacpath" "$target/$pacname.apk"
  fi
}





apm() { ## android.package.manager, priveleged interactive CLI package/app management built specifically for android.
  if [ $# -eq 0 ]; then
    echo "stdout *apps;"
    output=$(rish -c "pm list packages")
  else
    echo "REGEX:: $*;"
    output=""
    for term in "$@"; do
      part=$(rish -c "pm list packages | grep -i \"$term\"")
      output="$output"$'\n'"$part"
    done
  fi

  output=$(echo "$output" | grep -v '^$' | sort -u)

  if [ -z "$output" ]; then
    err "stderr: Matching REGEX=NULL;\n"
    return 1
  fi

  pkgs=$(echo "$output" | sed 's/^package://')

  i=1
  echo "$pkgs" | while IFS= read -r line; do
    echo -n "$i) $line\n"
    i=$((i + 1))
  done

  echo -n "stdin INT (1-$((i - 1))): "
  read num

  if ! echo "$num" | grep -qE '^[0-9]+$'; then
    err "stderr: Invalid INT (out of bounds);\n"
    return 1
  fi
  if [ "$num" -lt 1 ] || [ "$num" -ge "$i" ]; then
    err "stderr: Invalid INT (out of bounds);\n"
    return 1
  fi

  selected=$(echo "$pkgs" | sed -n "${num}p")

  echo "stdin: $selected"

  echo -n "exec stdin::$ "
  read cmd

  if [ "$cmd" = "mop" ]; then
    cmd="monkey -p $selected -c android.intent.category.LAUNCHER 1"
    echo "sh::rish -c \"$cmd\""
    rish -c "$cmd"
    return 0

  elif [ "$cmd" = "kill" ]; then
    cmd="am force-stop $selected"
    echo "sh::rich -c \"$cmd\""
    rish -c "$cmd"
    return 0

elif [ "$cmd" = "exap" ]; then
    echo "extracting stdin:: $selected..."

    # get the APK path (first APK if multiple)
    apkpath=$(rish -c "pm path $selected" | sed 's/^package://' | head -n1)
    apkpath=${apkpath#file://}

    if [ -z "$apkpath" ]; then
        err "stderr: $selected.apk == NULL\n"
        return 1
    fi

    # copy to current dir as selected.apk
    cp "$apkpath" "./$selected.apk" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Returncode=0! PATH:: [./$selected.apk]"
    else
        err "stderr: Extraction Returncode!=0;\n"
        echo "DEBUG: PATH='$apkpath'"
        ls -l "$apkpath" 2>/dev/null
        return 1
    fi

    return 0
  elif [ "$cmd" = "inf" ]; then
  am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$selected
  elif [ "$cmd" = "info" ]; then
    am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$selected
fi

  case "$cmd" in
    monkey*)
      # remove existing -p arg if any
      cmd=$(echo "$cmd" | sed -E 's/ -p [^ ]+//g')
      # insert -p right after monkey
      cmd=$(echo "$cmd" | sed -E "s/^(monkey)/\\1 -p $selected/")
      echo "sh::rish -c \"$cmd\""
      rish -c "$cmd"
      ;;
    *)
      echo "sh::rish -c \"$cmd $selected\""
      rish -c "$cmd $selected"
      ;;
  esac
}

pen() { ## print enviroment variables and find patterns in them
if [[ $# -eq 0 ]]; then
  printenv|sort
else
  printenv|sort|rg -- "$*"
fi
}

fz() { ## finds stuff in your zsh (ZShell) config ( ~/zsh.d/ )
  local arg1="$1"
  if [[ -z "$arg1" ]]; then
    err "Purpose: finding specific configurations in the files from ~/zsh.d/\nNoOp, Usage: [fz [a/al/f/un/z/uf/e/h/k/pa/p/t]]\n\nExamples: fz al 'alias somealias=', to find an alias named somealias in ~/zsh.d/aliases.zsh.\n\n"
  elif [[ "$arg1" == "-h" ]]; then
    pf "Purpose: finding specific configurations in the files from ~/zsh.d/\nUsage: [fz [a/al/f/un/z/uf/e/h/k/pa/p/t]]\n\nExamples: fz al 'alias somealias=', to find an alias named somealias in ~/zsh.d/aliases.zsh.\n\n"
  elif [[ "$arg1" == "-N" ]]; ## if you use {fz -N somefile somepattern} you'll need to put the pattern in quotes when using -N, as it doesnt use shift/all args and instead uses a multiple argument approach (flag (-N), file, pattern) unlike if you dont use -N which uses an infinite argument approach (file, the rest of this here whether you use spaces or other stuff is treated as a single string.) 
  then
    local file="$2"
    local regex="$3"
    
    case "$file" in
      f|fu|fun|func|function|functions)
        ff -N ~/zsh.d/functions.zsh "$regex"
      ;;
      al|alias|aliases)
        ff -N ~/zsh.d/aliases.zsh "$regex"
      ;;
      a|at|au|auto|startup|autostart|ast)
        ff -N ~/zsh.d/autostart.zsh "$regex"
      ;;
      e|ex|exp|exports)
        ff -N ~/zsh.d/exports.zsh "$regex"
      ;;
      h|ho|hook|hooks)
        ff -N ~/zsh.d/hooks.zsh "$regex"
      ;;
      k|key|ky|binds|keybinds|keybind)
        ff -N ~/zsh.d/keybinds.zsh "$regex"
      ;;
      pkg|pcheck|pgc|pack|package|pa)
        ff -N ~/zsh.d/pkgchecks.zsh "$regex"
      ;;
      p|pl|plug|plugins|plugin)
        ff -N ~/zsh.d/plugins.zsh "$regex"
      ;;
      t|th|theme|themes)
        ff -N ~/zsh.d/themes.zsh "$regex"
      ;;
      un|una|unal|unalias|unaliases)
        ff -N ~/zsh.d/unaliases.zsh "$regex"
      ;;
      unf|unfunc|unfunctions)
        ff -N ~/zsh.d/unfunctions.zsh "$regex"
     ;;
      z|zsh|zs|zshrc)
        ff -N ~/.zshrc "$regex"
      ;;
     all)
       local every_file;
       for every_file in ~/zsh.d/*; do
         if [[ -z "$regex" ]]; then
           ff -N "$every_file"
         else
           rg --with-filename -N -- "$regex" "$every_file"
         fi
       done
       ;;
     *)
       err "Invalid category \"$file\", pass -h to show the help screen, otherwise add the category yourself.\n"
       return 1
       ;;
    esac
  else
    shift
    local argv="$*"
    
    case "$arg1" in
      f|fu|fun|func|functions)
        ff ~/zsh.d/functions.zsh "$argv"
      ;;
      al|alias|aliases)
        ff ~/zsh.d/aliases.zsh "$argv"
      ;;
      a|at|au|auto|startup|autostart|ast)
        ff ~/zsh.d/autostart.zsh "$argv"
      ;;
      e|ex|exp|exports)
        ff ~/zsh.d/exports.zsh "$argv"
      ;;
      h|ho|hook|hooks)
        ff ~/zsh.d/hooks.zsh "$argv"
      ;;
      k|key|ky|binds|keybinds|keybind)
        ff ~/zsh.d/keybinds.zsh "$argv"
      ;;
      pkg|pcheck|pgc|pack|package|pa)
        ff ~/zsh.d/pkgchecks.zsh "$argv"
      ;;
      p|pl|plug|plugins|plugin)
        ff ~/zsh.d/plugins.zsh "$argv"
      ;;
      t|th|theme|themes)
        ff ~/zsh.d/themes.zsh "$argv"
      ;;
      un|una|unal|unalias|unaliases)
        ff ~/zsh.d/unaliases.zsh "$argv"
      ;;
      uf|unf|unfun|unfunc|unfu|unfunctions)
        ff ~/zsh.d/unfunctions.zsh "$argv"
     ;;
      z|zsh|zs|zshrc)
        ff ~/.zshrc "$argv"
      ;;
     all)
       local every_file;
       for every_file in ~/zsh.d/*; do
         if [[ -z "$argv" ]]; then
           ff "$every_file"
         else
           rg --with-filename -n -- "$argv" "$every_file"
         fi
       done
       ;;
     *)
       err "Invalid category \"$arg1\", pass -h to show the help screen, otherwise add the category yourself.\n"
       return 1
       ;;
    esac
  fi
}

fperm() {
  stat -c %a "$@"
}

su() { ## emulates a semi-root enviroment with shell(2000) priveleges via shizuku + rish(); (line :11), basically fakeroot but with real priveleges, albeit less than root.

  if command -v rish &>/dev/null; then
    :
  else
    critical "Even though this function is made to be used specifically with my dotfiles, which has rish preinstalled, rish doesnt exist.\nBut it's fine, just install rish and if you have shizuku you'll be fine."
    return 255
  fi
  
  local shizuku.IsRunning() {
    if ! {rish -c "return 0"} then
      critical "stderr: Critical [Shizuku failed.]; it may not be installed, configured properly, or running; Abort.\n"
      return 255
    else
      return 0;
    fi
  }

ldd.IsInstalled() {
  if command -v ldd &>/dev/null && [[ -f $bin/ldd || -f ~/.local/bin/ldd ]] then
      :
    else
      critical "stderr: Critical [the ldd bin could not be found.]\n"
      info "Installing ldd..\n"

      case "$PKG" in
        apt) apt install ldd -y ;;
        pacman) pacman -S ldd --noconfirm ;;
        *) pkg install ldd -y ;;
      esac

    if command -v ldd &>/dev/null && [[ -f $bin/ldd || -f ~/.local/bin/ldd ]] then
      ok "ldd Sucessfully installed!\n"
    else
      critical "stderr: Critical [ldd could not be installed.]\n"
      return 255
    fi
  fi
}

vim+nano.installed() {
  local missing=()

  if [[ ! -f $libexec/vim/vim ]]; then
    missing+=("vim")
  fi

  if ! command -v nano >/dev/null 2>&1; then
    missing+=("nano")
  fi

  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi

  err "The following required text editors are missing: ${missing[*]}.\n"
  err "Could not configure text editors without them.\n"
  sleep 0.5

  local success=true

  for editor in "${missing[@]}"; do

    info "\nUpdating repos..\n"
    case "$PKG" in
      apt) apt update ;;
      pacman) pacman -Sy ;;
      *) pkg update ;;
    esac

    info "Installing $editor...\n"

    case "$PKG" in
      apt)
        apt install "$editor" -y
        ;;
      pacman)
        pacman -S "$editor" --noconfirm
        ;;
      *)
        pkg install "$editor" -y
        ;;
    esac

    if [[ $? -eq 0 ]]; then
      ok "$editor successfully installed!\n"
    else
      critical "$editor could not be installed.\n"
      success=false
    fi
  done

  $success && return 0 || return 1
}

# local functions+logic

  local changeTermuxRoot() {
    if [[ $# -eq 0 ]]; then
      err "specify a permission number."
      return 1
    elif [[ $# -gt 1 ]]; then
      err "only 1 arg allowed"
      return 1
    else
      echo "Changing termux fs permissions to $1...\n"
    chmod "$1" /data/data/com.termux /data/data/com.termux/files/ $PREFIX $PREFIX/etc $PREFIX/etc/bash.bashrc;
    chmod "$1" -R $PREFIX/bin $PREFIX/lib $PREFIX/tmp
    fi
  }

  local changeShellRoot() {
    echo "Changing Shell's fs permissions to $1..."
    shizuku.IsRunning && rish -c "chmod $1 -R /data/local/tmp/sh"
  }

  local bootStrapDirectories() {
    echo "starting Init /data/local/tmp/sh (Shell's fs)..\n"

    shizuku.IsRunning && rish -c "cd /data/local/tmp/ && \
    mkdir ./sh 2>/dev/null
    
    echo 'Creating common directories'

    mkdir -p sh/home/ sh/usr/bin/  sh/usr/lib/ sh/etc/  sh/usr/share/terminfo/ sh/usr/libexec/ sh/tmp"
  }

  local findBashLibraries() {
  echo "Finding Bash needed Linking Libraries"
    realpath $(findLibPaths $PREFIX/bin/bash)|tr '\n ' ' ' > $PREFIX/tmp/bashLibraries # we cant use links without rish
  }

local boot.InstallTree() {
  if command -v tree &>/dev/null && [[ -f $bin/tree ]]; then
    rish -c "cp /data/data/com.termux/files/usr/bin/tree /data/local/tmp/sh/usr/bin/tree" && return 0
  else
    err "tree may not be installed, attempting to install..\n"

    case "$PKG" in
      apt) apt install tree -y ;;
      pacman) pacman -Sy tree --noconfirm ;;
      *) pkg install tree -y ;;
    esac

    if [[ -f $bin/tree ]]; then
      ok "Tree successfully installed!\n"
      rish -c "cp /data/data/com.termux/files/usr/bin/tree /data/local/tmp/sh/usr/bin"
    else
      err "tree could not be installed, skipping :(\n"
      return 1
    fi
  fi

  if command -v tree &>/dev/null && [[ ! -f /data/local/tmp/sh/usr/bin/tree ]] ; then
    warn "\n...tree is installed, but was not copied for some reason\n"
    info "Retrying...\n"
    openTermux
    rish -c "cp /data/data/com.termux/files/usr/bin/tree /data/local/tmp/sh/usr/bin" && closeTermux || critical "tree could still not be copied, Abort.\n"
  fi
}

  local copyBash() {
    echo "Copying bash to Shell's bin/"
    shizuku.IsRunning && rish -c "cp /data/data/com.termux/files/usr/bin/bash /data/local/tmp/sh/usr/bin/"
  }

  local copyBashLibraries() {
    echo "Copying bash's needed Linking libraries to Shell's lib/"
    shizuku.IsRunning && rish -c "cp $(cat /data/data/com.termux/files/usr/tmp/bashLibraries) /data/local/tmp/sh/usr/lib"
  }

  findLibPaths() {
   ldd.IsInstalled && ldd "$1" 2>/dev/null | awk '/=>/ {print $3}' | grep -v '^$' | tr '\n' ' '
  }

local runEnviroment() {
    rish -c "\
    export PATH=/data/local/tmp/sh/usr/bin/:\$PATH && \
    export LD_LIBRARY_PATH=/data/local/tmp/sh/usr/lib:$LD_LIBRARY_PATH && \
    exec bash -c 'export LD_LIBRARY_PATH=/data/local/tmp/sh/usr/lib && \

    export PATH=/data/local/tmp/sh/usr/bin:\$PATH && \
    export HOME=/data/local/tmp/sh/home && \
    export PREFIX=/data/local/tmp/sh/usr && \
    export SHELL=/data/local/tmp/sh/usr/bin/bash && \
    export LS_COLORS=\"di=34:fi=92:ln=96:ex=31\" && \
    export termuxPrefix=/data/data/com.termux/files/usr && \
    export TERM=xterm-256color && \
    export TERMINFO=/data/local/tmp/sh/usr/share/terminfo
    export PS1=\"\\[\e[38;5;129m\]:\\\$(pwd) # \\[\e[0m\]\" && \
    cd / && \
    chmod 755 -R /data/local/tmp/sh && \
    exec bash'"
}

  initEnviroment() {
    echo "running Init RootFS for Shell"
    shizuku.IsRunning && rish -c "chmod 755 /data/local/tmp && \
      mkdir /data/local/tmp/sh 2>/dev/null && \
      chmod 777 -R /data/local/tmp/sh"
}

  local linkBashLibraries() {
    echo "linking Bash required Libaries's realPath, to their needed equivalent"
      shizuku.IsRunning && rish -c " cd /data/local/tmp/sh/usr/lib && \
        cp libreadline.so.* libreadline.so.8
        cp libncursesw.so.* libncursesw.so.6
    "
}

  local removeShell.RootFS() {
    shizuku.IsRunning && \

      if [[ ! -d /data/local/tmp/sh ]] then
        err "stderr: conf was not installed, could not uninstall it.\n"
        return 1;
      else
        info "Wiping shell's rootfs...\n"
        {rish -c "rm -rf /data/local/tmp/sh" && return 0} || return 1;
      fi

  }

  config::LsColors() {
    printf "Configuring ls colors.."
    sleep 0.2

    [[ -d /data/local/tmp/sh/home ]] && {rish -c "echo alias ls=\"'ls --color=auto'\" > /data/local/tmp/sh/home/.bashrc" && ok "Success!\n"; return 0 } || return 1;
  }

  local boot.InstallFiles() {

    shizuku.IsRunning && \

    changeTermuxRoot 755 && \
    changeShellRoot 755 && \
    findBashLibraries && \
    copyBash && \
    copyBashLibraries && \
    linkBashLibraries && \
    config::LsColors && \
    boot.setupTermInfo && \
    boot.InstallTexEd && \
    boot.InstallTree

    return 0;

  }

  local boot.Install() {

      printf "\nStarting Installation."
    for sleep in {1..6}; do
      sleep 0.2
      printf "."
    done; printf "\n\n"

  {
    shizuku.IsRunning && initEnviroment && \
    changeTermuxRoot 755 && \

    bootStrapDirectories && \
    changeShellRoot 755 && \
    
    findBashLibraries && \
    copyBash && \
    copyBashLibraries && \
    linkBashLibraries && \
    boot.setupTermInfo && \
    boot.InstallTexEd && \
    boot.InstallTree

  } && {{{ok "Success!"; printf " conf Sucessfully installed,"; ok " you may now run \"su\" to login.\n\n";} && \
    config::LsColors} && return 0;} || return 1;
}

  already:Installed() {

    shizuku.IsRunning || return 1

    [[ -d /data/local/tmp/sh ]] || return 255

    shellDirs=(
      $dlt/usr/share/terminfo
      $dlt/usr
      $dlt/home
      $dlt/etc
      $dlt/tmp
      $dlt/usr/bin
      $dlt/usr/lib
      $dlt/usr/libexec
      $dlt/usr/share
      $dlt
      )

    shellFiles=(     
      $dlt/usr/bin/bash
      $dlt/usr/lib/ld-android.so
      $dlt/usr/lib/libandroid-support.so
      $dlt/usr/lib/libc.so
      $dlt/usr/lib/libdl.so
      $dlt/usr/lib/libiconv.so
      $dlt/usr/lib/libncursesw.so.6.5
      $dlt/usr/lib/libreadline.so.8.3
      $dlt/usr/lib/libncursesw.so.6
      $dlt/usr/lib/libreadline.so.8
      )
    
      dir=("${shellDirs[@]}")
      file=("${shellFiles[@]}")

      for dirs in "${dir[@]}"; do
        if [[ -d "$dirs" ]]; then
          :
        else
          return 1
        fi
      done

        for files in "${file[@]}"; do
          if [[ -f "$files" ]]; then
            return 0
          else
            return 1
          fi
        done
  }

  local boot.Init() {
    boot.Install && \
    runEnviroment && \
    return 0;
  }

  local revertChanges() {
    {pf "Changing termux's LocationPermissions to 750 (*rwxr-x---)\n"
    closeTermux
    closeTermuxBackups
    deleteTermuxBackups
    pf "Removing usr/tmp/bashLibraries\n"
    rm $PREFIX/tmp/bashLibraries 2>/dev/null}
    return 0;
  }

  changeTermuxLibexecPerms() {
    chmod "$1" -R $libexec
  }

  openTermux() {
    info "Opening termux's fs..\n"
    changeTermuxRoot 755
    changeTermuxSharePerms 755
    changeTermuxTexEdperms 755
    changeTermuxLibexecPerms 755
  }

  closeTermux() {
    info "Closing termux's fs..\n"
    changeTermuxRoot 750
    changeTermuxSharePerms 750
    changeTermuxTexEdperms 750
    changeTermuxLibexecPerms 750
  }

  openTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    info "Opening termux's external backup location..\n"
    changeTermuxRoot 755
    chmod 755 -R $PREFIX/ext_baks
  }

  closeTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    info "Closing termux's external backup location..\n"
    changeTermuxRoot 750
    chmod 750 -R $PREFIX/ext_baks
  }

  deleteTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    warn "Are you sure? this will delete the backups you made of the shell config.\n(if you did not create any then {do not worry, this wont delete anything.})\n[y/n] "
    local rrr;read rrr; case "$rrr" in
    y|Y) rm -rf $PREFIX/ext_baks && ok "Successfully deleted shell backups!\n" ;;
    n|N|*) err "\nAbort.\n" ;; esac
  }

  openShell() {

  [[ -d /data/local/tmp/sh ]] && \
    info "Opening shell's fs permissions..\n"
    changeShellRoot 755 1>/dev/null && \
    ok "Success!\n"
  }

  closeShell() {
    info "Closing shell's fs permissions..\n"
    changeShellRoot 750 1>/dev/null && \
    ok "Success!\n"
  }

  boot.Init+Validation() {

    if [[ -d /data/local/tmp/sh ]]; then
      dlt=/data/local/tmp/sh
    else
      {shizuku.IsRunning} && rish -c "mkdir /data/local/tmp/sh" && dlt=/data/local/tmp/sh
    fi

    shellDirs=(
      $dlt/tmp
      $dlt/usr/libexec
      $dlt/usr/share/terminfo
      $dlt/usr/share/terminfo/a
      $dlt/usr/share/terminfo/d
      $dlt/usr/share/terminfo/e
      $dlt/usr/share/terminfo/f
      $dlt/usr/share/terminfo/g
      $dlt/usr/share/terminfo/k
      $dlt/usr/share/terminfo/l
      $dlt/usr/share/terminfo/n
      $dlt/usr/share/terminfo/p
      $dlt/usr/share/terminfo/r
      $dlt/usr/share/terminfo/s
      $dlt/usr/share/terminfo/t
      $dlt/usr/share/terminfo/v
      $dlt/usr/share/terminfo/x
      $dlt/usr
      $dlt/home
      $dlt/etc
      $dlt/usr/bin
      $dlt/usr/lib
      $dlt/usr/share
      $dlt
      )

    shellFiles=(     
      $dlt/usr/share/terminfo/a/alacritty
      $dlt/usr/share/terminfo/a/alacritty+common
      $dlt/usr/share/terminfo/a/alacritty-direct
      $dlt/usr/share/terminfo/a/ansi
      $dlt/usr/share/terminfo/d/dtterm
      $dlt/usr/share/terminfo/d/dumb
      $dlt/usr/share/terminfo/e/eterm-color
      $dlt/usr/share/terminfo/f/foot
      $dlt/usr/share/terminfo/f/foot+base
      $dlt/usr/share/terminfo/f/foot-direct
      $dlt/usr/share/terminfo/g/gnome
      $dlt/usr/share/terminfo/g/gnome-256color
      $dlt/usr/share/terminfo/k/kitty
      $dlt/usr/share/terminfo/k/kitty+common
      $dlt/usr/share/terminfo/k/kitty-direct
      $dlt/usr/share/terminfo/l/linux
      $dlt/usr/share/terminfo/n/nsterm
      $dlt/usr/share/terminfo/p/putty
      $dlt/usr/share/terminfo/p/putty-256color
      $dlt/usr/share/terminfo/r/rxvt
      $dlt/usr/share/terminfo/r/rxvt-256color
      $dlt/usr/share/terminfo/r/rxvt-unicode
      $dlt/usr/share/terminfo/r/rxvt-unicode-256color
      $dlt/usr/share/terminfo/s/screen
      $dlt/usr/share/terminfo/s/screen-256color
      $dlt/usr/share/terminfo/s/screen2
      $dlt/usr/share/terminfo/s/st
      $dlt/usr/share/terminfo/s/st-256color
      $dlt/usr/share/terminfo/t/tmux
      $dlt/usr/share/terminfo/t/tmux-256color
      $dlt/usr/share/terminfo/v/vt100
      $dlt/usr/share/terminfo/v/vt102
      $dlt/usr/share/terminfo/v/vt52
      $dlt/usr/share/terminfo/x/xterm
      $dlt/usr/share/terminfo/x/xterm+256color
      $dlt/usr/share/terminfo/x/xterm-16color
      $dlt/usr/share/terminfo/x/xterm-256color
      $dlt/usr/share/terminfo/x/xterm-color
      $dlt/usr/share/terminfo/x/xterm-kitty
      $dlt/usr/share/terminfo/x/xterm-new
      $dlt/usr/lib/libreadline.so.8
      $dlt/usr/lib/ld-android.so
      $dlt/usr/lib/libandroid-support.so
      $dlt/usr/lib/libc.so
      $dlt/usr/lib/libdl.so
      $dlt/usr/lib/libiconv.so
      $dlt/usr/lib/libncursesw.so.6.5
      $dlt/usr/lib/libreadline.so.8.3
      $dlt/usr/lib/libncursesw.so.6
      $dlt/usr/bin/bash
      $dlt/usr/bin/nano
      $dlt/usr/bin/vim
      $dlt/usr/bin/vi
      $dlt/usr/bin/tree
      )
    
      dir=("${shellDirs[@]}")
      file=("${shellFiles[@]}")

      for dirs in "${dir[@]}"; do
        if [[ -d "$dirs" ]]; then

         for files in "${file[@]}"; do
           if [[ -f "$files" ]]; then
             ct=$HOME/comTermux/
             ctf=$ct/files/
             etc=$PREFIX/etc/
             bash=$etc/bash.bashrc
             permsShouldBeOctal=3020
             
             permsAre=$(($(fperm $ct)+$(fperm $ctf)+$(fperm $etc)+$(fperm $bash)))

             if (($permsAre == $permsShouldBeOctal)) then
                runEnviroment
                return 0;
             else
               fix::bash.bashrc\\ENOPERM && \
               runEnviroment
               return 0
             fi
           else

            err "Uh-Oh! The directories exist but some files are missing.\n"
            shizuku.IsRunning && printf "Attempting to create required files..\n"
            sleep 0.5
            boot.InstallFiles
            if [[ -f "$files" ]]; then
              ok "Success! Attempting to log into [shell(2000)], you wont see this message again unless the right conditions are met.\n"
              sleep 0.2;
              printf "\n\n"
              runEnviroment
              return 0;
            else
              critical "Uh-Oh! Critical [Files could not be created]; The only explanation could be that shizuku failed. If shizuku works and this still failed, then you're on your own;\nBailing out, Goodluck.\n\n";
              return 74;
            fi
           fi
          done

        else
          err "Uh-Oh! some directories are missing!\n"
          printf "Attempting to create required directories..\n"
          sleep 0.5;
          bootStrapDirectories
          boot.setupTermInfo

          if [[ -d "$dirs" ]]; then
            ok "Directories successfully created!\n"
          else
            critical "Uh-Oh! stderr: Critical [Directories could not be created]; The only explanation could be that shizuku failed. If shizuku works and this still failed, then you're on your own;\nBailing out, Goodluck.\n\n"
            return 74;
          fi
        fi
      done
  }

fix::bash.bashrc\\ENOPERM() {
  ct=/data/data/com.termux
  printf "\nFixing perm errors on login..\n"
  {chmod 755 $ct $ct/files/ $ct/files/usr/ $ct/files/usr/etc $ct/files/usr/etc/bash.bashrc} && return 0;
}

  
  local changeTermuxTexEdperms() {
    pf "Changing termux's usr/bin && libexec permissions to $1...\n"
      pref=/data/data/com.termux/files/usr
      chmod "$1" -R $pref/bin && \
      chmod "$1"    $pref/libexec/ && \
      {
        {
        chmod "$1" $pref/libexec/vim $pref/libexec/vim/vim 2>/dev/null
        } || \
        {
          err "\nVim may not be installed, could not change libexec/vim's permissions. but, the other permission changes succeeded.\n"; return 1
        }
      }
    }

  local changeTermuxSharePerms() {
    pf "Changing termux's usr/share && terminfo permissions to $1...\n"
      pref=/data/data/com.termux/files/usr/share/
      chmod "$1" $pref
      chmod "$1" -R $pref/terminfo
    }

  local boot.InstallTexEd() {

    vim+nano.installed &&  {

    printf "Setting up text editors (vim & nano)..\n"
    sleep 0.2

    changeTermuxRoot 755 && \
    changeShellRoot 755 && \

    printf "Changing some termux path perms..\n"
    changeTermuxTexEdperms 755 && \
    printf "copying binaries to shell's bin/\n\n"

    {shizuku.IsRunning && [[ -d /data/local/tmp/sh/usr/bin/ ]] && rish -c "
    cp /data/data/com.termux/files/usr/bin/nano /data/local/tmp/sh/usr/bin/nano && \
      cp /data/data/com.termux/files/usr/libexec/vim/vim /data/local/tmp/sh/usr/bin/vim && \
      cp /data/local/tmp/sh/usr/bin/vim /data/local/tmp/sh/usr/bin/vi && \
      touch /data/local/tmp/sh/home/.vimrc" && return 0;}} || \
      critical "\stderr: Critical [Could not install text editors]\n"; return 1;
  }

  local boot.setupTermInfo() {
    printf "Setting up terminfo..\n"
    sleep 0.2

      changeTermuxRoot 755 && \
      changeTermuxSharePerms 755 && \

  shizuku.IsRunning && \

  [[ -d /data/local/tmp/sh/usr/share/terminfo/ ]] && \

  rish -c "cp -r /data/data/com.termux/files/usr/share/terminfo/* /data/local/tmp/sh/usr/share/terminfo/" && return 0 || return 1;
  }

# logic end

if [[ -z "$1" ]]; then
  if already:Installed; then
    boot.Init+Validation
    return
  else
    err "seems like the su() enviroment isn't installed,\ndo you want to install it? [y/N]: "
    local reply
    read -r reply
    case "$reply" in
      y | Y)
        boot.Init+Validation
        ;;
      *)
        info "Abort.\n"
        return 1
        ;;
    esac
  fi
fi


if [[ -n "$1" ]]; then

  if [[ "$1" == -*  ]]; then
  case "$1" in

    -u|--uninstall)

    if [[ -n "$2" && "$2" == -[yYfF] ]]; then
      printf "Wiping Shell's fs...\n"; removeShell.RootFS && ok "Success!\n"; return 0
    else
      shizuku.IsRunning && info "{Shell.RootFS uninstallation}: Are you sure? if you stored sensitive data, or unbacked up configs here you will \033[91mpermanently\033[0m lose them. [y/N]\n"
      local Choice; read Choice; case "$Choice" in;
      y|Y|yes|Yes|yes) printf "Wiping Shell's fs...\n"; removeShell.RootFS && ok "Success!\n" && return 0 ;;
      n|N|No|no|*) printf "Abort.\n"; return 1 ;; esac
    fi
    ;;

  -uf|-fu|-uF|-Fu|-FU|-UF) 
      printf "Wiping Shell's fs...\n"; removeShell.RootFS && ok "Success!\n"; return 0 ;;

    -i|--install)
      if already:Installed; then
        warn "stderr: warning: Conf already installed, run su -r/--reinstall to reinstall it.\n"
      else
        {boot.Install && su -rev && return 0} || return 1
      fi
      ;;
    
    -rev|--revert) revertChanges && return 0; ;;

    -r|--reinstall)
      {su -u && su -i 2>/dev/null && return 0} || return 1; ;;

    -ref|-reif|rnsf|--reinstall-force)
      {su -fu && su -i 2>/dev/null && return 0} || return 1; ;;

    -h|--help)

      cat <<EOF

pseudo SuperUser via shizuku on termux

      Options:

      -u [Wipes the config]
      -uf [Forcefully wipes the config]
      -i [Installs the config]
      -r [Reinstalls the config]
      -ref [Forcefully reinstalls the config]

      -fbe {[Fixes the permission error shown below]
"bash: /data/data/com.termux/files/usr/etc/bash.bashrc: Permission denied"
      on su login}

      -rev [Reverts all changes made to termux's files]
      --nuke/--wipe [Fully reverts all changes made by {su}, besides package installations]
      -o [if -l is passed, login with termux having open permissions, else just open permissions]
      -ct [closes termux's fs]
      -c [Calls sudo]
      -cs [Closes shell's fs permissions]
      -os [Opens shell's fs permissions]

      --backup-conf [Backs up your current shell config, pass --backup-conf -h for more specific info.]

      -h/--help [Show this help screen]

Base: rish [~/.local/bin/rish], shizuku's default shell
EOF
return 0
;;

    -fix|-bashrc|-fixbashrc|-fixpermerror|-fbe|fixbasherr)
      warn "\nThis will make $etc/bash.bashrc world readable, to fix the permission error on su startup\n{--help for more info}."; printf "\n[y/N] ";
      local input;
      read input
      case "$input" in
        y|Y|yes|Yes) fix::bash.bashrc\\ENOPERM && ok "Success!\n"; return 0 ;;
        n|N|no|No) err "Abort.\n"; return 1 ;;
        *) err "Invalid option [y/n]\nAbort.\n"; return 1;;
      esac ;;

    -c|--command|-cc) shift; sudo "$*" ;;

    --nuke|--wipe|--redo-all) {removeShell.RootFS ; revertChanges} && info "\nFull wipe success!, all changes that were made by su were undone.\n\n"; return 0;;

    -o|--open)
      if [[ "$2" == "-l" ]] then
      info "\nStarting with termux having permissive permissions.\n"; openTermux && boot.Init+Validation
    else
      openTermux
      fi ;;

    --close|-ct) closeTermux ;;

    --close-shell|-cs) closeShell ;;
    -os|--open-shell) openShell ;;

    --backup-conf) 

      local INSTALLED() {
      already:Installed && [[ -d $usr/ext_baks ]] || mkdir $usr/ext_baks && return 0
      }

    [[ -n "$2" ]] || critical "stderr: 1 flag needed (max), pass \`-h/--help\` for more info.\n";

      case "$2" in
        --full) INSTALLED && tar -czvpf /data/data/com.termux/files/usr/ext_baks/shell_full.tar.gz /data/local/tmp/sh && ok "Success! full backup stored at $PREFIX/ext_baks/shell_full.tar.gz" && return 0 ;;
        --home) INSTALLED && tar -czvpf /data/data/com.termux/files/usr/ext_baks/shell_home.tar.gz /data/local/tmp/sh/home/ && ok "Success! backup of configuration files (home/) stored at $PREFIX/ext_baks/shell_home.tar.gz\n" && return 0 ;;

          --del) deleteTermuxBackups ;;

          -h|--help) info "Valid flags:\n--del {Deletes the backups (with confirmation)}\n--home {Partially backs up the full config (backs up only config files, seen in home/ (e.g: .bashrc)}\n--full {Fully backs up the entire shell config (/data/local/tmp/sh) recursively}\nBackup locations: $PREFIX/ext_baks"

        esac ;;

    --sudo-test) already:Installed && return 0 ;; # scripting purposes
    
    *) err "Invalid option: \"$1\"; run su -h to see valid flags.\n"; return 1 ;;

  esac
 fi
fi

        # end
    # end
# end
}

sudo() { ## emulates a temporary semi-root shell, based off of su();
    if [ $# -eq 0 ]; then
        echo "E: no operation specified"
        return 1
    fi

    if [ "$1" = "su" ]; then
        su
        return
    fi

    if [[ "$1" == "-f" ]]; then
    shift;
      rish -c 'export PATH=/data/local/tmp/sh/usr/bin:$PATH && \
             export LD_LIBRARY_PATH=/data/local/tmp/sh/usr/lib && \
             export HOME=/data/local/tmp/sh/home && \
             export PREFIX=/data/local/tmp/sh/usr && \
             export LS_COLORS="di=34:fi=92:ln=96:ex=31" && \
             export TERM="xterm-256color"
             export TERMINFO=/data/local/tmp/sh/usr/share/terminfo
             alias ls="ls --color=auto"
             exec eval "$*"' -- "$*"
             return
    fi

    if su --sudo-test; then
      rish -c 'export PATH=/data/local/tmp/sh/usr/bin:$PATH && \
             export LD_LIBRARY_PATH=/data/local/tmp/sh/usr/lib && \
             export HOME=/data/local/tmp/sh/home && \
             export PREFIX=/data/local/tmp/sh/usr && \
             export LS_COLORS="di=34:fi=92:ln=96:ex=31" && \
             export TERM="xterm-256color"
             export TERMINFO=/data/local/tmp/sh/usr/share/terminfo
             alias ls="ls --color=auto"
             exec eval "$*"' -- "$*"
    else; 
      critical "Uh-Oh! su is not installed and sudo couldnt run,\n"
      info "but to run sudo commands anyways, use the \'so\' command.\n"""
    return 1
    fi
}

so() {
  if [[ -z "$1" ]]; then
    rish
  else
    sudo -f "$*"
  fi
}

ng() { ## nvim/neovim glob
  nvim "$@"*
}

pa() {
  if [[ "$PKG" == "pacman" ]]; then

fzf_args=(
  --multi
  --preview 'pacman -Sii {1}'
  --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select, F11: maximize'
  --preview-label-pos='bottom'
  --preview-window 'down:65%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --color 'pointer:green,marker:green'
)

pkg_names=$(pacman -Slq | fzf "${fzf_args[@]}")

if [[ -n "$pkg_names" ]]; then
  # Convert newline-separated selections to space-separated for yay
  echo "$pkg_names" | tr '\n' ' ' | xargs pacman -S
fi
  elif [[ "$PKG" == "apt" ]]; then
fzf_args=(
  --multi
  --preview 'apt-cache show {1}'
  --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select, F11: maximize'
  --preview-label-pos='bottom'
  --preview-window 'down:65%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --color 'pointer:green,marker:green'
)

# Get all package names from apt
pkg_names=$(apt-cache pkgnames | fzf "${fzf_args[@]}")

if [[ -n "$pkg_names" ]]; then
  # Convert newline-separated selections to space-separated for apt
  echo "$pkg_names" | tr '\n' ' ' | xargs apt install
fi
fi
}


ff() { # find file, had to get claude to help me on the show line numbers logic :(
	local firstarg="$1"
	if [[ "$firstarg" == "-N" ]]
	then
		shift     
		local arg1="$1" 
		shift
		local allargs="$*" 
		local whence_path=$(whence -cp "$arg1") 
		local which_path=$(which "$arg1") 
		if [[ -f "$which_path" ]]
		then
			rg -N -- "$allargs" "$which_path"
		else
			echo "$which_path" | rg -N -- "$allargs"
		fi
	else
		local arg1="$firstarg" 
		shift
		local allargs="$*" 
		local whence_path=$(whence -cp "$arg1") 
		local which_path=$(which "$arg1") 
		if [[ -f "$which_path" ]]
		then
			rg --with-filename -n -- "$allargs" "$which_path"
		else
			echo "$which_path" | rg -n -- "$allargs"
		fi
	fi
}

dj() {
  ff "$@" | cl
}

jj() {
  local arg1="$1"
  shift
  local allargs="$*"

  if whence -cp "$arg1"; then
    nvim $(whence -cp "$arg1")
  else
    which "$arg1"
  fi
}

cfh() {
  cat "$1"|head -n "$2"
}

ccfh() {
  cat "$1" | head -n "$2" | tcs
}

wlw() {
  wc -l $(which "$@") # word.count.lines.which
}

wtf() {
  if [[ -z $1 ]]; then
    pf "stderr: NoOp, pass -h\n"
  elif [[ $1 == "is" ]]; then
    shift
    whatis "$@"
  elif [[ $1 == "-h" ]]; then
    pf "the only argument is \"is\" lol, i just wanted to waste your time.\n"
  else
    err "Invalid operation given. pass -h to show the help message\n"
  fi
}

mop() {
  sudo -f monkey -p $1 -c android.intent.category.LAUNCHER 1
}

inf() {
  am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$1
}

if [[ "$PKG" == "pacman" ]] then
  pacls() { 
    pacman -Qq | tr '\n' ' ' && pf "\n"
  }; paclsc() {
    ppg | tcs
  }; elif [[ "$PKG" == "apt" ]] then
  aptls() {
    apt list --installed | sed 's|/.*||'
  }; aptlsc() {
    aptls | tcs
  }; fi

hmal() { # "how many aliases (?)"
  local arg1="$1"
  local alias_count=$(fz -N al|wcl)
  if [[ -z "$arg1" ]]; then
    pf "you have $alias_count aliases in your \$(~/zsh.d/aliases.zsh)! \n"
  elif [[ "$arg1" == "-s" ]]; then
    pf "$alias_count"
  else
    pf "you have $alias_count aliases in your \$(~/zsh.d/aliases.zsh)! \n"
  fi
}

hmaf() { # "how many functions (?)"
  local arg1="$1"
  local func_count=$(fz -N fun ".*\(\).*\{"|wcl)
  if [[ -z "$arg1" ]]; then
    pf "you have $func_count functions in your \$(~/zsh.d/functions.zsh)! \n"
  elif [[ "$arg1" == "-s" ]]; then
    pf "$func_count"
  else
    pf "you have $func_count functions in your \$(~/zsh.d/functions.zsh)! \n"
  fi
}

hmap() { # "how many plugins (?)"
  # we'll use a different approach on this one compared to hmaf/hmal
  local arg1="$1"
  local plugin_count=$(("$(fz -N plug|wcl)"-2))
  if [[ -z "$arg1" ]]; then
    pf "you have $plugin_count plugins in your \$(~/zsh.d/plugins.zsh)! \n"
  elif [[ "$arg1" == "-s" ]]; then
    pf "$plugin_count"
  else
    pf "you have $plugin_count plugins in your \$(~/zsh.d/plugins.zsh)! \n"
  fi
}

fbin() { # find.binary
  find $bin -iname "$1"
}

cj() {
  qalc -c "$*"
}

diw() {
  diff $(which $@)
}

nd() {
  local file_opt="$1"

  if [[ -z "$file_opt" ]]; then
    err "NoOp, Usage: \n\n f/fu/fun/func/functions to edit functions. \n a/al/alias/aliases to edit aliases. \n at/au/auto/startup/autostart/ast to edit things that run on startup. \n e/ex/exp/exports to edit exports. \n h/ho/hook/hooks to edit hooks (e.g eval \$(zoxide init zsh)). \n k/key/ky/binds/keybinds/keybind to edit keybinds. \n pkg/pcheck/pgc/pack/package/pa to edit the script that checks whether your package manager is APT, or pacman. \n p/pl/plug/plugins/plugin to edit your zsh plugins. \n t/th/theme/themes to edit your zsh themes. \n un/una/unal/unaliases/unaliases to edit which aliases will be forgotten. \n uf/unf/unfun/unfunc/unfu/unfunctions to edit functions that will be forgotten. \n z/zsh/zs/zshrc to edit in what order the files will be sourced. \n\n"
    elif [[ "$file_opt" == "-h" ]]; then
      pf "Usage: \n\n f/fu/fun/func/functions to edit functions. \n al/alias/aliases to edit aliases. \n a/at/au/auto/startup/autostart/ast to edit things that run on startup. \n e/ex/exp/exports to edit exports. \n h/ho/hook/hooks to edit hooks (e.g eval \$(zoxide init zsh)). \n k/key/ky/binds/keybinds/keybind to edit keybinds. \n pkg/pcheck/pgc/pack/package/pa to edit the script that checks whether your package manager is APT, or pacman. \n p/pl/plug/plugins/plugin to edit your zsh plugins. \n t/th/theme/themes to edit your zsh themes. \n un/una/unal/unaliases/unaliases to edit which aliases will be forgotten. \n uf/unf/unfun/unfunc/unfu/unfunctions to edit functions that will be forgotten. \n z/zsh/zs/zshrc to edit in what order the files will be sourced. \n\n"
  fi

  case "$file_opt" in
  f|fu|fun|func|functions)
  $EDITOR ~/zsh.d/functions.zsh
  ;;
  al|alias|aliases)
  $EDITOR ~/zsh.d/aliases.zsh
  ;;
  a|at|au|auto|startup|autostart|ast)
  $EDITOR ~/zsh.d/autostart.zsh
  ;;
  e|ex|exp|exports)
  $EDITOR ~/zsh.d/exports.zsh
  ;;
  h|ho|hook|hooks)
  $EDITOR ~/zsh.d/hooks.zsh
  ;;
  k|key|ky|binds|keybinds|keybind)
  $EDITOR ~/zsh.d/keybinds.zsh
  ;;
  pkg|pcheck|pgc|pack|package|pa)
  $EDITOR ~/zsh.d/pkgchecks.zsh
  ;;
  p|pl|plug|plugins|plugin)
  $EDITOR ~/zsh.d/plugins.zsh
  ;;
  t|th|theme|themes)
  $EDITOR ~/zsh.d/themes.zsh
  ;;
  un|una|unal|unalias|unaliases)
  $EDITOR ~/zsh.d/unaliases.zsh
  ;;
  uf|unf|unfun|unfunc|unfu|unfunctions)
  $EDITOR ~/zsh.d/unfunctions.zsh
  ;;
  z|zsh|zs|zshrc)
  $EDITOR ~/.zshrc
  ;;
  *)
    err "Invalid OPT, \"$file_opt\". pass -h to show the help screen.\n"
  esac
}

lw() {
  local allargs="$@"
  ldd $(which "$allargs")
}

lzsh() {
  cat ~/zsh.d/*|wcl
}

hmpkg() {
  case "$pkg" in
    apt)
      apt list --installed|wcl
      ;;
    pacman)
      pacman -Qq|wcl
      ;;
  esac
}

fcn() {
  find "$1" -iname "*$2*"
}

cczsh() {
  ccont ~/.zshrc
}

fcount() {
	local show_dotfiles=false 
	local silent=false
	local target_dirs=()
	local argc="$#" 
	
	while [[ $# -gt 0 ]]
	do
		case "$1" in
			(-a | --all) 
				show_dotfiles=true 
				shift 
				;;
			(-s | --silent)
				silent=true
				shift
				;;
			(-as | -sa)
				show_dotfiles=true
				silent=true
				shift
				;;
			(-h | --help) 
				cat <<'EOF'

fcount() - Count files and directories

Usage: fcount [OPTIONS] [directory...]

Options:
    -a, --all       Include dotfiles in count
    -s, --silent    Silent mode: only output total count as integer
    -h, --help      Show this help message

Arguments:
    directory       One or more directories to count (default: current directory)

Examples:
    fcount                          Count in current directory
    fcount /tmp                     Count in /tmp
    fcount /tmp /data /sdcard       Count in multiple directories
    fcount -a /system /usr          Count with dotfiles in multiple dirs
    fcount -s /tmp                  Silent: just print the number
    fcount -sa /tmp                 Silent with dotfiles
    fcount -s -a /tmp               Silent with dotfiles (alt syntax)
    
EOF
				return 0 
				;;
			(-*) 
				err "stderr: Unknown option: $1\n"
				err "Use -h or --help for usage information.\n"
				return 1 
				;;
			(*) 
				target_dirs+=("$1")
				shift 
				;;
		esac
	done
	
	if [[ ${#target_dirs[@]} -eq 0 ]]; then
		target_dirs=(".")
	fi
	
	# SILENT MODE
	if [[ "$silent" == true ]]; then
		local total=0 failed=0 dir
		
		for dir in "${target_dirs[@]}"; do
			# All validation checks (silent)
			[[ -f "$dir" ]] && { ((failed++)); continue; }
			[[ ! -e "$dir" ]] && { ((failed++)); continue; }
			[[ ! -d "$dir" ]] && { ((failed++)); continue; }
			[[ ! -r "$dir" ]] && { ((failed++)); continue; }
			[[ ! -x "$dir" ]] && { ((failed++)); continue; }
			
			if [[ "$dir" == "/" ]]; then
				if [[ $(id -u) -ne 0 ]]; then
					if ! lsd / > /dev/null 2>&1; then
						((failed++))
						continue
					fi
				fi
			fi
			
			local count=0
			if [[ "$show_dotfiles" == true ]]; then
				shopt -s nullglob 2>/dev/null || setopt NULL_GLOB 2>/dev/null
				
				if [[ "$dir" == "." ]]; then
					local vis=$(for file in *; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l)
					local dot=$(for file in .*; do [[ -e "$file" && "$file" != "." && "$file" != ".." ]] && echo "$file"; done 2>/dev/null | wc -l)
					count=$((vis + dot))
				else
					local vis=$(for file in "$dir"/*; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l)
					local dot=$(for file in "$dir"/.*; do [[ -e "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]] && echo "$file"; done 2>/dev/null | wc -l)
					count=$((vis + dot))
				fi
			else
				if [[ "$dir" == "." ]]; then
					count=$(for file in *; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l)
				else
					count=$(for file in "$dir"/*; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l)
				fi
			fi
			
			((total += count))
		done
		
		# Output just the number
		printf "%d" "$total"
		
		# Return error if any failed
		[[ "$failed" -gt 0 ]] && return 1
		return 0
	fi
	
	# NORMAL MODE (unchanged)
	local total_files=0
	local total_visible=0
	local total_dotfiles=0
	local successful_dirs=0
	local failed_dirs=0
	
	local dir
	for dir in "${target_dirs[@]}"; do
		if [[ -f "$dir" ]]; then
			err "stderr: Path '$dir' is a file, not a directory.\n"
			((failed_dirs++))
			continue
		fi
		
		if [[ ! -e "$dir" ]]; then
			err "stderr: Path '$dir' does not exist.\n"
			((failed_dirs++))
			continue
		fi
		
		if [[ ! -d "$dir" ]]; then
			err "stderr: Path '$dir' exists but is not a directory.\n"
			((failed_dirs++))
			continue
		fi
		
		if [[ ! -r "$dir" ]]; then
			err "stderr: Permission denied: Cannot read directory '$dir'.\n"
			((failed_dirs++))
			continue
		fi
		
		if [[ "$dir" == "/" ]]; then
			local current_uid=$(id -u) 
			if [[ "$current_uid" -ne 0 ]]; then
				if ! lsd / > /dev/null 2>&1; then
					err "stderr: Permission denied: Cannot read root directory '/'.\n"
					err "Note: On Termux, you typically need elevated privileges (uid 0 or shell access via Shizuku).\n"
					((failed_dirs++))
					continue
				fi
			fi
		fi
		
		if [[ ! -x "$dir" ]]; then
			err "stderr: Permission denied: Cannot access directory '$dir' (no execute permission).\n"
			((failed_dirs++))
			continue
		fi
		
		local file_count
		local dotfile_count=0 
		local visible_count=0 
		
		if [[ "$show_dotfiles" == true ]]; then
			shopt -s nullglob 2> /dev/null || setopt NULL_GLOB 2> /dev/null
			
			if [[ "$dir" == "." ]]; then
				visible_count=$(for file in *; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l) 
				dotfile_count=$(for file in .*; do [[ -e "$file" && "$file" != "." && "$file" != ".." ]] && echo "$file"; done 2>/dev/null | wc -l) 
			else
				visible_count=$(for file in "$dir"/*; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l) 
				dotfile_count=$(for file in "$dir"/.*; do [[ -e "$file" && "$(basename "$file")" != "." && "$(basename "$file")" != ".." ]] && echo "$file"; done 2>/dev/null | wc -l) 
			fi
			
			file_count=$((visible_count + dotfile_count)) 
		else
			if [[ "$dir" == "." ]]; then
				file_count=$(for file in *; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l) 
			else
				file_count=$(for file in "$dir"/*; do [[ -e "$file" ]] && echo "$file"; done 2>/dev/null | wc -l) 
			fi
			visible_count=$file_count 
		fi
		
		local display_dir="$dir" 
		if [[ "$dir" == "." ]]; then
			display_dir="current directory" 
		fi
		
		if [[ ${#target_dirs[@]} -gt 1 ]]; then
			pf "\n[$display_dir]\n"
		fi
		
		if [[ "$file_count" -eq 0 ]]; then
			if [[ "$show_dotfiles" == true ]]; then
				pf "  Empty (including dotfiles)\n"
			else
				pf "  No visible files (use -a to check dotfiles)\n"
			fi
		else
			if [[ "$show_dotfiles" == true ]]; then
				pf "  Files/Dirs: {{     $file_count     }}\n"
				if [[ "$dotfile_count" -gt 0 ]]; then
					pf "  Dotfile count: $dotfile_count\n"
				fi
			else
				pf "  Files/Dirs: {{     $file_count     }}\n"
			fi
		fi
		
		((total_files += file_count))
		((total_visible += visible_count))
		((total_dotfiles += dotfile_count))
		((successful_dirs++))
	done
	
	if [[ ${#target_dirs[@]} -gt 1 ]]; then
		pf "\n"
		pf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
		pf "SUMMARY:\n"
		pf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
		pf "Directories processed: $successful_dirs/${#target_dirs[@]}\n"
		
		if [[ "$failed_dirs" -gt 0 ]]; then
			pf "Failed: $failed_dirs\n"
		fi
		
		pf "Total files/directories: {{     $total_files     }}\n"
		
		if [[ "$show_dotfiles" == true && "$total_dotfiles" -gt 0 ]]; then
			pf "  Visible: $total_visible\n"
			pf "  Dotfiles: $total_dotfiles\n"
		fi
		pf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
	fi
	
	if [[ "$successful_dirs" -eq 0 ]]; then
		return 1
	fi
	
	return 0
}

fflib() {
  local findLibPaths() {
    local bin="$1"
    local resolved
    resolved=$(which "$bin" 2>/dev/null || realpath "$bin" 2>/dev/null)
    [[ -f "$resolved" ]] || return 1
    ldd "$resolved" 2>/dev/null | awk '/=>/ {print $3}' | grep -v '^$' || true
  }

  # Check for -s flag at first or last position
  local silent=0
  if [[ "$1" == "-s" ]] || [[ "${@: -1}" == "-s" ]]; then
    silent=1
    # Remove -s from args
    set -- "${@:#-s}"  # ZSH: remove all -s occurrences
  fi

  (($# == 0)) && { 
    ((silent)) || printf "stderr: argc !>=1\n" >&2
    return 1
  }

  # SILENT MODE
  if ((silent)); then
    local all_libs=() missing_count=0 bin
    for bin in "$@"; do
      if ! findLibPaths "$bin" >/dev/null 2>&1; then
        ((missing_count++))
        continue
      fi
      # Collect all libs into array
      while IFS= read -r lib; do
        all_libs+=("$lib")
      done < <(findLibPaths "$bin")
    done

    # Print all libs space-separated, deduplicated
    ((${#all_libs[@]} > 0)) && {
      printf "%s" "${all_libs[1]}"
      local lib
      for lib in "${all_libs[@]:1}"; do
        printf " %s" "$lib"
      done
    }

    # Return error if any missing
    ((missing_count > 0)) && return 1
    return 0
  fi

  # NORMAL MODE (unchanged)
  local bin missing=() first=1
  for bin in "$@"; do
    if ! findLibPaths "$bin" >/dev/null 2>&1; then
      missing+=("$bin")
      continue
    fi

    # Print separator before every block except the very first one
    ((first)) && first=0 || printf "\n"

    printf "%s:\n" "$bin"
    findLibPaths "$bin" | sort -u
  done

  # Final four newlines after the last valid block (if any were printed)
  ((first)) || printf "\n\n\n"

  # Report missing ones
  ((${#missing[@]} > 0)) && {
    printf "stderr: the following files were not found:\n" >&2
    printf "  %s\n" "${missing[@]}" >&2
  }
}

alt() {

  if [[ $PKG == "apt" ]]; then
    # check if nala is installed
    if ! command -v nala >/dev/null 2>&1; then
        critical "Uh-Oh! nala not found, can be installed by running:\n apt install nala\n"
        return 1
    fi

    if [ -z "$1" ]; then
        nala -h
        return 0
    fi

    local cmd="$1"
    shift

    case "$cmd" in
    install | in | add | i)
        command nala install "$@"
        ;;
    search | look | sr | find)
        command nala search "$@"
        ;;
    update | upd)
        command nala update "$@"
        ;;
    upgrade | upg)
        command nala upgrade "$@"
        ;;
    u | up)
      command nala update && command nala upgrade "$@"
      ;;
    show | info | inf | see)
        command nala show "$@"
        ;;
    remove | del | delete | rm | rem | uninstall | r)
        command nala remove "$@"
        ;;
    *)
        command nala "$cmd" "$@"
        ;;
    esac
  else
    critical "Uh-Oh! this wrapper script was made for apt, and it seems you are using something different.\n"
    return 1
  fi
  }
