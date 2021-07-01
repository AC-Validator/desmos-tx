#!/bin/bash

cli="desmos"
chainid="morpheus-apollo-1"
mykey="xxxxx"
mykey_psw="yyyyy"
value="000udaric"
skip="desmos1xxxxxxx" # Self-Delegate Address to skip

LOG="/tmp/desmos-tx-staking.log"

SLEEP="10"

while true
do
        STAKING=`shuf -i 1-2 -n 1`      # 1 or 2

        TOKEN_RAND=`shuf -i 1-9 -n 1`   # 1 to 9
        TOKENS="$TOKEN_RAND$value"

        #FEE_RAND=`shuf -i 0-5 -n 1`    # 0 to 5
        FEE_RAND=`shuf -i 1-5 -n 1`     # 1 to 5

        if [ $FEE_RAND != 0 ]; then
                FEES="--fees $FEE_RAND$value"
        else
                FEES=""
        fi

        VALIDATORS_COUNT=`$cli query staking validators | grep operator_address | wc -l`
        VALIDATOR_RANDOM=`shuf -i 1-$VALIDATORS_COUNT -n 1`
        VALIDATOR=`$cli query staking validators | grep operator_address | awk '{print$2}' | sed -n "${VALIDATOR_RANDOM}p"`

        TIME=$(date +'%Y/%m/%d %H.%M.%S:')

        if [ $STAKING == 1 ]; then
                echo "$TIME Validators: $VALIDATORS_COUNT Random: $VALIDATOR_RANDOM Delegating to: $VALIDATOR $TOKENS $FEES"  >>$LOG
                (sleep 1; echo $mykey_psw; sleep 1; echo $mykey_psw) | $cli tx staking delegate $VALIDATOR $TOKENS --from $mykey --chain-id $chainid $FEES --yes | jq -r '.txhash' >>$LOG
        else
                if [ $VALIDATOR == $skip ]; then
                        echo "$TIME Validators: $VALIDATORS_COUNT Random: $VALIDATOR_RANDOM Unbonding to: $VALIDATOR $TOKENS $FEES"  >>$LOG
                        echo "SKIPPING $VALIDATOR"
                else
                        echo "$TIME Validators: $VALIDATORS_COUNT Random: $VALIDATOR_RANDOM Unbonding to: $VALIDATOR $TOKENS $FEES"  >>$LOG
                        (sleep 1; echo $mykey_psw; sleep 1; echo $mykey_psw) | $cli tx staking unbond $VALIDATOR $TOKENS --from $mykey --chain-id $chainid $FEES --yes | jq -r '.txhash' >>$LOG
                fi
        fi

        sleep $SLEEP
done
