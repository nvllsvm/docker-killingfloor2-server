#!/usr/bin/env bash
set -e

STEAM_APPID=232130

SERVER_DIR=/data/server
STEAMCMD_DIR=/data/steamcmd

function steamcmd() {
    mkdir -p "$STEAMCMD_DIR"
    if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
        wget -q -O - https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf - -C "$STEAMCMD_DIR"
    fi
    "$STEAMCMD_DIR/steamcmd.sh" "$@"
}

function require_kf2() {
    if [ ! -f "$SERVER_DIR/Binaries/Win64/KFServer.exe" ]; then
        steamcmd \
            +login anonymous \
            +force_install_dir "$SERVER_DIR" \
            +app_update "$STEAM_APPID" validate \
            +exit
    fi
}

function update() {
    steamcmd \
        +login anonymous \
        +force_install_dir "$SERVER_DIR" \
        +app_update "$STEAM_APPID" "$@" \
        +exit
}

function require_config() {
    # Generate INI files
    if [ ! -f "$SERVER_DIR/KFGame/Config/PCServer-KFGame.ini" ]; then
        "$SERVER_DIR/Binaries/Win64/KFGameSteamServer.bin.x86_64" kf-bioticslab?difficulty=0?adminpassword=secret?gamepassword=secret -port=7777 &
        sleep 20
        kfpid=$(pgrep -f port=7777)
        kill $kfpid
        # Workaround as per https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_%28Killing_Floor_2%29#Setting_Up_Steam_Workshop_For_Servers
        mkdir -p "$SERVER_DIR/KFGame/Cache"
    fi

}

function load_config() {
    # Default to survival
    export KF_GAME_MODE="${KF_GAME_MODE:-Survival}"
    if [ "$KF_GAME_MODE" = 'VersusSurvival' ]; then
        KF_GAME_MODE='VersusSurvival?maxplayers=12'
    fi

    # find /path/to/volume -name '*KF-*kfm' | xargs -n 1 basename -s .kfm\n"
    export KF_MAP="${KF_MAP:-KF-BioticsLab}"

    # 0 - normal, 1 - hard, 2 - suicidal, 3 - hell on earth
    export KF_DIFFICULTY="${KF_DIFFICULTY:-0}"

    # Used for web console and in-game logins
    export KF_ADMIN_PASS="${KF_ADMIN_PASS:-secret}"

    # Setting this creates a private server
    export KF_GAME_PASS="${KF_GAME_PASS}"

    # 0 - 4 waves, 1 - 7 waves, 2 - 10 waves, default 1
    export KF_GAME_LENGTH="${KF_GAME_LENGTH:-0}"

    # Name that appears in the server browser
    export KF_SERVER_NAME="${KF_SERVER_NAME:-Killing Floor 2}"

    # true or false, default false
    export KF_ENABLE_WEB="${KF_ENABLE_WEB:-false}"

    export KF_PORT="${KF_PORT:-7777}"
    export KF_QUERY_PORT="${KF_QUERY_PORT:-27015}"
    export KF_WEBADMIN_PORT="${KF_WEBADMIN_PORT:-8080}"


    ## Now we edit the config files to set the config
    sed -i "s/^GameLength=.*/GameLength=$KF_GAME_LENGTH\r/" "$SERVER_DIR/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^ServerName=.*/ServerName=$KF_SERVER_NAME\r/" "$SERVER_DIR/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^bEnabled=.*/bEnabled=$KF_ENABLE_WEB\r/" "$SERVER_DIR/KFGame/Config/KFWeb.ini"
    if [ "${KF_DISABLE_TAKEOVER}" = 'true' ]; then
        sed -i 's/^bUsedForTakeover=.*/bUsedForTakeover=FALSE'"\r"'/' "$SERVER_DIR/KFGame/Config/LinuxServer-KFEngine.ini"
    fi
    sed -i "s/^DownloadManagers=IpDrv.HTTPDownload/DownloadManagers=OnlineSubsystemSteamworks.SteamWorkshopDownload/" "$SERVER_DIR/KFGame/Config/LinuxServer-KFEngine.ini"
}

function launch() {
    export WINEDEBUG=fixme-all
    local cmd

    cmd="$SERVER_DIR/Binaries/Win64/KFGameSteamServer.bin.x86_64 "
    cmd+="$KF_MAP?Game=KFGameContent.KFGameInfo_$KF_GAME_MODE"
    cmd+="?Difficulty=$KF_DIFFICULTY"
    cmd+="?AdminPassword=$KF_ADMIN_PASS"
    if [ "$KF_GAME_PASS" ]; then
        cmd+="?GamePassword=$KF_GAME_PASS"
    fi
    cmd+=" -Port=$KF_PORT"
    cmd+=" -WebAdminPort=$KF_WEBADMIN_PORT"
    cmd+=" -QueryPort=$KF_QUERY_PORT"

    echo "Running command: $cmd" > $0-cmd.log
    exec $cmd
}

mkdir -p server

require_kf2
if [ "$1" = 'update' ]; then
    shift
    update "$@"
fi
require_config
load_config
launch
