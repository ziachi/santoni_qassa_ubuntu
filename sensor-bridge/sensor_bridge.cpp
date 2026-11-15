// sensor_bridge — mirror the santoni sensors into the Ubuntu chroot.
//
// SKELETON. Opens ASensorManager, enables the sensors the device reports, and
// appends one line per sample to /data/ubuntu/tmp/sensors.log. Nothing here is
// enabled in the build: see Android.bp.disabled.
//
// The chroot cannot read /dev/input directly: those nodes are owned by
// system:input and the Android input stack already has them open, so a second
// reader splits the event stream instead of duplicating it. ASensorManager is
// the supported path.

#include <android/log.h>
#include <android/looper.h>
#include <android/sensor.h>

#include <cstdint>
#include <cstdio>

#define LOG_TAG "sensor_bridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace {

constexpr const char* kOutPath = "/data/ubuntu/tmp/sensors.log";
constexpr int32_t kLooperId = 1;
constexpr int32_t kSampleUs = 200000;  // 5 Hz

void write_event(FILE* out, const ASensorEvent& event) {
    switch (event.type) {
        case ASENSOR_TYPE_ACCELEROMETER:
            std::fprintf(out, "accel %.6f %.6f %.6f\n", event.acceleration.x,
                         event.acceleration.y, event.acceleration.z);
            break;
        case ASENSOR_TYPE_GYROSCOPE:
            std::fprintf(out, "gyro %.6f %.6f %.6f\n", event.vector.x, event.vector.y,
                         event.vector.z);
            break;
        case ASENSOR_TYPE_MAGNETIC_FIELD:
            std::fprintf(out, "mag %.6f %.6f %.6f\n", event.magnetic.x, event.magnetic.y,
                         event.magnetic.z);
            break;
        case ASENSOR_TYPE_PROXIMITY:
            std::fprintf(out, "prox %.6f\n", event.distance);
            break;
        default:
            return;
    }
    std::fflush(out);
}

}  // namespace

int main() {
    FILE* out = std::fopen(kOutPath, "a");
    if (out == nullptr) {
        LOGE("cannot open %s", kOutPath);
        return 1;
    }

    ASensorManager* manager = ASensorManager_getInstance();
    if (manager == nullptr) {
        LOGE("ASensorManager_getInstance failed");
        return 1;
    }

    ALooper* looper = ALooper_prepare(ALOOPER_PREPARE_ALLOW_NON_CALLBACKS);
    ASensorEventQueue* queue =
        ASensorManager_createEventQueue(manager, looper, kLooperId, nullptr, nullptr);
    if (queue == nullptr) {
        LOGE("createEventQueue failed");
        return 1;
    }

    const int32_t types[] = {
        ASENSOR_TYPE_ACCELEROMETER,
        ASENSOR_TYPE_GYROSCOPE,
        ASENSOR_TYPE_MAGNETIC_FIELD,
        ASENSOR_TYPE_PROXIMITY,
    };

    int enabled = 0;
    for (int32_t type : types) {
        ASensor* sensor = ASensorManager_getDefaultSensor(manager, type);
        if (sensor == nullptr) {
            LOGI("no sensor for type %d", type);
            continue;
        }
        if (ASensorEventQueue_enableSensor(queue, sensor) != 0) {
            LOGE("enableSensor(%s) failed", ASensor_getName(sensor));
            continue;
        }
        ASensorEventQueue_setEventRate(queue, sensor, kSampleUs);
        LOGI("enabled %s", ASensor_getName(sensor));
        ++enabled;
    }

    if (enabled == 0) {
        LOGE("no sensors enabled, exiting");
        return 1;
    }

    for (;;) {
        int events = 0;
        void* data = nullptr;
        int ident = ALooper_pollAll(-1, nullptr, &events, &data);
        if (ident != kLooperId) {
            continue;
        }
        ASensorEvent event;
        while (ASensorEventQueue_getEvents(queue, &event, 1) > 0) {
            write_event(out, event);
        }
    }
}
