# some functions and aliases rely on Shizuku (https://github.com/RikkaApps/Shizuku) for priveleged actions, for the best experience i personally reccomend you install it

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


exap() { # simple apk extraction function
  local pacname pacpath target
  pacname="$1"
  target="$2"

  pacpath=$(soap "$pacname")
  pacpath=${pacpath:8}

  if [[ -z "$target" ]]; then
    cp "$pacpath" "./$pacname.apk" && \
    ok "Success! ${CYAN}$pacname${GREEN} copied to ${CYAN}./$pacname.apk${NC}\n"
  else
    cp "$pacpath" "$target.apk" && \
    ok "Success! ${CYAN}$pacname${GREEN} copied to ${CYAN}$target.apk$NC\n"
  fi
}





apm() { # simple android package manager
  if [[ $# -eq 0 ]]; then
    info "Listing all installed apps..\n"
    output=$(rish -c "pm list packages")
  elif [[ "$1" == "-h" || "$1" == "--h" ]]; then
    printf "

    ${BLUE}APM: Simple android CLI app manager${NC}

    ${WHITE}Available commands:${NC}

    ${BLUE}open${NC}: Opens selected app
    ${BLUE}info${NC}: Opens the settings page of selected app
    ${BLUE}kill${NC}: Force stops selected app
    ${BLUE}extract${NC}: Copies selected app's APK file to your current directory
    ${BLUE}pm uninstall${NC}: Permanently deletes selected app from device
    \n"
    return 0
  else
    info "Searching for: $*\n"
    output=""
    for term in "$@"; do
      part=$(rish -c "pm list packages | grep -i \"$term\"")
      output="$output"$'\n'"$part"
    done
  fi

  output=$(echo "$output" | grep -v '^$' | sort -u)

  if [[ -z "$output" ]]; then
    err "No packages matched the search terms.\n"
    return 1
  fi

  pkgs=$(echo "$output" | sed 's/^package://')

  i=1
  echo "$pkgs" | while IFS= read -r line; do
    echo -n "$i) $line\n"
    i=$((i + 1))
  done

  info "Input number of package (1-$((i - 1))): "
  read -r num

  if ! echo "$num" | grep -qE '^[0-9]+$'; then
    err "Invalid number given (out of bounds)\n"
    return 1
  fi
  if [[ "$num" -lt 1 ]] || [[ "$num" -ge "$i" ]]; then
    err "Invalid number given (out of bounds)\n"
    return 1
  fi

  selected=$(echo "$pkgs" | sed -n "${num}p")

  w_info "Selected package: $selected\n"

  info "\napm --h for a list of commands.\nExecute command: "
  read -r cmd

  case "$cmd" in
    
    mop|open|monkey-open)
    cmd="monkey -p $selected -c android.intent.category.LAUNCHER 1"
    w_info "Executed command: rish -c \"$cmd\"\n"
    rish -c "$cmd"
    ;;

    kill|stop|force-stop)
    cmd="am force-stop $selected"
    w_info "Executed command: rish -c \"$cmd\"\n"
    rish -c "$cmd"
    ;;

    exap|extract|extract-apk|apk)
    c_info "Extracting apk of: $selected\n"

    apkpath=$(rish -c "pm path $selected" | sed 's/^package://' | head -n1)
    apkpath=${apkpath#file://}

    if [[ -z "$apkpath" ]]; then
        err "Unable to find the APK Path of: $selected.apk\n"
        return 1
    fi

    cp "$apkpath" "./$selected.apk" 2>/dev/null

    if [ $? -eq 0 ]; then
        ok "APK extraction success! path: [./$selected.apk]\n"
    else
        err "APK extraction failed.\n"
        info "Debugging info: path of failed APK was \'$apkpath\' \n"
        ls -l "$apkpath" 2>/dev/null
        return 1
    fi
    return 0
    ;;

    info|app-info|inf|in)
    info "Opening settings page of: $selected\n"
    am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$selected
    ;;

    *)
      info "Executing command: $cmd $selected\n"
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

