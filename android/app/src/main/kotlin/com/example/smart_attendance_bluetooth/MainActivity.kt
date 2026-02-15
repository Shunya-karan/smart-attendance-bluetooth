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

    private val CHANNEL = "teacher_ble"
    private var isBleRunning = false

    private lateinit var channel: MethodChannel
    private lateinit var bluetoothManager: BluetoothManager
    private lateinit var bluetoothAdapter: BluetoothAdapter
    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    private val SERVICE_UUID =
        UUID.fromString("df3dca32-611e-4130-ad8c-df64d8d867c9")

    private val ATTENDANCE_UUID =
        UUID.fromString("52912853-4e88-42e0-a12b-abdcffc7ebd5")

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

    override fun onDestroy() {
        stopBleServer()
        super.onDestroy()
    }


    // ---------------- BLE SERVER ----------------

    private fun startBleServer(sessionCode: String) {
        if (isBleRunning) {
            Log.w("BLE", "BLE already running")
            return
        }

        bluetoothManager =
            getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter

        if (!bluetoothAdapter.isEnabled) {
            Log.e("BLE", "Bluetooth disabled")
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
        gattServer?.clearServices()

        gattServer?.addService(service)

        startAdvertising(sessionCode)

        isBleRunning = true
        Log.d("BLE", "BLE server started with session: $sessionCode")
    }

    private fun stopBleServer() {
        if (!isBleRunning) return

        advertiser?.stopAdvertising(advertiseCallback)
        advertiser = null

        gattServer?.close()
        gattServer = null

        isBleRunning = false
        Log.d("BLE", "BLE server stopped")
    }

    // ---------------- ADVERTISING ----------------

    private fun startAdvertising(sessionCode: String) {
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .build()

        val payloadBytes = sessionCode.toByteArray(Charsets.UTF_8)

        val data = AdvertiseData.Builder()
            .addManufacturerData(0x1234, payloadBytes)
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

            mainHandler.post {
                channel.invokeMethod("attendanceMarked", attendanceData)
            }

            if (responseNeeded) {
                gattServer?.sendResponse(
                    device,
                    requestId,
                    BluetoothGatt.GATT_SUCCESS,
                    0,
                    byteArrayOf()
                )
            }
        }
    }
}
