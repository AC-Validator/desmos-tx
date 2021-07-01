#!/bin/bash

cli="desmos"
chainid="morpheus-apollo-1"
mykey="xxxxxx"
mykey_psw="yyyyyy"
value="000udaric"

LOG="/tmp/desmos-tx-bank-send.log"
SLEEP="30"

while true
do
        TOKEN_RAND=`shuf -i 1-9 -n 1`   # 1 to 9
        TOKENS="$TOKEN_RAND$value"

        #FEE_RAND=`shuf -i 0-5 -n 1`    # 0 to 5
        FEE_RAND=`shuf -i 1-5 -n 1`     # 1 to 5

        if [ $FEE_RAND != 0 ]; then
                FEES="--fees $FEE_RAND$value"
        else
                FEES=""
        fi

        DESTINATION=`$cli keys add destination --dry-run  2>&1 | grep address | awk '{print$2}'`

        TIME=$(date +'%Y/%m/%d %H.%M.%S:')
        echo "$TIME Sending $TOKENS to $DESTINATION $FEES" >>$LOG
        (sleep 1; echo $mykey_psw; sleep 1; echo $mykey_psw) | $cli tx bank send $mykey $DESTINATION $TOKENS --chain-id $chainid $FEES --yes | jq -r '.txhash' >>$LOG

        sleep $SLEEP
done
