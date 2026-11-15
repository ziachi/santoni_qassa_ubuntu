# audio-bridge — speaker and mic for the Ubuntu chroot

**Status: config only, no binary.** `Android.bp.disabled` keeps Soong from
parsing this directory.

## What is here

`pulse-default.pa` is a PulseAudio server config that:

- listens on a unix socket at `/data/ubuntu/tmp/pulse.sock`, so both the
  Android side and the chroot can reach it without a bind mount of `/run`;
- loads `module-sles-sink` and `module-sles-source` for output and capture
  through OpenSL ES, which is the only audio path the Android HAL exposes to a
  non-framework process.

## What is NOT here

**The PulseAudio arm64 binary and the OpenSL ES modules are not in this tree.**
`module-sles-sink` and `module-sles-source` are not upstream PulseAudio
modules; they have to be built or obtained separately and dropped into
`/data/ubuntu/usr/lib/pulse-*/modules/`. Nothing in this directory fabricates
them, and the config will fail to load until they exist.

Check what is actually available before wiring anything up:

```bash
chroot /data/ubuntu /bin/bash -lc 'pulseaudio --version; ls /usr/lib/pulse-*/modules/'
```

## Why not just bind `/dev/snd`

`/dev/snd/*` is owned by `audio:audio` and the Android audio HAL holds the PCM
devices open. A chroot process opening them directly gets `EBUSY` or silence,
and it bypasses the HAL's routing. Going through OpenSL ES keeps the HAL in
charge of the mixer and the output path.
