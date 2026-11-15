# sensor-bridge — sensors into the Ubuntu chroot

**Status: skeleton, not built.** `Android.bp.disabled` keeps Soong from parsing
this directory.

## What it does

Opens `ASensorManager`, enables the accelerometer, gyroscope, magnetometer and
proximity sensors the device reports, and appends one line per sample to
`/data/ubuntu/tmp/sensors.log`:

```
accel 0.123456 -0.234567 9.789012
gyro  0.001234 -0.000987 0.000456
mag   -12.345678 34.567890 -5.678901
prox  0.000000
```

The chroot reads or tails that file instead of touching `/dev/input`.

## Why not `/dev/input`

`/dev/input/event*` is owned by `system:input` and the Android input stack
already has those devices open. A chroot process reading them competes with
`system_server` for the same evdev queue, and events are split between the two
readers rather than duplicated. `ASensorManager` is the supported path.

## What is missing

- The file is append-only and never rotated. A device left running for days
  will grow it without bound; add a size check or switch to a unix socket
  before leaving this on.
- Only the four types above are handled. Add cases in `write_event()` for
  whatever else the device reports.
