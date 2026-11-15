// webcam_bridge — expose the santoni camera to the Ubuntu chroot as MJPEG.
//
// SKELETON. The capture path below is complete enough to compile and to open
// the camera; the JPEG encode, the repeating request and the socket server are
// marked TODO. Nothing here is enabled in the build: see Android.bp.disabled.
//
// Why not /dev/video*: the MSM8937 camera stack on this device is not V4L2.
// /dev/video0..3 are the legacy msm vidc nodes, not UVC capture devices, so
// ffmpeg -f v4l2 and v4l2loopback cannot read them. The only supported entry
// point is the Camera2 NDK, which talks to cameraserver over binder.

#include <android/log.h>
#include <android/native_window.h>
#include <camera/NdkCameraCaptureSession.h>
#include <camera/NdkCameraDevice.h>
#include <camera/NdkCameraManager.h>
#include <media/NdkImage.h>
#include <media/NdkImageReader.h>

#include <cstdint>

#define LOG_TAG "webcam_bridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace {

constexpr int32_t kWidth = 640;
constexpr int32_t kHeight = 480;
constexpr int32_t kFormat = AIMAGE_FORMAT_YUV_420_888;
constexpr int32_t kMaxImages = 4;

struct Bridge {
    ACameraManager* manager = nullptr;
    ACameraDevice* device = nullptr;
    AImageReader* reader = nullptr;
    ACameraOutputTarget* target = nullptr;
    ACaptureSessionOutput* sessionOutput = nullptr;
    ACaptureSessionOutputContainer* outputs = nullptr;
    ACameraCaptureSession* session = nullptr;
};

void onDeviceDisconnected(void*, ACameraDevice*) {
    LOGE("camera disconnected");
}

void onDeviceError(void*, ACameraDevice*, int error) {
    LOGE("camera error %d", error);
}

ACameraDevice_StateCallbacks kDeviceCallbacks = {
    nullptr,
    onDeviceDisconnected,
    onDeviceError,
};

void onSessionClosed(void*, ACameraCaptureSession*) {
    LOGI("capture session closed");
}

void onSessionReady(void*, ACameraCaptureSession*) {
    LOGI("capture session ready");
}

ACameraCaptureSession_stateCallbacks kSessionCallbacks = {
    nullptr,
    onSessionClosed,
    onSessionReady,
};

// TODO: encode the YUV_420_888 planes into a JPEG and hand the frame to the
// MJPEG client. The NDK ships no JPEG encoder, so this needs a prebuilt
// libjpeg-turbo or a baseline encoder written by hand.
void onImage(void*, AImageReader* reader) {
    AImage* image = nullptr;
    if (AImageReader_acquireNextImage(reader, &image) != AMEDIA_OK || image == nullptr) {
        return;
    }
    int32_t width = 0;
    int32_t height = 0;
    AImage_getWidth(image, &width);
    AImage_getHeight(image, &height);
    LOGI("frame %dx%d", width, height);
    AImage_delete(image);
}

}  // namespace

int main() {
    Bridge bridge;

    bridge.manager = ACameraManager_create();
    if (bridge.manager == nullptr) {
        LOGE("ACameraManager_create failed");
        return 1;
    }

    ACameraIdList* ids = nullptr;
    if (ACameraManager_getCameraIdList(bridge.manager, &ids) != ACAMERA_OK || ids == nullptr) {
        LOGE("no camera ids");
        return 1;
    }
    LOGI("%d camera(s) reported", ids->numCameras);
    if (ids->numCameras == 0) {
        ACameraManager_deleteCameraIdList(ids);
        return 1;
    }

    const char* id = ids->cameraIds[0];
    if (ACameraManager_openCamera(bridge.manager, id, &kDeviceCallbacks, &bridge.device) !=
        ACAMERA_OK) {
        LOGE("openCamera(%s) failed", id);
        ACameraManager_deleteCameraIdList(ids);
        return 1;
    }
    ACameraManager_deleteCameraIdList(ids);

    if (AImageReader_new(kWidth, kHeight, kFormat, kMaxImages, &bridge.reader) != AMEDIA_OK) {
        LOGE("AImageReader_new failed");
        return 1;
    }
    AImageReader_ImageListener listener{nullptr, onImage};
    AImageReader_setImageListener(bridge.reader, &listener);

    ANativeWindow* window = nullptr;
    AImageReader_getWindow(bridge.reader, &window);

    ACameraOutputTarget_create(window, &bridge.target);
    ACaptureSessionOutput_create(window, &bridge.sessionOutput);
    ACaptureSessionOutputContainer_create(&bridge.outputs);
    ACaptureSessionOutputContainer_add(bridge.outputs, bridge.sessionOutput);

    if (ACameraDevice_createCaptureSession(bridge.device, bridge.outputs, &kSessionCallbacks,
                                           &bridge.session) != ACAMERA_OK) {
        LOGE("createCaptureSession failed");
        return 1;
    }

    // TODO: build the repeating request from the first
    // ACAMERA_REQUEST_AVAILABLE_CAPABILITIES entry that reports
    // ACAMERA_REQUEST_AVAILABLE_CAPABILITIES_BACKWARD_COMPATIBLE, then call
    // ACameraCaptureSession_setRepeatingRequest().
    //
    // TODO: serve the encoded frames on 127.0.0.1:8080 as
    // multipart/x-mixed-replace so the chroot can read it with
    //   ffplay http://127.0.0.1:8080/stream.mjpg

    LOGI("skeleton reached the end of main(); nothing is streaming yet");
    return 0;
}
