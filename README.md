# Slot Leader Docker

Expanding on papacarp's pooltool.io repo and specifically on the leaderLogs
scripts, this repo provides a dockerized version of `leaderLogs.py` intended
for programmatic use.

> NOTE: This currently only supports the mainnet!

## Usage

To just run slot-leader once run:
```
docker run -ti --rm \
	-e POOL_ID=079c...YOUR_POOL_ID_HEX...2791 \
	-v /path/to/your/ledger.json:/ledger.json \
	-v /path/to/your/vrf.skey:/vrf.skey \
	spectrumpool/slot-leader
```
This will download current epoch info from _epoch-api_ (see below on how to 
circumvent), calculate `σ` and play through the epoch checking if your pool
is slot leader for each slot.

To use it programmatically make sure to set the `SILENT` variable to `"true"`
```
docker run -ti --rm \
	-e SILENT=true \
	-e POOL_ID=079c374160b0ae34a5a20b8e95a5b5c8766239b2984f13d7ab962791 \
	-v /path/to/your/ledger.json:/ledger.json \
	-v /path/to/your/vrf.skey:/vrf.skey \
	spectrumpool/slot-leader
```

### Output

```
[
	{
		"timestamp": "2020-10-07 16:36:02", 
		"timestamp_unix": 1602088562.0, 
		"stolen": false, 
		"epochSlot": 406271
	}
]
```

The main output of the `spectrumpool/slot-leader` container is a JSON list
of slots for which your pool is _slot leader_. The slot objects include a
human readable timestamp, a unix timestamp and a boolean field indicating if
this slot gets stolen by the legacy BFT protocol.

Without the `SILENT` flag some human oriented output is produced. In silent
mode only the list of slots for which your pool will be slotleader will be 
printed out.

### Other Input

You can pass an explicit `SIGMA` value which will circumvent the `σ`
calculation.
```
docker run -ti --rm \
	-e SILENT=true \
	-e SIGMA=0.0000197962 \
	-e POOL_ID=079c374160b0ae34a5a20b8e95a5b5c8766239b2984f13d7ab962791 \
	-v /path/to/your/ledger.json:/ledger.json \
	-v /path/to/your/vrf.skey:/vrf.skey \
	spectrumpool/slot-leader
```

### Epochs, Epoch API dependency & Extra Arguments

You can steer wich epoch gets calculated via the `EPOCH` and `EPOCH_NONCE` env
varliables. Since `SIGMA` can only be calculated for the current epoch, it is
required to add these three env vars together.

This container is per default dependent on _epoch-api.crypto2099.io_ for the
epoch nonces. In case you add the `EPOCH` and `EPOCH_NONCE` env vars manually,
the call to _epoch-api_ is completely circumvented.

```
docker run -ti --rm \
	-e SILENT=true \
	-e SIGMA=0.0000065 \
	-e POOL_ID=079c374160b0ae34a5a20b8e95a5b5c8766239b2984f13d7ab962791 \
        -e EXTRA_ARGS="--epoch 221 --epoch-nonce 5ee77854fe91cc243b8d5589de3192e795f162097dba7501f8d1b0d5d7546bd5 --d-param 0.62" \
	-v /path/to/your/ledger.json:/ledger.json \
	-v /path/to/your/vrf.skey:/vrf.skey \
	spectrumpool/slot-leader
```

You can also pass arbitrary arguments to leaderLogs.py via the `EXTRA_ARGS` variable

### Real World Compose Config

I run this on the start of each epoch via a systemd timer and service.
Take a look at [KIND Article (TBD)]() for more details on this.

```
services:
  slot-leader:
    image: spectrumpool/slot-leader
    environment:
      POOL_ID: 079c374160b0ae34a5a20b8e95a5b5c8766239b2984f13d7ab962791
    volumes:
    - /var/lib/cn/run/ledger.json:/ledger.json
    - /var/lib/vrf.skey:/vrf.skey
```

## I don't trust your $%!@# container!

And that is fine. Just 
`git clone --recursive https://github.com/SpectrumPool/slot-leader-docker.git`
and build it yourself! ;-)

## Thanks

Thanks to Andrew Westberg [BCSH] and Papacarp [LOVE] for creating and hosting
the meat of this container.
