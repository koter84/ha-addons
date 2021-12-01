#!/usr/bin/with-contenv bashio

declare -a ebusd_args

# boolean options
declare options=( "readonly" "scanconfig" "foreground" "mqttjson" "mqttlog" "mqttretain" )
for optName in "${options[@]}"
do
    if bashio::config.true ${optName}; then
        ebusd_args+=("--$optName")
    fi
done

# other options
declare options=( "latency" "logareas" "loglevel" "mqtthost" "mqttport" "mqttuser" "mqttpass" )
for optName in "${options[@]}"
do
    if ! bashio::config.is_empty ${optName}; then
        ebusd_args+=("--${optName}=$(bashio::config ${optName})")
    fi
done

# device options
if ! bashio::config.is_empty 'device_usb'; then
    ebusd_args+=("--device=$(bashio::config 'device_usb')")
elif ! bashio::config.is_empty 'device_custom'; then
    ebusd_args+=("--device=$(bashio::config 'device_custom')")
else
	bashio::log.fatal "either device_usb or device_custom needs to be set"
	exit
fi

# port options
ebusd_args+=("--port=8888")
ebusd_args+=("--httpport=8889")

# uhm, this doesn't work, since that would be the external port...
#ebusd_args+=("--port=$(bashio::addon.port '8888/tcp')")
#ebusd_args+=("--httpport=$(bashio::addon.port '8889/tcp')")


if bashio::config.false "foreground" || bashio::config.is_empty "foreground"; then
    bashio::config.suggest.true "foreground" "ebusd add-on will stop if ebusd is not running in the foreground."
fi

if ! (bashio::config.equals "loglevel" "error" || bashio::config.is_empty "foreground"); then
    bashio::config.suggest "loglevel" "Consider setting the loglevel to 'error'."
fi

echo "> ebusd ${ebusd_args[*]}"

ebusd ${ebusd_args[*]}
