#!/bin/bash

set -e
set -u

print(){
  if [ -z "$SILENT" ] 
  then
    echo "$@"
  fi
}

print "Running with:

  EPOCH:        $EPOCH
  POOL_ID:      $POOL_ID
  TIME_ZONE:    $TIME_ZONE
  LEDGER_STATE: $LEDGER_JSON (RUN: cardano-cli shelley query ledger-state --mainnet --out-file ledger.json)
  VRF_SKEY:     $VRF_SKEY (Path to vrf.skey)
  SIGMA:        ${SIGMA:-to be calculated}

NOTE: The left hand names are all environment variable names! 
      Silence this (and the following) messages with 'docker run ... -e "SILENT=true" ...'

"

if [ -z "${SIGMA}" ]
then

  CMD="python3 getSigma.py --pool-id '$POOL_ID' --ledger '$LEDGER_JSON' --porcelain | jq .sigma  | xargs echo"
  print "$CMD"
  SIGMA=`bash -c "$CMD"`

  print
fi

EXTRA_ARGS="$EXTRA_ARGS"

CMD="python3 leaderLogs.py --epoch '$EPOCH' --pool-id '$POOL_ID' --vrf-skey '$VRF_SKEY' --sigma '$SIGMA' --tz '$TIME_ZONE'  --porcelain $EXTRA_ARGS"
print "$CMD"
bash -c "$CMD"