fz() { ## finds patterns in your ZSH config ( ~/zsh.d/ )
  local arg1="$1"
  if [[ -z "$arg1" ]]; then
    err "No operation given, pass -h for help.\n\n"
  elif [[ "$arg1" == "-h" ]]; then
    pf "
    Find patterns in ~/zsh.d files
    Usage:

    ${BLUE}fz func \"example\"${NC} find a pattern in functions
    ${BLUE}fz al \"example\"${NC} find a pattern in aliases
    ${BLUE}fz ast \"example\"${NC} find a pattern in autostart
    ${BLUE}fz exp \"example\"${NC} find a pattern in exports
    ${BLUE}fz ho \"example\"${NC} find a pattern in hooks
    ${BLUE}fz key \"example\"${NC} find a pattern in keybinds
    ${BLUE}fz pkg \"example\"${NC} find a pattern in pkgchecks
    ${BLUE}fz pl \"example\"${NC} find a pattern in plugins
    ${BLUE}fz th \"example\"${NC} find a pattern in themes
    ${BLUE}fz una \"example\"${NC} find a pattern in unaliases
    ${BLUE}fz unf \"example\"${NC} find a pattern in unfunctions
    ${BLUE}fz zsh \"example\"${NC} find a pattern in zshrc
    ${BLUE}fz all \"example\"${NC} find a pattern in all zsh configs


    ${BLUE}fz -N file example ${WHITE}to find patterns without line numbers, or fz -N file to quickly view the file contents as if ${CYAN}cat ${WHITE}was used.${NC}
    \n"
  elif [[ "$arg1" == "-N" ]]; ## if you use {fz -N somefile somepattern} you'll need to put the pattern in quotes when using -N, as it doesnt use shift/all args and instead uses a multiple argument approach (flag (-N), file, pattern) unlike if you dont use -N which uses an infinite argument approach (file, the rest of this here whether you use spaces or other stuff is treated as a single string.) 
  then
    local file="$2"
    local regex="$3"
    
    case "$file" in
      f|fu|fun|func|function|functions)
        ff -N $ZDIR/functions.zsh "$regex"
      ;;
      al|alias|aliases)
        ff -N $ZDIR/aliases.zsh "$regex"
      ;;
      a|at|au|auto|startup|autostart|ast)
        ff -N $ZDIR/autostart.zsh "$regex"
      ;;
      e|ex|exp|exports)
        ff -N $ZDIR/exports.zsh "$regex"
      ;;
      h|ho|hook|hooks)
        ff -N $ZDIR/hooks.zsh "$regex"
      ;;
      k|key|ky|binds|keybinds|keybind)
        ff -N $ZDIR/keybinds.zsh "$regex"
      ;;
      pkg|pcheck|pgc|pack|package|pa)
        ff -N $ZDIR/pkgchecks.zsh "$regex"
      ;;
      p|pl|plug|plugins|plugin)
        ff -N $ZDIR/plugins.zsh "$regex"
      ;;
      t|th|theme|themes)
        ff -N $ZDIR/themes.zsh "$regex"
      ;;
      un|una|unal|unalias|unaliases)
        ff -N $ZDIR/unaliases.zsh "$regex"
      ;;
      unf|unfunc|unfunctions)
        ff -N $ZDIR/unfunctions.zsh "$regex"
     ;;
      z|zsh|zs|zshrc)
        ff -N ~/.zshrc "$regex"
      ;;
     all)
       local every_file;
       for every_file in $ZDIR/*; do
         if [[ -z "$regex" ]]; then
           ff -N "$every_file"
         else
           rg --with-filename -N -- "$regex" "$every_file"
         fi
       done
       ;;
     *)
       err "Invalid category \"$file\", pass -h to show help screen.\n"
       return 1
       ;;
    esac
  else
    shift
    local argv="$*"
    
    case "$arg1" in
      f|fu|fun|func|functions)
        ff $ZDIR/functions.zsh "$argv"
      ;;
      al|alias|aliases)
        ff $ZDIR/aliases.zsh "$argv"
      ;;
      a|at|au|auto|startup|autostart|ast)
        ff $ZDIR/autostart.zsh "$argv"
      ;;
      e|ex|exp|exports)
        ff $ZDIR/exports.zsh "$argv"
      ;;
      h|ho|hook|hooks)
        ff $ZDIR/hooks.zsh "$argv"
      ;;
      k|key|ky|binds|keybinds|keybind)
        ff $ZDIR/keybinds.zsh "$argv"
      ;;
      pkg|pcheck|pgc|pack|package|pa)
        ff $ZDIR/pkgchecks.zsh "$argv"
      ;;
      p|pl|plug|plugins|plugin)
        ff $ZDIR/plugins.zsh "$argv"
      ;;
      t|th|theme|themes)
        ff $ZDIR/themes.zsh "$argv"
      ;;
      un|una|unal|unalias|unaliases)
        ff $ZDIR/unaliases.zsh "$argv"
      ;;
      uf|unf|unfun|unfunc|unfu|unfunctions)
        ff $ZDIR/unfunctions.zsh "$argv"
     ;;
      z|zsh|zs|zshrc)
        ff ~/.zshrc "$argv"
      ;;
     all)
       local every_file;
       for every_file in $ZDIR/*; do
         if [[ -z "$argv" ]]; then
           ff "$every_file"
         else
           rg --with-filename -n -- "$argv" "$every_file"
         fi
       done
       ;;
     *)
       err "Invalid category \"$arg1\", pass -h to show the help screen.\n"
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
    critical "Even though this function is made to be used specifically with my dotfiles, which has rish preinstalled, rish doesnt exist.\n${BLUE}rish can be manually installed with shizuku, or by copying it from my dotfiles.${NC}\n"
    return 255
  fi
  
  local shizuku.IsRunning() {
    if ! {rish -c "return 0"} then
      err "rish failed to run. Shizuku may not be installed, configured properly, or running.\n"
      return 255
    else
      return 0;
    fi
  }

local ldd.IsInstalled() {
  if [[ -f $PREFIX/bin/ldd ]]; then
      return 0
    else
      err "The ldd command could not be found.\n"
      info "Installing ldd..\n"

      case "$PKG" in
        apt) apt install ldd -y ;;
        pacman) pacman -S ldd --noconfirm ;;
        *) pkg install ldd -y ;;
      esac

  if [[ -f $PREFIX/bin/ldd ]]; then
      ok "ldd Sucessfully installed!\n"
      case "$PKG" in
        apt) apt install binutils -y ;;
        pacman) pacman -S binutils --noconfirm ;;
        *) pkg install binutils -y ;;
      esac
    else
      critical "ldd could not be installed.\n"
      return 1
    fi
  fi
}

local vim+nano.installed() {
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
      info "Changing termux fs permissions to $1...\n"
    chmod "$1" /data/data/com.termux /data/data/com.termux/files/ $PREFIX $PREFIX/etc $PREFIX/etc/bash.bashrc;
    chmod "$1" -R $PREFIX/bin $PREFIX/lib $PREFIX/tmp
    fi
  }

  local changeShellRoot() {
    info "Changing Shell's fs permissions to $1...\n"
    shizuku.IsRunning && rish -c "chmod $1 -R /data/local/tmp/sh"
  }

  local bootStrapDirectories() {
    info "starting Init /data/local/tmp/sh (Shell's fs)..\n"

    shizuku.IsRunning && rish -c "cd /data/local/tmp/ && \
    mkdir ./sh 2>/dev/null
    
    echo '\033[1m\033[38;2;125;167;205mCreating common directories'

    mkdir -p sh/home/ sh/usr/bin/  sh/usr/lib/ sh/etc/  sh/usr/share/terminfo/ sh/usr/libexec/ sh/tmp"
  }

  local findLibPaths() {
   ldd.IsInstalled && fflib -s "$1" 2>/dev/null
  }

  local findBashLibraries() {
  info "Finding Bash needed Linking Libraries\n"
  ldd.IsInstalled && \
    realpath $(findLibPaths $PREFIX/bin/bash)|tr '\n ' ' ' > $PREFIX/tmp/bashLibraries # we cant use links without rish
    vim+nano.installed && \
    echo " /data/data/com.termux/files/usr/lib/libsodium.so" >> $PREFIX/tmp/bashLibraries
  }

local boot.InstallTree() {
  if [[ -f $PREFIX/bin/tree ]]; then
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
      chmod 755 $PREFIX/bin/
      rish -c "cp /data/data/com.termux/files/usr/bin/tree /data/local/tmp/sh/usr/bin"
    else
      err "tree could not be installed, skipping\n"
      return 1
    fi
  fi

  if [[ ! -f /data/local/tmp/sh/usr/bin/tree ]]; then
    err "Unable to copy tree"
    info "Retrying...\n"
    openTermux
    rish -c "cp /data/data/com.termux/files/usr/bin/tree /data/local/tmp/sh/usr/bin" && closeTermux
    if [[ -f /data/local/tmp/sh/usr/bin/tree ]]; then
      return 0
    fi
  fi
}

  local copyBash() {
    info "Copying bash to Shell's usr/bin\n"
    shizuku.IsRunning && rish -c "cp /data/data/com.termux/files/usr/bin/bash /data/local/tmp/sh/usr/bin/bash"
  }

  local copyBashLibraries() {
    info "Copying bash's needed Linking libraries to Shell's usr/lib\n"
    shizuku.IsRunning && rish -c "cp $(cat /data/data/com.termux/files/usr/tmp/bashLibraries) /data/local/tmp/sh/usr/lib"
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

local initEnviroment() {
  info "Initializing & prepping the Shell filesystem\n"
  shizuku.IsRunning && rish -c "chmod 755 /data/local/tmp && \
    mkdir /data/local/tmp/sh 2>/dev/null && \
    chmod 777 -R /data/local/tmp/sh"
}

  local linkBashLibraries() {
    info "linking Bash required Libaries's realPath, to their needed equivalent\n"
      shizuku.IsRunning && rish -c " cd /data/local/tmp/sh/usr/lib && \
        cp libreadline.so.* libreadline.so.8
        cp libncursesw.so.* libncursesw.so.6
    "
}

  local removeShell.RootFS() {
    shizuku.IsRunning && \

      if [[ ! -d /data/local/tmp/sh ]] then
        err "Shell enviroment is not installed, could not uninstall.\n"
        return 1;
      else
        w_info "Wiping shell's rootfs...\n"
        {rish -c "rm -rf /data/local/tmp/sh" && return 0} || return 1;
      fi

  }

      local config::LsColors() {
        info "Configuring ls colors..\n"
        sleep 0.2

        [[ -d /data/local/tmp/sh/home ]] || return 1

        rish -c "grep -qF \"alias ls='ls --color=auto'\" /data/local/tmp/sh/home/.bashrc 2>/dev/null || echo alias ls=\"'ls --color=auto'\" >> /data/local/tmp/sh/home/.bashrc" && \
        ok "Success!\n" && return 0 || return 1
      }

  local boot.InstallFiles() {

    shizuku.IsRunning && \

    initEnviroment && \
    bootStrapDirectories && \
    changeTermuxRoot 755 && \
    changeShellRoot 755 && \
    ldd.IsInstalled && \
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

      w_info "\nStarting Installation."
    for sleep in {1..6}; do
      sleep 0.2
      printf "."
    done; printf "\n\n"

  {
    shizuku.IsRunning && initEnviroment && \
    changeTermuxRoot 755 && \

    bootStrapDirectories && \
    changeShellRoot 755 && \
    ldd.IsInstalled && \
    findBashLibraries && \
    copyBash && \
    copyBashLibraries && \
    linkBashLibraries && \
    config::LsColors && \
    boot.setupTermInfo && \
    boot.InstallTexEd && \
    boot.InstallTree

      } && {
          great "Success!"
          ok " The Shell enviroment was sucessfully installed."
          ok "\nyou may now run ${BRIGHT_CYAN}\"su\"${GREEN} or ${BRIGHT_CYAN}\"so\"${GREEN} to login.\n\n"
        } && return 0 || return 1
}

  local already:Installed() {

    shizuku.IsRunning || exit 1

    [[ -d /data/local/tmp/sh ]] || return 1
    dlt=/data/local/tmp/sh
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
      $dlt/usr/lib/ld-android.so
      $dlt/usr/lib/libandroid-support.so
      $dlt/usr/lib/libc.so
      $dlt/usr/lib/libdl.so
      $dlt/usr/lib/libiconv.so
      $dlt/usr/lib/libncursesw.so.6
      $dlt/usr/lib/libncursesw.so.6.5
      $dlt/usr/lib/libreadline.so.8
      $dlt/usr/lib/libreadline.so.8.3
      $dlt/usr/lib/libsodium.so
      $dlt/usr/bin/bash
      $dlt/usr/bin/nano
      $dlt/usr/bin/vim
      $dlt/usr/bin/vi
      $dlt/usr/bin/tree
      )
    
      dir=("${shellDirs[@]}")
      file=("${shellFiles[@]}")

      for dirs in "${dir[@]}"; do
        if [[ ! -d "$dirs" ]]; then
          return 1
        fi
      done

        for files in "${file[@]}"; do
          if [[ ! -f "$files" ]]; then
            return 1
          fi
        done
        return 0
  }

  local boot.Init() {
    boot.Install && \
    runEnviroment && \
    return 0;
  }

  local revertChanges() {
    {info "Changing termux's LocationPermissions to 750 (*rwxr-x---)\n"
    closeTermux
    closeTermuxBackups
    deleteTermuxBackups
    info "Removing usr/tmp/bashLibraries\n"
    rm $PREFIX/tmp/bashLibraries 2>/dev/null}
    return 0;
  }

  local changeTermuxLibexecPerms() {
    chmod "$1" -R $libexec
  }

  local openTermux() {
    info "Opening termux's fs..\n"
    changeTermuxRoot 755
    changeTermuxSharePerms 755
    changeTermuxTexEdperms 755
    changeTermuxLibexecPerms 755
  }

  local closeTermux() {
    info "Closing termux's fs..\n"
    changeTermuxRoot 750
    changeTermuxSharePerms 750
    changeTermuxTexEdperms 750
    changeTermuxLibexecPerms 750
  }

  local openTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    info "Opening termux's external backup location..\n"
    changeTermuxRoot 755
    chmod 755 -R $PREFIX/ext_baks
  }

  local closeTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    info "Closing termux's external backup location..\n"
    changeTermuxRoot 750
    chmod 750 -R $PREFIX/ext_baks
  }

  local deleteTermuxBackups() {
    [[ -d $PREFIX/ext_baks ]] || return 0

    warn "Are you sure? this will delete the backups you made of the shell config.\n(if you did not create any then {do not worry, this wont delete anything.})\n[y/N] "
    local rrr;read -r rrr; case "$rrr" in
    y|Y) rm -rf $PREFIX/ext_baks && ok "Successfully deleted shell backups!\n" ;;
    n|N|*) err "\nAbort.\n" ;; esac
  }

  local openShell() {

  [[ -d /data/local/tmp/sh ]] && \
    info "Opening shell's fs permissions..\n"
    changeShellRoot 755 1>/dev/null && \
    ok "Success!\n"
  }

  local closeShell() {
    info "Closing shell's fs permissions..\n"
    changeShellRoot 750 1>/dev/null && \
    ok "Success!\n"
  }

  local boot.Init+Validation() {

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
      $dlt/usr/lib/ld-android.so
      $dlt/usr/lib/libandroid-support.so
      $dlt/usr/lib/libc.so
      $dlt/usr/lib/libdl.so
      $dlt/usr/lib/libiconv.so
      $dlt/usr/lib/libncursesw.so.6
      $dlt/usr/lib/libncursesw.so.6.5
      $dlt/usr/lib/libreadline.so.8
      $dlt/usr/lib/libreadline.so.8.3
      $dlt/usr/lib/libsodium.so
      $dlt/usr/bin/bash
      $dlt/usr/bin/nano
      $dlt/usr/bin/vim
      $dlt/usr/bin/vi
      $dlt/usr/bin/tree
      )
    
      dir=("${shellDirs[@]}")
      file=("${shellFiles[@]}")

      local missing_dir=false
      for dirs in "${dir[@]}"; do
        if [[ ! -d "$dirs" ]]; then
          missing_dir=true
          break
        fi
      done

      if $missing_dir; then
        err "Uh-Oh! some directories are missing!\n"
        printf "Attempting to create required directories..\n"
        sleep 0.5
        bootStrapDirectories
        boot.setupTermInfo

      for dirs in "${dir[@]}"; do
          if [[ ! -d "$dirs" ]]; then
            critical "Uh-Oh! the needed directories could not be created, the only explanation could be that shizuku failed. If shizuku works and this still failed, then you're on your own.\n\n"
            return 1
          fi
        done
      ok "Directories successfully created!\n"
      fi

      local missing_file=false
      for files in "${file[@]}"; do
        if [[ ! -f "$files" ]]; then
          missing_file=true
          break
        fi
      done

      if $missing_file; then
        err "Uh-Oh! The directories exist but some files are missing.\n"
        shizuku.IsRunning && info "Attempting to create required files..\n"
        sleep 0.5
        boot.InstallFiles

        for files in "${file[@]}"; do
          if [[ ! -f "$files" ]]; then
            critical "Uh-Oh! The needed files could not be created, the only explanation could be that shizuku failed. If shizuku works and this still failed, then you're on your own.\n\n"
            return 74
          fi
        done
        ok "Success! Attempting to log into [shell(2000)], you wont see this message again unless the right conditions are met.\n"
        sleep 0.2
        printf "\n\n"
      fi

      ct=$HOME/comTermux/
      ctf=$ct/files/
      etc=$PREFIX/etc/
      bash=$etc/bash.bashrc
      permsShouldBeOctal=3020

      permsAre=$(($(fperm $ct)+$(fperm $ctf)+$(fperm $etc)+$(fperm $bash)))

      if (($permsAre == $permsShouldBeOctal)); then
        runEnviroment
        return 0
      else
        fix::bash.bashrc\\ENOPERM && \
        runEnviroment
        return 0
      fi
  }

local fix::bash.bashrc\\ENOPERM() {
  ct=/data/data/com.termux
  info "\nFixing perm errors on login..\n"
  {chmod 755 $ct $ct/files/ $ct/files/usr/ $ct/files/usr/etc $ct/files/usr/etc/bash.bashrc} && return 0;
}

  
  local changeTermuxTexEdperms() {
    info "Changing termux's usr/bin && libexec permissions to $1...\n"
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
    info "Changing termux's usr/share && terminfo permissions to $1...\n"
      pref=/data/data/com.termux/files/usr/share/
      chmod "$1" $pref
      chmod "$1" -R $pref/terminfo
    }

  local boot.InstallTexEd() {

    vim+nano.installed &&  {

    info "Setting up text editors (vim & nano)..\n"
    sleep 0.2

    changeTermuxRoot 755 && \
    changeShellRoot 755 && \

    info "Changing some termux path perms..\n"
    changeTermuxTexEdperms 755 && \
    info "copying binaries to shell's bin/\n\n"

    {shizuku.IsRunning && [[ -d /data/local/tmp/sh/usr/bin/ ]] && rish -c "
    cp /data/data/com.termux/files/usr/bin/nano /data/local/tmp/sh/usr/bin/nano && \
      cp /data/data/com.termux/files/usr/libexec/vim/vim /data/local/tmp/sh/usr/bin/vim && \
      cp /data/local/tmp/sh/usr/bin/vim /data/local/tmp/sh/usr/bin/vi && \
      touch /data/local/tmp/sh/home/.vimrc" && return 0;}} || \
      critical "Text editors could not be configured"; return 1;
  }

  local boot.setupTermInfo() {
    info "Setting up terminfo..\n"
    sleep 0.2

      changeTermuxRoot 755 && \
      changeTermuxSharePerms 755 && \

  shizuku.IsRunning && \

  [[ -d /data/local/tmp/sh/usr/share/terminfo/ ]] && \

  rish -c "cp -r /data/data/com.termux/files/usr/share/terminfo/* /data/local/tmp/sh/usr/share/terminfo/" && return 0 || return 1;
  }

# logic end

if [[ -z "$1" ]]; then
    shizuku.IsRunning && \
  if already:Installed; then
    boot.Init+Validation
    return
  else
    err "seems like the su() enviroment isn't installed, or some files were missing.\nfix? [y/N]: "
    local reply
    read -r reply
    case "$reply" in
      y | Y)
        boot.Install && boot.Init+Validation
        ;;
      *)
        w_info "Abort.\n"
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
      shizuku.IsRunning && info "{Shell.RootFS uninstallation}: Are you sure? if you stored sensitive data, or unbacked up configs here you will ${RED}permanently${NC} lose them. [y/N]\n"
      local Choice; read -r Choice; case "$Choice" in;
      y|Y|yes|Yes|yes) printf "Wiping Shell's fs...\n"; removeShell.RootFS && ok "Success!\n" && return 0 ;;
      n|N|No|no|*) printf "Abort.\n"; return 1 ;; esac
    fi
    ;;

  -uf|-fu|-uF|-Fu|-FU|-UF) 
      printf "Wiping Shell's fs...\n"; removeShell.RootFS && ok "Success!\n"; return 0 ;;

    -i|--install)
      if already:Installed; then
        w_info "Shell enviroment is already installed, run su -r/--reinstall if you need to reinstall it.\n"
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

      printf "

${BLUE}pseudo SuperUser via shizuku on termux${NC}

      ${WHITE}Options:${NC}

      ${BLUE}-vrf${NC} [Verifies that the shell env is installed]
      ${BLUE}-i${NC} [Installs the config]
      ${BLUE}-r${NC} [Reinstalls the config]
      ${BLUE}-ref${NC} [Forcefully reinstalls the config]

      ${BLUE}-u${NC} [Wipes the shell config]
      ${BLUE}-uf${NC} [Forcefully wipes the shell config]

      ${BLUE}-rev${NC} [Reverts all changes made to termux's files]
      ${BLUE}--nuke${NC} [Fully reverts all FS changes made by ${CYAN}su${NC}]

      ${BLUE}--backup-conf${NC} [${WHITE}su --backup-conf -h for more info.${NC}]

      ${BLUE}-fbe${NC} [Fix the bash.bashrc permission error on su login]

      ${BLUE}-o${NC} [Opens termux's fs]
      ${BLUE}-ct${NC} [Closes termux's fs]

      ${BLUE}-os${NC} [Opens shell's fs permissions]
      ${BLUE}-cs${NC} [Closes shell's fs permissions]

      ${BLUE}-c${NC} [Calls ${CYAN}sudo${NC} (su -c command)]

      ${CYAN}\"so\"${NC} command: run su -soh for more info.

      ${BLUE}-h/--help${WHITE} [Show this help screen]${NC}
\n"

return 0
;;

    -fix|-bashrc|-fixbashrc|-fixpermerror|-fbe|fixbasherr)
      warn "\nThis will make $etc/bash.bashrc world readable, to fix the permission error on su startup\n{--help for more info}."; printf "\n[y/N] ";
      local input;
      read -r input
      case "$input" in
        y|Y|yes|Yes) fix::bash.bashrc\\ENOPERM && ok "Success!\n"; return 0 ;;
        n|N|no|No) w_info "Abort.\n"; return 1 ;;
        *) err "Invalid option [y/n]\nAbort.\n"; return 1;;
      esac ;;

    -c|--command|-cc) shift; sudo "$*" ;;

    --nuke|--wipe|--redo-all)
      local sure
      warn "\nAre you sure? this will erase /data/local/tmp/sh and revert all changes made by su [y/N]: "
      read -r sure
      case "$sure" in
        y|Y)
      {removeShell.RootFS ; revertChanges} && w_info "\nFull wipe success!, all changes that were made by su were undone.\n\n"
        return 0
        ;;
       n|N)
        w_info "\nAbort.\n"
        ;;
        *)
        w_info "\nAbort.\n"
        ;;
      esac
      ;;

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

    [[ -n "$2" ]] || err "stderr: 1 flag needed (max), pass \`-h/--help\` for more info.\n";

      case "$2" in
        --full) INSTALLED && tar -czvpf /data/data/com.termux/files/usr/ext_baks/shell_full.tar.gz /data/local/tmp/sh && ok "Success! full backup stored at $PREFIX/ext_baks/shell_full.tar.gz" && return 0 ;;
        --home) INSTALLED && tar -czvpf /data/data/com.termux/files/usr/ext_baks/shell_home.tar.gz /data/local/tmp/sh/home/ && ok "Success! backup of configuration files (home/) stored at $PREFIX/ext_baks/shell_home.tar.gz\n" && return 0 ;;

          --del) deleteTermuxBackups ;;

          -h|--help)
            pf "
            ${WHITE}Shell enviroment backup manager${NC}

            Usage:
            ${BLUE}--del${NC} [Delete backups with confirmation]
            ${BLUE}--home${NC} [Backup shell home]
            ${BLUE}--full${NC} [Backup the entire shell FS]
            ${WHITE}Backups location: $PREFIX/ext_baks${NC}
            ${GRAY}Knowledge on how to use tar is required.${NC}\n"

        esac ;;

    --sudo-test) already:Installed && return 0 ;; # scripting purposes
    
    --quick-run-no-validation) runEnviroment ;;

    --verify|-vrf)
      if already:Installed; then
        ok "the su() env is installed!\n"
        return 0
      else
        err "the su() env is not installed, run ${CYAN}su -i${RED} to install.\n"
        return 1
      fi
      ;;

    --verify-scriptable)
      if already:Installed; then
        return 0
      else
        return 1
      fi
      ;;

      -soh)

printf "
      ${CYAN}so${NC}:

        ${WHITE}a wrapper between su and sudo that speeds up command execution.${NC}

        Usage:

        run ${CYAN}\"so\"${NC} with no arguments & fsu runs, putting you in su quickly
        run ${CYAN}\"so\"${NC} with arguments and sudo runs,
        (examples: ${BLUE}so ls${NC}, ${BLUE}so id${NC}, ${BLUE}so vim /some/config/file${NC})


        the reason as to why the ${CYAN}\"so\"${NC} command runs faster than su/sudo is because it skips verification entirely and just executes, so in turn, ${WHITE}make sure that su() is installed properly${NC} [${CYAN}su -vrf${NC}].

        ${CYAN}so ${WHITE}is reccomended to use instead of ${CYAN}su${NC} & ${CYAN}sudo ${WHITE}if the su enviroment is installed.${NC}
        \n"

        ;;

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
      info "but to run sudo commands anyways, use the ${CYAN}so${BLUE} command with arguments. (${CYAN}su -soh${NC} for more info)\n"
    return 1
    fi
}

so() {
  if [[ -z "$1" ]]; then
    fsu
  else
    sudo -f "$*"
  fi
}

fsu() {
  su --quick-run-no-validation
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
    err "No arguments given\n"
  elif [[ $1 == "is" ]]; then
    shift
    whatis "$@"
  else
    whatis "$@"
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
    err "No operation given, pass -h for help.\n\n"
    return 1
    elif [[ "$file_opt" == "-h" ]]; then
      pf "
      Edit zsh.d configuration files
      Usage:

      ${BLUE}f/fu/fun${NC} to edit functions.
      ${BLUE}al/alias${NC} to edit aliases.
      ${BLUE}a/at/au/ast${NC} to edit autostart.
      ${BLUE}e/ex/exp${NC} to edit exports.
      ${BLUE}h/ho/hook${NC} to edit hooks.
      ${BLUE}k/key/ky/binds${NC} to edit keybinds.
      ${BLUE}pkg/pcheck/pgc${NC} to edit pkgchecks.
      ${BLUE}p/pl/plug${NC} to edit zsh plugins.
      ${BLUE}t/th/theme${NC} to edit zsh themes.
      ${BLUE}un/una/unal${NC} to edit unaliases.
      ${BLUE}uf/unf/unfun${NC} to edit unfunctions.
      ${BLUE}z/zsh/zs/zshrc${NC} to edit zshrc.
      \n"
      return 0
  fi

  case "$file_opt" in
  f|fu|fun|func|functions)
  $EDITOR $ZDIR/functions.zsh
  ;;
  al|alias|aliases)
  $EDITOR $ZDIR/aliases.zsh
  ;;
  a|at|au|auto|startup|autostart|ast)
  $EDITOR $ZDIR/autostart.zsh
  ;;
  e|ex|exp|exports)
  $EDITOR $ZDIR/exports.zsh
  ;;
  h|ho|hook|hooks)
  $EDITOR $ZDIR/hooks.zsh
  ;;
  k|key|ky|binds|keybinds|keybind)
  $EDITOR $ZDIR/keybinds.zsh
  ;;
  pkg|pcheck|pgc|pack|package|pa)
  $EDITOR $ZDIR/pkgchecks.zsh
  ;;
  p|pl|plug|plugins|plugin)
  $EDITOR $ZDIR/plugins.zsh
  ;;
  t|th|theme|themes)
  $EDITOR $ZDIR/themes.zsh
  ;;
  un|una|unal|unalias|unaliases)
  $EDITOR $ZDIR/unaliases.zsh
  ;;
  uf|unf|unfun|unfunc|unfu|unfunctions)
  $EDITOR $ZDIR/unfunctions.zsh
  ;;
  z|zsh|zs|zshrc)
  $EDITOR ~/.zshrc
  ;;
  *)
    err "Invalid option, \"$file_opt\". pass -h to show the help screen.\n"
  esac
}

lw() {
  local allargs="$@"
  ldd $(which "$allargs")
}

lzsh() {
  cat $ZDIR/* | wcl
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
				printf "

${BLUE}fcount() - Count files and directories${NC}

${WHITE}Usage: fcount [OPTIONS] [directory...]${NC}

Options:
    ${BLUE}-a, --all${NC}       Include dotfiles in count
    ${BLUE}-s, --silent${NC}    Silent mode: only output total count as integer
    ${BLUE}-h, --help${NC}      Show this help message

Arguments:
    directory       One or more directories to count (default: current directory)

${WHITE}Examples:${NC}
    ${BLUE}fcount${NC}                          Count in current directory
    ${BLUE}fcount /tmp${NC}                     Count in /tmp
    ${BLUE}fcount /tmp /data /sdcard${NC}       Count in multiple directories
    ${BLUE}fcount -a /system /usr${NC}          Count with dotfiles in multiple dirs
    ${BLUE}fcount -s /tmp${NC}                  Silent: just print the number
    ${BLUE}fcount -sa /tmp${NC}                 Silent with dotfiles
    ${BLUE}fcount -s -a /tmp${NC}               Silent with dotfiles (alt syntax)
    
"
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
	
	if [[ "$silent" == true ]]; then
		local total=0 failed=0 dir
		
		for dir in "${target_dirs[@]}"; do
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
		
		printf "%d" "$total"
		
		[[ "$failed" -gt 0 ]] && return 1
		return 0
	fi
	
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

  local silent=0
  if [[ "$1" == "-s" ]] || [[ "${@: -1}" == "-s" ]]; then
    silent=1
    set -- "${@:#-s}"
  fi

  (($# == 0)) && { 
    ((silent)) || printf "stderr: argc !>=1\n" >&2
    return 1
  }

  if ((silent)); then
    local all_libs=() missing_count=0 bin
    for bin in "$@"; do
      if ! findLibPaths "$bin" >/dev/null 2>&1; then
        ((missing_count++))
        continue
      fi
      while IFS= read -r lib; do
        all_libs+=("$lib")
      done < <(findLibPaths "$bin")
    done

    ((${#all_libs[@]} > 0)) && {
      printf "%s" "${all_libs[1]}"
      local lib
      for lib in "${all_libs[@]:1}"; do
        printf " %s" "$lib"
      done
    }

    ((missing_count > 0)) && return 1
    return 0
  fi

  local bin missing=() first=1
  for bin in "$@"; do
    if ! findLibPaths "$bin" >/dev/null 2>&1; then
      missing+=("$bin")
      continue
    fi

    ((first)) && first=0 || printf "\n"

    printf "%s:\n" "$bin"
    findLibPaths "$bin" | sort -u
  done

  ((first)) || printf "\n\n\n"

  ((${#missing[@]} > 0)) && {
    printf "stderr: the following files were not found:\n" >&2
    printf "  %s\n" "${missing[@]}" >&2
  }
}

alt() {

  if [[ $PKG == "apt" ]]; then
    if ! command -v nala >/dev/null 2>&1; then
        err "Uh-Oh! nala not found, can be installed by running:\n apt install nala\n"
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
    err "Uh-Oh! this wrapper script was made for apt, and it seems you are using something different.\n"
    return 1
  fi
  }

rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bgrgb() { printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"; }
