package com.example.smart_attendance_bluetooth

import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {
    private var isBleRunning = false
    private val CHANNEL = "teacher_ble"

    private lateinit var channel: MethodChannel
    private lateinit var bluetoothManager: BluetoothManager
    private lateinit var bluetoothAdapter: BluetoothAdapter
    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    private val SERVICE_UUID =
        UUID.fromString("00001810-0000-1000-8000-00805f9b34fb")

    private val ATTENDANCE_UUID =
        UUID.fromString("00002a35-0000-1000-8000-00805f9b34fb")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startSession" -> {
                val args = call.arguments as Map<*, *>

                val sessionCode = args["sessionCode"] as String

                startBleServer(sessionCode)
                result.success(null)
}

                "stopSession" -> {
                    stopBleServer()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ---------------- BLE SERVER ----------------

private fun startBleServer(
        sessionCode: String?,
) {
    if (isBleRunning) {
        Log.w("BLE", "BLE already running, ignoring start")
        return
    }

    isBleRunning = true

    bluetoothManager =
        getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    bluetoothAdapter = bluetoothManager.adapter

    if (!bluetoothAdapter.isEnabled) {
        isBleRunning = false
        return
    }

    advertiser = bluetoothAdapter.bluetoothLeAdvertiser
    gattServer = bluetoothManager.openGattServer(this, gattCallback)

    val service = BluetoothGattService(
        SERVICE_UUID,
        BluetoothGattService.SERVICE_TYPE_PRIMARY
    )

    val attendanceChar = BluetoothGattCharacteristic(
        ATTENDANCE_UUID,
        BluetoothGattCharacteristic.PROPERTY_WRITE,
        BluetoothGattCharacteristic.PERMISSION_WRITE
    )

    service.addCharacteristic(attendanceChar)
    gattServer?.addService(service)

    bluetoothAdapter.name = sessionCode


    startAdvertising(sessionCode!!)


    Log.d("BLE", "BLE server started")
}


private fun stopBleServer() {
    if (!isBleRunning) return

    advertiser?.stopAdvertising(advertiseCallback)
    gattServer?.close()
    gattServer = null
    isBleRunning = false

    Log.d("BLE", "BLE server stopped")
}


    // ---------------- ADVERTISING ----------------

    private fun startAdvertising(
    sessionCode: String,
) {
    val settings = AdvertiseSettings.Builder()
        .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
        .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
        .setConnectable(true)
        .build()

    // 🔥 Build small session payload
    val sessionPayload = "$sessionCode"
    val payloadBytes = sessionPayload.toByteArray(Charsets.UTF_8)

    val data = AdvertiseData.Builder()
        .addServiceUuid(ParcelUuid(SERVICE_UUID))
        .addManufacturerData(0x1234, payloadBytes) // company ID (any 16-bit)
        .setIncludeDeviceName(true)
        .build()

    advertiser?.startAdvertising(settings, data, advertiseCallback)
}


    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            Log.d("BLE", "Advertising started")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.e("BLE", "Advertising failed: $errorCode")
        }
    }

    // ---------------- GATT CALLBACK ----------------

    private val gattCallback = object : BluetoothGattServerCallback() {

        override fun onConnectionStateChange(
            device: BluetoothDevice,
            status: Int,
            newState: Int
        ) {
            Log.d("BLE", "Device ${device.address} state: $newState")
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray
        ) {
            val attendanceData = String(value)
            Log.d("BLE", "Attendance received: $attendanceData")

            // 🔥 Send data to Flutter SAFELY
            mainHandler.post {
                channel.invokeMethod("attendanceMarked", attendanceData)
            }

            if (responseNeeded) {
                gattServer?.sendResponse(
                    device,
                    requestId,
                    BluetoothGatt.GATT_SUCCESS,
                    0,
                    null
                )
            }
        }
    }
}
