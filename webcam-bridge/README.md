# webcam-bridge — camera to the Ubuntu chroot

**Status: skeleton, not built.** `Android.bp.disabled` keeps Soong from parsing
this directory. Rename it to `Android.bp` and drop `enabled: false` to build.

## Why not `/dev/video*`

The MSM8937 camera stack on santoni is not V4L2/UVC. `/dev/video0..3` are the
legacy msm vidc nodes used by the old camera daemon, not capture devices that
`ffmpeg -f v4l2` or `v4l2loopback` can open. Reading them yields nothing
useful. The only supported entry point is the Camera2 NDK, which talks to
`cameraserver` over binder.

## What is missing

- **JPEG encode.** `onImage()` receives a `YUV_420_888` frame and logs its
  size. The NDK has no JPEG encoder, so this needs a prebuilt `libjpeg-turbo`
  or a baseline encoder written by hand. Do not stub it out and call it done.
- **Repeating request.** `main()` stops after creating the capture session. The
  request has to be built from
  `ACAMERA_REQUEST_AVAILABLE_CAPABILITIES_BACKWARD_COMPATIBLE` and handed to
  `ACameraCaptureSession_setRepeatingRequest()`.
- **MJPEG server.** Nothing listens on a socket yet. The target is
  `127.0.0.1:8080` with `multipart/x-mixed-replace`, so the chroot can read it
  with `ffplay http://127.0.0.1:8080/stream.mjpg`.

## UID caveat

`cameraserver` runs as `cameraserver` and the camera HAL as `camera`. This
binary is meant to run on the Android side, not from inside the chroot. If it
is ever started as root from the chroot, check the UID first: the camera
service rejects clients that are not in the `camera` group, and a root process
without that group gets `ACAMERA_ERROR_CAMERA_DISCONNECTED` with no useful
message. Run it as `camera` (or add the group) instead of debugging the
permission failure blind.
